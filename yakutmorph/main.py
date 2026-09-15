from typing import List, Tuple

from .constructions import detect as detect_multiword_constructions, load_patterns
from .disambiguation import YakutReranker
from .intensifiers import classify, construction_type
from .interfaces import Tokenizer, Transducer, DisambiguationModel, PostAnalysis
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
    disambiguation_model : The model used to disambiguate morphological analyses. Default is YakutReranker.
    reference: A reference to map the implemented morphology.
    construction_patterns : The multi-word construction lexicon (see `yakutmorph.constructions`),
        as a list of (label, pattern) tuples. Default is loaded from 'data/constructions.yaml'.
    """
    def __init__(self,
                 tokenizer: Tokenizer = None,
                 transducer: Transducer = None,
                 disambiguation_model: DisambiguationModel = None,
                 reference: YakutMorphReference = None,
                 construction_patterns: List[Tuple[str, List[str]]] = None
                 ):

        self.tokenizer = tokenizer if tokenizer else YakutTokenizer()
        self.transducer = transducer if transducer else YakutTransducerPipeline(morph_reference=reference)
        self.disambiguation_model = disambiguation_model if disambiguation_model else YakutReranker()
        self.construction_patterns = construction_patterns if construction_patterns is not None else load_patterns(
            'data/constructions.yaml', inside_package=True
        )

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

    def __detect_constructions(self, tokens: List[Token]) -> List[Token]:
        """
        Scans the token sequence for hyphen-joined constructions (reduplication,
        intensifying augmentation, or compounding; see `yakutmorph.intensifiers`)
        and flags the tokens on either side of the hyphen with `compound`
        set to the recognised construction's label.

        The transducer has no notion of these constructions, so an intensifying
        augment (e.g. "хап" in "хап-хара") is otherwise left with whatever
        unrelated free-standing readings it happens to also have (e.g. as an
        imitative or a verb root). When one is recognised, its analyses are
        replaced with a single synthetic reading instead.

        :param tokens: The list of Token objects, already morphologically analysed.
        :return: The same list of Tokens, with `compound` set on the tokens
            flanking each recognised hyphenated construction.
        """
        hyphen = YakutTokenizer.token_type.HYPHEN
        for left, separator, right in zip(tokens, tokens[1:], tokens[2:]):
            if not (left.has_morph and right.has_morph and separator.type == hyphen):
                continue
            construction = classify(left.surface, right.surface)
            left.compound = right.compound = construction
            if construction == construction_type.INTENSIFIER:
                reference = left.analyses.fst.reference
                left.analyses.output = [
                    Analysis(morphemes=[left.surface.lower(), '+INTENS'], reference=reference)
                ]
                left.analyses.set_mla(0)
        return tokens

    def __disambiguate(self, tokens: List[Token]) -> List[int]:
        """
        Disambiguates the morphological analyses using the disambiguation model.

        :param tokens: The list of Token objects for the sentence.
        :return: One index per ambiguous token, in order, selecting that
            token's most likely candidate analysis.
        """
        return self.disambiguation_model.disambiguate(tokens)

    def parse(self, input_text: str, post_analysis: PostAnalysis = PostPipeline):
        """
        Parses the input text, performing tokenization, morphological analysis,
        and disambiguation if necessary.

        :param input_text: The text to parse.
        :param post_analysis: The post-analysis process to apply. Defaults to PostPipeline.
        :return: A Parse object representing the analyzed input text.
        """
        tokens = self.__tokenize(input_text)
        tokens = self.__analyse(tokens, post_analysis)
        tokens = self.__detect_constructions(tokens)
        parse = Parse(input_text, tokens)

        ambiguous_tokens = [token for token in parse.tokens if token.is_ambiguous()]
        if ambiguous_tokens:
            indexes = self.__disambiguate(parse.tokens)
            for token, idx in zip(ambiguous_tokens, indexes):
                token.analyses.set_mla(idx)
        for token in parse.tokens:
            if token.has_morph and token.analyses.idx_mla is None:
                token.analyses.set_mla(0)

        # Multi-word constructions (see yakutmorph.constructions) are
        # matched against each token's disambiguated analysis, so this
        # only runs once every token has one.
        detect_multiword_constructions(parse.tokens, self.construction_patterns)

        return parse
