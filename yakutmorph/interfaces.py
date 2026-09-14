from abc import abstractmethod, ABC
from typing import List, Any


class Tokenizer(ABC):
    """
    Abstract class for a tokenizer.
    """

    @abstractmethod
    def tokenize(self, text: str) -> List[str]:
        """
        Split the input text into a list of tokens.

        :param text: The text to be tokenized.
        :return: A list of tokens extracted from the input text.
        """
        ...

    @abstractmethod
    def has_morphology(self) -> List[str]:
        """
        Return a list of token types that can be morphologically analysed.

        :return: A list of token types that have morphology.
        """
        ...


class MorphReference(ABC):

    @abstractmethod
    def get_tags(self) -> List[str]:
        """
        Returns a list of tags implemented in the transducer to mark lexical roots and affixes.
        """
        ...


class Transducer(ABC):
    """
    Abstract class for a transducer that performs morphological analysis and generation.
    """

    @abstractmethod
    def analyse(self, surface_form: str) -> List[str]:
        """
        Analyze a surface form and return possible analyses.

        :param surface_form: The surface form to be analyzed.
        :return: A list of possible analyses for the given surface form.
        """
        ...

    def generate(self, analysis_form: str) -> List[str]:
        """
        Generate possible surface forms from an analysis form.

        :param analysis_form: The analysis form to be used for generation.
        :return: A list of possible surface forms generated from the analysis form.
        """
        ...

    def __repr__(self):
        """
        Returns a string representation of the Transducer.
        """
        return f'Fst({self.label})'


class DisambiguationModel(ABC):
    """
    Abstract class for a morphological disambiguation process.
    """

    @abstractmethod
    def disambiguate(self, tokens: List) -> List[int]:
        """
        Selects the most probable analysis for each ambiguous token in a
        sequence, given the full token list for sentence context.

        :param tokens: The list of Token objects for the sentence (some with
            more than one candidate analysis, some with only one).
        :return: One index per *ambiguous* token (tokens with a single
            candidate are not included), in the same order they appear in
            `tokens`, each selecting that token's most likely candidate.
        """
        ...


class PostAnalysis(ABC):
    """
    Abstract base class for post-processing analysis of morphological data.
    This class provides a static method for applying transformations to a list
    of morphemes based on their surface form and token position.
    """

    @staticmethod
    def apply(morphemes: List[str], surface_form: str, token_pos: int) -> List[str]:
        """
        Applies post-processing analysis to a list of morphemes. The default
        implementation returns the input list of morphemes unchanged.

        :param morphemes: A list of morphemes.
        :param surface_form: The surface form of the token.
        :param token_pos: The position of the token in the sequence.
        :return: The list of morphemes after post-processing.
        """
        return morphemes


class OutputFormat(ABC):

    @staticmethod
    def apply(*args, **kwargs) -> Any:
        ...
