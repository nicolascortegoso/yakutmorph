#!/usr/bin/env python3
"""
Trains the two SentencePiece Unigram tokenizers described in paper_2027.md
§3.3: one for input sentences, one for candidate roots. Both select their
vocabulary size by minimizing the Earth Mover's Distance (EMD) between the
resulting subword-count distribution and an "ideal" distribution derived
from each word/root's own true morphological structure, sweeping vocab
sizes across ±75% of the corpus's unique syllable count.

Reads disambiguation_model/data/train.jsonl (built by prepare_dataset.py)
for the input side, and the sibling seq2seq project's already-extracted
external root lexicon (seq2seq_parser/data/external_lexicon_roots.txt,
itself derived from vocabulary/yakut_roots/*.lex) for the candidate side.
"""
import json
import re
import sys
from pathlib import Path

import sentencepiece as spm

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT))

from yakutmorph.transducers import YakutTransducer

DATA_DIR = Path(__file__).resolve().parents[1] / "data"
TOKENIZER_DIR = Path(__file__).resolve().parents[1] / "tokenizer"
EXTERNAL_LEXICON = REPO_ROOT / "seq2seq_parser" / "data" / "external_lexicon_roots.txt"
SYLLABIFIER_PATH = REPO_ROOT / "tools" / "syllabification.a"

MORPHEME_RE = re.compile(r"[а-яёһҕҥөү]+|[\^\+][A-Za-z_#\d\.\/]+")
TARGET_RE = re.compile(r"<TARGET>(.+?)</TARGET>")

# Range swept around the corpus's own unique-syllable count, per §3.3.
SWEEP_LOW_FRACTION = 0.25   # -75%
SWEEP_HIGH_FRACTION = 1.75  # +75%
SWEEP_STEPS = 8


class Syllabifier:
    """Wraps the dedicated Yakut syllabification FST (tools/syllabification.a,
    https://github.com/nicolascortegoso/yakutsyllabification). Falls back to
    character length / 3 (the average Yakut syllable length) on words that
    deviate from the expected canonical syllable structure, where the FST
    produces no analysis — see paper_2027.md §3.3."""

    def __init__(self):
        self.transducer = YakutTransducer(str(SYLLABIFIER_PATH), label="syl")

    def count(self, word):
        result = self.transducer.analyse(word.lower())
        if result:
            return result[0].count("##") + 1
        return max(1, round(len(word) / 3))


def wasserstein_1d(a, b):
    """1-D Earth Mover's Distance between two empirical distributions given
    as lists of values (the area between their empirical CDFs) — the exact,
    closed-form solution for the 1-D case, no optimal-transport solver
    needed."""
    a, b = sorted(a), sorted(b)
    na, nb = len(a), len(b)
    all_vals = sorted(set(a) | set(b))
    if len(all_vals) < 2:
        return 0.0
    total = 0.0
    ia = ib = 0
    for i in range(len(all_vals) - 1):
        v = all_vals[i]
        while ia < na and a[ia] <= v:
            ia += 1
        while ib < nb and b[ib] <= v:
            ib += 1
        total += abs(ia / na - ib / nb) * (all_vals[i + 1] - v)
    return total


def vocab_sweep(low, high, n=SWEEP_STEPS):
    """n evenly-spaced integer vocab sizes across [low, high]."""
    if high <= low:
        return [max(low, 16)]
    step = (high - low) / (n - 1)
    return sorted({max(16, round(low + i * step)) for i in range(n)})


def train_and_score(corpus_path, ideal_counts, vocab_size, model_prefix, extra_symbols=None):
    """Trains one SentencePiece Unigram model at `vocab_size` and returns
    (emd_against_ideal_counts, model_path), or (None, None) if training
    fails (vocab_size too large for the corpus)."""
    kwargs = dict(
        input=str(corpus_path),
        model_prefix=str(model_prefix),
        vocab_size=vocab_size,
        model_type="unigram",
        character_coverage=1.0,
        unk_id=0, pad_id=1, bos_id=2, eos_id=3,
    )
    if extra_symbols:
        kwargs["user_defined_symbols"] = extra_symbols
    try:
        spm.SentencePieceTrainer.train(**kwargs)
    except Exception as exc:  # vocab_size unreachable for this corpus, etc.
        return None, str(exc)

    sp = spm.SentencePieceProcessor(model_file=str(model_prefix) + ".model")
    actual_counts = [len(sp.encode(w, out_type=str)) for w in ideal_counts.words]
    emd = wasserstein_1d(actual_counts, ideal_counts.values)
    return emd, None


class IdealCounts:
    def __init__(self, words, values):
        self.words = words   # the words/roots to tokenize when scoring a candidate model
        self.values = values  # their "ideal" subword counts, same order


def build_input_ideal_counts(syllabifier):
    """One entry per unique word form seen as a <TARGET> in train.jsonl,
    ideal count = affixes (excluding the root's own category tag) + root
    syllable count."""
    seen = {}
    with open(DATA_DIR / "train.jsonl", encoding="utf-8") as f:
        for line in f:
            rec = json.loads(line)
            m = TARGET_RE.search(rec["sentence"])
            if not m:
                continue
            surface = m.group(1)
            gold = rec["candidates"][rec["label"]]
            if surface.lower() in seen:
                continue
            morphs = MORPHEME_RE.findall(gold)
            root = morphs[0]
            n_affixes = max(0, len(morphs) - 2)  # exclude root and its own category tag
            seen[surface.lower()] = n_affixes + syllabifier.count(root)
    words = list(seen.keys())
    values = [seen[w] for w in words]
    return words, values


