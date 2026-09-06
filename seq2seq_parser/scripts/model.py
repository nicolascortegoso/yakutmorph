"""BiRNN encoder + Luong global-attention decoder with input feeding
(Luong et al. 2015, "Effective Approaches to Attention-based NMT"), plus a
copy/pointer mechanism (See et al. 2017-style) adapted for two SEPARATE
source/target SentencePiece vocabularies.

Encoder and decoder use separate embedding tables over separate vocabularies
(spm_src / spm_tgt) — the source tokenizer is fit on raw sentences, the
target tokenizer on root text only (see scripts/train_tokenizer.py). Because
the two vocabularies are trained independently there's no shared id space to
copy through directly, so copying is matched by SURFACE STRING instead: a
source position can only be "copied" into a target vocabulary slot whose
piece string is identical to that source piece's string (precomputed as
`src_tgt_map` in dataset.py). Both tokenizers guarantee full character
coverage over the same Yakut alphabet, so this degrades gracefully to
character-level copying in the worst case rather than failing outright for
positions with no larger shared piece.
"""
import torch
import torch.nn as nn
import torch.nn.functional as F

PAD_ID, UNK_ID, BOS_ID, EOS_ID = 0, 1, 2, 3


def _banned_next_tokens(seq, n):
    """Tokens that would complete a repeat of an already-seen n-gram if
    appended to seq now."""
    if len(seq) < n - 1:
        return set()
    seen = {}
    for i in range(len(seq) - n + 1):
        prefix = tuple(seq[i:i + n - 1])
        seen.setdefault(prefix, set()).add(seq[i + n - 1])
    current_prefix = tuple(seq[-(n - 1):]) if n > 1 else ()
    return seen.get(current_prefix, set())


def make_src_mask(src_len, max_len, device):
    """Boolean (B, max_len) mask, True for valid (non-padding) positions,
    built from actual lengths rather than from src's own padding width —
    those can disagree once a sub-batch (e.g. one example sliced out for
    beam search) is narrower than the tensor it was sliced from but still
    carries the wider tensor's trailing padding."""
    return torch.arange(max_len, device=device).unsqueeze(0) < src_len.to(device).unsqueeze(1)


class Encoder(nn.Module):
    def __init__(self, embedding, hid_dim, n_layers, dropout):
        super().__init__()
        self.embedding = embedding
        emb_dim = embedding.embedding_dim
        self.hid_dim = hid_dim
        self.n_layers = n_layers
        self.rnn = nn.GRU(
            emb_dim, hid_dim, num_layers=n_layers, bidirectional=True,
            batch_first=True, dropout=dropout if n_layers > 1 else 0.0,
        )
        # project concatenated [forward;backward] final hidden of each layer
        # down to hid_dim, to seed the (unidirectional) decoder's hidden state
        self.bridge = nn.Linear(hid_dim * 2, hid_dim)
        self.dropout = nn.Dropout(dropout)

    def forward(self, src, src_len):
        emb = self.dropout(self.embedding(src))  # (B, S, E)
        packed = nn.utils.rnn.pack_padded_sequence(
            emb, src_len.cpu(), batch_first=True, enforce_sorted=False
        )
        packed_out, hidden = self.rnn(packed)
        outputs, _ = nn.utils.rnn.pad_packed_sequence(packed_out, batch_first=True)
        # outputs: (B, S, 2*hid_dim)

        # hidden: (n_layers*2, B, hid_dim) -> per layer, concat fwd/bwd -> bridge
        hidden = hidden.view(self.n_layers, 2, -1, self.hid_dim)  # (layers, dirs, B, H)
        hidden = torch.cat([hidden[:, 0], hidden[:, 1]], dim=-1)  # (layers, B, 2H)
        hidden = torch.tanh(self.bridge(hidden))  # (layers, B, H)
        return outputs, hidden


class LuongAttention(nn.Module):
    """General (bilinear) attention: score(h_t, h_s) = h_t^T W_a h_s."""

    def __init__(self, hid_dim, enc_out_dim):
        super().__init__()
        self.attn = nn.Linear(hid_dim, enc_out_dim, bias=False)

    def forward(self, dec_hidden, enc_outputs, src_mask):
        # dec_hidden: (B, H) ; enc_outputs: (B, S, enc_out_dim) ; src_mask: (B, S) True=valid
        query = self.attn(dec_hidden).unsqueeze(2)  # (B, enc_out_dim, 1)
        scores = torch.bmm(enc_outputs, query).squeeze(2)  # (B, S)
        scores = scores.masked_fill(~src_mask, float("-inf"))
        weights = F.softmax(scores, dim=1)  # (B, S)
        context = torch.bmm(weights.unsqueeze(1), enc_outputs).squeeze(1)  # (B, enc_out_dim)
        return context, weights


