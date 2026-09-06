"""Dataset, padding/collation, and length-bucketed batching for the seq2seq
morphological parser."""
import json
import random

import torch
from torch.utils.data import Dataset, Sampler

from text_utils import normalize_text

PAD_ID, UNK_ID, BOS_ID, EOS_ID = 0, 1, 2, 3


class ParsingDataset(Dataset):
    """Loads a jsonl split and pre-encodes every (sah, target) pair with two
    SEPARATE SentencePiece models — sp_src for the encoder input, sp_tgt for
    the decoder target — each fit to its own vocabulary. Small enough
    (<20k sentences) to hold fully tokenized in memory.

    Also precomputes `src_tgt_map`: for each source position, the target
    vocabulary id whose PIECE STRING is identical (or -1 if no such target
    piece exists). This is what makes the copy mechanism work despite the
    two vocabularies being trained independently — copying is matched by
    surface string, not by a shared id space. See model.py's Decoder.step.
    """

    def __init__(self, jsonl_path, sp_src, sp_tgt):
        self.records = [json.loads(l) for l in open(jsonl_path, encoding="utf-8")]
        # sentencepiece's piece_to_id returns UNK_ID for anything not in
        # vocab; build the reverse lookup explicitly so "maps to UNK" and
        # "genuinely is the <unk> piece" aren't confused.
        tgt_piece_to_id = {sp_tgt.id_to_piece(i): i for i in range(sp_tgt.vocab_size())}

        self.examples = []
        for r in self.records:
            src_ids = sp_src.encode(normalize_text(r["sah"]), out_type=int) + [EOS_ID]
            tgt_ids = sp_tgt.encode(normalize_text(r["target"]), out_type=int)
            tgt_in = [BOS_ID] + tgt_ids
            tgt_out = tgt_ids + [EOS_ID]
            src_tgt_map = [tgt_piece_to_id.get(sp_src.id_to_piece(i), -1) for i in src_ids]
            self.examples.append({
                "src": src_ids,
                "src_tgt_map": src_tgt_map,
                "tgt_in": tgt_in,
                "tgt_out": tgt_out,
                "id": r["id"],
                "has_unseen_root": r.get("has_unseen_root", False),
            })

    def __len__(self):
        return len(self.examples)

    def __getitem__(self, idx):
        return self.examples[idx]


def collate_fn(batch):
    src_lens = [len(ex["src"]) for ex in batch]
    tgt_lens = [len(ex["tgt_in"]) for ex in batch]
    max_src = max(src_lens)
    max_tgt = max(tgt_lens)

    src = torch.full((len(batch), max_src), PAD_ID, dtype=torch.long)
    src_tgt_map = torch.full((len(batch), max_src), -1, dtype=torch.long)
    tgt_in = torch.full((len(batch), max_tgt), PAD_ID, dtype=torch.long)
    tgt_out = torch.full((len(batch), max_tgt), PAD_ID, dtype=torch.long)

    for i, ex in enumerate(batch):
        src[i, :len(ex["src"])] = torch.tensor(ex["src"], dtype=torch.long)
        src_tgt_map[i, :len(ex["src_tgt_map"])] = torch.tensor(ex["src_tgt_map"], dtype=torch.long)
        tgt_in[i, :len(ex["tgt_in"])] = torch.tensor(ex["tgt_in"], dtype=torch.long)
        tgt_out[i, :len(ex["tgt_out"])] = torch.tensor(ex["tgt_out"], dtype=torch.long)

    return {
        "src": src,
        "src_tgt_map": src_tgt_map,
        "src_len": torch.tensor(src_lens, dtype=torch.long),
        "tgt_in": tgt_in,
        "tgt_out": tgt_out,
        "tgt_len": torch.tensor(tgt_lens, dtype=torch.long),
        "ids": [ex["id"] for ex in batch],
        "has_unseen_root": [ex["has_unseen_root"] for ex in batch],
    }


class BucketBatchSampler(Sampler):
    """Shuffle, then sort within local pools by source length so batches have
    similar lengths (less padding waste), and finally shuffle batch order so
    training doesn't see the same length-sorted curriculum every epoch."""

    def __init__(self, dataset, batch_size, pool_size_mult=50, shuffle=True):
        self.dataset = dataset
        self.batch_size = batch_size
        self.pool_size = batch_size * pool_size_mult
        self.shuffle = shuffle

    def __iter__(self):
        indices = list(range(len(self.dataset)))
        if self.shuffle:
            random.shuffle(indices)

        batches = []
        for pool_start in range(0, len(indices), self.pool_size):
            pool = indices[pool_start:pool_start + self.pool_size]
            pool.sort(key=lambda i: len(self.dataset[i]["src"]))
            for b_start in range(0, len(pool), self.batch_size):
                batches.append(pool[b_start:b_start + self.batch_size])

        if self.shuffle:
            random.shuffle(batches)
        yield from batches

    def __len__(self):
        return (len(self.dataset) + self.batch_size - 1) // self.batch_size
