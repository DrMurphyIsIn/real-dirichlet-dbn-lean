#!/bin/bash
# bb, 2026-10-29 (prime variant; lean4lean N/A on v4.34.1 exports): export (lean4export 3.1.0 for Lean v4.34.1, ~/e9-tools) of the OAI-pin composition and of a skipKernelTC
# control, then the six checkers bundled with Lean v4.35.0-rc3 (same export format 3.1.0) on each export, with guards.
O=$HOME/e9-research/review_cn1/p1p6/oaiport
T1=$HOME/.elan/toolchains/leanprover--lean4---v4.34.1
TC=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0-rc3/bin
EXP=$HOME/e9-tools/comparator/.lake/packages/lean4export/.lake/build/bin/lean4export
P=$HOME/oai-replay/.lake/packages
LPO="$T1/lib/lean:$O/build:$HOME/oai-replay/.lake/build/lib/lean"; for d in $P/*/; do [ -d "$d.lake/build/lib/lean" ] && LPO="$LPO:$d.lake/build/lib/lean"; done
EXTRA="Quot Quot.mk Quot.lift Quot.ind propext Quot.sound Classical.choice"
L=$O/log/kernels_realprim_progress.txt; mkdir -p $O/exp
cd $O/src
ex() { PATH="$T1/bin:$PATH" LEAN_PATH="$LPO" ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh $EXP $1 -- $3 $EXTRA > $O/exp/$2 2> $O/log/export_$2.err
  rc=$?; b=$(wc -c < $O/exp/$2 | tr -d ' '); echo "export $2 rc=$rc bytes=$b md5=$(md5 -q $O/exp/$2)" >> $L
  if [ $rc -ne 0 ] || [ "$b" -lt 1000 ]; then echo "ABORT: export $2 failed or empty" >> $L; exit 2; fi; }
ex BbOaiRealPrim realprim.ndjson bb_real_primitive_real_zeros_oai
kr() {
  E=$O/exp/$2
  printf '{"use_stdin": false, "export_file_path": "%s", "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"], "unpermitted_axiom_hard_error": true, "num_threads": 4, "nat_extension": true, "string_extension": true}' "$E" > $O/exp/$1.nanoda.json
  for k in leanchecker-paranoid nanoda con-leche con-ron leanchecker; do
    case $k in
      leanchecker-paranoid) cmd=("$TC/leanchecker-paranoid" --silent --from-export "$E");;
      lean4lean) cmd=("$TC/lean4lean" --import "$E");;
      nanoda) cmd=("$TC/nanoda_bin" "$O/exp/$1.nanoda.json");;
      con-leche) cmd=("$TC/con-leche" "$E");;
      con-ron) cmd=("$TC/con-ron" "$E");;
      leanchecker) cmd=("$TC/leanchecker" --silent --from-export "$E");;
    esac
    s=$(date +%s)
    PATH="$TC:$PATH" LEAN_ABORT_ON_PANIC=1 ARDA_LEAN_SLOTS=1 $HOME/hodge-engine/leanlock.sh "${cmd[@]}" > $O/log/kr_$1_$k.out 2>&1
    rc=$?; echo "$1 $k rc=$rc $(( $(date +%s) - s ))s" >> $L
    if [ "$1" = ctrl ] && [ $rc -eq 0 ]; then echo "INVALID RUN: $k ACCEPTED the skipKernelTC control" >> $L; fi
  done
}
kr ctrl ctrl.ndjson
kr realprim realprim.ndjson
echo DONE >> $L
