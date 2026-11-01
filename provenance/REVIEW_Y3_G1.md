# REVIEW_Y3_G1: bb's confirmation of the C2 G1 re-run (gate G-1 to G-6) and the B4 adoption

2026-11-01. **AI review by bb, NOT an operator read-back.** No Lean or lake was run. bb reproduced the whole G1 re-run and the LX
cover from copies in bb's scratchpad (y3g1rep/, lxrep/), writing only there. No team file other than this one was written.

**Object.**
- Y3/memo.md **3779ce49220e4f1c934afcfa6722037a**, §4.5 (B4) and §4.6 (G1 re-run).
- Y3/scripts/y3_big2.py aafeba32 and lx_cover_p5patched.out 5aa52aef.
- Y3/g1_rerun/:
  - g1_sweep_y3.py a591107d, g1_sweep_y3.diff 0bd7810a, run_all.sh e186b662;
  - y3_cert.py 5b375c5b, y3_big.py aa232458, c2_domain.py f84d38a1;
  - four ledgers (DONE / json / log): corner_a0 79194715 / 01a9cf7a / a35795d6; corner_a1 0c5a24e4 / de50ff39 / 719fc681;
    rem_a0 43e1f9bc / f1a620e6 / 43d86eb0; rem_a1 f630953b / 37d25be4 / ca8c9341;
  - .unfinished.json files, all `[]` (d7517139).

## Verdict: PASS. G-1 to G-5 are met, and the re-run reproduces bit-identically. C2 can be re-closed (the lead's call)

| Gate | Check | Result |
|---|---|---|
| G-1 code | The copies' md5s equal y3_cert 5b375c5b, y3_big aa232458 and c2_domain f84d38a1. `diff P5/scripts/g1_sweep.py g1_sweep_y3.py` shows **only line 85** (tl_arb_cert → y3_cert), which matches the archived .diff. run_all.sh exports `Y3_P=sqrt5` and pins BLAS to 1 thread before any job | ✓ |
| G-2 runs | The record's four jobs and parameters: corner a0/a1 at cap 300, rem a0/a1 at cap 240, W = 6, K0 = 1, depth 30 (driver unchanged), new directory | ✓ |
| G-3 pass | Every ledger has complete: true, attempted = completed = initial (320 / 320 / 4 576 / 4 576), capped 0, failed 0, fail_examples [] and capped_idx []. done_idx is exactly {0, …, N−1} in all four | ✓ |
| — | **Independent reproduction:** bb re-ran all four jobs from copies (run_all.sh with prefixes renamed only) | **All four DONE summaries are identical to Y3's** in every field except wall time: evaluations, certified, worst, max_depth and every dropped count. Leaves are 2 929 / 349 / 37 065 / 27 336 = 67 679 in total |
| G-4 hygiene | One thread per worker; 0.43 CPU-h (bb's reproduction about the same) | ✓ |
| G-5 LX | y3_big2 aafeba32 equals bb_big2_b4 a410901b except for comments and bb's diagnostic `GAP` dict (`diff` checked) | ✓ |
| — | **LX reproduction:** bb's copy of lx_cover_p5patched with y3_big2 aafeba32 | **All 136 JSON rows are identical to 5aa52aef apart from `sec`:** 3 069 boxes, 0 failed, worst −0.7689010122 |
| G-6 status | G1 (y3_cert, B1-valid; worst −0.9999990867 ≥ −1), LX (B1 + B2 + B3 + B4; −0.7689 ≥ −0.77) and STL (analytic, unaffected) | **The C2 statement of record is met** (S ≥ L/4 − 1 on G1, S ≥ L/4 − 0.77 on LX, 0.2764282 at 10⁸). Re-closing is the lead's call. Release stays the user's |

**The B4 re-derivation (§4.5).** Y3's route agrees with REVIEW_Y3 §4 at every step:
- the exact real weight φ(g) after the shift;
- the split g* = (u_s − Re c₂)/τ with no upper bound on Re c₂;
- the guard τZ₁ + lo g_s < 0;
- the |h_Γ| and |h_L| majorants;
- v-uniformity through P5 A.9.2(d);
- the mass Φ(lo g_s).

Y3's tail argument for u ≥ 60 is also correct, and equivalent to mine (Z(u) ≤ 2^{60−u}Z(60)). Since Z′ = −ΣΛ(n)log n·n^{−u} ≤
−log 2·Z, the function (u − c)Z(u) is decreasing once u − c ≥ 1/log 2. This is the independent second check REVIEW_Y3 asked for.

**The nits are applied.**
- The even constant is now labelled certificate 0.2783189 vs Lean-rational 0.2783196 at §0, §3.4 and the Lean comment.
- The IIb multiplier is stated (:366–368).
- The a ≤ 1 dependence of 0.5002 is stated (:351).
- Optional: the a ≤ 1 note could also go into the y3_big2 code comment beside 0.5002.

**For the record update.**
- Row 4a cites y3_cert 5b375c5b and the four Y3/g1_rerun ledgers above.
- Row 4b cites y3_big2 aafeba32 and lx_cover_p5patched.out 5aa52aef.
- P5's G1 ledgers and lx_cover_Rx.out 77cadb55 are superseded. They were invalid as certificates under B1 and B2 respectively, and
  are kept as records.
- The leaf count drops from 440 993 to 67 679 because of the B1 clamp, as predicted. This is not a weakening.

## bb's files (scratchpad)

| file | md5 |
|---|---|
| y3g1rep/cmp.py (ledger comparison) | 39aa5faa048339b6215d6eda9b58963c |
| y3g1rep/rep_{corner_a0, corner_a1, rem_a0, rem_a1}.DONE | a1b4131f, b5a56c76, 0ec3ecc7, 5d6ee1c4 (differ from Y3's only in wall_s and timing fields) |
| lxrep/bb_lx_rep.out | dbac23d2cb5fdbc355f89a273b2fcc79 |

No RH-facing claim. conjecture1_proved = False. AI review by bb, NOT an operator read-back.
