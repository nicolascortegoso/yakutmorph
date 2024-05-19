%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Affix transformations
%  Last review:    27/03/2024

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

% [01] (бар^V+NEG+CONV_COND#2 -> барбатах)
% [02] (бар^V+NEG+PART_FUT -> барымыах) (бар^V+NEG+CONV#3 -> барымына)
% [03] (сөбүлээ^V+NEG+CONV_COND#2 -> сөбүлээбэтэх)

$R-NEG01$ = {<C>м}:<B> ^-> __ <O> <neg><neg>      ( \
                           <B><C>т      <part2>   | \
                           <D1><O>[хр]  <part4>   | \
                           [#symbols#]+ <past>    | \
                           <D1><C>н     <imp-n>   )
$R-NEG02$ = <O>:<>     ^-> __ <neg><neg>          ( \
                           <C>?н<O>     <gnd3>    | \
                           <LO>р<C>     <gnd5>    | \
                           <DI>х        <part3-c> | \
                           <DI>         <part3-v> | \
                           <LO>р<O>й    <pot>     | \
                           <LC>         <imp-v>   | \
                           <DI>х        <imp-c>   | \
                           <LO>р        <imp-r>   )
$R-NEG03$ = м:<B>      ^-> __ <O> <neg><neg> (<D1><O>[хр] <part4> | [#symbols#]+ <past> | <D1><C>н <imp-n>)

$R-NEG$ = $R-NEG01$ || $R-NEG02$ || $R-NEG03$



% [R-ACCE] Aspect ------------------------------------------------------------------------------------------------------

$R-ACCE$ = <B>:м  ^-> [#vowels#] [#stem-types#]+ __ <O>хт<LO> <verb-v>



% [R-REFL] Reflexive ---------------------------------------------------------------------------------------------------

% [01] Reflexive verbs derived from dead roots or living stems with final 'т', are modified when conjugated [§65].

$R-REFL01$ = {<C>н}:<D1> ^-> [йткпсн] [#verbs-crjnl#] [#verbs-crjnl#] __ <refl><refl>

$R-REFL$ = $R-REFL01$



% [R-PASS - D-PASS] Passive --------------------------------------------------------------------------------------------

% [03] The passive for the near past form seems to behave different. Examples:
% - (суруй^V+PASS+PST.3SG -> сурулунна)
% - (таай^V+PASS+PST.3SG -> таайылынна)

$D-PASS01$ = н:<>      ^-> л [#verbs-crjnl# #d-verbs-jrc# <aux-c>]+ л<C>__  <pass><pass>
$D-PASS02$ = {<C>н}:<> ^-> (<tran-1c> <C> | <tran-2j>) л __ <pass><pass> л<O>ҥ <noun-dc>

$R-PASS01$ = {<C>н}:л ^-> [<tran-j> <fig-j> <tran-2l> <tran-l> <tran-2j> <tran-1j> <aux-c>]+ л __  <pass><pass> ( \
                          <C>м              <neg>                                                               | \
                          <O>р?             <part1>                                                             | \
                          <B><O>т           <part1-n>                                                           | \
                          <B><C>т           <part2>                                                             | \
                          <DI>              <part3-v>                                                           | \
                          <DI>х             <part3-c>                                                           | \
                          <LO>чч<C>         <part5>                                                             | \
                          <O>н              <gnd1>                                                              | \
                          <O>               <gnd2>                                                              | \
                          <LO>р<C>          <gnd5>                                                              )
$R-PASS02$ = {<C>н}:л ^-> [<tran-2r> <tran-1r> <tran-1l> <tran-1c> <tran-2c> <tran-c> <tran-1j> #voices#] \
                                                                                     <C>л __ <pass><pass> ( \
                          <C>м                 <neg>                                                      | \
                          <B><O>               <neg>                                                      | \
                          <O>р?                <part1>                                                    | \
                          <B><O>т              <part1-n>                                                  | \
                          <B><C>т              <part2>                                                    | \
                          <DI>                 <part3-v>                                                  | \
                          <DI>х                <part3-c>                                                  | \
                          <LO>чч<C>            <part5>                                                    | \
                          <O>н                 <gnd1>                                                     | \
                          <O>                  <gnd2>                                                     | \
                          <LO>р<C>             <gnd5>                                                     | \
                          <LC>                 <noun-dv>                                                  )
$R-PASS03$ = {<C>н}:л ^->  <begin> [#consonants#][#vowels#][#vowels#]?[т] \
                           (<tran-1c><tran-1c> | <tran-1j><tran-1j>) <C>л __ \
                           <pass><pass> (<D1><O> <past> | <O>р? <part1>)
$R-PASS04$ = л:<> ^-> л __ <pass><pass> <D1><O> <past>

$R-PASS$ = $D-PASS01$ || $D-PASS02$ || \
           $R-PASS01$ || $R-PASS02$ || $R-PASS03$ || $R-PASS04$



% [R-RECP] Reciprocal --------------------------------------------------------------------------------------------------

% [01] Prevents regressive assimilation in voice affixes [§112].
% [02] It as observed that (куус^V+RECP#1 -> куустус)

$R-RECP01$ = {<C>с}:с ^-> [#verbs-crjnl#] __ <recp><recp> ( \
                          <B><O>      <neg>               | \
                          <O>р        <part1>             | \
                          <O>         <part1><part1>      | \
                          <B><O>т     <part1-n>           | \
                          <B><C>т     <part2>             | \
                          <DI>        <part3-v>           | \
                          <DI>х       <part3-c>           | \
                          <O>н        <gnd1>              | \
                          <O>         <gnd2>              | \
                          <LO>р<C>    <gnd5>              | \
                          <LO>р<O>й   <pot><pot>          | \
                          <C>м<O>?    <neg>               | \
                          <LC>        <noun-dv>           | \
                          <LC>        <imp-v>             | \
                          <DI>х       <imp-c>             | \
                          <C>ҥ        <psor>              | \
                          <LO>р       <imp-r>             )
$R-RECP02$ = с:т ^->      с <tran-1c><tran-1c> __ <C>с <recp-s>

$R-RECP$ = $R-RECP01$ || $R-RECP02$



% [D-PART] Participles -------------------------------------------------------------------------------------------------

% [01] The final 'р' of the present participle turns into a 'л' before the plural [§67].
% [02] The final 'р' of the present participle is deleted before predicative affixes.
% [03] The 3 person singular possessive accusative and dative takes a short form after the future participle [§137].
% [04] deletes diphthong in plural participle after stem ending in diphthong.

$D-PART01$ = р:л                  ^-> __ (<part1><part1> | <cond><cond> | <aux-c><aux-c>) <D2><O>р <plur>
$D-PART02$ = р:<>                 ^-> __ <part1><part1> ( \
                                  <B><C>н      <predsg> | \
                                  <V><C>н      <predsg> | \
                                  <B><C>т      <predpl> | \
                                  <V><C>т      <predpl> )
$D-PART03$ = х:<>                 ^-> __ <part3-c><part3-c> (<C>н | <C>г<O>р) <case-p>
$D-PART04$ = <DI>:<>              ^-> [#closed-vowels#] [#open-vowels#] [#intrs-v# #trans-v#]+ __ х <part3-c>
$D-PART05$ = т:ч                  ^->  __ <part2><part2> ч<O> <adv-dv>
$D-PART06$ = {<B><C>т}:{<D1><O>х} ^-> <neg> __ <part2>

$D-PART$ = $D-PART01$ || $D-PART02$ || $D-PART03$ || $D-PART04$ || $D-PART05$ || $D-PART06$



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

$D-POSS01$ = <C>:<>       ^-> <part3-c><part3-c> __ н <case-p>
$D-POSS02$ = {<C>г<O>}:<> ^-> <part3-c><part3-c> __ р <case-p>
$D-POSS03$ = {<C>г}:<>    ^-> [#vowels#] [кхҥмп] (<noun-2c><noun-2c> | <noun-c><noun-c>) __ <O>р <case-p>
$D-POSS04$ = {<C>г}:<>    ^-> <begin> илик <part-c><part-c> __ <O>р <case-p>

% CHECK
%%%$D-POSS05$ = {<C>г}:<>    ^-> <begin> [#consonants#] ь? [иу] ҥ <noun-1c><noun-1c> __ <O>р <case-p>

$D-POSS$ = $D-POSS01$ || $D-POSS02$ || $D-POSS03$ || $D-POSS04$



% [R-POT] Potential mood case affix ------------------------------------------------------------------------------------

$R-POT01$ = {р<O>й}:{й<O>л} ^-> __ <pot><pot> <D2><O>р
$R-POT02$ = {р<O>й}:{й<O>}  ^-> __ <pot><pot>

$R-POT$ = $R-POT01$ || $R-POT02$



% [R-NOM] Nominalizers -------------------------------------------------------------------------------------------------

% [01] In stems containing л the affix б<C>л takes the form б<C>р [§177].

$R-NOM$ = л:р ^-> л [#vowels#]+ [#verbs-v# #verbs-j# <verb-v>]+ б<C> __ <noun-dc>
$R-CON$ = <O>:<C>  ^-> [#verbs-crjnl# <verb-c> #voices#] __ <gnd2><gnd2> <D1><O> <adv-dv>



% [R-CSTV] Causative ---------------------------------------------------------------------------------------------------

% Causative stems from intransitive verbs ending in 'р' seem to force the realization of affixes beginning with '<D1>'
% as 'т' instead of 'д'. For example: иһэртэ

$R-CSTV$ = <D1>:т  ^-> <cstv-r> __ <O> <past>



% [$MSC$] Miscellaneous ------------------------------------------------------------------------------------------------

% A set of non-classified rules with local impact.

% [01] After after removing the final nasal, the binding closed-vowel is not longer needed.
% [02] The root 'киһи' seems to have an irregular form for dative.
% [03] Observed in (ис^N^ADJZ#2 -> иһинээҕи) and (тас^N^ADJZ#2 -> таһынааҕы)

$D-MSC01$ = <C>:<>      ^-> [#vowels#] [#noms-c#]+ __ ( мс<C>й <verb-j> | рҕ<LO> <verb-v>)
$I-MSC02$ = <V>:{<O>х}  ^-> <begin> киһи <noun-v><noun-v> __ <O> <dat>
$I-MSC03$ = <D1>:{<C>н} ^-> <noun-1c><noun-1c> __ <LO>ҕ<C> <adj-dv>

$MSC$ = $D-MSC01$ || $I-MSC02$ || $I-MSC03$



% [R-STTY] Change stem type --------------------------------------------------------------------------------------------

% [01-02] It was observed that атта (около) has an irregular behaviour when attaching some case affixes.

$R-STTY01$ = {а<noun-2v><noun-2v>т}:{<noun-2v><noun-2v>} ^-> атт __  <C>г<O>р
$R-STTY02$ = а:<C> ^-> атт __  <noun-2v><noun-2v> н<O>н

$R-STTY$ = $R-STTY01$ || $R-STTY02$



% [D-LOD] Long vowel deletion (derivations) ----------------------------------------------------------------------------

% Deletes long open vowel in verbal derivations before certain affixes.
% This rule should be implemented before [R-LOD].

$D-LOD$ = <LO>:<> ^-> __ (<verb-v><verb-v>)                                              ( \
                      <LC>                 <gnd2>                                        | \
                      <O>ҕ<O>с             <adj-dc>                                      | \
                      <O>[рл]?             <part1>                                       | \
                      <LC>[рл]?            <part1>                                       | \
                      <DI>                 <part3-v>                                     | \
                      <DI>х                <part3-c>                                     | \
                      <LC>                 <imp-v>                                       | \
                      <DI>х                <imp-c>                                       | \
                      <LO>р                <imp-r>                                       | \
                      <LO>һ<C>н            <noun-dc>                                     )



% [R-LOD] Long open vowel shortening in derivations --------------------------------------------------------------------

% Applies before:
% [01] (от^N^VRBLZ#1+CAUS -> оттот)
% [03] reciprocal (доҕор^N^VRBLZ#1+RECP -> доҕордос)

$R-LOD$ = <LO>:<O> ^-> __ (<verb-v><verb-v> | <tran-v><tran-v>) ( \
                       т           <cstv-c>                     | \
                       т           <caus-c>                     | \
                       н           <refl>                       | \
                       н           <pass>                       | \
                       с           <recp-s>                     | \
                       х           <noun-dc>                    | \
                       (л<O>)?ҥ    <noun-dc>                    | \
                       ннь<O>ҥ     <adj-dc>                     | \
                       чч<C>       <adv-dv>                     | \
                       н           <refl>                       | \
                       с <recp>                                 )



% [I-CV] Inserts a close vowel before affixes --------------------------------------------------------------------------

% [03] (кырый^V+PART_PAST+POSS.3SG -> кырдьыбыта)

$I-CA01$ = <D2>:{<C>л} ^-> рт <noun-2c><noun-2c> __ <O>р <plur>
$I-CA02$ = <B>:{<C>б}  ^-> рт <noun-2c><noun-2c> __ [#symbols#]+ <case-p>
$I-CA03$ = <B>:{<C>б}  ^-> дь <intr-2j><intr-2j> __ <C>т <part2>

$I-CA$ = $I-CA01$ || $I-CA02$ || $I-CA03$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$affix-transformations$ = $R-NEG$ || $R-ACCE$ || $R-REFL$ || $R-PASS$ || $R-RECP$ || $D-PART$ || \
                          $R-CAS$ || $D-POSS$ || $R-POT$ || $R-NOM$ || $R-CON$  || $R-CSTV$ || $MSC$ || $R-STTY$ || \
                          $D-LOD$ || $R-LOD$ || $I-CA$
