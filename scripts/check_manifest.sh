#!/bin/bash
# Run right after `lake update`: fail loudly unless the workspace's lake-manifest.json is still OpenAI's pinned
# manifest (manifest_md5 in lean/OAI_PIN). `lake update` can rewrite the manifest, and a rewritten manifest means
# the dependencies are no longer the ones the chain was checked against.
#
#   scripts/check_manifest.sh                     # checks work/oai/lake-manifest.json
#   scripts/check_manifest.sh path/to/lake-manifest.json
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
. "$HERE/lean/OAI_PIN"
M="${1:-$HERE/work/oai/lake-manifest.json}"
md5of() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }
[ -f "$M" ] || { echo "ERROR: no manifest at $M"; exit 1; }
got="$(md5of "$M")"
if [ "$got" != "$manifest_md5" ]; then
  echo "ERROR: $M has md5 $got, not OpenAI's pinned $manifest_md5."
  echo "       lake update rewrote the manifest; the dependency set is no longer the pinned one. Stop here."
  exit 1
fi
echo "lake-manifest.json is still OpenAI's pinned manifest ($manifest_md5)."
