# Re-running the certificates of version 2 (and, from version 2.1.0, of the middle range in `w2b3/`)

Everything here is a Python 3 program using `python-flint` (Arb ball arithmetic). Each certifier returns a rigorous lower bound
over a box, with outward rounding (the `w2b3/` certifiers also return a rigorous upper bound for the vertical derivative), and each driver writes a ledger with the box count, the worst certified value and the list of
failures. **A ledger with a non-empty failure list certifies nothing.** The results in the paper are the statements "every box
passed, worst value ≥ the stated floor"; to check them, re-run the driver and compare the `evaluations`, `certified`, `worst` and
`failed` (or `n_failed`) fields with the record's `.DONE` file. The auditor's reproductions matched every field except wall time.

What the certificates do NOT establish: they are not kernel-checked proofs. Their soundness depends on the certifier programs
(AI-written; reviewed by one AI reviewer; four defects found and repaired, paper §7.3). A reader who wants to trust them should read
`y3_cert.py`, `y3_big.py` and `y3_big2.py`.

## Requirements

- Python 3 with `python-flint` (`pip install python-flint`; the record runs used the `flint` module's `arb`, `acb`, `acb_series`).
- One core per worker. Pin the BLAS to one thread (`OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
  VECLIB_MAXIMUM_THREADS=1`); otherwise the pool workers oversubscribe and the run slows down by a large factor.
- `y3_big.py` reads the probe height from the environment variable `Y3_P` (an exact decimal string, or `sqrt5`) and has no
  default on purpose: a missing `Y3_P` aborts.

## 1. Theorem C2, component 4a: the G1 cover (`g1_rerun/`)

Run, in `g1_rerun/`:

    sh run_all.sh

which is

    export Y3_P=sqrt5 OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
    python3 g1_sweep_y3.py corner 0 1750 6 y3g1_corner_a0 300
    python3 g1_sweep_y3.py corner 1 1750 6 y3g1_corner_a1 300
    python3 g1_sweep_y3.py rem    0 1750 6 y3g1_rem_a0    240
    python3 g1_sweep_y3.py rem    1 1750 6 y3g1_rem_a1    240

The arguments are: mode (`corner` = the hard corner L ∈ [L₀, 18.43], t ≤ 0.05, x ≤ 5; `rem` = the remainder of the compact
domain), parity (0 even, 1 odd), budget in seconds per job (1750), workers (6), ledger prefix, and the per-box time cap in
seconds (300 for corner, 240 for rem). K0 = 1 and the bisection depth cap 30 are inside the driver. The pass criterion is: `complete: true`,
`attempted = completed = initial_boxes` (320 / 320 / 4,576 / 4,576), `capped: 0`, `failed: 0`.

Measured cost (record run, 2026-11-01, six workers, one thread each): wall 12.6 s + 1.0 s + 152.9 s + 93.1 s, i.e. **about 0.43
CPU-hours**; 67,679 certified leaves in all. The auditor's reproduction took about the same. (The superseded P5 run, with the
unpatched certifier, needed 440,993 leaves and 2.9 CPU-hours; the difference is the B1 clamp, which removes a near-pole majorant
that forced deep bisection.)

The statement certified: S_chi(x, √5, t) − L/4 ≥ −1 for L ∈ [L₀, 4·10⁴] (L₀ = log(10⁸/π)), t ∈ [10⁻⁴, T(L)], 0 ≤ x ≤ 10⁴, both
parities, every real primitive χ. Negative x is covered by S(−x) = S(x).

## 2. Theorem C2, component 4b: the LX cover (`lx/`)

Run, in `lx/`:

    Y3_P=sqrt5 OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python3 lx_cover_p5patched.py 1.0 > lx_cover_p5patched.rerun.out

(the first argument is K0 = 1.0; the τ range defaults to [√(10⁻⁴/2)·0.999, 0.3718]). It prints one JSON line per τ-slab and a final
summary. The record: `{"boxes": 3069, "failed": [], "worst": -0.7689010121779203, "seconds": 36.1}`. All 136 slab rows must match
the record except `sec`.

Measured cost: **36 seconds** on one core. The statement certified: S_chi(x, √5, t) − L/4 ≥ −0.77 for L ≤ 4·10⁴, t ∈ [10⁻⁴, T(L)],
|x| ≥ 10⁴ (the certifier evaluates at v₀ = 2500, i.e. x = 10⁴, and the bound is valid for all larger x by the monotonicity lemma
of P5 memo §A.9.2, which is a proof, not a computation).

## 3. Theorem C2, component 4c: STL (`stl/`)

STL is a lemma, not a certificate (P5 memo §A.9.3): for τ ≤ 0.0175 and R ≥ 2.618, every x and both parities, S − L/4 ≥ −0.18. Its
constants (ψ(1.309), Z(2.618) = 0.2510, Z(2.44), Z₂(2.44), the majorant sup) are Arb values quoted in the proof; with
Z(2.6179) = 0.250988 the proof gives −0.17525. `stl_samples.out` is an illustration computed with the P5 certifiers (xfree and
xaware modes) at sample points; it is not needed for the proof and there is no driver to re-run for it. The domain fact that every
point with L > 4·10⁴ satisfies τ ≤ 0.0175 and R ≥ 2.618 is the Lean theorem `C2.STL_applies` (lean/).

## 4. Theorem C2, components 4d and 5 (`p5_components/`)

    OMP_NUM_THREADS=1 python3 rhi_monotone.py      # ~ seconds; expect 8000 boxes, 0 failures
    OMP_NUM_THREADS=1 python3 p2z_arb.py           # 1.6 s; expect 61440 boxes, 0 failed, worstQ 0.9084

