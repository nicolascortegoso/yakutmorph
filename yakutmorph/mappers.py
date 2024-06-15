from typing import List, Dict

import yaml

from .interfaces import Mapper, OutputFormat
from .utils import get_file_path
from .wrappers import Morph, Parse, Token


class YakutMapper(Mapper):
    def __init__(self, path_to_file: str, inside_package: bool = False):
        path = get_file_path(path_to_file) if inside_package else path_to_file
        with open(path, 'r') as f:
            self.mappings = yaml.safe_load(f)

    def reduce_morph(self, morphs: List[str]) -> List[str]:
        return [morph.split('#')[0] for morph in morphs]

    def filter_morph(self, morphs: List[str]) -> List[str]:
        return [morph for morph in morphs if morph in self.mappings['feature_morphs']]

    def map_morph(self, morph: str) -> str:
        return self.mappings['morph_mapping'].get(morph, morph)

    def process_morphs(self, morphs: List[str]) -> List[str]:
        return [self.map_morph(morph) for morph in self.filter_morph(self.reduce_morph(morphs))]

    def map_token_type(self, token_type: str) -> str:
        return self.mappings['token_type_mapping'].get(token_type, token_type)


class CoNLLU(OutputFormat):
    """
    A class to format a Parse object into a CoNLL-U string used in Universal Dependencies' treebanks.
    The mapping requires to apply a series of transformations in cascade.
    """
    def __new__(self, parse: Parse, header: List[str] = None):
        def __get_lemma(token: Token) -> str:
            """
            The model does not provide a method to disambiguate lemmas, therefore,
            ambiguous lemmas are separated by the operator '|'.
            """
            if token.has_morph:
                return '|'.join(token.lemmas)
            return token.surface

        def __map_token_type(token: Token, tag_type: str) -> str:
            """Maps tokens without morphology."""
            if token.type in ['number', 'roman']:
                return 'NUM' if tag_type == 'UPOS' else 'num'
            if token.type in ['symbol']:
                return 'SYM' if tag_type == 'UPOS' else 'sym'
            return 'PUNCT' if tag_type == 'UPOS' else 'punct'

        def __map_tag(token: Token, tag_type: str) -> str:
            if token.has_morph:
                last_ig = token.morph.infl_groups[-1]
                morpheme = last_ig.affixes[0]
                return morpheme.map(tag_type)
            return __map_token_type(token, tag_type)

        def __init_zero_affixation(upos: str):
            """Add default grammemes that correspond to zero affixation."""
            grammemes = dict()
            if upos == 'VERB':
                grammemes.update({'Mood': 'Imp'})

            elif upos == 'PROPN':
                grammemes.update({'Case': 'Nom'})

            elif upos == 'NUM':
                grammemes.update({'NumType': 'Card'})

            elif upos == 'NOUN':
                grammemes.update({'Case': 'Nom', 'Number': 'Sing'})

            return grammemes

        def __lexical_root(affix: Morph, root: Morph):
            if not affix:
                return dict()
            return affix.get(root.morpheme, dict())

        def __affixes(affix):
            if not affix:
                return dict()
            mapped_affix = affix.map('ud')
            return mapped_affix if mapped_affix else dict()

        def __combine_grammemes(grammemes: Dict) -> None:
            """Modifies a series of grammemes if some conditions are met within the set."""
            def __map_possessive(grammemes):
                grammemes['Person'] = grammemes.get('Person[psor]')
                grammemes['Number'] = grammemes.get('Number[psor]')
                grammemes.pop('Person[psor]')
                grammemes.pop('Number[psor]')

            def __add_person_number(grammemes):
                """For some forms the 3 person singular correspond to zero affixation."""
                #CHECK PLURAL?
                grammemes.update({'Person': 3, 'Number': 'Sing'})

            def __map_tense(grammemes):
                pos = grammemes.get('Person[psor]')
                pred = grammemes.get('Person')
                if pos and tense in ['Fut', 'PastResult']:
                    __map_possessive(grammemes)
                elif tense == 'PastResult' and pred:
                    grammemes['Tense'] = 'PastPerf'
                if not pos and not pred:
                    __add_person_number(grammemes)

            if grammemes.get('VerbForm', None) and grammemes.get('Mood', None):
                grammemes.pop('Mood')
            tense = grammemes.get('Tense', None)
            if tense:
                __map_tense(grammemes)

        def __map_grammmemes(token: Token):
            if not token.morph:
                return '_'

            affixes = token.morph.infl_groups[-1].affixes

            grammemes = __init_zero_affixation(__map_tag(token, 'UPOS'))
            grammemes.update(__lexical_root(affixes[0].map('ud'), token.morph.root))

            for affix in affixes[1:]:
                grammemes.update(__affixes(affix))

            __combine_grammemes(grammemes)

            to_string = [
                f'{key}={value}'
                for key, value in sorted(grammemes.items())
            ]
            return '|'.join(to_string) if grammemes else '_'

        def __get_root(token: Token) -> str:
            return ''.join([m.morpheme for m in token.morph.morphemes]) if token.has_morph else '_'

        rows = [[line] for line in header] if header else [[f'# text = {parse.text}']]
        rows.extend([
            [
                str(token.pos),
                token.surface,
                __get_lemma(token),
                __map_tag(token, 'UPOS'),
                __map_tag(token, 'XPOS'),
                __map_grammmemes(token),
                '_',
                '_',
                __get_root(token)
            ]
            for token in parse.tokens
        ])
        return '\n'.join(['\t'.join(row) for row in rows])


class YakutAnnotation(OutputFormat):
    """
    A custom class to format a Parse object.
    """

    def __new__(cls, parse: Parse, header: Dict):
        fields = header if header else dict()
        parses = list()
        for token in parse.tokens:
            parse = {
                "pos": token.pos,
                "text": token.surface,
                "type": token.type,
                "fst": None
            }
            if token.has_morph:
                parse.update({
                    "fst": token.analyses.fst.label,
                    "root": token.morph.root.morpheme,
                    "affixes": [m.morpheme for m in token.morph.morphemes]
                })
            parses.append(parse)
        fields.update({"parses": parses})
        return fields


class YakutManualDisambiguation(OutputFormat):
    """
    Outputs all the analysis for manual disambiguation.
    """

    def __new__(cls, parse: Parse):
        fields = {"sah": parse.text}

        parses = list()
        for token in parse.tokens:
            parse = {
                "pos": token.pos,
                "text": token.surface,
                "type": token.type,
                "fst": None
            }
            if token.has_morph:
                fst = token.analyses.fst
                for analysis in token.analyses.output:
                    parse.update({
                        "fst": fst,
                        "root": analysis.root.morpheme,
                        "affixes": [m.morpheme for m in analysis.morphemes]
                    })
                    parses.append(parse)
            else:
                parses.append(parse)
        fields.update({"parses": parses})
        return fields
