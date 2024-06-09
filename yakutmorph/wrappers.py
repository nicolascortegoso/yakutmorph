from dataclasses import dataclass, field
from typing import Dict, List, Optional, Union

from .interfaces import MorphReference, Transducer


@dataclass
class Morph:
    """
    Represents a morphological unit with a type and reference information.

    Attributes:
        morpheme: The string representation of the morpheme.
        type: The type of the morpheme (e.g., 'root', 'db', 'fl').
        reference: A dictionary containing reference information about the morpheme.
    """

    morpheme: str
    type: str
    reference: Dict

    def __repr__(self):
        """
        Returns a string representation of the Morph.

        :return: A string representing the Morph with its morpheme.
        """
        return f'{self.__class__.__name__}({self.morpheme})'

    def map(self, field: str):
        """
        Retrieves the value associated with the given field from the reference dictionary.

        :param field: The field to look up in the reference dictionary.
        :return: The value associated with the field, or None if the field is not found.
        """
        return self.reference.get(field, None)


@dataclass
class InflGroup:
    """
    Represents a group of inflectional morphemes.

    Attributes:
        pos: The position of the inflection group.
        affixes: A list of morpheme objects representing affixes.
    """

    pos: int
    affixes: List[Morph]

    def __repr__(self):
        """
        Returns a string representation of the InflGroup.

        :return: A string representing the InflGroup with its position.
        """
        return f'{self.__class__.__name__}({self.pos})'


class Analysis:
    """
    Represents the analysis of morphemes within a given context.

    Attributes:
        root: The lexical root of the analysis.
        infl_groups: A list of inflectional groups.
    """

    def __init__(self, morphemes: List[str], reference: MorphReference):

        self.root = Morph(morphemes[0], 'root', {})
        self.infl_groups = [
            InflGroup(i, igs)
            for i, igs in enumerate(self.__set_infl_groups(morphemes, reference), start=1)
        ]

    def __set_infl_groups(self, morphemes: List[str], reference: MorphReference) -> List[InflGroup]:
        """
        Private method to set inflection groups from morphemes.

        :param morphemes: A list of morphemes.
        :param reference: A reference to the morphology implemented by the transducer.
        :return: A list of inflectional groups.
        """
        infl_groups = list()
        curr_infl_group = list()
        last_idx = len(morphemes) - 1
        while last_idx > 0:
            ig = Morph(
                morphemes[last_idx],
                'db' if morphemes[last_idx].startswith('^') else 'fl',
                reference.get_tag(morphemes[last_idx])
            )

            curr_infl_group.insert(0, ig)
            if ig.type == 'db':
                infl_groups.insert(0, curr_infl_group)
                curr_infl_group = list()
            last_idx -= 1
        return infl_groups

    @property
    def morphemes(self):
        """
        Property to get all morphemes including the root and inflection groups.

        :return: A list of 'Morph' objects.
        """
        return [self.root] + [ig for group in self.infl_groups for ig in group.affixes]

    def remove_inflections(self):
        """
        Removes inflection morphemes from the last inflectional group.

        :return: A list of 'Morph' objects.
        """
        morphemes = self.morphemes
        last_idx = len(morphemes) - 1
        while last_idx > 0:
            if morphemes[last_idx].type == 'db':
                break
            last_idx -= 1
        return morphemes[:last_idx + 1]

    def __repr__(self):
        """
        Returns a string representation of the Analysis.

        :return: A string representation of the 'Analysis' object.
        """
        return f'Analysis({self.morphemes})'

@dataclass
class Analyses:
    """
    A class to represent the morphological analyses of a token, including the
    finite-state transducer (fst) that produced the output.

    Attributes:
        fst: The finite-state transducer used for the morphological analyses.
        output: The list of morphological analyses for the token.
    """

    fst: Transducer
    output: List[Analysis] = field(default_factory=list)
    idx_mla: int = None

    def set_mla(self, idx: int) -> None:
        self.idx_mla = idx

    def __repr__(self):
        """
        Returns a string representation of the Analyses object, displaying the class name,
        the FST used, and the number of morphological analyses.

        :return: A string representation of the Analyses object.
        """
        return f'{self.__class__.__name__}({self.fst}={len(self.output)})'


@dataclass
class Token:
    """
    A class to represent a token in a sequence, with its position, surface form,
    type, and optional morphological analyses.

    Attributes:
        pos: The position of the token in the input text.
        surface: The surface form of the token.
        type: The type of the token.
        has_morph: Indicates whether the token has morphological analyses.
        analyses: The morphological analyses of the token.
    """

    pos: int
    surface: str
    type: str
    has_morph: bool
    analyses: Optional[Analyses] = None

    def __repr__(self):
        """
        Returns a string representation of the Token object, displaying the class name
        and the surface form of the token.

        :return: A string representation of the Token object.
        """
        return f'{self.__class__.__name__}({self.surface})'

    def is_ambiguous(self) -> bool:
        """
        Checks if the token is morphologically ambiguous, i.e., has more than one possible
        morphological analysis.

        :return: True if the token is ambiguous, False otherwise.
        """
        if not self.analyses or len(self.analyses.output) == 1:
            return False
        return True

    @property
    def morph(self) -> Union[Analysis, None]:
        """
        Returns the most likely analysis for a token with morphology.

        :return: a Morph object with the most likely morphological analysis.
        """
        if not self.analyses:
            return None
        return self.analyses.output[self.analyses.idx_mla]

    @property
    def lemmas(self) -> List[str]:
        """
        Generates lemmas from a given analysis.

        :return: A list of surface forms for a given analysis.
        """
        analysis = ''.join([m.morpheme for m in self.morph.remove_inflections()])
        lemmas = self.analyses.fst.generate(analysis)
        return lemmas


@dataclass
class Parse:
    """
    A class to represent and manipulate a parsed text, consisting of tokens
    and their respective morphological parses.

    Attributes:
        text: The input text.
        tokens: The list of tokens in the input text.
    """

    text: str
    tokens: List[Token]

    def __repr__(self):
        """
        Returns a string representation of the Parse object.

        :return: A string representation of the Parse object.
        """
        return f'{self.__class__.__name__}({self.text})'

    def is_ambiguous(self) -> bool:
        """
        Checks if any token in the input text is morphologically ambiguous, i.e., has
        more than one possible morphological analysis.

        :return: True if any token is ambiguous, False otherwise.
        """
        return any([token for token in self.tokens if token.is_ambiguous()])

    def get_dag(self, mapper) -> List[List[str]]:
        """
        Generates a directed acyclic graph (DAG) representation of the morphological
        parses for the input sequence. Each node in the DAG represents a morphological
        analysis of a token.

        :param mapper: An object that provides methods for processing morphological
            groups and mapping token types.
        :return: A DAG where each sublist contains the nodes (morphological analyses)
            for a token.
        """
        dag = [['<BOS>']]
        for token in self.tokens:
            nodes = []
            if token.analyses:
                for analysis in token.analyses.output:
                    last_ig_affixes = [affix.morpheme for affix in analysis.infl_groups[-1].affixes]
                    node = ''.join(mapper.process_morphs(last_ig_affixes))
                    nodes.append(node)
            else:
                node = mapper.map_token_type(token.type)
                nodes.append(node)
            dag.append(nodes)
        dag.append(['<EOS>'])
        return dag
