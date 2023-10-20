%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Document index: 4. Inflectional affixes
%  Description:    This section defines inflectional affixes.
%  Last review:    19/10/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This section depends on the stems definitions, that was already included on the derivational affixes
#include "3_derivational_affixes.fst"




%%% NOTES: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inflectional afixes are grouped by type in blocks of code.
% Inside each block there are 3 columns:
% - the first column determines the type of stems the affix can be attached to;
% - the second column contains the analysis an surface forms of the inflectional affix
% - the third column specifies the type of stem that is formed after the affix.

% For tabulation reasons and to avoid disrupting the column layout, when a affix attaches to several stems types, these
% stems are grouped in variables at the beginning of each bock. These special variables start with the prefix 'g-'.




% Plural affix ---------------------------------------------------------------------------------------------------------


#g-plur# = <cond> <cert> <will>

#g-plur-part# = <part1> <part2> <part3-v> <part3-c> <part4> <part5> <part6>
#g-plur-gnd# = <gnd3> <gnd4>
#g-plur-pron# = <prs> <dem> <dt1> <dt2> <int-c> <int-v> <ind>
#g-plural-voice# = <pass>
#g-plur# = #g-plur-part# #g-plur-gnd# #g-plur-pron# #g-plural-voice#


$plur$ = <>:[#noms# #g-plur# <poss> <ord> <ps> #parts# <case-p>]       {\+plur}:{<D2><O>р}             <>:<plur>     | \
         <>:[<int-p>]                                                  {\+plur}:{<D2><LO>х}            <>:<plur>



% Predication affixes --------------------------------------------------------------------------------------------------


#g-pred-part# = <part1> <part2> <part3-c> <part4> <part5> <part6>
#g-pred-nums# = <ord> <appr>
#g-pred-particl# = <part-ac> <part-av>
#g-pred# = #noms# #g-pred-part# #g-pred-nums# <poss> <gnd2> <gnd3> <gnd4> #voices# <cert> <will> <cond> <dt1>

$pred$ = <>:[#g-pred# <dat> #g-pred-particl#]                          {\+a\#sg\&1}:{<B><C>н}          <>:<predsg>   | \
         <>:[#g-pred# <dat> #g-pred-particl#]                          {\+a\#sg\&2}:{<V><C>н}          <>:<predsg>   | \
         <>:[#g-pred# <plur> <psor-3> <dat> #g-pred-particl#]          {\+a\#pl\&1}:{<B><C>т}          <>:<predpl>   | \
         <>:[#g-pred# <plur> <psor-3> <dat> #g-pred-particl#]          {\+a\#pl\&2}:{<V><C>т}          <>:<predpl>



% Personal possessive affixes ------------------------------------------------------------------------------------------


#g-psor-v# = #verbs-v# <verb-v>
#g-psor-c# = #verbs-c# <verb-j> <verb-c> #voices#
#g-psor-pl# = <plur> <aux-c> <dem> <poss>
#g-psor-pt# = <part1> <part2> <part4> <part6>
#g-psor-sg-2# = #g-psor-pt# <part3-c> #noms-c# <poss> <ord> <dem> <plur> <aux-c> <imp> #g-psor-c#
#g-psor-pl-1-2# = #noms# #g-psor-pt# <part3-c> <part5> <ord> <col> #g-psor-pl#

$psor$ = <>:[#g-psor-pt# <part3-c> #noms-c# <ord> #g-psor-pl#]         {\+p\#sg\&1}:{<C>м}             <>:<psor>     | \
         <>:[<part3-v> <part5> #noms-v# <col>]                         {\+p\#sg\&1}:м                  <>:<psor>     | \
         <>:[#g-psor-sg-2#]                                            {\+p\#sg\&2}:{<C>ҥ}             <>:<psor>     | \
         <>:[<part3-v> <part5> #noms-v# <col> <neg> #g-psor-v#]        {\+p\#sg\&2}:ҥ                  <>:<psor>     | \
         <>:[#g-psor-pl-1-2#]                                          {\+p\#pl\&1}:{<B><C>т}          <>:<psor>     | \
         <>:[#g-psor-pl-1-2#]                                          {\+p\#pl\&2}:{<V><C>т}          <>:<psor>     | \
         <>:[#g-psor-pt# <part3-c> #noms-c# <ps> <part-c> #g-psor-pl#] {\+p\&3}:<O>                    <>:<psor-3>   | \
         <>:[#noms-v# <part5> <ord> <col> <col> <part-v> <acce>]       {\+p\&3}:{т<O>}                 <>:<psor-3>



% Simple case affixes --------------------------------------------------------------------------------------------------


#g-scase-part# = <part1> <part2> <part3-c> <part4> <part6>
#g-scase-pron-c-1# = <dt1> <int-c> <int-v> <int-p>
#g-scase-pron-c-2# = <prs> <dem> <dt2> #g-scase-pron-c-1#
#g-scase-v# = <propn-v> <card-v> <part-v> <adj-dv> <part5>
#g-scase-c# = #noms-c# <plur> <poss> <ord>
#g-scase-all# = #noms# #g-scase-part# #g-scase-pron-c-2# <plur> <poss> <adj-dv> <ord>
#g-scase-acc-c# = #g-scase-c# #g-scase-part# #g-scase-pron-c-1# <dem> <int-a> <propn-c> <part1> <card-c> <part-c>
#g-scase-abl-c# = #g-scase-c# #g-scase-part# #g-scase-pron-c-1# <dem> <propn-c> <card-c> <part-c>
#g-scase-ins-c# = #g-scase-c# #g-scase-part# #g-scase-pron-c-1# <int-a> <propn-c> <card-c> <part-c>

$s_case$ = <>:[#g-scase-all# #propns# #cards# #parts#]                 {\+com}:{<D2><LC>н}             <>:<case-c>   | \
           <>:[#g-scase-all# #cards# #propns# #parts#]                 {\+par}:{<D1><O>}               <>:<case-v>   | \
           <>:[#g-scase-acc-c#]                                        {\+acc}:<C>                     <>:<acc>      | \
           <>:[#noms-v# #g-scase-v# <prs> <dt2>]                       {\+acc}:{н<C>}                  <>:<case-v>   | \
           <>:[#g-scase-all# #propns# #cards# #parts#]                 {\+dat}:{<V><O>}                <>:<dat>      | \
           <>:[#g-scase-abl-c#]                                        {\+abl}:{т<O>н}                 <>:<case-c>   | \
           <>:[#noms-v# #g-scase-v# <prs><dt2> <int-v>]                {\+abl}:{тт<O>н}                <>:<case-c>   | \
           <>:[#g-scase-ins-c#]                                        {\+ins}:{<C>н<O>н}              <>:<case-c>   | \
           <>:[#noms-v# #g-scase-v# <prs><dt2> <int-v>]                {\+ins}:{н<O>н}                 <>:<case-c>   | \
           <>:[<dem>]                                                  {\+ins}:{<O>н}                  <>:<case-c>   | \
           <>:[#g-scase-all# #propns# #cards# #parts#]                 {\+cmp}:{<D1><LO>ҕ<O>р}         <>:<case-c>   | \
           <>:[<dem>]                                                  {\+loc}:{<D1><O>}               <>:<case-v>



% Possessive case affixes ----------------------------------------------------------------------------------------------


#g-pers-part# = <part1> <part2> <part3-c> <part4> <part6>
#g-pers-pg# = #g-pers-part# <gnd5>
#p-pers-prons-c# = <int-p>
#g-pers-prons# = #p-pers-prons-c#

$p-pers$ = <>:[#noms# #g-pers-pg# <plur> #g-pers-prons# #parts# <coll>]              {\+p\#sg\&1}:<B>                | \
           <>:[#noms# #g-pers-pg# <plur> #g-pers-prons# #parts# <coll>]              {\+p\#sg\&2}:<V>                | \
           <>:[#noms-v# <col> <appr> <part-v>]                                       {\+p\#sg\&3}:т                  | \
           <>:[#noms-c# #g-pers-pg# <plur> #p-pers-prons-c# <part-c> <coll> <poss>]  {\+p\#sg\&3}:<>                 | \
           <>:[#noms# #g-pers-pg# <plur> #g-pers-prons# #parts# <coll>]              {\+p\#pl\&1}:{<B><C>т}          | \
           <>:[#noms# #g-pers-pg# <plur> #g-pers-prons# #parts# <coll>]              {\+p\#pl\&2}:{<V><C>т}          | \
           <>:[#noms# #g-pers-pg# #g-pers-prons# #parts# <coll>]                     {\+p\#pl\&3}:{<D2><O>р}

$p-case$ = {\+com}:{<C>н<LC>н}                                                                         <>:<case-p>   | \
           {\+acc}:{<C>н}                                                                              <>:<case-p>   | \
           {\+par}:{<C>н<O>}                                                                           <>:<case-p>   | \
           {\+dat}:{<C>г<O>р}                                                                          <>:<case-p>   | \
           {\+abl}:{<C>тт<O>н}                                                                         <>:<case-p>   | \
           {\+ins}:{<C>н<O>н}                                                                          <>:<case-p>   | \
           {\+cmp}:{<C>н<LO>ҕ<O>р}                                                                     <>:<case-p>

$poss-case$ = $p-pers$ $p-case$



% Interrogative marks --------------------------------------------------------------------------------------------------


$int$ = <>:[<poss> <predsg> <predpl> <plur> <part2> <part-c> <psor>]   {\+int}:{<C>й}                  <>:<in>      | \
        <>:[#noms-v# <int-v> <part-v> <psor-3>]                        {\+int}:{н<C>й}                 <>:<in>