def build_input_corpus_file(out_path):
    """Raw sentence text (<TARGET> markers stripped) for every train.jsonl
    example, one per line — the actual text SentencePiece trains on. Uses
    every example, not just unique sentences, so word frequency in the
    trained vocabulary reflects the augmented training distribution."""
    seen_sentences = set()
    with open(DATA_DIR / "train.jsonl", encoding="utf-8") as f, \
         open(out_path, "w", encoding="utf-8") as out:
        for line in f:
            rec = json.loads(line)
            plain = rec["sentence"].replace("<TARGET>", "").replace("</TARGET>", "")
            if plain in seen_sentences:
                continue
            seen_sentences.add(plain)
            out.write(plain + "\n")


def main():
    TOKENIZER_DIR.mkdir(parents=True, exist_ok=True)
    syllabifier = Syllabifier()
    report_lines = ["# Tokenizer training report\n"]

    # ---- Input tokenizer ----
    print("Building input tokenizer training data and ideal-count target...")
    input_corpus_path = TOKENIZER_DIR / "input_corpus.txt"
    build_input_corpus_file(input_corpus_path)
    input_words, input_ideal = build_input_ideal_counts(syllabifier)
    input_ideal_counts = IdealCounts(input_words, input_ideal)

    unique_syllables = set()
    for w in input_words:
        result = syllabifier.transducer.analyse(w.lower())
        pieces = result[0].split("##") if result else [w]
        unique_syllables.update(pieces)
    n_unique_syllables = len(unique_syllables)
    low = round(n_unique_syllables * SWEEP_LOW_FRACTION)
    high = round(n_unique_syllables * SWEEP_HIGH_FRACTION)
    sweep = vocab_sweep(low, high)
    report_lines.append(f"## Input tokenizer\n\n- Unique word forms (train, <TARGET>-marked): {len(input_words)}"
                         f"\n- Unique syllable types: {n_unique_syllables}\n- Vocab size sweep: {sweep}\n")

    best = (None, float("inf"), None)
    for vs in sweep:
        emd, err = train_and_score(
            input_corpus_path, input_ideal_counts, vs,
            TOKENIZER_DIR / f"input_v{vs}", extra_symbols=["<TARGET>", "</TARGET>"],
        )
        status = f"EMD={emd:.4f}" if emd is not None else f"FAILED ({err})"
        report_lines.append(f"  - vocab_size={vs}: {status}")
        if emd is not None and emd < best[1]:
            best = (vs, emd, TOKENIZER_DIR / f"input_v{vs}")
    report_lines.append(f"\n**Selected: vocab_size={best[0]} (EMD={best[1]:.4f})**\n")
    (TOKENIZER_DIR / "spm_input.model").write_bytes((Path(str(best[2]) + ".model")).read_bytes())
    (TOKENIZER_DIR / "spm_input.vocab").write_bytes((Path(str(best[2]) + ".vocab")).read_bytes())

    # ---- Candidate (root) tokenizer ----
    print("Building candidate tokenizer training data and ideal-count target...")
    roots = [r.strip() for r in EXTERNAL_LEXICON.read_text(encoding="utf-8").splitlines() if r.strip()]
    root_ideal = [syllabifier.count(r) for r in roots]
    root_ideal_counts = IdealCounts(roots, root_ideal)

    unique_syllables = set()
    for r in roots:
        result = syllabifier.transducer.analyse(r.lower())
        pieces = result[0].split("##") if result else [r]
        unique_syllables.update(pieces)
    n_unique_syllables = len(unique_syllables)
    low = round(n_unique_syllables * SWEEP_LOW_FRACTION)
    high = round(n_unique_syllables * SWEEP_HIGH_FRACTION)
    sweep = vocab_sweep(low, high)
    report_lines.append(f"\n## Candidate (root) tokenizer\n\n- Lexicon roots: {len(roots)}"
                         f"\n- Unique syllable types: {n_unique_syllables}\n- Vocab size sweep: {sweep}\n")

    best = (None, float("inf"), None)
    for vs in sweep:
        emd, err = train_and_score(
            EXTERNAL_LEXICON, root_ideal_counts, vs, TOKENIZER_DIR / f"candidate_v{vs}",
        )
        status = f"EMD={emd:.4f}" if emd is not None else f"FAILED ({err})"
        report_lines.append(f"  - vocab_size={vs}: {status}")
        if emd is not None and emd < best[1]:
            best = (vs, emd, TOKENIZER_DIR / f"candidate_v{vs}")
    report_lines.append(f"\n**Selected: vocab_size={best[0]} (EMD={best[1]:.4f})**\n")
    (TOKENIZER_DIR / "spm_candidate.model").write_bytes((Path(str(best[2]) + ".model")).read_bytes())
    (TOKENIZER_DIR / "spm_candidate.vocab").write_bytes((Path(str(best[2]) + ".vocab")).read_bytes())

    report = "\n".join(report_lines)
    (TOKENIZER_DIR / "tokenizer_report.md").write_text(report, encoding="utf-8")
    print(report)


if __name__ == "__main__":
    main()
