%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Document index:  2. Stem definition
%  Description:     This section defines both primary and derived types of stems and also reads the lexicon.
%  Last review:     19/10/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This section depends on the alphabet definition, so the file is included.
#include "1_alphabet_definition.fst"




%%% NOTES: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Nothing to remark.




% Primary adverbial stems ----------------------------------------------------------------------------------------------

#advs-v# = <adv-v> <adv-2v> <adv-1v>
#advs-c# = <adv-c> <adv-2c> <adv-1c>
#advs# = #advs-v# #advs-c#


% Primary adjectival stems ---------------------------------------------------------------------------------------------

#adjs-v# = <adj-v> <adj-2v> <adj-1v>
#adjs-c# = <adj-c> <adj-2c> <adj-1c>
#adjs# = #adjs-v# #adjs-c#


% Primary numeral stems ------------------------------------------------------------------------------------------------


#cards# = <card-c> <card-v>



% Primary prononimal stems ---------------------------------------------------------------------------------------------


#prons# = <prs> <dem> <dem-n> <dt1> <dt2> <int-c> <int-v> <int-p> <int-a> <ind> <ps> <col>



% Primary nominal stems ------------------------------------------------------------------------------------------------

#nouns-v# = <noun-v> <noun-2v> <noun-1v>
#nouns-c# = <noun-c> <noun-2c> <noun-1c>
#nouns# = #nouns-v# #nouns-c#



% Primary proper noun stems --------------------------------------------------------------------------------------------

#propns# = <propn-v> <propn-c>



% Primary particle stems -----------------------------------------------------------------------------------------------

#parts# = <part-c> <part-v> <part-ac> <part-av>



% Primary particle stems -----------------------------------------------------------------------------------------------

#modals# = <mod>



% Primary postposition stems -------------------------------------------------------------------------------------------

#posts# = <post-c> <post-v>



% Primary auxiliary stems ----------------------------------------------------------------------------------------------

#auxs# = <aux-c> <aux-v>



% Primary onomatopeias stems -------------------------------------------------------------------------------------------

#onoms# = <ono-v> <ono-c> <ono-1> <ono-2a> <ono-3> <ono-4> <ono-5> <ono-6> <ono-7> <ono>



% Primary verbal stems (intransitive and transitive) -------------------------------------------------------------------


#intr-c# = <intr-3c> <intr-2c> <intr-1c> <intr-1cov> <intr-1cdi>
#intr-j# = <intr-3j> <intr-2j> <intr-1j>
#intr-aj# = <intr-3aj> <intr-2aj> <intr-1aj>
#intr-yj# = <intr-3yj> <intr-2yj> <intr-1yj>
#intr-dij# = <intr-3dij> <intr-2dij> <intr-1dij>
#intr-r# = <intr-3r> <intr-2r> <intr-1r> <intr-1rdi>
#intr-l# = <intr-3l> <intr-2l> <intr-1l> <intr-1lov>
#intr-n# = <intr-3n> <intr-2n> <intr-1n>
#intr-v# = <intr-3v> <intr-2v> <intr-1v>
#intransitives-c# = #intr-c# #intr-j# #intr-aj# #intr-yj# #intr-dij# #intr-r# #intr-l# #intr-n#
#intransitives-v# = #intr-v#
#intransitives# = #intransitives-c# #intransitives-v#

#tran-c# = <tran-3c> <tran-2c> <tran-1c>
#tran-j# = <tran-3j> <tran-2j> <tran-1j>
#tran-aj# = <tran-3aj> <tran-2aj> <tran-1aj>
#tran-yj# = <tran-3yj> <tran-2yj> <tran-1yj>
#tran-jet# = <tran-1lcj> <tran-1loj> <tran-1dij>
#tran-r# = <tran-3r> <tran-2r> <tran-1r>
#tran-l# = <tran-3l> <tran-2l> <tran-1l>
#tran-v# = <tran-3v> <tran-2v> <tran-1v>
#transitives-c# = #tran-c# #tran-j# #tran-aj# #tran-yj# #tran-jet# #tran-r# #tran-l#
#transitives-v# = #tran-v# <tran-1di> <tran-1di2>
#transitives# = #transitives-c# #transitives-v#

#verbs-c# = #intransitives-c# #transitives-c#
#verbs-v# = #intransitives-v# #transitives-v#
#verbs# = #verbs-c# #verbs-v#



% Aggregated primary stems ---------------------------------------------------------------------------------------------


#noms-v# = #adjs-v# #nouns-v# #advs-v#
#noms-c# = #adjs-c# #nouns-c# #advs-c#
#noms# = #noms-v# #noms-c#

