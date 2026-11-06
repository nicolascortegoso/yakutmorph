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

    def test_get_morphemes_keeps_syncretic_tags(self):
        """'+REFL/PASS' is one tag, not '+REFL' followed by stray text."""
        analysis = 'сатаа+V+REFL/PASS+NEG+PART_PRES'
        self.assertEqual(
            self.transducer.get_morphemes(analysis),
            ['сатаа', '+V', '+REFL/PASS', '+NEG', '+PART_PRES']
        )
        # Classified like the two voices it stands for.
        self.assertEqual(
            self.transducer.reference.is_boundary('+REFL/PASS'),
            self.transducer.reference.is_boundary('+REFL')
        )


if __name__ == '__main__':
    unittest.main()
