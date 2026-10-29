#!/bin/bash
# bb, 2026-10-29: local pre-flight for the Comparator challenge (plain lean, no lake, 1 leanlock slot). Challenge-side
# modules build into chal/build ONLY (never mixed with the solution build dir), against OAI's Mathlib (v4.34.1 / d13f23b).
W=$HOME/e9-research/review_cn1/p1p6/chal; O=$HOME/e9-research/review_cn1/p1p6/oaiport; L=$W/log/preflight_progress.txt
T1=$HOME/.elan/toolchains/leanprover--lean4---v4.34.1; PO=$HOME/oai-replay/.lake/packages
LPM="$T1/lib/lean"; for p in mathlib batteries aesop Qq proofwidgets plausible LeanSearchClient importGraph; do LPM="$LPM:$PO/$p/.lake/build/lib/lean"; done
LPC="$LPM:$W/build"
LPS="$T1/lib/lean:$O/build:$HOME/oai-replay/.lake/build/lib/lean"; for d in $PO/*/; do [ -d "$d.lake/build/lib/lean" ] && LPS="$LPS:$d.lake/build/lib/lean"; done
run() { PATH="$T1/bin:$PATH" LEAN_PATH="$1" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $T1/bin/lean -R . "${@:2}"; }
cd $W/src
for m in ChallengeDefs Challenge ChallengeTamperA ChallengeTamperB; do
  s=$(date +%s); run "$LPC" -o $W/build/$m.olean -i $W/build/$m.ilean $m.lean > $W/log/$m.out 2>&1
  rc=$?; echo "build $m rc=$rc $(( $(date +%s) - s ))s src=$(md5 -q $m.lean)" >> $L; [ $rc -ne 0 ] && { echo STOP >> $L; exit 1; }
done
for f in BbPreflightChal BbPreflightTamperA BbPreflightTamperB BbPreflightChalClosure; do run "$LPC" $f.lean > $W/log/$f.out 2>&1; echo "$f rc=$? out=$(md5 -q $W/log/$f.out)" >> $L; done
run "$LPS" BbPreflightSol.lean > $W/log/BbPreflightSol.out 2>&1; echo "BbPreflightSol rc=$? out=$(md5 -q $W/log/BbPreflightSol.out)" >> $L
echo DONE >> $L
