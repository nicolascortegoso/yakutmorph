import re
from typing import Dict, List, Tuple

import sfst_transduce
import yaml

from .interfaces import MorphReference, PostAnalysis, Transducer
from .utils import get_file_path


class YakutMorphReference(MorphReference):
    """
    Represents a reference for a Yakut language transducer, loaded from a YAML file.
    """

    def __init__(self, path_to_file: str, inside_package: bool = False):
        path = get_file_path(path_to_file) if inside_package else path_to_file
        with open(path, 'r') as f:
            reference = yaml.safe_load(f)
        self.tags = {k: v for value in reference.values() for k, v in value.items()}

    def get_tags(self) -> List[str]:
        """
        Returns the list of tags implemented in the Yakut transducer.
        """
        return list(self.tags.keys())

    def get_tag(self, tag: str) -> Dict:

        return self.tags.get(tag, dict())


class YakutTransducer(Transducer):
    """
    A transducer for analyzing and generating Yakut word forms using a specified
    finite-state transducer.
    """

    def __init__(
            self,
            path_to_transducer: str = None,
            label: str = None,
            regex: str = None,
            reference: MorphReference = None
            ):
        """
        Initializes the YakutTransducer with the specified or default transducer
        binary file.

        :param path_to_transducer: Path to the binary file of the transducer.
            If not provided, the default transducer binary is used.
        """
        default_label = 'ymv'
        default_regex = r'[а-яёһҕҥөү]+|[\^\+][A-Za-z_#\d\.]+'

        self.transducer = sfst_transduce.Transducer(
            path_to_transducer if path_to_transducer else get_file_path('fsts/ymv.a')
        )
        self.label = label if label else default_label
        self.morphemes = re.compile(regex if regex else default_regex)
        self.reference = reference if reference else YakutMorphReference(
            'data/morph_reference.yaml', inside_package=True
        )

    def analyse(self, surface_form: str) -> List[str]:
        """
        Analyzes the given surface form and returns a list of possible analyses.

        :param surface_form: The surface form to be analyzed.
        :return: A list of possible analyses for the given surface form.
        """
        if not surface_form.islower():
            surface_form = surface_form.lower()
        return self.transducer.analyse(surface_form)

    def generate(self, analysis: str) -> List[str]:
        """
        Generates the surface form from the given analysis.

        :param analysis: The analysis to generate the surface form from.
        :return: A list of generated surface forms from the given analysis.
        """
        return self.transducer.generate(analysis)

    def get_morphemes(self, analysis: str) -> List[str]:
        return self.morphemes.findall(analysis)


class DummyTransducer(Transducer):
    """
    A dummy implementation of a transducer to handle unknown words.
    """

    def __init__(self, label: str, unknown_tag: str, reference: MorphReference = None):
        self.label = label
        self.unknown_tag = unknown_tag
        # Loads the default reference if no MorphReference is passed
        self.reference = reference if reference else YakutMorphReference(
            'data/morph_reference.yaml', inside_package=True
        )

    def analyse(self, surface_form: str) -> List[str]:
        """
        Analyses a surface form as unknown.

        :param surface_form: The unknown surface form.
        :return: A list containing the analysis result.
        """
        return [f'{surface_form}{self.unknown_tag}']

    def generate(self, analysis_form: str) -> List[str]:
        """
        Outputs back the unknown surface form by removing the unknown tag.

        :param analysis_form: The morphological analysis.
        :return: A list containing the surface form(s).
        """
        return [analysis_form.replace(self.unknown_tag, '')]

    def get_morphemes(self, analysis: str) -> List[str]:
        """
        Retrieves the morphemes from the given analysis.

        :param analysis: The morphological analysis.
        :return: A list containing the surface form and the unknown label.
        """
        return [analysis.replace(self.unknown_tag, ''), self.unknown_tag]


class YakutTransducerPipeline(Transducer):
    """
    A pipeline for analyzing and generating Yakut word forms using multiple
    transducers in series.
    """

    def __init__(self, transducers: Dict[str, str] = None, morph_reference: YakutMorphReference = None):
        """
        Initializes the YakutTransducerPipeline with the specified or default
        transducers.

        :param transducers: A dictionary mapping transducer labels to the path to their corresponding
            binary file names. Defaults to a predefined set of transducers.
        """
        default_transducers = {
            'voc': 'fsts/ymv.a',
            'syl': 'fsts/yms.a',
            'aff': 'fsts/yma.a'
        }

        self.pipeline = self.__initialize_pipeline(
            transducers if transducers else default_transducers,
            morph_reference
        )

    def __initialize_pipeline(self, transducers, morph_reference: YakutMorphReference) -> List[Transducer]:
        """
        Initializes the pipeline with the given transducers.

        :param transducers: A dictionary mapping transducer labels to their
            corresponding path to the binary file names.
        :return: A list of functional transducers and a dummy one.
        """
        yakut_reference = morph_reference
        pipeline = [
            YakutTransducer(
                get_file_path(transducer_file),
                label=transducer_label,
                reference=yakut_reference
            )
            for transducer_label, transducer_file in transducers.items()
        ]
        pipeline.append(DummyTransducer('fail', '^UNK'))
        return pipeline

    def analyse(self, surface_form: str) -> Tuple[Transducer, List[str]]:
        """
        Analyzes the given surface form using the transducer pipeline.

        :param surface_form: The surface form to be analyzed.
        :return: the transducer that performed the analysis and a list of possible interpretations.
        """
        transducer_idx = 0
        while transducer_idx < len(self.pipeline):
            analyses = self.pipeline[transducer_idx].analyse(surface_form)
            if analyses:
                return self.pipeline[transducer_idx], analyses
            transducer_idx += 1

    def __repr__(self):
        return f'Pipeline({"|".join([fst for fst in self.pipeline])})'


class PostPipeline(PostAnalysis):
    """
    A class that provides a static method for applying some heuristics to a sequence
    of morphological analyses.
    """

    @staticmethod
    def apply(morphemes: List[str], surface_form: str, token_pos: int) -> List[str]:
        """
        Applies post-processing rules to the given morphemes list.

        :param morphemes: A list of morphemes representing the morphological analysis of a token.
        :param surface_form: The original surface form of the token.
        :param token_pos: The position of the token in the sequence.
        :return: The modified list of morphemes after applying the post-processing rules.
        """
        if len(morphemes) < 2:
            return morphemes
        if token_pos > 1 and surface_form[0].isupper() and morphemes[1] == '^N':
            morphemes[1] = '^PN'
        return morphemes
