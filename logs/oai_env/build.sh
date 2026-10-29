#!/bin/bash
# bb, 2026-10-29 (user-approved in bb's session): port of the island modules Gen needs + the 13 Gen files to OpenAI's pins
# (Lean v4.34.1, Mathlib d13f23b) using the built packages of ~/oai-replay (10-07 replay). Plain lean, no lake, 1 leanlock slot.
# Resumable: a module is rebuilt only if its source md5 changed since its last successful build.
O=$HOME/e9-research/review_cn1/p1p6/oaiport
TC=$HOME/.elan/toolchains/leanprover--lean4---v4.34.1
P=$HOME/oai-replay/.lake/packages
LP="$TC/lib/lean:$O/build"; for p in mathlib batteries aesop Qq proofwidgets plausible LeanSearchClient importGraph; do LP="$LP:$P/$p/.lake/build/lib/lean"; done
export PATH="$TC/bin:$PATH"
cd $O/src
for m in DBNHadamardCount DBNHadamardLinear DBNHadamardMean DBNHadamardProduct DBNStep DBNHurwitz DBNHadamard \
         GenFourier GenDefs GenHeatApprox GenM1Approx GenM1Parametric GenScale GenTheta GenMellin GenMellin2 GenBridge \
         GenStrip GenThetaFE GenChi4 $EXTRA_MODULES; do
  h=$(md5 -q $m.lean)
  if [ -f $O/build/$m.olean ] && [ "$(cat $O/build/$m.srcmd5 2>/dev/null)" = "$h" ]; then continue; fi
  s=$(date +%s)
  LEAN_PATH="$LP" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $TC/bin/lean -R . -o $O/build/$m.olean -i $O/build/$m.ilean $m.lean > $O/log/$m.out 2>&1
  rc=$?; echo "$m rc=$rc $(( $(date +%s) - s ))s src=$h" >> $O/log/progress.txt
  if [ $rc -ne 0 ]; then rm -f $O/build/$m.olean; echo "STOP at $m" >> $O/log/progress.txt; exit 1; fi
  echo $h > $O/build/$m.srcmd5
  # any downstream module must be rebuilt after an upstream change
  rm -f $O/build/*.srcmd5.stale
done
echo DONE >> $O/log/progress.txt
