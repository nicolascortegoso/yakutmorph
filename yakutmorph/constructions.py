"""
Detection of whitespace-separated multi-word constructions in Yakut: fixed
idioms and open-ended category runs that span more than one token but,
unlike the hyphen-joined constructions in `yakutmorph.intensifiers`, don't
need any token's own analysis replaced — every member token is already a
perfectly valid word on its own (e.g. "ол да буоллар", literally "even if
that is [so]", grammaticalised into a concessive conjunction "however",
from the demonstrative pronoun "ол", the particle "да", and the conditional
converb "буоллар" of "буол" 'to be' [Ubryatova et al., 1982, vol. 1, §976]).
This module only flags which tokens belong together, via `Token.compound`;
each token's chosen analysis is left untouched.

Patterns are declarative, loaded from a small YAML lexicon (see
`data/constructions.yaml`) rather than hard-coded, since — unlike the
hyphen constructions, which are a productive process applicable to any
root — these are individually lexicalised (or, for category-only patterns,
open-ended but still rule-based) and belong in data, not code.

Pattern mini-language
----------------------
A pattern is a list of slot strings, each matched against a token's
disambiguated `root.morpheme` (its combined lexical-root-plus-category
string, e.g. "ол+Pron", "буол+V"):

- a slot with a literal lexical root, e.g. "ол+Pron", matches only that
  exact root;
- a bare-category slot, e.g. "+V", matches ANY root ending in that tag —
  "any verb stem", "any proper noun", etc.;
- either form may carry a trailing '+' quantifier, e.g. "+PN+", meaning
  "one or more consecutive tokens matching this slot" instead of exactly
  one — this is what lets a single rule match a proper-name run of any
  length ("Николаев", "Николаев Афанасий", "Николаев Афанасий
  Николаевич", ...) without enumerating names.

Matching is greedy and does not backtrack: a quantified slot consumes as
many consecutive matching tokens as it can before the next slot is tried.
This is exact for every pattern currently in the default lexicon (a
quantified slot is always the last, or only, slot in its pattern); a
pattern that puts a quantified slot before another slot that could also
match the same tokens would need real backtracking to be matched
correctly, which this module does not implement.
"""
from typing import List, Optional, Tuple

import yaml

from .utils import get_file_path
from .wrappers import Token


def load_patterns(path_to_file: str, inside_package: bool = False) -> List[Tuple[str, List[str]]]:
    """
    Loads a construction lexicon from a YAML file: a list of entries, each
    `{label: str, pattern: List[str]}`.

    :param path_to_file: Path to the YAML lexicon.
    :param inside_package: Whether the path is relative to this package's
        own data directory.
    :return: A list of (label, pattern) tuples, in file order — matching
        tries patterns in this order, so put more specific patterns before
        more general ones that could also match the same tokens.
    """
    path = get_file_path(path_to_file) if inside_package else path_to_file
    with open(path, 'r') as f:
        entries = yaml.safe_load(f) or []
    return [(entry['label'], entry['pattern']) for entry in entries]


def _parse_slot(slot: str) -> Tuple[str, bool, bool]:
    """
    Splits a pattern slot into its match value and how it should be
    applied.

    :param slot: A slot string, e.g. "ол+Pron", "+V", or "+PN+".
    :return: A tuple (match_value, is_wildcard, is_repeated):
        - match_value: the literal root, or the bare category tag, to
          compare against each candidate token's root.
        - is_wildcard: True if `match_value` should match any root ending
          in it (a category-only slot), rather than requiring equality.
        - is_repeated: True if the slot may consume one or more
          consecutive tokens instead of exactly one.
    """
    is_repeated = len(slot) > 1 and slot.endswith('+')
    core = slot[:-1] if is_repeated else slot
    is_wildcard = core.startswith('+')
    return core, is_wildcard, is_repeated


def _token_matches_slot(token: Token, match_value: str, is_wildcard: bool) -> bool:
    if not token.has_morph or not token.morph:
        return False
    root = token.morph.root.morpheme
    return root.endswith(match_value) if is_wildcard else root == match_value


def _match_pattern_at(tokens: List[Token], start: int, pattern: List[str]) -> Optional[int]:
    """
    Tries to match `pattern` starting exactly at position `start`.

    :return: The index just past the matched span if `pattern` matches
        starting at `start`, else None.
    """
    idx = start
    for slot in pattern:
        match_value, is_wildcard, is_repeated = _parse_slot(slot)
        if not is_repeated:
            if idx >= len(tokens) or not _token_matches_slot(tokens[idx], match_value, is_wildcard):
                return None
            idx += 1
        else:
            consumed = 0
            while idx < len(tokens) and _token_matches_slot(tokens[idx], match_value, is_wildcard):
                idx += 1
                consumed += 1
            if consumed == 0:
                return None
    return idx


def detect(tokens: List[Token], patterns: List[Tuple[str, List[str]]]) -> List[Token]:
    """
    Scans an already-disambiguated token sequence for multi-word
    constructions and flags every matched token's `compound` with the
    matching pattern's label. Only spans of 2 or more tokens are flagged —
    a pattern that happens to match a single token (e.g. a lone proper
    noun against a "one or more" category slot) is not a construction on
    its own and is left alone.

    Patterns are tried in the order given at each starting position; the
    first one that matches wins, and matching resumes right after the
    matched span (matches never overlap).

    :param tokens: The list of Token objects for the sentence, already
        disambiguated (`token.morph` must be resolvable for any token a
        pattern could match).
    :param patterns: A list of (label, pattern) tuples, e.g. from
        `load_patterns`.
    :return: The same list of Tokens, with `compound` set on every token
        belonging to a recognised construction.
    """
    idx = 0
    while idx < len(tokens):
        for label, pattern in patterns:
            end = _match_pattern_at(tokens, idx, pattern)
            if end is not None and end - idx >= 2:
                for token in tokens[idx:end]:
                    token.compound = label
                idx = end
                break
        else:
            idx += 1
    return tokens
