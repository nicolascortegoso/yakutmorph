"""
Trains the dual-encoder reranker (paper_2027.md §4) and evaluates on dev
after every epoch, tracking ambiguous- and unambiguous-token accuracy
separately (§3.4 — unambiguous tokens are "free" and would otherwise
inflate an aggregate figure).
"""
import random
import sys
import time
from pathlib import Path

import torch
import torch.nn as nn

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dataset import RerankerDataset, Vocabs, collate
from model import DualEncoderReranker

CKPT_DIR = Path(__file__).resolve().parents[1] / "checkpoints"

EMBED_SIZE = 64
HIDDEN_SIZE = 128
DROPOUT = 0.3
BATCH_SIZE = 32
LR = 1e-3
EPOCHS = 15
SEED = 1


@torch.no_grad()
def evaluate(model, loader, device):
    model.eval()
    correct = ambiguous_total = ambiguous_correct = unambiguous_total = unambiguous_correct = 0
    for batch in loader:
        batch = {k: v.to(device) for k, v in batch.items()}
        scores = model(batch["sentence_ids"], batch["sentence_mask"],
                        batch["candidate_ids"], batch["candidate_token_mask"],
                        batch["candidate_mask"])
        preds = scores.argmax(dim=-1)
        n_candidates = batch["candidate_mask"].sum(dim=-1)
        is_correct = (preds == batch["labels"])
        correct += is_correct.sum().item()
        for i in range(len(preds)):
            if n_candidates[i] > 1:
                ambiguous_total += 1
                ambiguous_correct += is_correct[i].item()
            else:
                unambiguous_total += 1
                unambiguous_correct += is_correct[i].item()
    total = ambiguous_total + unambiguous_total
    return {
        "accuracy": correct / total,
        "ambiguous_accuracy": ambiguous_correct / max(1, ambiguous_total),
        "unambiguous_accuracy": unambiguous_correct / max(1, unambiguous_total),
        "n_ambiguous": ambiguous_total,
        "n_unambiguous": unambiguous_total,
    }


def main():
    seed = int(sys.argv[sys.argv.index("--seed") + 1]) if "--seed" in sys.argv else SEED
    torch.manual_seed(seed)
    random.seed(seed)
    print(f"Seed: {seed}")
    device = torch.device("mps" if torch.backends.mps.is_available()
                           else "cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {device}")

    vocabs = Vocabs()
    train_ds = RerankerDataset("train", vocabs)
    dev_ds = RerankerDataset("dev", vocabs)
    test_ds = RerankerDataset("test", vocabs)

    train_loader = torch.utils.data.DataLoader(
        train_ds, batch_size=BATCH_SIZE, shuffle=True, collate_fn=collate)
    dev_loader = torch.utils.data.DataLoader(
        dev_ds, batch_size=BATCH_SIZE, shuffle=False, collate_fn=collate)
    test_loader = torch.utils.data.DataLoader(
        test_ds, batch_size=BATCH_SIZE, shuffle=False, collate_fn=collate)

    model = DualEncoderReranker(
        input_vocab_size=vocabs.sp_input.vocab_size(),
        candidate_vocab_size=vocabs.candidate_vocab_size,
        embed_size=EMBED_SIZE, hidden_size=HIDDEN_SIZE, dropout=DROPOUT,
    ).to(device)
    print(f"Parameters: {sum(p.numel() for p in model.parameters()):,}")

    optimizer = torch.optim.Adam(model.parameters(), lr=LR)
    criterion = nn.CrossEntropyLoss()

    CKPT_DIR.mkdir(parents=True, exist_ok=True)
    best_dev_acc = 0.0
    log_lines = []

    for epoch in range(1, EPOCHS + 1):
        model.train()
        t0 = time.time()
        total_loss = 0.0
        for batch in train_loader:
            batch = {k: v.to(device) for k, v in batch.items()}
            optimizer.zero_grad()
            scores = model(batch["sentence_ids"], batch["sentence_mask"],
                            batch["candidate_ids"], batch["candidate_token_mask"],
                            batch["candidate_mask"])
            loss = criterion(scores, batch["labels"])
            loss.backward()
            optimizer.step()
            total_loss += loss.item() * len(batch["labels"])

        train_loss = total_loss / len(train_ds)
        dev_metrics = evaluate(model, dev_loader, device)
        elapsed = time.time() - t0
        line = (f"epoch {epoch:2d} | loss {train_loss:.4f} | "
                f"dev acc {dev_metrics['accuracy']:.4f} "
                f"(ambig {dev_metrics['ambiguous_accuracy']:.4f}/{dev_metrics['n_ambiguous']}, "
                f"unambig {dev_metrics['unambiguous_accuracy']:.4f}/{dev_metrics['n_unambiguous']}) "
                f"| {elapsed:.1f}s")
        print(line)
        log_lines.append(line)

        if dev_metrics["accuracy"] > best_dev_acc:
            best_dev_acc = dev_metrics["accuracy"]
            torch.save(model.state_dict(), CKPT_DIR / "best.pt")

    model.load_state_dict(torch.load(CKPT_DIR / "best.pt"))
    test_metrics = evaluate(model, test_loader, device)
    result = (f"\nBest dev accuracy: {best_dev_acc:.4f}\n"
              f"Test accuracy: {test_metrics['accuracy']:.4f} "
              f"(ambiguous {test_metrics['ambiguous_accuracy']:.4f} / {test_metrics['n_ambiguous']}, "
              f"unambiguous {test_metrics['unambiguous_accuracy']:.4f} / {test_metrics['n_unambiguous']})\n")
    print(result)
    log_lines.append(result)
    (CKPT_DIR / "train_log.txt").write_text("\n".join(log_lines), encoding="utf-8")


if __name__ == "__main__":
    main()
