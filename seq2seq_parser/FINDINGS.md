# Seq2seq Yakut Morphological Parser — Findings

Goal: train a seq2seq RNN with attention that maps a raw Yakut sentence to a
linearized morphological parse (e.g. `быыкаа дьиэ оҕото` →
`быыкаа+Adj дьиэ+N оҕо+N+POSS.3SG`), using the gold-annotated
`yakutmorph_dataset` as training data.

All numbers below are on the held-out **test** set (816 sentences) unless
stated otherwise. Full artifacts (configs, logs, predictions, plots) are in
`seq2seq_parser/checkpoints*/` and `seq2seq_parser/attention_plots/`.

---

## 1. Dataset

Source: `yakutmorph_dataset/*/processed/*.json` (read-only throughout — never
modified). See `data/prepare_report.md` for the full, reproducible account;
summary:

- **17,316** raw gold sentence entries → **39** excluded (genuine annotation
  gaps: a word-type token with no `root` at all) → **17,277** kept.
- **Target format**: each token is either the literal surface text
  (punctuation/numbers/symbols — confirmed to *never* carry a `root` in the
  gold data, ~20% of all tokens) or `root+TAG1+TAG2+...` for analyzed word
  tokens, normalizing the gold data's inconsistent `+`/`^` separators and
  string/list `affixes` representations into one convention.
- **Leakage control**: 1,047 sentences repeat verbatim in the corpus (810
  with identical gold parses, 237 with *conflicting* parses — annotator
  disagreement on the same sentence). All occurrences of any repeated
  sentence are forced into train; dev/test are drawn only from the 14,965
  sentences that occur exactly once, stratified by (source folder, topic).
- **Split**: 15,645 train / 816 dev / 816 test (90.6% / 4.7% / 4.7%).
- **Root vocabulary**: 4,872 distinct root lemmas in train. 108/816 test
  sentences (136/3,937 word tokens) contain at least one root never seen in
  training — this `has_unseen_root` flag is carried on every dev/test record
  and used throughout to separate raw accuracy from generalization to new
  vocabulary.

## 2. Tokenizer

Two designs were tried, in this order.

### v1 — single shared SentencePiece vocabulary
One unigram model (vocab_size=4,000) trained jointly on both the `sah`
sentences and the `target` strings, with all 205 morphological tags (`+N`,
`+POSS.3SG`, ...) reserved as atomic user-defined symbols so they're never
subword-split. Rationale: a shared vocabulary lets a source subword and a
target root share the same embedding, an implicit "copy" signal for OOV
roots (Yakut is suffixing-only, so a root is almost always a literal — if
sound-change-adjusted — prefix of its surface form).

### v2 — separate source/target vocabularies (adopted)
Two independent unigram models, each with its own full 4,000-piece budget:
- `spm_src`: trained on the raw `sah` sentences (unchanged).
- `spm_tgt`: trained on the **root portion only** of every word-type token
  occurrence (one line per occurrence, frequency-weighted) plus literal
  tokens verbatim, same 205 reserved tags.

Rationale (user-proposed, empirically confirmed): a joint vocabulary has to
split its budget between full inflected sentence text (suffix chains,
function words, punctuation — large and diverse) and bare roots (small,
homogeneous), under-serving root coverage. Dedicating the target's entire
budget to root text gave every metric a real improvement (see §4) — this
outweighed the loss of the shared-embedding copy signal that motivated v1,
contrary to my initial expectation.

Both tokenizer trainings, and every model trained against them, use
`text_utils.normalize_text` (NFC + lowercase) consistently — including the
reserved tag strings themselves, which must be lowercased identically to the
corpus or they silently stop matching and get shredded into junk pieces
(a bug caught and fixed during this work).

## 3. Model architecture

BiGRU encoder + Luong general-attention GRU decoder with input feeding
(Luong et al. 2015):
- Encoder: 2-layer bidirectional GRU, hidden size 512, embedding size 256.
  Final per-layer [forward;backward] hidden is projected (`Linear` + `tanh`)
  down to seed the unidirectional decoder.
- Decoder: 2-layer GRU, input-feeding (previous attentional hidden state is
  concatenated to the embedding at every step), Luong "general" (bilinear)
  attention over encoder outputs.
- v1 shared one embedding table between encoder and decoder; v2 uses two
  separate embedding tables (one per vocabulary).
- ~15-16M parameters depending on vocab sizes.

