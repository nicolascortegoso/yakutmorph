%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Lexical root transformations in closed-class lexical roots
%  Last review:    03/03/2025

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This code section consist of 2 parts:
% 1. Rules description;
% 2. Rules application order.

% The rule denomination consist of 3 elements:
% 1) prefix: describes the type of operation: D (drop), R (replace), I (insert). It is followed by a hyphen.
% 2) name: an acronym to refer to the rule.
% 3) number: if a general rule is composed by specific rules, those are given a number.




% 1. RULES DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [R-EXN] Exceptional cases --------------------------------------------------------------------------------------------

% [01-06] Special plural forms (made optional).
% [07] Diminutive form for доҕор+N+DIM#1 -> доҕоччук.
% [08] баар+N+PL -> бааллар

$R-EXC01$ = р:л         ^->? <begin> дьахта __ <noun-2c><noun-2c> <D2><O>р <plur>
$R-EXC02$ = р:т         ^-> <begin> оҕонньо __ <noun-c><noun-c> <D2><O>р <plur> <end>
$R-EXC03$ = н:т         ^-> <begin> эмээхси __ <noun-c><noun-c> <D2><O>р <plur> <end>
$R-EXC04$ = л:{лат}     ^->? <begin> уо __ <noun-1c><noun-1c> <D2><O>р <plur>
$R-EXC05$ = {ыс}:{ргыт} ^-> <begin> кы __ <noun-1c><noun-1c> <D2><O>р <plur> <end>
$R-EXC06$ = р:т         ^-> <begin> доҕо __ <noun-2c><noun-2c> <D2><O>р <plur>
$R-EXC07$ = р:ч         ^-> <begin> доҕо __ <noun-2c><noun-2c> ч<C>к <noun-dc> <end>
$R-EXC08$ = р:л         ^-> <begin> баа __ <noun-1c><noun-1c> <D2><O>р <plur>

$R-EXC$ = $R-EXC01$ || $R-EXC02$ || $R-EXC03$ || $R-EXC04$ || \
          $R-EXC05$ || $R-EXC06$ || $R-EXC07$ || $R-EXC08$



% [R-DEM] Root alterations for demonstrative pronouns ------------------------------------------------------------------

% Demonstrative pronouns бу and ол for the oblique cases have a different root ман and он.
% Their emphatic forms, субу and cол, form the oblique cases from сабан and сол, respectively [§318].
% Dative case inserts a diphthong <DI> before the affix [§318].

% [10] adds a diphthong before dative.
% [12] introduced to conform to the table in Sleptsov.

