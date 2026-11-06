import unittest

from yakutmorph.corpus import Corpus, analysis_string


class TestAnalysisString(unittest.TestCase):

    def test_joins_root_and_affixes(self):
        self.assertEqual(analysis_string({'root': 'дьиэ+N', 'affixes': '+POSS.3SG.ACC'}), 'дьиэ+N+POSS.3SG.ACC')

    def test_older_notations(self):
        self.assertEqual(analysis_string({'root': 'эт^V', 'affixes': '+PART_PAST'}), 'эт+V+PART_PAST')
        self.assertEqual(analysis_string({'root': 'санаа', 'affixes': ['+V', '+PART_PRES']}), 'санаа+V+PART_PRES')

    def test_punctuation_has_no_analysis(self):
        self.assertIsNone(analysis_string({'text': '.', 'type': 'period'}))


class TestCorpus(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.corpus = Corpus()

    def test_bundled_snapshot(self):
        self.assertGreater(len(self.corpus.records), 18000)
        self.assertEqual(self.corpus.origin['sentences'], len(self.corpus.records))

    def test_find_by_word_root_and_tag(self):
        by_word = self.corpus.find(word='Дьиэтин')
        self.assertGreater(by_word['total'], 0)
        for example in by_word['examples']:
            self.assertEqual(example['match']['text'].lower(), 'дьиэтин')
        by_root_and_tag = self.corpus.find(root='дьиэ', tag='+POSS.3SG.ACC', limit=3)
        for example in by_root_and_tag['examples']:
            analysis = example['match']['analysis']
            self.assertTrue(analysis.startswith('дьиэ+'))
            self.assertIn('POSS.3SG.ACC', analysis.split('+'))

    def test_both_criteria_apply_to_the_same_word(self):
        for example in self.corpus.find(root='көр', tag='NEG', limit=20)['examples']:
            self.assertTrue(example['match']['analysis'].startswith('көр+'))
            self.assertIn('NEG', example['match']['analysis'].split('+'))

    def test_example_fields(self):
        example = self.corpus.find(word='дьиэтин', limit=1)['examples'][0]
        for field in ('id', 'sentence', 'source', 'page', 'match', 'words'):
            self.assertIn(field, example)
        self.assertNotIn('notes', example)
        self.assertTrue('translation_ru' in example or 'translation_en' in example)

    def test_paging(self):
        first = self.corpus.find(tag='REFL/PASS', limit=3)
        second = self.corpus.find(tag='REFL/PASS', limit=3, offset=3)
        self.assertEqual(first['total'], second['total'])
        self.assertFalse({e['id'] for e in first['examples']} & {e['id'] for e in second['examples']})

    def test_ungrammatical_examples_are_flagged(self):
        flagged = [r for r in self.corpus.records if r.get('ungrammatical')]
        self.assertGreater(len(flagged), 0)

    def test_number_of_examples(self):
        self.assertEqual(len(self.corpus.find(tag='REFL/PASS')['examples']), 3)  # default
        self.assertEqual(len(self.corpus.find(tag='REFL/PASS', limit=7)['examples']), 7)
        few = self.corpus.find(word='дьиэтин', limit=1000)
        self.assertEqual(len(few['examples']), few['total'])  # fewer when fewer match

    def test_needs_a_criterion(self):
        with self.assertRaises(ValueError):
            self.corpus.find()


if __name__ == '__main__':
    unittest.main()
