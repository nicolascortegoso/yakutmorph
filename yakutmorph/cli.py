"""
The `yakutmorph` command.

    yakutmorph analyze text.txt                    # CoNLL-U (default)
    yakutmorph analyze text.txt --format json      # one JSON object per sentence
    yakutmorph analyze text.txt --format gloss     # interlinear glosses
    yakutmorph analyze text.txt --format tsv       # word, analysis, lemma, confidence
    echo "Мин кинигэни аахпытым." | yakutmorph analyze
    yakutmorph paradigm көр --category V           # inflection tables
    yakutmorph examples --root дьиэ --tag POSS.3SG.ACC -n 5
    yakutmorph generate дьиэ+N+POSS.1SG.DAT        # word forms
"""
import argparse
import json
import sys
from typing import Iterable, List, Optional

from . import __version__


def _read(paths: List[str]) -> str:
    if not paths or paths == ['-']:
        return sys.stdin.read()
    texts = []
    for path in paths:
        with open(path, encoding='utf-8') as f:
            texts.append(f.read())
    return '\n\n'.join(texts)


def _parses(morphology, text: str, lines: bool) -> Iterable:
    """One Parse per sentence; with `lines`, one per non-empty input line."""
    if lines:
        return [morphology.parse(line.strip()) for line in text.splitlines() if line.strip()]
    return morphology.parse_text(text)


def _analyze(args) -> None:
    from .main import YakutMorph
    from .mappers import conllu_document
    from .glossing import interlinear
    from .records import sentence_record

    parses = list(_parses(YakutMorph(), _read(args.files), args.lines))
    out = sys.stdout
    if args.format == 'conllu':
        out.write(conllu_document(parses))
    elif args.format == 'json':
        for parse in parses:
            out.write(json.dumps(sentence_record(parse), ensure_ascii=False) + '\n')
    elif args.format == 'gloss':
        out.write('\n\n'.join(interlinear(parse) for parse in parses) + '\n')
    else:  # tsv
        out.write('sentence\tposition\ttext\tanalysis\tlemma\tupos\tconfidence\n')
        for i, parse in enumerate(parses, start=1):
            for token in sentence_record(parse, alternatives=False)['tokens']:
                confidence = token.get('confidence')
                out.write('\t'.join(str(x) for x in (
                    i, token['position'], token['text'], token.get('analysis', ''), token.get('lemma', ''),
                    token.get('upos', ''), '' if confidence is None else confidence,
                )) + '\n')


def _paradigm(args) -> None:
    from .paradigms import paradigm

    try:
        result = paradigm(args.root, args.category)
    except ValueError as error:
        sys.exit(f'yakutmorph: {error}')
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=1))
        return
    for table in result['tables']:
        cells = [[row['label']] + ['/'.join(row['cells'][c]) or '—' for c in table['columns']]
                 for row in table['rows']]
        header = [''] + table['columns']
        widths = [max(len(r[i]) for r in cells + [header]) for i in range(len(header))]
        print(f"{result['root']} ({result['category']}): {table['name']}")
        for row in [header] + cells:
            print('  '.join(cell.ljust(w) for cell, w in zip(row, widths)).rstrip())
        print()


def _examples(args) -> None:
    from .corpus import Corpus

    try:
        result = Corpus().find(word=args.word, root=args.root, tag=args.tag,
                               limit=args.number, offset=args.offset)
    except ValueError as error:
        sys.exit(f'yakutmorph: {error}')
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=1))
        return
    shown = len(result['examples'])
    print(f"{result['total']} matching sentences" + (f', showing {shown}' if shown < result['total'] else ''))
    for example in result['examples']:
        print()
        flag = '  [ungrammatical]' if example.get('ungrammatical') else ''
        print(f"{example['sentence']}{flag}")
        for field in ('translation_ru', 'translation_en'):
            if field in example:
                print(f"  '{example[field]}'")
        match = example['match']
        print(f"  {match['text']} = {match['analysis']}")
        source = ', '.join(str(example[f]) for f in ('authors', 'source') if example.get(f))
        page = f", p. {example['page']}" if example.get('page') not in (None, '') else ''
        print(f'  ({source}{page})')


def _generate(args) -> None:
    from .transducers import YakutTransducer

    transducer = YakutTransducer()
    for analysis in args.analyses:
        print(analysis, '\t', ' / '.join(transducer.generate(analysis)) or '—', sep='')


def main(argv: Optional[List[str]] = None) -> None:
    """Entry point of the `yakutmorph` command."""
    for stream in (sys.stdout, sys.stderr):  # Cyrillic output on any platform
        if hasattr(stream, 'reconfigure'):
            stream.reconfigure(encoding='utf-8')
    if hasattr(sys.stdin, 'reconfigure'):
        sys.stdin.reconfigure(encoding='utf-8')

    parser = argparse.ArgumentParser(prog='yakutmorph', description='Morphological analysis of Yakut (Sakha).')
    parser.add_argument('--version', action='version', version=f'yakutmorph {__version__}')
    commands = parser.add_subparsers(dest='command', required=True)

    analyze = commands.add_parser('analyze', help='analyse text from files or standard input')
    analyze.add_argument('files', nargs='*', help='text files (UTF-8); standard input if none or "-"')
    analyze.add_argument('-f', '--format', choices=['conllu', 'json', 'gloss', 'tsv'], default='conllu',
                         help='output format (default: conllu)')
    analyze.add_argument('--lines', action='store_true',
                         help='one sentence per line, instead of splitting the text into sentences')
    analyze.set_defaults(handler=_analyze)

    table = commands.add_parser('paradigm', help='inflection tables of a noun or verb')
    table.add_argument('root', help='the root, e.g. дьиэ or көр')
    table.add_argument('-c', '--category', choices=['N', 'V'], default='N', help='N (noun, default) or V (verb)')
    table.add_argument('--json', action='store_true', help='print JSON')
    table.set_defaults(handler=_paradigm)

    examples = commands.add_parser('examples', help='example sentences from the annotated corpus')
    examples.add_argument('-w', '--word', help='a word form')
    examples.add_argument('-r', '--root', help='a root')
    examples.add_argument('-t', '--tag', help='a tag, e.g. POSS.3SG.ACC')
    examples.add_argument('-n', '--number', type=int, default=3, help='how many examples (default: 3)')
    examples.add_argument('--offset', type=int, default=0, help='skip this many matching sentences')
    examples.add_argument('--json', action='store_true', help='print JSON')
    examples.set_defaults(handler=_examples)

    generate = commands.add_parser('generate', help='word forms for analyses')
    generate.add_argument('analyses', nargs='+', help='analyses, e.g. дьиэ+N+POSS.1SG.DAT')
    generate.set_defaults(handler=_generate)

    args = parser.parse_args(argv)
    args.handler(args)


if __name__ == '__main__':
    main()
