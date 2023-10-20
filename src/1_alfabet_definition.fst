%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Document index:  1. Alphabet definition
%  Description:     This section defines the characters that are going to be recognized by the transducer.
%  Last review:     19/10/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%% NOTES: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All character are lower case, therefore, in analysis mode, strings must be converted to lowercase before input.




% 1.1 Vowel definition -------------------------------------------------------------------------------------------------


#back-unrounded-vowels# = аы
#back-rounded-vowels# = оу
#back-russian-vowels# = е
#front-unrounded-vowels# = эи
#front-rounded-vowels# = өү
#front-russian-vowels# = ёюя
#back-vowels# = #back-unrounded-vowels# #back-rounded-vowels# #back-russian-vowels#
#front-vowels# = #front-unrounded-vowels# #front-rounded-vowels# #front-russian-vowels#
#open-vowels# = аэоө <O> <LO>
#closed-vowels# = ыиуү <C> <LC>
#russian-vowels# = #back-russian-vowels# #front-russian-vowels#
#vowels# = #open-vowels# #closed-vowels# #russian-vowels# <DI> <A>


% 1.2 Consonant definition ---------------------------------------------------------------------------------------------


#unvoiced-stops# = птк
#voiced-stops# = бдг
#stops# = #unvoiced-stops# #voiced-stops#
#unvoiced-russian-fricatives# = фш
#voiced-russian-fricatives# = взж
#unvoiced-fricatives# = схһ #unvoiced-russian-fricatives#
#voiced-fricatives# = ҕ #voiced-russian-fricatives#
#fricatives# = #unvoiced-fricatives# #voiced-fricatives#
#nasals# = мнҥ
#approximants# = лрй
#russian-composite# = цщ
#composite# = ч #russian-composite#
#symbols# = ьъ
#consonant-placeholders# = <B> <D1> <D2> <V> <H> <K>
#non-nasals# = #stops# #fricatives#
#consonants# = #stops# #fricatives# #nasals# #approximants# #consonant-placeholders# #composite# #symbols#


% Letter definition ----------------------------------------------------------------------------------------------------

#letters# = #vowels# #consonants#
