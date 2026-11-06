%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Affix transformations
%  Last review:    02/11/2026

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description
% 2. Rules application order




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [R-NEG] Negative -----------------------------------------------------------------------------------------------------

% The negative affix has different forms [§113] :

% Before participles -т and -тах the joint vowels falls.
% variant ба after stems ending in vowels and й, л, р
% variant па after devoiced с, т, п, к, х.

% [01] (бар+V+NEG+CONV_COND#2 -> барбатах)
% [02] (бар+V+NEG+PART_FUT -> барымыах) (бар+V+NEG+CONV#3 -> барымына)
% [03] (сөбүлээ+V+NEG+CONV_COND#2 -> сөбүлээбэтэх)

$R-NEG01$ = {<C>м}:<B> ^-> __ <O> <neg><neg>       ( \
                           <B><C>т       <part2>   | \
                           <D1><O>[хр]   <part4>   | \
                           [#symbols#]+  <past>    | \
                           <D1><C>н      <imp-n>   | \
                           <D1><C>нн<O>р <imp>     )
$R-NEG02$ = <O>:<>     ^-> __ <neg><neg>           ( \
                           <C>?н<O>      <gnd3>    | \
                           <LO>р<C>      <gnd5>    | \
                           <DI>х         <part3-c> | \
                           <DI>          <part3-v> | \
                           <LC>м         <imp>     | \
                           <LO>р         <imp>     | \
                           <LO>р<C>ҥ     <imp>     | \
                           <LC>һ<C>к?    <cert>    | \
                           <LO>хт<LO>    <verb-v>  | \
                           <LO>р<O>й     <pot>     )
$R-NEG03$ = м:<B>      ^-> __ <O> <neg><neg>       ( \
                           <D1><O>[хр]   <part4>   | \
                           [#symbols#]+  <past>    | \
                           <D1><C>н      <imp-n>   | \
                           <D1><C>нн<O>р <imp>     )

$R-NEG$ = $R-NEG01$ || $R-NEG02$ || $R-NEG03$



% [R-ACCE] Aspect ------------------------------------------------------------------------------------------------------

$R-ACCE$ = <B>:м  ^-> [#vowels#] [#stem-types#]+ __ <O>хт<LO> <verb-v>



% [R-REFL] Reflexive ---------------------------------------------------------------------------------------------------

% [01] Reflexive verbs derived from dead roots or living stems with final 'т', are modified when conjugated [§65].
% [02] Observed in тобул -> тобулун -> тобуллубут [Kharitonov, 1963:100].
% [05] Observed in кыҥнай+V+RECP+REFL+ADJZ#5 -> кыҥнастыгас

$R-REFL01$ = {<C>н}:т ^-> [#consonants#] [#vowels#] [птк] [<tran-1c> <tran-2c> <tran-c>] \
                          [<tran-1c> <tran-2c> <tran-c>] __ <refl><refl>
$R-REFL02$ = {<C>н}:т ^-> [#vowels#] с <tran-1c><tran-1c> __ <refl><refl>
$R-REFL03$ = {<C>н}:л ^-> [#consonants#] [#vowels#] л <tran-2l><tran-2l> __ <refl><refl>
$R-REFL04$ = т:{<C>н} ^-> [#consonants#] [#vowels#] т [#trans-c#] [#trans-c#] __ <refl><refl> <D1><O>р <caus-r>
$R-REFL05$ = {<C>н}:т ^-> <recp-s> __ <refl><refl> <C>г<O>с <adj-dc>

% Suspended
% $R-REFL01$ || $R-REFL02$ ||

$R-REFL$ =  $R-REFL03$ || $R-REFL04$ || $R-REFL05$



% [R-PASS - D-PASS] Passive --------------------------------------------------------------------------------------------

% [03] The passive for the near past form seems to behave different. Examples:
% - (суруй+V+PASS+PST.3SG -> сурулунна)
% - (таай+V+PASS+PST.3SG -> таайылынна)
% [06] to produce ылыллыа -> ыл+V+PASS+PART_FUT
% [07] to produce иилиллээхтээбит -> иил+V+PASS+DIM
% [08] иһилин -> иһит+V+PASS
% [09] иһиллэр -> иһит+V+PASS+PART_PRES


$D-PASS01$ = н:<>      ^-> л [#verbs-crjnl# #d-verbs-jrc# <aux-c>]+ л<C>__  <pass><pass>
$D-PASS02$ = {<C>н}:<> ^-> (<tran-1c> <C> | <tran-2j>) л __ <pass><pass> л<O>ҥ <noun-dc>


#post-passive# = (<O>р?       <part1>               | \
                  <B><O>т     <part1-n>             | \
                  <B><C>т     <part2>               | \
                  <DI>        <part3-v>             | \
                  <DI>х       <part3-c>             | \
                  <LO>чч<C>   <part5>               | \
                  <O>н        <gnd1>                | \
                  <O>         <gnd2>                | \
                  <LO>хт<LO>  <verb-v>              | \
                  <LC>        <noun-dv>             )
$R-PASS01$ = {<C>н}:л     ^-> [#consonants#] [#vowels#] л <tran-1l><tran-1l> <C> л __ <pass><pass> [#post-passive#]
$R-PASS02$ = {<C>н}:л     ^-> [#vowels#][#vowels#]? р <tran-1r><tran-1r> <C> л __ <pass><pass> [#post-passive#]
$R-PASS03$ = {<C>н}:л     ^-> [<tran-1c> <tran-1j>] <C> л __ <pass><pass> [#post-passive#]
$R-PASS04$ = {<C>н}:л     ^-> [<tran-2c> <tran-2r> <tran-2l> <tran-2j> <fig-j>] <C>? л __ <pass><pass> [#post-passive#]
$R-PASS05$ = {<C>н}:л     ^-> [<cstv-r> <caus-r> <refl> <recp> <recp-s>] <C>? л __ <pass><pass>
$R-PASS06$ = {<C>н}:л     ^-> <begin> ыл <tran-1l><tran-1l> <C> л __ <pass><pass> <DI> <part3-v> <end> 
$R-PASS07$ = {<C>н}:л     ^-> <begin> [#vowels#][#vowels#] л <tran-1l><tran-1l> <C> л __ <pass><pass> [#post-passive#] 
$R-PASS08$ = <C>:<>       ^-> и <tran-2c><tran-2c> __ л<C>н <pass>
$R-PASS09$ = <C>:<>       ^-> и <tran-2c><tran-2c> __ лл <pass><pass>


%|| $R-PASS05$

$R-PASS$ = $R-PASS01$ %|| $R-PASS02$ || $R-PASS03$ || $R-PASS04$ || $R-PASS06$ || $R-PASS07$ || \
           %$R-PASS08$ || $R-PASS09$


% [R-RECP] Reciprocal --------------------------------------------------------------------------------------------------

% [01] This is to prevent applying the transformation to monosylabic verbal roots.
% [02] Prevents regressive assimilation in voice affixes [§112].
% [03] It was observed that (куус+V+RECP#1 -> куустус)
% [04] It was observed that (күл+V+RECP+CONV#1 -> күлсэн)
% [05] It was observed in verbal roots ending in two consonants (хаамп+V+RECP+PART_PRES+PL -> хаамсаллар)
% [08] It was observed that (көр+V+RECP+CONV#5 -> көрсөөрү)

% Removed because of
%                         <LC>        <noun-dv>           | \  сит+V+RECP+NMLZ#2 -> ситиһии

#verb-2plus-syl# = <tran-c> <tran-2c> <tran-j> <tran-2j> <tran-r> <tran-2r> <tran-l> <tran-2l> \
                   <intr-c> <intr-2c> <intr-j> <intr-2j> <intr-r> <intr-2r> <intr-nl> <intr-2nl>
$R-RECP01$ = {<C>с}:с ^-> [#vowels#] [#consonants#] [#verb-2plus-syl# #d-verbs-jrc#] [#verb-2plus-syl# #d-verbs-jrc#] \
                          __ <recp><recp>           ( \
                          <O>н     <gnd1>           | \
                          <O>р?    <part1><part1>   )
% VCVC to prevent this имнэн+V+RECP+PART_FUT -> имнэниһиэх
$R-RECP02222$ = {<C>с}:с ^-> (<begin> | [#vowels#]) [#consonants#] [#vowels#] [#consonants#] \
                          [#verbs-crjnl# #d-verbs-jrc#] [#verbs-crjnl# #d-verbs-jrc#] __ <recp><recp> ( \
                          <C>с        <recp>              | \
                          <B><O>      <neg>               | \
                          <O>р        <part1><part1>      | \
                          <O>         <part1><part1>      | \
                          <B><O>т     <part1-n>           | \
                          <B><C>т     <part2>             | \
                          <DI>        <part3-v>           | \
                          <DI>х       <part3-c>           | \
                          <O>         <gnd2>              | \
                          <LO>р<C>    <gnd5>              | \
                          <LO>р<O>й   <pot><pot>          | \
                          <C>м<O>?    <neg>               | \
                          <LO>р<O>й   <pot>               | \
                          <LC>м       <imp>               | \
                          <LO>р       <imp>               | \
                          <C>ҥ        <imp>               | \
                          <LO>р<C>ҥ   <imp>               )
$R-RECP02$ = {<C>с}:с ^-> <begin> [#consonants#]? [#vowels#][#vowels#]? [#consonants#] ( \
                          <tran-1c><tran-1c> | <tran-1r><tran-1r> | <tran-1l><tran-1l>   | <tran-1j><tran-1j> | \
                          <intr-1c><intr-1c> | <intr-1r><intr-1r> | <intr-1nl><intr-1nl> | <intr-1j><intr-1j> ) \
                          __ <recp><recp>                       ( \
                          <C>м<O>?   <neg>                      | \
                          <C>с       <recp>                     | \
                          <O>р       <part1>                    | \
                          <B><O>т    <part1-n>                  | \
                          <B><C>т    <part2>                    | \
                          <DI>       <part3-v>                  | \
                          <DI>х      <part3-c>                  | \
                          <O>н       <gnd1>                     | \
                          <O>        <gnd2>                     | \
                          <LO>т      <gnd6>                     | \
                          <LC>       <noun-dv>                  )
$R-RECP03$ = {<C>с}:с ^-> [#vowels#][#vowels#]? [#consonants#] ( \
                          <tran-2c><tran-2c> | <tran-2r><tran-2r> | <tran-2l><tran-2l>   | <tran-2j><tran-2j> | \
                          <intr-2c><intr-2c> | <intr-2r><intr-2r> | <intr-2nl><intr-2nl> ) \
                          __ <recp><recp>                       ( \
                          <C>с       <recp>                     | \
                          <O>р       <part1>                    | \
                          <B><C>т    <part2>                    | \
                          <DI>       <part3-v>                  | \
                          <DI>х      <part3-c>                  )
$R-RECP04$ = с:т ^->      с <tran-1c><tran-1c> __ <C>с <recp-s>
$R-RECP05$ = <C>:<> ^->   л <intr-1nl><intr-1nl> __ с <recp><recp> <O>н <gnd1>
$R-RECP06$ = <C>:<> ^->   [#consonants#] [#consonants#] <intr-1c><intr-1c> __ с <recp><recp>
$R-RECP07$ = {<C>с}:с ^-> (<verb-r><verb-r>) __ <recp><recp> ( \
                          <C>м<O>?            <neg>        | \
                          <O>                 <gnd2>       )
$R-RECP08$ = {<C>с}:с ^-> <tran-1r><tran-1r> __ <recp><recp> <LO>р<C> <gnd5>

%  || $R-RECP02$ Suspended because of: тутуһар -> тут+V+RECP+PART_PRES
$R-RECP$ = $R-RECP01$ || $R-RECP03$ || $R-RECP04$ || $R-RECP05$ || $R-RECP06$ || $R-RECP07$ || $R-RECP08$



% [D-PART] Participles -------------------------------------------------------------------------------------------------

% [01] The final 'р' of the present participle turns into a 'л' before the plural [§67].
% [02] The final 'р' of the present participle is deleted before predicative affixes.
% [03] The 3 person singular possessive accusative and dative takes a short form after the future participle [§137].
% [04] deletes diphthong in plural participle after stem ending in diphthong.
% [05] (options) since in Kharitonov L.N. this seems not to be applied [Neizmenyayemyye slova v yakutskom yazyke: posobiye dlya uchiteley:22].

$D-PART01$ = р:л                  ^-> __ (<part1><part1> | <cond><cond> | <aux-c><aux-c> | <part4><part4>) \
                                  <D2><O>р <plur>
$D-PART02$ = р:<>                 ^-> __ <part1><part1> ( \
                                  <B><C>н      <predsg> | \
                                  <V><C>н      <predsg> | \
                                  <B><C>т      <predpl> | \
                                  <V><C>т      <predpl> )
$D-PART03$ = х:<>                 ^-> __ <part3-c><part3-c> (<C>н | <C>г<O>р) <case-p>
$D-PART04$ = <DI>:<>              ^-> [#closed-vowels#] [#open-vowels#] [#intrs-v# #trans-v#]+ __ х <part3-c>
$D-PART05$ = т:ч                  ^->?  __ <part2><part2> ч<O> <adv-dv>


% [02] Observed in кырый+V+NEG+PART_PRES -> кырдьыбат

$R-PART01$ = {<B><C>т}:{<D1><O>х} ^-> <neg> __ <part2>
$R-PART02$ = {<B>}:{<C>б} ^-> дь <intr-2j><intr-2j> __ <O>т <part1-n>


$D-PART$ = $D-PART01$ || $D-PART02$ || $D-PART03$ || $D-PART04$ || $D-PART05$
$R-PART$ = $R-PART01$ || $R-PART02$


% [R-CAS] Case affixes -------------------------------------------------------------------------------------------------

% [01,02,03] Modify the case affix to inflect the adverb ханна
% [04] Dative case of киһи

$R-CAS01$ = <V>:{ыах} ^-> <begin> хан <adv-2v><adv-2v> __ <O> <dat>
$R-CAS02$ = т:<>      ^-> <begin> хан <adv-2v><adv-2v> __ т<O>н <case-c>
$R-CAS03$ = н:<>      ^-> <begin> хан <adv-2v><adv-2v> __ <O>н <case-c>
$R-CAS04$ = <V>:{эх}  ^-> <begin> киһи <noun-2v><noun-2v> __ <O> <dat>

$R-CAS$ = $R-CAS01$ || $R-CAS02$ || $R-CAS03$ || $R-CAS04$



% [D-POSS] Possessive case affixes -------------------------------------------------------------------------------------

% [01] Build upon [D-PART03] to form the short possessive accusative after the future participle [§137].
% [02] Build upon [D-PART03] to form the short possessive dative after the future participle [§137].
% [03] The initial г of the possessive dative affix falls in the 3 person singular before к, х, ҥ [§135].
% [04] The initial г was observed to fall in particle илик (needs to be generalized or merged).
% [05] The initial г was observed to fall in monosyllabic муҥ and дьиҥ (needs to be generalized or merged).
% [06] allows the transformation
% [07] суруй+V+NMLZ#5+POSS.3SG+DAT -> суругар | мус+V+NMLZ#6+POSS.3SG+DAT -> мунньаҕар

$D-POSS01$ = <C>:<>       ^-> <part3-c><part3-c> __ н <case-p>
$D-POSS02$ = {<C>г<O>}:<> ^-> <part3-c><part3-c> __ р <case-p>
$D-POSS03$ = {<C>г}:<>    ^-> [#consonants#] [#vowels#][#vowels#]? [кхҥмп] ( \
                              <adj-2c><adj-2c>   | \
                              <noun-2c><noun-2c> | \
                              <noun-dc><noun-dc> | \
                              <noun-c><noun-c>   ) \
                              __ <O>р <case-p>
$D-POSS04$ = {<C>г}:<>    ^-> <begin> илик <part-c><part-c> __ <O>р <case-p>
$D-POSS05$ = {<C>г}:<>    ^-> <begin> [#consonants#] ь? [иу] ҥ (<noun-1c><noun-1c> | <adj-1c><adj-1c>) __ <O>р <case-p>
$D-POSS06$ = {<C>г}:<>    ^-> <begin> сорох <ind><ind> __ <O>р <case-p>
$D-POSS07$ = {<C>г}:<>    ^-> [кх] <noun-dc><noun-dc> __ <O>р <case-p>

$D-POSS$ = $D-POSS01$ || $D-POSS02$ || $D-POSS03$ || $D-POSS04$ || $D-POSS05$ || $D-POSS06$ || $D-POSS07$



% [R-POT] Potential mood case affix ------------------------------------------------------------------------------------

$R-POT01$ = {р<O>й}:{й<O>л} ^-> __ <pot><pot> <D2><O>р
$R-POT02$ = {р<O>й}:{й<O>}  ^-> __ <pot><pot>

$R-POT$ = $R-POT01$ || $R-POT02$



% [R-NOM] Nominalizers -------------------------------------------------------------------------------------------------

% [01] In stems containing л the affix б<C>л takes the form б<C>р [§177].
% [02] before affixes ending in open vowel, the vowel of the converb changes to closed [Кharitonov, Adv: 32].

$R-NOM$ = л:р      ^-> л [#vowels#]+ [#verbs-v# #verbs-j# <verb-v>]+ б<C> __ <noun-dc>
$R-CON01$ = <O>:<C>  ^-> [#verbs-crjnl# <verb-c> #voices#] __ <gnd2><gnd2> <D1><O> <adv-dv>
$R-CON02$ = [ыи]:<O>  ^-> __ <adv-2v><adv-2v> р<C>т<O> <adv-v>

$R-CON$ = $R-CON01$ || $R-CON02$



% [R-CSTV] Causative ---------------------------------------------------------------------------------------------------

% Causative stems from intransitive verbs ending in 'р' seem to force the realization of affixes beginning with '<D1>'
% as 'т' instead of 'д'. For example: иһэртэ. But not бүт+V+CSTV+PST.3SG -> бүтэрдэ.

$R-CSTV01$ = <D1>:т  ^-> <cstv-r> __ <O> <past>
$R-CSTV02$ = т:<>    ^-> __ (<cstv-c><cstv-c> | <caus-c><caus-c>) ч<C> <adv-dv>
$R-CSTV03$ = <C>:<>  ^-> __ т <cstv-c><cstv-c> т<O>р <caus-r>

% || $R-CSTV03$
% $R-CSTV01$ ||
$R-CSTV$ = $R-CSTV02$



% [$MSC$] Miscellaneous ------------------------------------------------------------------------------------------------

% A set of non-classified rules with local impact.

% [01] After after removing the final nasal, the binding closed-vowel is not longer needed.
% [02]
% [03] The root 'киһи' seems to have an irregular form for dative.
% [04] Observed in (ис+N+ADJZ#2 -> иһинээҕи) and (тас+N+ADJZ#2 -> таһынааҕы)
% [05]
% [06] Prevents applying progressive assimilation. Observed in кэл+V+PST.3SG -> кэлтэ.

$D-MSC01$ = <C>:<>      ^-> [#vowels#] [#noms-c#]+ __ ( мс<C>й <verb-j> | рҕ<LO> <verb-v>)
$D-MSC02$ = {<C>й}:<>   ^-> р __ <verb-j><verb-j>             ( \
                            х<O>й                   <adj-dj>  )
$I-MSC03$ = <V>:{<O>х}  ^-> <begin> киһи <noun-v><noun-v> __ <O> <dat>
$I-MSC04$ = <D1>:{<C>н} ^-> <noun-1c><noun-1c> __ <LO>ҕ<C> <adj-dv>
$I-MSC05$ = й:{<C>й}    ^-> <adj-2v><adj-2v> __ <verb-j>
$I-MSC06$ = <D1>:т      ^-> <intr-1nl> __ <O> <past>

$MSC$ = $D-MSC01$ || $D-MSC02$ || $I-MSC03$ || $I-MSC04$ || $I-MSC05$ || $I-MSC06$



% [R-STTY] Change stem type --------------------------------------------------------------------------------------------

% [01-02] It was observed that атта (около) has an irregular behaviour when attaching some case affixes.

$R-STTY01$ = {а<noun-2v><noun-2v>т}:{<noun-2v><noun-2v>} ^-> атт __  (<C>г<O>р | <C>тт<O>н)
$R-STTY02$ = а:<C>                                       ^-> атт __  <noun-2v><noun-2v> н<O>н

$R-STTY$ = $R-STTY01$ || $R-STTY02$



% [D-LOD] Long vowel deletion (derivations) ----------------------------------------------------------------------------

% Deletes long open vowel in verbal derivations before certain affixes.
% This rule should be implemented before [R-LOD].

$D-LOD01$ = <LO>:<> ^-> __ (<verb-v><verb-v>)                                              ( \
                      <LC>                 <gnd2>                                        | \
                      <LO>т                <gnd6>                                        | \
                      <LC>                 <noun-dv>                                     | \
                      <O>ҕ<O>с             <adj-dc>                                      | \
                      <O>[рл]?             <part1>                                       | \
                      <LC>[рл]?            <part1>                                       | \
                      <DI>                 <part3-v>                                     | \
                      <DI>х                <part3-c>                                     | \
                      <LO>һ<C>н            <noun-dc>                                     | \
                      <LC>м                <imp>                                         | \
                      <LO>р                <imp>                                         | \
                      <LO>р<C>ҥ            <imp>                                         | \
                      <LC>һ<C>             <cert>                                        )
$D-LOD02$ = <LO>:<> ^->? __ <verb-v><verb-v> <LO>н <gnd1>
$D-LOD$ = $D-LOD01$ || $D-LOD02$



% [R-LOD] Long open vowel shortening in derivations --------------------------------------------------------------------

% Applies before:
% [01] (от+N+VRBLZ#1+CAUS -> оттот)
% [03] reciprocal (доҕор+N+VRBLZ#1+RECP -> доҕордос)

$R-LOD01$ = <LO>:<O> ^-> __ (<verb-v><verb-v> | <tran-v><tran-v>) ( \
                       т           <cstv-c>                     | \
                       т           <caus-c>                     | \
                       н           <refl>                       | \
                       н           <pass>                       | \
                       с           <recp-s>                     | \
                       х           <noun-dc>                    | \
                       (л<O>)?ҥ    <noun-dc>                    | \
                       б<C>л       <noun-dc>                    | \
                       ннь<O>ҥ     <adj-dc>                     | \
                       чч<C>       <adv-dv>                     | \
                       н           <refl>                       | \
                       с           <recp>                       | \
                       с           <adj-dc>                     | \
                       мт<O>ҕ<O>й  <adj-dj>                     )
$R-LOD02$ = <LO>:<O> ^-> г<C>[рн] __ <verb-v><verb-v> й <verb-j>

$R-LOD$ = $R-LOD01$ || $R-LOD02$



% [I-CV] Inserts a close vowel before affixes --------------------------------------------------------------------------

% [01] үрүт+N+VRBLZ#1 -> үрдүлээ [Kharitonov, 1943:29]
% [04] кырый+V+PART_PAST+POSS.3SG -> кырдьыбыта)

$I-CA01$ = <D2>:{<C>л} ^-> рт <noun-2c><noun-2c> __ (<O>|<LO>) <verb-v>
$I-CA02$ = <D2>:{<C>л} ^-> рт <noun-2c><noun-2c> __ <O>р <plur>
$I-CA03$ = <B>:{<C>б}  ^-> рт <noun-2c><noun-2c> __ [#symbols#]+ <case-p>
$I-CA04$ = <B>:{<C>б}  ^-> дь <intr-2j><intr-2j> __ <C>т <part2>
$I-CA05$ = <B>:{<C>б}  ^-> [#vowels#] [#consonants#] [#vowels#] т <caus-c><caus-c> __ <O>т <part1-n>


$I-CA$ = $I-CA01$ || $I-CA02$ || $I-CA03$ || $I-CA04$ || $I-CA05$


% [I-R] Restores present participle full affix when attaching an interrogative affix at the end (facultative) ----------


$I-R$ = <O>:{<O>р}  ^->? [#verbs# #d-verbs#] __ <part1><part1> [<B><V>] (<C>н <predsg><predsg> | <C>т <predpl><predpl>) \
                                                <C>й <in>




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$affix-transformations$ = $R-NEG$ || $R-ACCE$ || $R-REFL$ || $R-PASS$ || $R-RECP$ || $D-PART$ || $R-PART$ || \
                          $R-CAS$ || $D-POSS$ || $R-POT$ || $R-NOM$ || $R-CON$  || $R-CSTV$ || $MSC$ || $R-STTY$ || \
                          $D-LOD$ || $R-LOD$ || $I-CA$ || $I-R$
