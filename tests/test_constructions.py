import unittest

from yakutmorph.constructions import _match_pattern_at, _parse_slot, detect, load_patterns
from yakutmorph.interfaces import MorphReference
from yakutmorph.main import YakutMorph
from yakutmorph.wrappers import Analyses, Analysis, Token


class _StubReference(MorphReference):
    """A minimal MorphReference for building synthetic, FST-free Token
    fixtures: every tag maps to an empty reference dict, which is all
    `Analysis.__init__` needs for a bare root+category (no further
    affixation, so `is_boundary` is never even called)."""

    def get_tags(self):
        return []

    def get_tag(self, tag):
        return {}


def _token(pos: int, root: str) -> Token:
    """A Token whose sole, already-disambiguated analysis has exactly the
    given combined root+category string (e.g. 'ким+Pron') and no further
    affixation — everything `constructions.py`'s matcher looks at."""
    lexical, category = root.split('+', 1)
    analysis = Analysis([lexical, '+' + category], reference=_StubReference())
    return Token(pos, lexical, 'lowercase', True, analyses=Analyses(fst=None, output=[analysis], idx_mla=0))


def _punct(pos: int) -> Token:
    return Token(pos, '.', 'period', False)


class TestSlotParsing(unittest.TestCase):

    def test_literal_slot(self):
        self.assertEqual(_parse_slot('ол+Pron'), ('ол+Pron', False, False))

    def test_wildcard_slot(self):
        self.assertEqual(_parse_slot('+V'), ('+V', True, False))

    def test_quantified_literal_slot(self):
        self.assertEqual(_parse_slot('ол+Pron+'), ('ол+Pron', False, True))

    def test_quantified_wildcard_slot(self):
        self.assertEqual(_parse_slot('+PN+'), ('+PN', True, True))


class TestPatternMatching(unittest.TestCase):
    """Algorithmic tests against synthetic, FST-free tokens: literal vs.
    wildcard slots, greedy quantifiers, ordering, non-overlap, and the
    2-token minimum span guard — independent of any real Yakut data (see
    TestRealConstructions below for that)."""

    def test_literal_pattern_matches(self):
        tokens = [_token(1, 'ол+Pron'), _token(2, 'да+Part'), _token(3, 'буол+V')]
        end = _match_pattern_at(tokens, 0, ['ол+Pron', 'да+Part', 'буол+V'])
        self.assertEqual(end, 3)

    def test_literal_pattern_rejects_wrong_root(self):
        tokens = [_token(1, 'ол+Pron'), _token(2, 'да+Part'), _token(3, 'кэл+V')]
        end = _match_pattern_at(tokens, 0, ['ол+Pron', 'да+Part', 'буол+V'])
        self.assertIsNone(end)

    def test_wildcard_slot_matches_any_root_with_that_category(self):
        tokens = [_token(1, 'ким+Pron'), _token(2, 'эрэ+Part')]
        end = _match_pattern_at(tokens, 0, ['+Pron', 'эрэ+Part'])
        self.assertEqual(end, 2)

    def test_wildcard_slot_rejects_different_category(self):
        tokens = [_token(1, 'тоҕо+Adv'), _token(2, 'эрэ+Part')]
        end = _match_pattern_at(tokens, 0, ['+Pron', 'эрэ+Part'])
        self.assertIsNone(end)

    def test_quantified_wildcard_consumes_one(self):
        tokens = [_token(1, 'иван+PN'), _token(2, 'кэл+V')]
        end = _match_pattern_at(tokens, 0, ['+PN+'])
        self.assertEqual(end, 1)

    def test_quantified_wildcard_consumes_several(self):
        tokens = [_token(1, 'иван+PN'), _token(2, 'иванович+PN'), _token(3, 'кэл+V')]
        end = _match_pattern_at(tokens, 0, ['+PN+'])
        self.assertEqual(end, 2)

    def test_quantified_wildcard_requires_at_least_one(self):
        tokens = [_token(1, 'кэл+V')]
        end = _match_pattern_at(tokens, 0, ['+PN+'])
        self.assertIsNone(end)

    def test_pattern_past_end_of_tokens_fails(self):
        tokens = [_token(1, 'ол+Pron')]
        end = _match_pattern_at(tokens, 0, ['ол+Pron', 'да+Part'])
        self.assertIsNone(end)

    def test_non_morph_token_never_matches(self):
        tokens = [_token(1, 'ол+Pron'), _punct(2)]
        end = _match_pattern_at(tokens, 0, ['ол+Pron', '+Part'])
        self.assertIsNone(end)


