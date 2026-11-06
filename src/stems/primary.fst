%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Author:          Cortegoso-Vissio, Nicolas; Zakharov, Victor Pavlovich
%  University:      SPBGU, Saint-Petersburg State University
%  Department:      Mathematical linguistics
%  Title:           Primary stems definitions
%  Last review:     27/03/2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This file defines the base of a lexical root, that is a primary form with no productive affixes.

% The code in this file is divided into 2 sections:
% 1. Primary stems definition;
% 2. Primary stems aggregation.

% The distinction between intransitive and transitive verbs is founded mainly on the principle of the verb being able
% to take the reflexive and passive forms. Therefore, verbs of movement like бар, күл, туораа are marked as transitive,
% nevertheless they are technically not [§505].

% The stem endings for verbal roots are more fine-grained compared to other stem types. This strategy was adopted
% mainly to model the attachment of voice affixes.

% Most of the stems definitions presented here follow a two-element structure consisting of:
% 1. the base class (mandatory element) that may refer to a part of speech (e.g., adjective, adverb), stem type (e.g.,
% nominal, verb), or affix type (e.g., possessive, plural);
% 2. other specifications (optional), such as number of syllables, stem endings, and other characteristics.

% The accepted basis type format is of type <class-specification>. If no specifications are implemented, the base type
% is simply <class>.
% The base class is the main stem classifier, while the specifications convey extra information about the stem.

% Some of the symbols included in the specifications are:
% -1: monosyllabic stem type;
% -2: disyllabic;
% -v: vowel ending;
% -s: stressed vowel ending (used in load words lexical roots);
% -u: reduced vowel at starting syllable (used in load words lexical roots);
% -j: glide ending;
% -c: consonant ending;




%%% 1. PRIMARY STEM DEFINITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [adj] Primary adjectival stems ---------------------------------------------------------------------------------------

#adjs-v#  = <adj-v> <adj-2v> <adj-1v> <adj-uv> <adj-sv>
#adjs-j#  = <adj-j> <adj-2j> <adj-1j> <adj-uj> <adj-sj>
#adjs-c#  = <adj-c> <adj-2c> <adj-1c> <adj-uc> <adj-sc>



% [adv] Primary adverbial stems ----------------------------------------------------------------------------------------

#advs-v#  = <adv-v> <adv-2v> <adv-1v>
#advs-j#  = <adv-j> <adv-2j> <adv-1j>
#advs-c#  = <adv-c> <adv-2c> <adv-1c>



% [intj] Interjections -------------------------------------------------------------------------------------------------

#intj# = <intj> <intj-d>



% [aux] Auxiliary stems ------------------------------------------------------------------------------------------------

#auxs# = <aux-c> <aux-v>



% [noun] Primary nouns stems -------------------------------------------------------------------------------------------

#nouns-v#  = <noun-v> <noun-2v> <noun-1v> <noun-uv> <noun-sv>
#nouns-j#  = <noun-j> <noun-2j> <noun-1j> <noun-uj> <noun-sj>
#nouns-c#  = <noun-c> <noun-2c> <noun-1c> <noun-uc> <noun-2uc> <noun-sc>



% [card] Primary numeral stems -----------------------------------------------------------------------------------------

#cards# = <card-c> <card-v>



% [imit] Primary imitative stems ---------------------------------------------------------------------------------------

% Imitative stems can form verbs by affixation or analytically.

#imis# = <imi-v> <imi-ov> <imi-cv> <imi-c> <imi-k> <imi-p> <imi-2r> <imi-l> <imi-x> <imi-n> <imi-r> <imi>



% [part] Particle stems ------------------------------------------------------------------------------------------------

#parts#  = <part-c> <part-v>
#modals# = <mod>



% [post] Primary postposition stems ------------------------------------------------------------------------------------

#posts# = <post-c> <post-v>



% [pron] Primary prononimal stems --------------------------------------------------------------------------------------

