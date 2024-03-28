%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Inflectional affixes definitions
%  Last review:    27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% The code in this file is divided into 2 sections:
% 1. Inflectional affixes definition;
% 2. Aggregated inflectional affixes.

% Affixes are grouped into blocks.
% Each block is introduced by comments on the implementation and its reference to the linguistic source.
% The initial comments are followed by the affix formalization, consisting of three columns:
% - the first column specifies the set of stems the affix can be attached to;
% - the second column contains the affix’s analysis and surface forms;
% - the third column declares the type of stem that is formed after the affix.

% The analysis form in the second column is adopted (with minor changes) from the Turkic Morpheme web portal.
% The surface form in the second column is defined using the special symbols to represent the affix allomorphs.
% These special symbols are defined in the alphabet. The realization of the symbols in context is specified by the
% phonetic rules.

% In comments, the abbreviation (&all) stands for 'and allomorphs'.




% 1. INFLECTIONAL AFFIXES DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1.1 Plural affix -----------------------------------------------------------------------------------------------------

% The plural affix can be attached to various type of stems.
% The pronoun ким takes нээх to form the plural, after which a regular plural affix can be used for emphasis [§329].

$plur$ = <>:[#noms# #d-nouns# #d-adj# <poss>                                        \    % primary and derived nominals
             #cards# #d-nums# <ord> <coll-v>                                        \    % numerals
             <prs> <dem> <dt1> <dt2> <int-c> <int-v> <ind> <ka-v> <ka-c> #cos#      \    % pronouns
             <int-p>                                                                \    % interrogative
             <ps> <case-p>                                                          \    % case
             #auxs#                                                                 \    % auxiliaries
             #voices#                                                               \    % voice markers
             <cond> <cert> <pot> <imp-n>                                            \    % mood markers
             #participles#                                                          \    % participles
             <gnd3> <gnd4> <gnd5>                                                   \    % converbs
             #parts#                                                                \    % particles
             <plur-s>                                                               \    % special plural
             ]                                                  {\+PL}:{<D2><O>р}                        <>:<plur>   | \
<>:<int-p>                                                      {\+PL}:{нээх}                            <>:<plur-s>


% 1.2 Predicative affixes ----------------------------------------------------------------------------------------------

% Predicative affixes attach to many type of stems. The list below reference to the sections in Ubryatova et al., where
% this is specified:
% - adverbial participles can take personal affixes [§435].
% - adverbial participles change by person and number [§435].
% - adverbial participles -ымына can take personal affixes [§451].
% - adverbial participles -аары can take personal affixes [§457].

% Notes:
% - To ease readability, stem types common to the first and second person, both singular and plural, are grouped
% together in '#g-pred#'.
% - Specific stems for the singular and plural are respectively aggregated as '#g-pred-sg#' and '#g-pred-pl#.'
% - The third person in Yakut is unmarked (no affix).

#g-pred# = <part1> <part1-n> <part2> <part3-c> <part4> <part5> <part6> \    % participles
           <gnd3> <gnd4> <gnd5>                                        \    % converbs
           #auxs#                                                      \    % auxiliaries
           <cert> <pot> <cond>                                         \    % mood markers
           #voices#                                                    \    % voice markers
           #noms# <poss>                                               \    % nominals
           <co-v>                                                      \    % pronouns
           #cards# #colls# <ord> <appr>                                \    % numerals (cardinal, ordinal, approximate)
           <dat>                                                       \    % cases
           <part-c> <part-av>                                          \    % particles
           <psor-3>                                                    \    % possessives
           <dt1>                                                       \    % determiners
           <intj-d>                                                         % interjections

