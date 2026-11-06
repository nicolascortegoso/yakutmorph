"""
Search the manually annotated sentences of yakutmorph_dataset
(https://github.com/nicolascortegoso/yakutmorph_dataset) for examples of a
word form, a root or a tag.

The package ships a compact snapshot of the corpus (data/corpus.jsonl.gz,
built with scripts/build_corpus_snapshot.py). To search a local checkout of
the corpus instead, set the environment variable YAKUTMORPH_CORPUS to its
directory.

>>> from yakutmorph.corpus import Corpus
>>> corpus = Corpus()
>>> result = corpus.find(root='дьиэ', tag='POSS.3SG.ACC', limit=1)
"""
import gzip
import json
import os
import re
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional

from .utils import get_file_path

SNAPSHOT = 'data/corpus.jsonl.gz'
SNAPSHOT_INFO = 'data/corpus_info.json'
ENVIRONMENT_VARIABLE = 'YAKUTMORPH_CORPUS'

# Sentence-level fields kept from the corpus files, under their own names.
KEPT_FIELDS = ('sah', 'ru', 'en', 'source', 'page', 'authors')
# Corpus flags for examples that are deliberately wrong (e.g. starred forms
# quoted in a grammar); reported as "ungrammatical".
WRONG_FLAGS = ('incorrect', 'ungrammatical')

# One known glitch in the corpus: a root glued to its tag without '+'.
ROOT_FIXUPS = {'баһырҕасN': 'баһырҕас+N'}


def analysis_string(parse: Dict) -> Optional[str]:
    """
    The analysis of one annotated word as 'root+TAG+TAG...', joining the
    corpus's 'root' and 'affixes' fields and normalizing the older '^'
    separator to '+'; None for tokens without an analysis (punctuation).
    """
    root = parse.get('root')
    if not root:
        return None
    root = ROOT_FIXUPS.get(root, root)
    affixes = parse.get('affixes') or ''
    if isinstance(affixes, list):
        affixes = ''.join(affixes)
    return '+'.join(part for part in re.split(r'[+^]', root + affixes) if part)


def records_from_dataset(directory) -> Iterator[Dict]:
    """
    Reads every annotated sentence of a yakutmorph_dataset checkout
    (<directory>/*/processed/*.json) as a compact record: an id, the
    sentence, its translations, source, page and authors/translators,
    an "ungrammatical" flag when the corpus marks the example as wrong, and
    the words with their analyses.
    """
    for path in sorted(Path(directory).glob('*/processed/*.json')):
        for entry in json.loads(path.read_text(encoding='utf-8')):
            record = {'id': f"{path.parts[-3]}/{path.name}#{entry.get('id')}"}
            for field in KEPT_FIELDS:
                if entry.get(field) not in (None, ''):
                    record[field] = entry[field]
            if any(entry.get(flag) for flag in WRONG_FLAGS):
                record['ungrammatical'] = True
            record['words'] = [
                [parse['text'], analysis_string(parse)]
                for parse in sorted(entry.get('parses', []), key=lambda p: p['pos'])
            ]
            yield record


def write_snapshot(records: Iterable[Dict], path) -> int:
    """Writes the records as gzipped JSON lines; returns how many."""
    n = 0
    with gzip.open(path, 'wt', encoding='utf-8', compresslevel=9) as f:
        for record in records:
            f.write(json.dumps(record, ensure_ascii=False) + '\n')
            n += 1
    return n


def _read_snapshot(path) -> Iterator[Dict]:
    with gzip.open(path, 'rt', encoding='utf-8') as f:
        for line in f:
            yield json.loads(line)


def _tags(analysis: Optional[str]) -> List[str]:
    return analysis.split('+')[1:] if analysis else []


class Corpus:
    """
    The annotated corpus, loaded once into memory (about 19,000 sentences).

    :param directory: A yakutmorph_dataset checkout to read instead of the
        bundled snapshot. Defaults to the YAKUTMORPH_CORPUS environment
        variable, if set.
    """

    def __init__(self, directory: Optional[str] = None):
        directory = directory or os.environ.get(ENVIRONMENT_VARIABLE)
        if directory:
            self.records = list(records_from_dataset(directory))
            self.origin = {'directory': str(directory)}
        else:
            self.records = list(_read_snapshot(get_file_path(SNAPSHOT)))
            with open(get_file_path(SNAPSHOT_INFO), encoding='utf-8') as f:
                self.origin = json.load(f)

    def find(self, word: Optional[str] = None, root: Optional[str] = None,
             tag: Optional[str] = None, limit: int = 5, offset: int = 0) -> Dict:
        """
        Finds sentences containing a word that matches every given
        criterion, shortest sentences first.

        :param word: A word form, matched case-insensitively (e.g. 'дьиэтин').
        :param root: A root (e.g. 'дьиэ'), matched against the start of the analysis.
        :param tag: A tag with or without '+' (e.g. 'POSS.3SG.ACC').
        :param limit: How many sentences to return.
        :param offset: How many matching sentences to skip (for paging).
        :return: {'total': number of matching sentences, 'examples': [...]},
            each example with the matching word, its analysis and the whole
            annotated sentence.
        """
        if not (word or root or tag):
            raise ValueError('Give at least one of word, root or tag.')
        word = word.lower() if word else None
        root = root.lower() if root else None
        tag = tag.lstrip('+^') if tag else None

        def matches(text: str, analysis: Optional[str]) -> bool:
            if word and text.lower() != word:
                return False
            if root and (not analysis or analysis.split('+')[0] != root):
                return False
            if tag and tag not in _tags(analysis):
                return False
            return True

        found = []
        for record in self.records:
            hit = next((w for w in record['words'] if matches(*w)), None)
            if hit:
                found.append((record, hit))
        found.sort(key=lambda item: len(item[0]['sah'] or ''))

        examples = []
        for record, (text, analysis) in found[offset:offset + limit]:
            example = {k: v for k, v in record.items() if k not in ('words', 'sah', 'ru', 'en')}
            example.update({
                'sentence': record.get('sah', ''),
                'match': {'text': text, 'analysis': analysis},
                'words': [{'text': t, 'analysis': a} for t, a in record['words']],
            })
            for field, name in (('ru', 'translation_ru'), ('en', 'translation_en')):
                if field in record:
                    example[name] = record[field]
            examples.append(example)
        return {'total': len(found), 'examples': examples}