## 4. Training & results

Adam (lr=1e-3, `ReduceLROnPlateau`), label smoothing 0.1, gradient clipping
at norm 1.0, teacher forcing ratio 0.75, batch size 64, 30 epochs, trained
on an Apple M5 via PyTorch MPS (~30s/epoch typical; one run anomalously
slowed to 15-30x for ~10 epochs before recovering — never root-caused,
possibly OS-level throttling on a backgrounded process, did not recur).

### 4.1 Decoding: greedy vs. beam search

Beam search alone helps; **tuning it (length-alpha + no-repeat-ngram
blocking) fixes a real failure mode** — plain beam search introduced
repetition loops (e.g. a tag repeated 8x) in 33/816 test predictions,
which grid search on a dev subset traced almost entirely to length
normalization rewarding a confident repeated continuation. `beam_size=5,
length_alpha=0.7, no_repeat_ngram_size=3` eliminated every repetition loop
(33/816 → 0/816) and became the standing default for all later evaluation.

| decoding (v1 shared-vocab model) | exact match | token acc | root acc | tag-chain acc |
|---|---|---|---|---|
| greedy | 15.2% | 33.6% | 52.1% | 44.0% |
| beam=5 (untuned, α=1.0) | 16.1% | 41.0% | 54.9% | 47.1% |
| **beam=5, α=0.7, ngram-block=3** | 15.8% | **50.3%** | 54.3% | 45.5% |

### 4.2 Tokenizer ablation: shared vs. separate vocabularies

Separate vocabularies won outright on every metric, at both decoding
settings, including the unseen-root subset specifically — the opposite of
what the "shared vocab gives a free copy signal" theory predicted going in.

| model | decode | exact | token acc | root acc | tag acc | unseen-root token acc | unseen-root root acc |
|---|---|---|---|---|---|---|---|
| v1 shared vocab | greedy | 15.2% | 33.6% | 52.1% | 44.0% | 9.0% | 30.4% |
| v1 shared vocab | tuned beam | 15.8% | 50.3% | 54.3% | 45.5% | 13.2% | 32.0% |
| **v2 separate vocab** | greedy | 19.1% | 40.7% | 55.1% | 47.6% | 19.5% | 32.0% |
| **v2 separate vocab** | **tuned beam** | **20.0%** | **54.2%** | **57.8%** | **50.1%** | **38.7%** | **36.3%** |

### 4.3 Target vocabulary size ablation

Hypothesis tested (user-proposed): a *smaller* target vocabulary would force
root decomposition into reusable, syllable/morpheme-like pieces (the
classical BPE motivation), which should specifically help reconstructing
unseen roots from familiar fragments. Tested target vocab_size ∈
{1000, 2000, 4000} (source fixed at 4000), all with tuned beam decoding.

| target vocab_size | exact | token acc | root acc | tag acc | unseen-root token acc | unseen-root root acc |
|---|---|---|---|---|---|---|
| 1000 | 15.0% | 48.7% | 50.2% | 44.7% | 35.7% | 30.2% |
| 2000 | 18.4% | 53.5% | 56.6% | 48.7% | 38.4% | 35.0% |
| **4000** | **20.0%** | **54.2%** | **57.8%** | **50.1%** | **38.7%** | **36.3%** |

**Result: the hypothesis did not hold.** Bigger is monotonically better
across every metric tested, seen and unseen roots alike. Likely explanation:
the classical BPE argument pays off when a model has enough training signal
to learn to *compose* fine-grained pieces reliably (typically shown at much
larger corpus scale); here (~15.6k sentences, a modest RNN) shrinking the
vocab mainly lengthens root sequences, giving more opportunities for
per-step decoding error, without enough signal to earn back a compositional
generalization benefit. There is also a structural asymmetry: a larger
unigram vocabulary is never forced to use its bigger memorized pieces — it
can still fall back to fine segmentation for a genuinely novel root — so a
big vocab is a superset of a small vocab's segmentation options, not a
different, competing strategy.

### 4.4 Copy/pointer mechanism (adopted)

The seen/unseen gap in §4.2-4.3 is structural, not a hyperparameter problem:
the decoder can only ever emit pieces it learned as generation targets, so a
sentence needing a root it never saw as a *target* during training has no
path to being produced correctly, no matter how the vocabulary is tuned. A
copy/pointer mechanism (See et al. 2017-style) targets this directly — let
the decoder optionally copy a piece straight out of the source sentence
instead of only generating from its fixed vocabulary.

