"""
An MCP (Model Context Protocol) server that lets LLM applications use
yakutmorph: morphological analysis, disambiguation, CoNLL-U output, tag
explanations and word-form generation for Yakut (Sakha).

Install with the optional dependency and start it over stdio::

    pip install "yakutmorph[mcp]"
    yakutmorph-mcp

For example, to add it to Claude Code::

    claude mcp add yakutmorph -- yakutmorph-mcp

Or serve it over HTTP (streamable HTTP, at /mcp), e.g. on a public host::

    yakutmorph-mcp --http --host 0.0.0.0 --port 8000

Run ``yakutmorph-mcp --help`` for the options (text length limit, switching
off find_examples); the port can also be given in the PORT environment
variable, as most hosting services do.
"""
import argparse
import os
from functools import lru_cache
from typing import Dict, List, Optional

# typing_extensions (a dependency of the MCP SDK) rather than typing: pydantic
# needs it for TypedDict on Python < 3.12.
from typing_extensions import NotRequired, TypedDict

try:
    from mcp.server.mcpserver import MCPServer
    from mcp.server.mcpserver.exceptions import ToolError
    from mcp_types import ToolAnnotations
except ImportError as error:  # pragma: no cover - depends on the environment
    raise ImportError(
        'The MCP server needs the optional dependency: pip install "yakutmorph[mcp]"'
    ) from error

from . import __version__
from .corpus import Corpus
from .main import YakutMorph
from .glossing import gloss_words, interlinear
from .mappers import conllu_document
from .paradigms import paradigm
from .records import sentence_record
from .transducers import YakutTransducer

# Text an MCP client gives the model before it uses the tools.
INSTRUCTIONS = """\
Morphological analysis of Yakut (Sakha), a Turkic language written in Cyrillic.

Analyses are written as root+TAG+TAG..., e.g. "дьиэ+N+POSS.3SG.ACC" for
"дьиэтин" ('his/her house', accusative): the root, its category, then the
affixes in order. Call explain_tags to get the meaning of any tag.

Each word also reports which transducer analysed it, a measure of how much to
trust the result:
- "voc": the word's root is in the lexicon (most reliable);
- "syl": the root is unknown but has the shape of a Yakut root (a guess);
- "aff": only the affixes were recognised, e.g. in loanwords (a guess);
- "fail": the word could not be analysed (tag +UNK).

When a word has several possible analyses, a neural model chooses one from
the sentence context ("analysis"); the other candidates are listed under
"alternatives", each with the model's probability. "confidence" is the
probability of the chosen analysis (1.0 when there was only one). On held-out
data the choice is right for 99% of words with confidence >= 0.99, 97% at
0.90-0.99, 79% at 0.70-0.90 and only about half below 0.70: treat low-confidence
choices as uncertain and mention the alternatives. Proper names are tagged +PN by a heuristic (capitalised word not
at the start of a sentence, or a known name).

find_examples searches yakutmorph_dataset, a corpus of about 18,000 manually
annotated Yakut sentences (mostly examples from grammars and literary texts),
by word form, root and/or tag. Use it to show real usage, or to check an
analysis against manually annotated examples. Examples flagged "ungrammatical"
are deliberately wrong forms quoted in the source; never present them as
correct Yakut.
"""

TRANSDUCER_LABELS = {
    'voc': 'root found in the lexicon',
    'syl': 'unknown root guessed from Yakut syllable structure',
    'aff': 'unknown root, only the affixes were recognised',
    'fail': 'not analysed',
}

server = MCPServer(
    name='yakutmorph',
    title='Yakut morphology',
    version=__version__,
    instructions=INSTRUCTIONS,
)

# Longest text (in characters) the text tools accept; None = no limit.
# Unlimited over stdio (a local user), limited over HTTP (see main()).
MAX_TEXT_CHARS: Optional[int] = None


def _check_length(text: str) -> None:
    if MAX_TEXT_CHARS is not None and len(text) > MAX_TEXT_CHARS:
        raise ToolError(f'The text is {len(text)} characters long; this server accepts at most '
                         f'{MAX_TEXT_CHARS}. Send it in smaller parts.')


