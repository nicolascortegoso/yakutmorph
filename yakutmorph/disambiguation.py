"""
Morphological disambiguation. `YakutReranker`, a dual-encoder-with-attention
reranker running on ONNX Runtime, is the package's disambiguation model —
see nir/paper_2027.md in the yakutmorph_dataset research repository for its
evaluated design.
"""
import json
import re
from typing import List

import numpy as np
import onnxruntime as ort
import sentencepiece as spm

from .interfaces import DisambiguationModel
from .utils import get_file_path


class YakutReranker(DisambiguationModel):
    """
    Dual-encoder-with-attention disambiguator, run via onnxruntime rather
    than torch (~80MB installed — onnxruntime + numpy — versus torch's
    ~340MB, for numerically equivalent predictions; verified against the
    original PyTorch model on real held-out data before switching runtimes,
    see nir/disambiguation.md). Scores each ambiguous token's own candidate
    analyses against the full sentence context in one independent forward
    pass per token, rather than jointly decoding a whole-sentence DAG of
    coarse signatures the way the legacy model does — see nir/paper_2027.md
    §5 in the yakutmorph_dataset research repository for the architecture.
    """

    # Punctuation types that attach directly to the preceding/following
    # token with no space, for reconstructing a natural-looking sentence
    # string around the target marker — matches
    # disambiguation_model/scripts/prepare_dataset.py's mark_target.
    NO_SPACE_BEFORE = {
        'comma', 'period', 'colon', 'semicolon', 'question', 'exclamation',
        'ellipsis', 'hyphen',
    }
    NO_SPACE_AFTER = {'hyphen'}

    UNK_TAG_ID = 1

    _morpheme_re = re.compile(r'[а-яёһҕҥөү]+|[\^\+][A-Za-z_#\d\.\/]+')

    def __init__(self):
        self.sp_input = spm.SentencePieceProcessor(model_file=get_file_path('data/spm_input.model'))
        self.sp_candidate = spm.SentencePieceProcessor(model_file=get_file_path('data/spm_candidate.model'))
        with open(get_file_path('data/candidate_tag_vocab.json'), encoding='utf-8') as f:
            self.tag_to_id = json.load(f)
        self.session = ort.InferenceSession(get_file_path('data/reranker.onnx'))

    def _mark_target(self, tokens: List, target_pos: int) -> str:
        """
        Reconstructs a natural-looking sentence string with the token at
        `target_pos` wrapped in `<TARGET>`/`</TARGET>`, using the same
        punctuation-attachment rules as training-time data preparation
        rather than naive space-joining.
        """
        pieces = []
        for i, token in enumerate(tokens):
            text = f'<TARGET>{token.surface}</TARGET>' if i == target_pos else token.surface
            if pieces and token.type not in self.NO_SPACE_BEFORE and tokens[i - 1].type not in self.NO_SPACE_AFTER:
                pieces.append(' ')
            pieces.append(text)
        return ''.join(pieces)

    def _encode_candidate(self, candidate: str) -> List[int]:
        """
        Root subwords (via the candidate tokenizer) followed by hardcoded
        tag ids, in one combined id space — see disambiguation_model's
        dataset.py, whose encoding scheme this mirrors exactly so the
        shipped model weights and vocabularies stay meaningful.
        """
        morphs = self._morpheme_re.findall(candidate)
        root_ids = self.sp_candidate.encode(morphs[0], out_type=int)
        offset = self.sp_candidate.vocab_size()
        tag_ids = [offset + self.tag_to_id.get(t, self.UNK_TAG_ID) for t in morphs[1:]]
        return root_ids + tag_ids

    def disambiguate(self, tokens: List) -> List[int]:
        """
        Scores each ambiguous token's candidates independently, conditioned
        on the full sentence with that token marked as the target.

        :param tokens: The list of Token objects for the sentence.
        :return: One index per ambiguous token, in order, selecting that
            token's most likely candidate analysis.
        """
        indexes = []
        for pos, token in enumerate(tokens):
            if not token.has_morph or not token.is_ambiguous():
                continue

            candidates = [
                ''.join(m.morpheme for m in analysis.morphemes)
                for analysis in token.analyses.output
            ]

            sentence_text = self._mark_target(tokens, pos)
            sentence_ids = np.array([self.sp_input.encode(sentence_text, out_type=int)], dtype=np.int64)
            sentence_mask = np.ones_like(sentence_ids, dtype=np.float32)

            candidate_id_lists = [self._encode_candidate(c) for c in candidates]
            max_len = max(len(c) for c in candidate_id_lists)
            candidate_ids = np.zeros((1, len(candidates), max_len), dtype=np.int64)
            candidate_token_mask = np.zeros((1, len(candidates), max_len), dtype=np.float32)
            for j, ids in enumerate(candidate_id_lists):
                candidate_ids[0, j, :len(ids)] = ids
                candidate_token_mask[0, j, :len(ids)] = 1
            candidate_mask = np.ones((1, len(candidates)), dtype=np.float32)

            scores = self.session.run(['scores'], {
                'sentence_ids': sentence_ids,
                'sentence_mask': sentence_mask,
                'candidate_ids': candidate_ids,
                'candidate_token_mask': candidate_token_mask,
                'candidate_mask': candidate_mask,
            })[0]
            indexes.append(int(scores.argmax(axis=-1)[0]))
        return indexes
