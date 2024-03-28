%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Consonant cluster reduction
%  Last review:    27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Observed in Russian loan words. The final consonant must be dropped before applying progressive assimilation.
% For example: студент^N+PL -> студеннар.

% The confluence of two consonants in the end of a word is quite rare phenomenon in Yakut. Frequently sonorants р with
% plosives т like: бэрт, тарт, түөрт, and single combinations like: булт, эмп, үҥк [§749].


% Ending consonant clusters --------------------------------------------------------------------------------------------

% [03] Example: председатель

$D-CLS01$ = т:<> ^-> [ксн] __ [#propns-c# #nouns-c#]+ [#symbols#]
$D-CLS02$ = д:<> ^-> з __ [#propns-c# #nouns-c#]+ [#symbols#]
$D-CLS03$ = ь:<> ^-> л __ [#propns-c# #nouns-c#]+ [#symbols#]




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$consonant-clusters$ = $D-CLS01$ || $D-CLS02$ || $D-CLS03$