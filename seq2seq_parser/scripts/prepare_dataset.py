#!/usr/bin/env python3
"""
Build train/dev/test splits for the seq2seq Yakut morphological parser.

Reads gold-standard annotations from ../yakutmorph_dataset/<folder>/processed/*.json
(READ-ONLY — this script must never write into yakutmorph_dataset) and writes
normalized JSONL splits + a report into seq2seq_parser/data/.

Target format per sentence:
    <token_1> <token_2> ... <token_n>
where each <token_i> is either:
    - the literal surface text, for non-analyzable token classes (punctuation,
      numbers, symbols, unrecognized script, ...), or
    - "<root>+<TAG1>+<TAG2>+..." for analyzed word tokens, built by normalizing
      and concatenating the gold `root` and `affixes` fields.

See prepare_report.md (written alongside the splits) for exact counts.
"""
import json
import glob
import random
import re
import collections
from pathlib import Path

RANDOM_SEED = 13
# Target share of the *whole* kept corpus (train share is whatever remains,
# nominally 0.90). Duplicate-sentence records are always routed to train
# regardless of these fractions — see the leakage-control step below.
DEV_FRACTION = 0.05
TEST_FRACTION = 0.05

REPO_ROOT = Path(__file__).resolve().parents[2]
DATASET_DIR = REPO_ROOT / "yakutmorph_dataset"
OUT_DIR = Path(__file__).resolve().parents[1] / "data"

# Token classes that never carry a morphological analysis in the gold data
# (punctuation, digits, symbols, foreign/garbled script, unrecognized glyphs).
# Verified against the full corpus: every instance of these types lacks a
# `root` field, so the surface `text` is passed through verbatim as the
# target for these tokens.
LITERAL_TYPES = {
    "period", "comma", "hyphen", "question", "exclamation", "dash",
    "ellipsis", "quotation", "colon", "semicolon", "bracket", "number",
    "symbol", "roman", "unknown", "title_lat", "lowercase_lat",
}

# Token classes expected to carry a morphological analysis. If `root` is
# missing here it's a genuine gold-annotation gap, not a structural token,
# and the whole sentence is excluded (see build_target()).
WORD_TYPES = {"lowercase", "title", "uppercase"}

# One known data glitch found by manual audit (see prepare_report.md):
# root glued directly to its POS tag with no separator, e.g. "баһырҕасN".
# Hardcoded rather than guessed generically to avoid silently mangling a
# legitimate root that happens to end in a POS-tag-like substring.
ROOT_FIXUPS = {
    "баһырҕасN": "баһырҕас+N",
}


def normalize_tag_chain(raw):
    """Split a root/affixes value on '+' or '^' into a list of tags, stripping
    empties. Handles both the '^'-joined (yma/fst engine) and the standard
    '+'-joined (ymv engine) conventions, unifying them to '+'."""
    if raw is None:
        return []
    parts = re.split(r"[+^]", raw)
    return [p for p in parts if p]


def build_target_token(parse):
    """Return the target-string piece for one token, or None if this parse
    represents an unrecoverable gold-annotation gap (word-type token with no
    root) — the caller drops the whole sentence in that case."""
    ttype = parse.get("type")
    if ttype in LITERAL_TYPES:
        return parse["text"]

    root = parse.get("root")
    if root in ROOT_FIXUPS:
        root = ROOT_FIXUPS[root]

    if not root:
        return None  # annotation gap

    tags = normalize_tag_chain(root)

    affixes = parse.get("affixes")
    if isinstance(affixes, str):
        tags += normalize_tag_chain(affixes)
    elif isinstance(affixes, list):
        for item in affixes:
            tags += normalize_tag_chain(item)

    return "+".join(tags)


def load_entries():
    """Yield (folder, filename, entry_dict) for every example in every
    processed/*.json file."""
    for path in sorted(DATASET_DIR.glob("*/processed/*.json")):
        folder = path.parts[-3]
        data = json.loads(path.read_text(encoding="utf-8"))
        for entry in data:
            yield folder, path.name, entry


