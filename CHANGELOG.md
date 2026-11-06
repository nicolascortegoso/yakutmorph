# Changelog

## Unreleased

### Added
- Sentence splitting: `YakutMorph.parse_text` (one `Parse` per sentence),
  `yakutmorph.sentences.split_sentences`, and `mappers.conllu_document` for
  multi-sentence CoNLL-U. The MCP tools `analyze_text` and `to_conllu` now
  split their input into sentences (`analyze_text` returns `sentences`, each
  with its `tokens`, instead of a single `tokens` list).
- Confidence of the disambiguation: `token.analyses.probabilities` (the model's
  probability for each candidate) and `token.analyses.confidence` (that of the
  chosen analysis). The MCP tool `analyze_text` reports both.
  `DisambiguationModel` gains an optional `probabilities` method.
- `yakutmorph.corpus`: search a bundled snapshot of yakutmorph_dataset (18,873
  annotated sentences, corpus commit 393ebe9) by word form, root and/or tag,
  and the MCP tool `find_examples`, which uses it.

## 0.1.1 (2026-11-06)

### Fixed
- Proper nouns (`+PN`) had an empty lemma. Their lemma is now the root
  without inflectional affixes, as for every other word (`Кэскилгэ` → `кэскил`).

## 0.1.0 (2026-11-06)

### Added
- An MCP server for LLM applications: `pip install "yakutmorph[mcp]"`, then run
  `yakutmorph-mcp`. Tools: `analyze_text`, `analyze_word`, `to_conllu`,
  `explain_tags`, `list_tags`, `generate_word_form`.

### Changed
- Requires Python 3.10 or newer (3.8 and 3.9 are no longer supported upstream).
- Morphological disambiguation now uses the ONNX reranker (`YakutReranker`) on
  `onnxruntime`; `torch` is no longer a dependency.
- `YakutMorph` can be imported directly: `from yakutmorph import YakutMorph`
  (`from yakutmorph.main import YakutMorph` still works). Added
  `yakutmorph.__version__`.
- Updated transducers and lexicons.
- A capitalized word right after sentence-ending punctuation (. ... ? ! — :)
  counts as sentence-initial, so it is tagged `+PN` only if it is a listed
  name (e.g. "Суох" in "— Суох." stays `+N`); so does a word after a
  quotation mark that opens a sentence (direct speech). `PostAnalysis.apply`
  takes an optional `sentence_initial` argument for this.
- Listed names that are also common words (`data/name_homonyms.txt`, e.g.
  "харах" 'eye') are tagged `+PN` only in mid-sentence.

### Fixed
- A standalone `YakutTransducer()` is labelled `voc`, as in the pipeline
  (it was `ymv`). Transducer labels are `voc`, `syl`, `aff` and `fail`.
- `YakutManualDisambiguation` repeated the last analysis of an ambiguous word
  instead of listing each one, and its output could not be written as JSON.
- `import yakutmorph` failed on environments without `setuptools` (the default
  for new virtual environments on Python 3.12+), because package data was
  located with the deprecated `pkg_resources`. It now uses `importlib.resources`.
- Tags containing a slash, such as `+REFL/PASS`, were cut short (`+REFL/PASS` came out as `+REFL`, a different analysis).
- Possessive + case tags (`+POSS.3SG.ACC`) had no reference entry, so CoNLL-U
  output lost their case and possessor features.
- Data files are read as UTF-8 on every platform (previously the system
  default encoding was used, which breaks on Windows).

## 0.0.5 (2024-06-15)

First release on PyPI.
