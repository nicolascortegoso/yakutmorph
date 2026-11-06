import unittest

from yakutmorph.intensifiers import classify, construction_type


class TestIntensifierClassification(unittest.TestCase):
    """
    Regular and irregular intensifying augments, taken from Ubryatova et al.,
    1982, vol. 1, §250 (also collected in yakutmorph_dataset 001/pending/01_0250.json).
    """

    def test_monosyllabic_augments(self):
        pairs = [
            ('хап', 'хара'),
            ('ып', 'ыраас'),
            ('кып', 'кыһыл'),
            ('суп', 'суон'),
            ('хоп', 'хойуу'),
            ('ап', 'аһыы'),
            ('ып', 'ыарахан'),
            ('уп', 'ууллаҕас'),
            ('ап', 'араҕас'),
            ('төп', 'төгүрүк'),
        ]
        for augment, base in pairs:
            with self.subTest(augment=augment, base=base):
                self.assertEqual(classify(augment, base), construction_type.INTENSIFIER)

    def test_bisyllabic_augments(self):
        pairs = [
            ('тыбыс', 'тымныы'),
            ('кубус', 'кураанах'),
            ('көбүс', 'көнө'),
            ('хары', 'хантаҕар'),
            ('чуру', 'чулбугур'),
            ('бөрү', 'бөкчөгөр'),
        ]
        for augment, base in pairs:
            with self.subTest(augment=augment, base=base):
                self.assertEqual(classify(augment, base), construction_type.INTENSIFIER)

    def test_irregular_augments(self):
        pairs = [
            ('суос', 'соҕотох'),
            ('суоч', 'соҕотох'),
            ('уун', 'утары'),
        ]
        for augment, base in pairs:
            with self.subTest(augment=augment, base=base):
                self.assertEqual(classify(augment, base), construction_type.INTENSIFIER)

    def test_reduplication(self):
        self.assertEqual(classify('хара', 'хара'), construction_type.REDUPLICATION)
        self.assertEqual(classify('Хара', 'хара'), construction_type.REDUPLICATION)

    def test_compound(self):
        self.assertEqual(classify('ый', 'күн'), construction_type.COMPOUND)
        self.assertEqual(classify('баайдар', 'талымнар'), construction_type.COMPOUND)

    def test_fuzzy_fallback_false_positives(self):
        """
        Pairs confirmed, against yakutmorph_dataset, to be wrongly classified
        as intensifiers by an earlier version of the fuzzy fallback: either a
        literal prefix relationship (same-stem compounds/distributive
        reduplication, e.g. "each other"/"all of them") or same-or-greater
        length than the base (impossible for a genuine reduced augment).
        """
        pairs = [
            ('көр', 'көрүдьүөс'),
            ('мал', 'сал'),
            ('үөрүү', 'көтүү'),
            ('булааччы', 'талааччы'),
            ('бэйэ', 'бэйэтин'),
            ('бары', 'барыта'),
            ('нарыын', 'нарын'),
            ('ыраастан', 'ыраас'),
        ]
        for augment, base in pairs:
            with self.subTest(augment=augment, base=base):
                self.assertNotEqual(classify(augment, base), construction_type.INTENSIFIER)


if __name__ == '__main__':
    unittest.main()
