#!/usr/bin/env python3
"""Evaluate a trained checkpoint on a held-out split using greedy decoding
(not teacher forcing) and alignment-based metrics:

  - sentence exact match
  - token-level accuracy (1 - WER, via token-level edit-distance alignment)
  - root accuracy (lemma correctness among word-type tokens)
  - tag-chain accuracy (the full +TAG+TAG... suffix, exact match)

All four are also broken out by has_unseen_root, using the flag already
computed in dataset preparation, to separate raw accuracy from
generalization to roots absent from training.
"""
import argparse
import json
from pathlib import Path

import sentencepiece as spm
import torch
from torch.utils.data import DataLoader

from dataset import ParsingDataset, BucketBatchSampler, collate_fn, PAD_ID, EOS_ID
from model import Seq2Seq
from text_utils import normalize_text

DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def levenshtein_align(gold, pred):
    """Token-level edit-distance alignment. Returns list of (g, p) pairs,
    where either side is None for an insertion/deletion."""
    n, m = len(gold), len(pred)
    dp = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(n + 1):
        dp[i][0] = i
    for j in range(m + 1):
        dp[0][j] = j
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            cost = 0 if gold[i - 1] == pred[j - 1] else 1
            dp[i][j] = min(
                dp[i - 1][j] + 1,       # deletion (gold token dropped)
                dp[i][j - 1] + 1,       # insertion (extra predicted token)
                dp[i - 1][j - 1] + cost,  # match / substitution
            )

    # backtrace
    pairs = []
    i, j = n, m
    while i > 0 or j > 0:
        if i > 0 and j > 0 and dp[i][j] == dp[i - 1][j - 1] + (0 if gold[i - 1] == pred[j - 1] else 1):
            pairs.append((gold[i - 1], pred[j - 1]))
            i, j = i - 1, j - 1
        elif i > 0 and dp[i][j] == dp[i - 1][j] + 1:
            pairs.append((gold[i - 1], None))
            i -= 1
        else:
            pairs.append((None, pred[j - 1]))
            j -= 1
    pairs.reverse()
    return pairs, dp[n][m]


def split_root_tags(token):
    """'root+TAG1+TAG2' -> ('root', ('TAG1','TAG2')). A literal (punctuation)
    token has no '+' and returns (token, None)."""
    if "+" not in token:
        return token, None
    parts = token.split("+")
    return parts[0], tuple(parts[1:])


