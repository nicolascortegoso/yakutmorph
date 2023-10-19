%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Viktor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Document index: 6. Phonotactics
%  Description:    Describes and applies all phonotactic rules
%  Last review:    19/10/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This section depends on morphotactics, so the file is included.
#include "5_morphotactics.fst"


% IMPORTANT: UNDER DEVELOPMENT




% 6.1 Base stem transformations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Defines the symbols that may be represented as the wildcard *
ALPHABET = [#letters#] [#stem-types#]


% Root alterations for demonstrative pronouns --------------------------------------------------------------------------

$R-DR0$ = у:а ^-> с __ бу <dem>+ [#letters#]+ [#cases# <plur> <psor>  <psor-3> <dt1> <dt2>] % for the strong form
$R-DR1$ = {бу}:{ба} ^-> __ <dem>+ чч<O> <dt2>
$R-DR2$ = {бу}:{ман} ^-> __ <dem>+ ([#letters#]+ [#cases# <psor> <psor-3> <dt1>] | <D2><O>р <plur>+ <O> <psor-3> | <D1><LO>ҕ<C> <adj-dv>)
$R-DR3$ = {ити}:{итин} ^-> __ <dem>+ (([#letters#]+ - н<O>н) [#cases# <psor> <psor-3> <dt1>] | <D2><O>р <plur>+ <O> <psor-3> | <D1><LO>ҕ<C> <adj-dv>)  % apply to all cases with the exception of ins
$R-DR4$ = л:<> ^-> о __ <dem>+ чч<O> <dt2>
$R-DR5$ = л:<> ^-> о __ <dem>+ <D2><O>р <plur> (<end> | <plur> [#letters#]+ [#cases#])
$R-DR6$ = л:н ^-> о __ <dem>+ [#letters#]+ [#cases# <psor> <psor-3> <plur> <dt1>]
$R-DR7$ = н:{нт} ^-> (ма | ити | о) __ <dem>+ ( <C>м  <psor> | <C>ҥ <psor> | <O> <psor-3> )
$R-DR8$ = н:{нт<C>} ^-> (ма | ити | о) __ <dem>+ (<B><C>т <psor> | <V><C>т <psor> | <D2><O>р <plur>)
$R-DR9$ = <dem>:{<DI><dem>} ^-> (ман | итин | он) __ <dem> <V><O> <dat> % add a diphthong before dative
$R-DR10$ = <int-p>:{<DI><int-p>} ^-> ким __ <int-p> <V><O> <dat> % add a diphthong before dative
$R-DR11$ = {бу}:{ба} ^-> __ <dem>+ <D2><O>р <plur>

$R-DR$ = $R-DR0$ || $R-DR1$ || $R-DR2$ || $R-DR3$ || $R-DR4$ || $R-DR5$ || $R-DR6$ || $R-DR7$ || $R-DR8$ || $R-DR9$ || \
         $R-DR10$ || $R-DR11$


% Root alterations for personal pronouns -------------------------------------------------------------------------------

$R-BP1$ = н:{йн} ^-> э __ <prs>+ [#letters#]+
$R-BP2$ = н:э ^-> ми __ <prs>+ <V><O> <dat>
$R-BP3$ = н:{<C>г<C>} ^-> __ <prs>+ [#letters#]+
$R-BP4$ = {г[<C>и]}:{г<C>н} ^-> __ <prs>+ (<D2><LC>н  <case-c> | <D1><LO>ҕ<O>р <case-c> | <D1><LO>ҕ<C> <adj-dv> | <D2><LO>х <poss>)
$R-BP5$ = <prs>:{<DI><prs>} ^-> эй __ <prs> <V><O> <dat>
$R-BP6$ = и:<DI> ^-> кин __ <prs>+ <V><O> <dat>
$R-BP7$ = {[и<C>]г[и<C>]}:<DI> ^-> ( эй | биһ | эһ ) __ <prs>+ <V><O> <dat>
$R-BP8$ = <C>:<> ^-> <C> <prs>+ н __ <case-v>
$R-BP9$ = {<D1><O>}:<O> ^-> кини <prs>+ <D2><O>р <plur>+ __ <case-v>
$R-BP10$ = {[и<C>]г[и<C>]}:<> ^-> __ <prs>+ иэн <ps>
$R-BP11$ = и:<> ^-> (кин | м) __ <prs>+ иэн <ps>


% Inserts an н before the adverbial affix
$R-BP12$ = <prs>:{н<prs>} ^-> __ <prs> <D2><C>к <adv-c>

$R-BP$ = $R-BP1$ || $R-BP2$ || $R-BP3$ || $R-BP4$ || $R-BP5$ || $R-BP6$ || $R-BP7$ || $R-BP8$ || $R-BP9$ || \
         $R-BP10$ || $R-BP11$ || $R-BP12$


% Root alterations for interrogative pronouns --------------------------------------------------------------------------

$R-DIP1$ = {ох}:{г} ^-> ту __ <int-a>+ ( <C> | <C>н<O>н )
$R-DIP$ = $R-DIP1$


% Passive alteration before affixes -------------------------------------------------------------------------------------

$R-PASS1$ = {<C>н}:{л<C>} ^-> л __ <pass>+ [#letters#]+
$R-PASS2$ = <C>:<> ^-> лл __ <pass>+ [#letters#]+ [<part1> <part3-c> <gnd1> <gnd4>]
$R-PASS$ = $R-PASS1$ || $R-PASS2$


% Reciprocal alteration before affixes -------------------------------------------------------------------------------------

$R-RECP1$ = {<C>с}:с ^->  [#verbs-c#] __ <recp>+ [#letters#]+ <gnd1>
$R-RECP$ = $R-RECP1$


% Postpositions --------------------------------------------------------------------------------------------------------

$R-PS01$ = {ли}:{н} ^-> __ н <noun-2c>+ [#letters#]+ [<psor> <psor-3> <case-c>]
$R-PS$ = $R-PS01$


% General base stem transformations ------------------------------------------------------------------------------------

% Deletes uvular voiced fricative
$D-CG$ = {<C>г}:<> ^-> [<B><V>] __ <O>р <case-c>


% Inserts a sibilant before affixation
$I-S$ = э:{эс} ^-> сүүрб __ <card-v>+ <C>с <ord>


% Changes negative affix form before certain affixes
$R-NEG1$ = {<C>м}:<B> ^-> __ <O> <neg>+ <D1> <part6>
$R-NEG2$ = м:<B> ^-> __ <O> <neg>+ <D1> <part6>
$R-NEG3$ = {<C>м}:<B> ^-> __ <O> <neg>+ <D1><O>х <part4>
$R-NEG4$ = м:<B> ^-> __ <O> <neg>+ <D1><O>х <part4>
$R-NEG5$ = {<C>м}:<B> ^-> __ <O> <neg>+ <D1><O>р <cond>
$R-NEG6$ = м:<B> ^-> __ <O> <neg>+ <D1><O>р <cond>
$R-NEG7$ = <O>:<> ^-> __ <neg>+ [#letters#]+ [<part3-c> <part3-v> <gnd3> <gnd4> <noun-v>]
$R-NEG$ = $R-NEG1$ || $R-NEG2$ || $R-NEG3$ || $R-NEG4$ || $R-NEG5$ || $R-NEG6$ || $R-NEG7$


% Change possessive
$R-PO01$ = {лы}:н ^-> __ н <noun-2c>+ [#letters#]+ [<psor> <psor-3>]
$R-PO02$ = {р[ыуо]}:н ^-> __ н <noun-2c>+ [#letters#]+ [<psor> <psor-3>]
$R-PO$ = $R-PO01$ || $R-PO02$


% Invert order in reciprocal before certain affixes
$R-RECP1$ = {<C>с}:{с<C>} ^-> __ <recp>+ [#letters#]+ <part2>
$R-RECP$ = $R-RECP1$


% Prevent regressive assimilation in voice affixes
$R-VO01$ = {<C>н}:<D1> ^-> [<tran-1c> <tran-1l> <tran-1aj>]+ __ <refl>+ [#letters#]+ [^<part3-v>]   % The future ending in vowel is excluded
$R-VO02$ = {<C>с}:с ^-> [<tran-1c> <tran-1l> <tran-1r>]+ __ <recp>+ [#letters#]+
$R-VO$ = $R-VO01$ || $R-VO02$


% Deletes open vowel in negative before certain affixes
$D-OP1$ = <O>:<> ^-> __ <neg>+ [#letters#]+ [<part3-v> <part3-c>]
$D-OP2$ = <O>:<> ^-> __ <neg>+ <LC>һ<C> <cert>
$D-OP3$ = <O>:<> ^-> __ <neg>+ <LO>р<O>й <will>
$D-OP$ = $D-OP1$ || $D-OP2$ || $D-OP3$


% Deletes final vowel in cardinals
$D-V$ = [#vowels#]:<> ^-> __ <card-v>+ <C>с <ord>


% Deletes closed vowels in two syllables stems when an affix in attached
$D-2SC1$ = [#closed-vowels#]:<> ^-> [#consonants#] __ [#consonants#] [<intr-2c> <tran-2c>]+ <C>с <recp>
$D-2SC2$ = [#closed-vowels#]:<> ^-> ([#consonants#] - й) __ [ст] [#noms-c#]+ <LO> <verb-v>
$D-2SC3$ = [#closed-vowels#]:<> ^-> [#consonants#] __ т [#verbs#]+ <C>г<O>н <adj-dc>                                    % special for иһит
$D-2SC4$ = [#closed-vowels#]:<> ^-> м __ н [#verbs#]+ <C>г<O>н <adj-dc>                                                 % special for умнуган
$D-2SC5$ = [#closed-vowels#]:<> ^-> [#consonants#] __ с <card-c>+ <C>с <ord>
$D-2SC6$ = [#closed-vowels#]:<> ^-> ([#consonants#] - [скй]) __ [стн] [<intr-2c> <tran-2c> <intr-2n> <adj-2c>]+ [#letters#]+ [<part1> <part2> <part3-c> <part3-v> <gnd1> <gnd2> #d-verbs# <caus-c> <caus-r> <recp> <refl> <noun-v> <iter> <psor-3> <case-c>]
$D-2SC7$ = [#closed-vowels#]:<> ^-> [^ь] __ т <noun-2c>+ [#letters#]+ [<psor-3> <case-c>]                               % үрүт -> үрдэ
$D-2SC$ = $D-2SC1$ || $D-2SC2$ || $D-2SC3$ || $D-2SC4$ || $D-2SC5$ || $D-2SC6$ || $D-2SC7$


% Deletes closed vowels in two syllables stems when an affix in attached
$D-C1$ = [#closed-vowels#]:<> ^-> [#closed-vowels#] __ [#noms-v#]+ й <verb-j>
$D-C$ = $D-C1$


% Devoices velar-uvular fricative before voiceless dental alveolar fricative
$R-VC1$ = г:к ^-> __ с [<noun-2c> <adj-2c>]+ [#letters#]+ [<verb-v> <psor-3>]
$R-VC2$ = г:к ^-> __ н [<intr-2n>]+ [#letters#]+ <part1>
$R-VC3$ = ҕ:х ^-> __ с [<intr-2c> <tran-2c> <card-c>]+ <C>с [<recp> <ord>]
$R-VC4$ = ҕ:х ^-> __ [нст] [<intr-2c> <tran-2c> <intr-2n> <noun-2c>]+ [#letters#]+ [#participle# #d-verbs# #voices# <gnd1> <gnd2> <psor-3> <noun-v>]
$R-VC5$ = һ:с ^-> __ [нт] [<intr-2c><tran-2c>]+ [#letters#]+ [#participle# <recp> <noun-v>]
$R-VC6$ = р:л ^-> __ т [<intr-2c><tran-2c>]+ <C>с <recp>
$R-VC7$ = һ:с ^-> __ т [#verbs#]+ <C>г<O>н <adj-dc>
$R-VC8$ = б:п ^-> __ [ст] [#verbs#]+ [#letters#]+ [<noun-v> <iter>]
$R-DEVOICE$ = $R-VC1$ || $R-VC2$ || $R-VC3$ || $R-VC4$ || $R-VC5$ || $R-VC6$ || $R-VC7$ || $R-VC8$


$R-CC1$ = н:т ^-> [хкст] __ [<intr-2c> <intr-2n> <tran-2c>]+
$R-CC2$ = н:д ^-> й __ [<tran-1aj> <intr-2n> <tran-2c>]+
$R-CC3$ = н:л ^-> л __ [<intr-2n>]+
$change-consonant$ =  $R-CC1$ || $R-CC2$ || $R-CC3$


% Insert close vowel between affixes
$I-C1$ = <B>:{<C>б} ^-> <part6>+ __ <C>т <psor>
$I-C2$ = <V>:{<C>г} ^-> <part6>+ __ <C>т <psor>
$I-C3$ = <D2>:{<C>л} ^-> <part6>+ __ <O>р <plur>
$I-C4$ = <D1>:{л<C>} ^-> л <tran-1l>+ __ <refl>+ [#letters#]+ [<part1> <part2>]
$I-C5$ = {н}:{л<C>} ^-> л __ <intr-2n>+ <B><C>т <part2>
$I-C6$ = <D1>:{<D1><C>} ^-> __ <refl>+ <B><C>т <part2>
$I-C7$ = <D1>:{<D1><C>} ^-> __ <refl>+ <B><C>т <part2>
$I-C8$ = д:{д<C>} ^-> __ [<intr-2n> <tran-2c>]+ <B><C>т <part2>
$I-C9$ = л:{л<C>} ^-> л __ <intr-2n>+ <B><C>т <part2>
$I-C10$ = с:{с<C>} ^-> х __ <tran-2c>+ <B><C>т <part2>
$I-C11$ = с:{с<C>} ^-> х __ <intr-2c>+ <B><O>т <part1>
$I-C$ = $I-C1$ || $I-C2$ || $I-C3$ || $I-C4$ || $I-C5$ || $I-C6$ || $I-C7$ || $I-C8$ || $I-C9$ || $I-C10$ || $I-C11$


% Shortens diphthong
$R-DI1$ = [#closed-vowels#]:<> ^-> __ [#open-vowels#] [#consonants#] [<intr-1cov> <intr-1lov>]+ <O>р <cstv-r>
$R-DI2$ = [#closed-vowels#]:<> ^-> __ [#open-vowels#] <tran-1di2>+ <D1> <caus-c>
$R-DI3$ = [#closed-vowels#]:<> ^-> __ [#open-vowels#] <tran-1di2>+ н [<refl> <pass>]
$R-DI4$ = [#closed-vowels#]:<> ^-> __ [#open-vowels#] <tran-1di2>+ с <recp>
$R-DI5$ = [#closed-vowels#]:<> ^-> [#consonants#] __ [#open-vowels#] [лн] [<noun-1c> <adj-1c>]+ <LO> <verb-v>
$R-DI6$ = [#closed-vowels#]:<> ^-> [#consonants#] __ [#open-vowels#] [#consonants#]+ <card-c>+ <C>с <ord>
$R-DI7$ = <C>:<> ^-> __ <pass>+ <DI> (х <part3-c> | <part3-v>)                                                          % FUTURE PART
$R-DI8$ = <C>:<> ^-> __ <pass>+ <LO>чч<C> <part5>+                                                                      % FUTURE PART
$R-DI9$ = и:<> ^-> б __ эс <card-c>+ [#letters#]+
$R-DI$ = $R-DI1$ || $R-DI2$ || $R-DI3$ || $R-DI4$ || $R-DI5$ || $R-DI6$ || $R-DI7$ || $R-DI8$ || $R-DI9$


% Shortens long open vowel
$R-LO1$ = [#vowels#]:<> ^-> __ [#vowels#] [#intr-v# #tran-v#]+ <D1> [<cstv-c> <caus-c>]
$R-LO2$ = [#vowels#]:<> ^-> __ [#vowels#] [#tran-v#]+ н [<pass> <refl>]
$R-LO3$ = [#vowels#]:<> ^-> __ [#vowels#] [#tran-v# #intr-v#]+ с <recp>
$R-LO4$ = [#vowels#]:<> ^-> __ [#vowels#] [#verbs-v#]+ [схр] <adj-dc>
$R-LO5$ = [#vowels#]:<> ^-> __ [#vowels#] [#verbs-v#]+ ннь<O>ҥ <adj-dc>
$R-LO6$ = <LO>:<O> ^-> __ [<verb-v> <tran-3v> <iter>]+ <D1> [<cstv-c> <caus-c>]
$R-LO7$ = <LO>:<O> ^-> __ [<tran-3v> <verb-v> <iter>]+ н [<pass> <refl>]
$R-LO8$ = <LO>:<O> ^-> __ [<verb-v> <iter>]+ с <recp>
$R-LO9$ = <LO>:<O> ^-> __ [<verb-v>]+ [схр] <adj-dc>
$R-LO10$ = <LO>:<O> ^-> __ [<verb-v>]+ ннь<O>ҥ <adj-dc>
$R-LO$ = $R-LO1$ || $R-LO2$ || $R-LO3$ || $R-LO4$ || $R-LO5$ || $R-LO6$ || $R-LO7$ || $R-LO8$ || $R-LO9$ || $R-LO10$


% Deletes long open vowels
$D-LO1$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs#]+ <O>ҕ<O>с <adj-dc>
$D-LO2$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs#]+ <LO>һ<C>н <noun-c>
$D-LO3$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs#]+ <LO>чч<C> <noun-v>
$D-LO4$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs#]+ <LC>р <part1>
$D-LO5$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs#]+ <DI> (х <part3-c> | <part3-v>)
$D-LO6$ = {[#open-vowels#] [#open-vowels#]}:<> ^-> __ [#verbs#]+ <LC> <gnd2>
$D-LO7$ = <LO>:<> ^-> __ [#verbs#]+ <O>ҕ<O>с <adj-dc>
$D-LO8$ = <LO>:<> ^-> __ [#verbs# <verb-v>]+ <LO>һ<C>н <noun-c>
$D-LO9$ = <LO>:<> ^-> __ [#verbs#]+ <LO>чч<C> <noun-v>
$D-LO10$ = <LO>:<> ^-> __ [<verb-v> <acce> <iter>]+ <LC>р <part1>
$D-LO11$ = <LO>:<> ^-> __ <verb-v>+ <DI>х <part3-c>
$D-LO12$ = <LO>:<> ^-> __ [#verbs#]+ <LC> <gnd2>
$D-LO$ = $D-LO1$ || $D-LO2$ || $D-LO3$ || $D-LO4$ || $D-LO5$ || $D-LO6$ || $D-LO7$ || $D-LO8$ || $D-LO9$ || \
         $D-LO10$ || $D-LO11$ || $D-LO12$


% Deletes ending glide
$D-G1$ = й:<> ^-> __ [<intr-3j> <intr-2j> <intr-2yj>]+ <D1> <cstv-c>
$D-G2$ = й:<> ^-> __ [<tran-j> <tran-2j> <tran-1dij> <tran-2aj>]+ л<C>н <pass>
$D-G3$ = й:<> ^-> __ [<tran-j> <tran-2j> <tran-1dij> <tran-1lcj>]+ н <refl> % should act upon derived forms
$D-G4$ = й:<> ^-> __ [<verb-j> #verb3-j# #verb2-j# #verb-1aj#]+ с <recp>
$D-G5$ = й:<> ^-> __ [#intr-aj# #tran-aj#]+ ҕ<O>р <adj-dc>
$D-G6$ = й:<> ^-> __ [#intr-yj# #tran-yj#]+ г<C>р <adj-dc>
$D-G7$ = й:<> ^-> __ [#verb-j#]+ ҕ<O>й <adj-dj>
$D-G8$ = й:<> ^-> __ [#verb-j#]+ [кр] <adj-dc>
$D-G$ = $D-G1$ || $D-G2$ || $D-G3$ || $D-G4$ || $D-G5$ || $D-G6$ || $D-G7$ || $D-G8$


% Deletes both ending glide and previous closed vowel
$D-GC$ = {[#closed-vowels#] й}:<> ^-> __ [#verbs#]+ х<O>й <adj-dj>


% Deletes ending nasal
$D-N1$ = н:<> ^-> __ [#adjs#]+ мс<C>к <adj-dac>
$D-N$ = $D-N1$


% Special case will (must be before D-R)
$R-ROVJ$ = {р<O>й}:{й<O>р} ^-> [#verbals# <refl> <neg> <caus-r>]+ <LO>? __ <will>+ [#letters#]+ [<predsg> <predpl> <plur>]


% Modifies participles 1
$D-R1$ = р:<> ^-> [#consonants#] [#verbals# #voices#]+ <O> __ <part1>+ [#letters#]+ [<predsg> <predpl>]
$D-R2$ = р:<> ^-> __ <part1>+ [#letters#]+ [<predsg> <predpl>]
$D-R3$ = р:<> ^-> [#verbals# <refl> <neg> <caus-r>]+ <LO>? й <O>__ <will>+ [#letters#]+ [<predsg> <predpl>]
$D-R$ = $D-R1$ || $D-R2$ || $D-R3$


% Modifies participles 2
$R-R1$ = р:л ^-> [#consonants#] [#verbals# #voices#]+ <O> __ <part1>+ <D2><O>р <plur>
$R-R2$ = р:л ^-> [#consonants#] [#verbals# #voices# <acce>]+ <LC> __ <part1>+ <D2><O>р <plur>
$R-R3$ = р:л ^-> <D1><O> __ <cond>+ <D2><O>р <plur>
$R-R4$ = р:л ^-> <LO>? й<O> __ <will>+ <D2><O>р <plur>
$R-R5$ = т:ч ^-> __ <part2>+ [#letters#]+ <gnd6>
$R-RL$ = $R-R1$ || $R-R2$ || $R-R3$ || $R-R4$ || $R-R5$


% Modifies affix <D1><C>й
$R-DA1$ = <D1>:с ^-> [хмҥр] [<nom-3c> <nom-2c>]+ __ <C>й <verb-j>


% Modifies stem when ар and byt is attached (it works as pregressive assimilation inside the root)
$R-RYJ1$ = {рый}:{лдь} ^-> __ [<intr-2yj>]+ [#letters#]+ [<part1> <part2> <part3-c> <part5>]
$R-RYJ2$ = {рыт}:{лдь} ^-> __ [<intr-2c>]+ [#letters#]+ [<part1> <part2> <part3-c>]
$R-RYJ$ = $R-RYJ1$ || $R-RYJ2$


% Special roots
$R-ROOT1$ = с:{ннь} ^-> [^и] __ [<intr-1c> <tran-1c>]+ [#letters#]+ [<part1> <pass>]
$R-ROOT2$ = й:{ннь} ^-> оо __ <noun-1c>+ [#letters#]+ [<psor> <psor-3>]
$R-ROOT3$ = {р[үи]н}:{ннь} ^-> с[үи] __ <noun-2c>+ [#letters#]+ [<psor> <psor-3>]
$R-ROOT$ = $R-ROOT1$ || $R-ROOT2$ || $R-ROOT3$


% Inserts vowels when byt is attached
$I-CBYT$ = {лдь}:{лдь<C>} ^-> __ [<intr-2c> <intr-2yj>]+ <B><C>т <part2>


% Miscellaneous
$D-T$ = <D1>:<> ^-> <tran-1c>+ __ <O>р <caus-r>
$R-YS$ = {<C>с}:с ^-> [лрx] [#verbs#]+ __ <recp>+ [#letters#]+ [<part1> <part3-c> <gnd4>]
$I-SOFT$ = д:{дь} ^-> л __ <intr-2c>+ <O>р <part1>
$D-SOFT$ = ь:<> ^-> __ [#stem-types#]+ [#letters#]+


% Since rules are applied in cascade, the order is important
$ALTER-PRON$ = $R-DR$ || $R-BP$ || $R-DIP$
$ALTER$ = $R-PO$ || $R-RECP$ || $ALTER-PRON$ || $R-ROOT$ || $R-PS$ || $R-RYJ$ || $I-CBYT$ || $R-ROVJ$                             %    %%%%|| $D-T$
$BPREMOD1$ = $D-CG$ || $I-S$ || $R-NEG$ || $R-VO$ || $D-2SC$ || $R-DEVOICE$ || $change-consonant$ || $I-C$
$BPREMOD2$ = $D-LO$ || $D-R$ || $R-RL$ || $R-LO$ || $R-DI$ || $D-G$
$base-pre-modifications$ = $ALTER$ || $BPREMOD1$ || $BPREMOD2$ || $I-SOFT$ || $R-PASS$ || $R-RECP$ %|| $D-SOFT$



% 6.2 Progressive assimilation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$PAT00$ = <D1>:т ^-> [#stem-types#]+ __ [#stem-types#][<end>]
$PAT01$ = <D1>:н ^-> г [<C>и] [<prs>]+ __ <O> <case-v>
$PAT02$ = <D1>:т ^-> [#vowels# #unvoiced-stops# сх] [#stem-types#]+ __
$PAT03$ = <D1>:л ^-> л [#stem-types#]+ __
$PAT04$ = <D1>:д ^-> [йр] [#stem-types#]+ __
$PAT05$ = <D1>:н ^-> [#nasals#] [#stem-types#]+ __
$PAT$ = $PAT00$ || $PAT01$ || $PAT02$ || $PAT03$ || $PAT04$ || $PAT05$

$PAL01$ = <D2>:н ^-> кки [<prs>]+ __ [#letters#]+ <case-c>
$PAL02$ = <D2>:л ^-> [#vowels# л] [#stem-types#]+ __
$PAL03$ = <D2>:т ^-> [#unvoiced-stops# сх жзчвц] [#stem-types#]+ __
$PAL04$ = <D2>:д ^-> [йр] [#stem-types#]+ __
$PAL05$ = <D2>:н ^-> [#nasals#] [#stem-types#]+ __
$PAL$ = $PAL01$ || $PAL02$ || $PAL03$ || $PAL04$ || $PAL05$

$PAG01$ = <V>:х ^-> (иэ | [<DI> х]) [#stem-types#]+ __
$PAG02$ = <V>:ҕ ^-> [#open-vowels#] [#stem-types#]+ __
$PAG03$ = <V>:г ^-> [#closed-vowels# лйр] [#stem-types#]+ __
$PAG04$ = <V>:к ^-> [#stops# сжз] [#stem-types#]+ __
$PAG05$ = <V>:ҥ ^-> [#nasals#] [#stem-types#]+ __
$PAG$ = $PAG01$ || $PAG02$ || $PAG03$ || $PAG04$ || $PAG05$

$PAB01$ = <B>:б ^-> [#vowels# йрл] [#stem-types#]+ __
$PAB02$ = <B>:п ^-> [#unvoiced-stops# сх] [#stem-types#]+ __
$PAB03$ = <B>:м ^-> [#nasals#] [#stem-types#]+ __
$PAB$ = $PAB01$ || $PAB02$ || $PAB03$

$PAH01$ = <H>:һ ^-> [#vowels#] [#stem-types#]+ __
$PAH02$ = <H>:с ^-> [кх] [#stem-types#]+ __
$PAH03$ = <H>:ч ^-> [#unvoiced-stops# сх] [#stem-types#]+ __
$PAH04$ = <H>:{дь} ^-> [лйр] [#stem-types#]+ __
$PAH05$ = <H>:{нь} ^-> [#nasals#] [#stem-types#]+ __
$PAH$ = $PAH01$ || $PAH02$ || $PAH03$ || $PAH04$ || $PAH05$

$PAK01$ = <K>:г ^-> [#vowels# #unvoiced-stops# лйрх] [#stem-types#]+ __
$PAK02$ = <K>:к ^-> [с] [#stem-types#]+ __
$PAK03$ = <K>:ҥ ^-> [#nasals#] [#stem-types#]+ __
$PAK$ = $PAK01$ || $PAK02$ || $PAK03$

$progressive-assimilation$ = $PAT$ || $PAL$ || $PAB$ || $PAH$ || $PAK$ || $PAG$



% 6.3 Regressive assimilation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Voiceless consonants changes to it voiced pair at the end of a stem before an affix beginning with a vowel
$RA01$ = п:б ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$RA02$ = к:г ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$RA03$ = х:ҕ ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$RA04$ = с:һ ^-> [#vowels#] [#stem-types#]* __ [#stem-types#]+ [#vowels#]       % [^һ]  checks when reapeated
$RA05$ = т:д ^-> [рл] __ [#stem-types#]+ [#vowels#]+
$RA06$ = н:м ^-> [#vowels#] [#stem-types#]* __ [#stem-types#]+ м
$RA07$ = ҥ:м ^-> [#vowels#] __ [#stem-types#]+ м
$RA08$ = н:ҥ ^-> [#vowels#] __ [#stem-types#]+ ҥ
$RA09$ = т:п ^-> [#vowels# <neg> <tran-2v> <tran-3v>] __ [#stem-types#]+ п
$RA10$ = т:к ^-> [#vowels# <neg>] __ [#stem-types#]+ к
$regressive-assimilation$ = $RA01$ || $RA02$ || $RA03$ || $RA04$ || $RA05$ || $RA06$ || $RA07$ || $RA08$ || $RA09$ || \
                            $RA10$



% 6.4 Vowel harmony %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$BVH1$ = <O>:а ^-> ([#back-unrounded-vowels# <A>] .*) | (у .* ) | (о .* [<LC><C><DI>] .* ) __
$BVH2$ = <O>:э ^-> ([#front-unrounded-vowels#] .*) | (ө .* [<LC><C><DI>] .*) | (ү .*) __
$BVH3$ = <O>:о ^-> [#back-rounded-vowels#] .* __
$BVH4$ = <O>:ө ^-> [#front-rounded-vowels#] .*  __
$BVH5$ = <LO>:{аа} ^-> ([#back-unrounded-vowels# <A>] .*) | (у .* ) | (о .* [<LC><C><DI>] .* ) __
$BVH6$ = <LO>:{ээ} ^-> ([#front-unrounded-vowels#] .*) | (ө .* [<LC><C><DI>] .*) | (ү .*) __
$BVH7$ = <LO>:{оо} ^-> [#back-rounded-vowels#] .* __
$BVH8$ = <LO>:{өө} ^-> [#front-rounded-vowels#] .*  __
$back-harmony$ = $BVH1$ || $BVH2$ || $BVH3$ || $BVH4$ || $BVH5$ || $BVH6$ || $BVH7$ || $BVH8$

$FVH1$ = <C>:ы ^-> ([#back-unrounded-vowels# е] .* | и .* о .*) __
$FVH2$ = <C>:и ^-> [#front-unrounded-vowels#] .* __
$FVH3$ = <C>:у ^-> ([#back-rounded-vowels#] .* | ю .*) __
$FVH4$ = <C>:ү ^-> [#front-rounded-vowels#] .* __
$FVH5$ = <LC>:{ыы} ^-> ([#back-unrounded-vowels# е] .* | и .* о .*) __
$FVH6$ = <LC>:{ии} ^-> [#front-unrounded-vowels#] .* __
$FVH7$ = <LC>:{уу} ^-> ([#back-rounded-vowels#] .* | ю .*) __
$FVH8$ = <LC>:{үү} ^-> [#front-rounded-vowels#] .* __
$front-harmony$ = $FVH1$ || $FVH2$ || $FVH3$ || $FVH4$ || $FVH5$ || $FVH6$ || $FVH7$ || $FVH8$

$DVH1$ = <DI>:{ыа} ^-> [ыа] .* __
$DVH2$ = <DI>:{иэ} ^-> [иэ] .* __
$DVH3$ = <DI>:{уо} ^-> [уо] .* __
$DVH4$ = <DI>:{үө} ^-> [үө] .* __
$diphthong-harmony$ = $DVH1$ || $DVH2$ || $DVH3$ || $DVH4$

$vowel-harmony$ = $back-harmony$ || $front-harmony$ || $diphthong-harmony$



% 6.5 Special cases and exceptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$=FBV$ = [эө]
$long-vowels$ = $=FBV$ $=FBV$

% Eliminates diphtongs
$D-DI$ = {иэ}:<> => __ [<tran-1di1> <tran-1di2>]+ <LC>р <part-1>

% Restitutes diphthongs
$EX01$ = а:{ыа} => __ <tran-v>+ т <caus>
$EX02$ = э:{иэ} => __ <tran-v>+ т <caus>

% Deletes final letter if gets an affixes
$EX03$ = п:<> ^-> хаам __ <intr-1c>+ [#letters#]+ [#stem-types#]
% Shortens diphthong
$EX04$ = и:<> ^-> д __ э <verb1-v>+ с <recp>

% Replaces velar-uvular voiced fricative for velar-uvular voiced stop after trill
$VUFS1$ = ҕ:г ^-> р __ $long-vowels$ <verb-v>
$VUFS2$ = ҕ:г ^-> р __ [эө] <verb-v>+ т [<cstv-c> <cstv-r>]
$VUFS3$ = ҕ:г ^-> р __ [эө] <verb-v>+ н [<refl> <pass>]
$VUFS$ = $VUFS1$ || $VUFS2$

$R-XK$ = х:к ^-> [#verbs#] __ эй <adj-dj>

$exceptions$ = $EX03$

$post-harmony-alterations$ = $VUFS$ || $R-XK$ || $exceptions$

% Replaces first pharyngeal after attaching a second
$R-H1$ = һ:с ^-> __ [#vowels#] [#stem-types#]+ һ
$R-H2$ = һ:с ^-> __ [#stem-types#]+ [#vowels#] һ
$R-H$ = $R-H1$ || $R-H2$

$post-alterations$ = $post-harmony-alterations$ || $R-H$



% 6.6 Apply rules %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Delete base types from the surface representation
ALPHABET = [#letters#] [#stem-types#]:<> <A>:<>
$delete-base-types$ = .*

$consonant-assimilation$ = $progressive-assimilation$ || $regressive-assimilation$
$morph$ || $base-pre-modifications$ || $consonant-assimilation$ || $vowel-harmony$ || $post-alterations$ || $delete-base-types$
