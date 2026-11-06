"""
Plain-dictionary (JSON-ready) views of parsed sentences, shared by the
command-line tool and the MCP server.
"""
from typing import Any, Dict, List

from .mappers import CoNLLU
from .wrappers import Analysis, Parse, Token


def analysis_string(analysis: Analysis) -> str:
    """An analysis as 'root+TAG+TAG...'."""
    return ''.join(m.morpheme for m in analysis.morphemes)


def token_record(token: Token, conllu_row: List[str], alternatives: bool = True) -> Dict[str, Any]:
    """
    One token: position, text and type; for words also the chosen analysis,
    lemma, UPOS and features (from the CoNLL-U row), the transducer that
    analysed it, whether it was ambiguous, the model's confidence, the
    other candidates with their probabilities, and any construction label.
    """
    record: Dict[str, Any] = {'position': token.pos, 'text': token.surface, 'type': token.type}
    if not token.has_morph:
        return record
    candidates = [analysis_string(a) for a in token.analyses.output]
    record.update({
        'analysis': analysis_string(token.morph),
        'lemma': conllu_row[2],
        'upos': conllu_row[3],
        'features': conllu_row[5],
        'transducer': token.analyses.fst.label,
        'ambiguous': len(candidates) > 1,
    })
    confidence = token.analyses.confidence
    if confidence is not None:
        record['confidence'] = round(confidence, 3)
    if alternatives and len(candidates) > 1:
        probabilities = token.analyses.probabilities
        record['alternatives'] = [
            {'analysis': c, **({'probability': round(probabilities[i], 3)} if probabilities else {})}
            for i, c in enumerate(candidates) if i != token.analyses.idx_mla
        ]
    if token.compound:
        record['construction'] = token.compound
    return record


def sentence_record(parse: Parse, alternatives: bool = True) -> Dict[str, Any]:
    """One sentence: {'text', 'tokens': [token_record, ...]}."""
    rows = [line.split('\t') for line in str(CoNLLU(parse)).split('\n')[1:]]
    return {
        'text': parse.text,
        'tokens': [token_record(token, row, alternatives) for token, row in zip(parse.tokens, rows)],
    }
