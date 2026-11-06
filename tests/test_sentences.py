import unittest

from yakutmorph import YakutMorph
from yakutmorph.sentences import split_sentences


class TestSplitSentences(unittest.TestCase):

    def check(self, text, expected):
        self.assertEqual(split_sentences(text), expected)

    def test_end_marks(self):
        self.check('Кини кэллэ. Мин көрдүм! Тоҕо? Кэл... Бар.',
                   ['Кини кэллэ.', 'Мин көрдүм!', 'Тоҕо?', 'Кэл...', 'Бар.'])

    def test_combined_end_marks(self):
        self.check('Тоҕо?! Кэл!', ['Тоҕо?!', 'Кэл!'])

    def test_initials_do_not_end_a_sentence(self):
        self.check('В.И. Ленин төрөөбүтэ. Кини барда.', ['В.И. Ленин төрөөбүтэ.', 'Кини барда.'])

    def test_lowercase_after_period_does_not_end_a_sentence(self):
        self.check('Москва улахан. т.е. кини кэллэ', ['Москва улахан. т.е. кини кэллэ'])

    def test_quotation_marks_and_dashes(self):
        self.check('«Кини кэллэ.» Мин көрдүм.', ['«Кини кэллэ.»', 'Мин көрдүм.'])
        self.check('Кини кэллэ. — Суох.', ['Кини кэллэ.', '— Суох.'])
        self.check('Кини кэллэ. «Суох», — диэтэ.', ['Кини кэллэ.', '«Суох», — диэтэ.'])

    def test_paragraphs_and_line_breaks(self):
        self.check('Бастакы абзац\n\nИккис абзац\nсалҕанар.', ['Бастакы абзац', 'Иккис абзац салҕанар.'])

    def test_text_without_end_mark(self):
        self.check('мин аатым Кэскил', ['мин аатым Кэскил'])


class TestParseText(unittest.TestCase):

    def test_one_parse_per_sentence(self):
        parses = YakutMorph().parse_text('Мин оскуолаҕа бардым. Оскуолабыттан кэллим.')
        self.assertEqual([p.text for p in parses], ['Мин оскуолаҕа бардым.', 'Оскуолабыттан кэллим.'])
        # The second sentence starts with a capitalized common noun: not a name.
        first = parses[1].tokens[0]
        self.assertEqual(''.join(m.morpheme for m in first.morph.morphemes), 'оскуола+N+POSS.1SG.ABL')


if __name__ == '__main__':
    unittest.main()
