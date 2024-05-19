%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Syllable boundaries
%  Description:     This file defines the boundaries between syllables.
%  Last review:     16/11/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%% NOTES: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%% 1. SYLLABLES BOUNDARY DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Intermediate vowel matrix --------------------------------------------------------------------------------------------

#VI# = <iv1> <iv2> <iv3> <iv4> <iv5> <iv6>



% Intermediate consonant matrix ----------------------------------------------------------------------------------------


#CI01# = <ia1> <ia2> <ia3> <ia4> <ia5> <ia6>
#CI02# = <ic1> <ic2> <ic3> <ic4> <ic5> <ic6>
#CI03# = <id1> <id2> <id3> <id4> <id5> <id6>
#CI04# = <ie1> <ie2> <ie3> <ie4> <ie5> <ie6>
#CI05# = <if1> <if2> <if3> <if4> <if5> <if6>
#CI06# = <ig1> <ig2> <ig3> <ig4> <ig5> <ig6>
#CI07# = <ih1> <ih2> <ih3> <ih4> <ih5> <ih6>
#CI08# = <ii1> <ii2> <ii3> <ii4> <ii5> <ii6>
#CI09# = <ij1> <ij2> <ij3> <ij4> <ij5> <ij6>
#CI10# = <in1> <in2> <in3> <in4> <in5> <in6>
#CI11# = <io1> <io2> <io3> <io4> <io5> <io6>
#CI12# = <ip1> <ip2> <ip3> <ip4> <ip5> <ip6>
#CI13# = <iq1> <iq2> <iq3> <iq4> <iq5> <iq6>
#CI14# = <ir1> <ir2> <ir3> <ir4> <ir5> <ir6>
#CI15# = <is1> <is2> <is3> <is4> <is5> <is6>
#CI16# = <iv1> <iv2> <iv3> <iv4> <iv5> <iv6>
#CI# = #CI01# #CI02# #CI03# #CI04# #CI05# #CI06# #CI07# #CI08# #CI09# #CI10# #CI11# #CI12# #CI13# #CI14# #CI15# #CI16#


#boundaries# = #VI# #CI#


#disyllabic-adjs#    = <adj-2v> <adj-2c> <adj-2j>
#disyllabic-advs#    = <adv-2v> <adv-2c> <adv-2j>
#disyllabic-nouns#   = <noun-2v> <noun-2c> <noun-2j>
#disyllabic-intr#    = <intr-2v> <intr-2c> <intr-2j> <intr-2nl> <intr-2r>
#disyllabic-tran#    = <tran-2v> <tran-2c> <tran-2j> <tran-2l>  <tran-2r>
#disyllabic-verbs#   = #disyllabic-intr# #disyllabic-tran#

#polysyllabic-adjs#  = <adj-v>  <adj-c>  <adj-j>
#polysyllabic-advs#  = <adv-v>  <adv-c>  <adv-j>
#polysyllabic-nouns# = <noun-v> <noun-c> <noun-j>
#polysyllabic-intrs# = <intr-v> <intr-c> <intr-j> <intr-nl>
#polysyllabic-trans# = <tran-v> <tran-c> <tran-j>
#polysyllabic-verbs# = #polysyllabic-intrs# #polysyllabic-trans#


#syllable-boundaries# = <s> #boundaries#