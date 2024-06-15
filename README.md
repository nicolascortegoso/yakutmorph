# yakutmorph

This Python library provides tools for performing morphological annotations on texts in the Yakut (Sakha) language. It includes:

- A tokenizer to divide a string into tokens.
- A morphological transducer to map surface and analysis forms.
- A module to resolve ambiguity in morphological analysis within the context of a given sequence.

## Installation
 
The library yakutmorph can be installed using the package manager pip (Python's package installer):

```
pip install yakutmorph
```

## Basic Usage

For convenience, all three modules (tokenization, morphological analysis, and disambiguation) are implemented within the `YakutMorph` class, which provides a user-friendly interface.
This class follows a non-destructive approach, encapsulating the input string and subsequent processing steps as objects within a main `Parse` object:

```
>>> from yakutmorph.main import YakutMorph
>>> morphology = YakutMorph()
>>> parse = morphology.parse('мин атым Кэскил')
>>> parse
Parse(мин атым Кэскил.)
```

### Parse


The property `text` retrieves the input string: 

```
>>> parse.text
мин атым Кэскил.
```

The property `tokens` returns a list of `Token` objects: 

```
>>> parse.text
мин атым Кэскил.
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
[Analysis([Morph(мин), Morph(^N)]), Analysis([Morph(мин), Morph(^Pron)])]
```

### Analysis

Each `Analyses` object can be accessed using its respective index:

```
>>> output = fst_output[0]
>>> output
Analysis([Morph(мин), Morph(^N)])
```

The property `morphemes` returns a list of `Morph` objects representing the lexical root and the concatenated affixes:


```
>>> output.morphemes
[Morph(мин), Morph(^N)]
```


The property `root` returns just the Morph object that contains the lexical root:


```
>>> output.root
Morph(мин)
```

The property `infl_groups` retrieves a list of `InflGroup` objects:


```
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
[Morph(^N)]
```

### Morphemes

The `Morph` objects are accessed by index:


```
>>> morph = ig.affixes[0]
>>> morph
Morph(^N)
```

A `Morph` object contains either a lexical root (root), a derivational (db), or an inflectional affix (fl).

The property `morpheme` gets the tag representation of the morpheme:


```
>>> morph.morpheme
'^N'
```


The property `type` returns the morpheme type:


```
>>> morph.type
'db'
```

The property `reference` returns a dictionary with mappings for the morpheme:


```
>>> morph.reference
{'UPOS': 'NOUN', 'XPOS': 'n', 'ref': 'noun', 'aper': 'n'}
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
>>> from yakutmorph.main import YakutMorph
>>> morph = YakutMorph()
>>> parse = morphology.parse('Мама Егора учуутал.')
>>> [token.analyses for token in parse.tokens if token.has_morph]
[Analyses(Fst(syl)=1), Analyses(Fst(aff)=3), Analyses(Fst(voc)=1)]
```

For more details, please refer to the README.md file inside the `src` folder, which contains the source code for the morphological transducers.


## Morphological Ambiguity

Ambiguous analyses occur when the morphological transducer outputs more than one possible interpretation for a surface form. For example:

```
>>> token.analyses.output
[Morph(morphemes=['мин', '^N']), Morph(morphemes=['мин', '^Pron'])]
```

The disambiguation module employs a neural model to select the most likely analysis for each surface form within the context of the token sequence. This process happens automatically when calling the `parse` method.

The most likely analysis is an `Analysis` object, which can be retrieved through the token's `morph` property:

```
>>> token.morph
Analysis([Morph(мин), Morph(^Pron)])
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
Analysis([Morph)(мин), Morph)(^N)])
```


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
['аат^N+POSS.1SG']
>>> transducer.generate('аат^N+POSS.1SG')
['аатым']
```

These modules also expect Python native types as input, so it's essential to ensure the correct types are provided. For example, the disambiguation model expects a list of analyses and returns another list containing the indices corresponding to the selected analyses (excluding the sequence's start and end symbols):


```
>>> from yakutmorph.disambiguation import YakutModel
>>> model = YakutModel()
>>> tags = [['<BOS>'], ['^N', '^Pron'], ['^N+POSS.1SG'], ['^N', '^PN'], ['<EOS>']]
>>> model.disambiguate(tags)
[1, 0, 1]
```

## Analysis Output

The `mappers` module provides classes to convert the `Parse` object to a given format. For example:


```
>>> from yakutmorph.mappers import CoNLLU
>>> print(CoNLLU(parse))
text = Мин аатым Кэскил.
1       Мин     мин     PRON    pron    Case=Nom|Number=Sing|Person=1|PronType=Prs      _       _       мин^Pron
2       аатым   аат     NOUN    n       Case=Nom|Number=Sing|Number[psor]=Sing|Person[psor]=1   _       _       аат^N+POSS.1SG
3       Кэскил  кэскил  PROPN   propn   Case=Nom        _       _       кэскил^PN
4       .       .       PUNCT   punct   _       _       _       _
```


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
142
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
>>> from yakutmorph.main import YakutMorph
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


## Contact

The project is currently under development. If you would like to collaborate in the process, report an issue, or need assistance with using, implementing, or testing the morphology analyzer, please feel free to contact us.

In principle, the project could be modified to work for other from the turkish family.

Special thanks to:

- Helmut Schmid, for developing the SFST toolkit: https://www.cis.uni-muenchen.de/~schmid/tools/SFST/
- Gregor Middell, for the Python bindings https://pypi.org/project/sfst-transduce/