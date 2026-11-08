# Reranker dataset preparation report

Source: `yakutmorph_dataset/*/processed/*.json` (read-only)
Split: `disambiguation_model/data/split.tsv` (stable across releases, see `update_split.py`)
Output: `disambiguation_model/data/{train,dev,test}.jsonl`

## Filtering

- Excluded (no split assignment, or a word without annotation): 45
- Excluded (regenerated tokenization length != gold parse count): 6
  - 003/01_0113.json#50
  - 005/02_0003.json#1
  - 005/03_0005.json#11
  - 005/06_0002.json#17
  - 020/18_0266.json#1
  - 020/19_0000.json#27
- Excluded (sentence contains at least one token whose gold analysis is not among the regenerated candidates, see `fst_issues.md`): 1810 sentences, costing 12166 word tokens total (1982 of them the actual unrecoverable tokens, the rest otherwise-fine tokens excluded along with their sentence)
  - of which intensifier-heuristic false positives: 30 sentences
  - of which genuine FST/lexicon gaps: 1783 sentences

- Gold analyses rewritten into the transducer's current notation (listed in `gold_conversions.tsv`): 19
  - possessive + case written as one tag (`+POSS.3SG+ACC` -> `+POSS.3SG.ACC`): 0
  - `+REFL` / `+PASS` -> `+REFL/PASS`, where the transducer offers only the fused voice: 0
  - proper names `+N` -> `+PN`: 19

## Kept data

- Word tokens in kept (clean) sentences: 80023
  - Unambiguous (single candidate): 40281 (50.34%)
  - Ambiguous (2+ candidates): 39742 (49.66%)

## Example counts by split

| split | examples |
|---|---|
| train | 72353 |
| dev   | 3779 |
| test  | 3891 |