% - <prs> personal pronouns [§312-317].
% - <dem-n> demonstrative pronouns that do not take affixes. Example, the demonstrative pronoun били [§318];
% - <int-s> quantitive pronouns.
% - <ref> reflexive pronouns.
% - <int> interrogative pronouns that takes no affixes.
% - <int-av> marks ханна as a special case.

#cos# = <co-v> <co-c>
#int# = <int> <int-c> <int-v> <int-p> <int-a> <int-s>
#prons# = <prs> <dem> <dem-n> <ref> <dt1> <dt2> <ind> <ps> #int# #cos#



% [intr] Primary intransitive verbal stems -----------------------------------------------------------------------------

#intrs-c#  = <intr-c> <intr-2c> <intr-1c>
#intrs-j#  = <intr-j> <intr-2j> <intr-1j>
#intrs-r#  = <intr-r> <intr-2r> <intr-1r>
#intrs-nl# = <intr-nl> <intr-2nl> <intr-1nl>
#intrs-v#  = <intr-v> <intr-2v> <intr-1v>



% [tran] Primary transitive verbal stems -------------------------------------------------------------------------------

% - <tran-1-d-v> does not reduce diphthong when forming the causative voice.

#trans-c# = <tran-c> <tran-2c> <tran-1c>
#trans-j# = <tran-j> <tran-2j> <tran-1j>
#trans-r# = <tran-r> <tran-2r> <tran-1r>
#trans-l# = <tran-l> <tran-2l> <tran-1l>
#trans-v# = <tran-v> <tran-2v> <tran-1v> <tran-1-d-v>



% [fig] Figurative verbal stems ----------------------------------------------------------------------------------------

#figs# = <fig-j> <fig-r> <fig>




%%% 2. AGGREGATED PRIMARY STEMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The stems are combined into larger sets for ease of use during implementation.


% Aggregated nominal stems ---------------------------------------------------------------------------------------------

#adjs-cj#     = #adjs-c# #adjs-j#
#adjs#        = #adjs-v# #adjs-cj#

#advs-cj#     = #advs-c# #advs-j#
#advs#        = #advs-v# #advs-cj#

#nouns-cj#    = #nouns-c# #nouns-j#
#nouns#       = #nouns-v# #nouns-cj#

#noms-v#      = #adjs-v# #nouns-v# #advs-v#
#noms-j#      = #adjs-j# #nouns-j# #advs-j#
#noms-c#      = #adjs-c# #nouns-c# #advs-c#
#noms-cj#     = #noms-c# #noms-j#
#noms#        = #noms-v# #noms-cj#



% Aggregated verbal stems ----------------------------------------------------------------------------------------------

#intrs-crnl#  = #intrs-c# #intrs-r# #intrs-nl#
#intrs-cjrnl# = #intrs-j# #intrs-crnl#
#intrs#       = #intrs-cjrnl# #intrs-v#

#trans-crl#   = #trans-c# #trans-r# #trans-l#
#trans-cjrl#  = #trans-j# #trans-crl#
#trans#       = #trans-cjrl# #trans-v#

#verbs-c#     = #intrs-c# #trans-c#
#verbs-r#     = #intrs-r# #trans-r#
#verbs-j#     = #intrs-j# #trans-j#
#verbs-v#     = #intrs-v# #trans-v#
#verbs-crnl#  = #intrs-crnl# #trans-crl#
#verbs-crjnl# = #intrs-cjrnl# #trans-cjrl#
#verbs#       = #verbs-v# #verbs-crjnl# #figs#



% All primary stems ----------------------------------------------------------------------------------------------------

% The stem <comp> refers to lexical units that always appear in combination with others, never standing by itself.

#primary-stems# = #verbs# #advs# #adjs# #nouns# \
                  #prons# #cards# #parts# #imis# #intj# \
                  <conj> <comp> #posts# #auxs# #modals#