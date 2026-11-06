# A morphological transducer for Yakut (Sakha) language

A **morphological transducer** is a type of finite-state machine used for morphological analysis and word form generation in a language.

The transducer maps the **surface form** of a word to its **lexical representation**, segmenting the word into morphemes.

For example, in **analysis mode**, given the input "our writers":


```
суруйааччыларбыт
```


the transducer produces the output:


```
суруй+V+NMLZ#9+PL+POSS.1PL
```

Here, the verbal root суруй ‘write’ (+V) is followed by a nominalizer or participle affix (+NMLZ#9), the plural suffix (+PL), and the first person plural possessive suffix (+POSS.1PL).

If this analysis is provided as input in **generation mode**, the transducer returns the corresponding surface form of the word.



## Framework

The morphological transducer for the Yakut language is implemented using the **SFST** (Stuttgart Finite State Transducer) framework developed by **Helmut Schmid**.

SFST is a toolbox for building morphological analyzers and other natural language processing tools based on finite-state transducer technology.
It is freely available under the GNU General Public License (GPL).



For more information about the framework, visit:
- https://www.cis.uni-muenchen.de/~schmid/tools/SFST/


You may also refer to the following publication:
- A Programming Language for Finite State Transducers, Proceedings of the 5th International Workshop on Finite State Methods in Natural Language Processing (FSMNLP 2005), Helsinki, Finland. (PDF available on the SFST website)


## Implementation

The source code of the morphological transducer is organized into five main folders:


* alphabet: defines the input symbols accepted by the transducer;
* stems: specifies primary and derived stem types;
* affixes: defines derivational and inflectional affixes;
* lexicons: lists lexical roots;
* rules: models morphographemic processes, including vowel harmony, consonant assimilation, and stem alternations triggered by affixation.

The compiled transducer is saved in the file 'ymv.a', which can be found in this repository.

The development process follows a **test-driven approach**. The development cycle is structured as follows:

*gather test data → add new lexical roots → write rules → run tests → introduce modifications → gather new test data*

This iterative method ensures that new lexical and morphological patterns are introduced systematically and evaluated continuously.


## General Description

### 1. Alphabet Definition


Yakut uses the **Russian Cyrillic alphabet**, extended with five additional characters: ҕ, ҥ, ө, һ, ү.


The alphabet definition includes:

- Back vowels: {а, о, э, ө, ы, и, у, ү}, classified by backness and roundness;

- Consonants: {п, б, м, т, д, с, н, л, р, й, к, г, х, ҕ, ҥ, һ, ч}, classified by place and manner of articulation;

- Characters specific to Russian loanwords: {в, ж, з, ф, ц, ш, щ, ъ, я, е, ё};

- Metasymbols: placeholders used to represent sets of graphemes. These symbols simplify the encoding of affix alternations depending on phonological context.

For example, the plural suffix can appear in up to 16 different forms: *{лар, лэр, лор, лөр, тар, тэр, тор, төр, дар, дэр, дор, дөр, нар, нэр, нор, нөр}*. These variants can be captured using metasymbols, such as:
 &lt;D2>&lt;O>р, where &lt;D2> denotes a dental-alveolar consonant, encompassing {л, т, д, н}, and &lt;O> denotes a short open vowel, representing {а, э, о, ө}.

### 2. Stem Definition

The stem definition includes:

- A set of primary stems, representing the base lexical entries listed in the lexicon;
- A set of derived stems, which are formed through affixation processes.

Each stem is annotated with metadata that constrains affix concatenation and the application of phonological rules. This metadata includes:

1) Stem type (mandatory), e.g., noun, verb, adjective;

2) Optional specifications, such as syllable count or final segment (vowel/consonant).

For example, the stem type &lt;noun-2c> indicates a two-syllable noun ending in a consonant. This information plays a crucial role in selecting the appropriate affix form and triggering morphophonological alternations during transduction.



### 3. Lexicon

The **lexicon** consists of a list of lexical roots, each annotated with its corresponding primary stem definition. For example:


```
түүл<noun-1c>
чиҥ<adj-1c>
саамай<adv-2c>
```

The lexicon includes various lexical categories such as adjectives, adverbs, auxiliaries, cardinals, conjunctions, interjections, modals, nouns, imitatives, particles, postpositions, pronouns, and verbs.

Lexicon entries do not contain productive affixes. Forms like participles and gerunds are excluded, as they are derived via affixation.


### 4. Affixes

**Derivational affixes** are used to form new words or change the grammatical category or core meaning of a stem.

**Inflectional affixes** express grammatical features such as case, number, and person, without altering the core meaning or part of speech.

Both derivational and inflectional affixes are introduced by the symbol +.

Affixes are defined in the code by specifying both their **analysis** and **surface forms**, separated by a colon. For example, the affix +VRBLZ1:&lt;D1>&lt;LO> is used to form verb stems, where &lt;D1> represents dental-alveolar consonants, and &lt;LO> represents long open vowels.

In addition to their forms, each affix specifies:


- The set of stem types it can attach to (e.g.,  &lt;noun-1c>,  &lt;noun-2c>,  &lt;noun-1v>, etc.);

- The resulting derived stem type after affixation (e.g., &lt;verb-v>).



### 5. Morphotactics

**Derivational** and **inflectional** affixes are concatenated to the lexical roots defined in the lexicon. In Yakut, all affixes are suffixes; that is, they are always attached to the right of the stem. Prefixes (affixes preceding the root) do not occur.


Thus, word forms can be formally represented as:

```
root suffix*
```

where * represent zero or more affixes.

The **stem definitions** constrain which affix sequences are permitted, effectively filtering out invalid combinations. This ensures that only morphotactically valid word forms are generated or analyzed.



### 6. Phonotactics


The transducer uses a **cascade-rule formalism** to transform lexical forms into surface forms and vice versa.

Phonological rules apply to both roots and affixes and involve three core operations: insertion, deletion, and symbol replacement.

Each rule is applied in sequence, following this structure:

'x' is realized as 'y' in context 'z.'

The rules are applied in a cascading order, typically as follows:

1) Root and stem transformations
2) Affix transformations and special insertions
3) Consonant assimilation (progressive and regressive)
4) Vowel harmony
5) Post-transformations

This cascade ensures correct application of morphophonological processes and alignment with Yakut phonotactic constraints.


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

If you are interested in collaborating on development, reporting an issue, or need assistance with using, implementing, or testing the morphological transducer, feel free to reach out.

We welcome feedback, contributions, and questions.