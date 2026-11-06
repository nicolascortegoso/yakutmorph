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

% [02] Replaces velar-uvular voiced fricative for velar-uvular voiced stop after trill.
% [03] Add-hoc rule to handle: орт+V+ADJZ#15+VRBLZ#7+CONV#1, орт+V+NMLZ#5+VRBLZ#7+CONV#1 -> ордугургаан
% [04] Add-hoc rule to handle: бөлтөй+V+ADJZ#8 -> бөлтөгөр
% [05] Add-hoc rule to handle: салҕаа+V+CONV#2 -> салгыы

$R-CHC01$ = х:к ^-> [#verbs#] __ [эө]й <adj-dj>
$R-CHC02$ = ҕ:г ^-> __ ээ? <verb-v>
$R-CHC03$ = ҕ:г ^-> ур __ аа <verb-v><verb-v>
$R-CHC04$ = ҕ:г ^-> ө <intr-2j><intr-2j>  __ өр <adj-dc>
$R-CHC05$ = ҕ:г ^-> <begin> сал __ <tran-2v><tran-2v>


$R-CHC$ = $R-CHC01$ || $R-CHC02$ || $R-CHC03$ || $R-CHC04$ || $R-CHC05$



% [R-IVH] Intervocalic һ -----------------------------------------------------------------------------------------------

% If һ appears twice in adjacent syllables separated by a short vowel, then the first of them goes back to с [§111].
% [01] (эһэ+N+NMLZ#1 -> эсэһит)
% [02] (биэс+Num+ORD+ADVZ#9 -> бэсиһин)

$R-IVH01$ = һ:с ^-> [#vowels#] __ [#vowels#] [#stem-types#]+ һ
$R-IVH02$ = һ:с ^-> [#vowels#] __ [#stem-types#]* [#vowels#] [#stem-types#]* һ


$R-IVH$ = $R-IVH01$ || $R-IVH02$

% DEVELOPMENT NOTES:
% Does not work for (өһөс+Adj+ACC -> өһөһү)
% Does not work for (диэ+V+RECP+RECP+CONV#1 -> дэсиһэн)


% [D-EMP] Final letter deletion ----------------------------------------------------------------------------------------

% [01] (хаамп+V+PART_PRES -> хаамар), (үөмп+V+CONV#1 -> үөмэн)
% [02] (сыыҥк+N+VRBLZ#1 -> сыыҥтаа)
% [04] (эмп+N+ACC -> эми)
% [05] removes doubled consonant: илт+V+CAUS -> илтэр

$D-EMP01$ = п:<> ^-> үөм __ <intr-1c><intr-1c>
$D-EMP02$ = к:<> ^-> ҥ __ [#nouns#]+ [#symbols#]
$D-EMP03$ = т:<> ^-> <begin>түөр __ <card-c><card-c> т
$D-EMP04$ = п:<> ^-> эм __ <noun-1c><noun-1c>
$D-EMP05$ = м:<> ^-> м <refl><refl> __ т[#vowels#]ҕ[#vowels#]й
$D-EMP06$ = т:<> ^-> л __ <tran-1c><tran-1c> т[#vowels#]р <caus-r>
$D-EMP07$ = т:<> ^-> <intr-1r> т <cstv-c><cstv-c>  __ [#vowels#] <past>
$D-EMP08$ = п:<> ^-> хаам __ <tran-1c><tran-1c>

$D-EMP$ = $D-EMP01$ || $D-EMP02$ || $D-EMP03$ || $D-EMP04$ || $D-EMP05$ || $D-EMP06$ || $D-EMP07$ || $D-EMP08$

% DEVELOPMENT NOTES: needs to be generalized.



% [D-DIP] Diphthong deletion -------------------------------------------------------------------------------------------

% [01] (ыа+V+PART_PRES -> ыыр)
% [02] (диэ+V+PART_PRES -> диир)

$D-DIP01$ = {ыа}:<> ^-> <begin> __ <tran-1-d-v><tran-1-d-v> ( ыы | аа )
$D-DIP02$ = {иэ}:<> ^-> <begin> [#consonants#] __ (<tran-1v><tran-1v> | <tran-1-d-v><tran-1-d-v>) \
                      [#symbols#]+ (<part1> | <gnd2>)

$D-DIP$ = $D-DIP01$ || $D-DIP02$



% [D-SLT] Exceptions (delete) ------------------------------------------------------------------------------------------

% [01] Deletes the т in (булт+N+NMLZ#1 -> булчут) (булт+N+VRBLZ#1 -> бултаа)
% [02] Deletes the т in (бэрт+Adj+DAT -> бэркэ)
% [03] It seems that after рт the causative is reduced: (кэрт+V+CAUS -> кэртэр)
% [04] Deletes the last vowel in cardinal numbers before certain derivations (алта+Num+COLL#1 -> алтыа)
% [05] Applied ad-hoc to form (кыһын+Adv+DIM#1a -> кыһыары) [§707]
% [06] Applied ad-hoc to form устун+POST+INST
% [07] Observed in илт+V+PST.3SG -> илтэ

$D-SLT01$ = т:<>     ^-> <begin> бул __ <noun-1c><noun-1c> ( чут <noun-dc> | т)
$D-SLT02$ = т:<>     ^-> <begin> бэр __ <adj-1c><adj-1c> [#symbols#]+ <dat>
$D-SLT03$ = т:<>     ^-> рт <tran-1c><tran-1c> __ ([аэоө]р <caus-r> | [ыиуү]м <past>)
$D-SLT04$ = [эаи]:<> ^-> __ <card-v><card-v> [#symbols#]+ (<ord> | <coll-v>)
$D-SLT05$ = {ын}:<>  ^-> <begin> кыһ __ <adv-2c><adv-2c> ыары <adv-dv>
$D-SLT06$ = {ун}:<>  ^-> <begin> устун <post-c><post-c> __ ан <case-c>
$D-SLT07$ = т:<>     ^-> л __ <tran-1c><tran-1c> т[аэоө] <past>
$D-SLT08$ = т:<>     ^-> <begin> бэрт <adj-1c><adj-1c> __ эр <plur>

$D-SLT$ = $D-SLT01$ || $D-SLT02$ || $D-SLT03$ || $D-SLT04$ || $D-SLT05$ || $D-SLT06$ || \
          $D-SLT07$ || $D-SLT08$



% [R-SLT] Exceptions (replace) -----------------------------------------------------------------------------------------

% [01] Reverts regressive assimilation лт -> ст produced by [R-RAV] for the case (балыс+N+POSS.3 -> балта) [§133].
% [02] Applied ad-hoc to form (ыарый+V+ADJZ#6 -> ыарытыган)
% [03] Applied ad-hoc to form (түм+V+NMLZ#6 -> тимэх) [§179]
% [04] Observed in (куруук+Adv+AUG#3 -> куруутун)
% [05] Reverts regressive assimilation к -> т
% [06] Combinations of personal pronouns with possessive affixes (exception third person singular).
% [07] Reverts regressive assimilation ҕ -> х (хаах+IMIT+VRBLZ#16 -> хаахынаа)
% [08] Reverts regressive assimilation д -> т (үөр+V+CSTV+CONV#1 -> үөртэн)
% [09] Special word балис (younger sister)

$R-SLT01$ = {дь}:т ^-> <begin> бал __ <noun-2c><noun-2c> [#symbols#]+ <psor>
$R-SLT02$ = с:т    ^-> <begin> бал __ <noun-2c><noun-2c> [#symbols#]+ (<psor> | <psor-3>)
$R-SLT03$ = й:т    ^-> <begin> ыары __ <intr-2j><intr-2j> ыган <adj-dc>
$R-SLT04$ = ү:и    ^-> <begin> т __ м <tran-1c><tran-1c> эх <noun-dc>
$R-SLT05$ = г:т    ^-> <begin> куруу __ <adv-2c><adv-2c> ун <adv-dv>
$R-SLT06$ = т:н    ^-> ги <prs><prs> __ э <psor-3>
$R-SLT07$ = ҕ:х    ^-> __ <imi-x><imi-x> [ыиуү]н
$R-SLT08$ = д:т    ^-> р <intr-1r><intr-1r> __ <cstv-c><cstv-c> [аэоө]н <gnd1>
$R-SLT09$ = г:т    ^-> <begin>бал __ <noun-2c><noun-2c> ы

$R-SLT$ = $R-SLT01$ || $R-SLT02$ || $R-SLT03$ || $R-SLT04$ || $R-SLT05$ || $R-SLT06$ || \
          $R-SLT07$ || $R-SLT08$ || $R-SLT09$


% [I-RED] Consonant reduplication ---------------------------------------------------------------------------------------

% Observed in бэйэккэлээх

$I-RED$ = к:{кк}   ^->? <begin> бэйэ <noun-2v><noun-2v> __ э <dim>


% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$post-transformations$ = $R-IVH$ || $D-EMP$ || $R-CHC$ || $D-DIP$ || $D-SLT$ || $R-SLT$ || $I-RED$