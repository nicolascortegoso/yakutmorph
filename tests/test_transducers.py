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

    def test_get_morphemes_keeps_slash_tags(self):
        """'+REFL/PASS' is one tag and must not be read as '+REFL'."""
        analysis = 'сатаа+V+REFL/PASS+NEG+PART_PRES'
        self.assertEqual(
            self.transducer.get_morphemes(analysis),
            ['сатаа', '+V', '+REFL/PASS', '+NEG', '+PART_PRES']
        )
        # A voice affix, like +REFL.
        self.assertEqual(
            self.transducer.reference.is_boundary('+REFL/PASS'),
            self.transducer.reference.is_boundary('+REFL')
        )


if __name__ == '__main__':
    unittest.main()
