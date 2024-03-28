%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:         Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:     SPBGU, Saint-Petersburg State University
%  Department:     Mathematical linguistics
%  Title:          Lexical root transformations in closed-class lexical roots
%  Last review:    27/03/2024

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

% [01-06] Special plural forms.

$R-EXC01$ = р:л         ^-> дьахта __ <noun-2c><noun-2c> <D2><O>р <plur>
$R-EXC02$ = р:т         ^-> оҕонньо __ <noun-c><noun-c> <D2><O>р <plur>
$R-EXC03$ = н:т         ^-> эмээхси __ <noun-c><noun-c> <D2><O>р <plur>
$R-EXC04$ = л:{лат}     ^-> уо __ <noun-1c><noun-1c> <D2><O>р <plur>
$R-EXC05$ = {ыс}:{ргыт} ^-> кы __ <noun-1c><noun-1c> <D2><O>р <plur>
$R-EXC06$ = р:т         ^-> доҕо __ <noun-2c><noun-2c> <D2><O>р <plur>

$R-EXC$ = $R-EXC01$ || $R-EXC02$ || $R-EXC03$ || $R-EXC04$ || $R-EXC05$ || $R-EXC06$


% [R-DEM] Root alterations for demonstrative pronouns ------------------------------------------------------------------

% Demonstrative pronouns бу and ол for the oblique cases have a different root ман and он.
% Their emphatic forms, субу and cол, form the oblique cases from сабан and сол, respectively [§318].
% Dative case inserts a diphthong <DI> before the affix [§318].

% [10] add a diphthong before dative.

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
$R-DEM08$ = н:{нт}            ^-> (ма | ити | о) __ <dem>+ ( <C>м  <psor> | <C>ҥ <psor> | <O> <psor-3> )
$R-DEM09$ = н:{нт<C>}         ^-> (ма | ити | о) __ <dem><dem>                        ( \
                              <B><C>т               <psor>                            | \
                              <V><C>т               <psor>                            | \
                              <D2><O>р              <plur>                            | \
                              к<O>                  <ka-v>                            | \
                              к<O>й                 <ka-c>                            )
$R-DEM10$ = <dem>:{<DI><dem>} ^-> (ман | итин | он) __ <dem> <V><O> <dat>
$R-DEM11$ = {бу}:{ба}         ^-> __ <dem><dem> <D2><O>р <plur>

$R-DEM$ = $R-DEM01$ || $R-DEM02$ || $R-DEM03$ || $R-DEM04$ || $R-DEM05$ || $R-DEM06$ || \
          $R-DEM07$ || $R-DEM08$ || $R-DEM09$ || $R-DEM10$ || $R-DEM11$


% [R-PER] Root alterations for personal pronouns -----------------------------------------------------------------------

% [12] Inserts an н before the adverbial affix.

$R-PER01$ = н:{йн}               ^-> э __ <prs><prs>
$R-PER02$ = н:э                  ^-> ми __ <prs><prs> <V><O> <dat>
$R-PER03$ = н:{<C>г<C>}          ^-> __ <prs><prs>
$R-PER04$ = {г[<C>и]}:{г<C>н}    ^-> __ <prs><prs>                      ( \
                                 <D2><LC>н                    <case-c>  | \
                                 <D1><LO>ҕ<O>р                <case-c>  | \
                                 <D1><LO>ҕ<C>                 <adj-dv>  | \
                                 <D2><LO>х                    <poss>    )
$R-PER05$ = <prs>:{<DI><prs>}    ^-> эй __ <prs> <V><O> <dat>
$R-PER06$ = и:<DI>               ^-> кин __ <prs>+ <V><O> <dat>
$R-PER07$ = {[и<C>]г[и<C>]}:<DI> ^-> ( эй | биһ | эһ ) __ <prs><prs> <V><O> <dat>
$R-PER08$ = <C>:<>               ^-> <C> <prs><prs> н __ <case-v>
$R-PER09$ = {<D1><O>}:<O>        ^-> кини <prs><prs> <D2><O>р <plur><plur> __ <case-v>
$R-PER10$ = {[и<C>]г[и<C>]}:<>   ^-> __ <prs><prs> иэн <ps>
$R-PER11$ = и:<>                 ^-> (кин | м) __ <prs><prs> иэн <ps>
$R-PER12$ = <prs>:{н<prs>}       ^-> __ <prs> <D1><C>к <adv-dc>

$R-PER$ = $R-PER01$ || $R-PER02$ || $R-PER03$ || $R-PER04$ || $R-PER05$ || $R-PER06$ || \
          $R-PER07$ || $R-PER08$ || $R-PER09$ || $R-PER10$ || $R-PER11$ || $R-PER12$


% [R-INT] Root alterations for interrogative pronouns ------------------------------------------------------------------

$R-INT01$ = <int-p>:{<DI><int-p>} ^-> ким __ <int-p> <V><O> <dat>
$R-INT02$ = {ох}:{г}              ^-> ту __ <int-a><int-a> ( <C> | <C>н<O>н )

$R-INT$ = $R-INT01$ || $R-INT02$



% [$D-NUM$] Root alterations for numerals ------------------------------------------------------------------------------

% [01] When forming the collective, the cardinal 'уон' loses the beginning 'у'.

$D-NUM$ = у:<> ^-> <begin> __ он <card-c><card-c> (<DI> <coll-v> | <DI>й<O>х <coll-c>)




% 2. RULES APPLICATION ORDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$specific-root-transformations$ = $R-EXC$ || $R-DEM$ || $R-PER$ || $R-INT$ || $D-NUM$