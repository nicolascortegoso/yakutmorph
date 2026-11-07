#!/usr/bin/env bash
# Periodic release of yakutmorph: retrains the disambiguation model on the
# current lexicon, transducers and annotated corpus, and publishes a new
# version. For the daily lexicon/rule work, use ./rebuild.sh instead.
#
#   ./release.sh 0.3.0              # full release
#   ./release.sh 0.3.0 --dry-run    # everything up to the comparison, then put the old model back
#   options: --seeds N (default 3)  --skip-rebuild  --max-drop 1.0 (points of ambiguous accuracy)
#            --no-checks (skip step 1, for testing the script; implies --dry-run)
#
# Steps:
#   1. checks: yakutmorph on main with no uncommitted changes; the corpus
#      (yakutmorph_dataset) on main, up to date with GitHub, no uncommitted annotations
#   2. ./rebuild.sh (lexicon, transducer, tests); stops if that changes committed files
#   3. report of annotations whose notation no longer matches the transducer (changes nothing)
#   4. stable train/dev/test split, then the training data
#   5. accuracy of the installed model on the test set (the reference)
#   6. tokenizers and N training runs (seeds 1..N); the best on dev is kept
#   7. the new model is installed and evaluated; if it is worse than the reference
#      by more than --max-drop points on ambiguous words, the old model is put back and the release stops
#   8. corpus snapshot for find_examples, tests
#   9. version, changelog, commit, push, wait for CI, tag; the tag publishes to PyPI
#      (.github/workflows/publish.yml), or prints the upload command if that is not set up
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:-}"
shift || true
SEEDS=3; DRY_RUN=0; REBUILD=1; MAX_DROP=1.0; CHECKS=1
while [ $# -gt 0 ]; do
  case "$1" in
    --seeds) SEEDS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --skip-rebuild) REBUILD=0; shift ;;
    --max-drop) MAX_DROP="$2"; shift 2 ;;
    --no-checks) CHECKS=0; DRY_RUN=1; shift ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
done

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
fail() { printf '\n\033[31mStopped: %s\033[0m\n' "$*"; exit 1; }
PY=".venv/bin/python"
RUN_TRAIN="uv run -q --group train"
DM=disambiguation_model
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ---------------------------------------------------------------- 1. checks
step "1. Checks"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "give the new version, e.g. ./release.sh 0.3.0"
CURRENT=$(sed -n 's/^version = "\(.*\)"$/\1/p' pyproject.toml)
$PY -c "import sys; v=lambda s: tuple(map(int, s.split('.'))); sys.exit(v('$VERSION') <= v('$CURRENT'))" \
  || fail "the new version ($VERSION) must be higher than the current one ($CURRENT)"
CORPUS=yakutmorph_dataset
# Files this script regenerates itself (steps 4 and 6). An interrupted run
# leaves them changed; they are rebuilt below, so they don't block a new run.
GENERATED=("$DM/data/split.tsv" "$DM/data/prepare_report.md" "$DM/tokenizer/tokenizer_report.md")
EXCLUDE=(); for f in "${GENERATED[@]}"; do EXCLUDE+=(":(exclude)$f"); done
if [ $CHECKS = 1 ]; then
[ "$(git branch --show-current)" = main ] || fail "yakutmorph is not on main"
git diff --quiet -- . "${EXCLUDE[@]}" && git diff --cached --quiet \
  || fail "yakutmorph has uncommitted changes; commit your lexicon/transducer work first: $(git diff --name-only -- . "${EXCLUDE[@]}" | tr '\n' ' ')"
git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null && fail "tag v$VERSION already exists"
git fetch -q origin
[ "$(git rev-parse main)" = "$(git rev-parse origin/main)" ] || fail "yakutmorph main differs from GitHub (push or pull first)"
[ "$(git -C $CORPUS branch --show-current)" = main ] || fail "the corpus ($CORPUS) is not on main"
git -C $CORPUS fetch -q origin
[ "$(git -C $CORPUS rev-parse main)" = "$(git -C $CORPUS rev-parse origin/main)" ] \
  || fail "the corpus main differs from GitHub (push or pull it first)"
[ -z "$(git -C $CORPUS status --porcelain -- '*/processed/*')" ] \
  || fail "the corpus has annotation files that are not committed: $(git -C $CORPUS status --porcelain -- '*/processed/*' | awk '{print $2}' | tr '\n' ' ')"
else
  echo "checks skipped (--no-checks): dry run"
fi
CORPUS_COMMIT=$(git -C $CORPUS rev-parse --short HEAD)
echo "yakutmorph $CURRENT -> $VERSION; corpus at $CORPUS_COMMIT; $SEEDS training runs$([ $DRY_RUN = 1 ] && echo '; dry run')"

