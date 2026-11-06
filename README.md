# yakutmorph

This Python library provides tools for performing morphological annotations on texts in the Yakut (Sakha) language. It includes:

- A tokenizer to divide a string into tokens.
- A morphological transducer to map surface and analysis forms.
- A neural disambiguation module to resolve ambiguity in morphological analysis within the context of a given sequence.

## Installation
 
The library yakutmorph requires Python 3.10 or newer and can be installed using the package manager pip (Python's package installer):

```
pip install yakutmorph
```

To work on the library itself, clone the repository and use [uv](https://docs.astral.sh/uv/):

```
uv run --group dev pytest      # run the tests
uv build                       # build the wheel and source distribution into dist/
```

The disambiguation model runs on [onnxruntime](https://onnxruntime.ai/) rather than `torch` — the trained model is exported to ONNX once and shipped with the package, so installing `yakutmorph` pulls in `onnxruntime` and `numpy` (together, well under 100MB) instead of the full `torch` framework (hundreds of MB) needed to train it in the first place. The exported model gives the same predictions as the PyTorch model it was trained as (see [Retraining the disambiguation model](#retraining-the-disambiguation-model)).

## Basic Usage

For convenience, all three modules (tokenization, morphological analysis, and disambiguation) are implemented within the `YakutMorph` class, which provides a user-friendly interface.
This class follows a non-destructive approach, encapsulating the input string and subsequent processing steps as objects within a main `Parse` object:

```
>>> from yakutmorph import YakutMorph
>>> morphology = YakutMorph()
>>> parse = morphology.parse('мин атым Кэскил.')
>>> parse
Parse(мин атым Кэскил.)
```

### Parse


The property `text` retrieves the input string: 

```
>>> parse.text
'мин атым Кэскил.'
```

The property `tokens` returns a list of `Token` objects: 

```
>>> parse.tokens
[Token(мин), Token(атым), Token(Кэскил), Token(.)]
```


### Tokens

Tokens within a `Parse` object can be accessed by their index. For example:

```
>>> token = parse.tokens[0]
>>> token
Token(мин)
```

The property `pos` returns an integer representing the position of the token in the sequence (starting at 1):

```
>>> token.pos
1
```

The property `surface` retrieves the surface form of the token (as it appears originally in the input string):


```
>>> token.surface
'мин'
```

The property `type` returns the token classification provided by the tokenizer:


```
>>> token.type
'lowercase'
```

If the token corresponds to a Yakut word form, it also contains an `Analyses` object.


### Analyses (Possible Interpretations)

The `Analyses` object contains the transducer that performed the morphological analysis and wraps its outputs as a list of `Analysis` objects. A word form can be morphologically ambiguous and, therefore, have more than one interpretation.


```
>>> analyses = token.analyses
>>> analyses
Analyses(Fst(voc)=2)
```

In the example above, the object representation `Analyses(Fst(voc)=2)` shows that the surface form was processed by the morphological transducer `voc` and that it produced 2 analyses.
The transducer that performed the morphological analyses is found under the property `fst`:


```
>>> analyses.fst
Fst(voc)
```

The transducer output can be obtained with the property `output`. This returns a list of `Analysis` objects with possible interpretations:


```
>>> fst_output = analyses.output
>>> fst_output
[Analysis([Morph(мин+N)]), Analysis([Morph(мин+Pron)])]
```

### Analysis

Each `Analyses` object can be accessed using its respective index:

```
>>> output = fst_output[0]
>>> output
Analysis([Morph(мин+N)])
```

The property `morphemes` returns a list of `Morph` objects: the lexical root — combined with its own category tag, e.g. `+N`, since a root's category is inseparable from it rather than a first affix among others — followed by any further affixation:


```
>>> output.morphemes
[Morph(мин+N)]
```


The property `root` returns just the Morph object for the lexical root:


```
>>> output.root
Morph(мин+N)
```

`мин+N` has no affixation beyond its own category, so `infl_groups` is empty here:


```
>>> output.infl_groups
[]
```

To see a non-empty inflectional group, consider `parse.tokens[1]` (`атым`) instead: its one analysis adds a possessive suffix on top of the root's category:

```
>>> output = parse.tokens[1].analyses.output[0]
>>> output
Analysis([Morph(ат+N), Morph(+POSS.1SG)])
>>> output.root
Morph(ат+N)
>>> output.infl_groups
[InflGroup(1)]
```

### Inflectional Groups


Inflectional groups can be accessed by index:


```
>>> ig = output.infl_groups[0]
>>> ig
InflGroup(1)
```


The `InflGroup` object wraps a series of suffixes represented as `Morph` objects.

The property `pos` returns an integer representing the position of the inflectional group in the analysis:


```
>>> ig.pos
1
```

The property `affixes` is used to retrieve the list of `Morph` objects grouped within:


```
>>> ig.affixes
[Morph(+POSS.1SG)]
```

### Morphemes

The `Morph` objects are accessed by index:


```
>>> morph = ig.affixes[0]
>>> morph
Morph(+POSS.1SG)
```

A `Morph` object contains either a lexical root (`root`) — which, since it also carries its own category tag, is where that category-level information lives — a derivational affix (`db`, one that changes the word's category, e.g. `+ADJZ#16` deriving an adjective from a verb, starting a new inflectional group of its own) or an inflectional affix (`fl`), like `+POSS.1SG` here, which stays within its group.

The property `morpheme` gets the tag representation of the morpheme:


```
>>> morph.morpheme
'+POSS.1SG'
```


The property `type` returns the morpheme type:


```
>>> morph.type
'fl'
```

The property `reference` returns a dictionary with mappings for the morpheme:


```
>>> morph.reference
{'ref': '-(ы)м first person singular possessive.', 'ud': {'Number[psor]': 'Sing', 'Person[psor]': 1}, 'aper': 'px1sg'}
```

The root itself carries a `reference` too, populated from its own category tag:

```
>>> output.root.reference['ref']
'Non-derivative or primary nominal stem that cannot be decomposed into individual morphemes. It represents an independent word denoting an object or a subject. From the base of the noun, all grammatical forms of the noun (form of number, case, etc.) are formed (by attaching affixes to it) [Ubryatova at al., §149-150].'
```


## Processing Unknown Lexical Roots

The default morphological transducer analyzes and generates surface forms from an internal vocabulary containing lexical roots. However, it is impossible to list all roots that may appear in Yakut texts, especially given the expected presence of numerous loanwords from the Russian language.

A common practice to handle this issue is to provide auxiliary morphological transducers that increase coverage at the expense of outputting some spurious analyses.

To expand the capability of processing surface forms with minimal ambiguity, the `YakutMorph` class by default implements a three-stage morphological pipeline:

1. **Vocabulary-based transducer (labeled 'voc')**: Analyzes word forms using the lexical roots listed in the vocabulary.
2. **Syllable-based transducer (labeled 'syl')**: Operates on a set of Yakut syllables and accepts any valid concatenation of syllables in a Yakut root. It cannot analyze word forms that deviate from Yakut phonotactics.
3. **Affix-based transducer (labeled 'aff')**: Accepts any string consisting of a sequence of at least two characters of the Yakut alphabet. It can process loanwords.

In this pipeline, the next transducer only takes part if the previous one fails to process a given surface form. In the example below, the surface forms have been automatically processed by different morphological transducers:

```
>>> from yakutmorph import YakutMorph
>>> morphology = YakutMorph()
>>> parse = morphology.parse('Мама Егора учуутал.')
>>> [token.analyses for token in parse.tokens if token.has_morph]
[Analyses(Fst(voc)=1), Analyses(Fst(aff)=1), Analyses(Fst(voc)=1)]
```

For more details, please refer to the README.md file inside the `src` folder, which contains the source code for the morphological transducers.


## Morphological Ambiguity

Ambiguous analyses occur when the morphological transducer outputs more than one possible interpretation for a surface form. For example:

```
>>> token.analyses.output
[Analysis([Morph(мин+N)]), Analysis([Morph(мин+Pron)])]
```

The disambiguation module employs a dual-encoder neural network with attention to select the most likely analysis for each surface form within the context of the token sequence: one encoder represents the sentence, a second represents each candidate analysis, and an attention mechanism lets each candidate query the sentence's contextual representation before scoring. This process happens automatically when calling the `parse` method.

The model is trained on the manually disambiguated sentences of [yakutmorph_dataset](https://github.com/nicolascortegoso/yakutmorph_dataset). On its held-out test set it chooses the correct analysis for 92.2% of the ambiguous words (1,691 of 1,835), against 85.3% for always choosing the analysis most often correct in the training data. Words with only one analysis are, of course, always correct.

The most likely analysis is an `Analysis` object, which can be retrieved through the token's `morph` property:

```
>>> token.morph
Analysis([Morph(мин+Pron)])
```

Under the hood, the disambiguation model sets the `idx_mla` (index most-likely analysis) property inside the `Analyses` object. This property is an integer that points to the index of the output list containing the selected `Analysis` object:

```
>>> token.analyses.idx_mla
1
```

This index can be set manually if needed. It is used internally to retrieve the `Analysis` object when accessing the `morph` property of the `Token` object:


```
>>> token.analyses.idx_mla = 0
>>> token.morph
Analysis([Morph(мин+N)])
```


## Proper names

The transducer analyses names as common nouns (`+N`). After the analysis, a capitalized word with a `+N` reading is tagged as a proper noun (`+PN`) when:

1. its root is listed in `yakutmorph/data/proper_names.txt`, wherever it appears; or
2. it does not start a sentence, so its capital letter is not explained by its position.

A word starts a sentence when it is the first word, when it follows `.` `...` `?` `!` `—` or `:`, or when it follows a quotation mark that itself starts a sentence (direct speech). For example, `Суох` in `— Суох.` stays `суох+N`, while `Победа` in `Биһиги «Победа» теплоходунан бардыбыт.` becomes `победа+PN`.

Names that are also common words (listed in `yakutmorph/data/name_homonyms.txt`, e.g. `харах` 'eye') are tagged `+PN` only by rule 2, so that `Хараҕыттан уу таҕыста.` keeps `харах+N`.


## Independent Modules

The modules integrated into the `YakutMorph` class can be used independently by importing their respective classes. For example:


```
>>> from yakutmorph.tokenizers import YakutTokenizer
>>> tokenizer = YakutTokenizer()
>>> tokenizer.tokenize('Мин аатым Кэскил.')
[('Мин', 'title'), ('аатым', 'lowercase'), ('Кэскил', 'title'), ('.', 'period')]
```

They output Python native types instead of wrapping the results in the objects described above. For example:


```
>>> from yakutmorph.transducers import YakutTransducer
>>> transducer = YakutTransducer()
>>> transducer.analyse('аатым')
['аат+N+POSS.1SG']
>>> transducer.generate('аат+N+POSS.1SG')
['аатым']
```

The disambiguation model is different: unlike the tokenizer and transducer, it needs the full sentence context (to encode) and each ambiguous token's own candidate analyses (to score), so it operates on the `Token` objects `YakutMorph` already built rather than on a bare list of strings. A typical standalone use re-runs disambiguation on tokens obtained from a `Parse`:


```
>>> from yakutmorph import YakutMorph
>>> from yakutmorph.disambiguation import YakutReranker
>>> morphology = YakutMorph()
>>> parse = morphology.parse('мин атым Кэскил.')
>>> model = YakutReranker()
>>> model.disambiguate(parse.tokens)
[1]
```

The returned list has one index per *ambiguous* token in the sentence, in order — here just `мин` (`атым` and `Кэскил` each only had one candidate analysis to begin with, so they are not included).

## Analysis Output

The `mappers` module provides classes to convert the `Parse` object to a given format. For example:


```
>>> from yakutmorph.mappers import CoNLLU
>>> parse = morphology.parse('Мин аатым Кэскил.')
>>> print(CoNLLU(parse))
# text = Мин аатым Кэскил.
1	Мин	мин	PRON	pron	Case=Nom|Number=Sing|Person=1|PronType=Prs	_	_	_	Analysis=мин+Pron
2	аатым	аат	NOUN	n	Case=Nom|Number=Sing|Number[psor]=Sing|Person[psor]=1	_	_	_	Analysis=аат+N+POSS.1SG
3	Кэскил	кэскил	PROPN	propn	Case=Nom	_	_	_	Analysis=кэскил+PN
4	.	.	PUNCT	punct	_	_	_	_	_
```

The lemma of every word, proper nouns included, is its root without inflectional affixes (`Кэскилгэ` → `кэскил`).

The last column (MISC) carries the full underlying FST analysis as an `Analysis=` entry — this is treebank-specific annotation in the sense the [CoNLL-U spec](https://universaldependencies.org/format.html) describes for that column ("any additional information that does not fit into any of the other fields, such as language-specific annotation"), not a universal UD field.


# Morphological Reference

The transducers were developed following the grammar: Ubryatova Y.I. (red.) Grammatika sovremennogo yakutskogo literaturnogo yazyka. Tom 1: Fonetika i morfologiya. Moskva: Nauka Print, 1982.

The analysis form for affixes attempts to conform to the markup identifiers for grammatical annotation listed on the Turkic Morpheme web portal: Institute of Applied Semiotics, 420111, Kazan, 36A Levo-Bulachnaya st., http://modmorph.turklang.net/en/annotation .

The default YakutTransducer object includes a YakutReference object with references to the implemented tags:

## Default reference

The default `YakutTransducer` (and those in the morphological pipeline) object includes a `YakutReference` object with references to the implemented tags:


```
>>> from yakutmorph.transducers import YakutTransducer
>>> transducer = YakutTransducer()
>>> tag_set = transducer.reference.get_tags()
>>> len(tag_set)
145
```


The method `get_tag` returns a series of mappings for a tag in the transducer. For example, `ref` retrieves a description for the morpheme from the grammar:


```
>>> mappings = transducer.reference.get_tag('+PL')
>>> mappings['ref']
'-лар (and allomorphs) forms the plural affix from various type of stems. The interrogative pronoun ким takes the special form нээх to form the plural, after which a regular plural affix can be used for emphasis [Ubryatova et al., §329].'
```


These include alternative tags to map to different formats:


```
>>> mappings['ud']
{'Number': 'Plur'}
```

**ATTENTION**: the collaboration of specialists in Yakut language is highly needed to test/improve the current default reference.


### Modifying the default reference

The default reference can be manually edited as a normal dictionary object:

```
>>> mappings.update({'custom': 'plural affix'})
>>> mappings['custom']
'plural affix'
```

The `parse` method from the `YakutMorph` class applies the (edited) reference to the `Morph` object:


### Initializing a custom reference

Each transducer implements its own reference. This means, that if we are using a morphological pipeline with many transducers, we will need to edit each reference. This can be avoided by injecting an edited `YakutReference` object when initializing `YakutMorph`:


```
>>> from yakutmorph import YakutMorph
>>> from yakutmorph.transducers import YakutMorphReference
>>> custom_reference = YakutMorphReference('my_reference.yaml')
>>> morphology = YakutMorph(reference=custom_reference)
```


### Loading a custom reference

The `YakutReferece` object implements a `yaml` file. The default reference is located in folder `yakutmorph/data/morph_reference.yaml` . It is possible to upload a custom `yaml` file, as long as it implements the following key-value structure:

```
general_type:
    affix_1:
        key_1: value_1
        key_2: value_2
    affix_2:
        key_1: value_1
        key_2: value_2
    ...
```


## Using yakutmorph from an LLM (MCP server)

yakutmorph includes a [Model Context Protocol](https://modelcontextprotocol.io) server, so that LLM applications (Claude Desktop, Claude Code, and other MCP clients) can analyse Yakut text with it. Install it with the `mcp` extra, which adds the `yakutmorph-mcp` command:

```
pip install "yakutmorph[mcp]"
```

To add it to Claude Code:

```
claude mcp add yakutmorph -- yakutmorph-mcp
```

For other clients, configure a stdio server that runs the command `yakutmorph-mcp`, for example in Claude Desktop's `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "yakutmorph": { "command": "yakutmorph-mcp" }
  }
}
```

The server offers these tools (all read-only):

| Tool | Input | Output |
|---|---|---|
| `analyze_text` | a sentence, e.g. `Мин кинигэни аахпытым.` | each word's analysis in context, lemma, UD part of speech and features, the transducer that analysed it, and the alternatives for ambiguous words |
| `analyze_word` | one word form, e.g. `дьиэтин` | every analysis of the word, out of context |
| `to_conllu` | a sentence | the CoNLL-U annotation |
| `explain_tags` | tags, e.g. `["POSS.3SG.ACC", "PN"]` | what each tag marks, with its Universal Dependencies features |
| `list_tags` | optionally `roots`, `derivational` or `inflectional` | the tag inventory |
| `generate_word_form` | an analysis, e.g. `дьиэ+N+POSS.1SG.DAT` | the word form(s): `дьиэбэр` |
| `find_examples` | a word form, a root and/or a tag, e.g. root `дьиэ` and tag `POSS.3SG.ACC` | manually annotated sentences from [yakutmorph_dataset](https://github.com/nicolascortegoso/yakutmorph_dataset), with translation, source, page, authors or translator, and the analysis of every word |

The model is loaded once, on the first call.


## Example sentences from the annotated corpus

The package includes a snapshot of [yakutmorph_dataset](https://github.com/nicolascortegoso/yakutmorph_dataset) (about 19,000 manually annotated sentences, Apache-2.0), searchable by word form, root and/or tag:

```
>>> from yakutmorph.corpus import Corpus
>>> corpus = Corpus()
>>> result = corpus.find(root='дьиэ', tag='POSS.3SG.ACC', limit=1)
>>> result['examples'][0]['match']
{'text': 'дьиэтин', 'analysis': 'дьиэ+N+POSS.3SG.ACC'}
```

`limit` sets how many examples to return (3 if not given; fewer if fewer sentences match) and `offset` skips that many, to page through the results. Each example has the sentence, its translation (`translation_ru` and/or `translation_en`), `source`, `page`, `authors` (authors, editors or translator) and the analysis of every word. Examples that the corpus marks as deliberately wrong (e.g. starred forms quoted in a grammar) carry `"ungrammatical": true`.

`corpus.origin` tells which corpus commit the snapshot was built from. To search a local checkout of the corpus instead, set `YAKUTMORPH_CORPUS=/path/to/yakutmorph_dataset`. Before a release, rebuild the snapshot from the corpus's `main`:

```
uv run python scripts/build_corpus_snapshot.py yakutmorph_dataset
```


## Retraining the disambiguation model

The training code is in `disambiguation_model/scripts/`. It expects the corpus ([yakutmorph_dataset](https://github.com/nicolascortegoso/yakutmorph_dataset)) checked out in `yakutmorph_dataset/` and the train/dev/test split produced by `seq2seq_parser/scripts/prepare_dataset.py`. With the `train` dependency group (PyTorch):

```
uv run --group train python disambiguation_model/scripts/prepare_dataset.py    # candidates for every word, via the library itself
uv run --group train python disambiguation_model/scripts/train_tokenizer.py    # SentencePiece tokenizers
uv run --group train python disambiguation_model/scripts/train.py --seed 1     # train; reports dev and test accuracy
uv run --group train python disambiguation_model/scripts/export_onnx.py --install   # export to ONNX into yakutmorph/data/
uv run python disambiguation_model/scripts/evaluate_library.py test            # accuracy of the installed library
```

`prepare_dataset.py` writes `fst_issues.md`, the words whose annotated analysis the transducer does not produce. `evaluate_library.py` fails if the library's candidate analyses no longer match the training data, which means the transducer or the post-processing has changed since the model was trained and it should be retrained.


## License

GNU General Public License v3 (GPLv3) — see the `LICENSE` file.

## Contact

The project is currently under development. If you would like to collaborate in the process, report an issue, or need assistance with using, implementing, or testing the morphology analyzer, please get in touch via the project's repository: https://github.com/nicolascortegoso/yakutmorph

In principle, the project could be modified to work for other from the turkish family.

Special thanks to:

- Helmut Schmid, for developing the SFST toolkit: https://www.cis.uni-muenchen.de/~schmid/tools/SFST/
- Gregor Middell, for the Python bindings https://pypi.org/project/sfst-transduce/