READ_ONLY = ToolAnnotations(read_only_hint=True, idempotent_hint=True, open_world_hint=False)


@lru_cache(maxsize=1)
def _morphology() -> YakutMorph:
    """The analyser is loaded once, on first use (about a second)."""
    return YakutMorph()


@lru_cache(maxsize=1)
def _corpus() -> Corpus:
    """The annotated corpus, loaded once, on first use."""
    return Corpus()


@lru_cache(maxsize=1)
def _generator() -> YakutTransducer:
    """The lexicon-based transducer ('voc'), used to generate word forms."""
    return YakutTransducer()


class Alternative(TypedDict):
    analysis: str
    probability: NotRequired[float]


class TokenResult(TypedDict):
    position: int
    text: str
    type: str
    analysis: NotRequired[str]
    lemma: NotRequired[str]
    upos: NotRequired[str]
    features: NotRequired[str]
    transducer: NotRequired[str]
    ambiguous: NotRequired[bool]
    confidence: NotRequired[float]
    alternatives: NotRequired[List[Alternative]]
    construction: NotRequired[str]


class SentenceResult(TypedDict):
    text: str
    tokens: List[TokenResult]


class TextResult(TypedDict):
    text: str
    sentences: List[SentenceResult]


class WordResult(TypedDict):
    word: str
    transducer: str
    transducer_meaning: str
    analyses: List[str]


class TagInfo(TypedDict):
    ref: NotRequired[str]
    UPOS: NotRequired[str]
    ud: NotRequired[Dict[str, str]]


class TagsResult(TypedDict):
    tags: Dict[str, Optional[TagInfo]]


class TagList(TypedDict):
    roots: NotRequired[List[str]]
    derivational: NotRequired[List[str]]
    inflectional: NotRequired[List[str]]


class ExampleWord(TypedDict):
    text: str
    analysis: Optional[str]


class Example(TypedDict):
    id: str
    sentence: str
    translation_ru: NotRequired[str]
    translation_en: NotRequired[str]
    source: NotRequired[str]
    page: NotRequired[str]
    authors: NotRequired[str]
    ungrammatical: NotRequired[bool]
    match: ExampleWord
    words: List[ExampleWord]


class ExamplesResult(TypedDict):
    total: int
    examples: List[Example]


class ParadigmRow(TypedDict):
    label: str
    cells: Dict[str, List[str]]
    analyses: Dict[str, str]


class ParadigmTable(TypedDict):
    name: str
    columns: List[str]
    rows: List[ParadigmRow]


class ParadigmResult(TypedDict):
    root: str
    category: str
    tables: List[ParadigmTable]


class GlossedWord(TypedDict):
    text: str
    segmented: str
    gloss: str


class GlossedSentence(TypedDict):
    text: str
    interlinear: str
    words: List[GlossedWord]


class GlossResult(TypedDict):
    sentences: List[GlossedSentence]


class GenerationResult(TypedDict):
    analysis: str
    forms: List[str]


@server.tool(annotations=READ_ONLY)
def analyze_text(text: str, include_alternatives: bool = True) -> TextResult:
    """Analyse Yakut text: split it into sentences and tokens and give each
    word its morphological analysis in context (root, category, affixes),
    lemma, Universal Dependencies part of speech and features, the model's
    confidence and, for ambiguous words, the other possible analyses.

    Args:
        text: Yakut text in Cyrillic, e.g. "Мин кинигэни аахпытым."
        include_alternatives: Also list the analyses the model did not choose.
    """
    _check_length(text)
    return {'text': text, 'sentences': [
        sentence_record(parse, include_alternatives) for parse in _morphology().parse_text(text)
    ]}


@server.tool(annotations=READ_ONLY)
def analyze_word(word: str) -> WordResult:
    """List every morphological analysis of a single Yakut word form, out of
    context (no disambiguation). Use analyze_text instead to get the most
    likely analysis in a sentence.

    Args:
        word: One Yakut word form, e.g. "дьиэтин".
    """
    fst, analyses = _morphology().transducer.analyse(word)
    return {
        'word': word,
        'transducer': fst.label,
        'transducer_meaning': TRANSDUCER_LABELS.get(fst.label, ''),
        'analyses': [''.join(fst.get_morphemes(a)) for a in analyses],
    }


