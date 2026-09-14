"""
Detection of hyphen-joined constructions in Yakut.

Written Yakut uses a plain hyphen to join two word forms into a single
prosodic/orthographic unit for three distinct purposes:

1. Reduplication: the same word form repeated, e.g. "куруубай-куруубай"
   (very green), for emphasis.
2. Intensifying augmentation: a reduced copy of the following word's own
   first syllable plus a fixed increment, expressing an intensified degree
   of a quality, e.g. "хап-хара" (pitch-black), from "хара" (black)
   [Ubryatova et al., 1982, vol. 1, §250].
3. Compounding: two independent word forms joined to express a single
   concept, e.g. "ый-күн" (moon-sun -> roughly "time").

The transducer pipeline has no notion of these constructions: it analyses
each side of the hyphen independently, so an augment such as "хап" is
happily (mis)analysed as a free-standing root (e.g. an imitative or a verb),
since it also happens to be one on its own. This module classifies a
[token]-[hyphen]-[token] triple after the fact, from the surface forms
alone.
"""

from types import SimpleNamespace
from typing import Optional, Tuple

# The three constructions recognised by `classify`.
construction_type = SimpleNamespace(
    REDUPLICATION='reduplication',
    INTENSIFIER='intensifier',
    COMPOUND='compound',
)

# Vowels recognised for syllable extraction (native Yakut inventory, plus
# the Cyrillic-loanword vowels ё/е/ю/я for robustness; the latter are not
# part of the harmony pairing below).
_VOWELS = set('аэоыуиөүёеюя')

# Open/closed harmony pairs, as defined in `src/alphabet/vowels.fst`
# (#open-vowels# = аэоө, #closed-vowels# = ыиуү). An augment's increment
# always surfaces with the closed member of the base's own harmony pair.
_OPEN_TO_CLOSED = {
    'а': 'ы',
    'э': 'и',
    'о': 'у',
    'ө': 'ү',
}

# The three surface templates an intensifying augment can take, built from
# the base's own onset consonant (if any) and first vowel
# [Ubryatova et al., §250]:
#   - monosyllabic:  onset + vowel + "п"                      (хара -> хап)
#   - bisyllabic #1: onset + vowel + "б" + closed_vowel + "с"  (тымныы -> тыбыс)
#   - bisyllabic #2: onset + vowel + "р" + closed_vowel        (хантаҕар -> хары)
_MONO_INCREMENT = 'п'
_BISYLLABIC_S_INFIX = 'б'
_BISYLLABIC_S_SUFFIX = 'с'
_BISYLLABIC_R_INFIX = 'р'

# A handful of intensifiers that do not derive from their base's own first
# syllable, and are instead lexicalized to specific bases [Ubryatova et al.,
# §250]. Kept as a closed list rather than folded into the rule above.
IRREGULAR_INTENSIFIERS = {
    ('суос', 'соҕотох'),
    ('суоч', 'соҕотох'),
    ('уун', 'утары'),
}

# Similarity threshold (normalized edit distance against the base's own
# prefix, see `_prefix_similarity`) below which an augment shape not
# otherwise covered is still accepted as an intensifier. Tuned against the
# regular examples in the reference grammar; revisit once run against more
# of the corpus.
_SIMILARITY_THRESHOLD = 0.4

# The characters an augment can plausibly end in, per the three templates in
# `_augment_candidates`: 'п' (monosyllabic), 'с' (bisyllabic -ыс/-ис/-ус/-үс),
# or one of the closed vowels (bisyllabic -ры/-ри/-ру/-рү). Used to reject
# fuzzy-fallback matches whose shape no augment template could ever produce.
_VALID_AUGMENT_ENDINGS = set('псыиуү')


def _first_syllable(word: str) -> Optional[Tuple[str, str]]:
    """
    Splits off the onset consonant cluster (possibly empty) and first vowel
    of a word.

    :param word: A lowercase surface form.
    :return: An (onset, vowel) tuple, or None if the word contains no vowel.
    """
    for i, char in enumerate(word):
        if char in _VOWELS:
            return word[:i], char
    return None


def _closed_counterpart(vowel: str) -> str:
    """
    Returns the closed member of a vowel's open/closed harmony pair, or the
    vowel itself if it is already closed (or unrecognised).

    :param vowel: A single vowel character.
    :return: The corresponding closed vowel.
    """
    return _OPEN_TO_CLOSED.get(vowel, vowel)


