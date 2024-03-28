%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Open-class lexical root transformations
%  Last review:    27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [D-2SC] Closed vowels deletion ---------------------------------------------------------------------------------------

% Falling closed vowels occur in stems that contain an element that has fallen out of use [§122].
% Close vowels in the final syllable of two-syllable stems are dropped in certain contexts.

% [01] Numerals like аҕыс and тоҕус when taking affixes.

$D-2SC01$ = [#closed-vowels#]:<> ^-> ҕ __ с <card-c><card-c> ( \
                                     <C>с           <ord>    | \
                                     <DI>           <coll-v> | \
                                     <DI>й<O>х      <coll-c> )
$D-2SC02$ = [#closed-vowels#]:<> ^-> [гҕлм] __ с (<noun-2c><noun-2c> | <adj-2c><adj-2c>) [#symbols#]+ \
                                 (<psor> | <psor-3> | <case-p> | <verb-v>)
$D-2SC03$ = [#closed-vowels#]:<> ^-> р __ с (<noun-2c><noun-2c> | <adj-2c><adj-2c>) [#symbols#]+ \
                                 (<psor> | <psor-3> | <case-p>)
$D-2SC04$ = [#closed-vowels#]:<> ^-> [рл]    __ н (<noun-2c><noun-2c> | <adj-2c><adj-2c>) [#symbols#]+ \
                                 (<psor> | <psor-3> | <case-p> | <acc-p> | <adj-dv> | <plur>)
$D-2SC05$ = [#closed-vowels#]:<> ^-> р       __ т <noun-2c><noun-2c>
$D-2SC06$ = [#closed-vowels#]:<> ^-> [гҕрб] __ с (<intr-2c><intr-2c> | <tran-2c><tran-2c>) ( \
                                     <O>р?        <part1>            | \
                                     <B><O>т      <part1-n>          | \
                                     <B><C>т      <part2>            | \
                                     <DI>х        <part3-c>          | \
                                     <DI>         <part3-v>          | \
                                     <C>м<O>      <neg>              | \
                                     <O>н         <gnd1>             | \
                                     <O>          <gnd2>             | \
                                     <C>л<C>н     <pass>             | \
                                     <C>?ҥ        <psor>             )          % imperative
$D-2SC07$ = [#closed-vowels#]:<> ^-> [мнҥгтлһҕ] __ н (<intr-2c><intr-2c> | <intr-2nl><intr-2nl> | <tran-2c><tran-2c>) ( \
                                     <O>р?        <part1>            | \
                                     <B><O>т      <part1-n>          | \
                                     <B><C>т      <part2>            | \
                                     <DI>х        <part3-c>          | \
                                     <DI>         <part3-v>          | \
                                     <C>м<O>      <neg>              | \
                                     <LC>         <noun-dv>          | \
                                     <O>н         <gnd1>             | \
                                     <O>          <gnd2>             | \
                                     <LO>т        <gnd6>             | \
                                     <C>ҥ         <psor>             )
$D-2SC08$ = [#closed-vowels#]:<> ^-> һ __ т (<intr-2c><intr-2c> | <tran-2c><tran-2c>) ( \
                                     <O>р?        <part1>                             | \
                                     <C>м<O>      <neg>                               | \
                                     <O>н         <gnd1>                              | \
                                     <O>          <gnd2>                              )
$D-2SC09$ = [#closed-vowels#]:<> ^-> һ __ н <tran-c><tran-c> ( \
                                     <C>ҥ         <psor>     )

% DEVELOPMENT NOTES:
% [D-2SC08] Although 'үллэһин' has more than 2 syllables, it seems to behave as a two syllabic stem.
% Example үллэһин^V+IMP+2PL -> үллэһниҥ

$D-2SC$ = $D-2SC01$ || $D-2SC02$ || $D-2SC03$ || $D-2SC04$ || $D-2SC05$ || $D-2SC06$ || $D-2SC07$ || $D-2SC08$ || $D-2SC09$


% [R-ANL] Alternation л то н -------------------------------------------------------------------------------------------

% After dropping the closed vowel in the last syllable in two-syllable stems.

% In contrast to verbals stems, it occurs as regressive assimilation in nominal roots.
% According [§117] this alternation is observed when:
% [01] the nouns илин, кэлин, алын take possessive case affixes (it was observed alse before <K><C> (adverbialization))
% [02] the noun кылын takes possessive affix. Observed in (алын^N+POSS.3 -> анна), (илин^N+POSS.3 -> иннэ).

$R-ANL01$ = л:н ^-> <begin> (и|кэ|а) __ н <noun-2c><noun-2c> [#symbols#]+ (<case-p> | <adj-dv> | <psor-3> | <plur>)
$R-ANL02$ = л:н ^-> <begin> (кы|а)__ н <noun-2c><noun-2c> [#symbols#]+ (<psor> | <psor-3>)

$R-ANL$ = $R-ANL01$ || $R-ANL02$


% [R-ARL] Alternation р - л and р - н ----------------------------------------------------------------------------------

% [01] Observed in some dead reflexive forms: силин (сиир), сөлүн (сүөр), тилин (тириэр), тулун (туур),
% тылын (тыыр), ылын (ыыр) [§119].

% In contrast to verbals stems, it occurs as regressive assimilation in nominal roots.
% [02] Observed in some two-syllable nouns before the possessive affix (сарын^N+POSS.3 -> санна) [§127]. орун^N+POSS.3SG+DAT -> оннугар
% [03] (рый-лдь) in the declension of verbs ыарый (ыарый^V^PART_PRES+1SG -> ыалдьабын) [§120].
% [04] (рыт-лдь) in the declension of verbs сырыт (сырыт^V^PART_FUT+POSS.1SG -> сылдьыаҕым) [§120].
% [05] observed in (өрүт^N+POSS.3 -> өттө).

$R-ARL02$ = р:н         ^-> <begin> (са|му|о|ха) __ н <noun-2c><noun-2c> %%%%%[#symbols#]+ (<psor> | <psor-3> | <D2><LO>х <poss>)
$R-ARL03$ = {рый}:{лдь} ^-> <begin> ыа __ <intr-2j><intr-2j> [#symbols#]+ \
                        (<part1> | <part2> | <part3-c> | <iter> | <gnd1> | <acce>)
$R-ARL04$ = {рыт}:{лдь} ^-> <begin> сы __ <intr-2c><intr-2c> [#symbols#]+ \
                        (<part1> | <part2> | <part3-c> | <part3-v> | <iter> | <gnd1> | <acce>)
$R-ARL05$ = р:т         ^-> <begin> ө __ т <noun-2c><noun-2c> %%%%[#symbols#]+ (<psor> | <psor-3>)

% $R-ARL01$ || This needs narrowed context, otherwise collides
$R-ARL$ =  $R-ARL02$ || $R-ARL03$ || $R-ARL04$ || $R-ARL05$

% DEVELOPMENT NOTES
% PROBLEM: % alternation 'р' то 'л' at stem ending (сүөр^V^REFL^PART_PAST -> сөллүбүт)


% [R-ACN] Alternation c - ннь ------------------------------------------------------------------------------------------

% The following alternations are observed in special cases:
% [01] (с-ннь) in many conjugated forms from the verbs ас, сыс, and мус (ас^V^PART_PRES+1SG -> анньабын) [§124].
% [02] (й-ннь) in the possessive forms of the nouns моой and хоой (хоой^N+POSS.2SG -> хоонньуҥ) [§124].
% [03] (рн-ннь) in the possessive forms of the nouns сүрүн and сирин (сүрүн^N+POSS.1SG -> сүнньүм) [§125].

$R-ACN01$ = с:{ннь}    ^-> <begin> (а|сы|му) __ <tran-1c><tran-1c> [#symbols#]+ \
                       (<part1> | <part3-c> | <iter> | <refl> | <recp> | <gnd1> | <gnd2> | <noun-dv>)
$R-ACN02$ = й:{ннь}    ^-> <begin> [мх] оо __ <noun-1j><noun-1j> [#symbols#]+ (<psor> | <psor-3>)
$R-ACN03$ = {рн}:{ннь} ^-> <begin> с[үи] __ <noun-2c><noun-2c> [#symbols#]+ (<psor> | <psor-3>)

$R-ACN$ = $R-ACN01$ || $R-ACN02$ || $R-ACN03$


% [R-PGA] Progressive assimilation -------------------------------------------------------------------------------------

% This set of rules apply after dropping an closed vowel in the last syllable of 2 syllable stems [D-2SC].

% [01] тн -> тт (бэтин^V^PART_PRES -> бэттэр)
% [02] лн -> лл
% [03] йн -> йд

$R-PGA01$ = н:т ^-> т __ (<intr-2nl><intr-2nl> | <intr-2c><intr-2c> | <tran-2c><tran-2c>)
$R-PGA02$ = н:л ^-> л __ (<intr-2nl><intr-2nl> | <intr-2c><intr-2c> | <tran-2c><tran-2c>)
$R-PGA03$ = н:д ^-> й __ (<intr-2nl><intr-2nl> | <intr-2c><intr-2c> | <tran-2c><tran-2c>)

$R-PGA$ = $R-PGA01$ || $R-PGA02$ || $R-PGA03$

% DEVELOPMENT NOTES:
% лс -> ст (балыс^N+POSS.1SG) Not formulated as rule [§133]


% [R-RCA] Reciprocal assimilation --------------------------------------------------------------------------------------

% [04] быһын^V^PART_PRES -> быстар [§122].

$R-RCA01$ = {бн}:{пт} ^-> __ (<intr-2nl><intr-2nl> | <tran-2c><tran-2c>)
$R-RCA02$ = {гн}:{кт} ^-> __ (<intr-2nl><intr-2nl> | <tran-2c><tran-2c>)
$R-RCA03$ = {ҕн}:{хт} ^-> __ (<intr-2nl><intr-2nl> | <tran-2c><tran-2c>)
$R-RCA04$ = {һн}:{ст} ^-> __ (<intr-2nl><intr-2nl> | <tran-2c><tran-2c> | <tran-c><tran-c>)

$R-RCA$ = $R-RCA01$ || $R-RCA02$ || $R-RCA03$ || $R-RCA04$


% [R-VUC] Devoicing ----------------------------------------------------------------------------------------------------

% The deletion of the closed consonant from the last syllable in a two-syllable words [D-2SC] can trigger the
% devoicing of the previous consonant: {б, г, ҕ, һ} to {п, к, х, с}

$R-VUC01$ = г:к ^-> __ с (<noun-2c><noun-2c> | <adj-2c><adj-2c>) (<O>р? <psor-3> | <LO> <verb-v>)
$R-VUC02$ = ҕ:х ^-> __ с (<noun-2c><noun-2c> <O>р? <psor-3> | <card-c><card-c>) ( \
                    <C>с        <ord>        | \
                    <DI>        <coll-v>     | \
                    <DI>й<O>х   <coll-c>     )
$R-VUC03$ = б:п ^-> __ с <intr-2c><intr-2c> (<LC> <noun-dv> | <C>т<O>л<LO> <iter>)
$R-VUC04$ = ҕ:х ^-> __ [ст] (<intr-2nl><intr-2nl> | <intr-2c><intr-2c> | <tran-2c><tran-2c>) %%%%%%%(<O>р? <part1> | <B><O>т <part1-n> | <B><C>т <part2> | <DI>х <part3-c> | <O>н <gnd1>)
$R-VUC05$ = һ:с ^-> __ т (<intr-2nl><intr-2nl> | <intr-2c><intr-2c> | <tran-2c><tran-2c>) %%%%%%%%%%( <O>р? <part1> | <C>?м<O> <neg>)

$R-VUC$ = $R-VUC01$ || $R-VUC02$ || $R-VUC03$ || $R-VUC04$ || $R-VUC05$


% [D-LOR] Delete long open vowel ---------------------------------------------------------------------------------------

% Must be applied before long open vowel shortening [R-LOR].

$D-LOR$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs-v#]+           ( \
                                               <LC>             <gnd2>       | \
                                               <O>ҕ<O>с         <adj-dc>     | \
                                               <LC>             <noun-dv>    | \
                                               <LO>һ<C>н        <noun-dc>    | \
                                               <O>[рл]?         <part1>      | \
                                               <LC>[рл]?        <part1>      | \
                                               <DI>             <part3-v>    | \
                                               <DI>х            <part3-c>    | \
                                               <LC>             <imp-v>      | \
                                               <DI>х            <imp-c>      )


% [R-LOR] Long open vowel shortening in primary stems ------------------------------------------------------------------

$R-LOR01$ = [#open-vowels#]:<> ^-> __ [#open-vowels#] [#verbs-v#]+ ( \
                               т <cstv-c>                          | \
                               т <caus-c>                          | \
                               н <refl>                            | \
                               н <pass>                            | \
                               с <recp-s>                          | \
                               х <noun-dc>                         | \
                               (л<O>)?ҥ <noun-dc>                  | \
                               ннь<O>ҥ <adj-dc>                    | \
                               х <adj-dc>                          | \
                               чч<C> <adv-dv>                      | \
                               б<C>л <noun-dc>                     )
$R-LOR02$ = [#open-vowels#]:<> ^-> [#open-vowels#] __ й [#noms-j#]+ <C>рҕ<LO> <verb-v>

$R-LOR$ = $R-LOR01$ || $R-LOR02$


% [R-DIP] Diphthong shortening -----------------------------------------------------------------------------------------

% Diphthong shortening seems to have many exceptions.
% Research should be conducted to formalize the rules more clearly.
% diphthongs are shortened before the affix -т, but there are unless the stem ends in <tran-1di> [§481].
% diphthongs are shortened before the reflexive affix -н like in диэ, exceptions ыа, сиэ [§493].

% [01] Applies for all forms derived from the cardinal биэс? (exception adverbs)
% [03] would reduce суол but not суос.

$R-DIP01$ = и:<>                 ^-> <begin> б __ эс <card-c><card-c>  ( \
                                 <C>с                <ord>             | \
                                 <DI>                <coll-v>          | \
                                 <DI>й<O>х           <coll-c>          )
$R-DIP02$ = ү:<>                 ^-> <begin> т __ өрт <card-c><card-c> ( \
                                 <C>с                <ord>             | \
                                 <DI>                <coll-v>          | \
                                 <DI>й<O>х           <coll-c>          )
$R-DIP03$ = [#closed-vowels#]:<> ^-> [#consonants#] __ [#open-vowels#] [#consonants#] \
                                 (<tran-1r><tran-1r> | <intr-1nl><intr-1nl>) \
                                 [#symbols#]+ (<refl> | <noun-dc> | <adj-dc>)
$R-DIP04$ = [#closed-vowels#]:<> ^-> __ [#open-vowels#] л <noun-1c><noun-1c> <LO> <verb-v>
$R-DIP05$ = [#closed-vowels#]:<> ^-> __ [#open-vowels#] <tran-1v><tran-1v> (т <caus-c> |  н <refl> | с <recp>)

$R-DIP$ = $R-DIP01$ || $R-DIP02$ || $R-DIP03$ || $R-DIP04$ || $R-DIP05$


% [D-EGL] Drop ending glide --------------------------------------------------------------------------------------------

% [02] falls facultative in one-syllabic stems ending in long vowel or diphthong [§493].
% [09] сэрэй^V^NMLZ6 -> сэрэх [§179].
% [11] figurative verbs.

$D-EGL01$ = й:<> ^-> __ (<tran-1j><tran-1j> | <tran-2j><tran-2j>) н <refl>
$D-EGL02$ = й:<> ^-> __ [#noms-j#]+ мс<C>й <verb-j>
$D-EGL03$ = й:<> ^-> __ [#verbs-j# <verb-j>]+ лт<O> <noun-dv>
$D-EGL04$ = й:<> ^-> [#open-vowels#] __ [#verbs-j# <verb-j>]+ \
                     (х <noun-dc> | (л<O>)?ҥ <noun-dc> | ҕ<O>р <adj-dc> | ҕ<O>й <adj-dj> | р <adj-dc>)
$D-EGL05$ = й:<> ^-> [#closed-vowels#] __ [#verbs-j# <verb-j>]+ (г<C>р <adj-dc> | к <adj-dc> | р <adj-dc>)
$D-EGL06$ = й:<> ^-> __ <fig-j><fig-j> р<C>й <verb-j>
$D-EGL07$ = й:<> ^-> __ [#intrs-j# <verb-j>]+ т <cstv-c>
$D-EGL08$ = й:<> ^-> __ [#verbs-j# <verb-j> <fig-j>]+ (л<C>н <pass> | с <recp> | чч<C> <adv-dv>)

$D-EGL$ = $D-EGL01$ || $D-EGL02$ || $D-EGL03$ || $D-EGL04$ || $D-EGL05$ || $D-EGL06$ || $D-EGL07$ || $D-EGL08$


% [D-EVR] Ending deletion ----------------------------------------------------------------------------------------------

% [03] before passive in stems with more than 2 syllables (оҥоһун^V^PASS -> оҥоһулун)
% [0] The suffix <C>к to have a short form к after glides? For example: толуй+ук -> толук
% [0] nasal seems to fall in two-syllable stems like тойорҕоо (but not in one-syllable дьонурҕаа

$D-EVR01$ = с:<>                    ^-> __ [#verbs-c# <recp>]+ лт<O> <noun-dv>
$D-EVR02$ = {[#closed-vowels#]й}:<> ^-> __ [<verb-j> #verbs-j#]+ \
                                    (<LO>һ<C>н <noun-dc> | <C>к <noun-dc> | х<O>й <adj-dj> | <C>н <refl>)
$D-EVR03$ = {[#closed-vowels#]н}:<> ^-> __ <tran-c><tran-c> <C>л<C>н <pass>
$D-EVR04$ = {[#closed-vowels#]р}:<> ^-> __ (<adj-c><adj-c> | <adj-dc><adj-dc>) <O>р <verb-r>
$D-EVR05$ = [#nasals#]:<>           ^-> __ (<noun-2c><noun-2c> | <adj-2c><adj-2c> | <adv-2c><adv-2c>) \
                                    (<C>мс<C>й <verb-j> | <C>рҕ<LO> <verb-v> | р<C>й <verb-j>)

$D-EVR$ = $D-EVR01$ || $D-EVR02$ || $D-EVR03$ || $D-EVR04$ || $D-EVR05$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$general-root-transformations$ = $D-2SC$ || $R-ANL$ || $R-ARL$ || $R-ACN$ || $R-PGA$ || $R-RCA$ || \
                                 $R-VUC$ || $D-LOR$ || $R-LOR$ || $R-DIP$ || $D-EGL$ || $D-EVR$