@server.tool(annotations=READ_ONLY)
def to_conllu(text: str) -> str:
    """Analyse Yakut text and return it in CoNLL-U format (the format of
    Universal Dependencies treebanks): one block per sentence, one line per
    token with form, lemma, UPOS, XPOS and features; the full analysis is in
    the MISC column. Dependency columns are left empty ("_").

    Args:
        text: Yakut text in Cyrillic; it may contain several sentences.
    """
    _check_length(text)
    return conllu_document(_morphology().parse_text(text))


@server.tool(annotations=READ_ONLY)
def explain_tags(tags: List[str]) -> TagsResult:
    """Explain morphological tags used in the analyses: what each marks,
    with its affix forms and a reference to the grammar where available,
    and its Universal Dependencies equivalent.

    Args:
        tags: Tags with or without the leading "+", e.g. ["POSS.3SG.ACC", "+PN"].
    """
    reference = _generator().reference
    explained = {}
    for tag in tags:
        key = tag if tag[:1] in '+^' else f'+{tag}'
        entry = reference.get_tag(key)
        if not entry:
            explained[key] = None
            continue
        info: TagInfo = {field: entry[field] for field in ('ref', 'UPOS') if field in entry}
        if 'ud' in entry:
            info['ud'] = {feature: str(value) for feature, value in entry['ud'].items()}
        explained[key] = info
    return {'tags': explained}


@server.tool(annotations=READ_ONLY)
def list_tags(section: Optional[str] = None) -> TagList:
    """List the tags the analyser uses, grouped into 'roots' (word
    categories), 'derivational' and 'inflectional' affixes. Possessive +
    case portmanteaus such as POSS.3SG.ACC are not listed separately; they
    combine a POSS tag and a case tag.

    Args:
        section: Only list one group: "roots", "derivational" or "inflectional".
    """
    groups: TagList = {}
    for tag, group in _generator().reference.sections.items():
        if section is None or group == section:
            groups.setdefault(group, []).append(tag)
    return groups


@server.tool(annotations=READ_ONLY)
def generate_word_form(analysis: str) -> GenerationResult:
    """Generate the Yakut word form(s) for an analysis, the reverse of
    analyze_word. Useful to inflect a word correctly, e.g. "дьиэ+N+POSS.1SG.DAT"
    gives "дьиэбэр" ('to my house'). Only roots in the lexicon can be
    generated; the tag sequence must be one the analyser itself produces
    (see list_tags and the analyses returned by the other tools).

    Args:
        analysis: root+TAG+TAG..., e.g. "кинигэ+N+PL+ACC".
    """
    return {'analysis': analysis, 'forms': _generator().generate(analysis)}


@server.tool(annotations=READ_ONLY)
def gloss_text(text: str) -> GlossResult:
    """Gloss Yakut text interlinearly, in the style of the Leipzig Glossing
    Rules: each word segmented into morphemes with '-', and a gloss line
    with the analyser's tags (the root stands for itself; there are no
    translations). Affixes whose boundary is not visible in the written form
    are glossed together, joined with '.'. The segmentation is approximate.
    "interlinear" gives each sentence as three aligned lines: the sentence,
    the segmentation and the glosses.

    Args:
        text: Yakut text in Cyrillic; it may contain several sentences.
    """
    _check_length(text)
    return {'sentences': [
        {'text': parse.text, 'interlinear': interlinear(parse), 'words': gloss_words(parse)}
        for parse in _morphology().parse_text(text)
    ]}


