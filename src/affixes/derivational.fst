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
% Variants -чыт and -сыт sometimes occur after vowels in parallel with the regular form -һыт [§123].

$nomzn$ = \
<>:[#noms# <part3-c> <gnd2>]                                         {\^NMLZ1}:{<H><C>т}               <>:<noun-dc>  | \
<>:[#noms#]                                                          {\^NMLZ1a}:{ч<C>т}                <>:<noun-dc>

% DEVELOPMENT NOTS:
% Affixes that convey diminutive forms, referenced in Ubryatova et al. [§156-159], are still not implemented.


% 1.2 Noun from verbs --------------------------------------------------------------------------------------------------

% Productive affixes:
% -ыы (&all) is added to verbal stems ending in consonant. It refers mostly to the name of an action [§174].
% -ааһын (&all) attaches mainly to verbal stems ending in long vowels or diphthong. Similar in meaning to -ыы [§175].
% -ааччы (&all) can be attached to any verbal stem. It has a meaning close to the active participle in Russian [§176].
% -был (&all) joins verbal stems ending in long vowel or й to denote the name of an action [§177].
% -ык (&all) forms the name of the action from verbal stems ending in consonant [§178].
% -(а)х (&all) indicates the instrument or the result of the action from verbal stems [§179].
% -лаҥ (&all) conveys the name of the action. Has a short variant: ҥ [§180].
% -лта (&all) denotes also the name of the action [§181].

$nomzv$ = \
<>:[#verbs-crjnl# #voices# <neg> <iter> <aux-c>]                               {\^NMLZ2}:{<LC>}        <>:<noun-dv>  | \
<>:[#verbs-v#     #intrs-j# #trans-j# <verb-v>]                                {\^NMLZ3}:{<LO>һ<C>н}   <>:<noun-dc>  | \
<>:[#verbs-v# #verbs-j# <verb-v>]                                              {\^NMLZ4}:{б<C>л}       <>:<noun-dc>  | \
<>:[#verbs-crjnl#]                                                             {\^NMLZ5}:{<C>к}        <>:<noun-dc>  | \
<>:[#verbs-c# #verbs-r# <verb-c> <verb-r> #trans-l# #intrs-nl#]                {\^NMLZ6}:{<O>х}        <>:<noun-dc>  | \
<>:[#verbs-v# #verbs-j# <verb-j>]                                              {\^NMLZ6}:х             <>:<noun-dc>  | \
<>:[#verbs-r# #verbs-j# #verbs-v# <verb-c>]                                    {\^NMLZ7}:{л<O>ҥ}       <>:<noun-dc>  | \
<>:[#verbs-v# <verb-v>]                                                        {\^NMLZ7}:ҥ             <>:<noun-dc>  | \
<>:[#verbs# <verb-v>]                                                          {\^NMLZ8}:{лт<O>}       <>:<noun-dv>


% 1.3 Possesive affix --------------------------------------------------------------------------------------------------

% Ubryatova lists the affix -лаах (&all) as an affix forming adjectives from several stems. Here it was decided to
% include it separately as a possessive.

$poss$ = \
<>:[#noms# #d-nouns# #propns# #parts#           \
<part1> <part2> <part3-c> <part4>               \
<plur>                                          \
<card-v> <card-c> <appr>                        \
<int-v>                                         \
<prs> <dt2> <int-c>]                                                           {\^POSS}:{<D2><LO>х}      <>:<poss>


% 1.4 Adjectives from other adjectives ---------------------------------------------------------------------------------

$adjza$ = \
<>:[#adjs# <adj-dc> <adj-dv>]                                                  {\^DIM}:{<D1><C>ҥ<C>}     <>:<adj-dv> | \
<>:[#adjs# <adj-dc> <adj-dv>]                                                  {\^DIM}:{с<DI>р}          <>:<adj-dc>


% 1.5 Adjectives from other adjectives ---------------------------------------------------------------------------------

% -(ы)мсах (&all) denotes special inclination from nominal stems. Very productive [§259].
% -мсык (&all) from personal pronouns  [§316].
% -тааҕы (&all) denotes location from noun stems, adverbs of place and adjectives of time [§260].
% -тааҕы (&all) from personal pronouns [§316].
% -гы (&all) forms adjectives of place and time [§261].

$adjzn$ = \
<>:[#nouns-v# <prs>]                                                         {\^ADJZ1}:{мс<O>х}         <>:<adj-dc>  | \
<>:[#nouns-c# <plur>]                                                        {\^ADJZ1}:{<C>мс<O>х}      <>:<adj-dc>  | \
<>:[#adjs#]                                                                  {\^ADJZ1a}:{мс<C>к}        <>:<adj-dac> | \
<>:[#nouns# #advs# <prs> <dem> <plur> <dt2> <dem> <adj-dv>]                  {\^ADJZ2}:{<D1><LO>ҕ<C>}   <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\^ADJZ3}:{г<C>}           <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\^ADJZ3}:{к<C>}           <>:<adj-dv>  | \
<>:[#advs# #nouns#]                                                          {\^ADJZ3}:{ҥ<C>}           <>:<adj-dv>


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
% -нньаҥ (&all) express the capability to perform an action from base and reflexive verbal stems. Productive [§272].
% -(ы)к (&all) from verbal stems ending in й. Not very productive [§273].
% -(ы)х (&all) from verbal stems ending in long vowel. Not very productive [§273].
% -р (&all) similar in meaning to affix -гыр. Not very productive [§274].

% About affix '-аҕас': sometimes the verb can be reconstructed only with the aid of the historical-comparative method.

$adjzv$ = \
<>:[#verbs-v#]                                                               {\^ADJZ4}:{г<O>с}           <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                           {\^ADJZ4}:{<C>г<O>с}        <>:<adj-dc> | \
<>:[#verbs# <verb-v>]                                                        {\^ADJZ5}:{<O>ҕ<O>с}        <>:<adj-dc> | \
<>:[#verbs-v#]                                                               {\^ADJZ6}:{г<O>н}           <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                           {\^ADJZ6}:{<C>г<O>н}        <>:<adj-dc> | \
<>:[#verbs-j#]                                                               {\^ADJZ7}:{ҕ<O>р}           <>:<adj-dc> | \
<>:[#verbs-j#]                                                               {\^ADJZ7}:{г<C>р}           <>:<adj-dc> | \
<>:[#verbs#]                                                                 {\^ADJZ8}:{х<O>й}           <>:<adj-dj> | \
<>:[#verbs-j#]                                                               {\^ADJZ9}:{ҕ<O>й}           <>:<adj-dj> | \
<>:[#verbs-v#]                                                               {\^ADJZ10}:{мт<O>ҕ<O>й}     <>:<adj-dj> | \
<>:[#verbs-crjnl#]                                                           {\^ADJZ10}:{<C>мт<O>ҕ<O>й}  <>:<adj-dj> | \
<>:[#verbs-crjnl#]                                                           {\^ADJZ11}:{<C>мт<DI>}      <>:<adj-dv> | \
<>:[#verbs-crjnl# <recp>]                                                    {\^ADJZ12}:{<LC>к}          <>:<adj-dc> | \
<>:[#verbs-v# <verb-v>]                                                      {\^ADJZ13}:с                <>:<adj-dc> | \
<>:[#verbs-v# <verb-v>]                                                      {\^ADJZ14}:{ннь<O>ҥ}        <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                           {\^ADJZ14}:{<C>ннь<O>ҥ}     <>:<adj-dc> | \
<>:[#verbs-v#]                                                               {\^ADJZ15}:х                <>:<adj-dc> | \
<>:[#verbs-j#]                                                               {\^ADJZ15}:к                <>:<adj-dc> | \
<>:[#verbs-crjnl#]                                                           {\^ADJZ15}:{<C>к}           <>:<adj-dc> | \
<>:[<intr-2j>]                                                               {\^ADJZ16}:р                <>:<adj-dc>


% 1.7 Adverb from verbal stems -----------------------------------------------------------------------------------------

% These affixes forms adverbs and can be considered as its distinctive morphological features [§674].

% -ы (&all) forms adverbs of manner from some causative verbs. This affix is found also in lexicalized forms [§692].
% -чы (&all) forms adverbs of manner from figurative, imitatives, and some other verbs (mostly poetic writing) [§693].
% -дыы (&all) forms adverbs of manner from nominals, participles and negative forms [§694].
% -бычча (&all) forms an action that serves as a basis or motive for performing another action [§695].
% -ыахча (&all) denote an action or state that is ready to take place or is close to completion [§696].
% These last two, consist of two affixes -ыах + ча and -быт + ча.

$advzv$ = \
<>:[<cstv-c> <cstv-r> <caus-c> <caus-r> #advs-c#]                              {\^ADVZ1}:<C>             <>:<adv-dv> | \
<>:[#verbs-v# #verbs-j# <verb-v> <fig-j>]                                      {\^ADVZ2}:{чч<C>}         <>:<adv-dv> | \
<>:[#verbs-crjnl#]                                                             {\^ADVZ2}:{ч<C>}          <>:<adv-dv> | \
<>:[<part1> <part1-n> <part2> <part3-c> <part4> <neg>]                         {\^ADVZ3}:{<D1><LC>}      <>:<adv-dv> | \
<>:[<part2> <part3-c> #advs-v#]                                                {\^ADVZ4}:{ч<O>}          <>:<adv-dv>


% 1.8 Adverbs from nominal stems ---------------------------------------------------------------------------------------

% -тык (&all) forms adverbs of quality, quantity and manner from primary or derived adjectives and some adverbs [§698].
% -тык (&all) can be formed also from personal pronouns [§316].
% -лыы (&all) from several different nominals, including verbal nouns [§699].
% -лары (&all) from some nominal stems that act in the meaning of an adverb of time or place, and some adverbs [§700].
% -та (&all) forms adverbs with the meaning of 'x times' from numerals, and some other adjectives and adverbs [§701].
% -ыа(н) (&all) forms cardinals. It is ofter considered as the collective from numerals [§702].
% -ын (&all) forms ordinals and diminutive collectives [§298-§702].

% NOTE: for the affix -ыа(н), the first part -ыа is implemented as a derivation that conveys the collective from the
% numeral root (see affixes in file numerals), while the ending -н, is listed here as an adverbial derived form from
% the collective numeral.

$advzn$ = \
<>:[#noms# #advs# #adjs# <adj-dc> <plur> <poss> <prs> <part1> <part3-c> #parts#] {\^ADVZ5}:{<D1><C>к}    <>:<adv-dc> | \
<>:[#nouns# #adjs# <adj-dv> #advs# #cards# <appr> <dt2> <propn-c> <int-s>]       {\^ADVZ6}:{<D2><LC>}    <>:<adv-dv> | \
<>:[#nouns# #adjs# #advs#]                                                       {\^ADVZ7}:{<D2><O>р<C>} <>:<adv-dv> | \
<>:[#cards# <ord> <appr> <coll-c> #adjs# #advs# <adj-dc> <adv-v> <gnd2>]         {\^ADVZ8}:{<D1><O>}     <>:<adv-dv> | \
<>:[<ord> <coll-c>]                                                              {\^ADVZ9}:{<C>н}        <>:<adv-dc> | \
<>:[<coll-v>]                                                                    {\^ADVZ10}:н            <>:<adv-col>

% DEVELOPMENT NOTES:
% - биирдиилээн is the diminutive form of биирдии?


% 1.9 Adverbialization affixes from adverbial stems --------------------------------------------------------------------

% -ыары/лык (&all) forms not productive adverbs of time, more rarely, place [§707].
% -(ч)чы (&all) conveys an intensifying meaning [§708].
% -лыы (&all) provides an additional meaning of direction [§709].
% -тык (&all) often primary adverbs can take this affix as an intensifier.  [§710].
% -чыы (&all) frequently attaches to adverbs of manner ending in vowel [§710].
% -ын (&all) another affix that conveys the intensification of the adverb [§710].

$advza$ = \
<>:[#advs#]                                                                      {\^ADVZ7}:{<DI>р<C>}    <>:<adv-c>  | \
<>:[#advs#]                                                                      {\^ADVZ11}:{л<C>к}      <>:<adv-c>  | \
<>:[#advs-v#]                                                                    {\^ADVZ12}:{р<C>}       <>:<adv-v>

% DEVELOPMENT NOTES:
% -та/рыта (&all) conveys repetition from adverbial participles and adverbs from verbal origin [§705]


% 1.10 Pronoun affixes -------------------------------------------------------------------------------------------------

$pron$ = \
<>:[<dem>]                                                                     {\^DEF}:{н<C>к}           <>:<dt1>    | \
<>:[<dem>]                                                                     {\^DEF2}:{чч<O>}          <>:<dt2>    | \
<>:[<dem>]                                                                     {\^DEF}:{к<O>}            <>:<ka-v>   | \
<>:[<dem>]                                                                     {\^DEF}:{к<O>й}           <>:<ka-c>   | \
<>:[<prs> <int-p>]                                                             {\^POSS}:{иэн}            <>:<ps>


% 1.11 Numerals from other numerals ------------------------------------------------------------------------------------

% -(ы)с (&all) forms ordinals from cardinal numerals [§294].
% -ча (&all) forms approximate numerals [§299].
% -лыы (&all) conveys a distributive meaning (implemented as an adverbial affix) [§303].
% -ыан (&all) forms the collective from the numeral [§308].

$numz$ = \
<>:[#cards#]                                                                   {\^ORD}:{<C>с}            <>:<ord>    | \
<>:[<card-v>]                                                                  {\^APPR}:{чч<O>}          <>:<appr>   | \
<>:[<card-c>]                                                                  {\^APPR}:{ч<O>}           <>:<appr>   | \
<>:[<card-v>]                                                                  {\^APPRa}:{чч<O>к<O>}     <>:<appr>   | \
<>:[<card-c>]                                                                  {\^APPRa}:{ч<O>к<O>}      <>:<appr>   | \
<>:[#cards# <int-s>]                                                           {\^COLL}:<DI>             <>:<coll-v> | \
<>:[#cards#]                                                                   {\^COLLa}:{<DI>й<O>х}     <>:<coll-c>




% 2. VERBALIZATION AFFIXES DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2.1 Action-state verbal affixes --------------------------------------------------------------------------------------

% The most common affixes that form action-state verbs from other words [§378]:
% -лаа     (^VRBLZ1) the most productive form. From several type of stems [§379];
% -(ы)й    (^VRBLZ2) from nouns and adjectives, much less often from other types of words [§384];
% -аа      (^VRBLZ3) considered an early form of verb formation. Its productivity in modern language is fading [§385];
% -(ы)р/ар (^VRBLZ4) forms mainly intransitive verbs expressing various processes and states [§386];
% -тый     (^VRBLZ5) formed primarly from adjectives, but also from other type of stems [§387];
% -сый     (^VRBLZ5) formed primarly from adjectives, but also from other type of stems [§387];
% -(ы)мсый (^VRBLZ6) intransitive verbs from adjectives and nouns [§388];
% -(ы)рҕаа (^VRBLZ7) forms intransitive verbs that express actions or states from nouns and adjectives [§389];
% -рый     (^VRBLZ8) not very productive in contemporary Yakut [§390].

% Stems that can take the affix -лаа.
#g-stem-1# = #noms# <noun-dv> <adj-dc> #cards# <dt2> <ord> <appr> <int-c> <int-v> <loc> <imi-r> <intj-d>

$verbz$ = \
<>:[#g-stem-1# #propns#]                                                       {\^VRBLZ1}:{<D2><LO>}     <>:<verb-v> | \
<>:[#noms-v#]                                                                  {\^VRBLZ2}:й              <>:<verb-j> | \
<>:[#noms-c# #noms-j#]                                                         {\^VRBLZ2}:{<C>й}         <>:<verb-j> | \
<>:[#noms-c# #noms-j#]                                                         {\^VRBLZ3}:{<LO>}         <>:<verb-v> | \
<>:[#noms-v#]                                                                  {\^VRBLZ4}:р              <>:<verb-r> | \
<>:[#noms-c# #noms-j#]                                                         {\^VRBLZ4}:{<C>р}         <>:<verb-r> | \
<>:[#noms-v# <adj-dc>]                                                         {\^VRBLZ4a}:{<O>р}        <>:<verb-r> | \
<>:[#noms#]                                                                    {\^VRBLZ5}:{<D1><C>й}     <>:<verb-j> | \
<>:[#noms# <imi-c>]                                                            {\^VRBLZ5}:{с<C>й}        <>:<verb-j> | \
<>:[#noms-v# #noms-j#]                                                         {\^VRBLZ6}:{мс<C>й}       <>:<verb-j> | \
<>:[#noms-c# #noms-j# <noun-dc> <poss>]                                        {\^VRBLZ6}:{<C>мс<C>й}    <>:<verb-j> | \
<>:[#noms-v#]                                                                  {\^VRBLZ7}:{рҕ<LO>}       <>:<verb-v> | \
<>:[#noms-c# #noms-j# <adj-dc> <imi-c>]                                        {\^VRBLZ7}:{<C>рҕ<LO>}    <>:<verb-v> | \
<>:[#noms# <fig-j>]                                                            {\^VRBLZ8}:{р<C>й}        <>:<verb-j>

% DEVELOPMENT NOTES:
% In Ubryatova et al., [§963] p. 464, there is an example of a conjugated verb formed from the proper noun 'Moscow':
% москва^PN^VRBLZ1^PART_PRES -> москвалыыр. Although this may be a very rare phenomenon, it was decided to include
% proper nouns in the ^VRBLZ1 stem list as well.


% 2.2 Verbal affixes from imitative stems ------------------------------------------------------------------------------

% Imitative verbs are formed from imitative roots with the help of various affixes [§391].
% The following affixes express certain specific shades of the meaning of these verbs:
% -ҕынаа            (^VRBLZ9) a long sound that acts as a characteristic feature of an object or other action;
% -дьыгынаа/чыгынаа (^VRBLZ10) the special energy of the underlying sound (rattling, murmur, rumbling, etc.);
% -кыраа            (^VRBLZ11) an intransitive action, expressing a long, energetic and often vibrating sound;
% -(ы)гыраа         (^VRBLZ12) a quick and uniform alternation of the same sound;
% -дьыгыраа         (^VRBLZ12) expresses the rapid and uniform alternation of the same sound;
% -ҕаа              (^VRBLZ13) repetition, multiplicity of sound reproduced by a monosyllabic root;
% -ырҕаа            expresses a short repetition of a fractional sound (implemented as (^VRBLZ7).

% The element -дьы (-чы) in the affixes expresses a special energetic sound.
% The element -гынаа forms a verb with the meaning of an action with unspecified duration.

$imiz$ =  \
<>:[<imi-v> <imi-c>]                                                   {\^VRBLZ9}:{<K><C>н<LO>}         <>:<verb-v>  | \
<>:[<imi-r>]                                                           {\^VRBLZ10}:{дь<C>г<C>н<LO>}     <>:<verb-v>  | \
<>:[<imi-r> <imi-v>]                                                   {\^VRBLZ10}:{ч<C>г<C>н<LO>}      <>:<verb-v>  | \
<>:[<imi-c>]                                                           {\^VRBLZ11}:{к<C>р<LO>}          <>:<verb-v>  | \
<>:[<imi-v>]                                                           {\^VRBLZ12}:{г<C>р<LO>}          <>:<verb-v>  | \
<>:[<imi-c>]                                                           {\^VRBLZ12}:{<C>г<C>р<LO>}       <>:<verb-v>  | \
<>:[<imi-v>]                                                           {\^VRBLZ13}:{ч<C>г<C>р<LO>}      <>:<verb-v>  | \
<>:[<imi-c>]                                                           {\^VRBLZ13}:{дь<C>г<C>р<LO>}     <>:<verb-v>  | \
<>:[<imi-c>]                                                           {\^VRBLZ13}:{д<C>г<C>р<LO>}      <>:<verb-v>  | \
<>:[<imi-r>]                                                           {\^VRBLZ14}:{ҕ<LO>}              <>:<verb-v>


% 2.3 Negation affixes -------------------------------------------------------------------------------------------------

% -ма (&all) forms the negative from verbal stems ending in vowels [§113].
% -ыма (&all) forms the negative from verbal stems ending in consonants.

$neg$ = \
<>:[#verbs-v#     <verb-v>               #moods# <aux-v>]                       {\^NEG}:{м<O>}            <>:<neg>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#         <aux-c>]                       {\^NEG}:{<C>м<O>}         <>:<neg>


% 2.4 Voice markers ----------------------------------------------------------------------------------------------------

% There are five voices in Yakut [§472]:
% 1) base: is the primary verb form (null affix) [§473].
% 2) causative: indicates mainly that the grammatical subject is not the one that is completing the action [§477].
% 3) reflexive:
% 4) passive
% 5) reciprocal

% 2.4.1 Causative affixes from transitive verbs ------------------------------------------------------------------------

% The following affixes are attached to:
% -т after long vowel- or diphthong ending stems [§481].
% -тар (&all.) attach to stems ending in consonant [§482] (PO: only monosyllabic?).
% -тар attaches to different types of living and dead roots, frequently causative and other voices [§482].
% Affixes -т and -тар are very productive in modern Yakut [§482].

$caus$ = \
<>:[#trans-v# <verb-v> <iter> <expr>]                                          {\^CAUS}:т                <>:<caus-c> | \
<>:[<tran-1c> <tran-1r> <tran-1l> <tran-1j> <tran-2c> <refl> <pass> <recp>]    {\^CAUS}:{<D1><O>р}       <>:<caus-r> | \
<>:[<tran-2r> <tran-2j> <cstv-c>]                                              {\^CAUS}:{т<O>р}          <>:<caus-r>


% 2.4.2 Causative affixes from intransitive verbs ----------------------------------------------------------------------

% Forms causative-transitive verbs from intransitives [§483].
% -т (^cstv) from intransitives ending in long vowels, й and р [§483].
% -тар (&all) attaches to a small group of monosyllabic intransitives [§484].
% -ар (&all) a reduced group of one-syllable intransitive verbs [§485].
% -ыар (&all) from one-syllable intransitive verbs [§486].

$cstv$ = \
<>:[#intrs-v# #intrs-j# <intr-2r> <intr-1r> <verb-r> <verb-j>]                 {\^CSTV}:т                <>:<cstv-c> | \
<>:[#intrs-c# #intrs-j# #intrs-r# #recps#]                                     {\^CSTV}:{<C>т}           <>:<cstv-c> | \
<>:[#intrs-nl# <intr-1c>]                                                      {\^CSTV}:{<D1><O>р}       <>:<cstv-r> | \
<>:[<intr-1c>]                                                                 {\^CSTV}:{<O>р}           <>:<cstv-r> | \
<>:[<intr-1c> <intr-1r>]                                                       {\^CSTV}:{<DI>р}          <>:<cstv-r>


% 2.4.3 Reflective affixes ---------------------------------------------------------------------------------------------

% It is formed only from verbal stems (primary or derived) with transitive meaning (including causatives) [§493].
% -н after verbal stems ending in long vowel or diphthong (same form as the passive voice) [§493].
% -ын (&all) after verbal stems ending in consonant [§493].

% ABOUT DEAD forms (verbs that do not longer are used without the affix)

$refl$ = \
<>:[#trans-v# <verb-v> <tran-2j> <tran-1j> <iter> <acce> <expr>      <aux-v>]            {\^REFL}:н       <>:<refl>  | \
<>:[#trans-c# #trans-l# <tran-j> <tran-1j> #trans-r# #cstvs# #recps# <aux-c>]            {\^REFL}:{<C>н}  <>:<refl>


% 2.4.4 Passive affixes ------------------------------------------------------------------------------------------------

% The same as reflexive, passive verbs are formed from transitive verbs and a few verbs of movement [§505].
% The passive voice is formed by affixes -н and -ылын [§505]:
% -н after verbal stems ending in long vowel or diphthong (same form as the reflexive voice).
% -ылын (&all) after verbal stems ending in consonants.

$pass$ = \
<>:[#trans-v# <verb-v>                      #moods#          <aux-v>]          {\^PASS}:н                <>:<pass>   | \
<>:[#trans-c# #trans-r# <tran-1j>                   #voices#        ]          {\^PASS}:{<C>л<C>н}       <>:<pass>   | \
<>:[<tran-j>  #trans-l# <tran-2j> <tran-1j>                  <aux-c>]          {\^PASS}:{л<C>н}          <>:<pass>

% DEVELOPMENT NOTES:
% Check where to place #trans-l#


% 2.4.5 Joint-reciprocal affixes ---------------------------------------------------------------------------------------

% Reciprocal affix express reciprocal and simultaneous mutual action [§510].
% -с attaches to long vowel or diphthong ending stems.
% -ыс (&all) attaches to final consonants.
% -сыс (&all) joint-reciprocal verbs can appear in double form.

$recp$ = \
<>:[#trans-v# #intrs-v# <verb-v> <intr-j> <tran-j> <verb-j> <iter> <expr>]             {\^RECP}:с        <>:<recp-s> | \
<>:[<intr-1j> <tran-1j> <intr-2j> <tran-2j>]                                           {\^RECP}:с        <>:<recp-s> | \
<>:[#verbs-c# #verbs-j# #verbs-r# <verb-j> <tran-1l> <intr-1nl> <cstv-c>]              {\^RECP}:{<C>с}   <>:<recp>   | \
<>:[#verbs-c# #verbs-j# #verbs-r# <verb-c> <tran-1l> <verb-j> <verb-r> <intr-1nl>]     {\^RECP2}:{с<C>с} <>:<recp-s>


% 2.5 Expressive marker ------------------------------------------------------------------------------------------------

% Affix that can be attached to any global stem (non-derivative, derivative, including complex) with a modal-emotional
% connotation of affection, pity, regret for in relation to the performer of the action or, conversely, a shade of
% humiliation, irony, annoyance, contempt for someone [§396].

$expr$ = \
<>:[#verbs-c# #verbs-j# #verbs-r# #trans-l# #intrs-nl# #voices# <aux-c>]           {\^EXPR}:{<LO>хт<LO>}   <>:<expr> | \
<>:[#verbs-v# <aux-v>]                                                             {\^EXPR}:{хт<LO>}       <>:<expr>


% 2.6 Aspect marker ----------------------------------------------------------------------------------------------------

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

$aspc$ = \
<>:[#verbs# <verb-v> #voices#]                                               {\^ACCE}:{<B><O>хт<LO>}     <>:<acce>   | \
<>:[#intrs-v# #trans-v# #verbs-j# #verbs-r# #trans-l# #intrs-nl# #voices#]   {\^ITER}:{т<O>л<LO>}        <>:<iter>   | \
<>:[#verbs-c# #verbs-r# #verbs-j# #trans-l# #intrs-nl#]                      {\^ITER}:{<C>т<O>л<LO>}     <>:<iter>   | \
<>:[#trans-r# #trans-l# <caus-r> <cstv-r>]                                   {\^ITER}:{т<LO>}            <>:<iter>   | \
<>:[<tran-1c> <tran-1l> <tran-1r> <tran-2c>]                                 {\^ITER}:{<O>тт<LO>}        <>:<iter>   | \
<>:[#intrs# #trans#]                                                         {\^ITER}:{<DI>л<LO>}        <>:<iter>   | \
<>:[#intrs# #trans#]                                                         {\^ITER}:{<DI>кк<O>л<LO>}   <>:<iter>   | \
<>:[#intrs# #trans#]                                                         {\^ITER}:{<DI>к<O>л<LO>}    <>:<iter>   | \
<>:[#intrs# #trans#]                                                         {\^ITER}:{<DI>хт<LO>}       <>:<iter>   | \
<>:[#intrs# #trans# <caus-c> <cstv-c>]                                       {\^ITER}:{<O>л<LO>}         <>:<iter>   | \
<>:[#verbs-v#]                                                               {\^ITER}:{к<O>л<LO>}        <>:<iter>   | \
<>:[#verbs-c# #verbs-r# <intr-1nl>]                                          {\^ITER}:{<O>кк<O>л<LO>}    <>:<iter>   | \
<>:[#verbs-c# #verbs-r# <intr-1nl>]                                          {\^ITER}:{<O>к<O>л<LO>}     <>:<iter>   | \
<>:[<intr-1c> <tran-1c> <intr-1r> <tran-1r> <intr-1nl>]                      {\^ITER}:{<B><O>л<LO>}      <>:<iter>

% DEVELOPMENT NOTES:
% This section is underdefined and needs to be studied in detail. This outputs to many variants in generation mode.


% 2.8 Participial affixes ----------------------------------------------------------------------------------------------

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
% -ааччы commonly performed action is also considered a secondary participle [§429].

% Kharitonov L.N. and other specialists considered ааччы to be a verbal noun or the name of an actor, as it forms nouns
% denoting the actor's name. Ubryatova E.I. interprets this affix as a participle capable of taking predicate affixes
% and denoting an action that is usually performed [Korkina E.I. Nakloneniya glagola v yakutskom yazyke. Nauka, 1970,
% p. 221].

$partz$ = \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#                <aux-c>       ]  {\^PART\_PRES}:{<O>р}          <>:<part1>   | \
<>:[#verbs-v#     <verb-v>               #aspect#                     ]  {\^PART\_PRES}:{<LC>р}         <>:<part1>   | \
<>:[#verbs#       #d-verbs#     #voices# #aspect#       #auxs#        ]  {\^NEG\^PART\_PRES}:{<B><O>т}  <>:<part1-n> | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg> #auxs#  <gnd1>]  {\^PART\_PAST}:{<B><C>т}       <>:<part2>   | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg> #auxs#        ]  {\^PART\_FUT}:{<DI>х}          <>:<part3-c> | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg> #auxs#        ]  {\^PART\_FUT}:{<DI>}           <>:<part3-v> | \
<>:[#verbs#       #d-verbs#     #voices# #aspect# <neg> <aux-c>       ]  {\^CONV\_COND}:{<D1><O>х}      <>:<part4>   | \
<>:[#verbs-crjnl#               #voices#          <neg>               ]  {\^NMLZ}:{<LO>чч<C>}           <>:<part5>   | \
<>:[#verbs-v#     <verb-v>                                            ]  {\^NMLZ}:{чч<C>}               <>:<part5>


% 2.9 Adverbial participles --------------------------------------------------------------------------------------------

% There are nine types of adverbial participles [§433]:
% -ан (&all) express relative tense in relation with the action of the main verb.
% -а/-ыы (&all)
% -ымына (&all) negative form of -ан, and -а [§450].
% -бакка (&all) negative form of -ан, and -а/-ыы. More widely used than -ымына [§455].
% -аары (&all) denotes actions, conceived as the motive of the finite verb. [§459]
% -ымаары (implemented as the neg for of -аары) negative form of -ан, and -аары [§461].
% -аат (&all) does not have a negative form [§462-463].
% -бытынан instrumental case after -быт. Used to form analytically the initial aspect of verbs [§465].
% -бычча (&all) conveys an action representing a condition present at the time of speech by the finite verb [§469].

% COMMENTS:
% The affix -бакка can considered as the combination of the negative participle and the simple dative case [§455]. The
% decision to include it here as a 'full' affix, responds to the fact that it can be followed by the plural affix, to
% form the 3 person plural, while, typically, the plural affix precedes the dative case affix.

$gndz$ =  \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#                            <aux-c>] {\^CONV1}:{<O>н}            <>:<gnd1>   | \
<>:[#verbs-v#     <verb-v>               #aspect#         <part3-v> <aux-v>] {\^CONV1}:н                 <>:<gnd1>   | \
<>:[#verbs-crjnl# <verb-c>      #voices#                            <aux-c>] {\^CONV2}:<O>               <>:<gnd2>   | \
<>:[#verbs-v#     <verb-v>      #voices# #aspect#                   <aux-v>] {\^CONV2}:<LC>              <>:<gnd2>   | \
<>:[<neg>                                                                  ] {\^CONV3}:{<C>н<O>}         <>:<gnd3>   | \
<>:[<neg>                                                                  ] {\^CONV3a}:{н<O>}           <>:<gnd3>   | \
<>:[#verbs#                                                                ] {\^NEG\^CONV4}:{б<O>кк<O>}  <>:<gnd4>   | \
<>:[#verbs-crjnl# #d-verbs-jrc# #voices#           <neg>            #auxs# ] {\^CONV5}:{<LO>р<C>}        <>:<gnd5>   | \
<>:[#verbs-v#     <verb-v>                                                 ] {\^CONV5}:{р<C>}            <>:<gnd5>   | \
<>:[#verbs#       #d-verbs#     #voices#           <neg>                   ] {\^CONV6}:{<LO>т}           <>:<gnd6>   | \
<>:[<part2>                                                                ] {\^CONV7}:{ч<O>}            <>:<gnd7>




% 3. AGGREGATED DERIVATIONAL AFFIXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section aggregates the previously defined affixes and specifies which to include in the transducer by listing
% them in ('$derivational-affixes$').

$nomz$ = $nomzn$ | $nomzv$
$adjz$ = $adjza$ | $adjzn$ | $adjzv$
$advz$ = $advzv$ | $advzn$ | $advza$
$voice$ = $caus$ | $cstv$ | $refl$ | $pass$ | $recp$

$derivational-affixes$ = \
$nomz$ | $poss$ | $adjz$ | $advz$ | $pron$ | $numz$ | \
$verbz$ | $imiz$ | $neg$ | $voice$ | $expr$ | $aspc$ | $partz$ | $gndz$