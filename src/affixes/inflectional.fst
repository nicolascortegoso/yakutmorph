%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Inflectional affixes definitions
%  Last review:    02/03/2025

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

% -лар (&all.) forms the plural affix from various type of stems.
% The pronoun ким takes нээх to form the plural, after which a regular plural affix can be used for emphasis [§329].

$plur$ = <>:[#noms# #d-nouns# #d-adj# <poss>                                          \  % primary and derived nominals
             #cards# #d-nums# <ord> <coll-v> <int-s>                                  \  % numerals
             <prs> <dem> <dt1> <dt2> <int-c> <int-v> <ind> <ref> <ka-v> <ka-c> #cos#  \  % pronouns
             <int-p>                                                                  \  % interrogative
             <ps> <case-p> <loc>                                                      \  % case
             #auxs#                                                                   \  % auxiliaries
             #voices#                                                                 \  % voice markers
             <cond> <cert> <pot> <deb>                                                \  % mood markers
             #participles#                                                            \  % participles
             <gnd1> <gnd3> <gnd4> <gnd5> <gnd6>                                       \  % converbs
             #parts#                                                                  \  % particles
             <plur-s>                                                                 \  % special plural
             ]                                                  {\+PL}:{<D2><O>р}                        <>:<plur>   | \
<>:<int-p>                                                      {\+PL}:{нээх}                            <>:<plur-s>


% 1.2 Predicative affixes ----------------------------------------------------------------------------------------------

% Predicative affixes attach to many type of stems. The list below reference to the sections in Ubryatova et al., where
% this is specified:
% - adverbial participles can take personal affixes [§435].
% - adverbial participles change by person and number [§435].
% - adverbial participles -ымына can take personal affixes [§451].
% - adverbial participles -аары can take personal affixes [§457].
% - +CONV1 can take predicate affixes [§441].

% Notes:
% - To ease readability, stem types common to the first and second person, both singular and plural, are grouped
% together in '#g-pred#'.
% - Specific stems for the singular and plural are respectively aggregated as '#g-pred-sg#' and '#g-pred-pl#.'
% - The third person in Yakut is unmarked (no affix).

#g-pred# = <part1> <part1-n> <part2> <part3-c>                         \
           <part4> <part5> <part5-c> <part6>                           \    % participles
           <gnd3> <gnd4> <gnd5>                                        \    % converbs
           #auxs#                                                      \    % auxiliaries
           <cert> <pot> <cond> <deb>                                   \    % mood markers
           #voices#                                                    \    % voice markers
           <gnd1> <gnd6>                                               \    % converbs
           #noms#                                                      \    % primary nominals
           #d-nouns# #d-adj# <poss>                                    \    % derived nominals
           <co-v>                                                      \    % pronouns
           #cards# #colls# <ord> <appr>                                \    % numerals (cardinal, ordinal, approximate)
           <dat>                                                       \    % cases
           <part-c> <part-v>                                           \    % particles
           <psor-3>                                                    \    % possessives
           <dt1>                                                       \    % determiners
           <intj-d>                                                    \    % interjections
           <conj>                                                      \    % conjunctions
           #posts#                                                          % postpositions

