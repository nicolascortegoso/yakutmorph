# A morphological transducer for Yakut (Sakha) language

A morphological transducer is a type of finite-state machine used for morphological analysis and word generation in a language.

The transducer maps the surface form of a word to its lexical representation, segmenting the word into morphemes.

For example, in analysis mode, when given the input 'our writers'

```
суруйааччыларбыт
```

the transducer produces the output:

```
суруй^V^NMLZ#9+PL+POSS.1PL
```

Here, the verbal root 'write' (^V) is followed by a participle affix (^NMLZ#9), the plural affix (+PL), and the possessive suffix for the first person plural (+POSS.1PL).

If this analysis is provided as input in generator mode, the transducer outputs the word form.



## Framework

The transducer for the Yakut language is implemented using the SFST framework by Helmut Schmid. SFST is a toolbox for implementing morphological analyzers and other tools based on finite-state transducer technology. It is freely available under the GNU Public License.

For more information about the framework, please visit:
* https://www.cis.uni-muenchen.de/~schmid/tools/SFST/

You can also refer to:
* A Programming Language for Finite State Transducers, Proceedings of the 5th International Workshop on Finite State Methods in Natural Language Processing (FSMNLP 2005), Helsinki, Finland. (pdf) 


## Implementation

The source code of the morphological transducer is organized into five main folders:

* alphabet: specifies the input symbols accepted by the transducer; 
* stems: defines primary and derived stem types;
* affixes: defines derivational and inflectional affixes;
* lexicons: list lexical roots;
* rules: models morphographemics, including phenomena like vowel harmony, consonant assimilation, and alteration in stems after affixation;

The compiled transducer can be found in the file 'ymv.a' within this repository.

The development process for the transducer is guided by a test-driven approach. The development cycle can be summarized as follows: gather testing data → add new lexical roots → write rules → test → introduce modifications → gather new testing data.

## General description

### 1. Alphabet definition

Yakut utilizes the Russian Cyrillic alphabet with the inclusion of five additional characters: {ҕ, ҥ, ө, һ, ү}

Alphabet definition encompasses:
* the set of Yakut back vowels: {a, o, э, ө, ы, и, у, ү} (classified by backeness and roundness);
* the set of Yakut consonants: {п, б, м, т, д, с, н, л, р, й, к, г, х, ҕ, ҥ, һ, ч} (classified by articulation);
* the set of consonants and vowels specific to Russian loan words: {в, ж, з, ф, ц, ш, щ, ъ, я, е, ё};
* a set of metasymbols that stands for a set of graphemes and aids in encoding the various realization of an affix in different contexts.

For instance, the affix corresponding to the plural can have up to 16 different forms: {лар,лэр, лор, лөр, тар, тэр, тор, төр, дар, дэр, дор, дөр, нар, нэр, нор, нөр}. All these forms can be represented with the assistance of special placeholders, such as &lt;D2>&lt;O>р, where &lt;D2> denotes dental-alveolar, covering {л, т, д, н}, and &lt;O> signifies short open vowel, representing {а, э, о, ө}.

### 2. Stem definition

The stem definition comprises:
* a set of primary stems (representing the type of lexical found in the lexicon);
* a set of derived stems (formed through affixation).

The stem format encodes two features that constrain the affix concatenation process and the application of phonological rules:
1) the type of stem (mandatory);
2) other specification (optional), such as the number of syllables and the stem ending.

For instance, the stem type &lt;noun-2c> describes a two-syllable noun ending in a consonant.


### 3. Lexicon

The lexicon consists of a list of lexical roots, each followed by the corresponding primary stem definition. For example:

```
түүл<noun-1c>
чиҥ<adj-1c>
саамай<adv-2c>
```

The lexicon includes various types of lexical roots such as adjectives, adverbs, auxiliaries, cardinals, conjunctions, interjections, modals, nouns, imitatives, particles, postpositions, pronouns, proper nouns, and verbs. Lexicon entries should not contain any productive affixes. 

Some forms, like participles and gerunds, are not included because they are formed by affixation.



### 4. Affixes

Derivational affixes serve to create new words or modify the core meaning or grammatical category of a base word. In both analysis and generation modes, they are introduced by the symbol ^.

Inflectional affixes convey grammatical information such as case, number, and person. These affixes do not alter the core meaning or the part of speech of a word; instead, they express its grammatical characteristics. In both analysis and generation modes, they are introduced by the symbol +.

Affixes are defined by specifying both their analysis and surface representations, which are separated by a colon. For instance, the affix ^VRBLZ1:&lt;D1>&lt;LO> is used to form verb stems, where &lt;D1> represents dental-alveolar consonants and &lt;LO> represents long open vowels.
In addition to their analysis and surface representations, affixes also specify:
* the set of stems they can be attached to (primary or derived), such as {&lt;noun-1c> &lt;noun-2c>, &lt;noun-1v>, ...};
* the new type of stem (derived) that is formed as a result of the affix, for example, &lt;verb1>.


### 5. Morphotactics

Derivational and inflectional affixes are combined with the lexical roots defined in the lexicon. In Yakut, affixes are always attached to the stem at the back (to the right), as prefixes (affixes located ahead of the stem) do not occur. Therefore, word forms can be formally defined as the concatenation of zero or more suffixes to the right of a lexical root:

```
root suffix*
```

The stem definitions determine which affix concatenations are permissible, filtering out any non-allowed combinations.

### 6. Phonotactics

The transducer implements the cascade-rule formalism to map between surface and lexical forms. 
Phonetic rules apply to both lexical roots and affixes, involving three fundamental processes: insertion, deletion, and symbol replacement. These rules adhere to the following structure and are applied in cascade:

'x' is always realized as 'y' in context 'z.'

The basic rule implementation order is as follows:
1) root and stem transformations;
2) affix transformations;
3) special insertions;
4) consonant assimilation (progressive and regressive);
5) vowel harmony;
6) post-transformations.


## Limitations

The morphological transducer represents the initial step in generating the syntactical parsing of a Yakut sentence. Before advancing to syntactic parsing, two prerequisites must be addressed:
* implementing a method to handle out-of-vocabulary words (OOV);
* providing a mechanism to resolve morphological ambiguity.

Currently, the transducer is in the development phase, with efforts focused on the following key objectives:
* expanding the lexicon;
* identifying and resolving issues;
* clarifying and simplifying the phonetic rule implementations.


## Installation

To use the transducer, you'll need to install SFST. For information on SFST and installation instructions, please visit: https://www.cis.uni-muenchen.de/~schmid/tools/SFST/

Additionally, you can explore these Python libraries offering bindings for the Stuttgart Finite State Transducer:

https://pypi.org/project/sfst-transduce/

https://pypi.org/project/sfst/

## Execution

To execute the transducer, use the command 'fst-mor', followed by the name of the compiled transducer file:

```
fst-mor ymv.a
```

To recompile a transducer, navigate to the 'src' directory and use the 'fst-compiler-utf8' command followed by the file name with the source code (which includes the rest of the files) and a name for the new transducer:

```
fst-compiler-utf8 ymv.fst ymv.a
```

## Versions

For previous releases, please, check the other branches in this project.



## Contact

If you would like to collaborate on development, report an issue, or need help using/implementing/testing the morphology converter, please contact us.