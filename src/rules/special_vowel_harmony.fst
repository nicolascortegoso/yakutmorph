%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Special vowel harmony
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



% [R-UOV] Unstressed back low rounded vowel (о) ------------------------------------------------------------------------

$R-UOV01$ = <O>:а     ^-> [<noun-uc> <noun-2uc> <noun-uj> <noun-uv> <propn-uc> <propn-uv>] .* __
$R-UOV02$ = <LO>:{аа} ^-> [<noun-uc> <noun-uj> <noun-uv> <propn-uc> <propn-uv>] .* __

$R-UOV$ = $R-UOV01$ || $R-UOV02$



% [R-SOV] Stressed back low rounded vowel (о) --------------------------------------------------------------------------

% Example: звено, кислород

$R-SOV01$ = <O>:а      ^-> е . * [<noun-sc> <noun-sj> <noun-sv> <adj-sc> <adj-sj> <adj-sv> <propn-sc> <propn-sv>] .* __
$R-SOV02$ = <C>:у      ^-> [<noun-sc> <noun-sj> <noun-sv> <adj-sc> <adj-sj> <adj-sv> <propn-sc> <propn-sv>] .* __
$R-SOV03$ = <LO>:{аа}  ^-> е . * [<noun-sc> <noun-sj> <noun-sv> <adj-sc> <adj-sj> <adj-sv> <propn-sc> <propn-sv>] .* __
$R-SOV04$ = <LC>:уу    ^-> [<noun-sc> <noun-sj> <noun-sv> <adj-sc> <adj-sj> <adj-sv> <propn-sc> <propn-sv>] .* __

% || $R-SOV02$
$R-SOV$ = $R-SOV01$ || $R-SOV03$ || $R-SOV04$



% [R-ROV] Open vowels --------------------------------------------------------------------------------------------------

$R-ROV01$ = <O>:а         ^-> (е .* о .* | у .* е .* | о .* е .* ) __
$R-ROV02$ = <O>:э         ^-> а .* е .* __
$R-ROV03$ = <LO>:{аа}     ^-> (е .* о .* | у .* е .* | о .* е .* и . *) __
$R-ROV04$ = <LO>:{ээ}     ^-> а .* е .* __

$R-ROV$ = $R-ROV01$ || $R-ROV02$ || $R-ROV03$ || $R-ROV04$



% [R-RCV] Closed vowels ------------------------------------------------------------------------------------------------

$R-RCV01$ = <C>:ы         ^-> ([аио] .* е .* | я .* | е .* [ао] .*) __
$R-RCV02$ = <C>:у         ^-> (у .* е .* |  е .* у .*) __
$R-RCV03$ = <C>:и         ^-> е .*  __
$R-RCV04$ = <LC>:{ыы}     ^-> ([аио] .* е .* | я .* | е .* [ао] .*) __
$R-RCV05$ = <LC>:{уу}     ^-> (у .* е .* |  е .* у .*) __
$R-RCV06$ = <LC>:{ии}     ^-> е .*  __

%|| $R-RCV02$ 
$R-RSV$ = $R-RCV01$ || $R-RCV03$ || $R-RCV04$ || $R-RCV05$ || $R-RCV06$



% [R-RSC] Special combinations -----------------------------------------------------------------------------------------

$R-RSC01$ = <C>:ы         ^-> ([уо] .* и .* | и .* [уо] .*) __
$R-RSC02$ = <LC>:{ыы}     ^-> ([уо] .* и .* | и .* [уо] .*) __

$R-RSC$ = $R-RSC01$ || $R-RSC02$




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% More specific rules are applied first to prevent early matching with more general ones.

$special-vowel-harmony$ = $R-ROV03$ %|| $R-RSV$  %$R-UOV$ || $R-SOV$ || $R-ROV$ || $R-RSC$ || $R-RSV$