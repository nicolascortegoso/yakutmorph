%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Special insertions
%  Last review:    27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [I-S] Inserts a sibilant before affixation ---------------------------------------------------------------------------

$I-S$ = э:{эс} ^-> сүүрб __ <card-v>+ <C>с <ord>   % сүүрбэ+ис -> сүүрбэһис



% [I-CV] Inserts a close vowel before affixes --------------------------------------------------------------------------

% [01] special cases for сырыт and ыарыт
% [14] Nominals ending with т that lose the closed-vowel in the final syllable (өрүт^N+POSS.1PL+DAT -> өттүбүтүгэр)
% [15] Nominals ending with н that lose the closed-vowel in the final syllable (алын^N+PL+POSS.3SG+ACC -> анныларын)
% [16] when followed by other affixes (CHECK NOT APPLIED)

$I-CV01$ = ь:{ь<C>}       ^-> лд __ (<intr-2c><intr-2c>   | <intr-2j><intr-2j>) [#consonants# <B>]
$I-CV02$ = д:{д<C>}       ^->    __ (<intr-2nl><intr-2nl> | <tran-2c><tran-2c>) <B><C>т <part2>
$I-CV03$ = л:{л<C>}       ^-> (<tran-1l><tran-1l> | <tran-1r><tran-1r>) __ <refl><refl> <B><C>т <part2>
$I-CV04$ = <D1>:{<D1><C>} ^-> __ <refl><refl> <B><C>т <part2>
$I-CV05$ = л:{л<C>}       ^-> л __ <pass><pass> (<B><O>т <part1-n> | <B><C>[тч] <part2> | <B><O> <neg>)
$I-CV06$ = с:{с<C>}       ^-> [#stem-types#] __ <recp><recp>   ( \
                              <B><O>т           <part1-n><end> | \
                              <B><C>[тч]        <part2>        | \
                              <B><O>            <neg>          )
$I-CV07$ = с:{с<C>}       ^-> [#consonants#] __ (<intr-2c><intr-2c> | <tran-2c><tran-2c>) ( \
                              <B><O>т           <part1-n>      | \
                              <B><C>т           <part2>        | \
                              <B><O>            <neg>          )
$I-CV08$ = т:{т<C>} ^-> [#consonants#] __ (<intr-2nl><intr-2nl> | <intr-2c><intr-2c> | <tran-2c><tran-2c>) \
                        (<B><O> <neg> | <B><O>т <part1-n> | <B><C>т <part2>)
$I-CV09$ = т:{т<C>} ^-> р <intr-2r><intr-2r> __ <cstv-c><cstv-c> \
                        (<B><C>т <part2> | <B><O>т <part1-n>)
$I-CV10$ = т:{т<C>} ^-> р <tran-2r><tran-2r> __ <caus-c><caus-c> \
                        (<B><C>т <part2> | <B><O>т <part1-n>)
$I-CV11$ = н:{н<C>} ^-> [#consonants#] __ (<intr-2nl><intr-2nl> | <tran-2c><tran-2c>) \
                        (<B><C>т <part2> | <B><O>т <part1-n>)
$I-CV12$ = л:{л<C>} ^-> [#consonants#] __ <intr-2nl><intr-2nl> \
                        (<B><C>т <part2> | <B><O>т <part1-n>)
$I-CV13$ = <noun-2c>:{<noun-2c><C>}  ^-> [нт] <noun-2c> __ [ҥгк]<C> <adj-dv>

$I-CV14$ = н:{н<C>} ^-> н __ <noun-2c><noun-2c> (<D2> | <B> | <V>)
$I-CV15$ = т:{т<C>} ^-> т __ <noun-2c><noun-2c> (<B> | <D2><O>р <plur>)
$I-CV16$ = с:{с<C>} ^-> х __ <noun-2c><noun-2c> (<D2> | <B> | <V>)


$I-CV$ = $I-CV01$ || $I-CV02$ || $I-CV03$ || $I-CV04$ || $I-CV05$ || $I-CV06$ || $I-CV07$ || $I-CV08$ || \
         $I-CV09$ || $I-CV10$ || $I-CV11$ || $I-CV12$ || $I-CV13$ || $I-CV14$ || $I-CV15$ || $I-CV16$



% [R-HR] Intervocalic р ------------------------------------------------------------------------------------------------

% [01] It was observed to change in (оҥор^V^REFL -> оҥоһун instead of оҥорун).

$R-HR01$ = р:с ^-> <begin> оҥо __ <tran-2r><tran-2r> [#symbols#]+ [<refl> <pass>]
$R-HR$ = $R-HR01$

% DEVELOPMENT NOTES:
% Not applied. Check [§517] for explanation.



% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$special-insertions$ = $I-S$ || $I-CV$