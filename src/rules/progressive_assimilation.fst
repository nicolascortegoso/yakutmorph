%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Progressive consonant assimilation
%  Last review:    27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Progressive assimilation: the consonants at the junction of morphemes must occur only in one of their phonetic
% alternatives [§123].

% Mapping between placeholders and consonants:
% <B>   bilabials {п, б, м}
% <D1>  dental-alveolars {т, д, н, л} (in context 1)
% <D2>  dental-alveolars {т, д, н, л} (in context 2)
% <V>   velar-uvulars {ҕ, г, к, х, ҥ} (extended scope)
% <K>   velar-uvulars {г, к, ҥ} (narrower scope)
% <H>   consonants {һ, с, ч, дь, нь}

% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [R-PAT] Front consonants (context 1) ---------------------------------------------------------------------------------

% Occurs at the beginning of affixes that start with т [§114]:
% Examples:
% possessive -лаах (<D2><LO>х)
% plural -лар (<D2><O>р)
% adverb -лыы (<D2><LC>)

$R-PAT01$ = <D1>:н ^-> кки <prs><prs> __ <LO>ҕ<O>р <case-c>
$R-PAT02$ = <D1>:т ^-> [#stem-types#]+ __ [#stem-types#][<end>]
$R-PAT03$ = <D1>:т ^-> [#vowels# #unvoiced-stops# сх зч <D1>] [#stem-types#]+ __
$R-PAT04$ = <D1>:л ^-> л [#stem-types#]+ __
$R-PAT05$ = <D1>:д ^-> [йр] [#stem-types#]+ __
$R-PAT06$ = <D1>:н ^-> [#nasals#] [#stem-types#]+ __

$R-PAT$ = $R-PAT01$ || $R-PAT02$ || $R-PAT03$ || $R-PAT04$ || $R-PAT05$ || $R-PAT06$



% [R-PAL] Front consonants (context 2) ---------------------------------------------------------------------------------

% Occurs at the beginning of affixes that start with л [§114]:
% -тааҕа (adjectives)
% -тыҥы (adjectives)
% -тый (verbs)
% -та (partitive case)
% -тах (participles)

$R-PAL01$ = <D2>:н ^-> кки <prs><prs> __ [#symbols#]+ <case-c>
$R-PAL02$ = <D2>:л ^-> [#vowels# л] [#stem-types#]+ __
$R-PAL03$ = <D2>:т ^-> [#unvoiced-stops# схд жзчвц] [#stem-types#]+ __
$R-PAL04$ = <D2>:д ^-> [йр] [#stem-types#]+ __
$R-PAL05$ = <D2>:н ^-> [#nasals#] [#stem-types#]+ __

$R-PAL$ = $R-PAL01$ || $R-PAL02$ || $R-PAL03$ || $R-PAL04$ || $R-PAL05$



% [R-PAB] Bilabials ----------------------------------------------------------------------------------------------------

% Occurs mainly in affixes -м/-ма (&all), -бын (&all) и -быт (&all) [§113].

$R-PAB01$ = <B>:б ^-> [#vowels# йрл] [#stem-types#]+ __
$R-PAB02$ = <B>:п ^-> [#unvoiced-stops# сх з] [#stem-types#]+ __
$R-PAB03$ = <B>:м ^-> [#nasals#] [#stem-types#]+ __

$R-PAB$ = $R-PAB01$ || $R-PAB02$ || $R-PAB03$



% [R-PAH] Middle consonants --------------------------------------------------------------------------------------------

% Occurs before the affix -һыт [§123].

$R-PAH01$ = <H>:һ    ^-> [#vowels#] [#stem-types#]+ __
$R-PAH02$ = <H>:с    ^-> [кх] [#stem-types#]+ __
$R-PAH03$ = <H>:ч    ^-> [#unvoiced-stops# сх] [#stem-types#]+ __
$R-PAH04$ = <H>:{дь} ^-> [лйр] [#stem-types#]+ __
$R-PAH05$ = <H>:{нь} ^-> [#nasals#] [#stem-types#]+ __

$R-PAH$ = $R-PAH01$ || $R-PAH02$ || $R-PAH03$ || $R-PAH04$ || $R-PAH05$



% [R-PAG] Posterior and uvular consonants (narrow context) -------------------------------------------------------------

$R-PAK01$ = <K>:ҕ ^-> [#open-vowels#] [#stem-types#]+ __
$R-PAK02$ = <K>:г ^-> [#closed-vowels#] [#stem-types#]+ __
$R-PAK03$ = <K>:к ^-> [#nasals#] [#stem-types#]+ __

$R-PAK$ = $R-PAK01$ || $R-PAK02$ || $R-PAK03$



% [R-PAG] Posterior and uvular consonants (broad context) --------------------------------------------------------------

% Occurs in the following affixes among others [§127]:
% -ҕа (dat. case of simple declension)
% -ҕын (2 person singular)
% -ҕыт (2 person plural)

$R-PAG01$ = <V>:х ^-> ((иэ|<DI>) [#prons#]+ | уох [#prons#]+ | <DI><dem><dem> | <DI><int-p><int-p> | х [#stem-types#]+)  __
$R-PAG02$ = <V>:ҕ ^-> [#open-vowels# #open-vowel-placeholders# #russian-vowels# <DI>] [#stem-types#]+ __
$R-PAG03$ = <V>:г ^-> [#closed-vowels# #closed-vowel-placeholders# лйр] [#stem-types#]+ __
$R-PAG04$ = <V>:к ^-> [#stops# сжзв] [#stem-types#]+ __
$R-PAG05$ = <V>:ҥ ^-> [#nasals#] [#stem-types#]+ __

$R-PAG$ = $R-PAG01$ || $R-PAG02$ || $R-PAG03$ || $R-PAG04$ || $R-PAG05$



% [R-PAS] --------------------------------------------------------------------------------------------------------------

$R-PAS01$ = <S>:с ^-> [мҥх] [#stem-types#]+ __
$R-PAS02$ = <S>:т ^-> [#vowels# стк] [#stem-types#]+ __
$R-PAS03$ = <S>:л ^-> [л] [#stem-types#]+ __
$R-PAS04$ = <S>:д ^-> [йр] [#stem-types#]+ __
$R-PAS05$ = <S>:н ^-> [н] [#stem-types#]+ __

$R-PAS$ = $R-PAS01$ || $R-PAS02$ || $R-PAS03$ || $R-PAS04$ || $R-PAS05$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$progressive-assimilation$ = $R-PAT$ || $R-PAL$ || $R-PAB$ || $R-PAH$ || $R-PAK$ || $R-PAG$ || $R-PAS$
