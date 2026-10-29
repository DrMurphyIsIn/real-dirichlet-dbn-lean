#!/bin/bash
# bb, 2026-10-29 (user-approved OAI-env work in bb's session): the contrarian's GaussBridge.lean (4f746054), general-chi
# meaning link. (1) rc3 / Mathlib 0493595e: build + check + tamper. (2) OAI env (v4.34.1 / d13f23b, ~/oai-replay): build
# unchanged, conjunction BbOaiMeaning with bb_real_primitive_real_zeros_oai, check / ref / tamper. (3) export + five checkers
# + skipKernelTC control, with guards. Plain lean, 1 leanlock slot, no lake.
P=$HOME/e9-research/review_cn1/p1p6; G=$P/gen; O=$P/oaiport
L=$O/log/meaning_progress.txt
# (1) rc3
PK=$HOME/axiom-dzf/repo-adapted/.lake/packages
LP3="$G/build:$P/island/build"; for p in mathlib batteries aesop Qq proofwidgets plausible LeanSearchClient importGraph; do LP3="$LP3:$PK/$p/.lake/build/lib/lean"; done
L3=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0-rc3/bin/lean
cd $G/out
s=$(date +%s); LEAN_PATH="$LP3" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $L3 -R . -o $G/build/GaussBridge.olean -i $G/build/GaussBridge.ilean GaussBridge.lean > $G/log/GaussBridge.out 2>&1
rc=$?; echo "rc3 GaussBridge rc=$rc $(( $(date +%s) - s ))s src=$(md5 -q GaussBridge.lean)" >> $L; [ $rc -ne 0 ] && { echo "STOP rc3 build" >> $L; exit 1; }
for f in BbGaussBridgeCheck BbGaussBridgeTamper; do
  LEAN_PATH="$LP3" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $L3 -R . $f.lean > $G/log/$f.out 2>&1
  echo "rc3 $f rc=$? errors=$(grep -c ': error' $G/log/$f.out) out=$(md5 -q $G/log/$f.out)" >> $L
done
# (2) OAI env
T1=$HOME/.elan/toolchains/leanprover--lean4---v4.34.1
PO=$HOME/oai-replay/.lake/packages
LPO="$T1/lib/lean:$O/build:$HOME/oai-replay/.lake/build/lib/lean"; for d in $PO/*/; do [ -d "$d.lake/build/lib/lean" ] && LPO="$LPO:$d.lake/build/lib/lean"; done
EXTRA_MODULES="GaussQuad GaussPrime GaussCRT GaussPow GaussTwo GaussSign GaussBridge" $O/build.sh > /dev/null 2>&1
echo "oai build.sh rc=$? (last: $(tail -2 $O/log/progress.txt | tr '\n' ' '))" >> $L
[ -f $O/build/GaussBridge.olean ] || { echo "STOP oai GaussBridge missing" >> $L; exit 1; }
cd $O/src
s=$(date +%s); PATH="$T1/bin:$PATH" LEAN_PATH="$LPO" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $T1/bin/lean -R . -o $O/build/BbOaiMeaning.olean -i $O/build/BbOaiMeaning.ilean BbOaiMeaning.lean > $O/log/BbOaiMeaning.out 2>&1
rc=$?; echo "oai BbOaiMeaning rc=$rc $(( $(date +%s) - s ))s src=$(md5 -q BbOaiMeaning.lean)" >> $L; [ $rc -ne 0 ] && { echo "STOP oai build" >> $L; exit 1; }
for f in BbOaiMeaningCheck BbOaiMeaningRef BbOaiMeaningTamper; do
  PATH="$T1/bin:$PATH" LEAN_PATH="$LPO" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $T1/bin/lean -R . $f.lean > $O/log/$f.out 2>&1
  echo "oai $f rc=$? errors=$(grep -c ': error' $O/log/$f.out) out=$(md5 -q $O/log/$f.out)" >> $L
done
# (3) kernels
TC=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0-rc3/bin
EXP=$HOME/e9-tools/comparator/.lake/packages/lean4export/.lake/build/bin/lean4export
EXTRA="Quot Quot.mk Quot.lift Quot.ind propext Quot.sound Classical.choice"
PATH="$T1/bin:$PATH" LEAN_PATH="$LPO" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $EXP BbOaiMeaning -- bb_real_primitive_meaning_oai $EXTRA > $O/exp/meaning.ndjson 2> $O/log/export_meaning.ndjson.err
rc=$?; b=$(wc -c < $O/exp/meaning.ndjson | tr -d ' '); echo "export meaning.ndjson rc=$rc bytes=$b md5=$(md5 -q $O/exp/meaning.ndjson)" >> $L
if [ $rc -ne 0 ] || [ "$b" -lt 1000 ]; then echo "ABORT: export failed or empty" >> $L; exit 2; fi
echo "ctrl.ndjson md5=$(md5 -q $O/exp/ctrl.ndjson)" >> $L
kr() {
  E=$O/exp/$2
  printf '{"use_stdin": false, "export_file_path": "%s", "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"], "unpermitted_axiom_hard_error": true, "num_threads": 4, "nat_extension": true, "string_extension": true}' "$E" > $O/exp/$1.nanoda.json
  for k in leanchecker-paranoid nanoda con-leche con-ron leanchecker; do
    case $k in
      leanchecker-paranoid) cmd=("$TC/leanchecker-paranoid" --silent --from-export "$E");;
      nanoda) cmd=("$TC/nanoda_bin" "$O/exp/$1.nanoda.json");;
      con-leche) cmd=("$TC/con-leche" "$E");;
      con-ron) cmd=("$TC/con-ron" "$E");;
      leanchecker) cmd=("$TC/leanchecker" --silent --from-export "$E");;
    esac
    s=$(date +%s)
    PATH="$TC:$PATH" LEAN_ABORT_ON_PANIC=1 ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh "${cmd[@]}" > $O/log/km_$1_$k.out 2>&1
    rc=$?; echo "$1 $k rc=$rc $(( $(date +%s) - s ))s" >> $L
    if [ "$1" = ctrl ] && [ $rc -eq 0 ]; then echo "INVALID RUN: $k ACCEPTED the skipKernelTC control" >> $L; fi
  done
}
kr ctrl ctrl.ndjson
kr meaning meaning.ndjson
echo DONE >> $L
