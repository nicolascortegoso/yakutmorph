#!/usr/bin/env python3
"""
End-to-end evaluation of the disambiguator as the library ships it.

Runs `yakutmorph.YakutMorph` (tokenizer, transducers, post-analysis and the
ONNX reranker in yakutmorph/data/) on every sentence of a split prepared by
prepare_dataset.py, and compares each word's chosen analysis with the gold
one. Unlike train.py, which scores the PyTorch checkpoint on pre-encoded
data, this measures what a user of the library gets.

It also checks that the library still produces the same candidates the
model was trained on. A mismatch means the transducer or the post-analysis
changed after the data was prepared: rerun prepare_dataset.py and retrain.

Usage: python disambiguation_model/scripts/evaluate_library.py [test|dev] [--json]

With --json, prints the numbers as one JSON object instead of a report.
"""
import collections
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT))

from yakutmorph import YakutMorph  # noqa: E402

DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def analysis_string(analysis):
    return "".join(m.morpheme for m in analysis.morphemes)


def load(split):
    with open(DATA_DIR / f"{split}.jsonl", encoding="utf-8") as f:
        return [json.loads(line) for line in f]


def most_frequent_choice(train):
    """For each candidate set seen in training, the gold analysis chosen most
    often: the context-free baseline reported in the paper."""
    counts = collections.defaultdict(collections.Counter)
    overall = collections.Counter()
    for r in train:
        gold = r["candidates"][r["label"]]
        counts[tuple(sorted(r["candidates"]))][gold] += 1
        overall[gold] += 1

    def choose(candidates):
        seen = counts.get(tuple(sorted(candidates)))
        if seen:
            return seen.most_common(1)[0][0]
        return max(candidates, key=lambda c: overall[c])
    return choose


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    split = args[0] if args else "test"
    records = load(split)
    baseline = most_frequent_choice(load("train"))

    by_sentence = collections.defaultdict(list)
    for r in records:
        sentence_id, _, token = r["id"].rpartition("#")
        by_sentence[sentence_id].append((int(token), r))

    morph = YakutMorph()
    c = collections.Counter()
    by_n = collections.defaultdict(collections.Counter)
    mismatches = []
    for sentence_id, items in by_sentence.items():
        text = re.sub(r"</?TARGET>", "", items[0][1]["sentence"])
        tokens = morph.parse(text).tokens
        for idx, r in items:
            gold = r["candidates"][r["label"]]
            token = tokens[idx] if idx < len(tokens) else None
            if token is None or not token.has_morph:
                c["token_mismatch"] += 1
                continue
            candidates = [analysis_string(a) for a in token.analyses.output]
            if candidates != r["candidates"]:
                c["candidates_differ"] += 1
                if len(mismatches) < 10:
                    mismatches.append((token.surface, r["candidates"], candidates))
            kind = "ambiguous" if len(r["candidates"]) > 1 else "unambiguous"
            correct = analysis_string(token.morph) == gold
            c[kind] += 1
            c[f"{kind}_correct"] += correct
            if kind == "ambiguous":
                c["baseline_correct"] += baseline(r["candidates"]) == gold
                n = min(len(r["candidates"]), 6)
                by_n[n]["total"] += 1
                by_n[n]["correct"] += correct

    total = c["ambiguous"] + c["unambiguous"]
    correct = c["ambiguous_correct"] + c["unambiguous_correct"]
    if "--json" in sys.argv:
        print(json.dumps({
            "split": split, "words": total, "accuracy": correct / total,
            "ambiguous": c["ambiguous"], "ambiguous_accuracy": c["ambiguous_correct"] / c["ambiguous"],
            "baseline_ambiguous_accuracy": c["baseline_correct"] / c["ambiguous"],
            "candidates_differ": c["candidates_differ"], "token_mismatch": c["token_mismatch"],
        }))
        sys.exit(1 if c["candidates_differ"] or c["token_mismatch"] else 0)
    print(f"# End-to-end evaluation on {split} ({len(by_sentence)} sentences)\n")
    print(f"- Overall accuracy: {correct / total:.4f} ({correct}/{total})")
    print(f"- Ambiguous words: {c['ambiguous_correct'] / c['ambiguous']:.4f} "
          f"({c['ambiguous_correct']}/{c['ambiguous']})")
    print(f"- Unambiguous words: {c['unambiguous_correct'] / c['unambiguous']:.4f} "
          f"({c['unambiguous_correct']}/{c['unambiguous']})")
    print(f"- Most-frequent-choice baseline on ambiguous words: "
          f"{c['baseline_correct'] / c['ambiguous']:.4f}")
    print(f"- Words whose candidates differ from the training data: {c['candidates_differ']}")
    print(f"- Words not found at their position: {c['token_mismatch']}\n")
    print("| candidates | accuracy | n |\n|---|---|---|")
    for n in sorted(by_n):
        label = f"{n}+" if n == 6 else str(n)
        print(f"| {label} | {by_n[n]['correct'] / by_n[n]['total']:.4f} | {by_n[n]['total']} |")
    for surface, expected, got in mismatches:
        print(f"\ncandidates differ for {surface}:\n  data:    {expected}\n  library: {got}")
    if c["candidates_differ"] or c["token_mismatch"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
