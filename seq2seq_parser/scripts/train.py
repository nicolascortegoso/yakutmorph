#!/usr/bin/env python3
"""Train the BiGRU encoder / Luong-attention decoder seq2seq morphological
parser (with copy/pointer mechanism, see model.py) on
seq2seq_parser/data/{train,dev}.jsonl."""
import argparse
import json
import time
from pathlib import Path

import sentencepiece as spm
import torch
from torch.utils.data import DataLoader

from dataset import ParsingDataset, BucketBatchSampler, collate_fn, PAD_ID
from model import Seq2Seq

DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def pick_device(requested):
    if requested != "auto":
        return torch.device(requested)
    if torch.backends.mps.is_available():
        return torch.device("mps")
    if torch.cuda.is_available():
        return torch.device("cuda")
    return torch.device("cpu")


def nll_loss(probs, tgt_out, pad_id, eps=1e-9):
    """Negative log-likelihood against the model's own probability mixture
    (generate+copy — already properly combined in model.py, so this is NOT
    the same as CrossEntropyLoss, which would incorrectly re-softmax it)."""
    log_probs = torch.log(probs.clamp_min(eps))  # (B, T, V)
    nll = -log_probs.gather(2, tgt_out.unsqueeze(-1)).squeeze(-1)  # (B, T)
    mask = (tgt_out != pad_id).float()
    return (nll * mask).sum() / mask.sum().clamp_min(1)


def token_accuracy(probs, tgt_out):
    """Teacher-forced next-token accuracy, ignoring PAD positions."""
    pred = probs.argmax(dim=-1)
    mask = tgt_out != PAD_ID
    correct = ((pred == tgt_out) & mask).sum().item()
    total = mask.sum().item()
    return correct, total


def run_epoch(model, loader, optimizer, device, teacher_forcing_ratio, train):
    model.train(train)
    total_loss, total_correct, total_tokens, n_batches = 0.0, 0, 0, 0

    for batch in loader:
        src = batch["src"].to(device)
        src_len = batch["src_len"]
        src_tgt_map = batch["src_tgt_map"].to(device)
        tgt_in = batch["tgt_in"].to(device)
        tgt_out = batch["tgt_out"].to(device)

        with torch.set_grad_enabled(train):
            probs = model(src, src_len, src_tgt_map, tgt_in,
                          teacher_forcing_ratio=teacher_forcing_ratio if train else 0.0)
            loss = nll_loss(probs, tgt_out, PAD_ID)

        if train:
            optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

        correct, total = token_accuracy(probs, tgt_out)
        total_loss += loss.item()
        total_correct += correct
        total_tokens += total
        n_batches += 1

    return total_loss / n_batches, total_correct / total_tokens


