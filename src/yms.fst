%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Syllable-based morphological transducer for Yakut (Sakha) language
%  Last review:     14/04/2024

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

% The analysis form given for affixes is taken from the markup identifiers for grammatical annotation listed in the
% Turkic Morpheme web portal:
% Institute of Applied Semiotics
% 420111, Kazan, 36A Levo-Bulachnaya st.
% modmorph@yandex.ru
% http://modmorph.turklang.net/en/annotation



% Source code ----------------------------------------------------------------------------------------------------------

% The transducer's source code is divided into several files, and includes copious comments to describe the applied
% formalisms. Lines with comments start with the symbol % and are ignored by the compiler.
% When present in the comments, the sign '§' followed by a number references to a related section in Ubryatova et al.

% Since the transducer is intended for research/educational purposes, code readability and ease of modification are
% preferred over code efficiency and concision.

% The source code can be used to compile 3 types of transducers. These transducers differ in the method they use
% to recognize lexical roots:
% 1) vocabulary-based (lexical roots are directly listed);
% 2) syllable-based (lexical roots are not listed but reconstructed from syllables);
% 3) affix-based (lexical roots are the remainder to the left after all affixes have been recognized).



% Compiling instructions -----------------------------------------------------------------------------------------------

% To compile from source code use the command 'fst-compiler-utf8' from the SFST toolkit with source and output files
% For example: fst-compiler-utf8 yms.fst yms.a

% The source code is organized in five folders:
% /alphabet     (defines the symbols that the transducer recognizes)
% /stems        (defines the stem types)
% /lexicons     (contains the lexicons to compile the different type of transducers)
% /affixes      (defines derivational and inflectional affixes)
% /rules        (defines phonological rules)



% About this file ------------------------------------------------------------------------------------------------------

% This is the main file to compile a syllable-based transducer. In this type of transducer, a lexical root is formed
% by the concatenation of the syllables listed the lexicon.

% The syllables are classified as initial, middle, and final, according to their relative position within the root.
% The combination of syllables is restricted by vowel harmony and combination of consonants.

% The following sections specify the files required to compile the syllable-based transducer.
% Apart of the required files, each section includes a short explanation of the code implementation and the linguistic
% features/processes it attempts to model.



% 1. ALPHABET DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section defines the set of characters (alphabet) that will be recognized by the transducer.

% It also defines a set of special symbols that are used to describe allomorphs. These are used extensively in the
% definition of affixes in section 4 and are mapped to the corresponding vowels and consonants by the
% application of phonetic rules accordingly to the context in section 6.

% The transducer recognises only lower case characters, therefore, in analysis mode, input strings must be converted to
% lowercase.

% If the input string contains a symbol that the transducer does not recognizes, it will fail to analyse or generate a
% string.



% Required files for alphabet definition and syllable concatenation ----------------------------------------------------

#include "alphabet/vowels.fst"
#include "alphabet/consonants.fst"


% Implementation -------------------------------------------------------------------------------------------------------

% The alphabet is defined as the concatenation of vowels and consonants.

#alphabet# = #surface-vowels# #surface-consonants#
#symbols#  = #vowels# #consonants#



% 2. STEMS DEFINITIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section declares the primary, derived and inflected stems. Stem types determine which type of affixes can be
% attached to the stem in section 5. They also trigger the application of phonetic rules from section 6.

% Derived and inflected stems are the result respectively of derivation and inflectional processes defined in section 5.
% Primary stems correspond to lexical roots, that is to the forms with all productive affixes removed.
% Primary stems are used to classify the lexical rules listed in the lexicon.


% Required files for stem definition -----------------------------------------------------------------------------------

#include "stems/primary.fst"
#include "stems/derived.fst"


% Implementation -------------------------------------------------------------------------------------------------------

% Stem types are grouped together. The symbol <end> is a special marker used to signalize the last affix.


#stem-types# = #primary-stems# #derived-stems#
#markers# = #stem-types# <begin> <end>



% 3. SYLLABLES AND STEM TYPE CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reads the syllables from the lexicon and classifies them accordingly.


% Required file for syllable boundaries --------------------------------------------------------------------------------


#include "stems/syllable_boundaries.fst"


% Reads starting and middle syllables ----------------------------------------------------------------------------------


