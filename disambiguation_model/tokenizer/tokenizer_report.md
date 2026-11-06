# Tokenizer training report

## Input tokenizer

- Unique word forms (train, <TARGET>-marked): 10588
- Unique syllable types: 2739
- Vocab size sweep: [685, 1272, 1859, 2446, 3032, 3619, 4206, 4793]

  - vocab_size=685: EMD=1.0279
  - vocab_size=1272: EMD=0.5067
  - vocab_size=1859: EMD=0.3710
  - vocab_size=2446: EMD=0.4541
  - vocab_size=3032: EMD=0.5202
  - vocab_size=3619: EMD=0.6566
  - vocab_size=4206: EMD=0.7861
  - vocab_size=4793: EMD=0.8869

**Selected: vocab_size=1859 (EMD=0.3710)**


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
