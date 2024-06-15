from typing import List

from .disambiguation import YakutModel
from .interfaces import Tokenizer, Transducer, DisambiguationModel, PostAnalysis, Mapper
from .mappers import YakutMapper
from .tokenizers import YakutTokenizer
from .transducers import YakutTransducerPipeline, PostPipeline, YakutMorphReference
from .wrappers import Parse, Token, Analyses, Analysis


class YakutMorph:
    """
    A class used to perform morphological analysis on Yakut language texts.

    Attributes
    ----------
    tokenizer : The tokenizer to split input text into tokens. Default is YakutTokenizer.
    transducer : The transducer to perform morphological analysis. Default is YakutTransducerPipeline.
    disambiguation_model : The model used to disambiguate morphological analyses. Default is YakutModel.
    mapper : The mapper used for parsing DAGs. Default is YakutMapper with 'data/mappings.yaml'.
    reference: A reference to map the implemented morphology.
    """
    def __init__(self,
                 tokenizer: Tokenizer = None,
                 transducer: Transducer = None,
                 disambiguation_model: DisambiguationModel = None,
                 mapper: Mapper = None,
                 reference: YakutMorphReference = None
                 ):

        self.tokenizer = tokenizer if tokenizer else YakutTokenizer()
        self.transducer = transducer if transducer else YakutTransducerPipeline(morph_reference=reference)
        self.disambiguation_model = disambiguation_model if disambiguation_model else YakutModel()
        self.mapper = mapper if mapper else YakutMapper('data/mappings.yaml', inside_package=True)

    def __tokenize(self, input_text: str) -> List[Token]:
        """
        Tokenizes the input text into a list of Token objects.

        :param input_text: The text to be tokenized.
        :return: A list of Token objects.
        """
        return [
            Token(i + 1, token[0], token[1], True if token[1] in self.tokenizer.has_morphology() else False)
            for i, token in enumerate(self.tokenizer.tokenize(input_text))
        ]

    def __analyse(self, tokens: List[Token], post_analysis: PostAnalysis):
        """
        Analyzes the morphology of the given tokens.

        :param tokens: The list of Token objects to analyze.
        :param post_analysis: A PostAnalysis object to post-process the analyses.
        :return: The list of Tokens with their morphology analyzed.
        """
        for token in tokens:
            if token.has_morph:
                fst, analyses = self.transducer.analyse(token.surface)
                token.analyses = Analyses(fst=fst, output=[
                    Analysis(
                        morphemes=
                        post_analysis.apply(
                            fst.get_morphemes(analysis), token.surface, token.pos
                        ),
                        reference=fst.reference
                    )
                    for analysis in analyses
                    ]
                )
        return tokens

    def __disambiguate(self, dag: List[List[str]]) -> List[int]:
        """
        Disambiguates the morphological analyses using the disambiguation model.

        :param dag: The directed acyclic graph representing possible analyses.
        :return: The list of indexes representing the chosen analyses.
        """
        return self.disambiguation_model.disambiguate(dag)

    def parse(self, input_text: str, post_analysis: PostAnalysis = PostPipeline):
        """
        Parses the input text, performing tokenization, morphological analysis,
        and disambiguation if necessary.

        :param input_text: The text to parse.
        :param post_analysis: The post-analysis process to apply. Defaults to PostPipeline.
        :return: A Parse object representing the analyzed input text.
        """
        tokens = self.__tokenize(input_text)
        parse = Parse(input_text, self.__analyse(tokens, post_analysis))

        if parse.is_ambiguous():
            dag = parse.get_dag(self.mapper)
            indexes = self.__disambiguate(dag)
            [token.analyses.set_mla(idx) for token, idx in zip(parse.tokens, indexes) if token.has_morph]
        else:
            [token.analyses.set_mla(0) for token in parse.tokens if token.has_morph]

        return parse
