# certificates/w2b3/ — Theorem W2B3 (version 2.1.0): the middle range of conductors

Theorem W2B3 (paper §7.5) says: for every real primitive Dirichlet character χ of conductor m, with no hypothesis beyond
that (no GRH, no zero-free half-plane, no zero verification; a Siegel zero is allowed),

    odd  χ, 1 650 000 ≤ m ≤ 10⁸:  Λ_χ ≤ 0.2807226 < 9/32   (margin 5.27·10⁻⁴)
    even χ, 3 700 000 ≤ m ≤ 10⁸:  Λ_χ ≤ 0.2808812 < 9/32   (margin 3.69·10⁻⁴)

and Theorem C2 covers m ≥ 10⁸. It is NOT kernel-checked, and it has no Lean statement. It is in the same trust classes as
Theorem C2: Arb certificates (this directory), AI-written analysis reviewed by one AI reviewer, and unrefereed preprints
(Hakimoglu-Brown, arXiv:2610.12803, Lemma 10 and Theorem 12, read at source). The method is the one of paper §7.1 with
Hakimoglu-Brown's derivative kernel in place of the plain pairwise inequality: per time slab i, a certified floor
S_χ − L/4 ≥ CF_i AND a certified ceiling G := ∂_p S_χ ≤ CG_i (both uniform in x, m ∈ [m_lo, 10⁸]), an exact-rational
certificate that his polynomial Φ_i(D, r) ≥ 0 at (A²_i, λ_i, μ_i), and the stepped barrier recursion with
k_i = 4(λ_i C_i/p − μ_i G_i − 2λ_i/(B − q_i) − 2μ_i(B + q_i)/(B − q_i)²), his (33), at p = 7/2, B = 49/4, over 39 slabs per
parity. The landing is in Arb (128 bits, outward).

Conventions as in `../README.md`: a ledger with a non-empty failure list certifies nothing; the certifiers are
`python-flint` programs with outward rounding; one core per worker, BLAS pinned to one thread; `Y3_P` is the probe height
(here the exact rational string `7/2`; `y3_big.py` has no default on purpose).

## What each file is

Code (the as-run md5 prefix is the one stamped into the ledgers under `certifier_md5`; the shipped copies of five files
differ from the as-run ones ONLY in comments and in the two import-path lines noted below, so a re-run stamps different
prefixes; every other field reproduces):

| file | shipped md5 | as-run md5 | what it is |
|---|---|---|---|
| w2b3_cert.py | see MD5SUMS.txt | f2e56a85 | G1 certifier for 0 ≤ x ≤ 10⁴: `y3_cert.py` (5b375c5b, unchanged for the S floor, bit-identical) extended by accumulators that return an upper bound for G = (1/4) Re (D′/D)′(c) (the variance form, paper §7.5). Includes the fix F1 required by the review. Shipped copy: two comments reworded |
| w2b3_big2.py | see MD5SUMS.txt | 4b780036 | LX certifier for x ≥ 10⁴ (mode `xaware`, v₀ = 2500): `y3_big2.py` (aafeba32, S bit-identical) extended likewise. Shipped copy: three comments reworded |
| w2b3_sweep.py | see MD5SUMS.txt | 9efa5464 | the slab cover driver: `y3_sweep.py`'s structure with the second test `G ≤ CG`; writes `prefix.json`/`.DONE` with `g1_cert`, `lx_cert`, `evals`, `worst_g1`, `worst_lx`, `maxG_g1`, `maxG_lx`, `n_failed`, `complete`, `certifier_md5`. Shipped copy: the helper modules are read from this directory instead of a `scripts/` subdirectory (two lines), one comment reworded |
| w2b3_launch.py | 49f7fd30 | 49f7fd30 | runs the 39 sweeps of a plan with W workers (subprocesses), skipping slabs whose `.DONE` exists |
| w2b3_bound.py | 4b4ca675 | 4b4ca675 | the Arb landing from the 39 `.DONE` ledgers and the Φ certificate (asserts: complete, 0 failures, m_lo inside the band, t₀ ≤ 10⁻⁴, overlapping seams, 0 < q_i ≤ A²_i < B, every row certified, k_i > 0). Also reports the plain kernel (λ, μ) = (1, 0) |
| w2b3_phi.py | 797ff1d8 | 797ff1d8 | exact-rational Bernstein certificate of Φ_i ≥ 0 (Hakimoglu-Brown (25), (34)–(36)); `--selftest` runs his Table 3 row 0, the boundary case (1, 0), and the negative control (5/2, 0), which must be REFUSED |
| w2b3_check.py | see MD5SUMS.txt | a198a5ee | checks that the S floor of the two new certifiers is bit-identical to `y3_cert.py` / `y3_big2.py` on 16 + 10 boxes, and prints the certified G against the exact x = 0 model. Shipped copy: import path (one line) |
| w2b3_measure.py | see MD5SUMS.txt | f3b36538 | the slab MEASUREMENT (a fixed grid; COMPUTED, not a certificate) that produced the targets. Shipped copy: import path (one line) |
| w2b3_design.py | 7ad66fa0 | 7ad66fa0 | the DESIGN (COMPUTED): merges the measurement into 39 slabs, chooses (λ_i, μ_i) on the 1/50 grid to maximise k_i under the exact Φ certificate, writes the plan json |
| y3_big.py, y3_cert.py, y3_big2.py | aa232458, 5b375c5b, aafeba32 | same | the version-2.0.0 helpers and certifiers, byte-identical to `../g1_rerun/` and `../lx/` (needed by the three scripts above and by the check) |

