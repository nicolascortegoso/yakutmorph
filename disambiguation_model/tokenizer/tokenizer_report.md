# Tokenizer training report

## Input tokenizer

- Unique word forms (train, <TARGET>-marked): 18341
- Unique syllable types: 3707
- Vocab size sweep: [927, 1721, 2516, 3310, 4104, 4898, 5693, 6487]

  - vocab_size=927: EMD=0.8069
  - vocab_size=1721: EMD=0.3958
  - vocab_size=2516: EMD=0.3980
  - vocab_size=3310: EMD=0.4784
  - vocab_size=4104: EMD=0.5933
  - vocab_size=4898: EMD=0.7033
  - vocab_size=5693: EMD=0.8110
  - vocab_size=6487: EMD=0.9232

**Selected: vocab_size=1721 (EMD=0.3958)**


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
