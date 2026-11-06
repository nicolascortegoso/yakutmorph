"""
Dual-encoder-with-attention reranker (paper_2027.md §4): a sentence encoder
and a candidate encoder run independently, and an attention mechanism lets
each candidate representation query the sentence's hidden states before
scoring — adapted from dialogue-response-ranking dual encoders (Mueller &
Thyagarajan 2016; Li et al. 2020) rather than the encoder-decoder paradigm.
"""
import torch
import torch.nn as nn
from torch.nn.utils.rnn import pack_padded_sequence, pad_packed_sequence

PAD = 0


class SentenceEncoder(nn.Module):
    """Bidirectional GRU producing one contextual representation per input
    subword, H_s in the paper's notation."""

    def __init__(self, vocab_size, embed_size, hidden_size, dropout=0.3):
        super().__init__()
        self.embed = nn.Embedding(vocab_size, embed_size, padding_idx=PAD)
        self.dropout = nn.Dropout(dropout)
        self.gru = nn.GRU(embed_size, hidden_size, batch_first=True, bidirectional=True)

    def forward(self, ids, mask):
        lengths = mask.sum(dim=1).clamp(min=1).long().cpu()
        embedded = self.dropout(self.embed(ids))
        packed = pack_padded_sequence(embedded, lengths, batch_first=True, enforce_sorted=False)
        packed_out, _ = self.gru(packed)
        out, _ = pad_packed_sequence(packed_out, batch_first=True, total_length=ids.size(1))
        return out  # [B, Ls, 2H]


class CandidateEncoder(nn.Module):
    """Bidirectional GRU over one candidate's tokens (root subwords + hard-
    coded affix tags), mean-pooled to a fixed-size representation v_m."""

    def __init__(self, vocab_size, embed_size, hidden_size, dropout=0.3):
        super().__init__()
        self.embed = nn.Embedding(vocab_size, embed_size, padding_idx=PAD)
        self.dropout = nn.Dropout(dropout)
        self.gru = nn.GRU(embed_size, hidden_size, batch_first=True, bidirectional=True)

    def forward(self, ids, token_mask):
        # ids, token_mask: [B, C, Lc] -> flatten candidates into the batch dim
        B, C, Lc = ids.shape
        flat_ids = ids.view(B * C, Lc)
        flat_mask = token_mask.view(B * C, Lc)
        lengths = flat_mask.sum(dim=1).clamp(min=1).long().cpu()

        embedded = self.dropout(self.embed(flat_ids))
        packed = pack_padded_sequence(embedded, lengths, batch_first=True, enforce_sorted=False)
        packed_out, _ = self.gru(packed)
        out, _ = pad_packed_sequence(packed_out, batch_first=True, total_length=Lc)  # [B*C, Lc, 2H]

        mask = flat_mask.unsqueeze(-1)
        pooled = (out * mask).sum(dim=1) / mask.sum(dim=1).clamp(min=1e-9)  # [B*C, 2H]
        return pooled.view(B, C, -1)


class DualEncoderReranker(nn.Module):
    def __init__(self, input_vocab_size, candidate_vocab_size,
                 embed_size=64, hidden_size=128, dropout=0.3):
        super().__init__()
        two_h = 2 * hidden_size
        self.sentence_encoder = SentenceEncoder(input_vocab_size, embed_size, hidden_size, dropout)
        self.candidate_encoder = CandidateEncoder(candidate_vocab_size, embed_size, hidden_size, dropout)
        self.attn = nn.Linear(two_h, two_h, bias=False)          # W_a: 2H -> 2H
        self.combine = nn.Linear(4 * hidden_size, hidden_size)   # W_c: 4H -> H
        self.dropout = nn.Dropout(dropout)
        self.scorer = nn.Linear(hidden_size, 1)                  # W_s: H -> 1

    def forward(self, sentence_ids, sentence_mask, candidate_ids,
                candidate_token_mask, candidate_mask):
        H_s = self.sentence_encoder(sentence_ids, sentence_mask)       # [B, Ls, 2H]
        v = self.candidate_encoder(candidate_ids, candidate_token_mask)  # [B, C, 2H]

        # e_{m,j} = v_m^T W_a h_j, batched over candidates m and positions j
        query = self.attn(v)                                    # [B, C, 2H]
        scores_attn = torch.bmm(query, H_s.transpose(1, 2))      # [B, C, Ls]
        scores_attn = scores_attn.masked_fill(sentence_mask.unsqueeze(1) == 0, float("-inf"))
        alpha = torch.softmax(scores_attn, dim=-1)               # [B, C, Ls]
        c = torch.bmm(alpha, H_s)                                # [B, C, 2H]

        z = torch.cat([c, v], dim=-1)                            # [B, C, 4H]
        u = self.dropout(torch.tanh(self.combine(z)))            # [B, C, H]
        scores = self.scorer(u).squeeze(-1)                      # [B, C]
        scores = scores.masked_fill(candidate_mask == 0, float("-inf"))
        return scores
