import unittest

from yakutmorph import YakutMorph


class TestProperNamePromotion(unittest.TestCase):
    """Capitalized +N words are tagged +PN when they are listed names or do
    not start a sentence (see transducers.PostPipeline)."""

    @classmethod
    def setUpClass(cls):
        cls.morphology = YakutMorph()

    def analysis(self, text, surface):
        token = next(t for t in self.morphology.parse(text).tokens if t.surface == surface)
        return ''.join(m.morpheme for m in token.morph.morphemes)

    def test_capitalized_mid_sentence_is_a_name(self):
        self.assertEqual(self.analysis('мин аатым Кэскил.', 'Кэскил'), 'кэскил+PN')

    def test_capitalized_after_full_stop_is_not_a_name(self):
        text = 'Мин оскуолаҕа бардым. Оскуолабыттан кэллим.'
        self.assertEqual(self.analysis(text, 'Оскуолабыттан'), 'оскуола+N+POSS.1SG.ABL')

    def test_capitalized_after_dialogue_dash_is_not_a_name(self):
        self.assertEqual(self.analysis('— Суох.', 'Суох'), 'суох+N')

    def test_listed_name_after_full_stop_is_a_name(self):
        text = 'Мин Микиитэни көрдүм. Микиитэ кэллэ.'
        self.assertEqual(self.analysis(text, 'Микиитэ'), 'микиитэ+PN')

    def test_capitalized_after_quotation_mark_in_mid_sentence_is_a_name(self):
        self.assertEqual(self.analysis('Биһиги «Победа» теплоходунан бардыбыт.', 'Победа'), 'победа+PN')

    def test_capitalized_after_quotation_mark_opening_direct_speech_is_not_a_name(self):
        self.assertEqual(self.analysis('«Суох, суох», — диэтэ.', 'Суох'), 'суох+N')

    def test_listed_name_that_is_also_a_common_word(self):
        """'харах' ('eye') is listed as a name and as a homonym: promoted in
        mid-sentence only."""
        self.assertEqual(self.analysis('Хараҕыттан уу таҕыста.', 'Хараҕыттан'), 'харах+N+POSS.3SG.ABL')
        self.assertEqual(self.analysis('Мин Хараҕы көрдүм.', 'Хараҕы'), 'харах+PN+ACC')


if __name__ == '__main__':
    unittest.main()
