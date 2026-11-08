from typing import List, Dict

from .interfaces import OutputFormat
from .wrappers import Morph, Parse, Token


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

        def __category_morph(token: Token) -> Morph:
            """
            The morph carrying the analysis's current lexical category:
            the last derivational affix (e.g. +ADJZ#16 in "хараа+V+ADJZ#16"),
            or the root itself (which already folds in its own category
            tag) when there is no further derivation — the common case for
            underived words, possibly still inflected.
            """
            kept, _ = token.morph.split_at_last_derivation()
            return kept[-1]

        def __map_tag(token: Token, tag_type: str) -> str:
            if token.has_morph:
                return __category_morph(token).map(tag_type)
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

        def __lexical_root(ud_map: Dict, root_text: str):
            if not ud_map:
                return dict()
            return ud_map.get(root_text, dict())

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

            # Split the analysis at its last derivational boundary: the
            # category-bearing morph (root, or the last derivational
            # affix) supplies the base grammemes and any per-root 'ud'
            # exceptions (e.g. pronoun-specific mappings); every morph
            # after it is purely inflectional and feeds in on top.
            category_morph = __category_morph(token)
            _, inflections = token.morph.split_at_last_derivation()

            grammemes = __init_zero_affixation(category_morph.map('UPOS'))
            grammemes.update(__lexical_root(category_morph.map('ud'), token.morph.root_text))

            affix_grammemes = dict()
            for affix in inflections:
                affix_grammemes.update(__affixes(affix))
            # The default Mood=Imp of a verb (a bare stem is the 2SG
            # imperative) does not hold for a tensed form whose affixes
            # bring no mood of their own, e.g. кэл+V+PST.3PL. Forms whose
            # affix sets both (+IMP.FUT) keep their own mood.
            if 'Tense' in affix_grammemes and 'Mood' not in affix_grammemes:
                grammemes.pop('Mood', None)
            grammemes.update(affix_grammemes)

            __combine_grammemes(grammemes)

            to_string = [
                f'{key}={value}'
                for key, value in sorted(grammemes.items())
            ]
            return '|'.join(to_string) if grammemes else '_'

        def __get_root(token: Token) -> str:
            """
            The MISC column: the full underlying FST analysis, as
            treebank-specific annotation (per the CoNLL-U spec, MISC holds
            "any additional information that does not fit into any of the
            other fields, such as language-specific annotation"). Keyed,
            rather than a bare string, so it coexists unambiguously with
            any other '|'-joined MISC annotation (e.g. SpaceAfter=No)
            added later.
            """
            if not token.has_morph:
                return '_'
            analysis = ''.join([m.morpheme for m in token.morph.morphemes])
            return f'Analysis={analysis}'

        rows = [[line] for line in header] if header else [[f'# text = {parse.text}']]
        rows.extend([
            [
                str(token.pos),
                token.surface,
                __get_lemma(token),
                __map_tag(token, 'UPOS'),
                __map_tag(token, 'XPOS'),
                __map_grammmemes(token),
                '_',  # HEAD
                '_',  # DEPREL
                '_',  # DEPS
                __get_root(token)  # MISC
            ]
            for token in parse.tokens
        ])
        return '\n'.join(['\t'.join(row) for row in rows])


def conllu_document(parses: List[Parse]) -> str:
    """
    A CoNLL-U document for several sentences (e.g. from
    `YakutMorph.parse_text`): one block per sentence, each with
    `# sent_id` and `# text` comments and followed by a blank line, as the
    format requires.
    """
    blocks = [
        CoNLLU(parse, header=[f'# sent_id = {i}', f'# text = {parse.text}'])
        for i, parse in enumerate(parses, start=1)
    ]
    return ''.join(block + '\n\n' for block in blocks)


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
                    # One entry per candidate analysis, each its own dict.
                    parses.append({
                        **parse,
                        "fst": fst.label,
                        "root": analysis.root.morpheme,
                        "affixes": [m.morpheme for m in analysis.morphemes]
                    })
            else:
                parses.append(parse)
        fields.update({"parses": parses})
        return fields
