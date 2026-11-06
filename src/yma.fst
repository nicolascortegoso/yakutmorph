%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Affix-based morphological transducer for Yakut (Sakha) language
%  Last review:     14/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% About the project ----------------------------------------------------------------------------------------------------

% This is an implementation of a morphological transducer for Yakut language following the guidelines described
% in Ubryatova et al. Grammar of Modern Yakut Literary Language. Vol. 1: Phonology and Morphology. Moscow,
% Nauka Print, 1982.
% It were also consulted:
% - Sleptsov P.A. Saha tılın bıḫaarıılaah ulahan tıldıta E (XV). Novosibirskay Nauka, 2018.
% - Kharitonov L.N. Neizmenyayemyye slova v yakutskom yazyke: posobiye dlya uchiteley. Yakutsk, 1943.
% - Korkina E.I. Nakloneniya glagola v yakutskom yazyke. Chast' pervaya. Izdatel'stvo Nauka, Moskva, 1970.
% - Korkina E.I. Deeprichastiya v yakutskom yazyke. Chast' pervaya. Izdatel'stvo Nauka, Novosibirsk, 1985.
% - Petrov, Nikolaj Egorovich. Modal'nye slova v yakutskom yazyke. Novosibirsk : Nauka, 1984.

% The transducer is implemented using the Stuttgart Finite State Transducer (SFST) framework, a collection of software
% tools used for the generation, manipulation, and processing of finite-state automata and transducers by Helmut Schmid.
% Further information can be found at the following link: https://www.cis.uni-muenchen.de/~schmid/tools/SFST/

% The analysis form given for affixes is taken from the markup identifiers for grammatical annotation listed on the
% Turkic Morpheme web portal:
% Institute of Applied Semiotics
% 420111, Kazan, 36A Levo-Bulachnaya st.
% modmorph@yandex.ru
% http://modmorph.turklang.net/en/annotation



% Source code ----------------------------------------------------------------------------------------------------------

% The transducer's source code is divided into several files, and includes copious comments to describe the applied
% formalisms. Lines with comments start with the symbol '%' and are ignored by the compiler.
% When present in the comments, the symbol '§' followed by a number indicates a reference to a related section in
% Ubryatova et al.

% Since the transducer is intended for research/educational purposes, code readability and ease of modification are
% preferred over code efficiency and concision.



% Compiling instructions -----------------------------------------------------------------------------------------------

% To compile from source code use the command 'fst-compiler-utf8' from the SFST toolkit with source and output files.
% For example: fst-compiler-utf8 yma.fst yma.a

% The source code is organized in five folders:
% /alphabet     (defines the input symbols recognized by the transducer)
% /stems        (defines the stem types)
% /lexicons     (contains the lexicons to compile the transducer)
% /affixes      (defines derivational and inflectional affixes)
% /rules        (defines phonological rules)



% About this file ------------------------------------------------------------------------------------------------------

% This is the main file to compile a affix-based morphological transducer. For this type of transducer, lexical roots
% are inferred from what is to the left of the identified suffixes.

% The following sections specify the files required to compile the vocabulary-based transducer.
% Apart from the required files, each section includes a short explanation of the code implementation and the linguistic
% features/processes it attempts to model.




% 1. ALPHABET DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section defines the set of characters (alphabet) that will be recognized by the transducer. It also defines a
% set of special symbols used to describe allomorphs, which represent different forms of a morpheme. These symbols are
% extensively used in the definition of affixes in section 4 and are mapped to the corresponding vowels and consonants
% through the application of phonetic rules, as described in section 6.

% The transducer recognizes only lowercase characters. Therefore, input strings must be converted to lowercase in
% analysis mode. If the input string contains a symbol that the transducer does not recognize, it will fail to analyze
% or generate a string.


% Required files for alphabet definition -------------------------------------------------------------------------------

#include "alphabet/vowels.fst"
#include "alphabet/consonants.fst"


% Implementation -------------------------------------------------------------------------------------------------------

% The alphabet is defined as the union of vowels and consonants.

#alphabet# = #surface-vowels# #surface-consonants#
#symbols#  = #vowels# #consonants#




% 2. STEM DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section declares the primary and derived stems:
% - Primary stems refer to forms without productive affixes and classify lexical roots in section 3.
% - derived stems result from affixation processes described in section 4.

