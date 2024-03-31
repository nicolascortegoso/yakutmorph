%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Derived stems definitions
%  Last review:     27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This file defines stems types formed by affixation.

% The code in this file is divided into 2 sections:
% 1. Derived stems definition;
% 2. Derived stems aggregation.

% Most of the stems definitions presented here follow a two-element structure consisting of:
% 1. the base class (mandatory element) that may refer to a part of speech (e.g., adjective, adverb), stem type (e.g.,
% nominal, verb), or affix type (e.g., possessive, plural);
% 2. other specifications (optional), such as number of syllables, stem endings, and other characteristics.

% The accepted basis type format is of type <class-specification>. If no specifications are implemented, the base type
% is simply <class>.
% The base class is the main stem classifier, while the specifications convey extra information about the stem.

% Some of the symbols included in the specifications are:
% -v: vowel ending;
% -j: glide ending;
% -c: consonant ending.




%%% 1. DERIVED STEM DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Voice ----------------------------------------------------------------------------------------------------------------

% - <cstv (makes transitive an intransitive verb) -r> (for ending in р), -с> (ending in other consonant);
% - <caus (causative voice) -r> (ending in р) -с> (ending in other consonant);
% - <recp (reciprocal voice) -s> (special form for the reciprocal);
% - <refl> (reflexive);
% - <pass> (passive).

#cstvs# = <cstv-r> <cstv-c> <caus-r> <caus-c>
#recps# = <recp> <recp-s>
#voices# = #cstvs# <refl> <pass> #recps#


% Aspect ---------------------------------------------------------------------------------------------------------------

% - <iter> iterative / repeated action [§520-522];
% - <acce> an action performed at an accelerated pace [§523-525];
% - <expr> a diminutive affix for verbs that conveys different nuances depending on the context [§396];

#aspect# = <acce> <expr> <iter>


% Participles ----------------------------------------------------------------------------------------------------------

#participles-c# = <part1> <part1-n> <part2> <part3-c> <part4>
#participles-v# = <part3-v> <part5>
#participles#   = #participles-c# #participles-v#


% Gerunds --------------------------------------------------------------------------------------------------------------

#gerunds# = <gnd1> <gnd2> <gnd3> <gnd4> <gnd5> <gnd6>


% General --------------------------------------------------------------------------------------------------------------

% Previcative, imperative and mood affixes.

#predicatives# = <predsg> <predpl>
#general# = #predicatives# <psor> <poss>
#imperative# = <imp-v> <imp-c> <imp-r> <imp-n> <imp>
#moods# = <cond> <cert> <pot> #imperative#
#dem-prons# = <ka-v> <ka-c>


% Derived verbs --------------------------------------------------------------------------------------------------------

#d-verbs-jrc# = <verb-j> <verb-r> <verb-c>
#d-verbs# = <verb-v> #d-verbs-jrc#


% Derived nouns --------------------------------------------------------------------------------------------------------

#d-nouns# = <noun-dc> <noun-dv>


% Derived adjectives ---------------------------------------------------------------------------------------------------

#d-adj-cj# = <adj-dc> <adj-dac> <adj-dj>
#d-adj# = #d-adj-cj# <adj-dv>


% Derived adverbs ------------------------------------------------------------------------------------------------------

#d-adv# = <adv-dc> <adv-dv>


% Derived numerals -----------------------------------------------------------------------------------------------------

#colls# = <coll-c> <coll-v>
#d-nums# = <ord> <appr> <dist> #colls#


% Inflectional affixes -------------------------------------------------------------------------------------------------

% <plur-s> the interrogative pronoun ким takes a special type of plural affix.

#cases# = <case-v> <case-c> <acc> <dat> <case-p> <acc-p> <loc>
#inflections# = #cases# <plur> <psor> <psor-3> <ps-sg> <ps-pl> <ina> <in> <plur-s>




%%% 2. AGGREGATED DERIVED STEMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#derived-stems-1# = #d-verbs# #d-nouns# #d-adv# #d-adj# #voices# #aspect# #moods#
#derived-stems-2# = <neg> #participles# #general# #d-nums# #gerunds# #dem-prons# <past>
#derived-stems# = #derived-stems-1# #derived-stems-2# #inflections# <adv-col>