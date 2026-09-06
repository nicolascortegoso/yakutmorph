#!/usr/bin/env python3
"""
Train two SEPARATE SentencePiece (unigram) tokenizers, fit on the TRAIN split
only:

  - spm_src: encoder input, trained on the raw sah sentences.
  - spm_tgt: decoder output, trained on the ROOT portion of every word-type
    token occurrence (one line per occurrence, so frequency-weighted — a
    common root still gets proportionally more influence than a rare one)
    plus literal punctuation/number/symbol tokens verbatim.

Every morphological tag (e.g. "+N", "+POSS.3SG") is still registered as a
user-defined symbol in spm_tgt, so it stays one atomic piece instead of being
subword-segmented — the decoder picks a tag the way it picks a word, while
roots are learned as ordinary subwords.

Rationale for splitting (vs. the single shared tokenizer this replaces): a
joint vocabulary has to spend its budget on both full inflected sentence
text (suffix chains, function words, punctuation — large and diverse) and
bare roots (small, homogeneous), which likely under-serves root coverage.
Training spm_tgt on root text alone dedicates its entire budget to root
segmentation specifically. The trade-off (discussed with the user before
building this): a shared vocabulary also gives the model a "free" copy
signal for OOV roots, since a root is almost always a literal prefix of its
surface form and shares subword ids with it; splitting removes that, so this
is an empirical bet, not a strict improvement.
"""
import argparse
import json
import tempfile
from pathlib import Path

import sentencepiece as spm

from text_utils import normalize_text

MODEL_TYPE = "unigram"
CHARACTER_COVERAGE = 1.0  # small, well-defined alphabet (Yakut Cyrillic + a few Latin/digits) — no need to drop rare chars

DATA_DIR = Path(__file__).resolve().parents[1] / "data"
OUT_DIR = DATA_DIR / "tokenizer"


def train_one(corpus_lines, model_prefix, vocab_size, user_defined_symbols=()):
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8") as f:
        corpus_path = f.name
        for line in corpus_lines:
            f.write(line + "\n")

    spm.SentencePieceTrainer.train(
        input=corpus_path,
        model_prefix=str(OUT_DIR / model_prefix),
        vocab_size=vocab_size,
        model_type=MODEL_TYPE,
        character_coverage=CHARACTER_COVERAGE,
        user_defined_symbols=list(user_defined_symbols),
        pad_id=0, unk_id=1, bos_id=2, eos_id=3,
        pad_piece="<pad>", unk_piece="<unk>", bos_piece="<s>", eos_piece="</s>",
        hard_vocab_limit=False,  # let the trainer settle below VOCAB_SIZE if the corpus can't fill it
    )
    Path(corpus_path).unlink()
    return spm.SentencePieceProcessor(model_file=str(OUT_DIR / f"{model_prefix}.model"))


def vocab_breakdown(model_prefix, reserved_tags):
    vocab_lines = (OUT_DIR / f"{model_prefix}.vocab").read_text(encoding="utf-8").splitlines()
    n_special = 4  # <pad> <unk> <s> </s>
    n_tags = sum(1 for l in vocab_lines if l.split("\t")[0] in reserved_tags)
    n_learned = len(vocab_lines) - n_special - n_tags
    return n_special, n_tags, n_learned


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src-vocab-size", type=int, default=4000)
    ap.add_argument("--tgt-vocab-size", type=int, default=4000)
    ap.add_argument("--src-prefix", default="spm_src")
    ap.add_argument("--tgt-prefix", default="spm_tgt")
    ap.add_argument("--skip-src", action="store_true", help="reuse an already-trained spm_src (source side is unaffected by target vocab-size experiments)")
    args = ap.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    tag_vocab = json.loads((DATA_DIR / "tag_vocab.json").read_text(encoding="utf-8"))
    reserved_tags = sorted({normalize_text(f"+{tag}") for tag in tag_vocab["all_tags"]})
    assert len(reserved_tags) == len(tag_vocab["all_tags"]), (
        "lowercasing collapsed two distinct tags into the same reserved symbol"
    )

    train_records = [json.loads(l) for l in (DATA_DIR / "train.jsonl").read_text(encoding="utf-8").splitlines()]

    # --- source corpus: raw sentences, unchanged ---
    if args.skip_src:
        sp_src = spm.SentencePieceProcessor(model_file=str(OUT_DIR / f"{args.src_prefix}.model"))
        src_lines = []  # not retrained; only used below for the line count in the report
    else:
        src_lines = [normalize_text(r["sah"]) for r in train_records]
        sp_src = train_one(src_lines, args.src_prefix, args.src_vocab_size)

    # --- target corpus: root text only (one line per token occurrence, so
    # frequency-weighted), plus literal tokens verbatim ---
    tgt_lines = []
    for r in train_records:
        for tok in normalize_text(r["target"]).split():
            if "+" in tok:
                tgt_lines.append(tok.split("+")[0])  # root only, tag(s) dropped
            else:
                tgt_lines.append(tok)  # literal punctuation/number/etc.
    sp_tgt = train_one(tgt_lines, args.tgt_prefix, args.tgt_vocab_size, user_defined_symbols=reserved_tags)

    src_special, src_tags, src_learned = vocab_breakdown(args.src_prefix, set())
    tgt_special, tgt_tags, tgt_learned = vocab_breakdown(args.tgt_prefix, set(reserved_tags))

    report_lines = [
        f"# Tokenizer training report ({args.src_prefix} / {args.tgt_prefix})",
        "",
        f"Model type: SentencePiece {MODEL_TYPE}",
        f"Character coverage: {CHARACTER_COVERAGE}",
        "",
        f"## {args.src_prefix} (encoder input: sah sentences)",
        f"- actual vocab size: {sp_src.vocab_size()}",
        f"- breakdown: {src_special} special + {src_learned} learned subword pieces",
        "" if args.skip_src else f"- trained on {len(src_lines)} sentences",
        "",
        f"## {args.tgt_prefix} (decoder output: root text only)",
        f"- actual vocab size: {sp_tgt.vocab_size()}",
        f"- breakdown: {tgt_special} special + {tgt_tags} reserved tags + {tgt_learned} learned subword pieces",
        f"- trained on {len(tgt_lines)} token occurrences (roots + literals, frequency-weighted)",
        "",
        "## Sanity checks",
        "",
    ]

    samples = train_records[:3]
    dev_path = DATA_DIR / "dev.jsonl"
    if dev_path.exists():
        dev_records = [json.loads(l) for l in dev_path.read_text(encoding="utf-8").splitlines()]
        unseen = [r for r in dev_records if r.get("has_unseen_root")]
        if unseen:
            samples.append(unseen[0])

    for r in samples:
        sah_norm = normalize_text(r["sah"])
        tgt_norm = normalize_text(r["target"])
        report_lines.append(f"- sah: `{sah_norm}`")
        report_lines.append(f"  - src pieces: {sp_src.encode(sah_norm, out_type=str)}")
        report_lines.append(f"- target: `{tgt_norm}`")
        report_lines.append(f"  - tgt pieces: {sp_tgt.encode(tgt_norm, out_type=str)}")
        report_lines.append("")

    report = "\n".join(report_lines)
    (OUT_DIR / f"tokenizer_report_{args.tgt_prefix}.md").write_text(report, encoding="utf-8")
    print(report)


if __name__ == "__main__":
    main()