@server.tool(annotations=READ_ONLY)
def inflection_table(root: str, category: str = 'N') -> ParadigmResult:
    """Generate the inflection tables of a Yakut noun or verb. Nouns: the
    cases (NOM, ACC, DAT, ABL, INST, COMIT, COMP, PRTV) in singular and
    plural, and with each possessor (1SG...3PL), for one and for several
    possessed. Verbs: the finite forms in each tense (Pres, NearPast,
    PastResult, Fut) and person, affirmative and negative. Each cell lists
    the generated forms (some have variants) and the analysis it comes from;
    an empty cell means the analyser generates no form for it. Only roots in
    the lexicon can be inflected.

    Args:
        root: The root, e.g. "дьиэ" (house) or "көр" (see).
        category: "N" for a noun or "V" for a verb.
    """
    return paradigm(root, category, transducer=_generator())


@server.tool(annotations=READ_ONLY)
def find_examples(word: Optional[str] = None, root: Optional[str] = None, tag: Optional[str] = None,
                  limit: int = 3, offset: int = 0) -> ExamplesResult:
    """Find manually annotated example sentences in the yakutmorph_dataset
    corpus that contain a word matching every given criterion (give at least
    one). Each example has the sentence, its Russian and/or English
    translation, source, page, authors or translator, and the annotated
    analysis of every word. Shortest sentences come first.

    Args:
        word: An exact word form, case-insensitive, e.g. "дьиэтин".
        root: A root, e.g. "дьиэ" (any form of it).
        tag: A tag, with or without "+", e.g. "POSS.3SG.ACC" or "REFL/PASS".
        limit: How many examples to return: 3 if not given, at most 20; fewer if fewer match.
        offset: How many matching examples to skip, to page through results.
    """
    result = _corpus().find(word=word, root=root, tag=tag, limit=max(1, min(limit, 20)), offset=max(0, offset))
    for example in result['examples']:
        if 'page' in example:
            example['page'] = str(example['page'])
    return result


@server.custom_route('/health', methods=['GET'])
async def health(request):
    """A plain status page (HTTP mode only), for hosting services' health checks."""
    from starlette.responses import JSONResponse
    return JSONResponse({'status': 'ok', 'version': __version__})


def _flag(name: str) -> bool:
    return os.environ.get(name, '').strip().lower() in ('1', 'true', 'yes')


def main(argv: Optional[List[str]] = None) -> None:
    """Entry point of the `yakutmorph-mcp` command: stdio by default, or HTTP."""
    global MAX_TEXT_CHARS
    parser = argparse.ArgumentParser(
        prog='yakutmorph-mcp',
        description='MCP server for Yakut (Sakha) morphology. Without --http it talks over '
                    'stdio, as Claude Desktop and Claude Code expect.')
    parser.add_argument('--http', action='store_true',
                        help='serve over streamable HTTP at /mcp instead of stdio')
    parser.add_argument('--host', default=os.environ.get('HOST', '127.0.0.1'),
                        help='address to listen on in HTTP mode (default 127.0.0.1, this computer only; '
                             '0.0.0.0 to accept outside connections, e.g. in a container)')
    parser.add_argument('--port', type=int, default=int(os.environ.get('PORT', 8000)),
                        help='port in HTTP mode (default: $PORT, else 8000)')
    parser.add_argument('--max-text-chars', type=int,
                        default=int(os.environ.get('YAKUTMORPH_MCP_MAX_TEXT_CHARS', 5000)),
                        help='in HTTP mode, the longest text accepted by analyze_text, to_conllu '
                             'and gloss_text (default 5000; 0 = no limit)')
    parser.add_argument('--no-examples', action='store_true', default=_flag('YAKUTMORPH_MCP_NO_EXAMPLES'),
                        help='do not offer find_examples (the corpus sentences)')
    args = parser.parse_args(argv)

    if args.no_examples:
        server.remove_tool('find_examples')
    if not args.http:
        server.run()
        return
    MAX_TEXT_CHARS = args.max_text_chars or None
    _morphology()  # load the analyser now, not on the first request
    # Stateless, with plain JSON responses: each request stands alone, so the
    # server can be restarted or run in several copies behind a load balancer.
    server.run(transport='streamable-http', host=args.host, port=args.port,
               stateless_http=True, json_response=True)


if __name__ == '__main__':
    main()
