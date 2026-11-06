"""
Capacity sanity check: can the model drive accuracy to ~100% on a small,
fixed subset of training data with dropout disabled? If not, that points at
an architecture/capacity or implementation problem rather than a genuine
generalization limit — the standard "overfit a small batch" debugging trick.
"""
import sys
from pathlib import Path

import torch
import torch.nn as nn

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dataset import RerankerDataset, Vocabs, collate
from model import DualEncoderReranker

N_EXAMPLES = 300
EPOCHS = 150


def main():
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    vocabs = Vocabs()
    full_train = RerankerDataset("train", vocabs)
    subset = torch.utils.data.Subset(full_train, range(N_EXAMPLES))
    loader = torch.utils.data.DataLoader(subset, batch_size=32, shuffle=True, collate_fn=collate)

    model = DualEncoderReranker(
        input_vocab_size=vocabs.sp_input.vocab_size(),
        candidate_vocab_size=vocabs.candidate_vocab_size,
        embed_size=64, hidden_size=128, dropout=0.0,
    ).to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    criterion = nn.CrossEntropyLoss()

    for epoch in range(1, EPOCHS + 1):
        model.train()
        total_loss = correct = total = 0
        for batch in loader:
            batch = {k: v.to(device) for k, v in batch.items()}
            optimizer.zero_grad()
            scores = model(batch["sentence_ids"], batch["sentence_mask"],
                            batch["candidate_ids"], batch["candidate_token_mask"],
                            batch["candidate_mask"])
            loss = criterion(scores, batch["labels"])
            loss.backward()
            optimizer.step()
            total_loss += loss.item() * len(batch["labels"])
            correct += (scores.argmax(-1) == batch["labels"]).sum().item()
            total += len(batch["labels"])
        if epoch % 10 == 0 or epoch == 1:
            print(f"epoch {epoch:3d} | loss {total_loss/total:.4f} | train acc {correct/total:.4f}")


if __name__ == "__main__":
    main()