#verbs-c-exc-j# = #intr-c# #intr-r# #intr-l# #intr-n# #tran-c# #tran-r# #tran-l#
#verbals# = <verb-v> <verb-c> <verb-j> #intransitives# #transitives#


#primary-roots# = #advs# #adjs# #nouns# #propns# #cards# #prons# #parts# #onoms# <conj> <intj> #posts# #auxs# #modals#



% Reads the lexical roots from the lexicon files and classifies them accordingly to its lexical base stem type ---------


$adverbs$ =       ([#letters#]+ {\^adv}:[#advs#])           || "lexicon.lex"
$adjectives$ =    ([#letters#]+ {\^adj}:[#adjs#])           || "lexicon.lex"
$nouns$ =         ([#letters#]+ {\^noun}:[#nouns#])         || "lexicon.lex"
$propnouns$ =     ([#letters#]+ {\^propn}:[#propns#])       || "lexicon.lex"
$pronouns$ =      ([#letters#]+ {\^pron}:[#prons#])         || "lexicon.lex"
$cardinals$ =     ([#letters#]+ {\^card}:[#cards#])         || "lexicon.lex"
$conjunctions$ =  ([#letters#]+ {\^conj}:<conj>)            || "lexicon.lex"
$particles$ =     ([#letters#]+ {\^part}:[#parts#])         || "lexicon.lex"
$verbs$ =         ([#letters#]+ {\^verb}:[#verbs#])         || "lexicon.lex"
$onomatopoeias$ = ([#letters#]+ {\^onom}:[#onoms#])         || "lexicon.lex"
$interjections$ = ([#letters#]+ {\^intj}:<intj>)            || "lexicon.lex"
$postpositions$ = ([#letters#]+ {\^post}:[#posts#])         || "lexicon.lex"
$auxiliaries$ =   ([#letters#]+ {\^aux}:[#auxs#])           || "lexicon.lex"
$modals$ =        ([#letters#]+ {\^mod}:[#modals#])         || "lexicon.lex"

$lex-roots$ = $adverbs$ | $adjectives$ | $nouns$ | $propnouns$ | $pronouns$ | $cardinals$ | $conjunctions$ | \
              $particles$ | $verbs$ | $onomatopoeias$ | $interjections$ | $postpositions$ | $auxiliaries$ | $modals$



% Derived stems definitions --------------------------------------------------------------------------------------------

#cstvs# = <cstv-c> <cstv-r>
#causs# = <caus-c> <caus-r>
#voices# = #cstvs# #causs# <refl> <pass> <recp>
#aspect# = <iter> <acce>
#negation# = <neg>
#participle# = <part1> <part2> <part3-c> <part3-v> <part4> <part5> <part6>
#gerunds# = <gnd1> <gnd2> <gnd3> <gnd4> <gnd5> <gnd6>
#general# = <predsg> <predpl> <psor> <poss>
#special# = <cond> <cert> <will>

#d-verbs# = <verb-v> <verb-j> <verb-c>
#derived-adv# = <adv-dc> <adv-dv>
#derived-adj# = <adj-dv> <adj-dc> <adj-dac> <adj-dj>
#derived-nums# = <ord> <appr> <dist> <coll>

#derived-stems# = #derived-adv# #derived-adj# #verbals# #voices# #aspect# #negation# #participle# #general# #special# #derived-nums# #gerunds# <imp>



% Inflected stems ------------------------------------------------------------------------------------------------------


#cases# = <case-v> <case-c> <acc> <dat> <case-p>
#inflected-stems# = <plur> <psor> <psor-3> <ps-sg> <ps-pl> #cases# <ina> <in>



% Aggregated stems definition ------------------------------------------------------------------------------------------


#stem-types# = #primary-roots# #derived-stems# #inflected-stems# <end>

#syl-1# = <tran-1c> <tran-1j> <tran-1dij> <tran-1r> <tran-1l> <tran-1v> <tran-1di> <tran-1di2>

#verb-c# = #intr-c# #tran-c#
#verb3-j# = <intr-3j> <tran-3j>
#verb2-j# = <intr-2j> <tran-2j>
#verb1-j# = <intr-1j> <tran-1j>
#verb-1aj# = <intr-1dij> <tran-1dij>
#verb-j# = #verb3-j# #verb2-j# #verb1-j# #verb-1aj#
#verb-r# = #intr-r# #tran-r#
#verb-l# = #intr-l# #tran-l#
#verb-v# = #intr-v# #tran-v#
