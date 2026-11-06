%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Consonant definitions
%  Last review:     27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This file defines the set of vowels that are going to be recognized by the transducer.
% The alphabet recognises only lower case characters, therefore, in analysis mode, strings must be converted to
% lowercase before input.

% The code in this file is divided into 3 sections:
% 1. Consonants definitions;
% 2. Underspecified consonants;
% 3. Aggregated consonants.




% 1. CONSONANTS DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defines the set of consonants in the alphabet.
% Yakut language has 19 consonant phonemes: б, г, ҕ, д, дь, й, к, л, м, н, нь, ҥ, п, р, с, һ, т, ч, ч [§26].
% Digraphs {дь, нь} are implemented as a combination of д + ь and н + ь.
% Consonants в, ж, з, ц, ш, щ are found only in Russian loan words [§26].

% Defines consonants and aggregates them in subsets.
% According to the place of articulation, Yakut consonants are divided into: bilabial, dental/alveolar, palatal,
% velar/uvular, and glotal.
% By manner of articulation, they are further divided into stops, fricatives, and trills [Ubryatova, 1982, p. 54].
% Consonants can be voiced or unvoiced.
% Consonants {ч, ц, щ} are considered composites.

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




% 2. UNDERSPECIFIED CONSONANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Underspecified consonants are indicated by special symbols that function as placeholders.
% Underspecified consonants are mapped to their corresponding consonant in the context defined by the phonetic rules.
% Consonants placeholders are used to declare allomorphs.

% Mapping between placeholders and consonants:
% <B>   bilabials {п, б, м}
% <D1>  dental-alveolars {т, д, н, л} (context 1)
% <D2>  dental-alveolars {т, д, н, л} (context 2)
% <V>   velar-uvulars {ҕ, г, к, х, ҥ} (extended scope)
% <K>   velar-uvulars {г, к, ҥ} (narrower scope)
% <H>   consonants {һ, с, ч, дь, нь}
% <S>   consonants {һ, с, ч, дь, нь} special case

#consonant-placeholders# = <B> <D1> <D2> <V> <H> <K> <S>




% 3. AGGREGATED CONSONANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#surface-consonants# = #stops# #fricatives# #nasals# #approximants# #composite# #symbols#
#consonants# = #surface-consonants# #consonant-placeholders#