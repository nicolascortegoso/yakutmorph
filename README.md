# A morphological transducer for Yakut language

A morphological transducer is a type of finite-state machine used for morphological analysis and word generation in a language.

The transducer maps the surface form of a word to its lexical representation, segmenting the word into morphemes.

For example, in analysis mode, when given the input 'our writers,' the transducer produces the output:

```
суруйааччыларбыт
```

the transducer produces the output:

```
суруй^verb^part5+plur+p#pl&1
```

Here, the verbal root 'write' (^verb) is followed by a participle affix (^part5), the plural affix (+plur), and the possessive suffix for the first person plural (+p#pl&1).

If this analysis is provided as input in generator mode, the transducer outputs the word form.



## Framework

The transducer for the Yakut language is implemented using the SFST framework by Helmut Schmid. SFST is a toolbox for implementing morphological analyzers and other tools based on finite-state transducer technology. It is freely available under the GNU Public License.

For more information about the framework, please refer to:
* https://www.cis.uni-muenchen.de/~schmid/tools/SFST/
* A Programming Language for Finite State Transducers, Proceedings of the 5th International Workshop on Finite State Methods in Natural Language Processing (FSMNLP 2005), Helsinki, Finland. (pdf) 


## Implementation

The source code of the morphological transducer is organized into seven files:

* 1_alfabet_definition: specifies the input symbols accepted by the transducer; 
* 2_stem_definition: defines primary and derived stem types;
* 3_derivational_affixes: lists the derivational affixes;
* 4_inflectional affixes: lists the inflectional affixes;
* 5_morphotactics: models affix concatenation;
* 6_phonotactics: models morphographemics, including phenomena like vowel harmony, consonant assimilation, and alteration in stems after affixation;
* lexicon: contains a list of lexical roots (without productive affixes).

The compiled transducer can be found in the file 'morph.a' within this repository.

The development process for the transducer is guided by a test-driven approach. The development cycle can be summarized as follows: gather testing data → add new lexical roots → write rules → test → introduce modifications → gather new testing data.

## File description

### 1. Alphabet definition

Yakut uses the Russian Cyrillic alphabet with the addition of five characters: {ҕ, ҥ, ө, һ, ү}

The alphabet definition comprises:
* the set of Yakut back vowels: {a, o, э, ө, ы, и, у, ү} (classified by backeness and roundness);
* the set of Yakut consonants: {п, б, м, т, д, с, н, л, р, й, к, г, х, ҕ, ҥ, һ, ч} (classified by articulation);
* the set of consonants and vowels specific to Russian loan words: {в, ж, з, ф, ц, ш, щ, ъ, я, е, ё};
* a set of special symbols that helps to encode the different realization of an affix in different contexts.

For example, the affix corresponding to the plural can have up to 16 different forms: {лар,лэр, лор, лөр, тар, тэр, тор, төр, дар, дэр, дор, дөр, нар, нэр, нор, нөр}. All these forms can be represented with the help of special placeholders, like &lt;D2>&lt;O>р, where &lt;D2> stands for dental-alveolar, covering {л, т, д, н}, and &lt;O> for short open vowel, representing {а, э, о, ө}.

### 2. Stem definition

The stem definition includes:
* a set of primary stems (the type of lexical roots that appear in the lexicon);
* a set of derived stems (formed after a derivational affix).

The stem format encodes 3 features that constrain the affix concatenation process and the application of phonological rules:
1) the type of stem (mandatory);
2) the number of syllables (optional);
3) the stem ending (optional).

For example, the stem type &lt;verb-2c> describes a two-syllable verb stem ending in a consonant.

### 3. Derivational affixes

Derivational affixes serve to create new words or modify the core meaning or grammatical category of a base word. These affixes are defined by specifying both their analysis and surface representations, which are separated by a colon. For instance, the affix ^verb1:&lt;D1>&lt;LO> is used to form verb stems, where &lt;D1> represents dental-alveolar consonants and &lt;LO> represents long back vowels.

In addition to their analysis and surface representations, derivational affixes also specify:
* the set of stems they can be attached to, such as {&lt;noun-1c> &lt;noun-2c>, &lt;noun-1v>, ...};
* the new type of stem that is formed as a result of the affix, for example, &lt;verb1>.

### 4. Inflectional affixes

Inflectional affixes are used to indicate grammatical information such as case, number, person. These affixes don't alter the core meaning or the part of speech of a word; instead, they express its grammatical characteristics.

The implementation of inflectional affixes is similar to that used for representing derivational affixes. The main difference is that their analysis form is preceded by the symbol +, instead of ^.

Unlike derivational affixes, the analysis representation of inflectional affixes may include information about number and person, introduced by the symbols # and &, respectively. For example: +p#pl&1 represents the possessive suffix for the first person plural.


### 5. Morphotactics

Derivational and inflectional affixes are combined with the lexical roots defined in the lexicon. In Yakut, affixes are always attached to the stem at the back (to the right) since prefixes (affixes located ahead of the stem) do not occur. Therefore, word forms can be formally defined as the concatenation of zero or more suffixes to the right of a lexical root:

```
root suffix*
```

The stem definitions determine which affix concatenations are permissible, filtering out any non-allowed combinations.

### 6. Phonotactics

Phonetic rules apply to both lexical roots and affixes, involving three fundamental processes: insertion, deletion, and symbol replacement. These rules adhere to the following structure and are applied in cascade:

'x' is always realized as 'y' in context 'z.'

The basic rule implementation order is as follows:
1) root changes;
2) stem changes;
3) progressive consonant assimilation;
4) regressive consonant assimilation;
5) vowel harmony.


### Lexicon

The lexicon consists of a list of lexical roots, each followed by the primary stem definition. Lexicon entries should not contain any productive affixes. For example:

```
түүл<noun-1c>
чиҥ<adj-1c>
саамай<adv-2c>
```

The lexicon includes the following lexical roots: adjectives, adverbs, auxiliaries, cardinals, conjunctions, figuratives, interjections, modals, nouns, onomatopoeias, particles, postpositions, pronouns, proper nouns, verbs.

Some forms, like participles and gerunds, are not included as they are considered derived forms.

## Limitations

The morphological transducer is the initial step in generating the syntactical parsing of a Yakut sentence. Before progressing to syntactic parsing, two prerequisites must be addressed:
* implementing a method to handle words that are not present in the vocabulary;
* providing a mechanism to resolve morphological ambiguity.

The transducer is currently in the development phase, and efforts are focused on the following key objectives:
* expanding the lexicon;
* resolving issues;
* clarifying and simplifying the phonetic rule implementations.


## Installation

The transducer requires the installation of SFST. For information on SFST and installation instructions, please visit: https://www.cis.uni-muenchen.de/~schmid/tools/SFST/

A Python library that provides bindings for the Stuttgart Finite State Transducer can be found here: https://pypi.org/project/sfst/


## Execution

To execute the transducer, use the command 'fst-mor,' followed by the name of the compiled transducer file:

```
fst-mor morph.a
```

To recompile the transducer, navigate to the 'src' directory and use the 'fst-compiler-utf8' command inside the 'src' directory, followed by the file name '6_phonotactics.fst' (which includes the rest of the files) and a name for the compiled transducer:

```
fst-compiler-utf8 6_phonotactics.fst morph.a
```