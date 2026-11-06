import unittest

from yakutmorph.paradigms import paradigm


def cells(table, row):
    return next(r for r in table['rows'] if r['label'] == row)['cells']


class TestParadigms(unittest.TestCase):

    def test_noun_cases_and_number(self):
        table = paradigm('дьиэ', 'N')['tables'][0]
        self.assertEqual(table['columns'], ['SG', 'PL'])
        self.assertEqual(cells(table, 'NOM'), {'SG': ['дьиэ'], 'PL': ['дьиэлэр']})
        self.assertEqual(cells(table, 'DAT'), {'SG': ['дьиэҕэ'], 'PL': ['дьиэлэргэ']})

    def test_noun_possessive(self):
        one, several = paradigm('дьиэ', 'N')['tables'][1:]
        self.assertEqual(cells(one, 'DAT')['1SG'], ['дьиэбэр'])
        self.assertEqual(cells(one, 'ACC')['3SG'], ['дьиэтин'])
        self.assertEqual(cells(several, 'NOM')['1SG'], ['дьиэлэрим'])

    def test_verb_tenses(self):
        affirmative, negative = paradigm('көр', 'V')['tables']
        self.assertEqual(cells(affirmative, 'Pres')['1SG'], ['көрөбүн'])
        self.assertEqual(cells(affirmative, 'NearPast')['3PL'], ['көрдүлэр'])
        self.assertEqual(cells(negative, 'Pres')['3SG'], ['көрбөт'])

    def test_each_cell_records_its_analysis(self):
        row = paradigm('көр', 'V')['tables'][0]['rows'][0]
        self.assertEqual(row['analyses']['1SG'], 'көр+V+PART_PRES+1SG')

    def test_unknown_root_or_category(self):
        with self.assertRaises(ValueError):
            paradigm('дьиэ', 'V')
        with self.assertRaises(ValueError):
            paradigm('дьиэ', 'Adj')


if __name__ == '__main__':
    unittest.main()