class Decoder(nn.Module):
    def __init__(self, embedding, hid_dim, n_layers, dropout, enc_out_dim):
        super().__init__()
        self.embedding = embedding
        emb_dim = embedding.embedding_dim
        self.vocab_size = embedding.num_embeddings
        self.hid_dim = hid_dim

        # input feeding: concatenate previous attentional hidden state to the
        # embedding at every decoder step
        self.rnn = nn.GRU(
            emb_dim + hid_dim, hid_dim, num_layers=n_layers,
            batch_first=True, dropout=dropout if n_layers > 1 else 0.0,
        )
        self.attention = LuongAttention(hid_dim, enc_out_dim)
        self.combine = nn.Linear(hid_dim + enc_out_dim, hid_dim)
        self.out = nn.Linear(hid_dim, self.vocab_size)
        # copy/generate gate: how much to trust the fixed-vocab distribution
        # vs. the copy (attention-over-source) distribution at this step.
        self.p_gen = nn.Linear(enc_out_dim + hid_dim + emb_dim, 1)
        self.dropout = nn.Dropout(dropout)

    def step(self, prev_token, prev_attn_hidden, hidden, enc_outputs, src_mask, src_tgt_map):
        """One decoding step.
        prev_token: (B,) ; prev_attn_hidden: (B, H) ; hidden: (n_layers, B, H)
        src_tgt_map: (B, S) target-vocab id for each source position whose
        piece string matches one, else -1.

        Returns a genuine probability distribution over the target
        vocabulary (already mixing generate + copy — NOT raw logits, do not
        softmax it again), plus the usual decoder state and the raw
        attention weights (for visualization).
        """
        emb_vec = self.dropout(self.embedding(prev_token))  # (B, E)
        rnn_input = torch.cat([emb_vec.unsqueeze(1), prev_attn_hidden.unsqueeze(1)], dim=2)  # (B, 1, E+H)
        output, hidden = self.rnn(rnn_input, hidden)  # output: (B, 1, H)
        dec_top = output.squeeze(1)  # (B, H)

        context, attn_weights = self.attention(dec_top, enc_outputs, src_mask)
        attn_hidden = torch.tanh(self.combine(torch.cat([dec_top, context], dim=1)))  # (B, H)

        vocab_logits = self.out(self.dropout(attn_hidden))  # (B, V)
        p_vocab = F.softmax(vocab_logits, dim=-1)  # (B, V)

        # copy distribution: scatter attention mass into the target-vocab
        # slot each source position's piece string matches, if any.
        valid = (src_tgt_map >= 0)
        idx = src_tgt_map.clamp(min=0)
        contrib = attn_weights * valid.to(attn_weights.dtype)
        copy_dist = torch.zeros(prev_token.size(0), self.vocab_size, device=prev_token.device)
        copy_dist.scatter_add_(1, idx, contrib)

        p_gen = torch.sigmoid(self.p_gen(torch.cat([context, dec_top, emb_vec], dim=1)))  # (B, 1)
        probs = p_gen * p_vocab + (1 - p_gen) * copy_dist  # (B, V), sums to <=1

        return probs, hidden, attn_hidden, attn_weights, p_gen