`rhi_monotone` proves (Arb, forward-mode derivatives over a box cover) that T is strictly decreasing and L·T(L) strictly increasing
on [L₀, 4·10⁴], which the domain tiling of the G1 driver uses. `p2z_arb` is Lemma Z′ (uniform confinement of zeros of height ≥ √b to
|x| < X(L)) for L ≥ L₀: part 1 the analytic constants, part 2 a direct check of the criterion Q > 0 over 61,440 (L, t, y) boxes.
Both were run by P5 and are unaffected by the B1–B4 defects, which concern the floor certifiers only. The auditor re-ran both from
copies before release and obtained byte-identical outputs (p2z_arb.json 2b41dc9b, p2z_arb.DONE 69319cef, rhi_monotone.out 98c86374;
REVIEW_PRERELEASE_v2.0.0 d3a2e9eb in ../provenance/).

## 5. Theorems Y3 and U1: the p = 20 bands (`y3_bands/`)

    export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
    Y3_P=20 python3 y3_sweep.py 1 3 100000000 0.499 0.385 u20_a1      # odd:  ~40 s
    Y3_P=20 python3 y3_sweep.py 0 5 100000000 0.499 0.36  u20_a0      # even: ~39 s

Arguments: parity, m_lo, m_hi, t_hi, CF (the floor to certify for S − L/4), ledger prefix. Each writes `prefix.json` and
`prefix.DONE`; expect `n_failed: 0`, `complete: true`, and the `evals`, `worst_g1`, `worst_lx` fields of the record. Then the landing:

    python3 y3_bounds.py 20 0.36 0.385 9/16 0.499 > bounds_u20_q916.rerun.json   # Theorem Y3 (q0 = 9/16): 0.2783189 / 0.2791114
    python3 y3_bounds.py 20 0.36 0.385 1    0.499 > bounds_u20_q1.rerun.json     # Theorem U1 (q0 = 1):    0.4908346 / 0.4932941 (rounded up from 0.49083455… / 0.49329408…)

The CF floats are used exactly as the sweep compared against them (R-round). For Remark U2:

    Y3_P=2.5 python3 y3_sweep.py 1 15848932 100000000 0.282 -0.55 c25_a1     # ~42 s
    Y3_P=2.5 python3 y3_sweep.py 0 36307806 100000000 0.282 -0.76 c25_a0     # ~70 s
    python3 y3_bounds.py 2.5 -0.76 -0.55 1 0.282                              # 0.2812404 / 0.2811138

and the confinement lemma for 3 ≤ m ≤ 10⁸:

    python3 p2z_small.py          # 2.0 s; expect 76800 boxes, 0 failed, worstQ 0.9455

Note on the band ledgers: they were produced with the B1–B3 version of `y3_big2.py` (md5 a8f10bcd); the file here is the B1–B4
version (aafeba32). The auditor re-swept every band with the B1–B4 file and obtained ledgers identical in every field except wall time (REVIEW_Y3 §4, §6.1),
so a re-run with the file here should reproduce the record.

## 5a. Theorem W2B3, version 2.1.0: the middle range (`w2b3/`)

Odd χ with 1 650 000 ≤ m ≤ 10⁸: Λ_χ ≤ 0.2807226; even χ with 3 700 000 ≤ m ≤ 10⁸: Λ_χ ≤ 0.2808812; unconditional, not
kernel-checked. Thirty-nine slab ledgers per parity (each certifying a floor for S − L/4 and a ceiling for ∂_pS), two exact
Bernstein certificates and an Arb landing. `w2b3/README.md` says what every file is and gives the commands; the cheap checks are

    cd w2b3 && export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
    python3 w2b3_bound.py 1650000 w2b3_phi_a1_m1650000.json $(for i in $(seq 0 38); do echo w2b3_cov2_a1_m1650000_s$i.DONE; done)   # 0.2807226
    python3 w2b3_bound.py 3700000 w2b3_phi_a0_m3700000.json $(for i in $(seq 0 38); do echo w2b3_cov2_a0_m3700000_s$i.DONE; done)   # 0.2808812
    python3 w2b3_phi.py --selftest                                                                                                # negative control REFUSED
    Y3_P=7/2 python3 w2b3_check.py                                                                                                # S bit-identical: True

and the full re-sweep of the 78 slabs is about 5 CPU-minutes (`w2b3_launch.py`, see the README there). The record's ledgers were
reproduced field by field by the auditor (REVIEW_W2B3, Addendum 1) and again, from the files shipped here, for this release.

## 6. The Lean file (`../lean/`)

    lean DQ1_P5.lean     # Lean v4.35.0 with Mathlib of the same version on the path; 18 s; exit 0; five "#print axioms" lines

See `../lean/NOTE.md` for what it proves and what it only states.

## Records

Every number above is in `../provenance/`: P5_memo_extract.md §A.13 (the statement of record; §A.9 for LX and STL), Y3_memo_extract.md
§3–§4 (the all-conductor results, the defects, the G1 re-run), and the auditor's REVIEW_P5*.md, REVIEW_Y3.md, REVIEW_Y3_G1.md and
REVIEW_LEAN_DQ1.md, and REVIEW_PRERELEASE_v2.0.0.md (the pre-release review of this package, with the p2z_arb and rhi_monotone
re-runs). The extracts reproduce the cited sections of the two memos verbatim; their headers give the full memos' md5s. Paths of the
form `~/rh-team/...` inside those records refer to the programme's internal working tree at the time of writing; they are not part of
the release, and the copies are not redacted, so that their md5s match the originals.
