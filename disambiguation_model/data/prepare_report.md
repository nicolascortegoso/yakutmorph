# Reranker dataset preparation report

Source: `yakutmorph_dataset/*/processed/*.json` (read-only)
Split: reused verbatim from `seq2seq_parser/data/{train,dev,test}.jsonl`
Output: `disambiguation_model/data/{train,dev,test}.jsonl`

## Filtering

- Excluded (no split assignment — seq2seq project's own annotation-gap exclusion): 45
- Excluded (regenerated tokenization length != gold parse count): 21
  - 003/01_0113.json#50
  - 005/02_0003.json#1
  - 005/03_0005.json#11
  - 005/06_0002.json#17
  - 020/18_0266.json#1
  - 020/19_0000.json#27
  - 101/01_0003.json#27
  - 101/01_0003.json#31
  - 101/01_0007.json#13
  - 101/01_0007.json#50
  - 101/01_0007.json#60
  - 101/01_0007.json#68
  - 101/01_0009.json#15
  - 101/01_0009.json#33
  - 101/01_0014.json#6
  - 101/01_0015.json#13
  - 101/01_0017.json#30
  - 101/01_0025.json#14
  - 101/01_0025.json#24
  - 101/01_0026.json#98
- Excluded (sentence contains at least one token whose gold analysis is not among the regenerated candidates, see `fst_issues.md`): 1795 sentences, costing 12056 word tokens total (1963 of them the actual unrecoverable tokens, the rest otherwise-fine tokens excluded along with their sentence)
  - of which intensifier-heuristic false positives: 30 sentences
  - of which genuine FST/lexicon gaps: 1768 sentences

- Gold analyses rewritten into the transducer's current notation (listed in `gold_conversions.tsv`): 0
  - possessive + case written as one tag (`+POSS.3SG+ACC` -> `+POSS.3SG.ACC`): 0
  - `+REFL` / `+PASS` -> `+REFL/PASS`, where the transducer offers only the fused voice: 0
  - proper names `+N` -> `+PN`: 0

## Kept data

- Word tokens in kept (clean) sentences: 78681
  - Unambiguous (single candidate): 39568 (50.29%)
  - Ambiguous (2+ candidates): 39113 (49.71%)

## Example counts by split

| split | examples |
|---|---|
| train | 71156 |
| dev   | 3689 |
| test  | 3836 |