class Seq2Seq(nn.Module):
    def __init__(self, src_vocab_size, tgt_vocab_size, emb_dim=256, hid_dim=512, n_layers=2, dropout=0.3):
        super().__init__()
        src_embedding = nn.Embedding(src_vocab_size, emb_dim, padding_idx=PAD_ID)
        tgt_embedding = nn.Embedding(tgt_vocab_size, emb_dim, padding_idx=PAD_ID)
        self.encoder = Encoder(src_embedding, hid_dim, n_layers, dropout)
        self.decoder = Decoder(tgt_embedding, hid_dim, n_layers, dropout, enc_out_dim=hid_dim * 2)
        self.hid_dim = hid_dim
        self.src_vocab_size = src_vocab_size
        self.tgt_vocab_size = tgt_vocab_size

    def _encode(self, src, src_len, src_tgt_map):
        enc_outputs, hidden = self.encoder(src, src_len)
        src_mask = make_src_mask(src_len, enc_outputs.size(1), src.device)
        src_tgt_map = src_tgt_map[:, :enc_outputs.size(1)]
        return enc_outputs, hidden, src_mask, src_tgt_map

    def forward(self, src, src_len, src_tgt_map, tgt_in, teacher_forcing_ratio=1.0):
        """Training-time forward pass with teacher forcing.
        Returns probs: (B, T, V) — a probability distribution per step
        (already mixing generate+copy; take log() for NLL, don't softmax)."""
        batch_size, tgt_max_len = tgt_in.shape
        device = src.device

        enc_outputs, hidden, src_mask, src_tgt_map = self._encode(src, src_len, src_tgt_map)

        attn_hidden = torch.zeros(batch_size, self.hid_dim, device=device)
        probs_list = []
        input_token = tgt_in[:, 0]  # <s> for every example

        for t in range(tgt_max_len):
            probs, hidden, attn_hidden, _, _ = self.decoder.step(
                input_token, attn_hidden, hidden, enc_outputs, src_mask, src_tgt_map
            )
            probs_list.append(probs)
            use_teacher = torch.rand(1).item() < teacher_forcing_ratio
            if t + 1 < tgt_max_len:
                input_token = tgt_in[:, t + 1] if use_teacher else probs.argmax(dim=-1)

        return torch.stack(probs_list, dim=1)  # (B, T, V)

    @torch.no_grad()
    def greedy_decode(self, src, src_len, src_tgt_map, max_len=60):
        """Inference-time greedy decoding. Returns (B, <=max_len) token ids
        (stops per-example at EOS_ID, padded with PAD_ID after)."""
        self.eval()
        batch_size = src.size(0)
        device = src.device

        enc_outputs, hidden, src_mask, src_tgt_map = self._encode(src, src_len, src_tgt_map)

        attn_hidden = torch.zeros(batch_size, self.hid_dim, device=device)
        input_token = torch.full((batch_size,), BOS_ID, dtype=torch.long, device=device)
        finished = torch.zeros(batch_size, dtype=torch.bool, device=device)
        outputs = []

        for _ in range(max_len):
            probs, hidden, attn_hidden, _, _ = self.decoder.step(
                input_token, attn_hidden, hidden, enc_outputs, src_mask, src_tgt_map
            )
            next_token = probs.argmax(dim=-1)
            next_token = torch.where(finished, torch.full_like(next_token, PAD_ID), next_token)
            outputs.append(next_token)
            finished = finished | (next_token == EOS_ID)
            input_token = next_token
            if finished.all():
                break

        return torch.stack(outputs, dim=1)  # (B, T)

    @torch.no_grad()
    def greedy_decode_with_attention(self, src, src_len, src_tgt_map, max_len=60):
        """Same as greedy_decode, but also returns the per-step attention
        weights for visualization. Returns (token_ids (B,T), attn (B,T,S))
        — attn[b, t, s] is how much decoder step t attended to source
        position s when producing token_ids[b, t]."""
        self.eval()
        batch_size = src.size(0)
        device = src.device

        enc_outputs, hidden, src_mask, src_tgt_map = self._encode(src, src_len, src_tgt_map)

        attn_hidden = torch.zeros(batch_size, self.hid_dim, device=device)
        input_token = torch.full((batch_size,), BOS_ID, dtype=torch.long, device=device)
        finished = torch.zeros(batch_size, dtype=torch.bool, device=device)
        outputs, attn_history = [], []

        for _ in range(max_len):
            probs, hidden, attn_hidden, attn_weights, _ = self.decoder.step(
                input_token, attn_hidden, hidden, enc_outputs, src_mask, src_tgt_map
            )
            next_token = probs.argmax(dim=-1)
            next_token = torch.where(finished, torch.full_like(next_token, PAD_ID), next_token)
            outputs.append(next_token)
            attn_history.append(attn_weights)  # (B, S)
            finished = finished | (next_token == EOS_ID)
            input_token = next_token
            if finished.all():
                break

        return torch.stack(outputs, dim=1), torch.stack(attn_history, dim=1)  # (B,T), (B,T,S)

    @torch.no_grad()
    def beam_search_decode(self, src, src_len, src_tgt_map, beam_size=5, max_len=100, length_alpha=1.0,
                            no_repeat_ngram_size=0):
        """Beam search for a single example (src must have batch size 1).
        Returns the best hypothesis as a plain python list of token ids
        (BOS/EOS excluded). Beam hypotheses are vectorized along the batch
        dimension of the decoder, and shrink as candidates hit EOS.

        no_repeat_ngram_size>0 bans any continuation that would repeat an
        n-gram already produced within the same hypothesis (standard
        fairseq/huggingface-style repeat blocking) — a direct fix for the
        repetition loops length-normalized beam search is prone to when the
        model is unsure what comes next."""
        self.eval()
        assert src.size(0) == 1, "beam_search_decode handles one example at a time"
        device = src.device

        enc_outputs, hidden, src_mask, src_tgt_map = self._encode(src, src_len, src_tgt_map)

        n_active = 1
        attn_hidden = torch.zeros(n_active, self.hid_dim, device=device)
        last_token = torch.full((n_active,), BOS_ID, dtype=torch.long, device=device)
        cum_logprob = torch.zeros(n_active, device=device)
        seqs = [[]]
        completed = []  # (length_normalized_logprob, token_seq)

        enc_rep, mask_rep, map_rep = enc_outputs, src_mask, src_tgt_map

        for _ in range(max_len):
            probs, hidden, attn_hidden, _, _ = self.decoder.step(last_token, attn_hidden, hidden, enc_rep, mask_rep, map_rep)
            logprobs = torch.log(probs.clamp_min(1e-12))  # (n_active, V) — probs already properly mixed, don't re-softmax

            if no_repeat_ngram_size > 0:
                for i, seq in enumerate(seqs):
                    for banned in _banned_next_tokens(seq, no_repeat_ngram_size):
                        logprobs[i, banned] = float("-inf")

            total = cum_logprob.unsqueeze(1) + logprobs  # (n_active, V)
            flat = total.view(-1)
            k = min(beam_size, flat.numel())
            topk_logprob, topk_idx = flat.topk(k)
            parent_idx = torch.div(topk_idx, self.tgt_vocab_size, rounding_mode="floor")
            token_idx = topk_idx % self.tgt_vocab_size

            new_seqs, new_hidden, new_attn, new_last, new_cum = [], [], [], [], []
            for rank in range(k):
                p = parent_idx[rank].item()
                tok = token_idx[rank].item()
                score = topk_logprob[rank].item()
                seq = seqs[p] + [tok]
                if tok == EOS_ID:
                    completed.append((score / (len(seq) ** length_alpha), seq[:-1]))
                    continue
                new_seqs.append(seq)
                new_hidden.append(hidden[:, p, :])
                new_attn.append(attn_hidden[p])
                new_last.append(tok)
                new_cum.append(score)

            if not new_seqs:
                break

            seqs = new_seqs
            hidden = torch.stack(new_hidden, dim=1)
            attn_hidden = torch.stack(new_attn, dim=0)
            last_token = torch.tensor(new_last, dtype=torch.long, device=device)
            cum_logprob = torch.tensor(new_cum, device=device)
            enc_rep = enc_outputs.expand(len(seqs), -1, -1)
            mask_rep = src_mask.expand(len(seqs), -1)
            map_rep = src_tgt_map.expand(len(seqs), -1)

        if not completed:
            # nothing reached EOS within max_len: fall back to the best active hypothesis
            best = cum_logprob.argmax().item()
            completed = [(cum_logprob[best].item() / (len(seqs[best]) ** length_alpha), seqs[best])]

        completed.sort(key=lambda x: -x[0])
        return completed[0][1]

    def beam_search_decode_batch(self, src, src_len, src_tgt_map, beam_size=5, max_len=100, length_alpha=1.0,
                                  no_repeat_ngram_size=0):
        """Beam search over a batch by looping per example (beam search
        doesn't batch as naturally as greedy decoding). Returns a list of
        python token-id lists, one per example."""
        return [
            self.beam_search_decode(src[i:i + 1], src_len[i:i + 1], src_tgt_map[i:i + 1],
                                     beam_size, max_len, length_alpha, no_repeat_ngram_size)
            for i in range(src.size(0))
        ]