def show_samples(model, dataset, sp_tgt, device, n=3):
    model.eval()
    idxs = list(range(min(n, len(dataset))))
    batch = collate_fn([dataset[i] for i in idxs])
    src = batch["src"].to(device)
    src_len = batch["src_len"]
    src_tgt_map = batch["src_tgt_map"].to(device)
    pred_ids = model.greedy_decode(src, src_len, src_tgt_map)
    lines = []
    for i, idx in enumerate(idxs):
        pred_tokens = [t for t in pred_ids[i].tolist() if t not in (PAD_ID, 3)]  # strip pad/eos
        pred_text = sp_tgt.decode(pred_tokens)
        gold_text = sp_tgt.decode(dataset[idx]["tgt_out"][:-1])  # strip eos
        lines.append(f"  sah:  {dataset.records[idx]['sah']}")
        lines.append(f"  gold: {gold_text}")
        lines.append(f"  pred: {pred_text}")
        lines.append("")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--emb-dim", type=int, default=256)
    ap.add_argument("--hid-dim", type=int, default=512)
    ap.add_argument("--n-layers", type=int, default=2)
    ap.add_argument("--dropout", type=float, default=0.3)
    ap.add_argument("--batch-size", type=int, default=64)
    ap.add_argument("--lr", type=float, default=1e-3)
    ap.add_argument("--epochs", type=int, default=30)
    ap.add_argument("--teacher-forcing", type=float, default=0.75)
    ap.add_argument("--patience", type=int, default=5, help="early stop after N epochs with no dev-loss improvement")
    ap.add_argument("--device", type=str, default="auto")
    ap.add_argument("--seed", type=int, default=13)
    ap.add_argument("--limit-train", type=int, default=None, help="debug: cap number of train examples")
    ap.add_argument("--ckpt-dir", type=str, default="checkpoints",
                     help="where to write checkpoints/logs (separate dirs keep ablations from overwriting each other)")
    ap.add_argument("--src-tokenizer", type=str, default="spm_src")
    ap.add_argument("--tgt-tokenizer", type=str, default="spm_tgt")
    args = ap.parse_args()

    torch.manual_seed(args.seed)
    device = pick_device(args.device)
    CKPT_DIR = Path(__file__).resolve().parents[1] / args.ckpt_dir
    CKPT_DIR.mkdir(exist_ok=True)

    sp_src = spm.SentencePieceProcessor(model_file=str(DATA_DIR / "tokenizer" / f"{args.src_tokenizer}.model"))
    sp_tgt = spm.SentencePieceProcessor(model_file=str(DATA_DIR / "tokenizer" / f"{args.tgt_tokenizer}.model"))
    src_vocab_size = sp_src.vocab_size()
    tgt_vocab_size = sp_tgt.vocab_size()

    train_ds = ParsingDataset(DATA_DIR / "train.jsonl", sp_src, sp_tgt)
    dev_ds = ParsingDataset(DATA_DIR / "dev.jsonl", sp_src, sp_tgt)
    if args.limit_train:
        train_ds.examples = train_ds.examples[:args.limit_train]
        train_ds.records = train_ds.records[:args.limit_train]

    train_loader = DataLoader(train_ds, batch_sampler=BucketBatchSampler(train_ds, args.batch_size, shuffle=True), collate_fn=collate_fn)
    dev_loader = DataLoader(dev_ds, batch_sampler=BucketBatchSampler(dev_ds, args.batch_size, shuffle=False), collate_fn=collate_fn)

    model = Seq2Seq(src_vocab_size, tgt_vocab_size, args.emb_dim, args.hid_dim, args.n_layers, args.dropout).to(device)
    n_params = sum(p.numel() for p in model.parameters())
    print(f"device={device} src_vocab={src_vocab_size} tgt_vocab={tgt_vocab_size} params={n_params:,} train={len(train_ds)} dev={len(dev_ds)}")

    optimizer = torch.optim.Adam(model.parameters(), lr=args.lr)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode="min", factor=0.5, patience=2)

    (CKPT_DIR / "config.json").write_text(json.dumps(
        vars(args) | {"src_vocab_size": src_vocab_size, "tgt_vocab_size": tgt_vocab_size}, indent=2))

    best_dev_loss = float("inf")
    epochs_no_improve = 0
    log_path = CKPT_DIR / "train_log.jsonl"
    log_f = open(log_path, "w")

    for epoch in range(1, args.epochs + 1):
        t0 = time.time()
        train_loss, train_acc = run_epoch(model, train_loader, optimizer, device, args.teacher_forcing, train=True)
        dev_loss, dev_acc = run_epoch(model, dev_loader, optimizer, device, 0.0, train=False)
        scheduler.step(dev_loss)
        dt = time.time() - t0

        row = {"epoch": epoch, "train_loss": train_loss, "train_acc": train_acc,
               "dev_loss": dev_loss, "dev_acc": dev_acc, "lr": optimizer.param_groups[0]["lr"], "seconds": dt}
        print(f"epoch {epoch:3d} | train loss {train_loss:.4f} acc {train_acc:.4f} | "
              f"dev loss {dev_loss:.4f} acc {dev_acc:.4f} | lr {row['lr']:.2e} | {dt:.1f}s")
        log_f.write(json.dumps(row) + "\n")
        log_f.flush()

        if dev_loss < best_dev_loss - 1e-4:
            best_dev_loss = dev_loss
            epochs_no_improve = 0
            torch.save(model.state_dict(), CKPT_DIR / "best.pt")
        else:
            epochs_no_improve += 1

        if epoch % 5 == 0 or epoch == 1:
            print(show_samples(model, dev_ds, sp_tgt, device))

        if epochs_no_improve >= args.patience:
            print(f"early stopping: no dev-loss improvement for {args.patience} epochs")
            break

    log_f.close()
    torch.save(model.state_dict(), CKPT_DIR / "last.pt")
    print(f"done. best dev loss={best_dev_loss:.4f}. checkpoints in {CKPT_DIR}")


if __name__ == "__main__":
    main()
