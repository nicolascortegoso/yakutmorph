%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Document index: 3. Derivational affixes
%  Description:    This section defines derivational affixes.
%  Last review:    19/10/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This section depends on the stem definitions, so the file is included.
#include "2_stem_definition.fst"




%%% NOTES: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Derivational affixes are grouped by type in blocks of code.
% Inside each block there are 3 columns:
% - the first column determines the type of stems the affix can be attached to;
% - the second column contains the analysis an surface forms of the derivational affix
% - the third column specifies the type of stem that is formed after the affix.

% For tabulation reasons and to avoid disrupting the column layout, when a affix attaches to several stems types, these
% stems are grouped in variables at the beginning of each bock. These special variables start with the prefix 'g-'.




% Pronoun affixes -----------------------------------------------------------------------------------------------------


$pron$ = <>:<dem>                                                      {\^det}:{н<C>к}                 <>:<dt1>      | \
         <>:<dem>                                                      {\^dt2}:{чч<O>}                 <>:<dt2>      | \
         <>:[<prs> <int-p>]                                            {\^poss}:{иэн}                  <>:<ps>



% Negation affixes -----------------------------------------------------------------------------------------------------


$neg$ =  <>:[#verbs-c# #voices#]                                       {\^neg}:{<C>м<O>}               <>:<neg>      | \
         <>:[#verbs-v# <verb-v>]                                       {\^neg}:{м<O>}                  <>:<neg>



% Possesive affix ------------------------------------------------------------------------------------------------------


#g-poss# = <part1> <part2> <part3-c> <part4> <card-v> <card-c>

$poss$ = <>:[#noms# #g-poss# #parts# <prs> <plur> <dt2> <int-c>]       {\^poss}:{<D2><LO>х}            <>:<poss>



% Participle affixes ---------------------------------------------------------------------------------------------------


#g-part-d-c# = <verb-c> <verb-j>

$partz$ = <>:[#verbs-c# #voices# <verb-c> <verb-j> <aux-c>]            {\^part1}:{<O>р}                <>:<part1>    | \
          <>:[#verbs-v# <verb-v> <acce> <iter>]                        {\^part1}:{<LC>р}               <>:<part1>    | \
          <>:[#verbs# <verb-v> #voices# #d-verbs#]                     {\^neg\^part1}:{<B><O>т}        <>:<part1>    | \
          <>:[#verbs# #d-verbs# #voices#]                              {\^part2}:{<B><C>т}             <>:<part2>    | \
          <>:[#verbs# <neg> #voices# #d-verbs#]                        {\^part3}:{<DI>х}               <>:<part3-c>  | \
          <>:[#verbs# <neg> #voices#]                                  {\^part3}:{<DI>}                <>:<part3-v>  | \
          <>:[#verbs# #g-part-d-c# <neg> #voices# <verb-v> <aux-c>]    {\^part4}:{<D1><O>х}            <>:<part4>    | \
          <>:[#verbs-c# <neg> #voices#]                                {\^part5}:{<LO>чч<C>}           <>:<part5>    | \
          <>:[#verbs-v# <verb-v>]                                      {\^part5}:{чч<C>}               <>:<part5>    | \
          <>:[#verbs# <neg> #voices# #d-verbs#]                        {\^part6}:<D1>                  <>:<part6>



% Gerund affixes -------------------------------------------------------------------------------------------------------


$gndz$ =  <>:[#verbs-c# #voices# <verb-c> <verb-j> <cstv>]             {\^gnd1}:{<O>н}                 <>:<gnd1>      | \
          <>:[#verbs-v# <verb-v> <iter> <part3-v>]                     {\^gnd1}:н                      <>:<gnd1>      | \
          <>:[#verbs-c# <verb-c> <caus-c><caus-r><pass><refl><recp>]   {\^gnd2}:<O>                    <>:<gnd2>      | \
          <>:[#verbs-v# <verb-v> <iter> <cstv-c> <cstv-r>]             {\^gnd2}:<LC>                   <>:<gnd2>      | \
          <>:[<neg>]                                                   {\^gnd3}:{<C>н<O>}              <>:<gnd3>      | \
          <>:[<neg>]                                                   {\^gnd3a}:{н<O>}                <>:<gnd3>      | \
          <>:[#verbs-c# #voices# <verb-c> <verb-j> <neg>]              {\^gnd4}:{<LO>р<C>}             <>:<gnd4>      | \
          <>:[#verbs-v# <verb-v>]                                      {\^gnd4}:{р<C>}                 <>:<gnd4>      | \
          <>:[#verbs# #voices# <verb-v> <verb-c> <verb-j> <neg>]       {\^gnd5}:{<LO>т}                <>:<gnd5>      | \
          <>:[<part2>]                                                 {\^gnd6}:{ч<O>}                 <>:<gnd6>



% Numeral affixes ------------------------------------------------------------------------------------------------------


$numz$ = <>:[#cards#]                                                  {\^ord}:{<C>с}                  <>:<ord>      | \
         <>:[<card-v>]                                                 {\^appr}:{чч<O>}                <>:<appr>     | \
         <>:[<card-c>]                                                 {\^appr}:{ч<O>}                 <>:<appr>     | \
         <>:[<card-v>]                                                 {\^apprA}:{чч<O>к<O>}           <>:<appr>     | \
         <>:[<card-c>]                                                 {\^apprA}:{ч<O>к<O>}            <>:<appr>     | \
         <>:[#cards# <appr>]                                           {\^dist}:{л<LC>}                <>:<dist>     | \
         <>:[#cards#]                                                  {\^coll}:{<DI>}                 <>:<coll>     | \
         <>:[#cards#]                                                  {\^collA}:{<DI>й<O>х}           <>:<coll>



% Nominalization affixes -----------------------------------------------------------------------------------------------


$nomzn$ = <>:[#noms# <part3-c>]                                        {\^agen}:{<H><C>т}              <>:<noun-c>   | \
          <>:[#noms#]                                                  {\^dim1}:{ч<C>к}                <>:<noun-c>   | \
          <>:[#noms#]                                                  {\^dim2}:{к<O>}                 <>:<noun-v>   | \
          <>:[#noms#]                                                  {\^dim2a}:{к<O>й}               <>:<noun-c>   | \
          <>:[#noms#]                                                  {\^dim3}:{ч<LO>н}               <>:<noun-c>

$nomzv$ = <>:[#verbs-c# #voices# <neg>]                                {\^noun1}:{<LC>}                <>:<noun-v>   | \
          <>:[#verbs-v# <verb-v>]                                      {\^noun2}:{<LO>һ<C>н}           <>:<noun-c>   | \
          <>:[#verbs-v# #verb-j#]                                      {\^noun3}:{б<C>л}               <>:<noun-c>   | \
          <>:[#verbs-c#]                                               {\^noun4}:{<C>к}                <>:<noun-c>   | \
          <>:[#verbs-c#]                                               {\^noun5}:{<O>х}                <>:<noun-c>   | \
          <>:[#verbs-v#]                                               {\^noun5}:х                     <>:<noun-c>   | \
          <>:[#verb-r# #verb-j#]                                       {\^noun6}:{л<O>ҥ}               <>:<noun-c>   | \
          <>:[#verbs-v#]                                               {\^noun6}:ҥ                     <>:<noun-c>   | \
          <>:[#verbs#]                                                 {\^noun7}:{лт<O>}               <>:<noun-v>

$nounz$ = $nomzn$ | $nomzv$



% Adverbialization affixes ---------------------------------------------------------------------------------------------


#g-advn-misc# = #adjs# <adv-v> <adv-c> <plur> <poss>

$advzv$ = <>:[#verbs-c# <cstv-c> <cstv-r> <caus-c> <caus-r>]           {\^adv1}:<C>                    <>:<adv-v>    | \
          <>:[#verbs-v# <adv-v>]                                       {\^adv2}:{чч<C>}                <>:<adv-v>    | \
          <>:[#verbs-c# <adv-c>]                                       {\^adv2}:{ч<C>}                 <>:<adv-v>    | \
          <>:[<part1> <part2> <part3-c>]                               {\^adv3}:{<D1><LC>}             <>:<adv-v>    | \
          <>:[<part2> <part3-c>]                                       {\^adv4}:{ч<O>}                 <>:<adv-v>

$advzn$ = <>:[#noms# #g-advn-misc# <prs> <part1> <part3-c> #parts#]    {\^adv5}:{<D1><C>к}             <>:<adv-c>    | \
          <>:[#nouns# #adjs# <dt2>]                                    {\^adv6}:{<D2><LC>}             <>:<adv-v>    | \
          <>:[#nouns# #adjs# #advs#]                                   {\^adv7}:{<D2><O>р<C>}          <>:<adv-v>    | \
          <>:[<card> <ord> <appr>]                                     {\^adv8}:{<D1><O>}              <>:<adv-v>    | \
          <>:[<ord> <dim>]                                             {\^adv9}:{<C>н}                 <>:<adv-c>    | \
          <>:[<coll>]                                                  {\^adv10}:н                     <>:<adv-c>

$advz$ = $advzv$ | $advzn$



% Adjectivation affixes ------------------------------------------------------------------------------------------------


$adjza$ = <>:[#adjs# <adj-dc> <adj-dv>]                                {\^dim}:{<D1><C>ҥ<C>}           <>:<adj-dv>   | \
          <>:[#adjs# <adj-dc> <adj-dv>]                                {\^dim}:{с<DI>р}                <>:<adj-dc>

$adjzn$ = <>:[#nouns-v# <prs>]                                         {\^adj1}:{мс<O>х}               <>:<adj-dc>   | \
          <>:[#nouns-c# <plur>]                                        {\^adj1}:{<C>мс<O>х}            <>:<adj-dc>   | \
          <>:[#adjs#]                                                  {\^adj1a}:{мс<C>к}              <>:<adj-dac>  | \
          <>:[#nouns# <prs> <dem> <plur> <dt2>]                        {\^adj2}:{<D1><LO>ҕ<C>}         <>:<adj-dv>   | \
          <>:[#advs#]                                                  {\^adj3}:{<K><C>}               <>:<adj-dv>

$adjzv$ = <>:[#verbs-v#]                                               {\^adj4}:{г<O>с}                <>:<adj-dc>   | \
          <>:[#verbs-c#]                                               {\^adj4}:{<C>г<O>с}             <>:<adj-dc>   | \
          <>:[#verbs#]                                                 {\^adj5}:{<O>ҕ<O>с}             <>:<adj-dc>   | \
          <>:[#verbs-v#]                                               {\^adj6}:{г<O>н}                <>:<adj-dc>   | \
          <>:[#verbs-c#]                                               {\^adj6}:{<C>г<O>н}             <>:<adj-dc>   | \
          <>:[#intr-aj# #tran-aj#]                                     {\^adj7}:{ҕ<O>р}                <>:<adj-dc>   | \
          <>:[#intr-yj# #tran-yj#]                                     {\^adj7}:{г<C>р}                <>:<adj-dc>   | \
          <>:[#verbs#]                                                 {\^adj8}:{х<O>й}                <>:<adj-dj>   | \
          <>:[#verb-j#]                                                {\^adj9}:{ҕ<O>й}                <>:<adj-dj>   | \
          <>:[#verbs-v#]                                               {\^adj10}:{мт<O>ҕ<O>й}          <>:<adj-dj>   | \
          <>:[#verbs-c#]                                               {\^adj10}:{<C>мт<O>ҕ<O>й}       <>:<adj-dj>   | \
          <>:[#verbs-c#]                                               {\^adj11}:{<C>мт<DI>}           <>:<adj-dv>   | \
          <>:[#verbs-c#]                                               {\^adj12}:{<LC>к}               <>:<adj-dc>   | \
          <>:[#verbs-v# <verb-v>]                                      {\^adj13}:с                     <>:<adj-dc>   | \
          <>:[#verbs-v# <verb-v>]                                      {\^adj14}:{ннь<O>ҥ}             <>:<adj-dc>   | \
          <>:[#verbs-c#]                                               {\^adj14}:{<C>ннь<O>ҥ}          <>:<adj-dc>   | \
          <>:[#verbs-v#]                                               {\^adj15}:х                     <>:<adj-dc>   | \
          <>:[#verb-j#]                                                {\^adj15}:к                     <>:<adj-dc>   | \
          <>:[#verbs-c-exc-j#]                                         {\^adj15}:{<C>к}                <>:<adj-dc>   | \
          <>:[#verb-j#]                                                {\^adj16}:р                     <>:<adj-dc>

$adjz$ = $adjza$ | $adjzn$ | $adjzv$



% Verbalization affixes ------------------------------------------------------------------------------------------------


$verbz$ = <>:[#noms# #cards# <ord> <int-c> <int-v> <dt2> <ono-7>]      {\^verb1}:{<D2><LO>}            <>:<verb-v>   | \
          <>:[#noms-v#]                                                {\^verb2}:й                     <>:<verb-j>   | \
          <>:[#noms-c#]                                                {\^verb2}:{<C>й}                <>:<verb-j>   | \
          <>:[#noms-c#]                                                {\^verb3}:{<LO>}                <>:<verb-v>   | \
          <>:[#noms-v#]                                                {\^verb4}:р                     <>:<verb-c>   | \
          <>:[#noms-c#]                                                {\^verb4}:{<C>р}                <>:<verb-c>   | \
          <>:[#noms#]                                                  {\^verb5}:{<D1><C>й}            <>:<verb-j>   | \
          <>:[#noms-v#]                                                {\^verb6}:{мс<C>й}              <>:<verb-j>   | \
          <>:[#noms-c# <poss>]                                         {\^verb6}:{<C>мс<C>й}           <>:<verb-j>   | \
          <>:[#noms-v#]                                                {\^verb7}:{рҕ<LO>}              <>:<verb-v>   | \
          <>:[#noms-c#]                                                {\^verb7}:{<C>рҕ<LO>}           <>:<verb-v>

$onoz$ =  <>:[<ono-1>]                                                 {\^verb8}:{<K><C>н<LO>}         <>:<verb-v>   | \
          <>:[<ono-2>]                                                 {\^verb9}:{дь<C>г<C>н<LO>}      <>:<verb-v>   | \
          <>:[<ono-2a>]                                                {\^verb9}:{ч<C>г<C>н<LO>}       <>:<verb-v>   | \
          <>:[<ono-3>]                                                 {\^verb10}:{к<C>р<LO>}          <>:<verb-v>   | \
          <>:[<ono-v>]                                                 {\^verb11}:{г<C>р<LO>}          <>:<verb-v>   | \
          <>:[<ono-c>]                                                 {\^verb12}:{<C>г<C>р<LO>}       <>:<verb-v>   | \ %% CHECK
          <>:[<ono-4>]                                                 {\^verb13}:{ҕ<LO>}              <>:<verb-v>   | \
          <>:[<ono-5>]                                                 {\^verb14}:{<C>рҕ<LO>}          <>:<verb-v>



% Causative affixes ----------------------------------------------------------------------------------------------------


#g-cstv-nl# = <intr-3l> <intr-2l> <intr-1l> <intr-3n> <intr-2n> <intr-1n>
#g-cstv-j# = <intr-3j> <intr-2j> <intr-2yj>

$cstv$ = <>:[#intr-v# #intr-r# #g-cstv-j# <verb-v>]                    {\^cstv}:<D1>                   <>:<cstv-c>   | \
         <>:[<intr-1j> <intr-1dij>]                                    {\^cstv}:{<C>т}                 <>:<cstv-c>   | \
         <>:[#g-cstv-nl# <intr-1c>]                                    {\^cstv}:{<D1><O>р}             <>:<cstv-r>   | \
         <>:[<intr-1cov> <intr-1lov>]                                  {\^cstv}:{<O>р}                 <>:<cstv-r>   | \
         <>:[<intr-1cdi> <intr-1rdi>]                                  {\^cstv}:{<DI>р}                <>:<cstv-r>



% Verbal expressive ----------------------------------------------------------------------------------------------------


$expr$ = <>:[#verbs-c# #voices#]                                       {\^expr}:{<LO>хт<LO>}           <>:<verb-v>   | \
         <>:[#verbs-v#]                                                {\^expr}:{хт<LO>}               <>:<verb-v>



% Voice affixes --------------------------------------------------------------------------------------------------------

#g-caus# = <tran-1di> <tran-1di2>
#g-refl-1# = #tran-v# <tran-3j> <tran-2j> <tran-1dij> <tran-1lcj> <tran-1di> <tran-1di2>
#g-refl-2# = #tran-c# #tran-r# #tran-l# <tran-1j> <tran-1dij> <tran-1aj> <intr-1cov>
#g-pass-cstv# = <cstv-c> <cstv-r> <caus-r>
#g-pass-j# = <tran-1j> <tran-1dij> <tran-1aj> <tran-1loj>
#g-pass-1# = #tran-c# #tran-r# #tran-l# #g-pass-cstv# #g-pass-j# <intr-r> <intr-1l> <intr-1n>
#g-recp-1# = #verb-v# #verb3-j# #verb2-j# #verb-1aj# <tran-1di> <tran-1di2> <tran-2yj>
#g-recp-2# = #verb-c# #verb2-j# #verb1-j# #verb-1aj# #verb-r# #verb-l# #intr-n# <tran-2yj> <intr-1cov>

$caus$ = <>:[#g-caus# <verb-v> #tran-v# <verb-c> <iter> <cstv-r>]      {\^caus}:<D1>                   <>:<caus-c>   | \
         <>:[#tran-c# <tran-1r> <tran-3r> #tran-l# <tran-1j> <refl>]   {\^caus}:{<D1><O>р}             <>:<caus-r>   | \
         <>:[<cstv-c> <cstv-r> <tran-2j> <tran-1loj> <tran-2r>]        {\^caus}:{т<O>р}                <>:<caus-r>

$refl$ = <>:[#g-refl-1# <verb-v> <iter> <acce>]                        {\^refl}:н                      <>:<refl>     | \
         <>:[#g-refl-2# <recp> <cstv-c> <cstv-r>]                      {\^refl}:{<C>н}                 <>:<refl>

$pass$ = <>:[#tran-v# <tran-1di> <tran-1di2> <verb-v> <iter> <acce>]   {\^pass}:н                      <>:<pass>     | \
         <>:[#g-pass-1# <refl> <recp> <intr-1cov>]                     {\^pass}:{<C>л<C>н}             <>:<pass>     | \
         <>:[<tran-j> <tran-2j> <tran-2aj> <tran-1dij>]                {\^pass}:{л<C>н}                <>:<pass>

$recp$ = <>:[#g-recp-1# <verb-v> <verb-j> <iter>]                      {\^recp}:с                      <>:<recp>     | \
         <>:[#g-recp-2#]                                               {\^recp}:{<C>с}                 <>:<recp>     | \
         <>:[#g-recp-1# #g-recp-2#]                                    {\^recp2}:{с<C>с}               <>:<recp>

$voice$ = $caus$ | $refl$ | $pass$ | $recp$



% Aspect affixes -------------------------------------------------------------------------------------------------------


#g-iter-1# = #intransitives-v# #transitives-v# #verb-r# #verb-l#

$aspc$ = <>:[#g-iter-1# <cstv-r>]                                      {\^iter}:{т<O>л<LO>}            <>:<iter>     | \
         <>:[#intransitives-c# #transitives-c#]                        {\^iter}:{<C>т<O>л<LO>}         <>:<iter>     | \
         <>:[#tran-r# #tran-l# <caus-r> <cstv-r>]                      {\^iter}:{т<LO>}                <>:<iter>     | \
         <>:[<tran-2v>]                                                {\^iter}:{тт<LO>}               <>:<iter>     | \
         <>:[<tran-1c> <tran-1l> <tran-1r> <tran-2c>]                  {\^iter}:{<O>тт<LO>}            <>:<iter>     | \
         <>:[#intransitives# #transitives#]                            {\^rep}: {<DI>л<LO>}            <>:<iter>     | \
         <>:[#intransitives# #transitives#]                            {\^rep}: {<DI>кк<O>л<LO>}       <>:<iter>     | \
         <>:[#intransitives# #transitives#]                            {\^rep}: {<DI>хт<LO>}           <>:<iter>     | \
         <>:[#intransitives# #transitives#]                            {\^rep}: {<O>л<LO>}             <>:<iter>     | \
         <>:[#verb-v#]                                                 {\^rep}: {к<O>л<LO>}            <>:<iter>     | \
         <>:[#verb-c# #verb-r# #verb-l#]                               {\^rep}: {<O>к<O>л<LO>}         <>:<iter>     | \
         <>:[#syl-1#]                                                  {\^rep}: {<B><O>л<LO>}          <>:<iter>     | \
         <>:[#intransitives-v# #transitives-v#]                        {\^rep}: {нь<O>хт<LO>}          <>:<iter>     | \
         <>:[#intransitives-c# #transitives-c#]                        {\^rep}: {<C>нь<O>хт<LO>}       <>:<iter>     | \
         <>:[#intransitives# #transitives# <verb-v>]                   {\^acce}:{<B><O>хт<LO>}         <>:<acce>



% Verbal mood affixes --------------------------------------------------------------------------------------------------


$mood$ = <>:[#intransitives# #transitives# <neg>]                      {\^cond}:{<D1><O>р}             <>:<cond>     | \
         <>:[#intransitives# #transitives# #voices# <neg>]             {\^cert}:{<LC>һ<C>}             <>:<cert>     | \
         <>:[#intransitives-c# #transitives-c# #voices# <neg>]         {\^will}:{<LO>р<O>й}            <>:<will>     | \
         <>:[#intransitives-v# #transitives-v# <verb-v>]               {\^will}:{р<O>й}                <>:<will>     | \
         <>:[<part3-v> <neg>]                                          {\^imp}:{х<O>й}                 <>:<imp>