def main():
    random.seed(RANDOM_SEED)
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    total_raw = 0
    excluded_gap = 0
    excluded_gap_examples = []
    records = []  # kept sentence-level records

    for folder, filename, entry in load_entries():
        total_raw += 1
        parses = sorted(entry.get("parses", []), key=lambda p: p["pos"])

        target_tokens = []
        dropped = False
        for p in parses:
            tok = build_target_token(p)
            if tok is None:
                dropped = True
                break
            target_tokens.append(tok)

        if dropped:
            excluded_gap += 1
            if len(excluded_gap_examples) < 20:
                excluded_gap_examples.append(f"{folder}/{filename}: {entry.get('sah')!r}")
            continue

        records.append({
            "id": f"{folder}/{filename}#{entry.get('id')}",
            "folder": folder,
            "topic": entry.get("topic") or "UNK_TOPIC",
            "chapter": entry.get("chapter"),
            "section": entry.get("section"),
            "sah": entry.get("sah"),
            "target": " ".join(target_tokens),
            "n_tokens": len(target_tokens),
        })

    # --- group by exact surface sentence to prevent train/dev/test leakage ---
    by_sah = collections.defaultdict(list)
    for r in records:
        by_sah[r["sah"]].append(r)

    duplicated_records = []   # sah seen more than once anywhere -> forced to train
    unique_records = []       # sah seen exactly once -> eligible for stratified split
    for sah, group in by_sah.items():
        if len(group) > 1:
            duplicated_records.extend(group)
        else:
            unique_records.extend(group)

    n_conflicting_groups = sum(
        1 for g in by_sah.values()
        if len(g) > 1 and len({r["target"] for r in g}) > 1
    )
    n_consistent_dup_groups = sum(
        1 for g in by_sah.values()
        if len(g) > 1 and len({r["target"] for r in g}) == 1
    )

    # --- stratified split of unique-sah records by (folder, topic) ---
    # Duplicated-sah records are all forced into train (leakage control, see
    # above), so to land on DEV_FRACTION/TEST_FRACTION of the *whole* kept
    # corpus we draw dev/test only from the unique-sah pool but at an inflated
    # per-group rate that compensates for the pool being smaller than the
    # full corpus.
    n_kept = len(records)
    target_dev = round(n_kept * DEV_FRACTION)
    target_test = round(n_kept * TEST_FRACTION)
    pool_dev_fraction = target_dev / len(unique_records)
    pool_test_fraction = target_test / len(unique_records)

    groups = collections.defaultdict(list)
    for r in unique_records:
        groups[(r["folder"], r["topic"])].append(r)

    train, dev, test = [], [], []
    for key, items in groups.items():
        random.shuffle(items)
        n = len(items)
        n_dev = round(n * pool_dev_fraction)
        n_test = round(n * pool_test_fraction)
        # keep at least a couple examples of every group in train
        n_dev = min(n_dev, max(0, n - 1))
        n_test = min(n_test, max(0, n - n_dev - 1))
        dev.extend(items[:n_dev])
        test.extend(items[n_dev:n_dev + n_test])
        train.extend(items[n_dev + n_test:])

    train.extend(duplicated_records)

    for split in (train, dev, test):
        random.shuffle(split)

    # --- root vocabulary / seen-unseen analysis ---
    # second pass to attach root lemmas per record (kept only for word tokens)
    id_to_roots = {}
    for folder, filename, entry in load_entries():
        rid = f"{folder}/{filename}#{entry.get('id')}"
        roots = []
        for p in entry.get("parses", []):
            if p.get("type") in WORD_TYPES:
                root = p.get("root")
                root = ROOT_FIXUPS.get(root, root)
                if root:
                    roots.append(normalize_tag_chain(root)[0])
        id_to_roots[rid] = roots

    train_roots = set()
    for r in train:
        train_roots.update(id_to_roots.get(r["id"], []))

    def unseen_stats(split):
        n_sent_with_unseen = 0
        n_tok_unseen = 0
        n_tok_total = 0
        for r in split:
            roots = id_to_roots.get(r["id"], [])
            r["has_unseen_root"] = False
            for root in roots:
                n_tok_total += 1
                if root not in train_roots:
                    n_tok_unseen += 1
                    r["has_unseen_root"] = True
            if r["has_unseen_root"]:
                n_sent_with_unseen += 1
        return n_sent_with_unseen, n_tok_unseen, n_tok_total

    dev_stats = unseen_stats(dev)
    test_stats = unseen_stats(test)
    for r in train:
        r["has_unseen_root"] = False  # not meaningful for train itself

    # --- write splits ---
    def write_jsonl(path, split):
        with open(path, "w", encoding="utf-8") as f:
            for r in split:
                f.write(json.dumps(r, ensure_ascii=False) + "\n")

    write_jsonl(OUT_DIR / "train.jsonl", train)
    write_jsonl(OUT_DIR / "dev.jsonl", dev)
    write_jsonl(OUT_DIR / "test.jsonl", test)

    # --- tag vocabulary (for the subword tokenizer's reserved-token list) ---
    pos_tags = set()
    affix_tags = set()
    for folder, filename, entry in load_entries():
        for p in entry.get("parses", []):
            if p.get("type") not in WORD_TYPES:
                continue
            root = p.get("root")
            root = ROOT_FIXUPS.get(root, root)
            tags = normalize_tag_chain(root)
            if len(tags) > 1:
                pos_tags.update(tags[1:])
            affixes = p.get("affixes")
            if isinstance(affixes, str):
                affix_tags.update(normalize_tag_chain(affixes))
            elif isinstance(affixes, list):
                for item in affixes:
                    affix_tags.update(normalize_tag_chain(item))
    all_tags = sorted(pos_tags | affix_tags)
    (OUT_DIR / "tag_vocab.json").write_text(
        json.dumps({"pos_tags": sorted(pos_tags), "affix_tags": sorted(affix_tags),
                    "all_tags": all_tags}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    # --- report ---
    report = f"""# Dataset preparation report

Source: `yakutmorph_dataset/*/processed/*.json` (read-only)
Output: `seq2seq_parser/data/{{train,dev,test}}.jsonl`
Random seed: {RANDOM_SEED}

## Filtering

- Raw sentence-level entries read: {total_raw}
- Excluded (word-type token with a genuine missing-root annotation gap): {excluded_gap}
- Kept: {total_raw - excluded_gap}

Examples of excluded sentences (up to 20):
{chr(10).join('- ' + e for e in excluded_gap_examples)}

## Leakage control (duplicate surface sentences)

- Distinct surface sentences (`sah`): {len(by_sah)}
- Sentences appearing more than once: {n_consistent_dup_groups + n_conflicting_groups}
  - with identical gold parse every time: {n_consistent_dup_groups}
  - with a *different* gold parse across occurrences (annotator disagreement / genuine ambiguity): {n_conflicting_groups}
- All occurrences of any repeated sentence are forced into **train** (never split
  across train/dev/test) to avoid leaking identical or near-identical items into
  the evaluation sets. Splitting of dev/test is done only over the {len(unique_records)}
  sentences that occur exactly once in the corpus, stratified by (source folder, topic).

## Split sizes

| split | sentences | tokens |
|---|---|---|
| train | {len(train)} | {sum(r['n_tokens'] for r in train)} |
| dev   | {len(dev)} | {sum(r['n_tokens'] for r in dev)} |
| test  | {len(test)} | {sum(r['n_tokens'] for r in test)} |

## Root vocabulary / generalization

- Distinct root lemmas seen in train: {len(train_roots)}
- Dev: {dev_stats[0]}/{len(dev)} sentences contain at least one unseen root; {dev_stats[1]}/{dev_stats[2]} word tokens have an unseen root
- Test: {test_stats[0]}/{len(test)} sentences contain at least one unseen root; {test_stats[1]}/{test_stats[2]} word tokens have an unseen root

Each record in dev.jsonl/test.jsonl carries a `has_unseen_root` boolean for
slicing evaluation metrics into seen-root vs. unseen-root subsets.

## Target format

Each token in `target` is either:
- the literal surface text, for structural/non-analyzable tokens (types: {", ".join(sorted(LITERAL_TYPES))})
- `root+TAG1+TAG2+...` for analyzed word tokens (types: {", ".join(sorted(WORD_TYPES))}),
  normalizing the gold data's mixed `+`/`^` separators and list/string `affixes`
  representations into one consistent `+`-joined chain.

Tokens are space-joined in original token order. See `tag_vocab.json` for the
full closed set of POS/affix tags ({len(all_tags)} total: {len(pos_tags)} POS,
{len(affix_tags)} affix) to be reserved as atomic tokens in the subword
tokenizer built in the next step.
"""
    (OUT_DIR / "prepare_report.md").write_text(report, encoding="utf-8")
    print(report)


if __name__ == "__main__":
    main()