**The complication**: classic pointer-generator networks assume source and
target share one vocabulary, so "copying" just means inserting a shared
token id into the output distribution. §4.2 deliberately gave up a shared
vocabulary (and won by doing so), so there's no shared id space to copy
through. Resolution: match source and target pieces **by surface string**
instead of by id. Both tokenizers guarantee full character coverage over the
same Yakut alphabet, so this degrades gracefully to character-level copying
in the worst case rather than failing outright — confirmed empirically
before building anything: **37% of all `spm_src` pieces have an
identical-string counterpart in `spm_tgt`** (mostly short syllables, single
characters, and a good number of whole common words — pronouns, particles,
postpositions — whose root *is* their unmodified surface form).

Mechanism, per decoder step:
- `p_vocab` — the usual softmax generation distribution over the target
  vocabulary.
- `copy_dist` — attention weights scattered into whichever target-vocab
  slots the currently-attended source pieces' surface strings match (via a
  precomputed per-example `src_tgt_map`, §dataset.py); a source position
  with no matching target piece simply contributes nothing to copying.
- `p_gen` — a learned scalar gate (sigmoid over `[context; decoder hidden;
  input embedding]`) mixing the two: `P = p_gen · p_vocab + (1−p_gen) · copy_dist`.

Gold targets are always in-vocabulary by construction (they come from the
same `spm_tgt` model), so training needs no dynamic/extended vocabulary —
the copy channel is a pure additional signal on top of the existing
softmax, not a replacement mechanism. Loss changed accordingly, from
`CrossEntropyLoss` to a manual NLL directly against this probability
mixture (label smoothing dropped for simplicity — a disclosed regression in
rigor, not yet reintroduced).

**Result — the single largest improvement in this project**, bigger than
the tokenizer split or beam tuning:

| | previous best (§4.2, no copy) | **+ copy attention** | Δ |
|---|---|---|---|
| sentence exact match | 20.0% | **23.2%** | +3.2pp |
| token accuracy | 54.2% | **61.8%** | +7.6pp |
| root accuracy | 57.8% | **66.9%** | +9.1pp |
| tag-chain accuracy | 50.1% | **59.2%** | +9.1pp |
| unseen-root token accuracy | 38.7% | **45.8%** | +7.1pp |
| unseen-root root accuracy | 36.3% | **47.0%** | +10.7pp |
| unseen-root tag accuracy | 33.6% | **43.8%** | +10.2pp |
| repetition-loop predictions | 0/816 | 0/816 | — |

(All rows: tuned beam, beam=5/α=0.7/ngram-block=3, on top of the copy model.)

Unseen-root root accuracy — the metric every other experiment moved by only
a few points — jumped **10.7 points** in one change. Sentence exact match on
unseen-root sentences is still 0.0%: getting a whole sentence perfectly
right still requires spelling a genuinely novel root exactly, character by
character, which copying makes much closer but doesn't fully solve (§5).

Re-tuning `no_repeat_ngram_size` against this stronger model (grid over
{0,2,3,4,5,6} on a dev subset, confirmed on full dev and test) found only a
marginal, mixed-direction difference — the copy model produces far fewer
repetition loops on its own, so this knob matters much less than it did
pre-copy. `ngram_block=5` edges out the original 3 slightly (test root
accuracy 66.9%→67.1%, tag accuracy 59.2%→59.4%, exact match 23.2%→23.4%,
token accuracy essentially flat) and is the new default reflected below, but
unlike the original ngram-blocking discovery (§4.1, which fixed an actual
failure mode), this is fine-tuning around a problem that's already mostly
solved, not a new finding.

### 4.5 Lexicon augmentation: target tokenizer only

`vocabulary/yakut_roots/*.lex` — an existing project resource, unused until
now by this pipeline — is a curated Yakut root lexicon (4,320 entries)
entirely separate from the training *sentences*. Checked against the 129
distinct unseen roots in the test set: **48.8% already appear in this
lexicon.** The other half split cleanly into proper names (`иннокенти`,
`максимов`) and Russian loanwords (`бригада`, `автомат`, `жюри`) — open-class
categories no static lexicon will ever fully cover.

First test: add all 4,727 lexicon root lines to `spm_tgt`'s training corpus
(as single, unweighted extra lines — real training-sentence roots keep their
natural frequency-based influence; the lexicon only adds *coverage* of shapes
otherwise unseen), producing `spm_tgt_lex`. No new annotated parses needed —
purely reusing an existing resource.

