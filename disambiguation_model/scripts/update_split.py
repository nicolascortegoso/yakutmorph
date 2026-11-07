#!/usr/bin/env python3
"""
Keeps the train/dev/test split of the disambiguation data stable across
releases (disambiguation_model/data/split.tsv: sentence id -> split).

- Sentences already in the split keep their place, so every release is
  evaluated on the same test sentences (plus any new ones) and the
  numbers stay comparable.
- A new sentence that repeats an existing one word for word goes to the
  same split as that one, so no sentence can be in train and test at once.
- Any other new sentence is assigned deterministically from its id: about
  5% to dev, 5% to test, the rest to train.
- Sentences no longer in the corpus are dropped.

The first time, the split is copied from seq2seq_parser/data/{train,dev,test}.jsonl,
which the current model was trained on.

Usage: python disambiguation_model/scripts/update_split.py
"""
import collections
import hashlib
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DATASET_DIR = REPO_ROOT / "yakutmorph_dataset"
SEQ2SEQ_DATA_DIR = REPO_ROOT / "seq2seq_parser" / "data"
SPLIT_PATH = Path(__file__).resolve().parents[1] / "data" / "split.tsv"

DEV_PERMILLE, TEST_PERMILLE = 50, 50


def corpus_sentences():
    """Sentence id -> sentence text, for every annotated sentence."""
    sentences = {}
    for path in sorted(DATASET_DIR.glob("*/processed/*.json")):
        for entry in json.loads(path.read_text(encoding="utf-8")):
            sentences[f"{path.parts[-3]}/{path.name}#{entry.get('id')}"] = entry.get("sah") or ""
    return sentences


def read_split():
    if SPLIT_PATH.exists():
        rows = (line.rstrip("\n").split("\t") for line in SPLIT_PATH.read_text(encoding="utf-8").splitlines()[1:])
        return {sid: split for sid, split in rows}, "split.tsv"
    split = {}
    for name in ("train", "dev", "test"):
        with open(SEQ2SEQ_DATA_DIR / f"{name}.jsonl", encoding="utf-8") as f:
            for line in f:
                split[json.loads(line)["id"]] = name
    return split, "seq2seq_parser/data (first run)"


def assign(sentence_id):
    bucket = int(hashlib.sha256(sentence_id.encode("utf-8")).hexdigest()[:8], 16) % 1000
    if bucket < DEV_PERMILLE:
        return "dev"
    if bucket < DEV_PERMILLE + TEST_PERMILLE:
        return "test"
    return "train"


def main():
    sentences = corpus_sentences()
    split, origin = read_split()
    dropped = [sid for sid in split if sid not in sentences]
    for sid in dropped:
        del split[sid]

    split_of_text = {}
    for sid, name in split.items():
        split_of_text.setdefault(sentences[sid], name)

    added = collections.Counter()
    for sid, text in sentences.items():
        if sid in split:
            continue
        name = split_of_text.get(text) or assign(sid)
        split[sid] = name
        split_of_text.setdefault(text, name)
        added[name] += 1

    SPLIT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(SPLIT_PATH, "w", encoding="utf-8") as f:
        f.write("id\tsplit\n")
        for sid in sorted(split):
            f.write(f"{sid}\t{split[sid]}\n")

    totals = collections.Counter(split.values())
    print(f"Split read from {origin}; {len(split)} sentences: "
          + ", ".join(f"{name} {totals[name]}" for name in ("train", "dev", "test")))
    print(f"New sentences: {sum(added.values())} ("
          + ", ".join(f"{name} {added[name]}" for name in ("train", "dev", "test"))
          + f"); removed from the corpus: {len(dropped)}")


if __name__ == "__main__":
    main()
