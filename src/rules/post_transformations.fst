%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Transformations after vowel harmony
%  Last review:    27/04/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [CHC] Changes consonant depending on open vowel ----------------------------------------------------------------------

% [02] Replaces velar-uvular voiced fricative for velar-uvular voiced stop after trill
% [03] Add-hoc rule to handle: (орт^V^ADJZ#15^VRBLZ#7+CONV#1, орт^V^NMLZ#5^VRBLZ#7+CONV#1 -> ордугургаан)

$R-CHC01$ = х:к ^-> [#verbs#] __ [эө]й <adj-dj>
$R-CHC02$ = ҕ:г ^-> р __ ээ <verb-v>
$R-CHC03$ = ҕ:г ^-> ур __ аа <verb-v>
$R-CHC$ = $R-CHC01$ || $R-CHC02$ || $R-CHC03$



% [R-IVH] Intervocalic һ -----------------------------------------------------------------------------------------------

% If һ appears twice in adjacent syllables separated by a short vowel, then the first of them goes back to с [§111].
% [01] (эһэ^N^NMLZ#1 -> эсэһит)
% [02] (биэс^Num^ORD^ADVZ#9 -> бэсиһин)

$R-IVH01$ = һ:с ^-> [#vowels#] __ [#vowels#] [#stem-types#]+ һ
$R-IVH02$ = һ:с ^-> [#vowels#] __ [#stem-types#]* [#vowels#] һ

$R-IVH$ = $R-IVH01$ || $R-IVH02$

% DEVELOPMENT NOTES:
% Does not work for (өһөс^Adj+ACC -> өһөһү)



% [D-EMP] Final letter deletion ----------------------------------------------------------------------------------------

% [01] (хаамп^V+PART_PRES -> хаамар)
% [02] (сыыҥк^N^VRBLZ#1 -> сыыҥтаа)
% [04] (эмп^N+ACC -> эми)

$D-EMP01$ = п:<> ^-> хаам __ <intr-1c><intr-1c>
$D-EMP02$ = к:<> ^-> ҥ __ [#nouns#]+ [#symbols#]
$D-EMP03$ = т:<> ^-> <begin>түөр __ <card-c><card-c> т
$D-EMP04$ = п:<> ^-> эм __ <noun-1c><noun-1c>

$D-EMP$ = $D-EMP01$ || $D-EMP02$ || $D-EMP03$ || $D-EMP04$

% DEVELOPMENT NOTES: needs to be generalized.



% [D-DIP] Diphthong deletion -------------------------------------------------------------------------------------------

% [01] (ыа^V+PART_PRES -> ыыр)
% [02] (диэ^V+PART_PRES -> диир)

$D-DIP01$ = {ыа}:<> ^-> <begin> __ <tran-1-d-v><tran-1-d-v> ( ыы | аа )
$D-DIP02$ = {иэ}:<> ^-> <begin> [#consonants#] __ (<tran-1v><tran-1v> | <tran-1-d-v><tran-1-d-v>) \
                      [#symbols#]+ (<part1> | <gnd2>)

$D-DIP$ = $D-DIP01$ || $D-DIP02$



% [R-SLT] Exceptions ---------------------------------------------------------------------------------------------------

% [01] Deletes the т in (булт^N^NMLZ#1 -> булчут)
% [03] It seems that after рт the causative is reduced: (кэрт^V+CAUS -> кэртэр)
% [04] Deletes the last vowel in cardinal numbers before certain derivations (алта^Num^COLL#1 -> алтыа)
% [05] Reverts the regressive assimilation лт -> ст produced by [R-RAV] for the case (балыс^N+POSS.3 -> балта) [§133].
% [06] Applied ad-hoc to form (ыарый^V^ADJZ#6 -> ыарытыган)

$D-SLT01$ = т:<> ^-> <begin> бул __ <noun-1c><noun-1c> чут <noun-dc>
$D-SLT02$ = т:<> ^-> <begin> бэр __ <adj-1c><adj-1c> [#symbols#]+ <dat>
$D-SLT03$ = т:<> ^-> рт <tran-1c><tran-1c> __ [аэоө]р <caus-r>
$D-SLT04$ = [эаи]:<> ^-> __ <card-v><card-v> [#symbols#]+ (<ord> | <coll-v> | <coll-c>)
$R-SLT05$ = {дь}:т ^-> <begin> бал __ <noun-2c><noun-2c> [#symbols#]+ <psor>
$R-SLT06$ = с:т ^-> <begin> бал __ <noun-2c><noun-2c> [#symbols#]+ (<psor> | <psor-3>)
$R-SLT07$ = й:т ^-> <begin> ыары __ <intr-2j><intr-2j> ыган <adj-dc>

$R-SLT$ = $D-SLT01$ || $D-SLT02$ || $D-SLT03$ || $D-SLT04$ || $R-SLT05$ || $R-SLT06$ || $R-SLT07$

% DEVELOPMENT NOTES:
% [05] not working



% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$post-transformations$ = $R-IVH$ || $D-EMP$ || $R-CHC$ || $D-DIP$ || $R-SLT$