class Accumulator:
    def __init__(self):
        self.n_sentences = 0
        self.n_exact = 0
        self.n_gold_tokens = 0
        self.edit_distance = 0
        self.n_gold_words = 0  # gold tokens that are word-type (contain '+')
        self.root_correct = 0
        self.tags_correct = 0

    def add(self, gold_text, pred_text):
        self.n_sentences += 1
        if gold_text.strip() == pred_text.strip():
            self.n_exact += 1

        gold_tokens = gold_text.split()
        pred_tokens = pred_text.split()
        self.n_gold_tokens += len(gold_tokens)

        pairs, dist = levenshtein_align(gold_tokens, pred_tokens)
        self.edit_distance += dist

        for g, p in pairs:
            if g is None:
                continue
            g_root, g_tags = split_root_tags(g)
            if g_tags is None:
                continue  # literal/punctuation gold token: not scored for root/tag accuracy
            self.n_gold_words += 1
            if p is None:
                continue  # deleted by the model: counts as wrong (denominator already incremented)
            p_root, p_tags = split_root_tags(p)
            if p_root == g_root:
                self.root_correct += 1
            if p_tags == g_tags:
                self.tags_correct += 1

    def report(self):
        wer = self.edit_distance / max(1, self.n_gold_tokens)
        return {
            "n_sentences": self.n_sentences,
            "sentence_exact_match": self.n_exact / max(1, self.n_sentences),
            "token_accuracy_1_minus_wer": 1 - wer,
            "root_accuracy": self.root_correct / max(1, self.n_gold_words),
            "tag_chain_accuracy": self.tags_correct / max(1, self.n_gold_words),
            "n_gold_word_tokens": self.n_gold_words,
        }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--split", choices=["dev", "test"], default="test")
    ap.add_argument("--checkpoint", default=None, help="defaults to <ckpt-dir>/best.pt")
    ap.add_argument("--batch-size", type=int, default=64)
    ap.add_argument("--max-len", type=int, default=100)
    ap.add_argument("--device", default="auto")
    ap.add_argument("--decode", choices=["greedy", "beam"], default="greedy")
    ap.add_argument("--beam-size", type=int, default=5)
    ap.add_argument("--length-alpha", type=float, default=1.0, help="beam search length normalization exponent")
    ap.add_argument("--no-repeat-ngram-size", type=int, default=0, help="0=disabled; e.g. 3 bans repeating any trigram")
    ap.add_argument("--limit", type=int, default=None, help="evaluate only the first N examples (fast iteration)")
    ap.add_argument("--dump", default=None, help="optional path to write every prediction as jsonl")
    ap.add_argument("--quiet", action="store_true", help="only print the one-line summary, not the full JSON")
    ap.add_argument("--ckpt-dir", type=str, default="checkpoints", help="must match the --ckpt-dir used for training")
    args = ap.parse_args()

    CKPT_DIR = Path(__file__).resolve().parents[1] / args.ckpt_dir
    config = json.loads((CKPT_DIR / "config.json").read_text())
    if args.device != "auto":
        device = torch.device(args.device)
    else:
        device = torch.device("mps") if torch.backends.mps.is_available() else torch.device("cpu")

    # Which tokenizer files a checkpoint was trained against is recorded in
    # its own config.json (train.py's --src-tokenizer/--tgt-tokenizer),
    # defaulting to the original names for checkpoints predating those flags.
    src_tok = config.get("src_tokenizer", "spm_src")
    tgt_tok = config.get("tgt_tokenizer", "spm_tgt")
    sp_src = spm.SentencePieceProcessor(model_file=str(DATA_DIR / "tokenizer" / f"{src_tok}.model"))
    sp_tgt = spm.SentencePieceProcessor(model_file=str(DATA_DIR / "tokenizer" / f"{tgt_tok}.model"))
    model = Seq2Seq(config["src_vocab_size"], config["tgt_vocab_size"], config["emb_dim"], config["hid_dim"],
                     config["n_layers"], config["dropout"]).to(device)
    checkpoint = args.checkpoint or str(CKPT_DIR / "best.pt")
    model.load_state_dict(torch.load(checkpoint, map_location=device))
    model.eval()

    ds = ParsingDataset(DATA_DIR / f"{args.split}.jsonl", sp_src, sp_tgt)
    if args.limit:
        ds.examples = ds.examples[:args.limit]
        ds.records = ds.records[:args.limit]
    loader = DataLoader(ds, batch_sampler=BucketBatchSampler(ds, args.batch_size, shuffle=False), collate_fn=collate_fn)

    overall = Accumulator()
    seen = Accumulator()
    unseen = Accumulator()
    dump_f = open(args.dump, "w") if args.dump else None

    # Index gold records by id (not position) since BucketBatchSampler
    # reorders examples for length-bucketed batching.
    id_to_record = {r["id"]: r for r in ds.records}
    with torch.no_grad():
        for batch in loader:
            src = batch["src"].to(device)
            src_len = batch["src_len"]
            src_tgt_map = batch["src_tgt_map"].to(device)
            if args.decode == "beam":
                pred_seqs = model.beam_search_decode_batch(
                    src, src_len, src_tgt_map, beam_size=args.beam_size, max_len=args.max_len,
                    length_alpha=args.length_alpha, no_repeat_ngram_size=args.no_repeat_ngram_size,
                )
            else:
                pred_ids = model.greedy_decode(src, src_len, src_tgt_map, max_len=args.max_len)
                pred_seqs = [
                    [t for t in pred_ids[i].tolist() if t not in (PAD_ID, EOS_ID)]
                    for i in range(src.size(0))
                ]

            for i, ex_id in enumerate(batch["ids"]):
                toks = [t for t in pred_seqs[i] if t not in (PAD_ID, EOS_ID)]
                pred_text = sp_tgt.decode(toks)
                gold_text = normalize_text(id_to_record[ex_id]["target"])

                overall.add(gold_text, pred_text)
                if id_to_record[ex_id].get("has_unseen_root"):
                    unseen.add(gold_text, pred_text)
                else:
                    seen.add(gold_text, pred_text)

                if dump_f:
                    dump_f.write(json.dumps({
                        "id": ex_id,
                        "sah": id_to_record[ex_id]["sah"],
                        "gold": gold_text,
                        "pred": pred_text,
                        "has_unseen_root": id_to_record[ex_id].get("has_unseen_root", False),
                    }, ensure_ascii=False) + "\n")

    if dump_f:
        dump_f.close()

    result = {
        "split": args.split,
        "checkpoint": checkpoint,
        "decode": args.decode,
        "beam_size": args.beam_size if args.decode == "beam" else None,
        "length_alpha": args.length_alpha if args.decode == "beam" else None,
        "no_repeat_ngram_size": args.no_repeat_ngram_size if args.decode == "beam" else None,
        "limit": args.limit,
        "overall": overall.report(),
        "seen_root_sentences": seen.report(),
        "unseen_root_sentences": unseen.report(),
    }
    o = result["overall"]
    summary = (f"{args.decode} beam={args.beam_size} alpha={args.length_alpha} "
               f"ngram_block={args.no_repeat_ngram_size} limit={args.limit} | "
               f"exact={o['sentence_exact_match']:.4f} tok_acc={o['token_accuracy_1_minus_wer']:.4f} "
               f"root_acc={o['root_accuracy']:.4f} tag_acc={o['tag_chain_accuracy']:.4f}")
    print(summary)
    if not args.quiet:
        print(json.dumps(result, ensure_ascii=False, indent=2))

    if not args.limit:  # only persist full-split runs, not quick grid-search probes
        suffix = f"beam{args.beam_size}_a{args.length_alpha}_ngram{args.no_repeat_ngram_size}" if args.decode == "beam" else "greedy"
        out_path = CKPT_DIR / f"eval_{args.split}_{suffix}.json"
        out_path.write_text(json.dumps(result, ensure_ascii=False, indent=2))
        print(f"written to {out_path}")


if __name__ == "__main__":
    main()
