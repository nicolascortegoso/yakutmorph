#!/usr/bin/env python3
"""
Rewrites annotations in yakutmorph_dataset/*/processed/*.json into the
transducer's current notation, using the same rules and the same
candidate check as prepare_dataset.py (GOLD_RULES / normalize_gold):

- possessive + case as one tag: +POSS.3SG+ACC -> +POSS.3SG.ACC
- +REFL / +PASS -> +REFL/PASS, where the transducer offers only the fused
  reflexive-passive voice for that word
- proper names: +N -> +PN

A word's annotation is only changed when the annotated analysis is not
among the library's candidates for it and the rewritten one is. Only the
lines of the changed words are rewritten; every other byte of each file is
left as it was. A word is skipped (and reported) when its annotation cannot
be rewritten without moving the boundary between its "root" and "affixes"
fields.

Usage:
    python disambiguation_model/scripts/update_corpus_notation.py          # report only
    python disambiguation_model/scripts/update_corpus_notation.py --write  # change the files
    ... --rules poss_case_fused,refl_pass   # only these rules (names as in GOLD_RULES)
    ... --report path/to/report.tsv         # where to write the list of changes

Writes the list of changes to yakutmorph_dataset/reports/notation_update.tsv
unless --report is given."""
import collections
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import prepare_dataset as prep  # noqa: E402

DATASET_DIR = prep.DATASET_DIR
REPORT_PATH = DATASET_DIR / "reports" / "notation_update.tsv"


def chain(field):
    """The tags of a 'root' or 'affixes' field (a string such as
    'булт+N', '+POSS.3SG+ACC', or a list such as ['+V', '+PART_PRES'])."""
    if field is None:
        return []
    if isinstance(field, list):
        field = "".join(field)
    return prep.normalize_tag_chain(field)


def new_fields(parse, target):
    """The 'root' and 'affixes' values giving the analysis `target`, in the
    same format as the original fields, or None if the change would cross
    the boundary between the two fields."""
    root, affixes = parse["root"], parse.get("affixes")
    if affixes and "^" in "".join(affixes):
        return None
    old_root = chain(root)
    new = target.split("+")
    k = len(old_root)
    # The root field keeps its morphemes; only +N -> +PN may change there.
    for old, now in zip(old_root, new[:k]):
        if old != now and not (old == "N" and now == "PN"):
            return None
    rest = new[k:]
    if affixes is None and rest:
        return None
    # An unchanged root field is kept exactly as written (some folders
    # still use the older '^' separator, e.g. 'эт^V').
    fields = {"root": root if new[:k] == old_root else "+".join(new[:k])}
    if "^" in fields["root"] and fields["root"] != root:
        return None
    if affixes is not None:
        fields["affixes"] = ["+" + t for t in rest] if isinstance(affixes, list) else "".join("+" + t for t in rest)
    return fields


def plan_file(path, generator, stats, report):
    """Returns {(entry index, pos): new parse dict} for one file."""
    edits = {}
    data = json.loads(path.read_text(encoding="utf-8"))
    for entry_idx, entry in enumerate(data):
        parses = sorted(entry.get("parses", []), key=lambda p: p["pos"])
        if not parses:
            continue
        rows = generator.candidates_for_sentence(entry["sah"])
        if len(rows) != len(parses):
            stats["entries_skipped_tokenization"] += 1
            continue
        for parse, row in zip(parses, rows):
            try:
                gold = prep.gold_target_string(parse)
            except ValueError:
                continue
            if gold is None:
                continue
            target, rules = prep.normalize_gold(gold, row["candidates"])
            if not rules:
                continue
            fields = new_fields(parse, target)
            if fields is None:
                stats["words_skipped_field_boundary"] += 1
                report.append((path, entry.get("id"), parse["pos"], parse["text"], gold, target, "+".join(rules), "SKIPPED"))
                continue
            updated = {**parse, **fields}
            assert "+".join(chain(updated["root"]) + chain(updated.get("affixes"))) == target
            edits[(entry_idx, parse["pos"])] = updated
            for rule in rules:
                stats[f"rule_{rule}"] += 1
            stats["words_changed"] += 1
            report.append((path, entry.get("id"), parse["pos"], parse["text"], gold, target, "+".join(rules), "changed"))
    return edits


def apply_edits(path, edits):
    """Replaces only the lines of the edited parses, keeping indentation
    and trailing commas, and checks the result."""
    lines = path.read_text(encoding="utf-8").split("\n")
    entry_idx = -1
    done = 0
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('"parses": ['):
            entry_idx += 1
        if not stripped.startswith('{"pos"'):
            continue
        comma = stripped.endswith(",")
        parse = json.loads(stripped.rstrip(","))
        key = (entry_idx, parse["pos"])
        if key in edits:
            indent = line[: len(line) - len(line.lstrip())]
            lines[i] = indent + json.dumps(edits[key], ensure_ascii=False) + ("," if comma else "")
            done += 1
    assert done == len(edits), f"{path}: {done} of {len(edits)} edits applied"
    text = "\n".join(lines)
    json.loads(text)
    path.write_text(text, encoding="utf-8")


def main():
    write = "--write" in sys.argv
    report_path = Path(sys.argv[sys.argv.index("--report") + 1]) if "--report" in sys.argv else REPORT_PATH
    if "--rules" in sys.argv:
        chosen = sys.argv[sys.argv.index("--rules") + 1].split(",")
        unknown = set(chosen) - {name for name, _ in prep.GOLD_RULES}
        if unknown:
            sys.exit(f"Unknown rules: {sorted(unknown)}")
        prep.GOLD_RULES[:] = [rule for rule in prep.GOLD_RULES if rule[0] in chosen]
    print("Rules:", ", ".join(name for name, _ in prep.GOLD_RULES))
    generator = prep.CandidateGenerator()
    stats = collections.Counter()
    report = []
    files_changed = 0
    for path in sorted(DATASET_DIR.glob("*/processed/*.json")):
        edits = plan_file(path, generator, stats, report)
        if edits:
            files_changed += 1
            if write:
                apply_edits(path, edits)

    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("file\tentry_id\tpos\ttext\tannotation\tnew_annotation\trules\tstatus\n")
        for path, entry_id, pos, text, gold, target, rules, status in report:
            f.write(f"{path.relative_to(DATASET_DIR)}\t{entry_id}\t{pos}\t{text}\t{gold}\t{target}\t{rules}\t{status}\n")

    print(f"{'Changed' if write else 'Would change'} {stats['words_changed']} words in {files_changed} files")
    for key in ("rule_poss_case_fused", "rule_refl_pass", "rule_proper_name"):
        print(f"  {key[5:]}: {stats[key]}")
    print(f"Skipped (change would cross the root/affixes boundary): {stats['words_skipped_field_boundary']}")
    print(f"Entries not checked (tokenization differs from the annotation): {stats['entries_skipped_tokenization']}")
    print(f"Report: {report_path}")


if __name__ == "__main__":
    main()
