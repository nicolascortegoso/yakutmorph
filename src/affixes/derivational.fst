%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Derivational affixes definitions
%  Last review:    02/03/2025

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% The code in this file is divided into 3 sections:
% 1. Nominalization affixes definition;
% 2. Verbalization affixes definition;
% 3. Aggregated derivational affixes.

% In section 1 and 2 affixes are grouped into blocks.
% Each block is introduced by comments on the implementation and its reference to the source grammar.
% The initial comments are followed by the affix formalization, consisting of three columns:
% - the first column specifies the set of stems the affix can be attached to;
% - the second column contains the affix’s analysis and surface forms;
% - the third column declares the type of stem that is formed after the affix.

% The analysis form in the second column is adopted (with minor changes) from the Turkic Morpheme web portal.
% The surface form in the second column is defined using the special symbols to represent the affix allomorphs.
% These special symbols are defined in the alphabet. The realization of the symbols in context is specified by the
% phonetic rules.

% In comments, the abbreviation (&all) stands for 'and allomorphs'.




% 1. NOMINALIZATION AFFIXES DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 1.1 Nouns from other nouns -------------------------------------------------------------------------------------------

% This section includes just one affix:
% -һыт (&all) conveys agency, an occupation, profession, inclination towards an action [§155].
% -чыт and -сыт (&all) sometimes occur after vowels in parallel with the regular form -һыт [§123].
% -чык (&all) diminutive form from nouns [§156].
% -чаан (&all) diminutive form from nouns. Not very used [§158].
% -каан (&all) diminutive form from nouns. Not very used [§158].
% -ка (&all) diminutive forms always followed by possessive affixes [Sleptsov, p. 496].
% -ыйа (&all) unproductive affixes of emotional-evaluative meaning [§159].

