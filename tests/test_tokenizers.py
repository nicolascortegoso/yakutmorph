import unittest
from yakutmorph.tokenizers import YakutTokenizer


class TestYakutTokenizer(unittest.TestCase):

    def setUp(self):
        self.tokenizer = YakutTokenizer()

    def test_phone(self):
        text = 'Сиһилии билсиҥ: https://zhataytekh.ru саайтка, +7(4114)426407, +7(4113)427303 төлөпүөнүнэн.'
        expected = [
            ('Сиһилии', 'title'), ('билсиҥ', 'lowercase'), (':', 'colon'), ('https://zhataytekh.ru', 'uri'),
            ('саайтка', 'lowercase'), (',', 'comma'), ('+7(4114)426407', 'phone'), (',', 'comma'),
            ('+7(4113)427303', 'phone'), ('төлөпүөнүнэн', 'lowercase'), ('.', 'period')
        ]
        self.assertEqual(self.tokenizer.tokenize(text), expected)

    def test_date(self):
        text = 'дата 01/04/2024'
        expected = [
            ('дата', 'lowercase'), ('01/04/2024', 'date')
        ]
        self.assertEqual(self.tokenizer.tokenize(text), expected)

    def test_number(self):
        text = '1949 сыллаахха оруобуна ахсынньы 10 күнүгэр аан бастаан көрдөрүллүбүт эбит.'
        expected = [
            ('1949', 'number'), ('сыллаахха', 'lowercase'), ('оруобуна', 'lowercase'), ('ахсынньы', 'lowercase'),
            ('10', 'number'), ('күнүгэр', 'lowercase'), ('аан', 'lowercase'), ('бастаан', 'lowercase'),
            ('көрдөрүллүбүт', 'lowercase'), ('эбит', 'lowercase'), ('.', 'period')
        ]
        self.assertEqual(self.tokenizer.tokenize(text), expected)

    def test_url(self):
        text = 'Хаартыска https://www.trud.ru саайтан.'
        expected = [
            ('Хаартыска', 'title'), ('https://www.trud.ru', 'uri'), ('саайтан', 'lowercase'), ('.', 'period')
        ]
        self.assertEqual(self.tokenizer.tokenize(text), expected)

    def test_email(self):
        text = 'Кыттааччыларгыт тустарынан иһитиннэриини sleptsova191_@mail.ru ыытыҥ.'
        expected = [
            ('Кыттааччыларгыт', 'title'), ('тустарынан', 'lowercase'), ('иһитиннэриини', 'lowercase'),
            ('sleptsova191_@mail.ru', 'email'), ('ыытыҥ', 'lowercase'), ('.', 'period')
        ]
        self.assertEqual(self.tokenizer.tokenize(text), expected)

    def test_roman(self):
        text = 'Ити саха хомустара бары XIX үйэ бүтүүтэ – XX үйэ бастакы аҥаарыгар оҥоһуллубуттар.'
        expected = [
            ('Ити', 'title'), ('саха', 'lowercase'), ('хомустара', 'lowercase'), ('бары', 'lowercase'),
            ('XIX', 'roman'), ('үйэ', 'lowercase'), ('бүтүүтэ', 'lowercase'), ('–', 'dash'), ('XX', 'roman'),
            ('үйэ', 'lowercase'), ('бастакы', 'lowercase'), ('аҥаарыгар', 'lowercase'),
            ('оҥоһуллубуттар', 'lowercase'), ('.', 'period')
        ]
        self.assertEqual(self.tokenizer.tokenize(text), expected)


if __name__ == '__main__':
    unittest.main()