$pred$ = \
<>:[#g-pred#]                                                                  {\+1SG}:{<B><C>н}         <>:<predsg> | \
<>:[#g-pred#]                                                                  {\+2SG}:{<V><C>н}         <>:<predsg> | \
<>:[#g-pred#]                                                                  {\+1PL}:{<B><C>т}         <>:<predpl> | \
<>:[#g-pred#]                                                                  {\+2PL}:{<V><C>т}         <>:<predpl>


% 1.3 Mood markers -----------------------------------------------------------------------------------------------------

% The distant future for the imperative mood exist only for the second person singular and plural [Sleptsov, p.535].
% It is formed by adding the affix <LO>р after the verbal stem. The plural, the same as the regular imperative,
% requires also the addition of the possessive affix <C>ҥ.

$mood$ = \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg>                 ]          {\+COND}:{<D1><O>р}   <>:<cond>   | \
<>:[#verbs#       #d-verbs#     #voices#          <neg>                 ]          {\+AFFIR}:{<LC>һ<C>}  <>:<cert>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#          <neg>                 ]          {\+POT}:{<LO>р<O>й}   <>:<pot>    | \
<>:[#verbs-v#     <verb-v>               #aspect#                       ]          {\+POT}:{р<O>й}       <>:<pot>    | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg>                 ]          {\+IMP\^FUT}:{<LO>р}  <>:<imp-r>  | \
<>:[<part3-c>                                     <neg>                 ]          {\+IMP}:{<O>й}        <>:<imp-c>  | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg>                 ]          {\+IMP}:<LC>          <>:<imp-v>  | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg>                 ]          {\+IMP}:{<D1><C>н}    <>:<psor>   | \
<>:<imp-v>                                                                         {\+1SG}:м             <>:<psor>   | \
<>:<part3-c>                                                                       {\+1PL}:{<C>ҥ}        <>:<psor>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#                <imp-r>         ]          {\+IMP\+2PL}:{<C>ҥ}   <>:<psor>   | \
<>:[#verbs-v#     <verb-v>               #aspect# <neg>                 ]          {\+IMP\+2PL}:ҥ        <>:<psor>

$imp$ = \
<>:<part3-c>                                                              {\+IMP\+1SG}:{т<C>б<C>н}       <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+2SG}:{т<C>г<C>н}       <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+3SG}:{т<C>н}           <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+1PL}:{т<C>б<C>т<C>н}   <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+2PL}:{т<C>г<C>т<C>н}   <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+3PL}:{т<C>нн<O>р}      <>:<psor>


% 1.4 Near past --------------------------------------------------------------------------------------------------------

$past$ = \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\+1SG}:{<D1><C>м}         <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\+2SG}:{<D1><C>ҥ}         <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\+3SG}:{<D1><O>}          <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\+1PL}:{<D1><C>б<C>т}     <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\+2PL}:{<D1><C>г<C>т}     <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\+3PL}:{<D1><C>л<O>р}     <>:<past>


% 1.5 Simple case affixes ----------------------------------------------------------------------------------------------

% - demonstrative and personal pronouns do not take the partitive affix.
% - the pronoun туох <int-c> has alternative forms <int-a> for the accusative and instrumental cases.

% Table 1 [Pronouns]
#g-com-pron#   = <dem> <prs> <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v>
#g-par-pron#   =             <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v>
#g-acc-pron-c# = <dem>       <dt1>       <int-p> <int-c> <int-a> <int-s>
#g-acc-pron-v# =       <prs>       <dt2>                                 <int-v> <co-v>
#g-dat-pron#   = <dem> <prs> <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v>
#g-abl-pron-c# = <dem>       <dt1>       <int-p> <int-c>         <int-s>
#g-abl-pron-v# =       <prs>       <dt2>                                 <int-v> <co-v>
#g-ins-pron-c# =             <dt1>       <int-p> <int-c> <int-a> <int-s>
#g-ins-pron-v# = <dem> <prs>       <dt2>                                 <int-v> <co-v>
#g-cmp-pron#   = <dem> <prs> <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v>

% Table 2 [Postpositions and particles]
#g-com-nom#   = #noms#    #d-nouns# <poss> <adj-dc> <adj-dj>
#g-par-nom#   = #noms#    #d-nouns# <poss> <adj-dc> <adj-dj>
#g-acc-nom-c# = #noms-cj# <noun-dc> <poss> <adj-dc> <adj-dj>
#g-acc-nom-v# = #noms-v#  <noun-dv>
#g-dat-nom#   = #noms#    #d-nouns# <poss> <adj-dc> <adj-dj>
#g-abl-nom-c# = #noms-cj# <noun-dc> <poss> <adj-dc> <adj-dj>
#g-abl-nom-v# = #noms-v#  <noun-dv>
#g-ins-nom-c# = #noms-cj# <noun-dc> <poss> <adj-dc> <adj-dj>
#g-ins-nom-v# = #noms-v#  <noun-dv>
#g-cmp-nom#   = #noms#    #d-nouns# <poss> <adj-dc> <adj-dj>

