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

% -лар (&all.) forms the plural affix from various type of stems.
% The pronoun ким takes нээх to form the plural, after which a regular plural affix can be used for emphasis [§329].

$plur$ = <>:[#noms# #d-nouns# #d-adj# #propns# <poss>                               \    % primary and derived nominals
             #cards# #d-nums# <ord> <coll-v>                                        \    % numerals
             <prs> <dem> <dt1> <dt2> <int-c> <int-v> <ind> <ka-v> <ka-c> #cos#      \    % pronouns
             <int-p>                                                                \    % interrogative
             <ps> <case-p>                                                          \    % case
             #auxs#                                                                 \    % auxiliaries
             #voices#                                                               \    % voice markers
             <cond> <cert> <pot> <imp-n>                                            \    % mood markers
             #participles#                                                          \    % participles
             <gnd1> <gnd3> <gnd4> <gnd5> <gnd6>                                     \    % converbs
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
% - +CONV1 can take predicate affixes [§441].

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
           <gnd1> <gnd6>                                               \    % converbs
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



% 1.3 Simple case affixes ----------------------------------------------------------------------------------------------

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
<>:[#g-com#   #propns#   #participles#                     <adj-dv>]           {\+COMIT}:{<D2><LC>н}     <>:<case-c> | \
<>:[#g-par#   #propns#   #participles#                     <adj-dv>]           {\+PRTV}:{<D1><O>}        <>:<case-v> | \
<>:[#g-acc-c# #propns-c# #participles-c# <adv-dc> <coll-c>         ]           {\+ACC}:<C>               <>:<acc>    | \
<>:[#g-acc-v# #propns-v# <part3-v>       <adv-dv>          <adj-dv>]           {\+ACC}:{н<C>}            <>:<case-v> | \
<>:[#g-dat#   #propns#   #participles#   #d-adv#           <adj-dv>]           {\+DAT}:{<V><O>}          <>:<dat>    | \
<>:[#g-abl-c# #propns-c# #participles-c# <adv-dc>                  ]           {\+ABL}:{т<O>н}           <>:<case-c> | \
<>:[#g-abl-v# #propns-v# <part3-v>       <adv-dv>          <adj-dv>]           {\+ABL}:{тт<O>н}          <>:<case-c> | \
<>:[#g-ins-c# #propns-c# #participles-c# <adv-dc>                  ]           {\+INST}:{<C>н<O>н}       <>:<case-c> | \
<>:[#g-ins-v# #propns-v# <part3-v>       <adv-dv>          <adj-dv>]           {\+INST}:{н<O>н}          <>:<case-c> | \
<>:<dem>                                                                       {\+INST}:{<O>н}           <>:<case-c> | \
<>:[#g-cmp#   #propns#   #participles#                     <adj-dv>]           {\+COMP}:{<D1><LO>ҕ<O>р}  <>:<case-c> | \
<>:[<dem> <int-c>                                                  ]           {\+LOC}:{<D1><O>}         <>:<loc>



% 1.4 Personal possessive affixes --------------------------------------------------------------------------------------

#g-verb-sg-c# = <part1> <part1-n> <part2> <part3-c> <part4>         #voices#
#g-verb-sg-v# =                           <part3-v>         <part5>
#g-verb-pl#   = <part1> <part1-n> <part2> <part3-c> <part4> <part5> #voices#

#g-nom-sg-cj_1# = #noms-cj# <noun-dc> #d-adj-cj# <adv-dc> <adv-col> #propns-c# <card-c> <ord>
#g-nom-sg-v_1#  = #noms-v#  <noun-dv> <adj-dv>   <adv-dv>           #propns-v# <card-v>
#g-nom-pl_1#    = #noms#    #d-nouns# #d-adj#    <adv-dc> <adv-col> #propns#   #cards#  <ord>

#g-nom-sg-cj# = #g-nom-sg-cj_1#        <post-c>  <poss> <part-c>
#g-nom-sg-v#  = #g-nom-sg-v_1#  <appr> <post-v>         <part-v>  <co-v>
#g-nom-pl#    = #g-nom-pl_1#    <appr> #posts#   <poss> #parts#   <co-v>

$psor$ = \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur>                       <int-p>]          {\+POSS\.1SG}:{<C>м}      <>:<psor>   | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         <ka-v>          <dem>        ]          {\+POSS\.1SG}:м           <>:<psor>   | \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur>                       <int-p>]          {\+POSS\.2SG}:{<C>ҥ}      <>:<psor>   | \
<>:[#g-verb-sg-v# #g-nom-sg-v#         <ka-v>          <dem>        ]          {\+POSS\.2SG}:ҥ           <>:<psor>   | \
<>:[#g-verb-pl#   #g-nom-pl#    <plur>          <ka-v> <dem> <int-p>]          {\+POSS\.1PL}:{<B><C>т}   <>:<psor>   | \
<>:[#g-verb-pl#   #g-nom-pl#    <plur>          <ka-v> <dem> <int-p>]          {\+POSS\.2PL}:{<V><C>т}   <>:<psor>   | \
<>:[#g-verb-sg-c# #g-nom-sg-cj# <plur>                    <ps> <ind>]          {\+POSS\.3SG}:<O>         <>:<psor-3> | \
<>:[#g-verb-sg-v# #g-nom-sg-v#                  <ka-v> <dem> <int-p> <int-v>]  {\+POSS\.3SG}:{т<O>}      <>:<psor-3>



% 1.5 Possessive case affixes ------------------------------------------------------------------------------------------

% Ordinal numbers can take possessive case forms when replacing nouns [§297].
% Approximative numbers can take possessive case forms when replacing nouns [§301].
% Adverbial participle -аат does not take predicative affixes; instead, it takes the genitive case of the
% personal-possessive [§462-463].

#g-case#    = #g-nom-pl#    #participles#     #cards#   <prs> <co-v>          <int-c> <int-s>
#g-case-cj# = #g-nom-sg-cj# #participles-c#   <card-c>  <prs>                 <int-c> <int-s>
#g-case-v#  = #g-nom-sg-v#  #participles-v#   <card-v>  <prs> <co-v> <adv-dv>

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
<>:[#g-case-cj# <plur> <int-p> <ps>]                        {\+POSS\.3SG\+ACC}:{<C>н}                   <>:<acc-p>  | \
<>:[#g-case-v#         <int-p>]                             {\+POSS\.3SG\+ACC}:{т<C>н}                  <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.1PL\+ACC}:{<B><C>т<C>н}            <>:<acc-p>  | \
<>:[#g-case#    <plur> <int-p>]                             {\+POSS\.2PL\+ACC}:{<V><C>т<C>н}            <>:<acc-p>  | \
<>:[#g-case#           <int-p>]                             {\+POSS\.3PL\+ACC}:{<D2><O>р<C>н}           <>:<acc-p>  | \
\
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.1SG\+PRTV}:{<B><C>н<O>}            <>:<case-p>  | \
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.2SG\+PRTV}:{<V><C>н<O>}            <>:<case-p>  | \
<>:[#g-case-cj# <plur> <part4>]                             {\+POSS\.3SG\+PRTV}:{<C>н<O>}               <>:<case-p>  | \
<>:[#g-case-v#         <part4>]                             {\+POSS\.3SG\+PRTV}:{т<C>н<O>}              <>:<case-p>  | \
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.1PL\+PRTV}:{<B><C>т<C>н<O>}        <>:<case-p>  | \
<>:[#g-case#    <plur> <part4>]                             {\+POSS\.2PL\+PRTV}:{<V><C>т<C>н<O>}        <>:<case-p>  | \
<>:[#g-case#           <part4>]                             {\+POSS\.3PL\+PRTV}:{<D2><O>р<C>н<O>}       <>:<case-p>  | \
\
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.1SG\+DAT}:{<B><O>р}                <>:<case-p>  | \
<>:[#g-case#    <plur> <ord>]                               {\+POSS\.2SG\+DAT}:{<V><O>р}                <>:<case-p>  | \
<>:[#g-case-cj# <plur> <ord>]                               {\+POSS\.3SG\+DAT}:{<C>г<O>р}               <>:<case-p>  | \
<>:[#g-case-v#               <dt2>]                         {\+POSS\.3SG\+DAT}:{т<C>г<O>р}              <>:<case-p>  | \
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
<>:[#g-case-cj# <plur>]                                     {\+POSS\.3SG\+INST}:{<C>н<O>н}              <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\+INST}:{т<C>н<O>н}             <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\+INST}:{<B><C>т<C>н<O>н}       <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\+INST}:{<V><C>т<C>н<O>н}       <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\+INST}:{<D2><O>р<C>н<O>н}      <>:<case-p>  | \
\
<>:[#g-case#    <plur>]                                     {\+POSS\.1SG\+COMP}:{<B><C>н<LO>ҕ<O>р}      <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2SG\+COMP}:{<V><C>н<LO>ҕ<O>р}      <>:<case-p>  | \
<>:[#g-case-cj# <plur>]                                     {\+POSS\.3SG\+COMP}:{<C>н<LO>ҕ<O>р}         <>:<case-p>  | \
<>:[#g-case-v#        ]                                     {\+POSS\.3SG\+COMP}:{т<C>н<LO>ҕ<O>р}        <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.1PL\+COMP}:{<B><C>т<C>н<LO>ҕ<O>р}  <>:<case-p>  | \
<>:[#g-case#    <plur>]                                     {\+POSS\.2PL\+COMP}:{<V><C>т<C>н<LO>ҕ<O>р}  <>:<case-p>  | \
<>:[#g-case#          ]                                     {\+POSS\.3PL\+COMP}:{<D2><O>р<C>н<LO>ҕ<O>р} <>:<case-p>



% 2.1 Voice markers ----------------------------------------------------------------------------------------------------

% There are five voices in Yakut [§472]:
% 1) base: is the primary verb form (null affix) [§473].
% 2) causative: indicates mainly that the grammatical subject is not the one that is completing the action [§477].
% 3) reflexive:
% 4) passive
% 5) reciprocal


% 2.1.1 Causative affixes from transitive verbs ------------------------------------------------------------------------

% The following affixes are attached to:
% -т after long vowel- or diphthong ending stems [§481].
% -тар (&all.) attach to stems ending in consonant [§482] (PO: only monosyllabic?).
% -тар attaches to different types of living and dead roots, frequently causative and other voices [§482].
% Affixes -т and -тар are very productive in modern Yakut [§482].

$caus$ = \
<>:[#trans-v# <verb-v>]                                                        {\+CAUS}:т                <>:<caus-c> | \
<>:[<tran-1c> <tran-1r> <tran-1l> <tran-2c> <refl> <pass> <recp>]              {\+CAUS}:{<D1><O>р}       <>:<caus-r> | \
<>:[<tran-2r> <tran-2j> <cstv-c> <tran-1j>]                                    {\+CAUS}:{т<O>р}          <>:<caus-r>



% 2.1.2 Causative affixes from intransitive verbs ----------------------------------------------------------------------

% Forms causative-transitive verbs from intransitives [§483].
% -т (^cstv) from intransitives ending in long vowels, й and р [§483].
% -тар (&all) attaches to a small group of monosyllabic intransitives [§484].
% -ар (&all) a reduced group of one-syllable intransitive verbs [§485].
% -ыар (&all) from one-syllable intransitive verbs [§486].

$cstv$ = \
<>:[#intrs-v# #intrs-j# <intr-2r> <intr-1r> <verb-r> <verb-j>]                 {\+CSTV}:т                <>:<cstv-c> | \
<>:[#intrs-c# #intrs-j# #intrs-r# #recps#]                                     {\+CSTV}:{<C>т}           <>:<cstv-c> | \
<>:[#intrs-nl# <intr-1c>]                                                      {\+CSTV}:{<D1><O>р}       <>:<cstv-r> | \
<>:[<intr-1c>]                                                                 {\+CSTV}:{<O>р}           <>:<cstv-r> | \
<>:[<intr-1c> <intr-1r>]                                                       {\+CSTV}:{<DI>р}          <>:<cstv-r>



% 2.1.3 Reflective affixes ---------------------------------------------------------------------------------------------

% It is formed only from verbal stems (primary or derived) with transitive meaning (including causatives) [§493].
% -н after verbal stems ending in long vowel or diphthong (same form as the passive voice) [§493].
% -ын (&all) after verbal stems ending in consonant [§493].

% ABOUT DEAD forms (verbs that do not longer are used without the affix)

$refl$ = \
<>:[#trans-v# <verb-v> <tran-2j> <tran-1j>                           <aux-v>]            {\+REFL}:н       <>:<refl>  | \
<>:[#trans-c# #trans-l# <tran-j> <tran-1j> #trans-r# #cstvs# #recps# <aux-c>]            {\+REFL}:{<C>н}  <>:<refl>



% 2.1.4 Passive affixes ------------------------------------------------------------------------------------------------

% The same as reflexive, passive verbs are formed from transitive verbs and a few verbs of movement [§505].
% The passive voice is formed by affixes -н and -ылын [§505]:
% -н after verbal stems ending in long vowel or diphthong (same form as the reflexive voice).
% -ылын (&all) after verbal stems ending in consonants.

$pass$ = \
<>:[#trans-v# <verb-v>                                        #moods# <aux-v>]     {\+PASS}:н            <>:<pass>   | \
<>:[#trans-c# #trans-r# <tran-1l>          <tran-1j> #voices#                ]     {\+PASS}:{<C>л<C>н}   <>:<pass>   | \
<>:[<tran-j>  <tran-2l> <tran-l> <tran-1j> <tran-2j> <fig-j>          <aux-c>]     {\+PASS}:{л<C>н}      <>:<pass>

% DEVELOPMENT NOTES:
% Check where to place #trans-l#



% 2.1.5 Joint-reciprocal affixes ---------------------------------------------------------------------------------------

% Reciprocal affix express reciprocal and simultaneous mutual action [§510].
% -с attaches to long vowel or diphthong ending stems.
% -ыс (&all) attaches to final consonants.
% -сыс (&all) joint-reciprocal verbs can appear in double form.

$recp$ = \
<>:[#trans-v# #intrs-v# <verb-v> <intr-j> <tran-j> <verb-j>]                         {\+RECP}:с          <>:<recp-s> | \
<>:[<intr-1j> <tran-1j> <intr-2j> <tran-2j> <fig-j>]                                 {\+RECP}:с          <>:<recp-s> | \
<>:[#verbs-c# #verbs-j# #verbs-r# <verb-j> <tran-1l> <intr-1nl> <cstv-c> <caus-c>]   {\+RECP}:{<C>с}     <>:<recp>   | \
<>:[#verbs-c# #verbs-j# #verbs-r# <verb-c> <tran-1l> <verb-j> <verb-r> <intr-1nl>]   {\+RECP\#1}:{с<C>с} <>:<recp-s>



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

$mood$ = \
<>:[#verbs#       #d-verbs#     #voices#  <neg>          ]                         {\+AFFIR}:{<LC>һ<C>}  <>:<cert>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#  <neg> <aux-c>  ]                         {\+POT}:{<LO>р<O>й}   <>:<pot>    | \
<>:[#verbs-v#     <verb-v>                      <aux-v>  ]                         {\+POT}:{р<O>й}       <>:<pot>    | \
<>:[#verbs#       #d-verbs#     #voices#  <neg>          ]                         {\+IMP\.FUT}:{<LO>р}  <>:<imp-r>  | \
<>:[<part3-c>                             <neg>          ]                         {\+IMP}:{<O>й}        <>:<imp-c>  | \
<>:[#verbs#       #d-verbs#     #voices#  <neg>          ]                         {\+IMP}:<LC>          <>:<imp-v>  | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#   ]                         {\+IMP}:{<D1><C>н}    <>:<imp-n>  | \
<>:<imp-v>                                                                         {\+1SG}:м             <>:<psor>   | \
<>:<part3-c>                                                                       {\+1PL}:{<C>ҥ}        <>:<psor>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#        <imp-r>   <aux-c>]                 {\+IMP\+2PL}:{<C>ҥ}   <>:<psor>   | \
<>:[#verbs-v#     <verb-v>                <neg> <part3-v> <aux-v>]                 {\+IMP\+2PL}:ҥ        <>:<psor>

$imp$ = \
<>:<part3-c>                                                              {\+IMP\+1SG}:{т<C>б<C>н}       <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+2SG}:{т<C>г<C>н}       <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+3SG}:{т<C>н}           <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+1PL}:{т<C>б<C>т<C>н}   <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+2PL}:{т<C>г<C>т<C>н}   <>:<psor>   | \
<>:<part3-c>                                                              {\+IMP\+3PL}:{т<C>нн<O>р}      <>:<psor>



% 2.4 Expressive marker ------------------------------------------------------------------------------------------------

% Affix that can be attached to any global stem (non-derivative, derivative, including complex) with a modal-emotional
% connotation of affection, pity, regret for in relation to the performer of the action or, conversely, a shade of
% humiliation, irony, annoyance, contempt for someone [§396].

$expr$ = \
<>:[#verbs-c# #verbs-j# #verbs-r# #trans-l# #intrs-nl# <verb-j> <verb-r> \
    #voices# <aux-c>]                                                              {\+EXPR}:{<LO>хт<LO>} <>:<verb-v> | \
<>:[#verbs-v# <aux-v>]                                                             {\+EXPR}:{хт<LO>}     <>:<verb-v>



% 2.5 Aspect markers ---------------------------------------------------------------------------------------------------

% Yakut has a developed system of forms that serve to characterize the characteristics of the course of action from
% the side of its manifestation in time and space, its amount of force, achievements and results [§518].

% This affixes can be attached to almost every verb form, primary or derived:
% -бахтаа (&all.) expresses an action performed at an accelerated rate [§523].
% -(ы)талаа (&all.) expresses the sequential alternation of actions [§521].

% Apart from these forms, there are other less used [§536]:
% -таа (&all.) express repetition from transitives ending in р or л (also from causative forms) [§538].
% -аттаа (&all.) found in a few verbs formed from some monosyllabic stems with a transitive meaning [§539].
% -ыалаа (&all.) attached to stems that primarily express various types of movement (productive) [§541].
% -ыак(к)алаа (&all.) a variation of the -ыалаа with similar meaning [§542].
% -ыахтаа (&all.) forms verbs that are close in meaning to previous verbs [§543].
% -алаа (&all.) occurs in few verbs with the meaning is the same as -ыалаа [§544].
% -ак(к)алаа (&all.) occurs in several verbs [§545].
% -балаа (&all.) found in some verbs, usually formed from monosyllabic stems [§546].

$aspv$ = \
<>:[#verbs# <verb-v> #voices#]                                               {\+ACCE}:{<B><O>хт<LO>}     <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ACCE}:{х<C>с}            <>:<acce>   | \
<>:[<fig-j>]                                                                 {\+ACCE}:{к<C>с}            <>:<acce>   | \
<>:[#intrs-v# #trans-v# #verbs-j# #verbs-r# #trans-l# #intrs-nl#]            {\+ITER}:{т<O>л<LO>}        <>:<verb-v> | \
<>:[#verbs-c# #verbs-r# #verbs-j# #trans-l# #intrs-nl# <cstv-c>]             {\+ITER}:{<C>т<O>л<LO>}     <>:<verb-v> | \
<>:[#trans-r# #trans-l# <caus-r> <cstv-r> <recp>]                            {\+ITER}:{т<LO>}            <>:<verb-v> | \
<>:[<tran-1c> <tran-1l> <tran-1r> <tran-2c>]                                 {\+ITER}:{<O>тт<LO>}        <>:<verb-v> | \
<>:[<tran-2v>]                                                               {\+ITER}:{тт<LO>}           <>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+ITER}:{<DI>л<LO>}        <>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+ITER}:{<DI>кк<O>л<LO>}   <>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+ITER}:{<DI>к<O>л<LO>}    <>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+ITER}:{<DI>хт<LO>}       <>:<verb-v> | \
<>:[#intrs# #trans# <caus-c> <cstv-c>]                                       {\+ITER}:{<O>л<LO>}         <>:<verb-v> | \
<>:[#verbs-v#]                                                               {\+ITER}:{к<O>л<LO>}        <>:<verb-v> | \
<>:[#verbs-c# #verbs-r# <intr-1nl>]                                          {\+ITER}:{<O>кк<O>л<LO>}    <>:<verb-v> | \
<>:[#verbs-c# #verbs-r# <intr-1nl>]                                          {\+ITER}:{<O>к<O>л<LO>}     <>:<verb-v> | \
<>:[<intr-1c> <tran-1c> <intr-1r> <tran-1r> <intr-1nl>]                      {\+ITER}:{<B><O>л<LO>}      <>:<verb-v>

% DEVELOPMENT NOTES:
% тт<LO> was observed in тамнаа -> тамнааттаа and холбоо -> холбооттоо.
% This section is underdefined and needs to be studied in detail. This outputs to many variants in generation mode.
% Is the initial т not affected by regressive assimilation?



% 2.6 Aspect markers (figuratives) -------------------------------------------------------------------------------------

% These affixes mainly function among individual semantic groups of verbs. The following groups of forms are
% distinguished here based on their meaning [§572]:
% - movability: special dynamism or prevalence of a particular action or phenomenon [§572].
% - separative repetition: the action as a whole is represented as a series of repeated actions [§573].
% - frequentative repetition: is accelerated repetition of movement or its actions [§577].
% - slowness: indicates that the action is manifested at a slow pace [§580].

% Forms of movability [§573]:
% Close in meaning and in some cases are used interchangeable after the same figurative root.
% -рый (&all.) more common
% -һый (&all.) more common
% -лый (&all.) less common
% -чый (&all.) less common

% Accelerated for imitatives and figuratives is formed by ҥнаа (&all.).
% -ҥнаа consist of two elements -ҥ and -наа. The last is a phonetical variant of affix -лаа. The element -ҥ represents
% a half-deprecated nominal affix. Implemented as a combination of ^NMLZ7 + ^VRBZ1 [§570].
% с к are implemented as adjectives
% Uniform multiplicity. These are unproductive affixes.

$aspf$ = \
<>:[<fig-j>]                                                                 {\+ACCE}:{р<C>й}            <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ACCE}:{һ<C>й}            <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ACCE}:{л<C>й}            <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ACCE}:{ч<C>й}            <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ITER}:{лдь<C>й}          <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ITER}:{рд<LO>}           <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+FREC}:{х<O>чч<C>й}       <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+FREC\#1}:{х<O>чч<C>й}    <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+FREC}:{к<C>чч<C>й}       <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+FREC}:{ҕ<O>лдь<C>й}      <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+FREC}:{г<C>лдь<C>й}      <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+FREC}:{х<C>с}            <>:<verb-c> | \
<>:[<fig-j>]                                                                 {\+FREC}:{к<C>с}            <>:<verb-c> | \
<>:[<fig-j>]                                                                 {\+SLOW}:{<LO>р<C>й}        <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ITER}:{ҥ<O>л<LO>}        <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ITER}:{ҥх<O>л<LO>}       <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ITER}:{<LO>д<C>й}        <>:<verb-j> | \
<>:[<fig-j>]                                                                 {\+ITER}:{<LO>х<O>йд<LO>}   <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ITER}:{<LO>р<O>йд<LO>}   <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ITER}:{<LO>хт<LO>}       <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ITER}:{ҥх<O>ст<LO>}      <>:<verb-v>



% 2.7 Participial affixes ----------------------------------------------------------------------------------------------

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
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#        <aux-c>       ]          {\+PART\_PRES}:{<O>р}          <>:<part1>   | \
<>:[#verbs-v#     <verb-v>                                    ]          {\+PART\_PRES}:{<LC>р}         <>:<part1>   | \
<>:[#verbs#       #d-verbs#     #voices#        #auxs#        ]          {\+NEG\+PART\_PRES}:{<B><O>т}  <>:<part1-n> | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#  <gnd1>]          {\+PART\_PAST}:{<B><C>т}       <>:<part2>   | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+PART\_FUT}:{<DI>х}          <>:<part3-c> | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+PART\_FUT}:{<DI>}           <>:<part3-v> | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+CONV\_COND\#1}:{<D1><O>р}   <>:<part4>   | \
<>:[#verbs#       #d-verbs#     #voices#  <neg> #auxs#        ]          {\+CONV\_COND\#2}:{<D1><O>х}   <>:<part4>



% 2.8 Adverbial participles --------------------------------------------------------------------------------------------

% There are nine types of adverbial participles [§433]:
% -ан (&all) express relative tense in relation with the action of the main verb.
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
<>:[#verbs-crjnl# #d-verbs-jrc#     #voices#                  <aux-c>]     {\+CONV\#1}:{<O>н}            <>:<gnd1>   | \
<>:[#verbs-v#     <verb-v>                          <part3-v> <aux-v>]     {\+CONV\#1}:н                 <>:<gnd1>   | \
<>:[#verbs-crjnl# <verb-c> <verb-j> <verb-r> #voices#         <aux-c>]     {\+CONV\#2}:<O>               <>:<gnd2>   | \
<>:[#verbs-v#     <verb-v>          #voices#                  <aux-v>]     {\+CONV\#2}:<LC>              <>:<gnd2>   | \
<>:[<neg>                                                            ]     {\+CONV\#3}:{<C>н<O>}         <>:<gnd3>   | \
<>:[<neg>                                                            ]     {\+CONV\#3a}:{н<O>}           <>:<gnd3>   | \
<>:[#verbs#                                                          ]     {\+NEG\+CONV\#4}:{б<O>кк<O>}  <>:<gnd4>   | \
<>:[#verbs-crjnl# #d-verbs-jrc#     #voices# <neg>            #auxs# ]     {\+CONV\#5}:{<LO>р<C>}        <>:<gnd5>   | \
<>:[#verbs-v#     <verb-v>                                           ]     {\+CONV\#5}:{р<C>}            <>:<gnd5>   | \
<>:[#verbs#       #d-verbs#         #voices# <neg>            #auxs# ]     {\+CONV\#6}:{<LO>т}           <>:<gnd6>   | \
<>:[<part2>                                                          ]     {\+CONV\#7}:{ч<O>}            <>:<gnd7>



% 2.9 Near past --------------------------------------------------------------------------------------------------------

$past$ = \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.1SG}:{<D1><C>м}         <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.2SG}:{<D1><C>ҥ}         <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.3SG}:{<D1><O>}          <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.1PL}:{<D1><C>б<C>т}     <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.2PL}:{<D1><C>г<C>т}     <>:<past>   | \
<>:[#verbs# #voices# #d-verbs# <neg> <iter> <acce> #auxs#]               {\+PST\.3PL}:{<D1><C>л<O>р}     <>:<past>



% 3.1 Interrogative marks ----------------------------------------------------------------------------------------------

$int$ = \
<>:[<poss> <predsg> <predpl> <plur> <part1> <part2> <part-c> <psor> \
    <int-c> <int-p> <imp-n> <aux-c> <ord> ]                                                  {\+INT}:{<C>й}  <>:<in> | \
<>:[#noms-v# <int-v> <part-v> <part-av> <psor-3> <adj-dv>]                                   {\+INT}:{н<C>й} <>:<in> | \
<>:[<part3-v> <psor-3> <psor-3> <acc>]                                                       {\+INT}:{й}     <>:<in>




%%% 2. AGGREGATED INFLECTIONAL AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section specifies which of the previously defined affixes to include in the transducer by listing them in
% ('$inflectional-affixes$')

$voice$ = $caus$ | $cstv$ | $refl$ | $pass$ | $recp$

$inflectional-affixes$ = $plur$ | $pred$ | $mood$ | $imp$ | $past$ | $psor$ | $s-case$ | $poss-case$ | \
                         $voice$ | $neg$ | $expr$ | $aspv$ | $aspf$ | $partz$ | $gndz$ | $int$