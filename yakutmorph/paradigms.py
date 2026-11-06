"""
Inflection tables generated with the lexicon transducer.

>>> from yakutmorph.paradigms import paradigm
>>> table = paradigm('дьиэ', 'N')
>>> table['tables'][0]['rows'][2]['cells']['SG']
['дьиэҕэ']

Every cell holds the forms the transducer generates for that analysis (some
cells have variants); an empty list means it generates none. Only roots in
the lexicon can be inflected.
"""
from typing import Dict, List, Optional, Tuple

from .transducers import YakutTransducer

CASES = ['NOM', 'ACC', 'DAT', 'ABL', 'INST', 'COMIT', 'COMP', 'PRTV']
POSSESSORS = ['1SG', '2SG', '3SG', '1PL', '2PL', '3PL']
PERSONS = ['1SG', '2SG', '3SG', '1PL', '2PL', '3PL']

# Verb tenses, named with the Tense values of the CoNLL-U mapper, and the
# affixes that follow the (possibly negated) stem for each person.
VERB_TENSES: List[Tuple[str, List[str]]] = [
    ('Pres', ['+PART_PRES+1SG', '+PART_PRES+2SG', '+PART_PRES', '+PART_PRES+1PL', '+PART_PRES+2PL', '+PART_PRES+PL']),
    ('NearPast', ['+PST.1SG', '+PST.2SG', '+PST.3SG', '+PST.1PL', '+PST.2PL', '+PST.3PL']),
    ('PastResult', ['+PART_PAST+POSS.1SG', '+PART_PAST+POSS.2SG', '+PART_PAST',
                    '+PART_PAST+POSS.1PL', '+PART_PAST+POSS.2PL', '+PART_PAST+PL']),
    ('Fut', ['+PART_FUT+POSS.1SG', '+PART_FUT+POSS.2SG', '+PART_FUT',
             '+PART_FUT+POSS.1PL', '+PART_FUT+POSS.2PL', '+PART_FUT+PL+POSS.3SG']),
]

CATEGORIES = ('N', 'V')


def _case(case: str) -> str:
    return '' if case == 'NOM' else f'+{case}'


def _possessive(possessor: str, case: str) -> str:
    return f'+POSS.{possessor}' + ('' if case == 'NOM' else f'.{case}')


def _table(name: str, columns: List[str], rows: List[Tuple[str, Dict[str, str]]],
           generate) -> Dict:
    return {
        'name': name,
        'columns': columns,
        'rows': [
            {
                'label': label,
                'cells': {column: generate(analysis) for column, analysis in analyses.items()},
                'analyses': analyses,
            }
            for label, analyses in rows
        ],
    }


def paradigm(root: str, category: str = 'N', transducer: Optional[YakutTransducer] = None) -> Dict:
    """
    The inflection tables of a root.

    :param root: The root, e.g. 'дьиэ' or 'көр'.
    :param category: 'N' (noun: case by number, and by possessor for one
        and for several possessed) or 'V' (verb: finite forms by tense and
        person, affirmative and negative).
    :param transducer: The transducer used to generate; the lexicon
        transducer by default.
    :return: {'root', 'category', 'tables': [{'name', 'columns', 'rows':
        [{'label', 'cells': {column: [forms]}, 'analyses': {column: analysis}}]}]}
    :raises ValueError: for an unknown category, or a root the lexicon does
        not have in that category.
    """
    if category not in CATEGORIES:
        raise ValueError(f'category must be one of {CATEGORIES}')
    transducer = transducer or YakutTransducer()
    root = root.strip().lower()
    stem = f'{root}+{category}'
    if not transducer.generate(stem):
        raise ValueError(f'"{root}" is not in the lexicon as {category}.')

    def generate(analysis: str) -> List[str]:
        return transducer.generate(analysis)

    if category == 'N':
        tables = [
            _table('Case and number', ['SG', 'PL'], [
                (case, {'SG': stem + _case(case), 'PL': stem + '+PL' + _case(case)}) for case in CASES
            ], generate),
            _table('Possessive, one possessed', POSSESSORS, [
                (case, {p: stem + _possessive(p, case) for p in POSSESSORS}) for case in CASES
            ], generate),
            _table('Possessive, several possessed', POSSESSORS, [
                (case, {p: stem + '+PL' + _possessive(p, case) for p in POSSESSORS}) for case in CASES
            ], generate),
        ]
    else:
        tables = [
            _table(name, PERSONS, [
                (tense, dict(zip(PERSONS, (stem + negation + suffix for suffix in suffixes))))
                for tense, suffixes in VERB_TENSES
            ], generate)
            for name, negation in (('Affirmative', ''), ('Negative', '+NEG'))
        ]
    return {'root': root, 'category': category, 'tables': tables}
