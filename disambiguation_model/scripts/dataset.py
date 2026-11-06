"""
Data loading for the dual-encoder reranker (paper_2027.md §4). Builds the
tag vocabulary directly from this project's own regenerated candidate data
(train/dev/test.jsonl) rather than reusing the sibling seq2seq project's
tag_vocab.json, since candidates here can carry tags that project never saw
(e.g. ^INTENS, from this session's hyphen-construction work).
"""
import json
import re
from pathlib import Path

import sentencepiece as spm
import torch
from torch.nn.utils.rnn import pad_sequence

DATA_DIR = Path(__file__).resolve().parents[1] / "data"
TOKENIZER_DIR = Path(__file__).resolve().parents[1] / "tokenizer"

MORPHEME_RE = re.compile(r"[а-яёһҕҥөү]+|[\^\+][A-Za-z_#\d\.\/]+")

PAD, UNK = 0, 1  # tag-vocabulary reserved ids (offset after spm_candidate's own ids)


def load_jsonl(split):
    records = []
    with open(DATA_DIR / f"{split}.jsonl", encoding="utf-8") as f:
        for line in f:
            records.append(json.loads(line))
    return records


def build_tag_vocab(*splits_records):
    """All distinct affix/category tags seen across the given splits (train
    should always be included; dev/test are included too so an unseen-in-
    train tag still maps to a stable id rather than always UNK — the model
    itself never trains on it, matching how an unseen root behaves for the
    root tokenizer)."""
    tags = set()
    for records in splits_records:
        for rec in records:
            for cand in rec["candidates"]:
                morphs = MORPHEME_RE.findall(cand)
                tags.update(morphs[1:])  # everything but the root
    tag_to_id = {"<pad>": PAD, "<unk>": UNK}
    for t in sorted(tags):
        tag_to_id[t] = len(tag_to_id)
    return tag_to_id


class Vocabs:
    def __init__(self):
        self.sp_input = spm.SentencePieceProcessor(model_file=str(TOKENIZER_DIR / "spm_input.model"))
        self.sp_candidate = spm.SentencePieceProcessor(model_file=str(TOKENIZER_DIR / "spm_candidate.model"))
        train, dev, test = load_jsonl("train"), load_jsonl("dev"), load_jsonl("test")
        self.tag_to_id = build_tag_vocab(train, dev, test)
        self.candidate_vocab_size = self.sp_candidate.vocab_size() + len(self.tag_to_id)
        self._splits = {"train": train, "dev": dev, "test": test}

    def encode_candidate(self, candidate_str):
        """Root subwords (via spm_candidate) followed by hardcoded tag ids,
        all in one combined id space: spm_candidate ids as-is, tag ids
        offset past the end of spm_candidate's own vocabulary."""
        morphs = MORPHEME_RE.findall(candidate_str)
        root_ids = self.sp_candidate.encode(morphs[0], out_type=int)
        offset = self.sp_candidate.vocab_size()
        tag_ids = [offset + self.tag_to_id.get(t, UNK) for t in morphs[1:]]
        return root_ids + tag_ids


class RerankerDataset(torch.utils.data.Dataset):
    def __init__(self, split, vocabs: Vocabs):
        self.records = vocabs._splits[split]
        self.vocabs = vocabs

    def __len__(self):
        return len(self.records)

    def __getitem__(self, idx):
        rec = self.records[idx]
        sentence_ids = self.vocabs.sp_input.encode(rec["sentence"], out_type=int)
        candidate_ids = [self.vocabs.encode_candidate(c) for c in rec["candidates"]]
        return {
            "sentence_ids": sentence_ids,
            "candidate_ids": candidate_ids,
            "label": rec["label"],
        }


def collate(batch):
    """Pads a batch of variable-length sentences and variable-count,
    variable-length candidate lists into dense tensors, with masks for both
    the token dimension (within a sentence/candidate) and the candidate-slot
    dimension (how many real candidates a given example actually has)."""
    B = len(batch)
    sentence_ids = [torch.tensor(b["sentence_ids"], dtype=torch.long) for b in batch]
    sentence_ids = pad_sequence(sentence_ids, batch_first=True, padding_value=PAD)
    sentence_mask = (sentence_ids != PAD).float()

    max_candidates = max(len(b["candidate_ids"]) for b in batch)
    max_cand_len = max(len(c) for b in batch for c in b["candidate_ids"])

    candidate_ids = torch.full((B, max_candidates, max_cand_len), PAD, dtype=torch.long)
    candidate_token_mask = torch.zeros((B, max_candidates, max_cand_len))
    candidate_mask = torch.zeros((B, max_candidates))
    labels = torch.zeros(B, dtype=torch.long)

    for i, b in enumerate(batch):
        candidate_mask[i, :len(b["candidate_ids"])] = 1
        for j, cand in enumerate(b["candidate_ids"]):
            candidate_ids[i, j, :len(cand)] = torch.tensor(cand, dtype=torch.long)
            candidate_token_mask[i, j, :len(cand)] = 1
        labels[i] = b["label"]

    return {
        "sentence_ids": sentence_ids,
        "sentence_mask": sentence_mask,
        "candidate_ids": candidate_ids,
        "candidate_token_mask": candidate_token_mask,
        "candidate_mask": candidate_mask,
        "labels": labels,
    }
