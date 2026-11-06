import unittest
from yakutmorph.transducers import YakutTransducer


class TestYakutTransducer(unittest.TestCase):

    def setUp(self):
        self.transducer = YakutTransducer()

    def test_analyse(self):
        surface_form = 'дьоннор'
        analysis_form = ['дьон+N+PL']
        self.assertEqual(self.transducer.analyse(surface_form), analysis_form)

    def test_generate(self):
        analysis_form = 'дьон+N+PL'
        surface_form = ['дьоннор']
        self.assertEqual(self.transducer.generate(analysis_form), surface_form)


if __name__ == '__main__':
    unittest.main()