| | previous best (§4.4) | + target-lexicon `spm_tgt_lex` | Δ |
|---|---|---|---|
| sentence exact match | 23.4% | **26.0%** | +2.6pp |
| token accuracy | 61.3% | **64.1%** | +2.7pp |
| root accuracy | 67.1% | **67.6%** | +0.5pp |
| tag-chain accuracy | 59.4% | **62.1%** | +2.6pp |
| unseen-root root accuracy | 47.8% | 47.7% | ~flat |

A real overall win, concentrated almost entirely in **seen**-root sentences
(exact match 27.0%→29.9%, root accuracy 71.8%→72.5%) — the metric the
experiment specifically targeted, unseen-root root accuracy, barely moved.
Best guess: giving the tokenizer more root shapes improves segmentation
quality generally, which the *decoder* benefits from wherever it also has
supervised training examples — but adding a root to the tokenizer's corpus
only guarantees the pieces exist to spell it; it gives the decoder no
example of actually producing that root in context, since training targets
are still only the 15,645 sentence-derived parses.

### 4.6 Lexicon augmentation: both tokenizers (adopted)

Prompted by a direct question worth taking seriously: *if character coverage
already guarantees every root is composable, why doesn't composition close
the unseen-root gap on its own?* Checked empirically on the 136 unseen-root
word tokens in the test set (crude source-piece / target-vocab overlap
check): **only 96 had fully copy-aligned source pieces; 26 had none at
all.** `spm_src` had been trained only on the 15,645 sentences since the
very first version and never revisited — meaning the copy mechanism (§4.4)
could only ever copy what the *source* tokenizer happened to segment into a
piece the target vocabulary also recognized. A well-covered target
vocabulary is necessary but not sufficient if the source segmentation never
produces a matching piece to copy in the first place.

Fix: add the same 4,727 lexicon lines to `spm_src`'s corpus too
(`spm_src_lex`), so source-side segmentation is more likely to land on
root-shaped pieces with a target-vocab counterpart. Source/target piece
overlap (§2's 37% stat) rose to 42.2%.

| | + target-lexicon only (§4.5) | **+ source-lexicon too** | Δ |
|---|---|---|---|
| sentence exact match | 26.0% | **28.2%** | +2.2pp |
| token accuracy | 64.1% | **67.9%** | +3.9pp |
| root accuracy | 67.6% | **72.6%** | +5.0pp |
| tag-chain accuracy | 62.1% | **66.2%** | +4.1pp |
| unseen-root root accuracy | 47.7% | **53.7%** | **+6.0pp** |
| unseen-root token accuracy | 46.1% | **51.8%** | +5.7pp |
| unseen-root tag accuracy | 45.9% | **51.9%** | +6.0pp |
| repetition-loop predictions | 0/816 | 2/816 | minor regression |

Unseen-root root accuracy crosses 50% for the first time, and — unlike
§4.5 — this specifically moved the number it targeted, by the largest
margin since copy attention itself (§4.4). Confirms the two-sided
dependency directly: the target tokenizer needs good root pieces to
generate/copy *into*, and the source tokenizer needs to actually produce a
matching piece to copy *from* — fixing only one side leaves the other as
the binding constraint. The 2/816 new repetition loops are a minor,
disclosed side effect, not worth chasing given the scale of the gain
elsewhere.

One honest caveat: this isn't uniform. The running `хайа арҕаһа` example
(§5) is *not* fully fixed by this change — it still produces `арҕах`
instead of `арҕас`, and the first word's tag regresses slightly (`+pron`
instead of `+n`). Aggregate improvement across 108 unseen-root sentences
doesn't mean every individual case gets better.

### 4.7 Current best configuration

**Separate source/target vocabularies (4,000 each, both augmented with the
external root lexicon) + copy/pointer mechanism + tuned beam search
(beam=5, length_alpha=0.7, no_repeat_ngram_size=5)** —
`checkpoints_bothlex/best.pt`.

| | overall | seen-root (708 sentences) | unseen-root (108 sentences) |
|---|---|---|---|
| sentence exact match | 28.2% | 32.5% | 0.0% |
| token accuracy (1−WER) | 67.9% | 71.8% | 51.8% |
| root accuracy | 72.6% | 77.2% | 53.7% |
| tag-chain accuracy | 66.2% | 69.6% | 51.9% |

