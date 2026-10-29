#!/bin/bash
# Check the md5 manifests of this repository: every file listed in lean/MD5SUMS.txt and logs/MD5SUMS.txt must have
# the recorded md5, and every file under lean/ and logs/ must be listed. Works with md5sum (Linux) or md5 (macOS).
#
#   scripts/verify_md5.sh            # both manifests
#   scripts/verify_md5.sh lean       # one of them
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
md5of() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }
fail=0
for d in "${@:-lean logs}"; do
  for dir in $d; do
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
[ "$fail" = 0 ] && echo "all md5s match" || { echo "md5 check FAILED"; exit 1; }
