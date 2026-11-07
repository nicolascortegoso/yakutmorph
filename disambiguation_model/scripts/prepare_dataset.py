#!/usr/bin/env python3
"""
Build train/dev/test data for the FST-candidate reranker (morphological
disambiguation model described in nir/paper_2027.md).

yakutmorph_dataset/*/processed/*.json (READ-ONLY, never modified) preserves
only the single analysis an annotator selected per token, not the full
candidate set the transducer originally proposed (see paper_2027.md §3.1).
This script reconstructs it by re-running the transducer pipeline over each
gold sentence and matching the recovered gold analysis back to its position
among the regenerated candidates, then emits one training example per word
token (§3.2's augmentation scheme), marking the target word with
<TARGET>/</TARGET> in the sentence.

The sentence-level train/dev/test split is read from
disambiguation_model/data/split.tsv, which update_split.py keeps stable
across releases (it started as the seq2seq project's split). Sentences with
a word that has no annotation are excluded.
"""
import collections
import itertools
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT))

from yakutmorph.interfaces import DisambiguationModel
from yakutmorph.main import YakutMorph

DATASET_DIR = REPO_ROOT / "yakutmorph_dataset"
SPLIT_PATH = Path(__file__).resolve().parents[1] / "data" / "split.tsv"
OUT_DIR = Path(__file__).resolve().parents[1] / "data"

# Same constants as seq2seq_parser/scripts/prepare_dataset.py, needed to
# normalize the gold `root`/`affixes` fields into one "root+TAG1+TAG2+..."
# string directly comparable against raw transducer output (which already
# uses the same '+'-joined convention, see FINDINGS from this session).
LITERAL_TYPES = {
    "period", "comma", "hyphen", "question", "exclamation", "dash",
    "ellipsis", "quotation", "colon", "semicolon", "bracket", "number",
    "symbol", "roman", "unknown", "title_lat", "lowercase_lat",
}
WORD_TYPES = {"lowercase", "title", "uppercase"}
# One known data glitch (see seq2seq_parser/scripts/prepare_dataset.py):
# root glued directly to its POS tag with no separator.
ROOT_FIXUPS = {
    "баһырҕасN": "баһырҕас+N",
}
# Punctuation types that attach directly to the preceding token with no
# space, for reconstructing a natural-looking sentence string.
NO_SPACE_BEFORE = {
    "comma", "period", "colon", "semicolon", "question", "exclamation",
    "ellipsis", "hyphen",
}
NO_SPACE_AFTER = {"hyphen"}


def normalize_tag_chain(raw):
    if raw is None:
        return []
    parts = re.split(r"[+^]", raw)
    return [p for p in parts if p]


def gold_target_string(parse):
    """Normalizes one gold parse's root/affixes into a 'root+TAG1+...' string
    directly comparable to raw transducer output. Returns None for literal
    (non-word) token types, which have no candidates and aren't disambiguation
    targets. Raises ValueError on a genuine annotation gap (a word-type token
    with no root) so the caller can drop the sentence."""
    if parse.get("type") in LITERAL_TYPES:
        return None
    root = parse.get("root")
    root = ROOT_FIXUPS.get(root, root)
    if not root:
        raise ValueError("annotation gap")
    tags = normalize_tag_chain(root)
    affixes = parse.get("affixes")
    if isinstance(affixes, str):
        tags += normalize_tag_chain(affixes)
    elif isinstance(affixes, list):
        for item in affixes:
            tags += normalize_tag_chain(item)
    return "+".join(tags)


def load_split_ids():
    """Sentence id -> 'train'/'dev'/'test', from the stable split kept in
    disambiguation_model/data/split.tsv (see update_split.py)."""
    lines = SPLIT_PATH.read_text(encoding="utf-8").splitlines()[1:]
    return dict(line.split("\t") for line in lines)


def load_entries():
    for path in sorted(DATASET_DIR.glob("*/processed/*.json")):
        folder = path.parts[-3]
        data = json.loads(path.read_text(encoding="utf-8"))
        for entry in data:
            yield folder, path.name, entry


