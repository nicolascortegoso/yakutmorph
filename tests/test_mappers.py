import unittest

from yakutmorph.main import YakutMorph
from yakutmorph.mappers import CoNLLU, YakutManualDisambiguation


class TestCoNLLU(unittest.TestCase):

    def setUp(self):
        self.morphology = YakutMorph()

    def _rows(self, text):
        parse = self.morphology.parse(text)
        lines = str(CoNLLU(parse)).split('\n')
        header, rows = lines[0], lines[1:]
        return header, [row.split('\t') for row in rows]

    def test_header_line(self):
        header, _ = self._rows('мин аатым Кэскил.')
        self.assertEqual(header, '# text = мин аатым Кэскил.')

    def test_pronoun_row(self):
        _, rows = self._rows('мин аатым Кэскил.')
        pos, form, lemma, upos, xpos, feats, head, deprel, deps, misc = rows[0]
        self.assertEqual((pos, form, lemma, upos, xpos), ('1', 'мин', 'мин', 'PRON', 'pron'))
        self.assertIn('PronType=Prs', feats.split('|'))
        self.assertEqual((head, deprel, deps), ('_', '_', '_'))
        self.assertEqual(misc, 'Analysis=мин+Pron')

    def test_possessive_inflection_row(self):
        _, rows = self._rows('мин аатым Кэскил.')
        _, form, lemma, upos, xpos, feats, *_, misc = rows[1]
        self.assertEqual((form, lemma, upos, xpos), ('аатым', 'аат', 'NOUN', 'n'))
        grammemes = feats.split('|')
        self.assertIn('Number[psor]=Sing', grammemes)
        self.assertIn('Person[psor]=1', grammemes)
        self.assertEqual(misc, 'Analysis=аат+N+POSS.1SG')

    def test_possessive_case_portmanteau_row(self):
        """'+POSS.3SG.ACC' is one tag; its features are those of
        '+POSS.3SG' and '+ACC' together."""
        _, rows = self._rows('мин кини дьиэтин көрдүм.')
        _, form, lemma, upos, _, feats, *_, misc = rows[2]
        self.assertEqual((form, lemma, upos), ('дьиэтин', 'дьиэ', 'NOUN'))
        self.assertEqual(misc, 'Analysis=дьиэ+N+POSS.3SG.ACC')
        grammemes = feats.split('|')
        for grammeme in ('Case=Acc', 'Number[psor]=Sing', 'Person[psor]=3'):
            self.assertIn(grammeme, grammemes)

    def test_derivational_grammemes_come_from_outermost_category(self):
        """For 'хараарар' (хара+Adj -> +VRBLZ#4a (db) -> +PART_PRES (fl)),
        UPOS/grammemes must come from the derived VERB category, not the
        underlying adjective root."""
        _, rows = self._rows('хараарар байанай.')
        _, form, lemma, upos, xpos, feats, *_, misc = rows[0]
        self.assertEqual((form, lemma, upos, xpos), ('хараарар', 'хараар', 'VERB', 'v'))
        self.assertEqual(misc, 'Analysis=хара+Adj+VRBLZ#4a+PART_PRES')

    def test_multiple_derivational_boundaries(self):
        """'холобурдаабыт' has two derivational steps; the mapper must
        use the outer (verbal) one, not the inner (nominalising) one, and
        must still surface the trailing purely-inflectional PART_PAST."""
        _, rows = self._rows('холобурдаабыт киһи.')
        _, form, lemma, upos, xpos, feats, *_, misc = rows[0]
        self.assertEqual((form, lemma, upos), ('холобурдаабыт', 'холобурдаа', 'VERB'))
        self.assertEqual(misc, 'Analysis=холоо+V+NMLZ#4+VRBLZ#1+PART_PAST')

    def _feats(self, word):
        _, rows = self._rows(word)
        return rows[0][5]

    def test_past_tense_has_no_imperative_mood(self):
        self.assertEqual(self._feats('кэллилэр'), 'Number=Plur|Person=3|Tense=NearPast')
        self.assertEqual(self._feats('кэллэ'), 'Number=Sing|Person=3|Tense=NearPast')

    def test_imperatives_keep_imperative_mood(self):
        for word in ('кэл', 'ааҕыҥ', 'барыма'):
            with self.subTest(word=word):
                self.assertIn('Mood=Imp', self._feats(word).split('|'))

    def test_voice_values_follow_ud_sakha(self):
        """Values as in UD's Sakha Voice feature: the fused reflexive-passive
        is PassRfl; stacked voices are one value, parts in alphabetical order."""
        for word, voice in (('суунна', 'PassRfl'), ('ыытылынна', 'Pass'),
                            ('ыыттарда', 'Cau'), ('оҥоһуллубут', 'PassRcp')):
            with self.subTest(word=word):
                self.assertIn(f'Voice={voice}', self._feats(word).split('|'))

    def _row(self, text, form):
        _, rows = self._rows(text)
        return next(row for row in rows if row[1] == form)

    def test_registered_sakha_auxiliaries_are_aux(self):
        """э-, баар and суох are AUX, as in UD_Yakut-YKTDT, without noun features."""
        self.assertEqual(self._row('Кини быраас этэ.', 'этэ')[3], 'AUX')
        баар = self._row('Биһиэхэ биир улахан сылабаар баар.', 'баар')
        self.assertEqual((баар[3], баар[5]), ('AUX', '_'))
        self.assertEqual(self._row('Бу сир чиэрбэтэ суох.', 'суох')[3], 'AUX')

    def test_service_verbs_and_copula_buol_stay_verb(self):
        self.assertEqual(self._row('Кыыс чобуотук эппиэттээн барда.', 'барда')[3], 'VERB')
        self.assertEqual(self._row('Кини быраас буолла.', 'буолла')[3], 'VERB')

    def test_yes_valued_features_are_not_booleans(self):
        """PyYAML reads an unquoted Yes as True; the feature value must be Yes."""
        self.assertIn('Int=Yes', self._row('Ханна баарый?', 'баарый')[5].split('|'))

    def test_punctuation_row(self):
        _, rows = self._rows('мин аатым Кэскил.')
        pos, form, lemma, upos, xpos, feats, head, deprel, deps, misc = rows[-1]
        self.assertEqual((form, lemma, upos, xpos), ('.', '.', 'PUNCT', 'punct'))
        self.assertEqual((feats, head, deprel, deps, misc), ('_', '_', '_', '_', '_'))

    def test_proper_noun_lemma_is_the_root_without_inflection(self):
        """Кэскил, capitalized and non-sentence-initial, is promoted
        N -> PN by PostPipeline; like any other word, its lemma is the
        root without inflectional affixes."""
        _, rows = self._rows('мин аатым Кэскил.')
        _, form, lemma, upos, xpos, *_ = rows[2]
        self.assertEqual((form, lemma, upos, xpos), ('Кэскил', 'кэскил', 'PROPN', 'propn'))
        _, rows = self._rows('мин Кэскилгэ бардым.')
        self.assertEqual(rows[1][1:4], ['Кэскилгэ', 'кэскил', 'PROPN'])

    def test_indefinite_pronoun_construction_does_not_change_conllu_tags(self):
        """Token.compound isn't surfaced in CoNLL-U (see the compounds
        discussion): flagged tokens still get their own ordinary tags."""
        _, rows = self._rows('ким эрэ кэлбитэ.')
        pos, form, lemma, upos, xpos, feats, *_ = rows[0]
        self.assertEqual((form, upos), ('ким', 'PRON'))
        self.assertIn('PronType=Int', feats.split('|'))


class TestYakutManualDisambiguation(unittest.TestCase):

    def test_one_entry_per_candidate_with_transducer_label(self):
        import json
        result = YakutManualDisambiguation(YakutMorph().parse('мин аатым Кэскил.'))
        json.dumps(result, ensure_ascii=False)  # must be serializable
        min_entries = [p for p in result['parses'] if p['text'] == 'мин']
        self.assertEqual({p['root'] for p in min_entries}, {'мин+N', 'мин+Pron'})
        self.assertEqual({p['fst'] for p in min_entries}, {'voc'})


if __name__ == '__main__':
    unittest.main()
