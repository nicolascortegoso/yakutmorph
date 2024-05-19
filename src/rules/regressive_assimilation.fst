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
% [01] (п:б) (сап^N+POSS.3 -> саба).
% [02] (к:г) (бэлэх^N+POSS.3 -> бэлэҕэ).
% [03] (х:ҕ) (бырах^V^NMLZ2 -> быраҕыы).
% [04] (с:һ) not having a corresponding voiced pair in place and method of articulation, the sibilant с changes to the
% voiced glottal consonant һ.
% [05] (т:д) only at stem endings in лт оr лр (кэрт^V^PART_PRES -> кэрдэр).
% [12] Observed in отут^Num^APPR -> отучча

$R-RAV01$ = п:б ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$R-RAV02$ = к:г ^-> [#vowels#] __ [#stem-types#]+ [#vowels#]
$R-RAV03$ = х:ҕ ^-> [#vowels#] ([#stem-types#] [#stem-types#])? __ [#stem-types#]+ [#vowels#]
$R-RAV04$ = с:һ ^-> [#vowels#] ([#stem-types#] [#stem-types#])? __ [#stem-types#]+ [#vowels#]
$R-RAV05$ = т:{дь} ^-> л __ [#stem-types#]+ [#vowels#]+
$R-RAV06$ = т:д ^-> [лр] ([#stem-types#] [#stem-types#])? __ [#stem-types#]+ [#vowels#]+

$R-RAV$ = $R-RAV01$ || $R-RAV02$ || $R-RAV03$ || $R-RAV04$ || $R-RAV05$ || $R-RAV06$

% DEVELOPMENT NOTES:
% [05] PROBLEM: балыс^N+POSS.1SG -> балтым



% [R-RA] ---------------------------------------------------------------------------------------------------------------

$RA06$ = н:м ^-> [#vowels#] [#stem-types#]* __ [#stem-types#] [#stem-types#] м
$RA07$ = н:ҥ ^-> [#vowels#] ([#stem-types#] [#stem-types#])?  __ [#stem-types#]+ ҥ
$RA08$ = т:п ^-> [#vowels#] ([#stem-types#] [#stem-types#])? __ [#stem-types#] [#stem-types#] п
$RA09$ = т:к ^-> [#vowels# <neg>] __ [#stem-types#] [#stem-types#] к
$RA10$ = ҕ:г ^-> р __ [#stem-types#]+ [#vowels#]

$RA2$ = $RA06$ || $RA07$ || $RA08$ || $RA09$ || $RA10$



% [R-IMI] --------------------------------------------------------------------------------------------------------------

% [01] Applies to monosyllabic imitatives ending in лк (балк^IMIT^VRBLZ#12 -> баллыгыраа) [§561]
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


$regressive-assimilation$ = $R-RAV$ || $RA2$ || $R-IMI$ || $RB1$