class _KeepAllCandidates(DisambiguationModel):
    """A stand-in disambiguator that leaves every candidate in place, so
    `YakutMorph.parse` returns the full candidate set of each token."""

    def disambiguate(self, tokens):
        return [0 for token in tokens if token.has_morph and token.is_ambiguous()]


class CandidateGenerator:
    """Regenerates a sentence's per-token candidates through the library's
    own analysis path (`YakutMorph.parse`: tokenizer, transducer pipeline,
    post-analysis such as +N -> +PN promotion of proper names, and the
    hyphen-construction handling). Training data therefore contains exactly
    the candidate strings the shipped reranker is given at inference time."""

    def __init__(self):
        self.morph = YakutMorph(disambiguation_model=_KeepAllCandidates())

    def candidates_for_sentence(self, sah):
        """Returns a list of {"text", "type", "candidates"} dicts, one per
        token, in original order."""
        return [
            {
                "text": token.surface,
                "type": token.type,
                "candidates": [
                    "".join(m.morpheme for m in analysis.morphemes)
                    for analysis in token.analyses.output
                ] if token.has_morph else [],
            }
            for token in self.morph.parse(sah).tokens
        ]


# The annotated corpus predates some notation changes in the transducer.
# Each rule rewrites a gold analysis into the current notation; a rewrite
# is only accepted when the result is literally one of the library's
# candidates for that token (see normalize_gold).
CASES = "ACC|DAT|ABL|INST|PRTV|COMIT|COMP"
POSS_CASE = re.compile(rf"\+POSS\.(\d(?:SG|PL))\+({CASES})\b")   # +POSS.3SG+ACC -> +POSS.3SG.ACC
CASE_POSS = re.compile(rf"\+({CASES})\+POSS\.(\d(?:SG|PL))\b")   # +INST+POSS.3SG -> +POSS.3SG.INST
GOLD_RULES = [
    ("poss_case_fused", lambda g: CASE_POSS.sub(r"+POSS.\2.\1", POSS_CASE.sub(r"+POSS.\1.\2", g))),
    # +REFL, +PASS and +REFL/PASS are different labels: some transitive
    # roots have separate reflexive and passive voices, others a single
    # fused reflexive-passive one (+REFL/PASS). Where the annotators wrote
    # +REFL or +PASS but the transducer offers only the +REFL/PASS
    # analysis for that word, the annotation is corrected to +REFL/PASS
    # (decision of the corpus author, 2026-11-06).
    ("refl_pass", lambda g: re.sub(r"\+(REFL|PASS)\b(?!/)", "+REFL/PASS", g)),
    # Names are tagged as common nouns in the corpus ('маша+N'); the
    # library promotes them to '+PN' (yakutmorph.transducers.PostPipeline).
    ("proper_name", lambda g: re.sub(r"^([^+]+)\+N\b", r"\1+PN", g)),
]


def normalize_gold(gold, candidates):
    """Returns (analysis, rules): the gold analysis rewritten into the
    transducer's current notation, and the names of the rules applied.
    Tries every combination of the rules in GOLD_RULES, fewest first, and
    accepts the first result that is one of `candidates`. Returns the gold
    analysis unchanged when it is already a candidate or when no
    combination produces one."""
    if gold in candidates:
        return gold, ()
    for n in range(1, len(GOLD_RULES) + 1):
        for combination in itertools.combinations(GOLD_RULES, n):
            rewritten = gold
            for _, rule in combination:
                rewritten = rule(rewritten)
            if rewritten != gold and rewritten in candidates:
                return rewritten, tuple(name for name, _ in combination)
    return gold, ()


def mark_target(rows, target_pos):
    """Reconstructs a natural-looking sentence string with the token at
    target_pos wrapped in <TARGET>/</TARGET>, using simple punctuation-
    attachment rules rather than naive space-joining."""
    pieces = []
    for i, row in enumerate(rows):
        text = f"<TARGET>{row['text']}</TARGET>" if i == target_pos else row["text"]
        if pieces and row["type"] not in NO_SPACE_BEFORE and rows[i - 1]["type"] not in NO_SPACE_AFTER:
            pieces.append(" ")
        pieces.append(text)
    return "".join(pieces)