Certificates and ledgers of record (byte-for-byte copies of the as-run files; the review's Addendum 1 confirmed every
field of every ledger against the auditor's own re-run):

| file(s) | md5 | what it is |
|---|---|---|
| w2b3_cov2_a1_m1650000_s{0..38}.DONE / .json / .log | DONE files concatenated in slab order: 696148f1 | odd χ, band [1 650 000, 10⁸], 39 slabs with t-edges 10⁻⁴, 0.005, …, 0.10, 0.11, …, 0.29: 4 926 boxes certified (6 078 evaluations), 0 failed, all complete, 126 s wall (two workers) |
| w2b3_cov2_a0_m3700000_s{0..38}.DONE / .json / .log | concatenated: 0be5d4cf | even χ, band [3 700 000, 10⁸]: 5 925 boxes (8 076 evaluations), 0 failed, 166 s wall |
| w2b3_phi_a1_m1650000.json | 4e72c655 | the exact Φ certificate, odd: 39 rows (A²_i, λ_i, μ_i, min Bernstein coefficient as an exact rational), `all_certified: true`, smallest coefficient 1.34·10⁻⁴ |
| w2b3_phi_a0_m3700000.json | c3213386 | the same, even |
| w2b3_bound2_a1.json | 87e26183 | the Arb landing, odd: T = 0.2806725, Λ_χ ≤ 0.2807226, `lt_9_32: true`, margin 5.27·10⁻⁴, landed in slab 38; per-slab q_i (up), k_i (down), k_plain |
| w2b3_bound2_a0.json | 55c37c93 | the same, even: T = 0.2808311, Λ_χ ≤ 0.2808812, margin 3.69·10⁻⁴, slab 38 |
| w2b3_meas_p35_d05_a1_m1.5e6_plan_m1650000.json | a2111bb6 | the plan of record, odd (the design's output: per slab t_lo, t_hi, CF, CG, λ, μ, A²); the input of `w2b3_phi.py` and `w2b3_launch.py` |
| w2b3_meas_p35_d05_a0_m2.5e6_plan_m3700000.json | ecc27b99 | the plan of record, even |
| w2b3_launch2_a1.log, w2b3_launch2_a0.log | 57e6af13, 67f399fb | the launcher's console logs of the record runs |

Inputs of the design (COMPUTED, not certificates):

| file(s) | md5 | what it is |
|---|---|---|
| w2b3_meas_p35_d05_a1_m1.5e6.json / .DONE | 9620a633 | the measurement, odd, band [1.5·10⁶, 10⁸], p = 7/2, δ = 1/2: 136 fine τ-slabs, 27 885 box evaluations, 632 s |
| w2b3_meas_p35_d05_a0_m2.5e6.json / .DONE | b98ae3a5 | the measurement, even, band [2.5·10⁶, 10⁸]: 25 805 evaluations, 590 s |
| w2b3_design_a1_final.out, w2b3_design_a0_final.out | 9f47f42d, 64001424 | the design runs that wrote the two plans (design thresholds 1.587·10⁶ / 3.599·10⁶) |

Not included: the pre-F1 code, ledgers and landings (superseded; see the review), the negative-control copies, and the
earlier measurement and design runs that the record does not use.

## Re-running the cheap checks

In this directory, with the BLAS pinned:

    export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1

1. The landing (under a second each; the outputs must be byte-identical to the two `w2b3_bound2_*.json`):

       python3 w2b3_bound.py 1650000 w2b3_phi_a1_m1650000.json $(for i in $(seq 0 38); do echo w2b3_cov2_a1_m1650000_s$i.DONE; done) > bound2_a1.rerun.json
       python3 w2b3_bound.py 3700000 w2b3_phi_a0_m3700000.json $(for i in $(seq 0 38); do echo w2b3_cov2_a0_m3700000_s$i.DONE; done) > bound2_a0.rerun.json
       cmp bound2_a1.rerun.json w2b3_bound2_a1.json && cmp bound2_a0.rerun.json w2b3_bound2_a0.json

   Expected: `"Lambda_up": 0.2807225213960525` / `0.2808811111166155`, `"lt_9_32": true`, `"landed_in_slab": 38`.
   Negative controls that must raise an AssertionError: a ledger copy with `"n_failed": 1`; a certificate copy with one
   row's `"certified": false`; `m_lo` below the ledgers' (e.g. 1600000).

2. The positivity certificates (under a second each; byte-identical to the two `w2b3_phi_*.json`), and the self-test:

       python3 w2b3_phi.py --selftest
       python3 w2b3_phi.py w2b3_meas_p35_d05_a1_m1.5e6_plan_m1650000.json phi_a1.rerun.json
       python3 w2b3_phi.py w2b3_meas_p35_d05_a0_m2.5e6_plan_m3700000.json phi_a0.rerun.json

3. The bit-identity of the S floor with the version-2.0.0 certifiers, and the G calibration (one second):

       Y3_P=7/2 python3 w2b3_check.py        # expect "G1 S bit-identical on all boxes: True" and identical=True on every LX line

4. One slab sweep (seconds), to compare with its ledger field by field (everything except `sec` and `certifier_md5`):

       Y3_P=7/2 python3 w2b3_sweep.py 1 1650000 100000000 0.29000000000000004 -0.03162312486851568 0.12955958435119794 s38.rerun 1.02 0.28 0.5

   The arguments are parity, m_lo, m_hi, t_hi, CF, CG, prefix, τ-ratio, t_lo, δ, with CF, CG, t_lo, t_hi taken from the
   slab's `.DONE` file exactly (they are the floats the record compared against).

5. All 78 slabs (about 5 CPU-minutes; two to four workers), written to a new prefix so that the record is not touched:

       python3 w2b3_launch.py w2b3_meas_p35_d05_a1_m1.5e6_plan_m1650000.json /some/other/dir/w2b3_cov2_a1_m1650000 2
       python3 w2b3_launch.py w2b3_meas_p35_d05_a0_m2.5e6_plan_m3700000.json /some/other/dir/w2b3_cov2_a0_m3700000 2

   then compare every field of every `.DONE` and `.json` with the record's except `sec` and `certifier_md5`, and run step 1
   on the new ledgers. (The launcher skips a slab whose `.DONE` already exists at the given prefix.)

The measurement (`w2b3_measure.py`, about ten minutes per parity) and the design (`w2b3_design.py`) are not needed to check
the theorem: the plans of record are here, and the sweeps and the exact certificate are what the theorem rests on.

Checks made for this release, from the files in this directory: steps 1–3 as stated (byte-identical landings and
certificates; S bit-identical on all 26 boxes), and step 5 in full (all 78 ledgers equal to the record in every field
except `sec` and `certifier_md5`; landing from the re-swept ledgers 0.2807226 / 0.2808812).

## Records

The W2B3 memo (md5 c5cd8f39; its §0 carries the erratum F1 and its §5, §6, §9 the re-issued record) and the auditor's review
REVIEW_W2B3 (md5 e195ebaa; PASS after the required fix F1; Addendum 1 confirms the re-issued ledgers field by field, the
landing, and the exact reproduction of every Bernstein coefficient by the auditor's own checker) are the records behind this
directory; see Appendix B of the paper for where they are held.
