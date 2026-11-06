"""
Interlinear glossing in the style of the Leipzig Glossing Rules: each word
is segmented into morphemes (separated by '-'), and each segment is glossed
with the analyser's tags.

>>> from yakutmorph import YakutMorph
>>> from yakutmorph.glossing import gloss_words
>>> [(w['segmented'], w['gloss']) for w in gloss_words(YakutMorph().parse('дьиэлэргэ'))]
[('дьиэ-лэр-гэ', 'дьиэ-PL-DAT')]
>>> gloss_words(YakutMorph().parse('көрбөппүн'))[0]['gloss']
'көр-NEG.PART_PRES-1SG'

How the segmentation is found: the transducer gives the analysis of a word
but not where its morphemes begin in the written form. They are found by
generating the analysis step by step (root, root + first affix, ...) and
comparing each generated form with the word: where a step generates the
beginning of the word, a morpheme boundary is placed (allowing for an
alternation of the last letter, as in хараҕ-ыттан from харах). Where a step
does not, there is no visible boundary, and that affix's gloss is joined to
the next one with '.' (e.g. көр-бөп-пүн 'see-NEG.PART_PRES-1SG'). The root is
glossed with itself (the analyser has no translations), and category tags
such as +N or +V, which are not morphemes, are left out. The segmentation is
therefore an approximation, best checked by a linguist.
"""
from typing import Dict, List

from .wrappers import Parse, Token


# Consonant alternations at a morpheme boundary: the generated form may end
# in the first letter where the word has the second. Voicing of a
# stem-final consonant before a vowel (харах -> хараҕ-ыттан) and assimilation
# of т to a following п or к (көрбөт -> көр-бөп-пүн).
ALTERNATIONS = {('х', 'ҕ'), ('к', 'г'), ('п', 'б'), ('с', 'һ'), ('т', 'п'), ('т', 'к')}


def _boundary(generated: List[str], word: str) -> int:
    """
    Where a morpheme boundary falls in `word`, given the forms generated for
    an analysis prefix: the end of a generated form that is a prefix of the
    word (allowing a stem-final alternation); -1 if there is none.
    """
    best = -1
    for form in generated:
        if not form or len(form) > len(word):
            continue
        if word.startswith(form) or (
                word.startswith(form[:-1]) and (form[-1], word[len(form) - 1]) in ALTERNATIONS):
            best = max(best, len(form))
    return best


def gloss_token(token: Token) -> Dict[str, str]:
    """
    The segmentation and gloss of one token: {'text', 'segmented', 'gloss'}.
    Tokens without an analysis (punctuation) are returned unchanged, with an
    empty gloss.
    """
    if not token.has_morph:
        return {'text': token.surface, 'segmented': token.surface, 'gloss': ''}
    morphemes = token.morph.morphemes
    fst = token.analyses.fst
    word = token.surface
    lower = word.lower()

    def boundary(analysis: str) -> int:
        # '+PN' is added after the transducer, which only knows '+N'.
        return _boundary(fst.generate(analysis.replace('+PN', '+N', 1)), lower)

    # segments[i] holds the glosses of the i-th piece of the word, which
    # ends at cuts[i].
    segments: List[List[str]] = [[token.morph.root_text]]
    cuts: List[int] = []
    analysis = morphemes[0].morpheme
    pending: List[str] = []
    for i, morph in enumerate(morphemes[1:], start=1):
        position = boundary(analysis)
        if position > (cuts[-1] if cuts else 0):
            cuts.append(position)
            segments[-1].extend(pending)
            segments.append([])
            pending = []
        analysis += morph.morpheme
        pending.append(morph.morpheme.lstrip('+^'))
    segments[-1].extend(pending)
    cuts.append(len(lower))

    if len(segments) == 1:  # no visible boundary
        return {'text': word, 'segmented': word, 'gloss': '.'.join(segments[0])}
    starts = [0] + cuts[:-1]
    return {
        'text': word,
        'segmented': '-'.join(word[a:b] for a, b in zip(starts, cuts)),
        'gloss': '-'.join('.'.join(glosses) for glosses in segments),
    }


def gloss_words(parse: Parse) -> List[Dict[str, str]]:
    """The segmentation and gloss of every token of a sentence."""
    return [gloss_token(token) for token in parse.tokens]


def interlinear(parse: Parse, translation: str = '') -> str:
    """
    A sentence as interlinear text: the original line, the segmented line
    and the gloss line (aligned word by word), and an optional free
    translation in quotation marks.
    """
    words = [w for w in gloss_words(parse)]
    widths = [max(len(w['segmented']), len(w['gloss'])) for w in words]
    lines = [
        parse.text,
        '  '.join(w['segmented'].ljust(n) for w, n in zip(words, widths)).rstrip(),
        '  '.join(w['gloss'].ljust(n) for w, n in zip(words, widths)).rstrip(),
    ]
    if translation:
        lines.append(f"'{translation}'")
    return '\n'.join(lines)