$R-DEM01$ = у:а               ^-> с __ бу <dem><dem> [#symbols#]+ \
                              [#cases# <plur> <psor> <psor-3> <dt1> <dt2> <ka-v> <ka-c>]
$R-DEM02$ = {бу}:{ба}         ^-> __ <dem><dem> чч<O> <dt2>
$R-DEM03$ = {бу}:{ман}        ^-> __ <dem><dem>                                       ( \
                              [#symbols#]+ [#cases# <psor> <psor-3> <dt1>]            | \
                              <D2><O>р      <plur>+ <O> <psor-3>                      | \
                              <D1><LO>ҕ<C>  <adj-dv>                                  | \
                              к<O>          <ka-v>                                    | \
                              к<O>й         <ka-c>                                    )
$R-DEM04$ = {ити}:{итин}      ^-> __ <dem><dem>                                       ( \
                              ([#symbols#]+ - н<O>н) [#cases# <psor> <psor-3> <dt1>]  | \
                              <D2><O>р <plur>+ <O>    <psor-3>                        | \
                              <D1><LO>ҕ<C>            <adj-dv>                        | \
                              к<O>                    <ka-v>                          | \
                              к<O>й                   <ka-c>                          )
$R-DEM05$ = л:<>              ^-> о __ <dem><dem> чч<O> <dt2>
$R-DEM06$ = л:<>              ^-> о __ <dem><dem> <D2><O>р <plur> (<end> | <plur> [#symbols#]+ [#cases#])
$R-DEM07$ = л:н               ^-> о __ <dem><dem> [#symbols#]+ [#cases# <psor> <psor-3> <plur> <dt1> <ka-v> <ka-c> <adj-dv>]
$R-DEM08$ = н:{нт}            ^-> (ма | ити | о) __ <dem>+ ( <C>м <psor> | <C>ҥ <psor> | <O> <psor-3> )
$R-DEM09$ = н:{нт<C>}         ^-> (ма | ити | о) __ <dem><dem>                        ( \
                              <B><C>т               <psor>                            | \
                              <V><C>т               <psor>                            | \
                              <D2><O>р              <plur>                            | \
                              к<O>                  <ka-v>                            | \
                              к<O>й                 <ka-c>                            )
$R-DEM10$ = <dem>:{<DI><dem>} ^-> (ман | итин | он) __ <dem> <V><O> <dat>
$R-DEM11$ = {бу}:{ба}         ^-> __ <dem><dem> <D2><O>р <plur>
$R-DEM12$ = <dem>:{т<C><dem>} ^-> __ <dem> [#symbols#]+ (<case-p> | <acc-p>)


$R-DEM$ = $R-DEM01$ || $R-DEM02$ || $R-DEM03$ || $R-DEM04$ || $R-DEM05$ || $R-DEM06$ || \
          $R-DEM07$ || $R-DEM08$ || $R-DEM09$ || $R-DEM10$ || $R-DEM11$ || $R-DEM12$



% [R-PER] Root alterations for personal pronouns -----------------------------------------------------------------------

% [12] Inserts an н before the adverbial affix.

$R-PER01$ = н:{йн}               ^-> э __ <prs><prs>
$R-PER02$ = н:э                  ^-> ми __ <prs><prs> <V><O> <dat>
$R-PER03$ = н:{эни}              ^-> __ <prs><prs> <D2><LC> <adv-dv>
$R-PER04$ = н:{<C>г<C>}          ^-> __ <prs><prs>
$R-PER05$ = {г[<C>и]}:{г<C>н}    ^-> __ <prs><prs>                      ( \
                                 <D2><LC>н                    <case-c>  | \
                                 <D1><LO>ҕ<O>р                <case-c>  | \
                                 <D1><LO>ҕ<C>                 <adj-dv>  | \
                                 <D2><LO>х                    <poss>    )
$R-PER06$ = <prs>:{<DI><prs>}    ^-> эй __ <prs> <V><O> <dat>
$R-PER07$ = и:<DI>               ^-> кин __ <prs>+ <V><O> <dat>
$R-PER08$ = {[и<C>]г[и<C>]}:<DI> ^-> ( эй | биһ | эһ ) __ <prs><prs> <V><O> <dat>
$R-PER09$ = <C>:<>               ^-> <C> <prs><prs> н __ <case-v>
$R-PER10$ = {<D1><O>}:<O>        ^-> кини <prs><prs> <D2><O>р <plur><plur> __ <case-v>
$R-PER11$ = <O>:<DI>             ^-> <int-p><int-p> __ н <ps>
$R-PER12$ = {г[и<C>]}:<>         ^-> __ <prs><prs> <O>н <ps>
$R-PER13$ = [и<C>]:<>            ^-> ми __ <prs><prs> <O>н <ps>
$R-PER14$ = <prs>:{н<prs>}       ^-> __ <prs> ( <D1><C>к <adv-dc> | <D2><LC> <adv-dv>)
$R-PER15$ = {н<prs><prs><D1>}:{<prs><prs>н} ^-> <begin> (биһиг | эһиг) <C> __  <LO>ҕ<O>р <case-c>
$R-PER16$ = һ:й                  ^-> <begin> э __ иг<C> <prs><prs> <D2><LO>ҕ<O>р <case-c>


%%%<begin>эйиги<prs><prs>нээҕэр<case-c><end>

$R-PER$ = $R-PER01$ || $R-PER02$ || $R-PER03$ || $R-PER04$ || $R-PER05$ || $R-PER06$ || \
          $R-PER07$ || $R-PER08$ || $R-PER09$ || $R-PER10$ || $R-PER11$ || $R-PER12$ || \
          $R-PER13$ || $R-PER14$ || $R-PER15$ || $R-PER16$


% [R-INT] Root alterations for interrogative pronouns ------------------------------------------------------------------


% [01] Deletes ending of the adverb ханна before attaching case affixes.


% ханна +INST -> ханан
% ханна +ABL -> хантан

$D-INT01$ = {на}:<> ^-> __ <int-v><int-v> (<V><O> <dat> | тт<O>н <case-c> | н<O>н <case-c>)
$I-INT01$ = а:{аа}  ^-> <begin> хаһ __ н <int-c><int-c>

$R-INT01$ = <int-p>:{<DI><int-p>} ^-> ким __ <int-p> <V><O> <dat>
$R-INT02$ = {ох}:{г}              ^-> ту __ <int-a><int-a> ( <C> | <C>н<O>н )
$R-INT03$ = {на}:<> ^-> <begin>хан __ <int-v><int-v> <O>н <case-c>
$R-INT04$ = {на}:<> ^-> <begin>хан __ <int-v><int-v> т<O>н <case-c>

$R-INT$ = $D-INT01$ || $I-INT01$ || $R-INT01$ || $R-INT02$ ||  $R-INT03$ || $R-INT04$



% [$D-NUM$] Root alterations for numerals ------------------------------------------------------------------------------

% [01] When forming the collective and ordinal, the cardinal 'уон' loses the beginning 'у' (уон+Num+ORD -> онус)
% [02] Affix starting with ч forces final stem т to turn into ч. Observed in (отут+Num+APPR#1+ACC -> отуччаны)

$D-NUM01$ = у:<> ^-> <begin> __ он <card-c><card-c> (<DI> <coll-v> | <C>с <ord>)
$D-NUM02$ = т:ч  ^-> <begin>оту __ <card-c><card-c> ч

$D-NUM$ = $D-NUM01$ || $D-NUM02$



% [R-ACN] Alternation c - ннь ------------------------------------------------------------------------------------------

% The following alternations are observed in special cases:
% [01] (с-ннь) in many conjugated forms from the verbs ас, сыс, and мус (ас+V+PART_PRES+1SG -> анньабын) [§124].
% [02] (й-ннь) in the possessive forms of the nouns моой and хоой (хоой+N+POSS.2SG -> хоонньуҥ) [§124].
% [03] (рн-ннь) in the possessive forms of the nouns сүрүн and сирин (сүрүн+N+POSS.1SG -> сүнньүм) [§125]. It was
% observed also сүрүн+N+POSS.3SG+INST -> сүнньүнэн [Petrov N.E. 1984:163].

$R-ACN01$ = с:{ннь}    ^->? <begin> (а|сы|му) __ <tran-1c><tran-1c> [#symbols#]+ ( \
                                                 <part1>                         | \
                                                 <part3-c>                       | \
                                                 <verb-v>                        | \
                                                 <refl>                          | \
                                                 <pass>                          | \
                                                 <recp>                          | \
                                                 <gnd1>                          | \
                                                 <gnd2>                          | \
                                                 <noun-dc>                       | \
                                                 <noun-dv>                       )
$R-ACN02$ = й:{ннь}    ^-> <begin> [мх] оо __ <noun-1j><noun-1j> [#symbols#]+ (<psor> | <psor-3> | <case-p>)
$R-ACN03$ = {р[#closed-vowels#]н}:{ннь} ^->? <begin> с[үи] __ <noun-2c><noun-2c> [#symbols#]+ \
                                        (<psor> | <psor-3> | <case-p>) 

$R-ACN$ = $R-ACN01$ || $R-ACN02$ || $R-ACN03$



% [R-ARL] Special cases (replacement) ----------------------------------------------------------------------------------

% [01] (рый-лдь) in the declension of verbs ыарый (ыарый+V+PART_PRES+1SG -> ыалдьабын) [§120].
% [02] (рыт-лдь) in the declension of verbs сырыт (сырыт+V+PART_FUT+POSS.1SG -> сылдьыаҕым) [§120].
% [03] (ри-дь) observed in кырый - [Kharitonov, 1943, §45] refers to it as progressive assimilation inside a stem.
% [05] (т-дь) observed in (күрт+V+PART_PRES, күрт+V+RECP+PST.3SG), but not in кэрт
% [07] ad-hoc to produce (аны+Adv+DAT -> аныаха). It might generalize.
% [08] ad-hoc to produce киир+V+CSTV -> киллэр

$R-ARL01$ = {рыы <noun-v><noun-v> й}:{л <noun-v><noun-v> дь} ^-> <begin> ыа __ <verb-j><verb-j> [#symbols#]+ ( \
                            <recp>                                        | \
                            <neg>                                         | \
                            <part1>                                       | \
                            <part1-n>                                     | \
                            <part2>                                       | \
                            <part3-c>                                     | \
                            <part3-v>                                     | \
                            <part5>                                       | \
                            <verb-v>                                      | \
                            <gnd1>                                        | \
                            <gnd2>                                        | \
                            <gnd5>                                        | \
                            <noun-dv>                                     )
$R-ARL02$ = {рыт}:{лдь} ^-> <begin> сы __ <intr-2c><intr-2c> [#symbols#]+ ( \
                            <recp>                                        | \
                            <neg>                                         | \
                            <part1>                                       | \
                            <part1-n>                                     | \
                            <part2>                                       | \
                            <part3-c>                                     | \
                            <part3-v>                                     | \
                            <part5>                                       | \
                            <verb-v>                                      | \
                            <gnd1>                                        | \
                            <gnd2>                                        | \
                            <gnd5>                                        | \
                            <noun-dv>                                     | \
                            <imp>                                         )
$R-ARL03$ = {ый}:{дь}   ^-> <begin> кыр __ <intr-2j><intr-2j>
$R-ARL04$ = {ыс}:{т}    ^-> <begin> бал __ <noun-2c><noun-2c>
$R-ARL05$ = т:{дь}      ^-> күр __ <tran-1c><tran-1c>
$R-ARL06$ = <V>:{ах}    ^-> <begin> аны <adv-2v><adv-2v> __  <O> <dat>
$R-ARL07$ = <V>:{<DI>х} ^-> <begin> хан <int-v><int-v> __ <O> <dat>
$R-ARL08$ = {ир}:л      ^-> <begin> ки __ <intr-1r><intr-1r> <D1><O>р <cstv-r> 


$R-ARL$ = $R-ARL01$ || $R-ARL02$ || $R-ARL03$ || $R-ARL04$ || $R-ARL05$ || $R-ARL06$ || \
          $R-ARL07$ || $R-ARL08$



% [R-ARL] Special cases (deletion) -------------------------------------------------------------------------------------

% [02] diphthong shortening in диэ- when forming the passive voice [Kharitonov L.N., 1963: §200]
% [03] аас+V+CSTV -> аһар

$D-ARL01$ = {ын}:<>     ^-> <begin> ахс __ <noun-2c><noun-2c>
$D-ARL02$ = и:<>        ^-> <begin> д __ э <tran-1v><tran-1v> н <pass>
$D-ARL03$ = а:<>        ^-> <begin> а __ с <intr-1c><intr-1c> <O>р <cstv-r>
$D-ARL04$ = т:<>        ^-> <begin> иһи __ <tran-2c><tran-2c> <C>л<C>н <pass>


$D-ARL$ = $D-ARL01$ || $D-ARL02$ || $D-ARL03$ || $D-ARL04$



% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$specific-root-transformations$ = $R-EXC$ || $R-DEM$ || $R-PER$ || $R-INT$ || $D-NUM$ || $R-ACN$ || $R-ARL$ || $D-ARL$