% Both primary and derived types determine which type of affixes can be attached to a stem in section 5 and trigger the
% application of phonetic rules from section 6.


% Required files for stem definition -----------------------------------------------------------------------------------

#include "stems/primary.fst"
#include "stems/derived.fst"


% Implementation -------------------------------------------------------------------------------------------------------

% Stem types are grouped together. The symbol <end> is a special marker used to signalize the last affix.

#stem-types# = #primary-stems# #derived-stems#
#markers# = #stem-types# <end>




% 3. LEXICON AND PRIMARY STEM ENDING CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section retrieves the stem endings from the lexicon and classifies them accordingly.

$nouns$       = ([#alphabet#]+ {\+N}:[#nouns#])                                        || "lexicons/primary_endings.lex"
$adjectives$  = ([#alphabet#]+ {\+Adj}:[<adj-j> <adj-uj>])                             || "lexicons/primary_endings.lex"


% Implementation -------------------------------------------------------------------------------------------------------

$primary-endings$ = $nouns$ | $adjectives$




% 4. AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This section lists derivational and inflectional affixes:
% - derivations determine or govern the word class of the stem.
% - inflections express a grammatical contrast that is obligatory for its stem's word class in a grammatical context.


% Required files for derivational and inflectional affixes -------------------------------------------------------------

#include "affixes/derivational.fst"
#include "affixes/inflectional.fst"


% Implementation -------------------------------------------------------------------------------------------------------


$affixes$ = $derivational-affixes$ | $inflectional-affixes$




% 5. MORPHOTACTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section models the word formation process (morphotactics).
% A filter is defined and applied to rule out non-allowed affix concatenations.


% Filter definition ----------------------------------------------------------------------------------------------------

$=C1$                  = [#markers#]
$joint$                = $=C1$ $=C1$
$concatenation-filter$ = [#symbols#]+ ($joint$ [#symbols#]+)* [#stem-types#]


% Affix concatenation and filter application ---------------------------------------------------------------------------

$wordforms$ = [#alphabet#]* $primary-endings$ ($affixes$)* || $concatenation-filter$
$morph$     = $wordforms$ <>:<end>




% 6. PHONOTACTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section describes the application of phonological rules to both stems and affixes.
% Most of the rules are extracted directly from Ubryatova et al, but other where observed empirically.
% All rules have the following form: 'x' is always implemented as 'y' in context 'z'

% Rules are first formulated in a narrow context, and then generalized to a broader one when possible.
% Rule description is in a stage of active development, revision and testing.


% Alphabet definition --------------------------------------------------------------------------------------------------

% This is required for replace operators to work properly.

ALPHABET = [#symbols#] [#markers#]


% Required files for rules application ---------------------------------------------------------------------------------

#include "rules/consonant_clusters.fst"
#include "rules/affix_transformations.fst"
#include "rules/special_insertions.fst"
#include "rules/progressive_assimilation.fst"
#include "rules/regressive_assimilation.fst"
#include "rules/special_vowel_harmony.fst"
#include "rules/regular_vowel_harmony.fst"
#include "rules/post_transformations.fst"


% Rules's application order --------------------------------------------------------------------------------------------

% Application order matters for two reasons:
% 1) some rules require transformations performed by other rules;
% 2) the application of some rules is prevented by the application of previous one.
% Globally, base transformations occur first, followed by consonant assimilation processes and vowel harmony.

$derived-stems$          = $affix-transformations$         || $special-insertions$
$base-transformations$   = $consonant-clusters$            || $derived-stems$

$consonant-assimilation$ = $progressive-assimilation$      || $regressive-assimilation$
$vowel-harmony$          = $special-vowel-harmony$         || $regular-vowel-harmony$
$context$                = $consonant-assimilation$        || $vowel-harmony$

$phonological-rules$     = $base-transformations$          || $context$                      || $post-transformations$


% Implementation -------------------------------------------------------------------------------------------------------

$phonotactics$ = $morph$ || $phonological-rules$




% 7. MARKER DELETION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deletes stem types and other markers from surface representations.


% Alphabet definition --------------------------------------------------------------------------------------------------

ALPHABET = [#symbols#] [#markers#]:<>
$delete-markers$ = .*


% Implementation -------------------------------------------------------------------------------------------------------

$phonotactics$ || $delete-markers$
