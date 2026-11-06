import contextlib
import io
import json
import os
import subprocess
import sys
import tempfile
import unittest

from yakutmorph.cli import main


def run(*argv):
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        main(list(argv))
    return out.getvalue()


class TestCommandLine(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        handle, cls.path = tempfile.mkstemp(suffix='.txt')
        with os.fdopen(handle, 'w', encoding='utf-8') as f:
            f.write('Мин оскуолаҕа бардым. Оскуолабыттан кэллим.\n')

    @classmethod
    def tearDownClass(cls):
        os.remove(cls.path)

    def test_analyze_conllu(self):
        output = run('analyze', self.path)
        self.assertTrue(output.startswith('# sent_id = 1\n# text = Мин оскуолаҕа бардым.\n'))
        self.assertIn('# sent_id = 2\n', output)

    def test_analyze_json(self):
        sentences = [json.loads(line) for line in run('analyze', self.path, '-f', 'json').splitlines()]
        self.assertEqual(len(sentences), 2)
        self.assertEqual(sentences[0]['tokens'][1]['analysis'], 'оскуола+N+DAT')

    def test_analyze_gloss_and_tsv(self):
        self.assertIn('оскуола-ҕа', run('analyze', self.path, '-f', 'gloss'))
        rows = run('analyze', self.path, '-f', 'tsv').splitlines()
        self.assertEqual(rows[0].split('\t')[:4], ['sentence', 'position', 'text', 'analysis'])
        self.assertEqual(rows[2].split('\t')[2:4], ['оскуолаҕа', 'оскуола+N+DAT'])

    def test_analyze_one_sentence_per_line(self):
        output = run('analyze', self.path, '--lines', '-f', 'json')
        self.assertEqual(len(output.splitlines()), 1)

    def test_paradigm(self):
        self.assertIn('көрдүм', run('paradigm', 'көр', '-c', 'V'))
        self.assertEqual(json.loads(run('paradigm', 'дьиэ', '--json'))['category'], 'N')

    def test_paradigm_unknown_root(self):
        with self.assertRaises(SystemExit) as raised:
            run('paradigm', 'дьиэ', '-c', 'V')
        self.assertIn('not in the lexicon', str(raised.exception.code))

    def test_examples(self):
        result = json.loads(run('examples', '--root', 'дьиэ', '--tag', 'POSS.3SG.ACC', '-n', '2', '--json'))
        self.assertEqual(len(result['examples']), 2)
        self.assertIn('matching sentences', run('examples', '--word', 'дьиэтин'))

    def test_generate(self):
        self.assertEqual(run('generate', 'дьиэ+N+POSS.1SG.DAT').strip(), 'дьиэ+N+POSS.1SG.DAT\tдьиэбэр')

    def test_standard_input(self):
        result = subprocess.run(
            [sys.executable, '-m', 'yakutmorph.cli', 'analyze', '-f', 'tsv'],
            input='Мин кинигэни аахпытым.'.encode('utf-8'), capture_output=True, check=True)
        self.assertIn('кинигэ+N+ACC', result.stdout.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
