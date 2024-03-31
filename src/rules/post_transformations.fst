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

$R-CHC01$ = х:к ^-> [#verbs#] __ [эө]й <adj-dj>
$R-CHC02$ = ҕ:г ^-> р __ ээ <verb-v>
$R-CHC$ = $R-CHC01$ || $R-CHC02$


% [R-IVH] Intervocalic һ -----------------------------------------------------------------------------------------------

% If һ appears twice in adjacent syllables separated by a short vowel, then the first of them goes back to с [§111].
% [01] эһэ^N^NMLZ1 -> эсэһит
% [02] биэс^Num^ORD^ADVZ9 -> бэсиһин

$R-IVH01$ = һ:с ^-> [#vowels#] __ [#vowels#] [#stem-types#]+ һ
$R-IVH02$ = һ:с ^-> [#vowels#] __ [#stem-types#]* [#vowels#] һ

$R-IVH$ = $R-IVH01$ || $R-IVH02$


% [R-HR] Intervocalic р ------------------------------------------------------------------------------------------------

%$R-HR$ = р:һ ^-> [#vowels#] __ <tran-2r><tran-2r> [#symbols#]+ (<refl> | <pass>)                % оҥор+ун -> оҥоһун

% DEVELOPMENT NOTES: not applied


% [D-EMP] Final letter deletion ----------------------------------------------------------------------------------------

% [02] сыыҥк^N^VRBLZ1 -> сыыҥтаа

$D-EMP01$ = п:<> ^-> хаам __ <intr-1c><intr-1c>
$D-EMP02$ = к:<> ^-> ҥ __ [#nouns#]+ [#symbols#]
$D-EMP03$ = т:<> ^-> <begin>түөр __ <card-c><card-c> т

$D-EMP$ = $D-EMP01$ || $D-EMP02$ || $D-EMP03$


% [D-DIP] Diphthong deletion -------------------------------------------------------------------------------------------

% [01] диэ^V^PART_PRES -> диир

$D-DIP$ = {иэ}:<> ^-> <begin> [#consonants#] __ (<tran-1v><tran-1v> | <tran-1-d-v><tran-1-d-v>) \
                      [#symbols#]+ (<part1> | <gnd2>)


% [R-SLT] Exceptions ---------------------------------------------------------------------------------------------------

% [01] Deletes the т in булт^N^NMLZ1 -> бултчут
% [03] Deletes the last vowel in cardinal numbers before certain derivations (алта^Num^COLL -> алтыа).
% [04] Reverts the regressive assimilation лт -> ст produced by [R-RAV] for the case (балыс^N+POSS.3 -> балта) [§133].

$D-SLT01$ = т:<> ^-> <begin> бул __ <noun-1c><noun-1c> чут <noun-dc>
$D-SLT02$ = т:<> ^-> <begin> бэр __ <adj-1c><adj-1c> [#symbols#]+ <dat>
$D-SLT03$ = [эаи]:<> ^-> __ <card-v><card-v> [#symbols#]+ (<ord> | <coll-v> | <coll-c>)
$R-SLT04$ = с:т ^-> <begin> бал __ <noun-2c><noun-2c> [#symbols#]+ (<psor> | <psor-3>)

$R-SLT$ = $D-SLT01$ || $D-SLT02$ || $D-SLT03$ || $R-SLT04$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$post-transformations$ = $R-IVH$ || $D-EMP$ || $R-CHC$ || $D-DIP$ || $R-SLT$