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

% [01] (бар^V^NEG^COND -> барбатах)
% [02] (бар^V^NEG^PART_FUT -> барымыах) (бар^V^NEG^CONV3 -> барымына)
% [03] (сөбүлээ^V^NEG^COND -> сөбүлээбэтэх)

$R-NEG01$ = {<C>м}:<B> ^-> __ <O> <neg><neg> (<D1><O>х <part4> | [#symbols#]+ <past> | <D1><C>н <imp-n>)
$R-NEG02$ = <O>:<>     ^-> __ <neg><neg> (<C>н<O> <gnd3> | <DI>х <part3-c> | <LO>р<O>й <pot> | <LC> <imp-v> | \
                       <DI>х <imp-c> | <LO>р <imp-r>)
$R-NEG03$ = м:<B>      ^-> __ <O> <neg><neg> (<D1><O>х <part4> | [#symbols#]+ <past> | <D1><C>н <imp-n>)

$R-NEG$ = $R-NEG01$ || $R-NEG02$ || $R-NEG03$


% [R-ACCE] Aspect ------------------------------------------------------------------------------------------------------

$R-ACCE$ = <B>:м  ^-> [#vowels#] [#stem-types#]+ __ <O>хт<LO> <acce>


% [R-REFL] Reflexive ---------------------------------------------------------------------------------------------------

% Reflexive verbs derived from dead roots or living stems with final 'т', are modified when conjugated [§65].

$R-REFL01$ = {<C>н}:<D1> ^-> __ <refl><refl> [#symbols#]+ <cert>
%$R-REFL02$ = {<C>н}:<D1> ^-> л __ <refl><refl> [#symbols#]+ (<cert> | <pot>)

$R-REFL$ = $R-REFL01$ %|| $R-REFL02$


% [R-PASS - D-PASS] Passive --------------------------------------------------------------------------------------------

% The passive for the near past form seems to behave different.

% [01] Must be applied before [D-PART01] ????
% [03] For the past we exclude one-syllable roots аһылынна

$D-PASS01$ = н:<>      ^-> л [#verbs-crjnl# #d-verbs-jrc# <aux-c>]+ л<C>__  <pass><pass>
$R-PASS01$ = {<C>н}:л ^-> [<tran-j>  #trans-l# <tran-2j> <tran-1j> <aux-c>]+ л __  <pass><pass>
$R-PASS02$ = {<C>н}:л ^-> [<tran-2r> <tran-1r> <tran-1c> <tran-2c> <tran-c> #voices#] <C>л __ <pass><pass> ( \
                      <O>р?     <part1>                                                                    | \
                      <B><O>т   <part1-n>                                                                  | \
                      <B><C>т   <part2>                                                                    | \
                      <DI>      <part3-v>                                                                  | \
                      <DI>х     <part3-c>                                                                  | \
                      <O>н      <gnd1>                                                                     )
$R-PASS03$ = {<C>н}:л ^-> <begin> [#consonants#][#vowels#][#vowels#]?[#consonants#] \
                      (<tran-1c><tran-1c> | <tran-1j><tran-1j>) <C>л __ \
                          <pass><pass> (<D1><O> <past> | <O>р? <part1>)
$R-PASS04$ = л:<> ^-> л __ <pass><pass> <D1><O> <past>  % кэт^V^PASS^PST+3SG -> кэтиллэ

$R-PASS$ = $D-PASS01$ || \
           $R-PASS01$ || $R-PASS02$ || $R-PASS03$ || $R-PASS04$


% [R-RECP] Reciprocal --------------------------------------------------------------------------------------------------

% Prevents regressive assimilation in voice affixes [§112].

$R-RECP$ = {<C>с}:с ^-> [#verbs-crjnl#] __ <recp><recp> ( \
                    <B><O>      <neg>                   | \
                    <O>р        <part1><part1>          | \
                    <O>         <part1><part1>          | \
                    <B><O>т     <part1-n>               | \
                    <B><C>т     <part2>                 | \
                    <DI>        <part3-v><part3-v>      | \
                    <DI>х       <part3-c><part3-c>      | \
                    <O>н        <gnd1>                  | \
                    <O>         <gnd2>                  | \
                    <LO>р<O>й   <pot><pot>              | \
                    <C>м<O>?    <neg>                   | \
                    <LC>        <noun-dv>               | \
                    <LC>        <imp-v>                 | \
                    <DI>х       <imp-c>                 | \
                    <C>ҥ        <psor>                  | \
                    <LO>р       <imp-r>                 )


% [D-PART] Participles -------------------------------------------------------------------------------------------------

% [01] The final 'р' of the present participle turns into a 'л' before the plural [§67].
% [02] The final 'р' of the present participle is deleted before predicative affixes.
% [03] The 3 person singular possessive accusative and dative takes a short form after the future participle [§137].
% [04] deletes diphthong in plural participle after stem ending in diphthong.

$D-PART01$ = р:л     ^-> __ (<part1><part1> | <cond><cond>) <D2><O>р <plur>
$D-PART02$ = р:<>    ^-> __ <part1><part1> ( \
                     <B><C>н      <predsg> | \
                     <V><C>н      <predsg> | \
                     <B><C>т      <predpl> | \
                     <V><C>т      <predpl> )
$D-PART03$ = х:<>    ^-> __ <part3-c><part3-c> (<C>н | <C>г<O>р) <case-p>
$D-PART04$ = <DI>:<> ^-> [#closed-vowels#] [#open-vowels#] [#intrs-v# #trans-v#]+ __ х <part3-c>
$D-PART05$ = т:ч     ^->  __ <part2><part2> ч<O> <adv-dv>

$D-PART$ = $D-PART01$ || $D-PART02$ || $D-PART03$ || $D-PART04$ || $D-PART05$


% [D-POSS] Possessive case affixes -------------------------------------------------------------------------------------

% [01] Build upon [D-PART03] to form the short possessive accusative after the future participle [§137].
% [02] Build upon [D-PART03] to form the short possessive dative after the future participle [§137].
% [03] The initial г of the possessive dative affix falls in the 3 person singular before к, х, ҥ [§135].
% [04] The initial г was observed to fall in particle илик (needs to be generalized or merged).
% [05] The initial г was observed to fall in monosyllabic муҥ and дьиҥ (needs to be generalized or merged).

$D-POSS01$ = <C>:<>       ^-> <part3-c><part3-c> __ н <case-p>
$D-POSS02$ = {<C>г<O>}:<> ^-> <part3-c><part3-c> __ р <case-p>
$D-POSS03$ = {<C>г}:<>    ^-> [кхҥмп] <noun-2c><noun-2c> __ <O>р <case-p>
$D-POSS04$ = {<C>г}:<>    ^-> <begin> илик <part-c><part-c> __ <O>р <case-p>
$D-POSS05$ = {<C>г}:<>    ^-> <begin> [#consonants#] ь? [иу] ҥ <noun-1c><noun-1c> __ <O>р <case-p>

$D-POSS$ = $D-POSS01$ || $D-POSS02$ || $D-POSS03$ || $D-POSS04$


% [R-POT] Potential mood case affix ------------------------------------------------------------------------------------

$R-POT01$ = {р<O>й}:{й<O>л} ^-> __ <pot><pot> <D2><O>р
$R-POT02$ = {р<O>й}:{й<O>}  ^-> __ <pot><pot>

$R-POT$ = $R-POT01$ || $R-POT02$


% [R-NOM] Nominalizers -------------------------------------------------------------------------------------------------

% [01] In stems containing л the affix б<C>л takes the form б<C>р [§177].

$R-NOM$ = л:р ^-> л [#vowels#]+ [#verbs-v# #verbs-j# <verb-v>]+ б<C> __ <noun-dc>
$R-CON$ = <O>:<C>  ^-> [#verbs-crjnl# <verb-c> #voices#] __ <gnd2><gnd2> <D1><O> <adv-dv>


% [R-CSTV] Near past ---------------------------------------------------------------------------------------------------

% Causative stems from intransitive verbs ending in 'р' seem to force affixes beginning with '<D1>' to realize as 'т'
% instead of 'д'. For example: иһэртэ

$R-CSTV$ = <D1>:т ^-> <cstv-r> __ <O> <past>


% [$MSC$] Extra --------------------------------------------------------------------------------------------------------

% [01] After after removing the final nasal, the binding closed-vowel is not longer needed.
% [02] The root 'киһи' seems to have an irregular form for dative.

$D-MSC01$ = <C>:<> ^-> [#vowels#] [#noms-c#]+ __ ( мс<C>й <verb-j> | рҕ<LO> <verb-v>)
$I-MSC02$ = <V>:{<O>х} ^-> <begin> киһи <noun-v><noun-v> __ <O> <dat>

$MSC$ = $D-MSC01$ || $I-MSC02$


% [R-STTY] Change stem type --------------------------------------------------------------------------------------------

$R-STTY$ = {а<noun-v><noun-v>т}:{<noun-v><noun-v>} ^-> атт __  <C>г<O>р


% [D-LOD] Long vowel deletion (derivations) ----------------------------------------------------------------------------

% Deletes long open vowel in verbal derivations before certain affixes.
% This rule should be implemented before [R-LOD].

$D-LOD$ = <LO>:<> ^-> __ (<verb-v><verb-v> | <iter><iter> | <acce><acce> | <expr><expr>) ( \
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
% [01] от^N^VRBLZ1^CAUS -> оттот
% [03] reciprocal доҕордоос -> доҕордос

$R-LOD$ = <LO>:<O> ^-> __ (<verb-v><verb-v> | <tran-v><tran-v> | <iter><iter>) ( \
                       т <cstv-c>                                              | \
                       т <caus-c>                                              | \
                       н <refl>                                                | \
                       н <pass>                                                | \
                       с <recp-s>                                              | \
                       х <noun-dc>                                             | \
                       (л<O>)?ҥ <noun-dc>                                      | \
                       ннь<O>ҥ <adj-dc>                                        | \
                       чч<C> <adv-dv>                                          | \
                       н <refl>                                                | \
                       с <recp>                                                )




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$affix-transformations$ = $R-NEG$ || $R-ACCE$ || $R-REFL$ || $R-PASS$ || $R-RECP$ || $D-PART$ || $D-POSS$ || \
                          $R-POT$ || $R-NOM$ || $R-CON$  || $R-CSTV$ || $MSC$ || $R-STTY$ || $D-LOD$ || $R-LOD$