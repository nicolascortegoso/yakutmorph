#!/usr/bin/env python3
"""
Builds yakutmorph/data/corpus.jsonl.gz, the snapshot of the annotated corpus
that yakutmorph.corpus (and the MCP tool find_examples) searches.

Run before a release, against a clean checkout of yakutmorph_dataset's main:

    uv run python scripts/build_corpus_snapshot.py [path/to/yakutmorph_dataset]

The default path is ./yakutmorph_dataset. Also writes corpus_info.json with
the corpus commit and the number of sentences.
"""
import datetime
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from yakutmorph.corpus import records_from_dataset, write_snapshot  # noqa: E402

DATA_DIR = REPO_ROOT / "yakutmorph" / "data"


def git(directory, *args):
    return subprocess.run(["git", "-C", str(directory), *args], capture_output=True, text=True).stdout.strip()


def main():
    dataset = Path(sys.argv[1] if len(sys.argv) > 1 else REPO_ROOT / "yakutmorph_dataset").resolve()
    if git(dataset, "status", "--porcelain", "--untracked-files=no", "--", "*/processed/*"):
        sys.exit(f"{dataset} has uncommitted changes in its annotations; commit or stash them first.")
    n = write_snapshot(records_from_dataset(dataset), DATA_DIR / "corpus.jsonl.gz")
    info = {
        "corpus": "https://github.com/nicolascortegoso/yakutmorph_dataset",
        "commit": git(dataset, "rev-parse", "HEAD"),
        "branch": git(dataset, "rev-parse", "--abbrev-ref", "HEAD"),
        "built": datetime.date.today().isoformat(),
        "sentences": n,
        "license": "Apache-2.0",
    }
    (DATA_DIR / "corpus_info.json").write_text(json.dumps(info, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(info, indent=1))


if __name__ == "__main__":
    main()