class TestDetect(unittest.TestCase):
    """`detect` end-to-end over a token sequence: flagging, the 2-token
    minimum span, pattern-order precedence, and non-overlapping matches."""

    def test_matched_span_gets_flagged_with_label(self):
        tokens = [_token(1, 'ол+Pron'), _token(2, 'да+Part'), _token(3, 'буол+V')]
        patterns = [('ол_да_буоллар', ['ол+Pron', 'да+Part', 'буол+V'])]
        detect(tokens, patterns)
        self.assertEqual([t.compound for t in tokens], ['ол_да_буоллар'] * 3)

    def test_unmatched_tokens_stay_unflagged(self):
        tokens = [_token(1, 'мин+Pron'), _token(2, 'кэл+V')]
        patterns = [('ол_да_буоллар', ['ол+Pron', 'да+Part', 'буол+V'])]
        detect(tokens, patterns)
        self.assertEqual([t.compound for t in tokens], [None, None])

    def test_single_token_match_is_not_flagged(self):
        """A pattern that happens to match only one token (e.g. a lone
        proper noun against a '+PN+' wildcard) is not a construction on
        its own."""
        tokens = [_token(1, 'иван+PN'), _token(2, 'кэл+V')]
        patterns = [('proper_name_run', ['+PN+'])]
        detect(tokens, patterns)
        self.assertEqual([t.compound for t in tokens], [None, None])

    def test_multi_token_quantified_match_is_flagged(self):
        tokens = [_token(1, 'иван+PN'), _token(2, 'иванович+PN'), _token(3, 'кэл+V')]
        patterns = [('proper_name_run', ['+PN+'])]
        detect(tokens, patterns)
        self.assertEqual([t.compound for t in tokens], ['proper_name_run', 'proper_name_run', None])

    def test_earlier_pattern_wins_at_same_position(self):
        tokens = [_token(1, 'ол+Pron'), _token(2, 'да+Part')]
        patterns = [
            ('specific', ['ол+Pron', 'да+Part']),
            ('generic', ['+Pron', '+Part']),
        ]
        detect(tokens, patterns)
        self.assertEqual([t.compound for t in tokens], ['specific', 'specific'])

    def test_matches_do_not_overlap(self):
        tokens = [_token(1, 'ким+Pron'), _token(2, 'эрэ+Part'), _token(3, 'ким+Pron'), _token(4, 'эрэ+Part')]
        patterns = [('indefinite_pronoun', ['ким+Pron', 'эрэ+Part'])]
        detect(tokens, patterns)
        self.assertEqual([t.compound for t in tokens], ['indefinite_pronoun'] * 4)


class TestLoadPatterns(unittest.TestCase):

    def test_loads_default_lexicon(self):
        patterns = load_patterns('data/constructions.yaml', inside_package=True)
        self.assertGreater(len(patterns), 0)
        for label, pattern in patterns:
            self.assertIsInstance(label, str)
            self.assertIsInstance(pattern, list)
            self.assertGreater(len(pattern), 0)

    def test_ol_da_buollar_present(self):
        patterns = load_patterns('data/constructions.yaml', inside_package=True)
        labels = [label for label, _ in patterns]
        self.assertIn('ол_да_буоллар', labels)


class TestRealConstructions(unittest.TestCase):
    """Integration tests against the real transducer pipeline and the
    shipped default lexicon, matching what was verified live in session
    against yakutmorph_dataset (see §976 for ол_да_буоллар and the
    'эрэ'/'эмэ' indefinite-pronoun word-forming note)."""

    def setUp(self):
        self.morphology = YakutMorph()

    def test_ol_da_buollar_flagged(self):
        text = 'Барахсан ырыата дьырылаан үчүгэй даҕаны, ол да буоллар кыыс ырыата быдан ордук быһыылаах.'
        parse = self.morphology.parse(text)
        flagged = [t.surface for t in parse.tokens if t.compound == 'ол_да_буоллар']
        self.assertEqual(flagged, ['ол', 'да', 'буоллар'])

    def test_partial_ol_da_without_buollar_not_flagged(self):
        parse = self.morphology.parse('ол да киһи кэллэ.')
        self.assertFalse(any(t.compound for t in parse.tokens))

    def test_indefinite_pronoun_flagged(self):
        for word in ('ким', 'туох', 'ханнык', 'хаһан'):
            with self.subTest(word=word):
                parse = self.morphology.parse(f'{word} эрэ')
                self.assertEqual([t.compound for t in parse.tokens], ['indefinite_pronoun'] * 2)

    def test_ordinary_particle_use_not_flagged(self):
        """'эрэ' after a verb is ordinary 'only' usage, not the
        interrogative-forming construction."""
        parse = self.morphology.parse('билсэн эрэ')
        self.assertFalse(any(t.compound for t in parse.tokens))

    def test_hyphen_intensifier_still_uses_its_own_label(self):
        """Sanity check that the two detection mechanisms (hyphen-joined,
        via yakutmorph.intensifiers, and whitespace-separated, via this
        module) share the Token.compound flag without colliding."""
        parse = self.morphology.parse('хап-хара харах')
        self.assertEqual(parse.tokens[0].compound, 'intensifier')
        self.assertEqual(parse.tokens[2].compound, 'intensifier')
        self.assertIsNone(parse.tokens[3].compound)


if __name__ == '__main__':
    unittest.main()