# ---------------------------------------------------------------- 2. rebuild
if [ $REBUILD = 1 ]; then
  step "2. Rebuilding lexicon and transducer"
  ./rebuild.sh
  git diff --quiet -- . "${EXCLUDE[@]}" || fail "rebuilding changed committed files (lexicon or transducer were not rebuilt/committed after your last edit): $(git diff --name-only -- . "${EXCLUDE[@]}" | tr '\n' ' ')"
else
  step "2. Rebuild skipped"
fi

# ---------------------------------------------------------------- 3. notation report
step "3. Annotations whose notation no longer matches the transducer (report only)"
$PY $DM/scripts/update_corpus_notation.py --report $DM/data/notation_report.tsv 2>/dev/null | grep -v '^Rules:' || true

# ---------------------------------------------------------------- 4. data
step "4. Split and training data"
$PY $DM/scripts/update_split.py
$RUN_TRAIN python $DM/scripts/prepare_dataset.py 2>/dev/null | sed -n '/## Kept data/,$p'

# ---------------------------------------------------------------- 5. reference
step "5. Installed model on the test set (reference)"
$PY $DM/scripts/evaluate_library.py test --json 2>/dev/null > "$WORK/before.json" \
  || fail "the library's candidates no longer match the training data: $(cat "$WORK/before.json")"
cat "$WORK/before.json"

# ---------------------------------------------------------------- 6. training
step "6. Tokenizers and $SEEDS training runs"
$RUN_TRAIN python $DM/scripts/train_tokenizer.py 2>/dev/null | grep 'Selected' || true
BEST_SEED=""; BEST_DEV=-1
for seed in $(seq 1 "$SEEDS"); do
  dir="$DM/checkpoints/seed_$seed"
  $RUN_TRAIN python -u $DM/scripts/train.py --seed "$seed" --checkpoint-dir "$dir" 2>/dev/null | tail -3
  dev=$(sed -n 's/^Best dev accuracy: //p' "$dir/train_log.txt")
  echo "seed $seed: dev accuracy $dev"
  if $PY -c "import sys; sys.exit(not $dev > $BEST_DEV)"; then BEST_SEED=$seed; BEST_DEV=$dev; fi
done
echo "kept seed $BEST_SEED (dev accuracy $BEST_DEV)"

# ---------------------------------------------------------------- 7. install and compare
step "7. Installing the new model and comparing"
MODEL_FILES="reranker.onnx spm_input.model spm_candidate.model candidate_tag_vocab.json"
mkdir -p "$WORK/old_model"
for f in $MODEL_FILES; do cp "yakutmorph/data/$f" "$WORK/old_model/"; done
restore() { for f in $MODEL_FILES; do cp "$WORK/old_model/$f" "yakutmorph/data/$f"; done; }
$RUN_TRAIN python $DM/scripts/export_onnx.py --checkpoint-dir "$DM/checkpoints/seed_$BEST_SEED" --install 2>/dev/null | grep Installed || true
$PY $DM/scripts/evaluate_library.py test --json 2>/dev/null > "$WORK/after.json" || { restore; fail "evaluation of the new model failed"; }
read -r BEFORE AFTER BASELINE <<< "$($PY -c "
import json
b, a = json.load(open('$WORK/before.json')), json.load(open('$WORK/after.json'))
print(round(100 * b['ambiguous_accuracy'], 2), round(100 * a['ambiguous_accuracy'], 2), round(100 * a['baseline_ambiguous_accuracy'], 2))")"
echo "ambiguous test words: installed model $BEFORE%, new model $AFTER% (most-frequent baseline $BASELINE%)"
if $PY -c "import sys; sys.exit(not $AFTER < $BEFORE - $MAX_DROP)"; then
  restore
  fail "the new model is worse than the installed one by more than $MAX_DROP points; the installed model was put back"
fi
if [ $DRY_RUN = 1 ]; then
  restore
  echo "Dry run: the installed model was put back. Nothing was committed."
  exit 0
fi
cp "$DM/checkpoints/seed_$BEST_SEED/train_log.txt" "$DM/checkpoints/train_log.txt"
cp "$DM/checkpoints/seed_$BEST_SEED/best.pt" "$DM/checkpoints/best.pt"
for s in test dev; do $PY $DM/scripts/evaluate_library.py $s 2>/dev/null > "$DM/data/evaluation_$s.md" || true; done