The seen/unseen gap has narrowed at every stage of this project (root
accuracy gap: 63.0 vs. 36.3 → 71.7 vs. 47.0 → 77.2 vs. 53.7) without ever
closing — see §5 for what's left of it.

## 5. Attention visualization

`scripts/plot_attention.py` greedy-decodes one sentence and plots the
source-piece × predicted-piece attention matrix (`attention_plots/`).
Consistent qualitative pattern across every example inspected:

- **Correct predictions → clean, monotonic, near-diagonal attention.**
  (`attention_plots/exact_match.png`)
- **Wrong predictions still often show attention correctly localized to the
  relevant source region** — the failure is in symbolic generation from that
  context, not misalignment. Clearest case: `хайа арҕаһа` (`arɣas`+`poss.3sg`,
  with a с→һ sound change at the root-suffix boundary the source tokenizer
  can't see through cleanly) — attention steps sensibly left to right across
  the source pieces, but the **pre-copy** decoder never emits a second root
  at all, collapsing into one garbled tag chain.
  (`attention_plots/unseen_root_fail.png`)
- **Same sentence, post-copy-attention (§4.4): structurally fixed, one
  character off.** `хайа+n арҕах+n+poss.3sg` — two correctly segmented
  tokens, both POS tags right, `POSS.3SG` right, root one letter away from
  gold `арҕас`. Attention on the second root now cleanly locks onto source
  piece `▁ар` before generating the rest — but what it generates is a
  *different, whole, known* target-vocab piece (`арҕах`, presumably some
  other real root memorized during training) rather than assembling the
  exact right spelling character-by-character. This is the clearest
  illustration of what copy attention did and didn't fix: it repairs
  structural collapse (dropped tokens, wrong POS, garbled tag chains) far
  more reliably than it achieves exact character-level reconstruction of a
  root the model has truly never produced before.
  (`attention_plots/unseen_root_fail_copyattn.png`)
- **Hedging attention (split across two source positions, or jumping
  backward to re-attend a already-visited region) is a visible tell for an
  imminent decoding error** — seen right before a real sentence's
  prediction went off the rails, and in a token-omission case where a whole
  source word (`туһунан`) was skipped with no corresponding attended output
  row at all. (`attention_plots/pending_example.png`)

## 6. Key lessons

1. **A theoretically-motivated concern doesn't always survive contact with
   the data at this scale** — twice. Splitting the tokenizer vocabulary was
   expected (by me) to hurt OOV generalization by removing a shared-ID copy
   signal; it helped, substantially, everywhere including OOV. Shrinking the
   target vocabulary was expected (by the user, on sound BPE-style
   reasoning) to help OOV generalization by forcing compositionality; it
   hurt, monotonically, everywhere. Both were worth testing empirically
   rather than resolving by argument.
2. **Teacher-forced training metrics (loss, next-token accuracy) are not
   comparable across different target tokenizations** — a finer vocabulary
   produces longer sequences and a different loss scale, so all real
   comparisons in this work were done on detokenized text via
   `evaluate.py`'s alignment-based metrics, never on raw training-loop
   numbers.
3. **Free-generation seq2seq needs alignment-based evaluation**, not
   positional comparison — predicted and gold token counts diverge, so
   `evaluate.py` aligns them by token-level edit distance before scoring
   root/tag accuracy.
4. **Beam search's failure modes need explicit handling**, not just a beam
   width — length normalization alone introduced a new problem (repetition
   loops) that plain greedy decoding didn't have; no-repeat-ngram blocking
   fixed it outright.
5. **The unseen-root gap is real and structural, but not immovable** — every
   tokenizer/beam-search experiment moved it a little; a mechanism actually
   targeted at the right level (copying, §4.4) moved it an order of
   magnitude more. Knowing *which* lever addresses a bottleneck structurally
   vs. incidentally was worth the earlier ablations, even the ones that
   individually only bought a few points.
6. **Classic mechanisms sometimes need re-deriving, not just re-implementing,
   under a changed assumption.** Pointer-generator networks are specified
   assuming a shared vocabulary; matching source and target by surface
   string instead of id preserved the mechanism's benefit without giving up
   the separate-vocabulary win it would otherwise have conflicted with — and
   turned out not to need it, since full character coverage on both sides
   already guarantees a copy path exists down to individual characters.
7. **A mechanism's benefit is bounded by its weakest input, not just its own
   design.** Copy attention (§4.4) only works as well as the source
   tokenizer's segmentation lets it — §4.6 re-derived this the hard way:
   augmenting the *target* vocabulary alone (§4.5) barely moved unseen-root
   accuracy, but augmenting *both* sides moved it more than any single
   change except copy attention itself. Two components of one mechanism
   need to be checked (and fixed) together, not assumed to inherit a fix
   made to just one of them.
8. **Aggregate improvement doesn't mean uniform improvement.** The
   `хайа арҕаһа` example used throughout §5 is *still* not fully fixed by
   the best model in this project, even though it improved the aggregate
   unseen-root numbers substantially — worth remembering before reading a
   single before/after example as proof a fix "worked."

## 7. Open items / possible next steps

- **Exact character-level reconstruction of a novel root** — even after both
  lexicon-augmentation rounds, this remains the shape of what's left: the
  `арҕах`-for-`арҕас` near-miss (§4.6) persists in the current best model.
  Structural collapse is fixed far more reliably than precise spelling of a
  root the model has never produced before.
- **Reintroduce label smoothing** for the copy-attention loss (dropped for
  implementation simplicity, §4.4 — a disclosed regression in rigor, not a
  deliberate finding).
- **The one-off training slowdown recurred a third time** in the
  lexicon-augmented run too (again self-resolving) — now seen across three
  different architectures on three different training runs, which points
  firmly away from a code-level cause and toward the OS/environment. Still
  not root-caused; worth a look if long background runs become routine.
- **Larger target vocab (>4000)** — §4.3's trend is monotonic within the
  range tested; unclear if it continues past the point where most of the
  4,872 train roots already get a dedicated whole piece, or whether it
  still holds now that copy attention and lexicon augmentation change the
  model's reliance on generation vs. copying.
- **The remaining ~half of unseen roots not in the external lexicon**
  (§4.5) — mostly proper names and Russian loanwords — are a structurally
  different problem (open-class vocabulary) that no amount of lexicon
  augmentation will solve; would need transliteration/loanword-adaptation
  rules or named-entity handling specifically.
- **FST baseline comparison** — the existing `yakutmorph` package has a
  rule-based FST analyzer + disambiguator; a head-to-head comparison would
  contextualize these numbers against the project's other approach.

## 8. Reproducing this work

```
seq2seq_parser/
  scripts/
    prepare_dataset.py    # yakutmorph_dataset/*/processed → data/{train,dev,test}.jsonl
    train_tokenizer.py     # trains spm_src / spm_tgt (--tgt-vocab-size, --tgt-prefix, --extra-root-file for ablations)
    dataset.py, model.py   # data loading; BiGRU+attention+copy-mechanism seq2seq model
    train.py               # --ckpt-dir, --src-tokenizer/--tgt-tokenizer for parallel experiments
    evaluate.py             # --decode {greedy,beam}, alignment-based metrics, seen/unseen breakdown
    plot_attention.py       # attention heatmap for one sentence
  data/                     # prepared splits, tokenizers, tag_vocab.json
              # data/external_lexicon_roots.txt: vocabulary/yakut_roots/*.lex, extracted+normalized (§4.5-4.6)
  checkpoints/              # v1 shared-vocab run (pre-copy-mechanism architecture)
  checkpoints_sepvocab/     # v2 separate-vocab run (pre-copy-mechanism architecture)
  checkpoints_tgtv1000/, checkpoints_tgtv2000/  # target vocab-size ablation (pre-copy-mechanism)
  checkpoints_copyattn/     # + copy/pointer mechanism (§4.4)
  checkpoints_lexaug/       # + target-lexicon augmentation only (§4.5)
  checkpoints_bothlex/      # + source-lexicon augmentation too (current best, §4.6-4.7)
  attention_plots/
```

Note: `model.py`'s `Decoder`/`Seq2Seq` API changed with the copy mechanism
(§4.4) — every method now takes an additional `src_tgt_map` tensor, and
`Seq2Seq.forward`/`decoder.step` return a probability distribution
(generate+copy already mixed) rather than raw logits, so a checkpoint from
`checkpoints/`, `checkpoints_sepvocab/`, or the vocab-size ablation
directories will not `load_state_dict` into the current code — those
directories are a historical record (weights + eval jsons + logs already
captured above), not runnable end states going forward.