def main():
    split_of = load_split_ids()
    generator = CandidateGenerator()

    out_records = {"train": [], "dev": [], "test": []}
    stats = collections.Counter()
    length_mismatches = []
    excluded_no_split = 0
    gold_conversions = []  # gold analyses rewritten into current notation, for review
    fst_issues = []  # diagnostics for sentences excluded due to an unrecoverable gold analysis

    for folder, filename, entry in load_entries():
        sid = f"{folder}/{filename}#{entry.get('id')}"
        split = split_of.get(sid)
        if split is None:
            excluded_no_split += 1  # not in split.tsv
            continue

        sah = entry.get("sah")
        parses = sorted(entry.get("parses", []), key=lambda p: p["pos"])

        try:
            gold_targets = [gold_target_string(p) for p in parses]
        except ValueError:
            excluded_no_split += 1  # a word without annotation
            continue

        regenerated = generator.candidates_for_sentence(sah)

        if len(regenerated) != len(parses):
            length_mismatches.append(sid)
            continue

        # First pass: check every word token's gold analysis is actually
        # recoverable before emitting anything for this sentence. A sentence
        # with even one unrecoverable token points at a real FST gap (missing
        # root/rule) and is excluded wholesale, since its other tokens' context
        # is only as trustworthy as the sentence itself — see disambiguation.md.
        for pos, (row, gold) in enumerate(zip(regenerated, gold_targets)):
            if gold is None:
                continue
            normalized, rules = normalize_gold(gold, row["candidates"])
            if rules:
                gold_targets[pos] = normalized
                gold_conversions.append((sid, pos, row["text"], gold, normalized, "+".join(rules)))
                for rule in rules:
                    stats[f"gold_rule_{rule}"] += 1

        problems = []
        n_word_tokens = 0
        for pos, (row, gold) in enumerate(zip(regenerated, gold_targets)):
            if gold is None:
                continue  # literal (non-word) token, not a disambiguation target
            n_word_tokens += 1
            if gold not in row["candidates"]:
                # A single candidate of exactly "<surface>+INTENS" means the
                # hyphen-construction detector (yakutmorph.intensifiers)
                # overwrote this token's real candidates with a synthetic
                # one that turned out wrong — a heuristic false positive to
                # fix in that module, not a transducer/lexicon gap.
                likely_cause = (
                    "intensifier_heuristic"
                    if row["candidates"] == [f"{row['text'].lower()}+INTENS"]
                    else "fst_gap"
                )
                problems.append({
                    "pos": pos,
                    "surface": row["text"],
                    "gold": gold,
                    "candidates": row["candidates"],
                    "likely_cause": likely_cause,
                })
        if problems:
            stats["excluded_sentences_fst_gap"] += 1
            stats["excluded_tokens_fst_gap"] += len(problems)
            stats["tokens_lost_in_excluded_sentences"] += n_word_tokens
            fst_issues.append({"id": sid, "sah": sah, "problems": problems})
            continue

        # Second pass: sentence is clean, emit one example per word token.
        for pos, (row, gold) in enumerate(zip(regenerated, gold_targets)):
            if gold is None:
                continue
            stats["total_word_tokens"] += 1
            candidates = row["candidates"]
            label = candidates.index(gold)
            stats["unambiguous" if len(candidates) == 1 else "ambiguous"] += 1

            out_records[split].append({
                "id": f"{sid}#{pos}",
                "sentence": mark_target(regenerated, pos),
                "candidates": candidates,
                "label": label,
            })

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for split, records in out_records.items():
        with open(OUT_DIR / f"{split}.jsonl", "w", encoding="utf-8") as f:
            for r in records:
                f.write(json.dumps(r, ensure_ascii=False) + "\n")

    def write_issue_section(f, issues, cause):
        filtered = [
            (issue, [p for p in issue["problems"] if p["likely_cause"] == cause])
            for issue in issues
        ]
        filtered = [(issue, ps) for issue, ps in filtered if ps]
        for issue, ps in filtered:
            f.write(f"## {issue['id']}\n\n`{issue['sah']}`\n\n")
            for p in ps:
                f.write(f"- **{p['surface']}** (pos {p['pos']}): gold=`{p['gold']}`, "
                        f"candidates={p['candidates']}\n")
            f.write("\n")
        return len(filtered)

    with open(OUT_DIR / "fst_issues.md", "w", encoding="utf-8") as f:
        f.write(
            "# Sentences excluded during data preparation\n\n"
            "Each sentence below was excluded in full because at least one of "
            "its tokens' gold analysis does not appear among the transducer's "
            "regenerated candidates. Split into two causes — see "
            "`yakutmorph/intensifiers.py`'s docstring for the first, and treat "
            "the second as an actual FST/lexicon worklist.\n\n"
        )
        f.write("## Intensifier-heuristic false positives\n\n"
                 "The hyphen-construction detector wrongly collapsed this "
                 "token's real candidates into a single synthetic `+INTENS` "
                 "one that doesn't match the gold analysis. Not a transducer "
                 "gap — fix in `yakutmorph/intensifiers.py`.\n\n")
        n_heuristic = write_issue_section(f, fst_issues, "intensifier_heuristic")
        f.write("\n## Genuine FST/lexicon gaps\n\n"
                 "The transducer's own candidates never included the gold "
                 "analysis — a worklist for FST fixes (missing root, missing "
                 "rule, or a rule that has since changed), not a data-quality "
                 "issue in `yakutmorph_dataset` itself.\n\n")
        n_fst_gap = write_issue_section(f, fst_issues, "fst_gap")

    with open(OUT_DIR / "gold_conversions.tsv", "w", encoding="utf-8") as f:
        f.write("sentence_id\ttoken\tsurface\tgold\tconverted\trules\n")
        for row in gold_conversions:
            f.write("\t".join(str(x) for x in row) + "\n")

    total = stats["total_word_tokens"]  # tokens in kept (clean) sentences only; all recoverable by construction
    report = f"""# Reranker dataset preparation report

Source: `yakutmorph_dataset/*/processed/*.json` (read-only)
Split: `disambiguation_model/data/split.tsv` (stable across releases, see `update_split.py`)
Output: `disambiguation_model/data/{{train,dev,test}}.jsonl`

## Filtering

- Excluded (no split assignment, or a word without annotation): {excluded_no_split}
- Excluded (regenerated tokenization length != gold parse count): {len(length_mismatches)}
{chr(10).join('  - ' + m for m in length_mismatches[:20])}
- Excluded (sentence contains at least one token whose gold analysis is not among the regenerated candidates, see `fst_issues.md`): {stats['excluded_sentences_fst_gap']} sentences, costing {stats['tokens_lost_in_excluded_sentences']} word tokens total ({stats['excluded_tokens_fst_gap']} of them the actual unrecoverable tokens, the rest otherwise-fine tokens excluded along with their sentence)
  - of which intensifier-heuristic false positives: {n_heuristic} sentences
  - of which genuine FST/lexicon gaps: {n_fst_gap} sentences

- Gold analyses rewritten into the transducer's current notation (listed in `gold_conversions.tsv`): {len(gold_conversions)}
  - possessive + case written as one tag (`+POSS.3SG+ACC` -> `+POSS.3SG.ACC`): {stats['gold_rule_poss_case_fused']}
  - `+REFL` / `+PASS` -> `+REFL/PASS`, where the transducer offers only the fused voice: {stats['gold_rule_refl_pass']}
  - proper names `+N` -> `+PN`: {stats['gold_rule_proper_name']}

## Kept data

- Word tokens in kept (clean) sentences: {total}
  - Unambiguous (single candidate): {stats['unambiguous']} ({stats['unambiguous'] / total * 100:.2f}%)
  - Ambiguous (2+ candidates): {stats['ambiguous']} ({stats['ambiguous'] / total * 100:.2f}%)

## Example counts by split

| split | examples |
|---|---|
| train | {len(out_records['train'])} |
| dev   | {len(out_records['dev'])} |
| test  | {len(out_records['test'])} |
"""
    (OUT_DIR / "prepare_report.md").write_text(report, encoding="utf-8")
    print(report)


if __name__ == "__main__":
    main()
