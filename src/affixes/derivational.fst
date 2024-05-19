%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Derivational affixes definitions
%  Last review:    27/03/2024

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

$nomzn$ = \
<>:[#noms# <part3-c> <gnd2> <noun-dv> <noun-dc>]                     {\^NMLZ\#1}:{<H><C>т}             <>:<noun-dc>  | \
<>:[#noms#]                                                          {\^NMLZ\#1a}:{ч<C>т}              <>:<noun-dc>  | \
<>:[#noms#]                                                          {\^DIM\#1}:{ч<C>к}                <>:<noun-dc>  | \
<>:[#noms#]                                                          {\^DIM\#2}:{к<LO>н}               <>:<noun-dc>  | \
<>:[#noms#]                                                          {\^DIM\#2}:{ч<LO>н}               <>:<noun-dc>

% DEVELOPMENT NOTS:
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
% -ааччы (&all) can be attached to any verbal stem. It has a meaning close to the active participle in Russian [§176].

% -ааччы commonly performed action is also considered a secondary participle [§429].
% Kharitonov L.N. and other specialists considered -ааччы to be a verbal noun or the name of an actor, as it forms nouns
% denoting the actor's name. Ubryatova E.I. interprets this affix as a participle capable of taking predicate affixes
% and denoting an action that is usually performed [Korkina E.I. Nakloneniya glagola v yakutskom yazyke. Nauka, 1970,
% p. 221].

$nomzv$ = \
<>:[#verbs-crjnl# #voices# <neg>      <verb-v> <aux-c>        ]              {\^NMLZ\#2}:{<LC>}        <>:<noun-dv>  | \
<>:[#verbs-v#     #intrs-j# #trans-j# <verb-v>                ]              {\^NMLZ\#3}:{<LO>һ<C>н}   <>:<noun-dc>  | \
<>:[#verbs-v# #verbs-j# <verb-v>                              ]              {\^NMLZ\#4}:{б<C>л}       <>:<noun-dc>  | \
<>:[#verbs-crjnl#                                             ]              {\^NMLZ\#5}:{<C>к}        <>:<noun-dc>  | \
<>:[#verbs-c# #verbs-r# <verb-c> <verb-r> #trans-l# #intrs-nl#]              {\^NMLZ\#6}:{<O>х}        <>:<noun-dc>  | \
<>:[#verbs-v# #verbs-j# <verb-j>                               <neg>]        {\^NMLZ\#6}:х             <>:<noun-dc>  | \
<>:[#verbs-r# #verbs-j# #verbs-v# <verb-c> <pass> <intr-2nl>  ]              {\^NMLZ\#7}:{л<O>ҥ}       <>:<noun-dc>  | \
<>:[#verbs-v# <verb-v> <fig-j> <verb-j>                       ]              {\^NMLZ\#7}:ҥ             <>:<noun-dc>  | \
<>:[#verbs# <verb-v>                                          ]              {\^NMLZ\#8}:{лт<O>}       <>:<noun-dv>  | \
<>:[#verbs-crjnl#               #voices#  <neg> <aux-c>       ]              {\^NMLZ\#9}:{<LO>чч<C>}   <>:<part5>    | \
<>:[#verbs-v#     <verb-v>                      <aux-v>       ]              {\^NMLZ\#9}:{чч<C>}       <>:<part5>



% 1.3 Adjective from several stems -------------------------------------------------------------------------------------

% -лаах (&all) forms adjectives from several types of nominal and verbal stems [§262].

$poss$ = \
<>:[#noms# #d-nouns# #propns# #parts#           \
<part1> <part2> <part3-c> <part4>               \
<plur>                                          \
<card-v> <card-c> <appr>                        \
<int-v>                                         \
<prs> <dt2> <int-c> <adj-dv>]                                                  {\^ADJZ}:{<D2><LO>х}      <>:<poss>



% 1.4 Adjectives from other adjectives ---------------------------------------------------------------------------------

$adjza$ = \
<>:[#adjs# <adj-dc> <adj-dv>]                                                  {\^DIM\#4}:{<D1><C>ҥ<C>}  <>:<adj-dv> | \
<>:[#adjs# <adj-dc> <adj-dv>]                                                  {\^DIM\#5}:{с<DI>р}       <>:<adj-dc>



% 1.5 Adjectives from other adjectives ---------------------------------------------------------------------------------

% -(ы)мсах (&all) denotes special inclination from nominal stems. Very productive [§259].
% -мсык (&all) from personal pronouns [§316].
% -тааҕы (&all) denotes location from noun stems, adverbs of place and adjectives of time [§260].
% -тааҕы (&all) from personal pronouns [§316].
% -гы (&all) forms adjectives of place and time [§261].

% The complex affix -тааҕы, forms relative adjectives from various simple and possessive nouns. As part of this affix,
% the frozen form of the local case -ta is restored.

$adjzn$ = \
<>:[#nouns-v# <prs>]                                                         {\^ADJZ\#1}:{мс<O>х}       <>:<adj-dc>  | \
<>:[#nouns-c# <plur>]                                                        {\^ADJZ\#1}:{<C>мс<O>х}    <>:<adj-dc>  | \
<>:[#adjs#]                                                                  {\^ADJZ\#1a}:{мс<C>к}      <>:<adj-dac> | \
<>:[#nouns# #advs# <prs> <dem> <plur> <dt2> <dem> <adj-dv> <int-v>]          {\^ADJZ\#2}:{<D1><LO>ҕ<C>} <>:<adj-dv>  | \
<>:[<acc-p> <case-p>]                                                        {\^ADJZ\#2}:{<LO>ҕ<C>}     <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\^ADJZ\#3}:{г<C>}         <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\^ADJZ\#3}:{к<C>}         <>:<adj-dv>  | \
<>:[#advs# #nouns# <intr-2j> <int-p>]                                        {\^ADJZ\#3}:{ҥ<C>}         <>:<adj-dv>



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

$adjzv$ = \
<>:[#verbs-v# #verbs-r#]                                                   {\^ADJZ\#4}:{г<O>с}           <>:<adj-dc> | \
<>:[#verbs-crjnl# <intr-2v>]                                               {\^ADJZ\#4}:{<C>г<O>с}        <>:<adj-dc> | \
<>:[#verbs# <verb-v>]                                                      {\^ADJZ\#5}:{<O>ҕ<O>с}        <>:<adj-dc> | \
<>:[#verbs-v#]                                                             {\^ADJZ\#6}:{г<O>н}           <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                         {\^ADJZ\#6}:{<C>г<O>н}        <>:<adj-dc> | \
<>:[#verbs-j#]                                                             {\^ADJZ\#7}:{ҕ<O>р}           <>:<adj-dc> | \
<>:[#verbs-j# <fig-j>]                                                     {\^ADJZ\#7}:{г<C>р}           <>:<adj-dc> | \
<>:[#verbs#]                                                               {\^ADJZ\#8}:{х<O>й}           <>:<adj-dj> | \
<>:[#verbs-j#]                                                             {\^ADJZ\#9}:{ҕ<O>й}           <>:<adj-dj> | \
<>:[#verbs-v#]                                                             {\^ADJZ\#10}:{мт<O>ҕ<O>й}     <>:<adj-dj> | \
<>:[#verbs-crjnl#]                                                         {\^ADJZ\#10}:{<C>мт<O>ҕ<O>й}  <>:<adj-dj> | \
<>:[#verbs-crjnl# <pass>]                                                  {\^ADJZ\#11}:{<C>мт<DI>}      <>:<adj-dv> | \
<>:[#verbs-crjnl# <recp>]                                                  {\^ADJZ\#12}:{<LC>к}          <>:<adj-dc> | \
<>:[#verbs-v# <verb-v> <fig-j>]                                            {\^ADJZ\#13}:с                <>:<adj-dc> | \
<>:[#verbs-v# <verb-v>]                                                    {\^ADJZ\#14}:{ннь<O>ҥ}        <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                         {\^ADJZ\#14}:{<C>ннь<O>ҥ}     <>:<adj-dc> | \
<>:[#verbs-v# <fig-j>]                                                     {\^ADJZ\#15}:х                <>:<adj-dc> | \
<>:[#verbs-j# <fig-j>]                                                     {\^ADJZ\#15}:к                <>:<adj-dc> | \
<>:[#verbs-crjnl# #voices#]                                                {\^ADJZ\#15}:{<C>к}           <>:<adj-dc> | \
<>:[<intr-2j>]                                                             {\^ADJZ\#16}:р                <>:<adj-dc>



% 1.7 Adverb from verbal stems -----------------------------------------------------------------------------------------

% These affixes forms adverbs and can be considered as its distinctive morphological features [§674].

% -ы (&all) forms adverbs of manner from some causative verbs. This affix is found also in lexicalized forms [§692].
% -чы (&all) forms adverbs of manner from figurative, imitatives, and some other verbs (mostly poetic writing) [§693].
% -дыы (&all) forms adverbs of manner from nominals, participles and negative forms [§694].
% -бычча (&all) forms adverbs that serve as a basis or motive for performing another action [§695].
% -ыахча (&all) denotes an action or state that is ready to take place or is close to completion [§696].
% These last two, consist of two affixes -ыах + ча and -быт + ча.

$advzv$ = \
<>:[<cstv-c> <cstv-r> <caus-c> <caus-r> #advs-c#]                              {\^ADVZ\#1}:<C>           <>:<adv-dv> | \
<>:[#verbs-v# #verbs-j# <verb-v> <fig-j> <adv-v>]                              {\^ADVZ\#2}:{чч<C>}       <>:<adv-dv> | \
<>:[#verbs-crjnl#]                                                             {\^ADVZ\#2}:{ч<C>}        <>:<adv-dv> | \
<>:[<part1> <part1-n> <part2> <part3-c> <part4> <neg>]                         {\^ADVZ\#3}:{<D1><LC>}    <>:<adv-dv> | \
<>:[<part2> <part3-c> #advs-v#]                                                {\^ADVZ\#4}:{ч<O>}        <>:<adv-dv>

% DEVELOPMENT NOTES:
% Although, it not stated in Ubryatova, <adv-v> was added to ^ADVZ2 to



% 1.8 Adverbs from nominal stems ---------------------------------------------------------------------------------------

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
<>:[#noms# #advs# #adjs# <adj-dc> <plur> <poss> <prs> #parts# <int-c> \
    <part1> <part3-c> <part1-n> #cards#]                                       {\^ADVZ\#5}:{<D1><C>к}    <>:<adv-dc> | \
<>:[#nouns# #adjs# <adj-dv> #advs# #cards# <appr> <dt2> <propn-c>  \
    <int-s> <int-v> <poss>]                                                    {\^ADVZ\#6}:{<D2><LC>}    <>:<adv-dv> | \
<>:[#nouns# #adjs# #advs#]                                                     {\^ADVZ\#7}:{<D2><O>р<C>} <>:<adv-dv> | \
<>:[#cards# <ord> <appr> <coll-c> #adjs# #advs# <adj-dc> <adv-v> <gnd2>]       {\^ADVZ\#8}:{<D1><O>}     <>:<adv-dv> | \
<>:[<ord> <coll-c>]                                                            {\^ADVZ\#9}:{<C>н}        <>:<adv-dc> | \
<>:[<coll-v>]                                                                  {\^ADVZ\#10}:н            <>:<adv-col>

% DEVELOPMENT NOTES:
% - биирдиилээн is the diminutive form of биирдии?
% эмискэ - эмискэччи



% 1.9 Adverbialization affixes from adverbial stems --------------------------------------------------------------------

% -ыары/лык (&all) forms not productive adverbs of time, more rarely, place [§707].
% -(ч)чы (&all) conveys an intensifying meaning [§708].
% -лыы (&all) provides an additional meaning of direction [§709].
% -тык (&all) often primary adverbs can take this affix as an intensifier.  [§710].
% -чыы (&all) frequently attaches to adverbs of manner ending in vowel [§710].
% -ын (&all) another affix that conveys the intensification of the adverb [§710].

$advza$ = \
<>:[#advs#]                                                                      {\^ADVZ\#7}:{<DI>р<C>}  <>:<adv-c>  | \
<>:[#advs#]                                                                      {\^ADVZ\#11}:{л<C>к}    <>:<adv-c>  | \
<>:[#advs-v#]                                                                    {\^ADVZ\#12}:{р<C>}     <>:<adv-v>

% DEVELOPMENT NOTES:
% -та/рыта (&all) conveys repetition from adverbial participles and adverbs from verbal origin [§705].



% 1.10 Pronoun affixes -------------------------------------------------------------------------------------------------

% -нык (&all) forms determinative pronouns from primary demonstratives or their emphatic variant -кa(й) [§324].
% -кa(й) (&all) affix that attaches to demonstratives pronouns to add emphasis [§322].
% -чча (&all) forms determinative pronouns from primary demonstratives or their emphatic variant -кa(й) [§325].
% -он (&all) added to personal and some interrogatives pronouns to form the possessive form [§364].

$pron$ = \
<>:[<dem>]                                                                     {\^DEF}:{н<C>к}           <>:<dt1>    | \
<>:[<dem>]                                                                     {\^DEF\#1}:{к<O>}         <>:<ka-v>   | \
<>:[<dem>]                                                                     {\^DEF\#1}:{к<O>й}        <>:<ka-c>   | \
<>:[<dem>]                                                                     {\^DEF\#2}:{чч<O>}        <>:<dt2>    | \
<>:[<prs> <int-p>]                                                             {\^POSS}:{<O>н}           <>:<ps>



% 1.11 Numerals from other numerals ------------------------------------------------------------------------------------

% -(ы)с (&all) forms ordinals from cardinal numbers [§294].
% -ча (&all) forms approximate numbers [§299].
% -лыы (&all) conveys a distributive meaning (implemented as an adverbial affix) [§303].
% -ыан (&all) forms the collective from the numeral [§308].

$numz$ = \
<>:[#cards# <int-s>]                                                           {\^ORD}:{<C>с}            <>:<ord>    | \
<>:[<card-v>]                                                                  {\^APPR\#1}:{чч<O>}       <>:<appr>   | \
<>:[<card-c>]                                                                  {\^APPR\#1}:{ч<O>}        <>:<appr>   | \
<>:[<card-v>]                                                                  {\^APPR\#2}:{чч<O>к<O>}   <>:<appr>   | \
<>:[<card-c>]                                                                  {\^APPR\#2}:{ч<O>к<O>}    <>:<appr>   | \
<>:[#cards# <int-s>]                                                           {\^COLL\#1}:<DI>          <>:<coll-v> | \
<>:[#cards#]                                                                   {\^COLL\#2}:{<DI>й<O>х}   <>:<coll-c>




% 2. VERBALIZATION AFFIXES DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2.1 Action-state verbal affixes --------------------------------------------------------------------------------------

% The most common affixes that form action-state verbs from other words [§378]:
% -лаа     (^VRBLZ1) form verbals from various types of stems. Very productive [§379];
% -(ы)й    (^VRBLZ2) from nouns and adjectives, much less often from other types of words [§384];
% -аа      (^VRBLZ3) considered an early form of verb formation. Its productivity in modern language is fading [§385];
% -(ы)р/ар (^VRBLZ4) forms mainly intransitive verbs expressing various processes and states [§386];
% -тый     (^VRBLZ5) forms verbals primarly from adjectives, but also from other type of stems [§387];
% -сый     (^VRBLZ5) forms verbals primarly from adjectives, but also from other type of stems [§387];
% -(ы)мсый (^VRBLZ6) forms intransitive verbs from adjectives and nouns [§388];
% -(ы)рҕаа (^VRBLZ7) forms intransitive verbs that express actions or states from nouns and adjectives [§389];
% -рый     (^VRBLZ8) not very productive in contemporary Yakut [§390].

% Stems that can take the affix -лаа.
#g-stem-1# = #noms# <noun-dv> <adj-dc> #cards# <dt2> <ord> <appr> <int-c> <int-v> <loc> <imi-r> <imi-2r> <intj-d> \
             <noun-dc> <adv-dc>

$verbz$ = \
<>:[#g-stem-1# #propns#]                                                       {\^VRBLZ\#1}:{<D2><LO>}   <>:<verb-v> | \
<>:[#noms-v#]                                                                  {\^VRBLZ\#2}:й            <>:<verb-j> | \
<>:[#noms-c# #noms-j#]                                                         {\^VRBLZ\#2}:{<C>й}       <>:<verb-j> | \
<>:[#noms-c# #noms-j#]                                                         {\^VRBLZ\#3}:{<LO>}       <>:<verb-v> | \
<>:[#noms-v#]                                                                  {\^VRBLZ\#4}:р            <>:<verb-r> | \
<>:[#noms-c# #noms-j#]                                                         {\^VRBLZ\#4}:{<C>р}       <>:<verb-r> | \
<>:[#noms-v# <adj-dc>]                                                         {\^VRBLZ\#4a}:{<O>р}      <>:<verb-r> | \
<>:[#noms#]                                                                    {\^VRBLZ\#5}:{<D1><C>й}   <>:<verb-j> | \
<>:[#noms# <imi-c> <adj-dc> <noun-dc>]                                         {\^VRBLZ\#5}:{с<C>й}      <>:<verb-j> | \
<>:[#noms-v# #noms-j#]                                                         {\^VRBLZ\#6}:{мс<C>й}     <>:<verb-j> | \
<>:[#noms-c# #noms-j# <noun-dc> <poss>]                                        {\^VRBLZ\#6}:{<C>мс<C>й}  <>:<verb-j> | \
<>:[#noms-v#]                                                                  {\^VRBLZ\#7}:{рҕ<LO>}     <>:<verb-v> | \
<>:[#noms-c# #noms-j# <adj-dc> <imi-c> <imi-n> <noun-dc>]                      {\^VRBLZ\#7}:{<C>рҕ<LO>}  <>:<verb-v> | \
<>:[#noms#]                                                                    {\^VRBLZ\#8}:{р<C>й}      <>:<verb-j>

% DEVELOPMENT NOTES:
% In Ubryatova et al., [§963] p. 464, there is an example of a conjugated verb formed from the proper noun 'Moscow':
% москва^PN^VRBLZ1^PART_PRES -> москвалыыр. Although this may be a very rare phenomenon, it was decided to include
% proper nouns in the ^VRBLZ1 stem list as well.



% 2.2 Verbal affixes from imitative stems ------------------------------------------------------------------------------

% The form with affix of imitative verbs is divided into two groups according to their meaning: [§557]
% 1) separate-multiple sound;
% 2) long lasting sound.

% Imitative verbs are formed from imitative roots with the help of various affixes [§391].
% The following affixes express certain specific shades of the meaning of these verbs:
% -ҕынаа            (^VRBLZ9) a long sound that acts as a characteristic feature of an object or other action;
% -дьыгынаа/чыгынаа (^VRBLZ10) the special energy of the underlying sound (rattling, murmur, rumbling, etc.);
% -кыраа            (^VRBLZ11) an intransitive action, expressing a long, energetic and often vibrating sound;
% -(ы)гыраа         (^VRBLZ12) a quick and uniform alternation of the same sound;
% -дьыгыраа         (^VRBLZ13) expresses the rapid and uniform alternation of the same sound;
% -ҕаа              (^VRBLZ14) repetition, multiplicity of sound reproduced by a monosyllabic root;
% -ырҕаа            expresses a short repetition of a fractional sound (implemented as (^VRBLZ7).
% -даа              (^VRBLZ15) similar in meaning to (^VRBLZ14)
% -ырдаа            (^VRBLZ15)

% The affix й in the forms (<C>)г<C>р<LO> и (<C>)г<C>н<LO> &all. appears quite rarely to express the particular
% sharpness and energy of a sound phenomenon [§565]

% -<C>л<LO> monosyllabic imitatives ending in r
% - (<C>)г<C>р<LO> &all. almost universal.
% - ҕ<C>н<LO> &all. very productive.
% - дь<C>г<C>р<LO> not very productive.

% The element -дьы (-чы) in the affixes expresses a special energetic sound.
% The element -гынаа forms a verb with the meaning of an action with unspecified duration.

$imiz$ =  \
<>:[<imi-v> <imi-c>]                                                 {\^VRBLZ\#9}:{<K><C>н<LO>}         <>:<verb-v>  | \
<>:[<imi-r>]                                                         {\^VRBLZ\#10}:{дь<C>г<C>н<LO>}     <>:<verb-v>  | \
<>:[<imi-r> <imi-v>]                                                 {\^VRBLZ\#10}:{ч<C>г<C>н<LO>}      <>:<verb-v>  | \
<>:[<imi-c>]                                                         {\^VRBLZ\#11}:{к<C>р<LO>}          <>:<verb-v>  | \
<>:[<imi-v>]                                                         {\^VRBLZ\#12}:{г<C>р<LO>}          <>:<verb-v>  | \
<>:[<imi-v>]                                                         {\^VRBLZ\#12}:{г<C>р<O>й}          <>:<verb-j>  | \
<>:[<imi-c> <imi-p> <imi-l>]                                         {\^VRBLZ\#12}:{<C>г<C>р<LO>}       <>:<verb-v>  | \
<>:[<imi-c> <imi-p> <imi-l>]                                         {\^VRBLZ\#12}:{<C>г<C>р<O>й}       <>:<verb-j>  | \
<>:[<imi-v>]                                                         {\^VRBLZ\#13}:{ч<C>г<C>р<LO>}      <>:<verb-v>  | \
<>:[<imi-p> <imi-l> <imi-r>]                                         {\^VRBLZ\#13}:{дь<C>г<C>р<LO>}     <>:<verb-v>  | \
<>:[<imi-c>]                                                         {\^VRBLZ\#13}:{д<C>г<C>р<LO>}      <>:<verb-v>  | \
<>:[<imi-2r>]                                                        {\^VRBLZ\#14}:{ҕ<LO>}              <>:<verb-v>  | \
<>:[<imi-c>]                                                         {\^VRBLZ\#15}:{<C>рд<LO>}          <>:<verb-v>  | \
<>:[<imi-r>]                                                         {\^VRBLZ\#16}:{<C>л<LO>}           <>:<verb-v>  | \
<>:[<imi-ov>]                                                        {\^VRBLZ\#16}:{ҕ<C>н<LO>}          <>:<verb-v>  | \
<>:[<imi-cv>]                                                        {\^VRBLZ\#16}:{г<C>н<LO>}          <>:<verb-v>  | \
<>:[<imi-cv>]                                                        {\^VRBLZ\#16}:{г<C>н<O>й}          <>:<verb-j>  | \
<>:[<imi-n> <imi-ov> <imi-cv>]                                       {\^VRBLZ\#16}:{к<C>н<LO>}          <>:<verb-v>  | \
<>:[<imi-k>]                                                         {\^VRBLZ\#16}:{к<C>р<LO>}          <>:<verb-v>



% 3. AGGREGATED DERIVATIONAL AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section aggregates the previously defined affixes and specifies which to include in the transducer by listing
% them in ('$derivational-affixes$').

$nomz$ = $nomzn$ | $nomzv$
$adjz$ = $adjza$ | $adjzn$ | $adjzv$
$advz$ = $advzv$ | $advzn$ | $advza$

$derivational-affixes$ = $nomz$ | $poss$ | $adjz$ | $advz$ | $pron$ | $numz$ | $verbz$ | $imiz$