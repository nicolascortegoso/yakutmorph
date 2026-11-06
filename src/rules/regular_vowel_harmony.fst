%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Vowel harmony
%  Last review:    27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% There are strict restrictions on the use of vowels in adjacent syllables or within the word as a whole based on
% their palatality and labiality. One word can contain:
% - either only front vowels or only back vowels;
% - only labial vowels or labials, followed by oral vowels.
% These restrictions are consistent and represent a phonetic law called vowel harmony [§19].

% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Vowel harmony realizes the vowels from affixes in context:
% <O>  short back vowel
% <C>  short front vowel
% <LO> long back vowel
% <LC> long front vowel
% <DI> diphthong



% [R-VHOC] Low (open) vowels -------------------------------------------------------------------------------------------

$R-VHO01$ = <O>:а     ^-> ([#back-unrounded-vowels#] .*) | ([уюя] .* ) | (о .* [<LC><C><DI>] .* ) __
$R-VHO02$ = <O>:э     ^-> ([#front-unrounded-vowels#] .*) | (ө .* [<LC><C><DI>] .*) | (ү .*) __
$R-VHO03$ = <O>:о     ^-> [#back-rounded-vowels#] .* __
$R-VHO04$ = <O>:ө     ^-> [#front-rounded-vowels#] .*  __
$R-VHO05$ = <LO>:{аа} ^-> ([#back-unrounded-vowels#] .*) | ([уюя] .* ) | (о .* [<LC><C><DI>] .*)  __
$R-VHO06$ = <LO>:{ээ} ^-> ([#front-unrounded-vowels#] .*) | (ө .* [<LC><C><DI>] .*) | (ү .*) __
$R-VHO07$ = <LO>:{оо} ^-> [#back-rounded-vowels#] .* __
$R-VHO08$ = <LO>:{өө} ^-> [#front-rounded-vowels#] .*  __

$R-VHO$ = $R-VHO01$ || $R-VHO02$ || $R-VHO03$ || $R-VHO04$ || $R-VHO05$ || $R-VHO06$ || $R-VHO07$ || $R-VHO08$



% [R-VHC] High (closed) vowels -----------------------------------------------------------------------------------------

$R-VHC01$ = <C>:ы     ^-> [#back-unrounded-vowels#] .* __
$R-VHC02$ = <C>:и     ^-> [#front-unrounded-vowels#] .* __
$R-VHC03$ = <C>:у     ^-> ([#back-rounded-vowels#] .*  | а .* о .*) __
$R-VHC04$ = <C>:ү     ^-> [#front-rounded-vowels#] .* __
$R-VHC05$ = <LC>:{ыы} ^-> [#back-unrounded-vowels#] .* __
$R-VHC06$ = <LC>:{ии} ^-> [#front-unrounded-vowels#] .* __
$R-VHC07$ = <LC>:{уу} ^-> ([#back-rounded-vowels#] .* | а .* о .*) __
$R-VHC08$ = <LC>:{үү} ^-> [#front-rounded-vowels#] .* __

$R-VHC$ = $R-VHC01$ || $R-VHC02$ || $R-VHC03$ || $R-VHC04$ || $R-VHC05$ || $R-VHC06$ || $R-VHC07$ || $R-VHC08$



% [R-VHD] Diphthongs ---------------------------------------------------------------------------------------------------

$R-VHD01$ = <DI>:{ыа} ^-> [ыа] .* __
$R-VHD02$ = <DI>:{иэ} ^-> [иэ] .* __
$R-VHD03$ = <DI>:{уо} ^-> [уо] .* __
$R-VHD04$ = <DI>:{үө} ^-> [үө] .* __

$R-VHD$ = $R-VHD01$ || $R-VHD02$ || $R-VHD03$ || $R-VHD04$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% More specific rules are applied first to prevent early matching with more general ones.

$regular-vowel-harmony$ = $R-VHO$ || $R-VHC$ || $R-VHD$