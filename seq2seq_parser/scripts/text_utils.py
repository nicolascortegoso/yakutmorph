"""Shared text normalization for the seq2seq pipeline.

Applied identically wherever raw text reaches the tokenizer — tokenizer
training here, and later the data loader / inference code — so encoder input
is never tokenized inconsistently between training and serving.
"""
import unicodedata


def normalize_text(text: str) -> str:
    """Unicode-normalize (NFC) and lowercase.

    Lowercasing is safe here because the target side never needs to
    reproduce surface capitalization: gold roots are already stored
    lowercase regardless of the source token's case (sentence-initial
    capital, proper nouns, acronyms), and no tag in the label set encodes
    case information. Folding case on the input side collapses e.g. "Аны"
    (sentence-initial) and "аны" (mid-sentence) into the same subword
    pieces instead of splitting the tokenizer's/model's capacity across
    two surface forms of the same word.
    """
    return unicodedata.normalize("NFC", text).lower()
