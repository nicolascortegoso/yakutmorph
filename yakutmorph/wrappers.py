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
        root: The lexical root of the analysis, combined with its own
            category tag (e.g. "мин+N", not just "мин") — matching how
            "root" is used everywhere else this analyzer's output feeds
            into (the gold dataset schema, the disambiguation model's
            candidate strings): a root's own category is inseparable from
            it, not a first affix among others.
        root_text: Just the bare lexical root string (e.g. "мин"), without
            its category tag — needed internally wherever a reference
            lookup is keyed by the literal root (e.g. per-pronoun 'ud'
            mappings in morph_reference.yaml), which `root.morpheme` no
            longer directly is.
        infl_groups: A list of inflectional groups covering everything
            beyond the root's own category — empty if the analysis has no
            further derivation or inflection at all.
    """

    def __init__(self, morphemes: List[str], reference: MorphReference):

        self.root_text = morphemes[0]
        self.root = Morph(morphemes[0] + morphemes[1], 'root', reference.get_tag(morphemes[1]))
        self.infl_groups = [
            InflGroup(i, igs)
            for i, igs in enumerate(self.__set_infl_groups(morphemes, reference), start=1)
        ]

    def __set_infl_groups(self, morphemes: List[str], reference: MorphReference) -> List[InflGroup]:
        """
        Private method to set inflection groups from morphemes, excluding
        the root and its own category tag (morphemes[0], morphemes[1]),
        which `__init__` already folded into `root`.

        :param morphemes: A list of morphemes.
        :param reference: A reference to the morphology implemented by the transducer.
        :return: A list of inflectional groups.
        """
        infl_groups = list()
        curr_infl_group = list()
        last_idx = len(morphemes) - 1
        while last_idx > 1:
            ig = Morph(
                morphemes[last_idx],
                'db' if reference.is_boundary(morphemes[last_idx]) else 'fl',
                reference.get_tag(morphemes[last_idx])
            )

            curr_infl_group.insert(0, ig)
            if ig.type == 'db':
                infl_groups.insert(0, curr_infl_group)
                curr_infl_group = list()
            last_idx -= 1
        # Whatever's left accumulated since the last (or only) boundary —
        # e.g. pure inflection directly on the root's own category, with no
        # further derivational boundary of its own — still needs its group.
        if curr_infl_group:
            infl_groups.insert(0, curr_infl_group)
        return infl_groups

    @property
    def morphemes(self):
        """
        Property to get all morphemes including the root and inflection groups.

        :return: A list of 'Morph' objects.
        """
        return [self.root] + [ig for group in self.infl_groups for ig in group.affixes]

    def split_at_last_derivation(self):
        """
        Splits the analysis at its last derivational boundary: walks
        `morphemes` backward from the end, treating each inflectional
        ('fl') morph as part of the word's inflection, until either a
        derivational ('db') morph is found or only the root is left (an
        analysis with no derivation beyond the root's own category).

        This is the single place that answers "where does the lemma end
        and the inflection begin" — both lemma lookup (`remove_inflections`)
        and grammatical-feature extraction (e.g. `CoNLLU`'s mapper) are
        expressed in terms of it, rather than each re-deriving the split
        point its own way.

        :return: A tuple (kept, inflections):
            - kept: `morphemes`, truncated right after the last
              derivational boundary (or just the root, if there is none).
              `kept[-1]` is the morph carrying the analysis's current
              lexical category — either that derivational affix, or the
              root itself. Joining `kept`'s morpheme strings and handing
              the result to the transducer's `generate` produces the
              lemma.
            - inflections: the Morph objects after that point — every
              affix that inflects the word without changing its lemma
              or category.
        """
        morphemes = self.morphemes
        last_idx = len(morphemes) - 1
        while last_idx > 0 and morphemes[last_idx].type != 'db':
            last_idx -= 1
        return morphemes[:last_idx + 1], morphemes[last_idx + 1:]

    def remove_inflections(self):
        """
        Removes inflection morphemes from the end of the analysis, keeping
        everything up to and including the last derivational boundary (or
        just the root, if there is none).

        :return: A list of 'Morph' objects.
        """
        kept, _ = self.split_at_last_derivation()
        return kept

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
    # The disambiguation model's probability for each analysis in `output`
    # (same order); None when the token was not disambiguated by the model.
    probabilities: Optional[List[float]] = None

    def set_mla(self, idx: int) -> None:
        self.idx_mla = idx

    @property
    def confidence(self) -> Optional[float]:
        """
        The probability of the chosen analysis: 1.0 when there is only one
        analysis, the model's probability when it chose among several, and
        None when the choice was not made by the model (e.g. set by hand).
        """
        if len(self.output) == 1:
            return 1.0
        if self.probabilities is None or self.idx_mla is None:
            return None
        return self.probabilities[self.idx_mla]

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
        compound: The label of the multi-token construction this token is
            part of, if any — `None` otherwise. Covers two distinct
            detection mechanisms sharing one flag:
              - hyphen-joined constructions (reduplication, intensifying
                augmentation, compounding; see `yakutmorph.intensifiers`),
                where the label is one of `intensifiers.construction_type`'s
                values;
              - whitespace-separated multi-word constructions matched
                against a pattern lexicon (fixed idioms like "ол да
                буоллар", or open-ended category runs like a sequence of
                proper nouns; see `yakutmorph.constructions`), where the
                label is that pattern's own name from the lexicon.
            Tokens sharing the same (non-`None`) label and adjacent
            positions belong to the same matched construction; unlike the
            hyphen case, a multi-word match never replaces the member
            tokens' own analyses — each keeps whatever it was disambiguated
            to.
    """

    pos: int
    surface: str
    type: str
    has_morph: bool
    analyses: Optional[Analyses] = None
    compound: Optional[str] = None

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
        if self.morph.root.morpheme.endswith('+PN'):
            # '+PN' is assigned after the transducer (see
            # transducers.PostPipeline), which analyses names as '+N', so
            # a proper noun's lemma is generated from its '+N' form.
            analysis = analysis.replace('+PN', '+N', 1)
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