$nomzn$ = \
<>:[#noms# <part3-c> <gnd2> <noun-dv> <noun-dc>]                     {\+NMLZ\#1}:{<H><C>т}             <>:<noun-dc>  | \
<>:[#noms#]                                                          {\+DIM\#1}:{ч<C>к}                <>:<noun-dc>  | \
<>:[#noms#]                                                          {\+DIM\#2}:{к<LO>н}               <>:<noun-dc>  | \
<>:[#noms#]                                                          {\+DIM\#2}:{ч<LO>н}               <>:<noun-dc>  | \
<>:[#noms# <ref>]                                                    {\+DIM\#3}:{к<O>}                 <>:<dim>      | \
<>:[#noms#]                                                          {\+DIM\#4}:{<C>й<O>}              <>:<dim>


% DEVELOPMENT NOTES:
% Affixes that convey diminutive forms, referenced in Ubryatova et al. [§156-159], are still not fully implemented.



% 1.2 Noun from verbs --------------------------------------------------------------------------------------------------

% Productive affixes:
% -ыы (&all) forms nouns from verbal stems ending in consonant. It refers mostly to the name of an action [§174].
% -ааһын (&all) forms nouns mainly from verbal stems ending in long vowels or diphthong. Similar in meaning to -ыы [§175].
% -был (&all) forms nouns from verbal stems ending in long vowel or й to denote the name of an action [§177].
% -ык (&all) forms nouns that denote the name of the action from verbal stems ending in consonant [§178].
% -(а)х (&all) forms nouns that indicate the instrument or the result of the action from verbal stems [§179].
% -лаҥ (&all) forms nouns that convey the name of the action. Has a short variant: ҥ [§180].
% -лта (&all) forms nouns from verbs to denote the name of the action [§181].
% -л form names with the meaning of concrete and abstract concepts. Unproductive [Sleptsov, p. 497].

$nomzv$ = \
<>:[#verbs-crjnl# #voices# <neg> <verb-r> <tran-2v> <verb-v> <verb-j> <aux-c>         ]     {\+NMLZ\#2}:{<LC>}        <>:<noun-dv>  | \
<>:[#verbs-v#     #intrs-j# #trans-j# <verb-v>                ]              {\+NMLZ\#3}:{<LO>һ<C>н}   <>:<noun-dc>  | \
<>:[#verbs-v# #verbs-j# <verb-v>                              ]              {\+NMLZ\#4}:{б<C>л}       <>:<noun-dc>  | \
<>:[#verbs-crjnl# #verbs-v#                                   ]              {\+NMLZ\#5}:{<C>к}        <>:<noun-dc>  | \
<>:[#verbs-c# #verbs-r# <verb-c> <verb-r> #trans-l# #intrs-nl# <recp-s>]     {\+NMLZ\#6}:{<O>х}        <>:<noun-dc>  | \
<>:[#verbs-v# #verbs-j# <verb-j>                               <neg>]        {\+NMLZ\#6}:х             <>:<noun-dc>  | \
<>:[#verbs-r# #verbs-j# #verbs-v# <verb-c> <pass> <intr-2nl>  ]              {\+NMLZ\#7}:{л<O>ҥ}       <>:<noun-dc>  | \
<>:[#verbs-v# <verb-v> <fig-j> <verb-j>                       ]              {\+NMLZ\#7}:ҥ             <>:<noun-dc>  | \
<>:[#verbs# <verb-v>                                          ]              {\+NMLZ\#8}:{лт<O>}       <>:<noun-dv>  | \
<>:[#verbs-v#     <verb-v>     <tran-j>  <tran-2j> <intr-2j>  ]              {\+NMLZ\#9}:л             <>:<noun-dc>


% DEVELOPMENT NOTES: Although [§178] does not mention the possibility of adding the affix -ык to verbal stems ending
% in vowels, we included this option to allow the formation of сырдык (light) from сырдаа (to light).


% 1.3 Adjectives from other adjectives ---------------------------------------------------------------------------------

% Augmentative form [§250].

$adjza$ = \
<>:[#adjs# <adj-dc> <adj-dv>]                                                  {\+DIM\#4}:{<D1><C>ҥ<C>}  <>:<adj-dv> | \
<>:[#adjs# <adj-dc> <adj-dv>]                                                  {\+DIM\#5}:{с<DI>р}       <>:<adj-dc>



% 1.4 Adjective from several stems -------------------------------------------------------------------------------------

% -лаах (&all) forms adjectives from several types of nominal and verbal stems [§262].
% Affix reduplication observed in түүлээхтээх

$poss$ = \
<>:[#noms# #d-nouns# #parts#                    \
<part1>                                         \
<plur>                                          \
<adv-dv>                                        \
<card-v> <card-c> <appr>                        \
<int-v>                                         \
<prs> <dt2> <int-c> <adj-dv> <poss>]                                                  {\+ADJZ\#1}:{<D2><LO>х} <>:<poss>



% 1.5 Adjectives from other nominals -----------------------------------------------------------------------------------

% -(ы)мсах (&all) denotes special inclination from nominal stems. Very productive [§259].
% -мсык (&all) from personal pronouns [§316].
% -тааҕы (&all) denotes location from noun stems, adverbs of place and adjectives of time [§260].
% -тааҕы (&all) from personal pronouns [§316].
% -гы (&all) forms adjectives of place and time [§261].

% The complex affix -тааҕы, forms relative adjectives from various simple and possessive nouns. As part of this affix,
% the frozen form of the local case -ta is restored.

$adjzn$ = \
<>:[#nouns-v# <prs>]                                                         {\+ADJZ\#2}:{мс<O>х}       <>:<adj-dc>  | \
<>:[#nouns-c# <plur>]                                                        {\+ADJZ\#2}:{<C>мс<O>х}    <>:<adj-dc>  | \
<>:[#adjs#]                                                                  {\+ADJZ\#2a}:{мс<C>к}      <>:<adj-dac> | \
<>:[#nouns# #advs# <prs> <dem> <plur> <dt2> <dem> <adj-dv> <int-v>]          {\+ADJZ\#3}:{<D1><LO>ҕ<C>} <>:<adj-dv>  | \
<>:[<acc-p> <case-p>]                                                        {\+ADJZ\#3}:{<LO>ҕ<C>}     <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\+ADJZ\#4}:{г<C>}         <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\+ADJZ\#4}:{к<C>}         <>:<adj-dv>  | \
<>:[#advs# #nouns# <intr-2j> <int-p> <verb-v>]                               {\+ADJZ\#4}:{ҥ<C>}         <>:<adj-dv>



% 1.6 Adjectives from verbs --------------------------------------------------------------------------------------------

% The following affixes are productive:
% -(ы)гас (&all) denotes a inclination to an action from base and reflexive verbs [§263].
% -аҕас (&all) forms result of an action or a characteristic of people. Not very productive [§264].
% -(ы)ган (&all) forms capability of carrying out an action or its result from stems ending in consonant [§265].
% -ҕар (&all) forms adjectives from verbs stems ending in -ай. Quite productive [§266].
% -гыр (&all) forms adjectives from verbs stems ending in -ый. It is a variant of -ҕар [§266].
% -хай/кэй (&all) forms primary adjectives denoting shades of colour [§266a].
% -ҕай/гэй (&all) express the result of an action from verbs ending in -й. Not productive [§267].
% -(ы)мтаҕай (&all) indicates the tendency towards an action or state [§268].
% -(ы)мтыа (&all) denotes the tendency towards or capability to perform an action. Quite productive [§269].
% -ыык (&all) indicates the tendency towards an action from verb stems ending in consonant. Quite productive [§270].
% -с from imitatives and some figurative verbs. Quite productive [§271].
% -нньаҥ (&all) expresses the capability to perform an action from base and reflexive verbal stems. Productive [§272].
% -(ы)к (&all) from verbal stems ending in й. Not very productive [§273].
% -(ы)х (&all) from verbal stems ending in long vowel. Not very productive [§273].
% -р (&all) similar in meaning to affix -гыр. Not very productive [§274].

% About affix '-аҕас': sometimes the verb can be reconstructed only with the aid of the historical-comparative method.

% -(ы)гас (&all) was found for the causative 'сүүй-тэр-игэс' [Kharitonov, 1963:73].

$adjzv$ = \
<>:[#verbs-v# #verbs-r# <intr-j>]                                          {\+ADJZ\#5}:{г<O>с}           <>:<adj-dc> | \
<>:[#verbs-crjnl# <intr-2v> <refl> <caus-r> <recp-s>]                      {\+ADJZ\#5}:{<C>г<O>с}        <>:<adj-dc> | \
<>:[#verbs# <verb-v> <pass>]                                               {\+ADJZ\#6}:{<O>ҕ<O>с}        <>:<adj-dc> | \
<>:[#verbs-v# <intr-j>]                                                    {\+ADJZ\#7}:{г<O>н}           <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                         {\+ADJZ\#7}:{<C>г<O>н}        <>:<adj-dc> | \
<>:[#verbs-j#]                                                             {\+ADJZ\#8}:{ҕ<O>р}           <>:<adj-dc> | \
<>:[#verbs-j# <fig-j>]                                                     {\+ADJZ\#8}:{г<C>р}           <>:<adj-dc> | \
<>:[#verbs# <verb-j>]                                                      {\+ADJZ\#9}:{х<O>й}           <>:<adj-dj> | \
<>:[#verbs-j# <fig-j>]                                                     {\+ADJZ\#10}:{ҕ<O>й}          <>:<adj-dj> | \
<>:[#verbs-v# <verb-v> <refl> <intr-2j>]                                   {\+ADJZ\#11}:{мт<O>ҕ<O>й}     <>:<adj-dj> | \
<>:[#verbs-crjnl# <verb-r>]                                                {\+ADJZ\#11}:{<C>мт<O>ҕ<O>й}  <>:<adj-dj> | \
<>:[#verbs-crjnl# <pass>]                                                  {\+ADJZ\#12}:{<C>мт<DI>}      <>:<adj-dv> | \
<>:[#verbs-crjnl# <recp> <recp-s>]                                         {\+ADJZ\#13}:{<LC>к}          <>:<adj-dc> | \
<>:[#verbs-v# <verb-v> <fig-j>]                                            {\+ADJZ\#14}:с                <>:<adj-dc> | \
<>:[#verbs-v# <verb-v>]                                                    {\+ADJZ\#15}:{ннь<O>ҥ}        <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                         {\+ADJZ\#15}:{<C>ннь<O>ҥ}     <>:<adj-dc> | \
<>:[#verbs-v# <fig-j>]                                                     {\+ADJZ\#16}:х                <>:<adj-dc> | \
<>:[#verbs-j# <fig-j> #intrs-nl#]                                          {\+ADJZ\#16}:к                <>:<adj-dc> | \
<>:[#verbs-c# #verbs-r# #voices#]                                          {\+ADJZ\#16}:{<C>к}           <>:<adj-dc> | \
<>:[<intr-2j> <fig-j> <neg>]                                               {\+ADJZ\#17}:р                <>:<adj-dc>

% DEVELOPMENT NOTES: the c affix derivation may require the creation of a special derived stem for verbs derived from
% onomatopoeias.



% 1.7 Pronoun affixes -------------------------------------------------------------------------------------------------

% -нык (&all) forms determinative pronouns from primary demonstratives or their emphatic variant -кa(й) [§324].
% -кa(й) (&all) affix that attaches to demonstratives pronouns to add emphasis [§322].
% -чча (&all) forms determinative pronouns from primary demonstratives or their emphatic variant -кa(й) [§325].
% -он (&all) added to personal and some interrogatives pronouns to form the possessive form [§364].

$pron$ = \
<>:[<dem>]                                                                     {\+DEF}:{н<C>к}           <>:<dt1>    | \
<>:[<dem>]                                                                     {\+DEF\#1}:{к<O>}         <>:<ka-v>   | \
<>:[<dem>]                                                                     {\+DEF\#1}:{к<O>й}        <>:<ka-c>   | \
<>:[<dem>]                                                                     {\+DEF\#2}:{чч<O>}        <>:<dt2>    | \
<>:[<prs> <int-p>]                                                             {\+COLL\#1}:{<O>н}        <>:<ps>



% 1.8 Numerals from other numerals ------------------------------------------------------------------------------------

% -(ы)с (&all) forms ordinals from cardinal numbers [§294].
% -ча (&all) forms approximate numbers [§299].
% -лыы (&all) conveys a distributive meaning [§303].
% -ыан (&all) forms the collective from the numeral [§308].
% -йах (&all) forms collective numerals with a restrictive-diminutive meaning [§309].

$numz$ = \
<>:[#cards# <int-s>]                                                           {\+ORD}:{<C>с}            <>:<ord>    | \
<>:[<card-v>]                                                                  {\+APPR\#1}:{чч<O>}       <>:<appr>   | \
<>:[<card-c>]                                                                  {\+APPR\#1}:{ч<O>}        <>:<appr>   | \
<>:[<card-v>]                                                                  {\+APPR\#2}:{чч<O>к<O>}   <>:<appr>   | \
<>:[<card-c>]                                                                  {\+APPR\#2}:{ч<O>к<O>}    <>:<appr>   | \
<>:[#cards# <appr> <int-s>]                                                    {\+DISTR}:{<D2><LC>}      <>:<dist>   | \
<>:[#cards# <int-s>]                                                           {\+COLL}:<DI>             <>:<coll-v> | \
<>:[<coll-v>]                                                                  {\+DIM\#4}:{й<O>х}        <>:<coll-c>



% 2. VERBALIZATION AFFIXES DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
<>:[#trans-v# <verb-v> <cstv-r>]                                               {\+CAUS}:т                <>:<caus-c> | \
<>:[<tran-1c> <tran-1r> <tran-1l> <tran-2l> <tran-2c> <refl> <pass> <recp> <tran-1j>]    {\+CAUS}:{<D1><O>р}       <>:<caus-r> | \
<>:[<tran-2r> <tran-2j> <cstv-c> <cstv-r> <caus-r> <tran-1j> <tran-2l>]                  {\+CAUS}:{т<O>р}          <>:<caus-r>


% DEVELOPMENT NOTES: <tran-1j> was added to т<O>р to allow



% 2.1.2 Causative affixes from intransitive verbs ----------------------------------------------------------------------

% Forms causative-transitive verbs from intransitives [§483].
% -т (+cstv) from intransitives ending in long vowels, й and р [§483].
% -тар (&all) attaches to a small group of monosyllabic intransitives [§484].
% -ар (&all) a reduced group of one-syllable intransitive verbs [§485].
% -ыар (&all) from one-syllable intransitive verbs [§486].

$cstv$ = \
<>:[#intrs-v# #intrs-j# <intr-2r> <intr-1r> <verb-r> <verb-j> <fig-j> <verb-v>]{\+CSTV}:т                <>:<cstv-c> | \
<>:[#intrs-c# #intrs-j# #intrs-r# #recps#]                                     {\+CSTV}:{<C>т}           <>:<cstv-c> | \
<>:[#intrs-nl# <intr-1c> <intr-1r>]                                            {\+CSTV}:{<D1><O>р}       <>:<cstv-r> | \
<>:[<intr-1c> <intr-2c> <intr-1nl> <intr-2nl> ]                                {\+CSTV}:{<O>р}           <>:<cstv-r> | \
<>:[<intr-1c> <intr-1r>]                                                       {\+CSTV}:{<DI>р}          <>:<cstv-r>

% DEVELOPMENT NOTES: <intr-2nl> was added to -ар to enable the transformation сиҥин+V+CSTV -> сиҥнэр. In many cases,
% when the causative affix is attached, the narrow vowel in the final syllable drops, reducing the verbal root to a
% monosyllable.



% 2.1.3 Reflective affixes ---------------------------------------------------------------------------------------------

% It is formed only from verbal stems (primary or derived) with transitive meaning (including causatives) [§493].
% -н after verbal stems ending in long vowel or diphthong (same form as the passive voice) [§493].
% -ын (&all) after verbal stems ending in consonant [§493].

% ABOUT DEAD forms (verbs that do not longer are used without the affix)

$refl$ = \
<>:[#trans-v# <verb-v> <tran-2j> <tran-1j>                           <aux-v>]            {\+REFL/PASS}:н  <>:<refl>  | \
<>:[#trans-c# #trans-l# <tran-j> <tran-1j> #trans-r# #cstvs# #recps# <aux-c>]            {\+REFL}:{<C>н}  <>:<refl>



% 2.1.4 Passive affixes ------------------------------------------------------------------------------------------------

% The same as reflexive, passive verbs are formed from transitive verbs and a few verbs of movement [§505].
% The passive voice is formed by affixes -н and -ылын [§505]:
% -н after verbal stems ending in long vowel or diphthong (same form as the reflexive voice).
% -ылын (&all) after verbal stems ending in consonants.

#pass-voc# = #cstvs# <refl> #recps#

$pass$ = \
<>:[#trans-v# <verb-v>                                  #moods# <aux-v>]             {\+REFL/PASS}:н      <>:<pass>   | \
<>:[#trans-c# #trans-r# <tran-1l> <tran-2l>       <tran-1j> #pass-voc# ]             {\+PASS}:{<C>л<C>н}  <>:<pass>   | \
<>:[<tran-j> <tran-l> <tran-1j> <tran-2j> <fig-j> <aux-c>              ]             {\+PASS}:{л<C>н}     <>:<pass>

% DEVELOPMENT NOTES:
% Check where to place #trans-l#



% 2.1.5 Joint-reciprocal affixes ---------------------------------------------------------------------------------------

% Reciprocal affix express reciprocal and simultaneous mutual action [§510].
% -с attaches to long vowel or diphthong ending stems.
% -ыс (&all) attaches to final consonants.
% -сыс (&all) joint-reciprocal verbs can appear in double form.

$recp$ = \
<>:[#trans-v# #intrs-v# <verb-v> <intr-j> <tran-j> <verb-j> \
    <intr-1j> <tran-1j> <intr-2j> <tran-2j> <fig-j> <recp>]                          {\+RECP}:с          <>:<recp-s> | \
<>:[#verbs-c# #verbs-j# #verbs-r# <verb-j> <tran-1l> <tran-2l> <intr-1nl> <intr-2nl> \
    <cstv-c> <cstv-r> <caus-c> <caus-r> #d-verbs-jrc# <recp> <recp-s> <refl>]               {\+RECP}:{<C>с}     <>:<recp>



% 2.2 Expressive marker ------------------------------------------------------------------------------------------------

% Affix that can be attached to any global stem (non-derivative, derivative, including complex) with a modal-emotional
% connotation of affection, pity, regret for in relation to the performer of the action or, conversely, a shade of
% humiliation, irony, annoyance, contempt for someone [§396].

$expr$ = \
<>:[#verbs-c# #verbs-j# #verbs-r# #trans-l# #intrs-nl# <verb-j> <verb-r> \
    #voices# <aux-c> <neg>]                                                        {\+DIM}:{<LO>хт<LO>} <>:<verb-v>  | \
<>:[#verbs-v# <verb-v> <aux-v> <part3-v>]                                          {\+DIM}:{хт<LO>}     <>:<verb-v>



% 2.3 Aspect markers ---------------------------------------------------------------------------------------------------

% Yakut has a developed system of forms that serve to characterize the characteristics of the course of action from
% the side of its manifestation in time and space, its amount of force, achievements and results [§518].

% These affixes can be attached to almost every verb form, primary or derived:
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
% -й denotes an abrupt increase in sound or its unexpected, sudden occurrence from onomatopoeic verbs [§565].

$aspv$ = \
<>:[#verbs# <verb-v> #voices# <verb-j>]                                      {\+ACCE\#1}:{<B><O>хт<LO>}  <>:<verb-v> | \
<>:[<fig-j>]                                                                 {\+ACCE\#1}:{х<C>с}         <>:<acce>   | \
<>:[<fig-j>]                                                                 {\+ACCE\#1}:{к<C>с}         <>:<acce>   | \
<>:[#intrs-v# #trans-v# #verbs-j# #verbs-r# #trans-l# #intrs-nl# <cstv-r> <tran-1c>]   {\+ITER\#1}:{т<O>л<LO>}     <>:<verb-v> | \
<>:[#verbs-c# #verbs-r# #verbs-j# #trans-l# #intrs-nl# <cstv-c> <refl> <pass>] {\+ITER\#1}:{<C>т<O>л<LO>}  <>:<verb-v> | \
<>:[#trans-r# #trans-l# <caus-r> <cstv-r> <recp> <verb-r>]                   {\+ITER\#2}:{т<LO>}         <>:<verb-v> | \
<>:[<tran-1c> <tran-1l> <tran-1r> <tran-2c>]                                 {\+ITER\#3}:{<O>тт<LO>}     <>:<verb-v> | \
<>:[<tran-2v>]                                                               {\+ITER\#3}:{тт<LO>}        <>:<verb-v> | \
<>:[#intrs# #trans# <recp>]                                                  {\+FREC\#1}:{<DI>л<LO>}     <>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+FREC\#2}:{<DI>кк<O>л<LO>}<>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+FREC\#2}:{<DI>к<O>л<LO>} <>:<verb-v> | \
<>:[#intrs# #trans#]                                                         {\+FREC\#3}:{<DI>хт<LO>}    <>:<verb-v> | \
<>:[#intrs# #trans# <caus-c> <cstv-c>]                                       {\+FREC\#4}:{<O>л<LO>}      <>:<verb-v> | \
<>:[#verbs-v#]                                                               {\+FREC\#5}:{к<O>л<LO>}     <>:<verb-v> | \
<>:[#verbs-c# #verbs-r# <intr-1nl>]                                          {\+FREC\#5}:{<O>кк<O>л<LO>} <>:<verb-v> | \
<>:[#verbs-c# #verbs-r# <intr-1nl>]                                          {\+FREC\#5}:{<O>к<O>л<LO>}  <>:<verb-v> | \
<>:[<intr-1c> <tran-1c> <intr-1r> <tran-1r> <intr-1nl>]                      {\+FREC\#6}:{<B><O>л<LO>}   <>:<verb-v> | \
<>:[<verb-v>]                                                                {\+SUDD\#1}:й               <>:<verb-j>

% DEVELOPMENT NOTES:
% тт<LO> was observed in тамнаа -> тамнааттаа and холбоо -> холбооттоо.
% This section is underdefined and needs to be studied in detail. This outputs to many variants in generation mode.
% Is the initial т not affected by regressive assimilation?



% 2.4 Aspect markers (figuratives) -------------------------------------------------------------------------------------

% These affixes mainly function among individual semantic groups of verbs. The following groups of forms are
% distinguished here based on their meaning [§572]:
% - movability: special dynamism or prevalence of a particular action or phenomenon [§572].
% - separative repetition: the action as a whole is represented as a series of repeated actions [§573].
% - frequentative repetition: is accelerated repetition of movement or its actions [§577].
% - slowness: indicates that the action is manifested at a slow pace [§580].

% Forms of mobility [§573]:
% Close in meaning and in some cases are used interchangeable after the same figurative root.
% -рый (&all.) more common
% -һый (&all.) more common
% -лый (&all.) less common
% -чый (&all.) less common

% с, -х, -к form an instant-single form using the suffixal-analytical method [§568].

% Accelerated for imitatives and figuratives is formed by ҥнаа (&all.).
% -ҥнаа consist of two elements -ҥ and -наа. The last is a phonetical variant of affix -лаа.
% Uniform multiplicity. These are unproductive affixes.

$aspf$ = \
<>:[<fig-j> <verb-j>]                                                  {\+FREC\#7}:{ҥн<LO>}              <>:<verb-v> | \
<>:[<fig-j> <verb-j>]                                                  {\+SUDD\#2}:с                     <>:<verb-c> | \
<>:[<fig-j>]                                                           {\+SUDD\#2}:х                     <>:<verb-c> | \
<>:[<fig-j>]                                                           {\+SUDD\#2}:к                     <>:<verb-c> | \
<>:[<fig-j>]                                                           {\+ACCE\#2}:{р<C>й}               <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ACCE\#2}:{һ<C>й}               <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ACCE\#2}:{л<C>й}               <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ACCE\#2}:{ч<C>й}               <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ITER\#4}:{лдь<C>й}             <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ITER\#5}:{рд<LO>}              <>:<verb-v> | \
<>:[<fig-j>]                                                           {\+ITER\#6}:{[хк]<O>чч<C>й}       <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ITER\#6}:{[хк]<O>ч<C>й}        <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ITER\#6}:{к<C>чч<C>й}          <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ITER\#6}:{[ҕг]<O>лдь<C>й}      <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+ITER\#6}:{г<C>лдь<C>й}         <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+FREC}:{х<C>с}                  <>:<verb-c> | \
<>:[<fig-j>]                                                           {\+FREC}:{к<C>с}                  <>:<verb-c> | \
<>:[<fig-j>]                                                           {\+SLOW\#1}:{<LO>р<C>й}           <>:<verb-j> | \
<>:[<fig-j>]                                                           {\+FREC\#8}:{ҥ<O>л<LO>}           <>:<verb-v> | \
<>:[<fig-j>]                                                           {\+FREC\#9}:{ҥ[хк]<O>л<LO>}       <>:<verb-v> | \
<>:[<fig-j>]                                                           {\+SLOW\#2}:{<LO>д<C>й}           <>:<verb-j> | \
<>:[<fig-j> <verb-j>]                                                  {\+SLOW\#3}:{<LO>[хр]<O>йд<LO>}   <>:<verb-v> | \
<>:[<fig-j>]                                                           {\+SLOW\#4}:{<LO>хт<LO>}          <>:<verb-v> | \
<>:[<fig-j>]                                                           {\+SUDD\#3}:{ҥ[хк]<O>ст<LO>}      <>:<verb-v>



% 2.5 Action-state verbal affixes --------------------------------------------------------------------------------------

% The most common affixes that form action-state verbs from other words [§378]:
% -лаа     (+VRBLZ#1) form verbals from various types of stems. Very productive [§379];
% -(ы)й    (+VRBLZ#2) from nouns and adjectives, much less often from other types of words [§384];
% -аа      (+VRBLZ#3) considered an early form of verb formation. Its productivity in modern language is fading [§385];
% -(ы)р/ар (+VRBLZ#4) forms mainly intransitive verbs expressing various processes and states [§386];
% -тый     (+VRBLZ#5) forms verbals primarly from adjectives, but also from other type of stems [§387];
% -сый     (+VRBLZ#5) forms verbals primarly from adjectives, but also from other type of stems [§387];
% -(ы)мсый (+VRBLZ#6) forms intransitive verbs from adjectives and nouns [§388];
% -(ы)рҕаа (+VRBLZ#7) forms intransitive verbs that express actions or states from nouns and adjectives [§389];
% -рый     (+VRBLZ#8) not very productive in contemporary Yakut [§390].

% Stems that can take the affix -лаа.
#g-stem-1# = #noms# <noun-dv> <adj-dc> #cards# <dt2> <ord> <appr> <int-s> <int-c> <int-v> <loc> <imi-r> <imi-2r> \
             <intj-d> <noun-dc> <adv-dc> <int-av>

$verbzv$ = \
<>:[#g-stem-1# <part5> <plur>]                                                 {\+VRBLZ\#1}:{<D2><LO>}   <>:<verb-v> | \
<>:[#noms-v#]                                                                  {\+VRBLZ\#2}:й            <>:<verb-j> | \
<>:[#noms-c# #noms-j#]                                                         {\+VRBLZ\#2}:{<C>й}       <>:<verb-j> | \
<>:[#noms-c# #noms-j#]                                                         {\+VRBLZ\#3}:{<LO>}       <>:<verb-v> | \
<>:[#noms-v#]                                                                  {\+VRBLZ\#4}:р            <>:<verb-r> | \
<>:[#noms-c# #noms-j# <noun-dc> <adj-dc>]                                      {\+VRBLZ\#4}:{<C>р}       <>:<verb-r> | \
<>:[#noms-v# <adj-dc>]                                                         {\+VRBLZ\#4a}:{<O>р}      <>:<verb-r> | \
<>:[#noms#]                                                                    {\+VRBLZ\#5}:{<D1><C>й}   <>:<verb-j> | \
<>:[#noms# #imis# <adj-dc> <noun-dc>]                                          {\+VRBLZ\#5}:{с<C>й}      <>:<verb-j> | \
<>:[#noms-v# #noms-j#]                                                         {\+VRBLZ\#6}:{мс<C>й}     <>:<verb-j> | \
<>:[#noms-c# #noms-j# <noun-dc> <poss> <adj-dc>]                               {\+VRBLZ\#6}:{<C>мс<C>й}  <>:<verb-j> | \
<>:[#noms-v#]                                                                  {\+VRBLZ\#7}:{рҕ<LO>}     <>:<verb-v> | \
<>:[#noms-c# #noms-j# <adj-dc> <imi-c> <imi-n> <imi-p> <noun-dc>]              {\+VRBLZ\#7}:{<C>рҕ<LO>}  <>:<verb-v> | \
<>:[#noms#]                                                                    {\+VRBLZ\#8}:{р<C>й}      <>:<verb-j>

% DEVELOPMENT NOTES:
% In Ubryatova et al., [§963] p. 464, there is an example of a conjugated verb formed from the proper noun 'Moscow':
% москва+N+VRBLZ1+PART_PRES -> москвалыыр. Although this may be a very rare phenomenon, it was decided to include
% proper nouns in the +VRBLZ1 stem list as well.



% 2.6 Verbal affixes from imitative stems ------------------------------------------------------------------------------

% The form with affix of imitative verbs is divided into two groups according to their meaning: [§557]
% 1) separate-multiple sound;
% 2) long lasting sound.

% Imitative verbs are formed from imitative roots with the help of various affixes [§391].
% The following affixes express certain specific shades of the meaning of these verbs:
% -ҕынаа            (+VRBLZ#9) a long sound that acts as a characteristic feature of an object or other action;
% -дьыгынаа/чыгынаа (+VRBLZ#10) the special energy of the underlying sound (rattling, murmur, rumbling, etc.);
% -кыраа            (+VRBLZ#11) an intransitive action, expressing a long, energetic and often vibrating sound;
% -(ы)гыраа         (+VRBLZ#12) a quick and uniform alternation of the same sound;
% -дьыгыраа         (+VRBLZ#13) expresses the rapid and uniform alternation of the same sound;
% -ҕаа              (+VRBLZ#14) repetition, multiplicity of sound reproduced by a monosyllabic root;
% -ырҕаа            expresses a short repetition of a fractional sound (implemented as (+VRBLZ7).
% -даа              (+VRBLZ#15) similar in meaning to (+VRBLZ14)
% -ырдаа            (+VRBLZ#15)

% The affix й in the forms (<C>)г<C>р<LO> и (<C>)г<C>н<LO> &all. appears quite rarely to express the particular
% sharpness and energy of a sound phenomenon [§565]

% -<C>л<LO> monosyllabic imitatives ending in r
% - (<C>)г<C>р<LO> &all. almost universal.
% - ҕ<C>н<LO> (г<C>н<LO>) &all. very productive.
% - дь<C>г<C>р<LO> not very productive.

% The element -дьы (-чы) in the affixes expresses a special energetic sound.
% The element -гынаа forms a verb with the meaning of an action with unspecified duration.

$imiz$ =  \
<>:[<imi-v> <imi-c>]                                                 {\+VRBLZ\#9}:{<K><C>н<LO>}         <>:<verb-v>  | \
<>:[<imi-r>]                                                         {\+VRBLZ\#10}:{дь<C>г<C>н<LO>}     <>:<verb-v>  | \
<>:[<imi-r> <imi-v>]                                                 {\+VRBLZ\#10}:{ч<C>г<C>н<LO>}      <>:<verb-v>  | \
<>:[<imi-c>]                                                         {\+VRBLZ\#11}:{к<C>р<LO>}          <>:<verb-v>  | \
<>:[<imi-v>]                                                         {\+VRBLZ\#12}:{г<C>р<LO>}          <>:<verb-v>  | \
<>:[<imi-c> <imi-p> <imi-l>]                                         {\+VRBLZ\#12}:{<C>г<C>р<LO>}       <>:<verb-v>  | \
<>:[<imi-v>]                                                         {\+VRBLZ\#13}:{ч<C>г<C>р<LO>}      <>:<verb-v>  | \
<>:[<imi-p> <imi-l> <imi-r>]                                         {\+VRBLZ\#13}:{дь<C>г<C>р<LO>}     <>:<verb-v>  | \
<>:[<imi-c>]                                                         {\+VRBLZ\#13}:{д<C>г<C>р<LO>}      <>:<verb-v>  | \
<>:[<imi-2r>]                                                        {\+VRBLZ\#14}:{ҕ<LO>}              <>:<verb-v>  | \
<>:[<imi-c>]                                                         {\+VRBLZ\#15}:{<C>рд<LO>}          <>:<verb-v>  | \
<>:[<imi-r>]                                                         {\+VRBLZ\#16}:{<C>л<LO>}           <>:<verb-v>  | \
<>:[<imi-x>]                                                         {\+VRBLZ\#16}:{<C>н<LO>}           <>:<verb-v>  | \
<>:[<imi-ov>]                                                        {\+VRBLZ\#16}:{ҕ<C>н<LO>}          <>:<verb-v>  | \
<>:[<imi-cv>]                                                        {\+VRBLZ\#16}:{г<C>н<LO>}          <>:<verb-v>  | \
<>:[<imi-n> <imi-ov> <imi-cv>]                                       {\+VRBLZ\#16}:{к<C>н<LO>}          <>:<verb-v>  | \
<>:[<imi-k>]                                                         {\+VRBLZ\#16}:{к<C>р<LO>}          <>:<verb-v>

% DEVELOPMENT NOTES:
% - +VRBLZ#9 and +VRBLZ#16 are similar.
% - ынаа (+VRBLZ#16) was added add-hoc to allow



% 3. OTHER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 3.1 Adverbialization affixes from adverbial stems --------------------------------------------------------------------

% -(ч)чы (&all) conveys an intensifying meaning [§708].
% -лыы (&all) provides an additional meaning of direction [§709].
% -тык (&all) often primary adverbs can take this affix as an intensifier.  [§710].
% -чыы (&all) frequently attaches to adverbs of manner ending in vowel [§710].
% -ын (&all) another affix that conveys the intensification of the adverb [§710].

$advza$ = \
<>:[#advs-v# <gnd2>]                                                          {\+ADVZ\#8}:{р<C>т<O>}          <>:<adv-v>

% DEVELOPMENT NOTES:
% -та/рыта (&all) conveys repetition from adverbial participles and adverbs from verbal origin [§705].
% Many indecomposable adverbs ending in -ы (-и,-у,-ү) take the affix -та, preceded by -ры [Kharitonov, adv:33].



% 3.2 Adverbs from nominal stems ---------------------------------------------------------------------------------------

% -тык (&all) forms adverbs of quality, quantity and manner from primary or derived adjectives and some adverbs [§698].
% -тык (&all) can be formed also from personal pronouns [§316].
% -лыы (&all) forms adverbs from several different nominals, including verbal nouns [§699].
% -лары (&all) from some nominal stems that act in the meaning of an adverb of time or place, and some adverbs [§700].
% -та (&all) forms adverbs with the meaning of 'x times' from numerals, and some other adjectives and adverbs [§701].
% -ыа(н) (&all) forms adverbs from cardinals. It is ofter considered as the collective from numerals [§702].
% -ын (&all) forms adverbs from ordinals and diminutive collectives [§298-§702].

% NOTE: for the affix -ыа(н), the first part -ыа is implemented as a derivation that conveys the collective from the
% numeral root (see affixes in file numerals), while the ending -н, is listed here as an adverbial derived form from
% the collective numeral.

$advzn$ = \
<>:[#nouns# #adjs# <adj-dc> <plur> <poss> <prs> #parts# <int-c> \
    <part1> <part3-c> <part1-n> #cards# <gnd2>]                                {\+ADVZ\#5}:{<D1><C>к}    <>:<adv-dc> | \
<>:[#nouns# #adjs# <adj-dv> <adj-dc> <noun-dc> #advs# <dt2> <propn-c>  \
    <int-s> <int-v> <poss> <adv-dc> <plur> <part5> <prs>]                      {\+ADVZ\#6}:{<D2><LC>}    <>:<adv-dv> | \
<>:[#nouns# #adjs# #advs# <adj-dv>]                                            {\+ADVZ\#7}:{<D2><O>р<C>} <>:<adv-dv> | \
<>:[#cards# <ord> <appr> <dist> #adjs# #advs# <adj-dc> \
    <adv-v> <gnd2> <int-s> <coll-c>]                                           {\+ADVZ\#8}:{<D1><O>}     <>:<adv-dv> | \
<>:[<ord> <coll-c>]                                                            {\+ADVZ\#9}:{<C>н}        <>:<adv-dc> | \
<>:[<coll-v>]                                                                  {\+ADVZ\#10}:н            <>:<adv-col>

% DEVELOPMENT NOTES:
% - биирдиилээн is the diminutive form of биирдии?
% эмискэ - эмискэччи



% 3.3 Adverb from verbal stems -----------------------------------------------------------------------------------------

% These affixes forms adverbs and can be considered as its distinctive morphological features [§674].

% -ы (&all) forms adverbs of manner from some causative verbs. This affix is found also in lexicalized forms [§692].
% -чы (&all) forms adverbs of manner from figurative, imitatives, and some other verbs (mostly poetic writing) [§693].
% -дыы (&all) forms adverbs of manner from nominals, participles and negative forms [§694].
% -бычча (&all) forms adverbs that serve as a basis or motive for performing another action [§695].
% -ыахча (&all) denotes an action or state that is ready to take place or is close to completion [§696].
% These last two, consist of two affixes -ыах + ча and -быт + ча.

#ind-verbs# = <tran-2l> <tran-2r> <intr-2r> <verb-r>

% -ы (&all) according to Kharitonov, it also forms adverbs from some indicative verbs [pag. 20]. It was observed in the
% testing data that this concerns verbal roots ending in р and л.

$advzv$ = \
<>:[<cstv-c> <cstv-r> <caus-c> <caus-r> #advs-c# #ind-verbs#]                  {\+ADVZ\#1}:<C>           <>:<adv-dv> | \
<>:[#verbs-v# #verbs-j# <verb-v> <verb-j> <fig-j> <pass>]                      {\+ADVZ\#2}:{чч<C>}       <>:<adv-dv> | \
<>:[#verbs-crjnl# <verb-j> <cstv-c> <caus-c>]                                  {\+ADVZ\#2}:{ч<C>}        <>:<adv-dv> | \
<>:[<part1> <part1-n> <part2> <part3-c> <part4> <neg> ]                        {\+ADVZ\#3}:{<D1><LC>}    <>:<adv-dv> | \
<>:[<part2> <part3-c> #advs-v# <adv-2c>]                                                {\+ADVZ\#4}:{ч<O>}        <>:<adv-dv>


% DEVELOPMENT NOTES:
% Although, it not stated in Ubryatova, <adv-2j> was added to +ADVZ#4 to allow




% 3. AGGREGATED DERIVATIONAL AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section aggregates the previously defined affixes and specifies which to include in the transducer by listing
% them in ('$derivational-affixes$').

$nomz$ = $nomzn$ | $nomzv$ | $adjza$ | $poss$ | $adjzn$ | $adjzv$ | $pron$ | $numz$
$voices$ = $caus$ | $cstv$ | $refl$ | $pass$ | $recp$
$verbz$ = $voices$ | $expr$ | $aspv$ | $aspf$ | $verbzv$ | $imiz$
$advz$ = $advza$ | $advzn$ | $advzv$


$derivational-affixes$ = $nomz$ | $verbz$ | $advz$
