#!/bin/bash
# Materialize the verification workspace: an UNMODIFIED checkout of openai/math's lean/ directory at the commit
# pinned in lean/OAI_PIN, with this repository's 29 chain modules and its check files copied into its root and the
# lean_lib stanzas of lean/lakefile-stanza.lean appended to OpenAI's lakefile. OpenAI's lakefile has to stay the
# workspace root (its hooks patch 23 dependency packages before Lake resolves them), so this is the way in.
#
#   scripts/materialize.sh                     # clone openai/math at the pin into work/oai (network)
#   scripts/materialize.sh --from-local DIR    # copy an existing checkout DIR of openai/math's lean/ instead
#                                              # (checked file by file against a git clone in $OAI_GIT)
#   scripts/materialize.sh --check-island      # also re-derive lean/island/ from the dbn island at
#                                              # provenance/ISLAND_SOURCE plus lean/patches/ (network)
# Then, from work/oai:
#   lake update && ../../scripts/check_manifest.sh && lake exe cache get
#                                              # lake update can rewrite the manifest: the check stops unless it is
#                                              # still OpenAI's pinned one (manifest_md5 in lean/OAI_PIN)
#   lake build RDDBNIsland RDDBNGen RDDBNGauss RDDBNMain RDDBNNegativeControl
#   lake env lean BbOaiMeaningCheck.lean       # axioms [propext, Classical.choice, Quot.sound] for both conjuncts
#   lake env lean BbOaiMeaningRef.lean         # the bridge statement in pp.all, WITHOUT OpenAI in the environment
#   lake env lean BbOaiMeaningTamper.lean      # must FAIL with 3 errors
#   lake env lean BbOaiRealPrimTamper.lean     # must FAIL with 2 errors
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
. "$HERE/lean/OAI_PIN"
WORK="$HERE/work/oai"
md5of() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }

"$HERE/scripts/verify_md5.sh" lean

mkdir -p "$HERE/work"
CHECK_ISLAND=0; FROM_LOCAL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --from-local) FROM_LOCAL="$2"; shift 2;;
    --check-island) CHECK_ISLAND=1; shift;;
    *) echo "unknown argument: $1"; exit 1;;
  esac
done

if [ -n "$FROM_LOCAL" ]; then
  GIT="${OAI_GIT:-$HOME/oai-math}"
  [ "$(git -C "$GIT" rev-parse HEAD)" = "$commit" ] || { echo "OAI_GIT is not at $commit"; exit 1; }
  diff -rq "$GIT/$subdir" "$FROM_LOCAL" -x .lake -x .git -x replay_configs -x replay_logs \
       -x REPLAY_REPORT.md -x ReplayChecks || { echo "source tree differs from $commit"; exit 1; }
  rm -rf "$WORK"; cp -c -R "$FROM_LOCAL" "$WORK" 2>/dev/null || cp -R "$FROM_LOCAL" "$WORK"
else
  rm -rf "$HERE/work/math"
  git clone --no-checkout "$repo" "$HERE/work/math"
  git -C "$HERE/work/math" checkout --detach "$commit"
  rm -rf "$WORK"; mv "$HERE/work/math/$subdir" "$WORK"
fi

# OpenAI's tree must be exactly the one the auditor built against.
[ "$(md5of "$WORK/lakefile.lean")" = "$lakefile_md5" ] || { echo "lakefile.lean differs from the pin"; exit 1; }
[ "$(md5of "$WORK/lake-manifest.json")" = "$manifest_md5" ] || { echo "lake-manifest.json differs from the pin"; exit 1; }
[ "$(md5of "$WORK/lean-toolchain")" = "$toolchain_md5" ] || { echo "lean-toolchain differs from the pin"; exit 1; }
[ "$(cat "$WORK/lean-toolchain")" = "$toolchain" ] || { echo "toolchain mismatch"; exit 1; }
grep -q "\"rev\": \"$mathlib\"" "$WORK/lake-manifest.json" || { echo "mathlib pin mismatch"; exit 1; }
[ "$(md5of "$WORK/$nonvanishing_path")" = "$nonvanishing_md5" ] || { echo "$nonvanishing_path differs"; exit 1; }
[ "$(md5of "$WORK/$challenge_path")" = "$challenge_md5" ] || { echo "$challenge_path differs"; exit 1; }

# Our modules are flat (import GenDefs, import GaussSign, ...), so they go into the workspace root, as in the
# auditor's build tree. The rc3 audit checks are records at another pin and are not copied.
for d in island gen gauss main checks; do
  for f in "$HERE/lean/$d/"*.lean; do
    b="$(basename "$f")"
    [ -e "$WORK/$b" ] && { echo "module name collision with OpenAI's tree: $b"; exit 1; }
    cp "$f" "$WORK/$b"
  done
done
cat "$HERE/lean/lakefile-stanza.lean" >> "$WORK/lakefile.lean"

if [ "$CHECK_ISLAND" = 1 ]; then
  . "$HERE/provenance/ISLAND_SOURCE"
  rm -rf "$HERE/work/island"
  git clone --no-checkout "$source_repo" "$HERE/work/island"
  git -C "$HERE/work/island" checkout "$source_commit" -- "$source_dir"
  T="$HERE/work/island/$source_dir"
  for p in "$HERE"/lean/patches/*.patch; do (cd "$T" && patch -p1 --no-backup-if-mismatch < "$p"); done
  for m in $modules; do
    cmp -s "$T/$m.lean" "$HERE/lean/island/$m.lean" || { echo "island module differs from source + patches: $m"; exit 1; }
  done
  echo "lean/island/ = $source_repo @ $source_commit ($source_dir) + lean/patches/, byte for byte."
fi

echo "Materialized at $WORK (openai/math $commit, $toolchain, Mathlib $mathlib). See the header of this script for the next commands."
