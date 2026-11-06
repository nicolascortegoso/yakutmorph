# Reranker dataset preparation report

Source: `yakutmorph_dataset/*/processed/*.json` (read-only)
Split: reused verbatim from `seq2seq_parser/data/{train,dev,test}.jsonl`
Output: `disambiguation_model/data/{train,dev,test}.jsonl`

## Filtering

- Excluded (no split assignment — seq2seq project's own annotation-gap exclusion): 21
- Excluded (regenerated tokenization length != gold parse count): 6
  - 001/01_0279.json#4
  - 001/01_0299.json#12
  - 003/01_0113.json#50
  - 005/02_0003.json#1
  - 005/03_0005.json#11
  - 005/06_0002.json#17
- Excluded (sentence contains at least one token whose gold analysis is not among the regenerated candidates, see `fst_issues.md`): 954 sentences, costing 5848 word tokens total (1045 of them the actual unrecoverable tokens, the rest otherwise-fine tokens excluded along with their sentence)
  - of which intensifier-heuristic false positives: 11 sentences
  - of which genuine FST/lexicon gaps: 945 sentences

- Gold analyses rewritten into the transducer's current notation (listed in `gold_conversions.tsv`): 2788
  - possessive + case written as one tag (`+POSS.3SG+ACC` -> `+POSS.3SG.ACC`): 1771
  - `+REFL` / `+PASS` -> `+REFL/PASS`, where the transducer offers only the fused voice: 149
  - proper names `+N` -> `+PN`: 884

## Kept data

- Word tokens in kept (clean) sentences: 34778
  - Unambiguous (single candidate): 17493 (50.30%)
  - Ambiguous (2+ candidates): 17285 (49.70%)

## Example counts by split

| split | examples |
|---|---|
| train | 31354 |
| dev   | 1688 |
| test  | 1736 |
