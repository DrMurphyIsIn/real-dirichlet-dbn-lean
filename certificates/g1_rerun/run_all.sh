#!/bin/sh
# Y3 G1 re-run of C2 (bb REVIEW_Y3 G-1..G-4): record jobs and parameters, y3_cert (B1-patched) at p = sqrt5.
export Y3_P=sqrt5 OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
cd "$(dirname "$0")"
python3 g1_sweep_y3.py corner 0 1750 6 y3g1_corner_a0 300 > y3g1_corner_a0.log 2>&1
python3 g1_sweep_y3.py corner 1 1750 6 y3g1_corner_a1 300 > y3g1_corner_a1.log 2>&1
python3 g1_sweep_y3.py rem 0 1750 6 y3g1_rem_a0 240 > y3g1_rem_a0.log 2>&1
python3 g1_sweep_y3.py rem 1 1750 6 y3g1_rem_a1 240 > y3g1_rem_a1.log 2>&1
echo ALLDONE > run_all.DONE
