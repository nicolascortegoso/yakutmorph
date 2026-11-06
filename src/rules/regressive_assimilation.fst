%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Regressive consonant assimilation rules
%  Last review:    01/11/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Regressive consonant assimilation changes the last consonant of a stem in intervocalic position.


% [R-RAV] Voiceless to voiced ------------------------------------------------------------------------------------------

% Voiceless consonants changes to it voiced pair at the end of a stem before an affix beginning with a vowel [§111]:
% [01] (п:б) (сап+N+POSS.3 -> саба).
% [02] (к:г) (бэлэх+N+POSS.3 -> бэлэҕэ).
% [03] (х:ҕ) (бырах+V+NMLZ2 -> быраҕыы).
% [04] (с:һ) not having a corresponding voiced pair in place and method of articulation, the sibilant с changes to the
% voiced glottal consonant һ.
% [05] (т:г) observed in (кырт+V+RECP) -> кыргыс
% [06] (т:д) only at stem endings in лт оr лр (кэрт+V+PART_PRES -> кэрдэр).
% [12] Observed in отут+Num+APPR -> отучча

$R-RAV01$ = п:б    ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$R-RAV02$ = к:г    ^-> [#vowels#] [лр]? __ [#stem-types#]+ [#vowels#]
$R-RAV03$ = х:ҕ    ^-> [#vowels#] ([#stem-types#] [#stem-types#])? __ [#stem-types#]+ [#vowels#]
$R-RAV04$ = с:һ    ^-> [#vowels#] ([#stem-types#] [#stem-types#])? __ [#stem-types#]+ [#vowels#]
$R-RAV05$ = т:г    ^-> (ал|ыр) __ [#stem-types#]+ [#vowels#]+
$R-RAV06$ = т:{дь} ^-> л __ [#stem-types#]+ [#vowels#]+
$R-RAV07$ = т:д    ^-> [лр] ([#stem-types#] [#stem-types#])? __ [#stem-types#]+ [#vowels#]+

$R-RAV$ = $R-RAV01$ || $R-RAV02$ || $R-RAV03$ || $R-RAV04$ || $R-RAV05$ || $R-RAV06$ || $R-RAV07$

% DEVELOPMENT NOTES:
% [05] PROBLEM: балыс+N+POSS.1SG -> балтым
% [07] хаал+V+CSTV+ITER#2+PART_PRES long vowel deletion should be take place after regressive assimilation



% [R-RA] ---------------------------------------------------------------------------------------------------------------

% [06] observed in киэн+N+VRBLZ#5 -> киэмсий
% [11] Added to produce хамнас+N+NMLZ#1 -> хамначчыт, but does not apply to тылбаас+N+NMLZ#1 -> тылбаасчыт


$RA06$ = н:м ^-> [#vowels#] [#stem-types#]* __ [#stem-types#] [#stem-types#] [мс]
$RA07$ = н:ҥ ^-> [#vowels#] ([#stem-types#] [#stem-types#])?  __ [#stem-types#]+ ҥ
$RA08$ = т:п ^-> [#vowels#] ([#stem-types#] [#stem-types#])? __ [#stem-types#] [#stem-types#] п
$RA09$ = т:к ^-> [#vowels# <neg>] __ [#stem-types#] [#stem-types#] к
$RA10$ = ҕ:г ^-> [йр] __ [#stem-types#]+ [#vowels#]
$RA11$ = с:ч ^-> [#consonants#] [#vowels#] __ <noun-2c><noun-2c> ч<C>т <noun-dc>

$RA2$ = $RA06$ || $RA07$ || $RA08$ || $RA09$ || $RA10$ || $RA11$



% [R-CAUS] Causative ---------------------------------------------------------------------------------------------------

% Regressive assimilation causatives.

$R-CAUS$ = т:ч ^-> __ (<cstv-c><cstv-c> | <caus-c><caus-c>) ч<C> <adv-dv>



% [R-IMI] --------------------------------------------------------------------------------------------------------------

% [01] Applies to monosyllabic imitatives ending in лк (балк+IMIT+VRBLZ#12 -> баллыгыраа) [§561]
% [02-03] [§563]

$R-IMI01$ = {пт}:{бдь} ^-> __ <imi-c><imi-c> <C>
$R-IMI02$ = п:{бдь}    ^-> __ <imi-c><imi-c> <C>
$R-IMI03$ = {ьт}:{дь}  ^-> л __ <imi-c><imi-c> <C>
$R-IMI04$ = к:{дь}     ^-> л __ <imi-c><imi-c> <C>
$R-IMI05$ = к:л        ^-> __ <imi-c><imi-c> <C>
$R-IMI06$ = п:б        ^-> __ <imi-p><imi-p> <C>

$R-IMI$ = $R-IMI01$ || $R-IMI02$ || $R-IMI03$ || $R-IMI04$ || $R-IMI05$ || $R-IMI06$



% [RB] Russian load words ----------------------------------------------------------------------------------------------

$RB01$ = ч:һ ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$RB02$ = з:һ ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$RB03$ = п:б ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]

$RB1$ = $RB01$ || $RB02$ || $RB03$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$regressive-assimilation$ = $R-RAV$ || $RA2$ || $R-CAUS$ || $R-IMI$ || $RB1$
