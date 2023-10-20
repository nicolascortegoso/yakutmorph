%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Document index: 5. Morphotactics
%  Description:    This section concatenates suffixes to lexical roots and filters out non-valid combinations.
%  Last review:    19/10/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This section depends on inflectional affixes, that already includes derivational affixes.
#include "4_inflectional_affixes.fst"




%%% NOTES: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Nothing to remark.




% Derivational affixes -------------------------------------------------------------------------------------------------


$derivational-affixes-1$ = $pron$ | $neg$ | $poss$ | $partz$ | $gndz$ | $numz$ | $nounz$ | $advz$ | $adjz$
$derivational-affixes-2$ = $verbz$ | $onoz$ | $cstv$ | $expr$ | $voice$ | $aspc$ | $mood$
$derivational-affixes$ = $derivational-affixes-1$ | $derivational-affixes-2$



% Inflectional affixes -------------------------------------------------------------------------------------------------


$inflectional-affixes$ = $plur$ | $pred$ | $psor$ | $s_case$ | $poss-case$ | $int$



% All affixes ----------------------------------------------------------------------------------------------------------

$affixes$ = $derivational-affixes$ | $inflectional-affixes$



% Concatenation filter to rule out non-allowed combinations ------------------------------------------------------------


$=C1$ = [#stem-types#]
$joint$ = $=C1$ $=C1$
$derivation-filter$ = [#letters#]+ ($joint$ [#letters#]+)* [#stem-types#]



% Concatenates affixes to a lexical root and applies the filter --------------------------------------------------------


$wordforms$ = $lex-roots$ ($affixes$)* || $derivation-filter$

$morph$ = $wordforms$ <>:<end>