$pred$ = \
<>:[#g-pred# <int-v> <dt2> <loc>]                                              {\+1SG}:{<B><C>н}         <>:<predsg> | \
<>:[#g-pred# <int-v> <dt2> <loc>]                                              {\+2SG}:{<V><C>н}         <>:<predsg> | \
<>:[#g-pred# <plur> <int-v> <dt2> <loc>]                                       {\+1PL}:{<B><C>т}         <>:<predpl> | \
<>:[#g-pred# <plur> <int-v> <dt2> <loc>]                                       {\+2PL}:{<V><C>т}         <>:<predpl> | \
<>:[<part2>]                                                                   {\+1SG}:{<B><DI>н}        <>:<predsg> | \
<>:[<part2>]                                                                   {\+2SG}:{<V><DI>н}        <>:<predsg> | \
<>:[<part2>]                                                                   {\+3SG}:{<DI>н}           <>:<predsg> | \
<>:[<part2>]                                                                   {\+1PL}:{<B><C>т<DI>н}    <>:<predpl> | \
<>:[<part2>]                                                                   {\+2PL}:{<V><C>т<DI>н}    <>:<predpl>


% In writing, the narrow vowel in the predicate affix added to participles ending in -byt is transformed into the 
% corresponding diphthong in the 1st and 2nd persons singular to increase expressiveness [Коркина Е.И., Наклонения 
% глагола в якутском языке, 90].




% 1.3 Simple case affixes ----------------------------------------------------------------------------------------------

% - demonstrative and personal pronouns do not take the partitive affix.
% - the pronoun туох <int-c> has alternative forms <int-a> for the accusative and instrumental cases.

% Table 1 [Pronouns]
#g-com-pron#   = <dem> <prs> <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v> <ind> <ref>
#g-par-pron#   =             <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v> <ind> <ref>
#g-acc-pron-c# = <dem>       <dt1>       <int-p> <int-c> <int-a> <int-s>                <ind>
#g-acc-pron-v# =       <prs>       <dt2>                                 <int-v> <co-v>       <ref>
#g-dat-pron#   = <dem> <prs> <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v> <ind> <ref>
#g-abl-pron-c# = <dem>       <dt1>       <int-p> <int-c>         <int-s>                <ind>
#g-abl-pron-v# =       <prs>       <dt2>                                 <int-v> <co-v>       <ref>
#g-ins-pron-c# =             <dt1>       <int-p> <int-c> <int-a> <int-s>                <ind>
#g-ins-pron-v# = <dem> <prs>       <dt2>                                 <int-v> <co-v>       <ref>
#g-cmp-pron#   = <dem> <prs> <dt1> <dt2> <int-p> <int-c>         <int-s> <int-v> <co-v> <ind>

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
#g-com#   = #g-com-nom#   #g-com-pron#   #plurs# #cards#  <ord> <appr>                                  #parts#
#g-par#   = #g-par-nom#   #g-par-pron#   #plurs# #cards#  <ord> <appr>                                  #parts#
#g-acc-c# = #g-acc-nom-c# #g-acc-pron-c# #plurs# <card-c> <ord>                <part1>                 <part-c> <post-c>
#g-acc-v# = #g-acc-nom-v# #g-acc-pron-v#         <card-v>       <appr>                          <part5> <part-v> <post-v>
#g-dat#   = #g-dat-nom#   #g-dat-pron#   #plurs# #cards#  <ord> <appr> <coll-c>         <part4>         #parts#  #posts#
#g-abl-c# = #g-abl-nom-c# #g-abl-pron-c# #plurs# <card-c> <ord>                                                 <post-c>
#g-abl-v# = #g-abl-nom-v# #g-abl-pron-v#         <card-v>       <appr>                                           <post-v> <part-v>
#g-ins-c# = #g-ins-nom-c# #g-ins-pron-c# #plurs# <card-c> <ord>                           <part5>          <post-c>
#g-ins-v# = #g-ins-nom-v# #g-ins-pron-v#         <card-v>                                 <part5>          <post-v>
#g-cmp#   = #g-cmp-nom#   #g-cmp-pron#   #plurs# #cards#  <ord> <appr>                                           #posts#

% DEVELOPMENT NOTES:
% - та (&all) demonstrative pronouns retain the locative case [§318].

$s-case$ = \
<>:[#g-com#   #participles#                     <adj-dv>]                      {\+COMIT}:{<D2><LC>н}     <>:<case-c> | \
<>:[#g-par#   #participles#                     <adj-dv>]                      {\+PRTV}:{<D1><O>}        <>:<case-v> | \
<>:[#g-acc-c# #participles-c# <adv-dc> <coll-c>         ]                      {\+ACC}:<C>               <>:<acc>    | \
<>:[#g-acc-v# <part3-v>       <adv-dv>          <adj-dv>]                      {\+ACC}:{н<C>}            <>:<case-v> | \
<>:[#g-dat#   #participles#   #d-adv#           <adj-dv>]                      {\+DAT}:{<V><O>}          <>:<dat>    | \
<>:[#g-abl-c# #participles-c# <adv-dc>                   <int-v>]              {\+ABL}:{т<O>н}           <>:<case-c> | \
<>:[#g-abl-v# <part3-v>       <adv-dv>          <adj-dv>]                      {\+ABL}:{тт<O>н}          <>:<case-c> | \
<>:[#g-ins-c# #participles-c# <adv-dc>                  ]                      {\+INST}:{<C>н<O>н}       <>:<case-c> | \
<>:[#g-ins-v# <part3-v>       <adv-dv>          <adj-dv>]                      {\+INST}:{н<O>н}          <>:<case-c> | \
<>:[<dem> <int-v>                                                  ]           {\+INST}:{<O>н}           <>:<case-c> | \
<>:[#g-cmp#   #participles#                     <adj-dv>]                      {\+COMP}:{<D1><LO>ҕ<O>р}  <>:<case-c> | \
<>:[<dem> <int-c>                                                  ]           {\+LOC}:{<D1><O>}         <>:<loc>



% 1.4 Personal possessive affixes --------------------------------------------------------------------------------------

#g-verb-sg-c# = <part1> <part1-n> <part2> <part3-c> <part4>         <part5-c> <deb> <int-a> <int-c>
#g-verb-sg-v# =                           <part3-v>         <part5>
#g-verb-pl#   = <part1> <part1-n> <part2> <part3-c> <part4> <part5> <part5-c> <deb>

#g-nom-sg-cj_1# = #noms-cj# <noun-dc> #d-adj-cj# <adv-dc> <adv-col> <card-c> <ord>
#g-nom-sg-v_1#  = #noms-v#  <noun-dv> <adj-dv>   <adv-dv>           <card-v>
#g-nom-pl_1#    = #noms#    #d-nouns# #d-adj#    <adv-dc> <adv-col> #cards#  <ord>

#g-nom-sg-cj# = #g-nom-sg-cj_1#        <post-c>  <poss> <part-c>
#g-nom-sg-v#  = #g-nom-sg-v_1#  <appr> <post-v>         <part-v>  <co-v> <ref>
#g-nom-pl#    = #g-nom-pl_1#    <appr> #posts#   <poss> #parts#   <co-v> <ref>

#3-sing# = <ka-v> <prs> <dem> <int-p> <ref> <int-v> <dim>

$psor$ = \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur> <ka-c>      <dem> <int-p>      ]        {\+POSS\.1SG}:{<C>м}      <>:<psor>   | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         <ka-v>                    <dim>]        {\+POSS\.1SG}:м           <>:<psor>   | \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur> <ka-c>      <dem> <int-p>      ]        {\+POSS\.2SG}:{<C>ҥ}      <>:<psor>   | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         <ka-v>                    <dim>]        {\+POSS\.2SG}:ҥ           <>:<psor>   | \
<>:[#g-verb-pl#   #g-nom-pl#    <plur> #dem-prons# <dem> <int-p> <dim> <int-a> <int-v>] {\+POSS\.1PL}:{<B><C>т}   <>:<psor>   | \
<>:[#g-verb-pl#   #g-nom-pl#    <plur> #dem-prons# <dem> <int-p> <dim> <int-a> <int-v>] {\+POSS\.2PL}:{<V><C>т}   <>:<psor>   | \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur> <ka-c>            <ind>   <ps> ]        {\+POSS\.3SG}:<O>         <>:<psor-3> | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         #3-sing#                       ]        {\+POSS\.3SG}:{т<O>}      <>:<psor-3> | \
<>:<part3-c>                                                                   {\+POSS\.1PL}:{<B><C>т<C>н} <>:<psor> | \
<>:<part3-c>                                                                   {\+POSS\.2PL}:{<V><C>т<C>н} <>:<psor>

% DEVELOPMENT NOTES: According to Korkina E.I. [1970: 55-56], before the interrogative suffix and after the plural \
% participle, the first and second person plural possessives can take respectively the forms at the end of the list.



% 1.5 Possessive case affixes ------------------------------------------------------------------------------------------

% Ordinal numbers can take possessive case forms when replacing nouns [§297].
% Approximative numbers can take possessive case forms when replacing nouns [§301].
% Adverbial participle -аат does not take predicative affixes; instead, it takes the genitive case of the
% personal-possessive [§462-463].

#g-case#    = #g-nom-pl#    #participles#     #cards#   <prs> <co-v>          <int-c> <int-s>
#g-case-cj# = #g-nom-sg-cj# #participles-c#   <card-c>  <prs>                 <int-c> <int-s>
#g-case-v#  = #g-nom-sg-v#  #participles-v#   <card-v>  <prs> <co-v> <adv-dv>

$poss-case$ = \
<>:[#g-case#    <plur> <dem>]                               {\+POSS\.1SG\.COMIT}:{<B><C>н<LC>н}         <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\.COMIT}:{<V><C>н<LC>н}         <>:<case-p>  | \
<>:[#g-case-cj# <plur>        <ps>]                         {\+POSS\.3SG\.COMIT}:{<C>н<LC>н}            <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\.COMIT}:{т<C>н<LC>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\.COMIT}:{<B><C>т<C>н<LC>н}     <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\.COMIT}:{<V><C>т<C>н<LC>н}     <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\.COMIT}:{<D2><O>р<C>н<LC>н}    <>:<case-p>  | \
\
<>:[#g-case#    <plur> <int-p>      <dem>]                  {\+POSS\.1SG\.ACC}:{<B><C>н}                <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.2SG\.ACC}:{<V><C>н}                <>:<acc-p>  | \
<>:[#g-case-cj# <plur> <int-p> <ps> <int-a>]                {\+POSS\.3SG\.ACC}:{<C>н}                   <>:<acc-p>  | \
<>:[#g-case-v#         <int-p>]                             {\+POSS\.3SG\.ACC}:{т<C>н}                  <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.1PL\.ACC}:{<B><C>т<C>н}            <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.2PL\.ACC}:{<V><C>т<C>н}            <>:<acc-p>  | \
<>:[#g-case#           <int-p>]                             {\+POSS\.3PL\.ACC}:{<D2><O>р<C>н}           <>:<acc-p>  | \
\
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.1SG\.PRTV}:{<B><C>н<O>}            <>:<case-p>  | \
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.2SG\.PRTV}:{<V><C>н<O>}            <>:<case-p>  | \
<>:[#g-case-cj# <plur> <part4> <ps>]                        {\+POSS\.3SG\.PRTV}:{<C>н<O>}               <>:<case-p>  | \
<>:[#g-case-v#         <part4>]                             {\+POSS\.3SG\.PRTV}:{т<C>н<O>}              <>:<case-p>  | \
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.1PL\.PRTV}:{<B><C>т<C>н<O>}        <>:<case-p>  | \
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.2PL\.PRTV}:{<V><C>т<C>н<O>}        <>:<case-p>  | \
<>:[#g-case#           <part4>]                             {\+POSS\.3PL\.PRTV}:{<D2><O>р<C>н<O>}       <>:<case-p>  | \
\
<>:[#g-case#    <plur> <ord> <dem>]                         {\+POSS\.1SG\.DAT}:{<B><O>р}                <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.2SG\.DAT}:{<V><O>р}                <>:<case-p>  | \
<>:[#g-case-cj# <plur> <ord> <ps> <ind>]                    {\+POSS\.3SG\.DAT}:{<C>г<O>р}               <>:<case-p>  | \
<>:[#g-case-v#                          <dt2>]              {\+POSS\.3SG\.DAT}:{т<C>г<O>р}              <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.1PL\.DAT}:{<B><C>т<C>г<O>р}        <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.2PL\.DAT}:{<V><C>т<C>г<O>р}        <>:<case-p>  | \
<>:[#g-case#           <ord>]                               {\+POSS\.3PL\.DAT}:{<D2><O>р<C>г<O>р}       <>:<case-p>  | \
\
<>:[#g-case#    <plur> <dem>]                               {\+POSS\.1SG\.ABL}:{<B><C>тт<O>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\.ABL}:{<V><C>тт<O>н}           <>:<case-p>  | \
<>:[#g-case-cj# <plur>       <ps>]                          {\+POSS\.3SG\.ABL}:{<C>тт<O>н}              <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\.ABL}:{т<C>тт<O>н}             <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\.ABL}:{<B><C>т<C>тт<O>н}       <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\.ABL}:{<V><C>т<C>тт<O>н}       <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\.ABL}:{<D2><O>р<C>тт<O>н}      <>:<case-p>  | \
\
<>:[#g-case#    <plur> <dem>]                               {\+POSS\.1SG\.INST}:{<B><C>н<O>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\.INST}:{<V><C>н<O>н}           <>:<case-p>  | \
<>:[#g-case-cj# <plur>       <ps>]                          {\+POSS\.3SG\.INST}:{<C>н<O>н}              <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\.INST}:{т<C>н<O>н}             <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\.INST}:{<B><C>т<C>н<O>н}       <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\.INST}:{<V><C>т<C>н<O>н}       <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\.INST}:{<D2><O>р<C>н<O>н}      <>:<case-p>  | \
\
<>:[#g-case#    <plur> <dem>]                               {\+POSS\.1SG\.COMP}:{<B><C>н<LO>ҕ<O>р}      <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\.COMP}:{<V><C>н<LO>ҕ<O>р}      <>:<case-p>  | \
<>:[#g-case-cj# <plur>       <ps>]                          {\+POSS\.3SG\.COMP}:{<C>н<LO>ҕ<O>р}         <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\.COMP}:{т<C>н<LO>ҕ<O>р}        <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\.COMP}:{<B><C>т<C>н<LO>ҕ<O>р}  <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\.COMP}:{<V><C>т<C>н<LO>ҕ<O>р}  <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\.COMP}:{<D2><O>р<C>н<LO>ҕ<O>р} <>:<case-p>


$poss-case-2$ = \
<>:[#g-case#    <plur> <dem>]                               {\+POSS\.1SG\.COMIT}:{<B><C>н<LO>н}         <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\.COMIT}:{<V><C>н<LO>н}         <>:<case-p>  | \
<>:[#g-case-cj# <plur>        <ps>]                         {\+POSS\.3SG\.COMIT}:{<C>н<LO>н}            <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\.COMIT}:{т<C>н<LO>н}           <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\.COMIT}:{<B><C>т<C>н<LO>н}     <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\.COMIT}:{<V><C>т<C>н<LO>н}     <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\.COMIT}:{<D2><O>р<C>н<LO>н}    <>:<case-p>




% 2.2 Negation affixes -------------------------------------------------------------------------------------------------

% -ма (&all) forms the negative from verbal stems ending in vowels [§113].
% -ыма (&all) forms the negative from verbal stems ending in consonants.

$neg$ = \
<>:[#verbs-v#     <verb-v>               #moods# <aux-v>]                       {\+NEG}:{м<O>}            <>:<neg>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#         <aux-c>]                       {\+NEG}:{<C>м<O>}         <>:<neg>



% 2.3 Mood markers -----------------------------------------------------------------------------------------------------

% The distant future for the imperative mood exist only for the second person singular and plural [Sleptsov, p.535].
% It is formed by adding the affix <LO>р after the verbal stem. The plural, the same as the regular imperative,
% requires also the addition of the possessive affix <C>ҥ.

$imp$ = \
<>:[#verbs#       #d-verbs#     <neg> #voices#]                        {\+IMP\#1\.1SG}:{<LC>м}         <>:<imp>      | \
<>:[#verbs#       #d-verbs#     <neg> #voices# <aux-c>]                {\+IMP\#1\.3SG}:{<D1><C>н}      <>:<imp-n>    | \
<>:[<part3-c>]                                                         {\+IMP\#1\.1PL}:{<C>ҥ}          <>:<imp-p>    | \
<>:[#verbs-v#     <verb-v>      <neg>         ]                        {\+IMP\#1\.2PL}:ҥ               <>:<imp-p>    | \
<>:[#verbs-crjnl# #d-verbs-jrc#       #voices# <aux-c>]                {\+IMP\#1\.2PL}:{<C>ҥ}          <>:<imp-p>    | \
<>:[#verbs#       #d-verbs#     <neg> #voices#]                        {\+IMP\#1\.3PL}:{<D1><C>нн<O>р} <>:<imp>      | \
<>:[#verbs#       #d-verbs#     <neg> #voices#]                        {\+IMP\#2\.2SG}:{<LO>р}         <>:<imp>      | \
<>:[#verbs#       #d-verbs#     <neg> #voices#]                        {\+IMP\#2\.2PL}:{<LO>р<C>ҥ}     <>:<imp>


% -лаах   it forms the debitive mood after participles.

% -ааччы (&all) can be attached to any verbal stem. It has a meaning close to the active participle in Russian [§176].
% -ааччы commonly performed action is also considered a secondary participle [§429].
% Kharitonov L.N. and other specialists considered -ааччы to be a verbal noun or the name of an actor, as it forms nouns
% denoting the actor's name. Ubryatova E.I. interprets this affix as a participle capable of taking predicate affixes
% and denoting an action that is usually performed [Korkina E.I. Nakloneniya glagola v yakutskom yazyke. Nauka, 1970,
% p. 221].

$mood$ = \
<>:[#verbs#       #d-verbs#     #voices#  <neg> <aux-c>  ]                       {\+AFFIR#1}:{<LC>һ<C>}  <>:<cert>   | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> <aux-c>  ]                       {\+AFFIR#2}:{<LC>һ<C>к} <>:<cert>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#  <neg> <aux-c>  ]                       {\+POT}:{<LO>р<O>й}     <>:<pot>    | \
<>:[#verbs-v#     <verb-v>                      <aux-v>  ]                       {\+POT}:{р<O>й}         <>:<pot>    | \
<>:[<part1> <part1-n> <part2> <part3-c> <part4>          ]                       {\+DEB}:{<D2><LO>х}     <>:<deb>    | \
<>:[#verbs-crjnl#               #voices#  <neg> <aux-c>  ]                       {\+HAB#1}:{<LO>чч<C>}   <>:<part5>  | \
<>:[#verbs-v#     <verb-v>                      <aux-v>  ]                       {\+HAB#1}:{чч<C>}       <>:<part5>  | \
<>:[#verbs-crjnl#               #voices#  <neg> <aux-c>  ]                       {\+HAB#2}:{<LO>чч<C>к}  <>:<part5-c>| \
<>:[#verbs-v#     <verb-v>                      <aux-v>  ]                       {\+HAB#2}:{чч<C>к}      <>:<part5-c>




% 2.4 Participial affixes ----------------------------------------------------------------------------------------------

% Participles retain the basic characteristics of the verb [Ubryatova, p. 37]:
% 1) express the concept of action;
% 2) are linked to the category of tense;
% 3) can be used in the negative form.
% Participles are used as the main component in forming a number of complex verb forms.

% There are four primary forms of participles in Yakut [§400]:
% -ар/ыыр first participle form. It forms present-future and past continuous tense of the indicative mood [§401];
% -быт    second participle form. It underlies a number of forms of the past tense of the indicative mood [§407-408];
% -ыах    third participle form. It forms the future tense of the indicative mood [§412];
% -тах    fourth participle form. Forms the basis for the presumptive and second conditional moods [§422-423].

% Secondary forms are considered a combination of primary participle affixes with the affix -тах.

$partz$ = \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices# <fig-j><aux-c>       ]          {\+PART\_PRES}:{<O>р}          <>:<part1>   | \
<>:[#verbs-v#     <verb-v>                                    ]          {\+PART\_PRES}:{<LC>р}         <>:<part1>   | \
<>:[#verbs#       #d-verbs#     #voices#        #auxs#        ]          {\+NEG\+PART\_PRES}:{<B><O>т}  <>:<part1-n> | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#  <gnd1>]          {\+PART\_PAST}:{<B><C>т}       <>:<part2>   | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+PART\_FUT}:{<DI>х}          <>:<part3-c> | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+PART\_FUT}:{<DI>}           <>:<part3-v> | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+CONV\_COND\#1}:{<D1><O>р}   <>:<part4>   | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+CONV\_COND\#2}:{<D1><O>х}   <>:<part4>



% 2.5 Adverbial participles --------------------------------------------------------------------------------------------

% There are nine types of adverbial participles [§433]:
% -ан (&all) express relative tense in relation with the action of the main verb.
% -аан (&all) in some dialects of the Yakut language, the affix -ан acquires a long vowel, becoming -аан [Korkina: 1985:15].
% -а/-ыы (&all)
% -ымына (&all) negative form of -ан, and -а [§450].
% -бакка (&all) negative form of -ан, and -а/-ыы. More widely used than -ымына [§455].
% -аары (&all) denotes actions, conceived as the motive of the finite verb. [§459]
% -ымаары (implemented as the neg for of -аары) negative form of -ан, and -аары [§461].
% -аат (&all) does not have a negative form [§462-463].
% -бытынан implemented as instrumental case after -быт. Used to form analytically the initial aspect of verbs [§465].
% -бычча (&all) conveys an action representing a condition present at the time of speech by the finite verb [§469].

% COMMENTS:
% The affix -бакка can considered as the combination of the negative participle and the simple dative case [§455]. The
% decision to include it here as a 'full' affix, responds to the fact that it can be followed by the plural affix, to
% form the 3 person plural, while, typically, the plural affix precedes the dative case affix.

$gndz$ =  \
<>:[#verbs-crjnl# #d-verbs-jrc#     #voices#        <fig-j>   <aux-c>]     {\+CONV\#1}:{<O>н}            <>:<gnd1>   | \
<>:[#verbs-crjnl# #d-verbs-jrc#     #voices#        <fig-j>   <aux-c>]     {\+CONV\#1}:{<LO>н}           <>:<gnd1>   | \
<>:[#verbs-v#     <verb-v>                          <part3-v> <aux-v>]     {\+CONV\#1}:н                 <>:<gnd1>   | \
<>:[#verbs-crjnl# <verb-c> <verb-j> <fig-j> <verb-r> #voices# <aux-c>]     {\+CONV\#2}:<O>               <>:<gnd2>   | \
<>:[#verbs-v#     <verb-v>          #voices#                  <aux-v>]     {\+CONV\#2}:<LC>              <>:<gnd2>   | \
<>:[<neg>                                                            ]     {\+CONV\#3}:{<C>н<O>}         <>:<gnd3>   | \
<>:[<neg>                                                            ]     {\+CONV\#3a}:{н<O>}           <>:<gnd3>   | \
<>:[#verbs#                                                          ]     {\+NEG\+CONV\#4}:{б<O>кк<O>}  <>:<gnd4>   | \
<>:[#verbs-crjnl# #d-verbs-jrc#     #voices# <neg>            #auxs# ]     {\+CONV\#5}:{<LO>р<C>}        <>:<gnd5>   | \
<>:[#verbs-v#     <verb-v>                                           ]     {\+CONV\#5}:{р<C>}            <>:<gnd5>   | \
<>:[#verbs#       #d-verbs#         #voices# <neg>            #auxs# ]     {\+CONV\#6}:{<LO>т}           <>:<gnd6>   | \
<>:[<part2>                                                          ]     {\+CONV\#7}:{ч<O>}            <>:<gnd7>



% 2.7 Near past --------------------------------------------------------------------------------------------------------

$past$ = \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.1SG}:{<D1><C>м}         <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.2SG}:{<D1><C>ҥ}         <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.3SG}:{<D1><O>}          <>:<past-v> | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.1PL}:{<D1><C>б<C>т}     <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.2PL}:{<D1><C>г<C>т}     <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.3PL}:{<D1><C>л<O>р}     <>:<past>



% 3.1 Interrogative marks ----------------------------------------------------------------------------------------------

$int$ = \
<>:[<poss> <predsg> <predpl> <plur> <part1> <part2> <part-c> <psor> \
    <int-c> <int-p> <imp-n> <aux-c> <ord> #noms-c# <deb> <int-s>]          {\+INT}:{<C>й}                   <>:<in>  | \
<>:[#noms-v# <int-v> <part-v> <part-av> <psor-3> <adj-dv> <post-v>]        {\+INT}:{н<C>й}                  <>:<in>  | \
<>:[<part3-v> <psor-3> <psor-3> <acc> <past-v>]                            {\+INT}:{й}                      <>:<in>  | \
<>:[#verbs-crjnl# #d-verbs-jrc#       <imp> <imp-n> <part3-c>]             {\+INT\#1}:{<LC>й}               <>:<in>  | \
<>:[#verbs-v#     <verb-v>      <neg>]                                     {\+INT\#1}:{р<LC>й}              <>:<in>  | \
<>:[<imp-p>                                         <part3-c>]             {\+INT\#1}:{<C>т<LC>й}           <>:<in>  | \
<>:[<imp>                                           <part3-c>]             {\+INT\#2}:{<C>ҥ<LC>й}           <>:<in>  | \
<>:[#verbs-crjnl# #d-verbs-jrc#]                                           {\+INT\#2}:{<LC>ҥ<LC>й}          <>:<in>  | \
<>:[#verbs-v#     <verb-v>      <neg>]                                     {\+INT\#2}:{р<C>ҥ<LC>й}          <>:<in>  | \
<>:[<imp-p>]                                                               {\+INT\#2}:{<C>т<C>н<LC>й}       <>:<in>



% 3.2 Diminutive and intensifying marks --------------------------------------------------------------------------------

% -ыары/лык (&all) forms not productive adverbs of time, more rarely, place [§707].

$emph$ = \
<>:[#advs# <adv-dv>]                                                             {\+AUG\#1}:{<D1><C>к}   <>:<adv-dv> | \
<>:[#advs-v#]                                                                    {\+AUG\#2}:{чч<C>}      <>:<adv-dv> | \
<>:[#advs-c# #adjs-c# #adjs-j#]                                                  {\+AUG\#3}:{<C>н}       <>:<adv-dv> | \
<>:[#advs#]                                                                      {\+DIM\#1}:{<DI>р}      <>:<adv-dc> | \
<>:[#advs#]                                                                      {\+DIM\#1a}:{<DI>р<C>}  <>:<adv-dv> | \
<>:[#advs#]                                                                      {\+DIM\#1b}:{<DI>р<O>х} <>:<adv-dc> | \
<>:[#advs-v#]                                                                    {\+DIM\#1c}:{һ<DI>р}    <>:<adv-dc> | \
<>:[#advs-c#]                                                                    {\+DIM\#1c}:{с<DI>р}    <>:<adv-dc> | \
<>:[#advs#]                                                                      {\+DIM\#2}:{<D2><C>к}   <>:<adv-dc>

% DEVELOPMENT NOTES:
% Most of the diminutive and augmentative affix variants were added to match examples from the grammar [§707]. However,
% they still need to be revised.
% 'ыраах+Adv+DIM#1c', 'ыраах+Adj+DIM#5'



%%% 2. AGGREGATED INFLECTIONAL AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section specifies which of the previously defined affixes to include in the transducer by listing them in
% ('$inflectional-affixes$')


$inflectional-affixes$ = $plur$ | $pred$ | $imp$ | $mood$ | $past$ | $psor$ | $s-case$ | $poss-case$ | \
                         $poss-case-2$ | $neg$ | $partz$ | $gndz$ | $int$ | $emph$
