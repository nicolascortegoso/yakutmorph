# Tokenizer training report

## Input tokenizer

- Unique word forms (train, <TARGET>-marked): 18219
- Unique syllable types: 3691
- Vocab size sweep: [923, 1714, 2505, 3296, 4086, 4877, 5668, 6459]

  - vocab_size=923: EMD=0.8275
  - vocab_size=1714: EMD=0.3933
  - vocab_size=2505: EMD=0.3906
  - vocab_size=3296: EMD=0.4735
  - vocab_size=4086: EMD=0.5920
  - vocab_size=4877: EMD=0.7042
  - vocab_size=5668: EMD=0.8138
  - vocab_size=6459: EMD=0.9246

**Selected: vocab_size=2505 (EMD=0.3906)**


## Candidate (root) tokenizer

- Lexicon roots: 4727
- Unique syllable types: 2049
- Vocab size sweep: [512, 951, 1390, 1829, 2269, 2708, 3147, 3586]

  - vocab_size=512: EMD=1.0036
  - vocab_size=951: EMD=0.5359
  - vocab_size=1390: EMD=0.2505
  - vocab_size=1829: EMD=0.0717
  - vocab_size=2269: EMD=0.0444
  - vocab_size=2708: FAILED (INTERNAL: /Users/runner/work/sentencepiece/sentencepiece/src/trainer_interface.cc(744) [(trainer_spec_.vocab_size()) == (model_proto->pieces_size())] Vocabulary size too high (2708). Please set it to a value <= 2584.)
  - vocab_size=3147: FAILED (INTERNAL: /Users/runner/work/sentencepiece/sentencepiece/src/trainer_interface.cc(744) [(trainer_spec_.vocab_size()) == (model_proto->pieces_size())] Vocabulary size too high (3147). Please set it to a value <= 2584.)
  - vocab_size=3586: FAILED (INTERNAL: /Users/runner/work/sentencepiece/sentencepiece/src/trainer_interface.cc(744) [(trainer_spec_.vocab_size()) == (model_proto->pieces_size())] Vocabulary size too high (3586). Please set it to a value <= 2584.)

**Selected: vocab_size=2269 (EMD=0.0444)**