def _augment_candidates(base: str) -> set:
    """
    Generates the surface forms an intensifying augment of `base` could
    regularly take.

    :param base: The lowercase base word the augment would intensify.
    :return: A set of candidate augment surface forms (empty if `base` has
        no identifiable first syllable).
    """
    syllable = _first_syllable(base)
    if syllable is None:
        return set()
    onset, vowel = syllable
    onset_vowel = onset + vowel
    closed_vowel = _closed_counterpart(vowel)
    return {
        onset_vowel + _MONO_INCREMENT,
        onset_vowel + _BISYLLABIC_S_INFIX + closed_vowel + _BISYLLABIC_S_SUFFIX,
        onset_vowel + _BISYLLABIC_R_INFIX + closed_vowel,
    }


def _edit_distance(a: str, b: str) -> int:
    """
    Computes the Levenshtein edit distance between two strings.

    :param a: The first string.
    :param b: The second string.
    :return: The minimum number of single-character insertions, deletions,
        or substitutions needed to turn `a` into `b`.
    """
    if not a:
        return len(b)
    if not b:
        return len(a)
    previous_row = list(range(len(b) + 1))
    for i, char_a in enumerate(a, start=1):
        current_row = [i]
        for j, char_b in enumerate(b, start=1):
            cost = 0 if char_a == char_b else 1
            current_row.append(min(
                previous_row[j] + 1,         # deletion
                current_row[j - 1] + 1,      # insertion
                previous_row[j - 1] + cost,  # substitution
            ))
        previous_row = current_row
    return previous_row[-1]


def _prefix_similarity(augment: str, base: str) -> float:
    """
    Scores how close `augment` is to a reduction of `base`'s own beginning,
    by measuring edit distance against `base`'s prefix of matching length
    (rather than the whole word, which would be dominated by the length
    gap that the construction itself introduces by design).

    :param augment: The candidate augment surface form.
    :param base: The base word it would intensify.
    :return: A normalized distance in [0, 1]; lower means more similar.
    """
    if not augment:
        return 1.0
    return _edit_distance(augment, base[:len(augment)]) / len(augment)


def is_intensifier(augment: str, base: str) -> bool:
    """
    Checks whether `augment` is a plausible intensifying augment of `base`,
    either by regular derivation, by a known irregular pairing, or by a
    fuzzy fallback for augment shapes not otherwise covered.

    :param augment: The lowercase token to the left of the hyphen.
    :param base: The lowercase token to the right of the hyphen.
    :return: True if `augment` is a plausible intensifier of `base`.
    """
    # A genuine augment is always a reduced form of the base's own first
    # syllable, and every template in `_augment_candidates` changes at least
    # one character in doing so — it is never a literal prefix of the base.
    # A literal prefix relationship instead signals ordinary shared-stem
    # morphology: distributive/reciprocal reduplication ("бэйэ-бэйэтин",
    # 'each other'; "бары-барыта", 'all of them') or an unrelated compound
    # ("көр-көрүдьүөс"). This is checked first because it can otherwise slip
    # past even the strict template match below by coincidence — "бары" is
    # both a real word and, independently, this template's derivation from
    # "барыта" — confirmed as false positives against yakutmorph_dataset.
    if base.startswith(augment):
        return False
    if augment in _augment_candidates(base):
        return True
    if (augment, base) in IRREGULAR_INTENSIFIERS:
        return True
    # The remaining guards apply only to the fuzzy fallback: a genuine
    # augment is strictly shorter than its base (impossible for e.g.
    # "мал-сал", same length) and ends in one of the three templates'
    # possible final characters (impossible for e.g. "көр", ending in a
    # consonant no template produces) — without them the fuzzy fallback is
    # easily fooled by same-stem pairs sharing several characters by chance.
    if len(augment) >= len(base):
        return False
    if augment[-1] not in _VALID_AUGMENT_ENDINGS:
        return False
    return _prefix_similarity(augment, base) <= _SIMILARITY_THRESHOLD


def classify(left: str, right: str) -> str:
    """
    Classifies a [token]-[hyphen]-[token] triple as a reduplication, an
    intensifying augment, or a compound.

    :param left: The token to the left of the hyphen.
    :param right: The token to the right of the hyphen.
    :return: One of `construction_type.REDUPLICATION`,
        `construction_type.INTENSIFIER`, or `construction_type.COMPOUND`.
    """
    left, right = left.lower(), right.lower()
    if left == right:
        return construction_type.REDUPLICATION
    if is_intensifier(left, right):
        return construction_type.INTENSIFIER
    return construction_type.COMPOUND
