%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Vowel definitions
%  Last review:     26/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This file defines the set of vowels that are going to be recognized by the transducer.
% The alphabet recognises only lower case characters, therefore, in analysis mode, strings must be converted to
% lowercase before input.

% The code in this file is divided into 3 sections:
% 1. Vowels definition;
% 2. Underspecified vowels;
% 3. Aggregated vowels.




% 1. VOWELS DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Vowels are primary defined as subsets taking into account both backness and roundness features.

#back-unrounded-vowels# = аы
#back-rounded-vowels# = оу
#back-russian-vowels# = е
#front-unrounded-vowels# = эи
#front-rounded-vowels# = өү
#front-russian-vowels# = ёюя




% 2. UNDERSPECIFIED VOWELS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Underspecified vowels are indicated by special symbols that function as placeholders.
% Underspecified vowels are mapped to their corresponding consonant in the context defined by the phonetic rules.
% Vowels placeholders are used to declare allomorphs.

% Mapping between placeholders and vowels:
% <O>  short open vowel
% <C>  short closed vowel
% <LO> long open vowel
% <LC> long closed vowel
% <DI> diphthong

#open-vowel-placeholders# = <O> <LO>
#closed-vowel-placeholders# = <C> <LC>
#diphthong-placeholder# = <DI>

#vowel-placeholders# = #open-vowel-placeholders# #closed-vowel-placeholders# #diphthong-placeholder#




% 3. AGGREGATED VOWELS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Rules operate at different level of generalization, therefore vowels are grouped further in more comprehensive sets.


% Open and closed vowels -----------------------------------------------------------------------------------------------

#open-vowels# = аэоө
#closed-vowels# = ыиуү


% Back and front vowels ------------------------------------------------------------------------------------------------

#back-vowels# = #back-unrounded-vowels# #back-rounded-vowels# #back-russian-vowels#
#front-vowels# = #front-unrounded-vowels# #front-rounded-vowels# #front-russian-vowels#


% Russian vowels -------------------------------------------------------------------------------------------------------

#russian-vowels# = #back-russian-vowels# #front-russian-vowels#


% All vowels -----------------------------------------------------------------------------------------------------------

#surface-vowels# = #open-vowels# #closed-vowels# #russian-vowels#
#vowels# = #surface-vowels# #vowel-placeholders#