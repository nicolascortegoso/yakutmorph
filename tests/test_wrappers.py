import unittest

from yakutmorph.main import YakutMorph


class TestAnalysisStructure(unittest.TestCase):
    """Analysis/InflGroup/Morph structure across the three cases that
    matter for `Analysis.root` combining the lexical root with its own
    category tag: no affixation at all, pure inflection on the root, and
    real derivation. Each case was hand-verified in session; see
    README.md's "Analysis"/"Inflectional Groups"/"Morphemes" walkthrough
    for the same examples."""

    def setUp(self):
        self.morphology = YakutMorph()

    def test_no_affixation_beyond_root_category(self):
        """'мин' as the pronoun 'I': root already carries everything,
        infl_groups is empty."""
        parse = self.morphology.parse('мин барда.')
        token = parse.tokens[0]
        self.assertEqual(token.morph.root.morpheme, 'мин+Pron')
        self.assertEqual(token.morph.root.type, 'root')
        self.assertEqual(token.morph.infl_groups, [])
        self.assertEqual(token.morph.morphemes, [token.morph.root])

    def test_pure_inflection_on_root(self):
        """'аатым' = аат (name) + N (its own category) + POSS.1SG: one
        inflectional group, no derivational boundary."""
        parse = self.morphology.parse('аатым сыыс.')
        token = parse.tokens[0]
        self.assertEqual(token.morph.root.morpheme, 'аат+N')
        self.assertEqual(len(token.morph.infl_groups), 1)
        ig = token.morph.infl_groups[0]
        self.assertEqual(ig.pos, 1)
        self.assertEqual([a.morpheme for a in ig.affixes], ['+POSS.1SG'])
        self.assertEqual(ig.affixes[0].type, 'fl')

    def test_real_derivation_plus_inflection(self):
        """'хараарар' = хара+Adj + VRBLZ#4a (derivational boundary) +
        PART_PRES (inflectional, on top of the derived verb)."""
        parse = self.morphology.parse('хараарар байанай.')
        token = parse.tokens[0]
        self.assertEqual(token.morph.root.morpheme, 'хара+Adj')
        self.assertEqual(len(token.morph.infl_groups), 1)
        ig = token.morph.infl_groups[0]
        self.assertEqual([a.morpheme for a in ig.affixes], ['+VRBLZ#4a', '+PART_PRES'])
        self.assertEqual(ig.affixes[0].type, 'db')
        self.assertEqual(ig.affixes[1].type, 'fl')

    def test_multiple_derivational_boundaries(self):
        """'холобурдаабыт' = холоо+V + NMLZ#4 (db) + VRBLZ#1 (db) +
        PART_PAST (fl): two inflectional groups, the outer one holding
        the word's current (verbal) category."""
        parse = self.morphology.parse('холобурдаабыт киһи.')
        token = parse.tokens[0]
        self.assertEqual(token.morph.root.morpheme, 'холоо+V')
        self.assertEqual(len(token.morph.infl_groups), 2)
        first, second = token.morph.infl_groups
        self.assertEqual([a.morpheme for a in first.affixes], ['+NMLZ#4'])
        self.assertEqual(first.affixes[0].type, 'db')
        self.assertEqual([a.morpheme for a in second.affixes], ['+VRBLZ#1', '+PART_PAST'])
        self.assertEqual(second.affixes[0].type, 'db')
        self.assertEqual(second.affixes[1].type, 'fl')


class TestSplitAtLastDerivation(unittest.TestCase):
    """The shared backward-walk (`Analysis.split_at_last_derivation`)
    that both lemma extraction (`remove_inflections`) and the CoNLL-U
    mapper's grammeme extraction are built on."""

    def setUp(self):
        self.morphology = YakutMorph()

    def test_no_derivation_kept_is_just_the_root(self):
        parse = self.morphology.parse('мин барда.')
        token = parse.tokens[0]
        kept, inflections = token.morph.split_at_last_derivation()
        self.assertEqual(kept, [token.morph.root])
        self.assertEqual(inflections, [])

    def test_pure_inflection_kept_is_root_inflections_is_the_affix(self):
        parse = self.morphology.parse('аатым сыыс.')
        token = parse.tokens[0]
        kept, inflections = token.morph.split_at_last_derivation()
        self.assertEqual(kept, [token.morph.root])
        self.assertEqual([m.morpheme for m in inflections], ['+POSS.1SG'])

    def test_stops_at_last_derivational_boundary(self):
        """For a word with two derivational steps, the split point is the
        LAST (outermost) one — everything up to and including it is
        'kept' (the lemma-bearing portion), only the trailing purely
        inflectional affix is peeled off."""
        parse = self.morphology.parse('холобурдаабыт киһи.')
        token = parse.tokens[0]
        kept, inflections = token.morph.split_at_last_derivation()
        self.assertEqual(
            [m.morpheme for m in kept],
            ['холоо+V', '+NMLZ#4', '+VRBLZ#1'],
        )
        self.assertEqual([m.morpheme for m in inflections], ['+PART_PAST'])

    def test_remove_inflections_matches_split_at_last_derivation(self):
        parse = self.morphology.parse('холобурдаабыт киһи.')
        token = parse.tokens[0]
        kept, _ = token.morph.split_at_last_derivation()
        self.assertEqual(token.morph.remove_inflections(), kept)


class TestTokenAndParse(unittest.TestCase):

    def setUp(self):
        self.morphology = YakutMorph()

    def test_ambiguous_token_reports_multiple_candidates(self):
        parse = self.morphology.parse('мин аатым Кэскил.')
        self.assertTrue(parse.tokens[0].is_ambiguous())
        self.assertGreater(len(parse.tokens[0].analyses.output), 1)

    def test_unambiguous_token_reports_single_candidate(self):
        parse = self.morphology.parse('мин аатым Кэскил.')
        self.assertFalse(parse.tokens[1].is_ambiguous())

    def test_morph_property_follows_idx_mla(self):
        parse = self.morphology.parse('мин аатым Кэскил.')
        token = parse.tokens[0]
        candidates = token.analyses.output
        for idx in range(len(candidates)):
            token.analyses.set_mla(idx)
            self.assertIs(token.morph, candidates[idx])

    def test_lemma_of_derived_word(self):
        parse = self.morphology.parse('холобурдаабыт киһи.')
        self.assertEqual(parse.tokens[0].lemmas, ['холобурдаа'])

    def test_confidence_of_the_chosen_analysis(self):
        token = self.morphology.parse('мин аатым Кэскил.').tokens[0]  # мин: +N or +Pron
        probabilities = token.analyses.probabilities
        self.assertEqual(len(probabilities), len(token.analyses.output))
        self.assertAlmostEqual(sum(probabilities), 1.0, places=5)
        self.assertEqual(token.analyses.confidence, max(probabilities))
        self.assertEqual(token.analyses.idx_mla, probabilities.index(max(probabilities)))

    def test_confidence_of_a_single_analysis(self):
        token = self.morphology.parse('мин аатым Кэскил.').tokens[1]
        self.assertEqual(token.analyses.confidence, 1.0)

    def test_parse_is_ambiguous_reflects_any_ambiguous_token(self):
        parse = self.morphology.parse('мин аатым Кэскил.')
        self.assertTrue(parse.is_ambiguous())
        parse2 = self.morphology.parse('аатым.')
        self.assertFalse(parse2.is_ambiguous())


if __name__ == '__main__':
    unittest.main()
