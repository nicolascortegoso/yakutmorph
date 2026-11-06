"""
Exports the trained DualEncoderReranker to ONNX, so it can be run at
inference time via onnxruntime (~80MB installed: ~60MB onnxruntime + ~20MB
numpy) instead of torch (~339MB) — see the README/nir/disambiguation.md
discussion on lightweight deployment.
"""
import json
import shutil
import sys
from pathlib import Path

import torch

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dataset import Vocabs
from model import DualEncoderReranker

CKPT_DIR = Path(__file__).resolve().parents[1] / "checkpoints"
TOKENIZER_DIR = Path(__file__).resolve().parents[1] / "tokenizer"
OUT_PATH = TOKENIZER_DIR / "reranker.onnx"
PACKAGE_DATA_DIR = Path(__file__).resolve().parents[2] / "yakutmorph" / "data"


def main():
    vocabs = Vocabs()
    model = DualEncoderReranker(
        input_vocab_size=vocabs.sp_input.vocab_size(),
        candidate_vocab_size=vocabs.candidate_vocab_size,
    )
    model.load_state_dict(torch.load(CKPT_DIR / "best.pt", map_location="cpu"))
    model.eval()

    # A small, representative dummy batch: batch=1, sentence length 6,
    # 3 candidates each of length 4. Only used to trace shapes; dynamic_axes
    # below lets every one of these vary at inference time.
    sentence_ids = torch.randint(4, 100, (1, 6))
    sentence_mask = torch.ones(1, 6)
    candidate_ids = torch.randint(4, 100, (1, 3, 4))
    candidate_token_mask = torch.ones(1, 3, 4)
    candidate_mask = torch.ones(1, 3)

    torch.onnx.export(
        model,
        (sentence_ids, sentence_mask, candidate_ids, candidate_token_mask, candidate_mask),
        str(OUT_PATH),
        input_names=["sentence_ids", "sentence_mask", "candidate_ids", "candidate_token_mask", "candidate_mask"],
        output_names=["scores"],
        dynamic_axes={
            "sentence_ids": {0: "batch", 1: "sentence_len"},
            "sentence_mask": {0: "batch", 1: "sentence_len"},
            "candidate_ids": {0: "batch", 1: "num_candidates", 2: "candidate_len"},
            "candidate_token_mask": {0: "batch", 1: "num_candidates", 2: "candidate_len"},
            "candidate_mask": {0: "batch", 1: "num_candidates"},
            "scores": {0: "batch", 1: "num_candidates"},
        },
        opset_version=17,
        # The TorchScript-based exporter: torch.export (the default since
        # torch 2.9) cannot trace this model's dynamic padding.
        dynamo=False,
    )
    print(f"Exported to {OUT_PATH}")

    # The tag ids are part of the model: the library needs the exact
    # mapping the weights were trained with.
    tag_vocab_path = TOKENIZER_DIR / "tag_vocab.json"
    tag_vocab_path.write_text(json.dumps(vocabs.tag_to_id, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"Wrote {tag_vocab_path}")

    if "--install" in sys.argv:
        files = {
            OUT_PATH: "reranker.onnx",
            TOKENIZER_DIR / "spm_input.model": "spm_input.model",
            TOKENIZER_DIR / "spm_candidate.model": "spm_candidate.model",
            tag_vocab_path: "candidate_tag_vocab.json",
        }
        for source, name in files.items():
            shutil.copyfile(source, PACKAGE_DATA_DIR / name)
            print(f"Installed {PACKAGE_DATA_DIR / name}")


if __name__ == "__main__":
    main()
