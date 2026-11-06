import unittest

from yakutmorph import YakutMorph
from yakutmorph.glossing import gloss_token, gloss_words, interlinear


class TestGlossing(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.morphology = YakutMorph()

    def gloss(self, word):
        g = gloss_token(self.morphology.parse(word).tokens[0])
        return g['segmented'], g['gloss']

    def test_regular_segmentation(self):
        self.assertEqual(self.gloss('дьиэлэргэ'), ('дьиэ-лэр-гэ', 'дьиэ-PL-DAT'))
        self.assertEqual(self.gloss('кинигэлэрбитин'), ('кинигэ-лэр-битин', 'кинигэ-PL-POSS.1PL.ACC'))

    def test_stem_final_alternation(self):
        self.assertEqual(self.gloss('Хараҕыттан'), ('Хараҕ-ыттан', 'харах-POSS.3SG.ABL'))
        self.assertEqual(self.gloss('аппын'), ('ап-пын', 'ат-POSS.1SG.ACC'))

    def test_affixes_without_visible_boundary_are_joined(self):
        self.assertEqual(self.gloss('көрбөппүн'), ('көр-бөп-пүн', 'көр-NEG.PART_PRES-1SG'))

    def test_no_boundary_found(self):
        segmented, gloss = self.gloss('сатаммат')
        self.assertEqual(segmented, 'сатаммат')
        self.assertEqual(gloss, 'сатаа.REFL/PASS.NEG.PART_PRES')

    def test_punctuation(self):
        words = gloss_words(self.morphology.parse('Кини кэллэ.'))
        self.assertEqual(words[-1], {'text': '.', 'segmented': '.', 'gloss': ''})

    def test_interlinear_lines_are_aligned(self):
        text = interlinear(self.morphology.parse('Мин кини дьиэтин көрдүм.'), translation='Я увидел его дом.')
        original, segmented, glosses, translation = text.split('\n')
        self.assertEqual(original, 'Мин кини дьиэтин көрдүм.')
        self.assertEqual(segmented.index('дьиэ-тин'), glosses.index('дьиэ-POSS.3SG.ACC'))
        self.assertEqual(translation, "'Я увидел его дом.'")


if __name__ == '__main__':
    unittest.main()