% - Ordinal numbers can take simple case forms when replacing nouns [§297].
% - Approximate numbers can take simple case forms when replacing nouns [§301].

% Main table:
#g-com#   = #g-com-nom#   #g-com-pron#   <plur> #cards#  <appr>                                  #parts#
#g-par#   = #g-par-nom#   #g-par-pron#   <plur> #cards#  <appr>                                  #parts#
#g-acc-c# = #g-acc-nom-c# #g-acc-pron-c# <plur> <card-c>                 <part1>                 <part-c> <post-c>
#g-acc-v# = #g-acc-nom-v# #g-acc-pron-v#        <card-v> <appr>                                  <part-v> <post-v>
#g-dat#   = #g-dat-nom#   #g-dat-pron#   <plur> #cards#  <appr> <coll-c>         <part4>         #parts#  #posts#
#g-abl-c# = #g-abl-nom-c# #g-abl-pron-c# <plur> <card-c>                                                  <post-c>
#g-abl-v# = #g-abl-nom-v# #g-abl-pron-v#        <card-v> <appr>                                           <post-v>
#g-ins-c# = #g-ins-nom-c# #g-ins-pron-c# <plur> <card-c>                                  <part5>         <post-c>
#g-ins-v# = #g-ins-nom-v# #g-ins-pron-v#        <card-v> <appr>                           <part5>         <post-v>
#g-cmp#   = #g-cmp-nom#   #g-cmp-pron#   <plur> #cards#  <appr>                                           #posts#

% DEVELOPMENT NOTES:
% - та (&all) demonstrative pronouns retain the locative case [§318].

