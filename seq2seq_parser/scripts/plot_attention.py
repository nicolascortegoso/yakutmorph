#!/usr/bin/env python3
"""Plot the encoder-decoder attention matrix for one sentence, greedy-decoded
with the trained model — source subword pieces on one axis, predicted target
subword pieces on the other, cell shade = attention weight.

Usage:
    ./.venv/bin/python scripts/plot_attention.py --sah "Ама да, ..." --out attention_plots/example.png
    ./.venv/bin/python scripts/plot_attention.py --split test --index 42 --ckpt-dir checkpoints_sepvocab
"""
import argparse
import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import sentencepiece as spm
import torch

from model import Seq2Seq, PAD_ID, UNK_ID, EOS_ID
from text_utils import normalize_text

DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def load_model(ckpt_dir):
    ckpt_dir = Path(__file__).resolve().parents[1] / ckpt_dir
    config = json.loads((ckpt_dir / "config.json").read_text())
    src_tok = config.get("src_tokenizer", "spm_src")
    tgt_tok = config.get("tgt_tokenizer", "spm_tgt")
    sp_src = spm.SentencePieceProcessor(model_file=str(DATA_DIR / "tokenizer" / f"{src_tok}.model"))
    sp_tgt = spm.SentencePieceProcessor(model_file=str(DATA_DIR / "tokenizer" / f"{tgt_tok}.model"))
    device = torch.device("mps") if torch.backends.mps.is_available() else torch.device("cpu")
    model = Seq2Seq(config["src_vocab_size"], config["tgt_vocab_size"], config["emb_dim"],
                     config["hid_dim"], config["n_layers"], config["dropout"]).to(device)
    model.load_state_dict(torch.load(ckpt_dir / "best.pt", map_location=device))
    model.eval()
    return model, sp_src, sp_tgt, device


def plot_one(model, sp_src, sp_tgt, device, sah, gold=None, out_path="attention.png", max_len=100):
    sah_norm = normalize_text(sah)
    src_pieces = sp_src.encode(sah_norm, out_type=str)
    src_ids = sp_src.encode(sah_norm, out_type=int) + [EOS_ID]
    src_pieces = src_pieces + ["</s>"]

    # same surface-string matching used in dataset.py: which source pieces
    # are copyable (exist verbatim in the target vocabulary)?
    src_tgt_map_list = [sp_tgt.piece_to_id(p) if sp_tgt.piece_to_id(p) != UNK_ID or p == "<unk>" else -1
                         for p in src_pieces]

    src = torch.tensor([src_ids], dtype=torch.long, device=device)
    src_len = torch.tensor([len(src_ids)], dtype=torch.long)
    src_tgt_map = torch.tensor([src_tgt_map_list], dtype=torch.long, device=device)

    pred_ids, attn = model.greedy_decode_with_attention(src, src_len, src_tgt_map, max_len=max_len)
    pred_ids = pred_ids[0].tolist()
    attn = attn[0].cpu().numpy()  # (T, S)

    # trim to before EOS/PAD, keep the EOS step itself so the plot shows where it stopped
    T = 0
    for t, tok in enumerate(pred_ids):
        T += 1
        if tok in (EOS_ID, PAD_ID):
            break
    pred_ids = pred_ids[:T]
    attn = attn[:T]
    tgt_pieces = [sp_tgt.id_to_piece(t) for t in pred_ids]

    pred_text = sp_tgt.decode([t for t in pred_ids if t not in (PAD_ID, EOS_ID)])

    fig_w = max(6, 0.45 * len(src_pieces))
    fig_h = max(4, 0.4 * len(tgt_pieces))
    fig, ax = plt.subplots(figsize=(fig_w, fig_h))
    im = ax.imshow(attn, aspect="auto", cmap="viridis", vmin=0, vmax=attn.max())
    ax.set_xticks(range(len(src_pieces)))
    ax.set_xticklabels(src_pieces, rotation=60, ha="right", fontsize=9)
    ax.set_yticks(range(len(tgt_pieces)))
    ax.set_yticklabels(tgt_pieces, fontsize=9)
    ax.set_xlabel("source pieces (encoder input)")
    ax.set_ylabel("predicted pieces (decoder output)")
    fig.colorbar(im, ax=ax, label="attention weight")

    title = f"sah: {sah}\npred: {pred_text}"
    if gold:
        title += f"\ngold: {gold}"
    ax.set_title(title, fontsize=10, wrap=True)

    fig.tight_layout()
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    print(f"pred: {pred_text}")
    if gold:
        print(f"gold: {gold}")
    print(f"saved to {out_path}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ckpt-dir", default="checkpoints_sepvocab")
    ap.add_argument("--sah", default=None, help="a raw Yakut sentence to visualize directly")
    ap.add_argument("--split", choices=["dev", "test"], default=None, help="pull an example from this split instead")
    ap.add_argument("--index", type=int, default=0, help="index within --split")
    ap.add_argument("--out", default=None)
    args = ap.parse_args()

    model, sp_src, sp_tgt, device = load_model(args.ckpt_dir)

    if args.sah:
        sah, gold = args.sah, None
        out = args.out or "attention_plots/custom.png"
    else:
        split = args.split or "test"
        records = [json.loads(l) for l in (DATA_DIR / f"{split}.jsonl").read_text(encoding="utf-8").splitlines()]
        r = records[args.index]
        sah, gold = r["sah"], normalize_text(r["target"])
        out = args.out or f"attention_plots/{split}_{args.index}.png"

    plot_one(model, sp_src, sp_tgt, device, sah, gold, out)


if __name__ == "__main__":
    main()
