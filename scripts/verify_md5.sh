#!/bin/bash
# Check the md5 manifests of this repository: every file listed in lean/MD5SUMS.txt, logs/MD5SUMS.txt and
# provenance/MD5SUMS.txt must have the recorded md5, and every file under lean/, logs/ and provenance/ must be listed;
# likewise for the auditor's two manifests in challenge/. Works with md5sum (Linux) or md5 (macOS).
#
#   scripts/verify_md5.sh            # all manifests
#   scripts/verify_md5.sh lean       # one of them (lean, logs, challenge or provenance)
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
md5of() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }
fail=0
for d in "${@:-lean logs provenance}"; do
  for dir in $d; do
    [ "$dir" = challenge ] && continue
    M="$HERE/$dir/MD5SUMS.txt"
    [ -f "$M" ] || { echo "missing manifest: $dir/MD5SUMS.txt"; fail=1; continue; }
    n=0
    while read -r h p; do
      [ -z "$h" ] && continue
      n=$((n + 1))
      if [ ! -f "$HERE/$dir/$p" ]; then echo "MISSING  $dir/$p"; fail=1
      elif [ "$(md5of "$HERE/$dir/$p")" != "$h" ]; then echo "MISMATCH $dir/$p"; fail=1; fi
    done < "$M"
    while IFS= read -r f; do
      rel="${f#"$HERE/$dir/"}"
      [ "$rel" = "MD5SUMS.txt" ] && continue
      grep -q "  $rel\$" "$M" || { echo "UNLISTED $dir/$rel"; fail=1; }
    done < <(find "$HERE/$dir" -type f ! -name .DS_Store | sort)
    echo "$dir/MD5SUMS.txt: $n entries checked"
  done
done
# challenge/ carries the auditor's own two manifests (challenge/MD5SUMS.txt, challenge/preflight/MD5SUMS.txt), kept
# byte-identical; only challenge/README.md is outside them.
if [ $# -eq 0 ] || [[ " $* " == *" challenge "* ]]; then
  for M in "$HERE/challenge/MD5SUMS.txt" "$HERE/challenge/preflight/MD5SUMS.txt"; do
    D="$(dirname "$M")"; n=0
    [ -f "$M" ] || { echo "missing manifest: ${M#"$HERE/"}"; fail=1; continue; }
    while read -r h p; do
      [ -z "$h" ] && continue
      n=$((n + 1))
      if [ ! -f "$D/$p" ]; then echo "MISSING  ${D#"$HERE/"}/$p"; fail=1
      elif [ "$(md5of "$D/$p")" != "$h" ]; then echo "MISMATCH ${D#"$HERE/"}/$p"; fail=1; fi
    done < "$M"
    while IFS= read -r f; do
      b="$(basename "$f")"
      [ "$b" = "MD5SUMS.txt" ] || [ "$f" = "$HERE/challenge/README.md" ] && continue
      grep -q "  $b\$" "$M" || { echo "UNLISTED ${f#"$HERE/"}"; fail=1; }
    done < <(find "$D" -maxdepth 1 -type f ! -name .DS_Store | sort)
    echo "${M#"$HERE/"}: $n entries checked"
  done
fi
[ "$fail" = 0 ] && echo "all md5s match" || { echo "md5 check FAILED"; exit 1; }