$starting-syllables$  = (<>:<s>            [#alphabet#]+ <>:[#boundaries#])             || "lexicons/prev_syllables.lex"
$middle-syllables$    = (<>:[#boundaries#] [#alphabet#]+ <>:[#boundaries#])             || "lexicons/prev_syllables.lex"


% Reads ending syllables for disyllabic lexical roots ------------------------------------------------------------------




$disyllabic-adjs$    = (<>:[#boundaries#] [#alphabet#]+ {\+Adj}:[#disyllabic-adjs#])    || "lexicons/last_syllables.lex"
$disyllabic-advs$    = (<>:[#boundaries#] [#alphabet#]+ {\+Adv}:[#disyllabic-advs#])    || "lexicons/last_syllables.lex"
$disyllabic-nouns$   = (<>:[#boundaries#] [#alphabet#]+ {\+N}:[#disyllabic-nouns#])     || "lexicons/last_syllables.lex"
$disyllabic-verbs$   = (<>:[#boundaries#] [#alphabet#]+ {\+V}:[#disyllabic-verbs#])     || "lexicons/last_syllables.lex"

$disyllabics-stems$ = $disyllabic-adjs$ | $disyllabic-advs$ | $disyllabic-nouns$ | $disyllabic-verbs$



% Reads ending syllables for polysyllabic lexical roots ----------------------------------------------------------------


$polysyllabic-adjs$   = (<>:[#boundaries#] [#alphabet#]+ {\+Adj}:[#polysyllabic-adjs#]) || "lexicons/last_syllables.lex"
$polysyllabic-advs$   = (<>:[#boundaries#] [#alphabet#]+ {\+Adv}:[#polysyllabic-advs#]) || "lexicons/last_syllables.lex"
$polysyllabic-nouns$  = (<>:[#boundaries#] [#alphabet#]+ {\+N}:[#polysyllabic-nouns#])  || "lexicons/last_syllables.lex"
$polysyllabic-verbs$  = (<>:[#boundaries#] [#alphabet#]+ {\+V}:[#polysyllabic-verbs#])  || "lexicons/last_syllables.lex"

$polysyllabics-stems$ = $polysyllabic-adjs$ | $polysyllabic-advs$ | $polysyllabic-nouns$ | $polysyllabic-verbs$



% 5. AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section retrieves the derivational and inflectional affixes.
% Derivational affixes determine or govern the word class of the stem.



% Required files for inflectional and derivational affixes -------------------------------------------------------------

#include "affixes/derivational.fst"
#include "affixes/inflectional.fst"



% Implementation -------------------------------------------------------------------------------------------------------


$affixes$ = $derivational-affixes$ | $inflectional-affixes$



% 6. MORPHOTACTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section defines and applies a filter to rule out non-allowed affix concatenations.




% Filter definition ----------------------------------------------------------------------------------------------------


$=C1$ = [#markers# #syllable-boundaries#]
$joint$ = $=C1$ $=C1$
$concatenation-filter$ = ($joint$ [#symbols#]+)* [#stem-types#]



% Affix concatenation and filter application ---------------------------------------------------------------------------

%%$wordforms$ = <>:<s> ($prev-syllable$)* $last-syllable$ ($affixes$)* || $concatenation-filter$

$disyllabics$   = $starting-syllables$ $disyllabics-stems$
$polysyllabics$ = $starting-syllables$ ($middle-syllables$)+ $polysyllabics-stems$

$wordforms$     = <>:<s> ($disyllabics$ | $polysyllabics$) ($affixes$)* || $concatenation-filter$
$morph$         = $wordforms$ <>:<end>



% 7. PHONOTACTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Alphabet definition --------------------------------------------------------------------------------------------------
% This is required for replace operators

ALPHABET = [#symbols#] [#markers#] [#syllable-boundaries#]



% Required files for rules application ---------------------------------------------------------------------------------

#include "rules/general_root_transformations.fst"
#include "rules/affix_transformations.fst"
#include "rules/special_insertions.fst"
#include "rules/progressive_assimilation.fst"
#include "rules/regressive_assimilation.fst"
#include "rules/regular_vowel_harmony.fst"
#include "rules/post_transformations.fst"


% Rules's application order --------------------------------------------------------------------------------------------

% Application order matters for two reasons:
% 1) some rules require transformations performed by other rules;
% 2) the application of some rules is prevented by the application of previous one.
% Globally, base transformations occur first, followed by consonant assimilation processes and vowel harmony.


$derived-stems$          = $affix-transformations$         || $special-insertions$
$base-transformations$   = $general-root-transformations$  || $derived-stems$

$consonant-assimilation$ = $progressive-assimilation$      || $regressive-assimilation$
$context$                = $consonant-assimilation$        || $regular-vowel-harmony$

$phonological-rules$     = $base-transformations$          || $context$                      || $post-transformations$


% Implementation -------------------------------------------------------------------------------------------------------

$phonotactics$ = $morph$ || $phonological-rules$




% 8. MARKER DELETION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deletes stem types and other markers from surface representations.


% Alphabet definition --------------------------------------------------------------------------------------------------

ALPHABET = [#symbols#] [#markers#]:<> [#syllable-boundaries#]:<>
$delete-markers$ = .*


% Implementation -------------------------------------------------------------------------------------------------------

$phonotactics$ || $delete-markers$