$s-case$ = \
<>:[#g-com#   #propns#   #participles#                    ]                    {\+COMIT}:{<D2><LC>н}     <>:<case-c> | \
<>:[#g-par#   #propns#   #participles#                    ]                    {\+PRTV}:{<D1><O>}        <>:<case-v> | \
<>:[#g-acc-c# #propns-c# #participles-c# <adv-dc> <coll-c>]                    {\+ACC}:<C>               <>:<acc>    | \
<>:[#g-acc-v# #propns-v# <part3-v>       <adv-dv>         ]                    {\+ACC}:{н<C>}            <>:<case-v> | \
<>:[#g-dat#   #propns#   #participles#   #d-adv#          ]                    {\+DAT}:{<V><O>}          <>:<dat>    | \
<>:[#g-abl-c# #propns-c# #participles-c# <adv-dc>         ]                    {\+ABL}:{т<O>н}           <>:<case-c> | \
<>:[#g-abl-v# #propns-v# <part3-v>       <adv-dv>         ]                    {\+ABL}:{тт<O>н}          <>:<case-c> | \
<>:[#g-ins-c# #propns-c# #participles-c# <adv-dc>         ]                    {\+INST}:{<C>н<O>н}       <>:<case-c> | \
<>:[#g-ins-v# #propns-v# <part3-v>       <adv-dv>         ]                    {\+INST}:{н<O>н}          <>:<case-c> | \
<>:<dem>                                                                       {\+INST}:{<O>н}           <>:<case-c> | \
<>:[#g-cmp#   #propns#   #participles#                    ]                    {\+COMP}:{<D1><LO>ҕ<O>р}  <>:<case-c> | \
<>:[<dem> <int-c>                                         ]                    {\+LOC}:{<D1><O>}         <>:<loc>


% 1.6 Personal possessive affixes --------------------------------------------------------------------------------------

#g-verb-sg-c# = <part1> <part1-n> <part2> <part3-c> <part4>         #voices#
#g-verb-sg-v# =                           <part3-v>         <part5>
#g-verb-pl#   = <part1> <part1-n> <part2> <part3-c> <part4> <part5> #voices#

#g-nom-sg-cj# = #noms-cj# <noun-dc> #d-adj-cj# #propns-c# <card-c> <ord>        <post-c>  <poss> <part-c> <adv-col>
#g-nom-sg-v# =  #noms-v#  <noun-dv> <adj-dv>   #propns-v# <card-v>       <appr> <post-v>         <part-v>
#g-nom-pl# =    #noms#    #d-nouns# #d-adj#    #propns#   #cards#  <ord> <appr> #posts#   <poss> #parts#  <adv-col>

$psor$ = \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur>                       <int-p>]          {\+POSS\.1SG}:{<C>м}      <>:<psor>   | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         #aspect# <ka-v> <dem>        ]          {\+POSS\.1SG}:м           <>:<psor>   | \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur>                       <int-p>]          {\+POSS\.2SG}:{<C>ҥ}      <>:<psor>   | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         #aspect# <ka-v> <dem>        ]          {\+POSS\.2SG}:ҥ           <>:<psor>   | \
<>:[#g-verb-pl#   #g-nom-pl#    <plur>          <ka-v> <dem> <int-p>]          {\+POSS\.1PL}:{<B><C>т}   <>:<psor>   | \
<>:[#g-verb-pl#   #g-nom-pl#    <plur>          <ka-v> <dem> <int-p>]          {\+POSS\.2PL}:{<V><C>т}   <>:<psor>   | \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur>                              ]          {\+POSS\.3}:<O>           <>:<psor-3> | \
<>:[#g-verb-sg-v# #g-nom-sg-v#                  <ka-v> <dem> <int-p>]          {\+POSS\.3}:{т<O>}        <>:<psor-3>


% 1.7 Possessive case affixes ------------------------------------------------------------------------------------------

% Ordinal numbers can take possessive case forms when replacing nouns [§297].
% Approximative numbers can take possessive case forms when replacing nouns [§301].
% Adverbial participle -аат does not take predicative affixes; instead, it takes the genitive case of the
% personal-possessive [§462-463].

#g-case#    = #g-nom-pl#    #participles#     #cards#   <prs> <co-v>
#g-case-cj# = #g-nom-sg-cj# #participles-c#   <card-c>  <prs>
#g-case-v#  = #g-nom-sg-v#  #participles-v#   <card-v>  <prs> <co-v>

$poss-case$ = \
<>:[#g-case#    <plur>]                                     {\+POSS\.1SG\+COMIT}:{<B><C>н<LC>н}         <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\+COMIT}:{<V><C>н<LC>н}         <>:<case-p>  | \
<>:[#g-case-cj# <plur>]                                     {\+POSS\.3SG\+COMIT}:{<C>н<LC>н}            <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\+COMIT}:{т<C>н<LC>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\+COMIT}:{<B><C>т<C>н<LC>н}     <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\+COMIT}:{<V><C>т<C>н<LC>н}     <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\+COMIT}:{<D2><O>р<C>н<LC>н}    <>:<case-p>  | \
\
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.1SG\+ACC}:{<B><C>н}                <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.2SG\+ACC}:{<V><C>н}                <>:<acc-p>  | \
<>:[#g-case-cj# <plur> <int-p>]                             {\+POSS\.3SG\+ACC}:{<C>н}                   <>:<acc-p>  | \
<>:[#g-case-v#         <int-p>]                             {\+POSS\.3SG\+ACC}:{т<C>н}                  <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.1PL\+ACC}:{<B><C>т<C>н}            <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.2PL\+ACC}:{<V><C>т<C>н}            <>:<acc-p>  | \
<>:[#g-case#           <int-p>]                             {\+POSS\.3PL\+ACC}:{<D2><O>р<C>н}           <>:<acc-p>  | \
\
<>:[#g-case#    <part4>]                                    {\+POSS\.1SG\+PRTV}:{<B><C>н<O>}            <>:<case-p>  | \
<>:[#g-case#    <part4>]                                    {\+POSS\.2SG\+PRTV}:{<V><C>н<O>}            <>:<case-p>  | \
<>:[#g-case-cj# <part4>]                                    {\+POSS\.3SG\+PRTV}:{<C>н<O>}               <>:<case-p>  | \
<>:[#g-case-v#  <part4>]                                    {\+POSS\.3SG\+PRTV}:{т<C>н<O>}              <>:<case-p>  | \
<>:[#g-case#    <part4>]                                    {\+POSS\.1PL\+PRTV}:{<B><C>т<C>н<O>}        <>:<case-p>  | \
<>:[#g-case#    <part4>]                                    {\+POSS\.2PL\+PRTV}:{<V><C>т<C>н<O>}        <>:<case-p>  | \
<>:[#g-case#    <part4>]                                    {\+POSS\.3PL\+PRTV}:{<D2><O>р<C>н<O>}       <>:<case-p>  | \
\
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.1SG\+DAT}:{<B><O>р}                <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.2SG\+DAT}:{<V><O>р}                <>:<case-p>  | \
<>:[#g-case-cj# <plur> <ord>]                               {\+POSS\.3SG\+DAT}:{<C>г<O>р}               <>:<case-p>  | \
<>:[#g-case-v#              ]                               {\+POSS\.3SG\+DAT}:{т<C>г<O>р}              <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.1PL\+DAT}:{<B><C>т<C>г<O>р}        <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.2PL\+DAT}:{<V><C>т<C>г<O>р}        <>:<case-p>  | \
<>:[#g-case#           <ord>]                               {\+POSS\.3PL\+DAT}:{<D2><O>р<C>г<O>р}       <>:<case-p>  | \
\
<>:[#g-case#    <plur>]                                     {\+POSS\.1SG\+ABL}:{<B><C>тт<O>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\+ABL}:{<V><C>тт<O>н}           <>:<case-p>  | \
<>:[#g-case-cj# <plur>]                                     {\+POSS\.3SG\+ABL}:{<C>тт<O>н}              <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\+ABL}:{т<C>тт<O>н}             <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\+ABL}:{<B><C>т<C>тт<O>н}       <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\+ABL}:{<V><C>т<C>тт<O>н}       <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\+ABL}:{<D2><O>р<C>тт<O>н}      <>:<case-p>  | \
\
<>:[#g-case#    <plur>]                                     {\+POSS\.1SG\+INST}:{<B><C>н<O>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\+INST}:{<V><C>н<O>н}           <>:<case-p>  | \
<>:[#g-case-cj#       ]                                     {\+POSS\.3SG\+INST}:{<C>н<O>н}              <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\+INST}:{т<C>н<O>н}             <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\+INST}:{<B><C>т<C>н<O>н}       <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\+INST}:{<V><C>т<C>н<O>н}       <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\+INST}:{<D2><O>р<C>н<O>н}      <>:<case-p>  | \
\
<>:[#g-case#]                                               {\+POSS\.1SG\+COMP}:{<B><C>н<LO>ҕ<O>р}      <>:<case-p>  | \
<>:[#g-case#]                                               {\+POSS\.2SG\+COMP}:{<V><C>н<LO>ҕ<O>р}      <>:<case-p>  | \
<>:[#g-case-cj#]                                            {\+POSS\.3SG\+COMP}:{<C>н<LO>ҕ<O>р}         <>:<case-p>  | \
<>:[#g-case-v#]                                             {\+POSS\.3SG\+COMP}:{т<C>н<LO>ҕ<O>р}        <>:<case-p>  | \
<>:[#g-case#]                                               {\+POSS\.1PL\+COMP}:{<B><C>т<C>н<LO>ҕ<O>р}  <>:<case-p>  | \
<>:[#g-case#]                                               {\+POSS\.2PL\+COMP}:{<V><C>т<C>н<LO>ҕ<O>р}  <>:<case-p>  | \
<>:[#g-case#]                                               {\+POSS\.3PL\+COMP}:{<D2><O>р<C>н<LO>ҕ<O>р} <>:<case-p>


% 1.8 Interrogative marks ----------------------------------------------------------------------------------------------

$int$ = \
<>:[<poss> <predsg> <predpl> <plur> <part2> <part-c> <psor> <int-c>]                   {\+INT}:{<C>й}    <>:<in>     | \
<>:[#noms-v# <int-v> <part-v> <part-av> <psor-3>]                                      {\+INT}:{н<C>й}   <>:<in>     | \
<>:[<part3-v> <psor-3>]                                                                {\+INT}:{й}       <>:<in>




%%% 2. AGGREGATED INFLECTIONAL AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section specifies which of the previously defined affixes to include in the transducer by listing them in
% ('$inflectional-affixes$')

$inflectional-affixes$ = $plur$ | $pred$ | $mood$ | $imp$ | $past$ | $psor$ | $s-case$ | $poss-case$ | $int$