# ---------------------------------------------------------------- 8. snapshot and tests
step "8. Corpus snapshot and tests"
$PY scripts/build_corpus_snapshot.py $CORPUS >/dev/null
SENTENCES=$($PY -c "import json; print(json.load(open('yakutmorph/data/corpus_info.json'))['sentences'])")
uv run -q --group dev pytest -q 2>&1 | tail -1
uv run -q --group dev pytest -q >/dev/null 2>&1 || fail "tests fail with the new model (nothing committed; see 'uv run --group dev pytest')"

# ---------------------------------------------------------------- 9. publish
step "9. Version $VERSION: commit, push, CI, tag"
PREVIOUS_TAG="v$CURRENT"
$PY - "$VERSION" "$BEFORE" "$AFTER" "$BASELINE" "$CORPUS_COMMIT" "$SENTENCES" "$PREVIOUS_TAG" <<'EOF'
import datetime, re, subprocess, sys
version, before, after, baseline, corpus, sentences, previous = sys.argv[1:]
rules = subprocess.run(['git', 'log', '--oneline', f'{previous}..HEAD', '--', 'src', 'yakutmorph/fsts'],
                       capture_output=True, text=True).stdout.strip().splitlines()
notes = [
    f'- Disambiguation model retrained on the current lexicon, transducers and corpus: '
    f'{after}% of ambiguous test words correct (previous model {before}%, '
    f'most-frequent baseline {baseline}%).',
    f'- Corpus snapshot for `find_examples`: yakutmorph_dataset {corpus}, {sentences} sentences.',
]
if rules:
    notes.append(f'- Lexicon and transducer changes: {len(rules)} commit(s) since {previous}.')
text = open('CHANGELOG.md', encoding='utf-8').read()
head = f'## {version} ({datetime.date.today().isoformat()})'
if '## Unreleased' in text:
    start = text.index('## Unreleased')
    end = text.find('\n## ', start + 1)
    end = len(text) if end < 0 else end
    section = text[start:end].replace('## Unreleased', head, 1).rstrip() + '\n\n### Model and data\n' + '\n'.join(notes) + '\n\n'
    text = text[:start] + section + text[end:].lstrip('\n')
else:
    text = text.replace('# Changelog\n\n', f'# Changelog\n\n{head}\n\n### Model and data\n' + '\n'.join(notes) + '\n\n', 1)
open('CHANGELOG.md', 'w', encoding='utf-8').write(text)
p = open('pyproject.toml').read()
open('pyproject.toml', 'w').write(re.sub(r'^version = ".*"$', f'version = "{version}"', p, count=1, flags=re.M))
EOF
uv lock -q
git add pyproject.toml uv.lock CHANGELOG.md yakutmorph/data $DM/data/split.tsv $DM/data/prepare_report.md \
  $DM/data/evaluation_test.md $DM/data/evaluation_dev.md $DM/checkpoints/train_log.txt \
  $DM/tokenizer/tag_vocab.json $DM/tokenizer/tokenizer_report.md
git commit -q -m "Release $VERSION" -m "Disambiguation model: $AFTER% of ambiguous test words (previous $BEFORE%). Corpus $CORPUS_COMMIT, $SENTENCES sentences."
git push -q origin main
SHA=$(git rev-parse HEAD)
echo "pushed $(git rev-parse --short HEAD); waiting for CI ..."
$PY - "$SHA" <<'EOF' || fail "CI did not pass for $(git rev-parse --short HEAD); fix it, then tag with: git tag -a v$VERSION -m v$VERSION && git push origin v$VERSION"
import json, sys, time, urllib.request
api = 'https://api.github.com/repos/nicolascortegoso/yakutmorph/actions/runs'
def get(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)
for _ in range(120):
    runs = [r for r in get(f'{api}?head_sha={sys.argv[1]}').get('workflow_runs', []) if r['name'] == 'tests']
    if runs and runs[0]['status'] == 'completed':
        print('CI:', runs[0]['conclusion'], runs[0]['html_url'])
        sys.exit(runs[0]['conclusion'] != 'success')
    time.sleep(30)
sys.exit('CI did not finish within an hour')
EOF
git tag -a "v$VERSION" -m "yakutmorph $VERSION"
git push -q origin "v$VERSION"
step "Done"
echo "Tagged v$VERSION. If Trusted Publishing is set up on PyPI, the 'publish' workflow uploads the release:"
echo "  https://github.com/nicolascortegoso/yakutmorph/actions/workflows/publish.yml"
echo "Otherwise upload it yourself (username __token__, your PyPI token as password):"
echo "  rm -rf dist && uv build && uvx twine upload dist/yakutmorph-$VERSION*"
