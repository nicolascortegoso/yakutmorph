"""
Sentence splitting for Yakut text.

A sentence ends after `.`, `...`, `?` or `!` when the next word starts with a
capital letter (or the next token is a dash, an opening quotation mark or a
number). Closing quotation marks and brackets right after the end mark stay
with the sentence (`... диэтэ.»`). A period after a single capital letter is
taken as an initial and does not end the sentence (`В.И. Ленин`). A blank
line always ends a sentence; single line breaks are treated as spaces.

>>> split_sentences('Кини кэллэ. Мин көрдүм!')
['Кини кэллэ.', 'Мин көрдүм!']
"""
import re
from typing import List, Optional, Tuple

from .interfaces import Tokenizer
from .tokenizers import YakutTokenizer

_types = YakutTokenizer.token_type
SENTENCE_END = {_types.STOP, _types.ELLIPSIS, _types.QUESTION, _types.EXCLAMATION}
CLOSING = set('»”’)]}')
OPENING = set('«“‘([{')
CAPITALIZED = {_types.TITLE, _types.UPPERCASE, _types.TITLELAT, _types.UPPERCASELAT}


def _offsets(text: str, tokens: List[Tuple[str, str]]) -> List[Tuple[int, int]]:
    """Start and end of each token in `text` (tokens appear in order)."""
    spans, position = [], 0
    for surface, _ in tokens:
        start = text.index(surface, position)
        spans.append((start, start + len(surface)))
        position = start + len(surface)
    return spans


def _clean(sentence: str) -> str:
    return ' '.join(sentence.split())


def _starts_sentence(surface: str, kind: str) -> bool:
    return (kind in CAPITALIZED or kind == _types.DASH or kind == _types.NUMBER
            or (kind == _types.QUOTATION and surface not in CLOSING)
            or (kind == _types.BRACKET and surface in OPENING))


def split_sentences(text: str, tokenizer: Optional[Tokenizer] = None) -> List[str]:
    """
    Splits a text into sentences.

    :param text: Yakut text, possibly several paragraphs.
    :param tokenizer: The tokenizer to use; YakutTokenizer by default.
    :return: The sentences, as written in the text, with whitespace
        inside a sentence (e.g. a line break) collapsed to one space.
    """
    tokenizer = tokenizer or YakutTokenizer()
    sentences = []
    for paragraph in re.split(r'\n\s*\n', text):
        tokens = tokenizer.tokenize(paragraph)
        if not tokens:
            continue
        spans = _offsets(paragraph, tokens)
        start, i = 0, 0
        while i < len(tokens):
            surface, kind = tokens[i]
            initial = (kind == _types.STOP and i > 0 and tokens[i - 1][1] in CAPITALIZED
                       and len(tokens[i - 1][0]) == 1)
            if kind in SENTENCE_END and not initial:
                end = i
                # Closing quotation marks / brackets attached to the end mark.
                while (end + 1 < len(tokens) and tokens[end + 1][0] in CLOSING | {'"', "'"}
                       and spans[end + 1][0] == spans[end][1]):
                    end += 1
                if end + 1 == len(tokens) or _starts_sentence(*tokens[end + 1]):
                    sentences.append(_clean(paragraph[spans[start][0]:spans[end][1]]))
                    start, i = end + 1, end + 1
                    continue
            i += 1
        if start < len(tokens):
            sentences.append(_clean(paragraph[spans[start][0]:spans[-1][1]]))
    return sentences
