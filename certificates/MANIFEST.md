# certificates/ — the as-run certificate bundle for version 2.0.0

Every file is a byte-for-byte copy (`cp`, never moved) from the programme's internal `dq1/` working tree (its `P5/scripts/`, `Y3/scripts/` and `Y3/g1_rerun/` directories) as of 2026-11-01. The md5 is the full md5 of the
copy; it equals the md5 of the original. Prefixes quoted in the paper, the memos and the reviews are the first eight characters.
The layout is by result; where one source file serves two results it appears in both directories (same md5).

## g1_rerun/ — Theorem C2, component 4a (G1: the compact part of the floor), certificate of record

Row 4a of P5 memo §A.13.3 as re-closed on 2026-11-01 (Y3 memo §4.6; REVIEW_Y3_G1 4b4d8aab). Copied from `dq1/Y3/g1_rerun/`.

| file | md5 | what it is |
|---|---|---|
| y3_cert.py | 5b375c5ba74f3c906807d2957c60d154 | G1 box certifier: certified (Arb) lower bound for S_chi(x, p, t) − L/4 over an (L, t, x) box, parity a. P5's tl_arb_cert.py (4a001119) with the Y3 patch B1 (real-part clamp at u₀). p is read from env `Y3_P` through y3_big |
| y3_big.py | aa2324580d421d4604c8fb82f61b639e | shared special-function helpers (monotone ζ, −ζ′/ζ tables, ψ′ majorant, ρ_lo, P_up) and the xfree/xaware big-x bound; p-parametrised (`Y3_P`, no default) |
| c2_domain.py | f84d38a19aa6bf635cbb27a3120ef241 | the C2 record domain in (R, τ): t_min, b, k, T(L), Lam_bound(L), R_range(τ). Identical to P5's c2_domain.py |
| g1_sweep_y3.py | a591107d3d93df7ea4035ff831bdb8e7 | the hybrid G1 driver (corner + remainder jobs, seeded order, bisection, caps, ledgers). P5's g1_sweep.py (5374c662) with one line changed (line 85: import from y3_cert) |
| g1_sweep_y3.diff | 0bd7810ae7034ef3c7b9504d30761434 | `diff` of P5's g1_sweep.py against g1_sweep_y3.py: exactly that one line |
| run_all.sh | e186b662bf97999a0954003986a52b93 | the as-run driver script: exports `Y3_P=sqrt5`, pins BLAS to one thread, runs the four jobs sequentially |
| run_all.DONE | 4dc7fdc2eca43d9498e0829200574957 | the marker written when run_all.sh finished (`ALLDONE`) |
| run_all.out | d41d8cd98f00b204e9800998ecf8427e | stdout of run_all.sh (empty; the md5 is that of the empty file) |
| y3g1_corner_a0.DONE | 791947156c1a5889b35b10848a36f62b | ledger summary, corner job, even parity: 320 initial boxes, 320 completed, 0 capped, 0 failed, 5,538 evaluations, 2,929 certified leaves, worst −0.9999656033, wall 12.6 s |
| y3g1_corner_a0.json | 01a9cf7a554647163d646b332d40baa1 | full ledger of that job (per-box results) |
| y3g1_corner_a0.log | a35795d608f7f23e1990c799d2333511 | stdout of that job |
| y3g1_corner_a0.unfinished.json | d751713988987e9331980363e24189ce | list of unfinished boxes: `[]` |
| y3g1_corner_a1.DONE | 0c5a24e45426d91d84d60bba3a6d596d | corner job, odd parity: 320 / 320 / 0 capped / 0 failed, 378 evaluations, 349 leaves, worst −0.9988738033, wall 1.0 s |
| y3g1_corner_a1.json | de50ff392091d30f7264ccb8dc340ae2 | full ledger |
| y3g1_corner_a1.log | 719fc68115778d9a50a3dca1a9710c1e | stdout |
| y3g1_corner_a1.unfinished.json | d751713988987e9331980363e24189ce | `[]` |
| y3g1_rem_a0.DONE | 43e1f9bc377d9743cd6e315e1ded05f8 | remainder job, even parity: 4,576 / 4,576 / 0 capped / 0 failed, 74,495 evaluations, 37,065 leaves, dropped 4,384 out / 69 stl / 0 above / 488 corner, worst −0.9999990867, max depth 17, wall 152.9 s |
| y3g1_rem_a0.json | f1a620e69a391fe9f389c9c8ea3a0a69 | full ledger |
| y3g1_rem_a0.log | 43d86eb03fe88a3230477272fb9dd202 | stdout |
| y3g1_rem_a0.unfinished.json | d751713988987e9331980363e24189ce | `[]` |
| y3g1_rem_a1.DONE | f630953b01fc97c00eb2172ec031e898 | remainder job, odd parity: 4,576 / 4,576 / 0 capped / 0 failed, 50,165 evaluations, 27,336 leaves, dropped 0 / 69 / 0 / 0, worst −0.9999363845, max depth 8, wall 93.1 s |
| y3g1_rem_a1.json | 37d25be40f21f2a18b786db5ba165bfc | full ledger |
| y3g1_rem_a1.log | ca8c9341f3a4bb1f163af9db61b93e64 | stdout |
| y3g1_rem_a1.unfinished.json | d751713988987e9331980363e24189ce | `[]` |

Totals: 67,679 certified leaves (2,929 + 349 + 37,065 + 27,336), 0 capped, 0 failed, worst certified value −0.9999990867 ≥ −1 = −K0,
about 0.43 CPU-hours (wall × 6 workers). The P5 record (440,993 leaves, 2.9 CPU-h) is superseded (provenance/P5_SUPERSEDED.md).

## lx/ — Theorem C2, component 4b (LX: all |x| ≥ 10⁴), certificate of record

Row 4b of P5 memo §A.13.3 with patches B1–B4 (Y3 memo §4.2, §4.5; REVIEW_Y3 §4; REVIEW_Y3_G1). Copied from `dq1/Y3/scripts/`.

| file | md5 | what it is |
|---|---|---|
| y3_big2.py | aafeba32b5f8c85d7a935d8b66967215 | the double-contour-shift certifier `big2` (P5 memo A.9.1), mode `xaware` (valid for all x ≥ 4v₀, v-monotone) and `xfree`. P5's tl_big2.py (cc065977) with Y3 patches B1 (clamp at u_s), B2 (Pb from hi(g_s)), B3 (three-region far tail, Lemma Γ↓) and B4 (the bulk/tail gap term, bb's) |
| y3_big.py | aa2324580d421d4604c8fb82f61b639e | helpers (same file as in g1_rerun/) |
| c2_domain_p5.py | f84d38a19aa6bf635cbb27a3120ef241 | the C2 domain (same content as c2_domain.py; the LX script imports it under this name) |
| lx_cover_p5patched.py | 5ca71fdc614fd3743c3bd9ef708bcf26 | the LX cover driver: τ-slabs of ratio 1.03 from √(10⁻⁴/2)·0.999 to 0.3718, split at τ*, R-boxes over R_range(τ) bisected to depth 10, both parities, K0 = 1, v₀ = 2500. Requires `Y3_P=sqrt5` in the environment |
| lx_cover_p5patched.out | 5aa52aefbe979908c49fccbcc22557f2 | its output with y3_big2 aafeba32 (B1–B4): one JSON line per slab, then the summary `{"boxes": 3069, "failed": [], "worst": -0.7689010121779203, "seconds": 36.1}` |
| y3_big2_vs_bb_b4.diff | 5dd6036728403ca9b8607fd42b15b508 | `diff` of y3_big2.py against bb's bb_big2_b4.py (a410901b): only bb's diagnostic `GAP` dict and comments differ |

The certified statement: S_chi(x, √5, t) ≥ L/4 − 0.77 for L ≤ 4·10⁴, t ∈ [10⁻⁴, T(L)], |x| ≥ 10⁴, both parities. C2 needs only −1.
The pre-B4 output (d0f05b64, worst −0.7689010031) and P5's lx_cover_Rx.out (77cadb55) are superseded.

## stl/ — Theorem C2, component 4c (STL: every L > 4·10⁴), illustration only

STL is an analytic lemma (P5 memo §A.9.3, PROVED by P5, reviewed in REVIEW_P5_DELTA and REVIEW_P5_A11 item N-c) whose constants are
Arb values: for τ ≤ 0.0175, R ≥ 2.618 and every x, S − L/4 ≥ −0.18 (the proof gives −0.17525 with Z(2.6179) = 0.250988). It has no
ledger. The P5 memo's illustration output is kept here.

| file | md5 | what it is |
|---|---|---|
| stl_samples.out | 0eac19052f5e248198ab7f32cd953979 | Arb samples of the xaware (v ≥ 2500) and xfree (v ≤ 2500) bounds at R ∈ {2.62, 5, 10, 100}, τ ∈ {0.0175, 0.001, 0.0001}, both parities; e.g. R = 2.62, τ = 0.0175: −0.1714 (a = 0), −0.0569 (a = 1); R = 100: ≥ 0.975. Not used in the proof |

## p5_components/ — Theorem C2, components 4d and 5, as in P5 (unaffected by B1–B4)

Copied from `dq1/P5/scripts/`. These P5 outputs are NOT superseded (REVIEW_Y3 §4 "Not affected"; P5_SUPERSEDED.md names only the G1
ledgers and lx_cover_Rx.out). Both scripts were re-run by the auditor from copies before release, with byte-identical outputs
(REVIEW_PRERELEASE_v2.0.0, md5 d3a2e9ebb56fe28a8482b8269ceaa810, in ../provenance/).

| file | md5 | what it is |
|---|---|---|
| c2_domain.py | f84d38a19aa6bf635cbb27a3120ef241 | the C2 record domain (same as above) |
| rhi_monotone.py | 66a25babc6da415b338369a69144c483 | Arb proof that L·T(L) is strictly increasing and T strictly decreasing on [L₀, 4·10⁴] (forward-mode derivatives over a box cover), so the domain's upper edge R_hi(τ) is monotone on each side of τ* (component 4d; REVIEW_P5_A11) |
| rhi_monotone.out | 98c863748429d812c5601e195c948632 | its output: 8,000 boxes, 0 failures, min lower bound of d(LT)/dL = 1.54·10⁻⁴, max upper bound of dT/dL = −1.13·10⁻⁸ |
| p2z_arb.py | b732f0ef4f95695d74d2a44c3b6c58bd | Lemma Z′ (P2′, uniform confinement; P5 memo A.12.2) in Arb: part 1 the analytic constants, part 2 a direct evaluation of the criterion Q > 0 over (L, t, y) boxes at x = X(L), for L ≥ L₀ (component 5; REVIEW_P5_A12) |
| p2z_arb.json | 2b41dc9b73307fb8de6f51a973a55e93 | its ledger |
| p2z_arb.DONE | 69319cef2d07b9c97e37da1343c74fc0 | summary: `{"n_failed": 0, "boxes": 61440, "worstQ": 0.9084365748232226, "seconds": 1.6, "complete": true}` |

## y3_bands/ — Theorems Y3 and U1 (every conductor), and Remark U2

Not part of the lead's C2 list; added because the paper's all-conductor constants rest on these ledgers (Y3 memo §3; REVIEW_Y3 §6,
which reproduced u20_a0/a1 and c25_a0/a1, identical in every field except wall time, and recomputed the landing independently). Copied from `dq1/Y3/scripts/`.

| file | md5 | what it is |
|---|---|---|
| y3_sweep.py | 129799ab43a0b247dc4bc5966a5a7016 | the band sweep: certifies S_chi(x, p, t) − L/4 ≥ CF for parity a, m ∈ [m_lo, m_hi], t ∈ [t_lo, t_hi], every x (G1 part 0 ≤ x ≤ 10⁴ via y3_cert.floor_box; LX part x ≥ 10⁴ via y3_big2.big2 xaware). Usage: `Y3_P=p python3 y3_sweep.py a m_lo m_hi t_hi CF prefix [tau_ratio] [t_lo]` |
| y3_cert.py | 5b375c5ba74f3c906807d2957c60d154 | G1 certifier (same as g1_rerun/) |
| y3_big.py | aa2324580d421d4604c8fb82f61b639e | helpers (same) |
| y3_big2.py | aafeba32b5f8c85d7a935d8b66967215 | LX certifier with B1–B4 (same as lx/). The band ledgers below were produced with the B1–B3 version a8f10bcd; bb re-swept every band with B4 (this file) and obtained ledgers identical in every field except wall time (REVIEW_Y3 §4, §6.1) |
| u20_a1.DONE | 4a1c199c8c7726fec7d5e4039b05d276 | odd χ, m ∈ [3, 10⁸], t ∈ [10⁻⁴, 0.499], p = 20, CF = 0.385: 3,456 G1 + 216 LX certified, 3,672 evaluations, worst G1 0.3903445661, worst LX 1.8113382786, 0 failed, complete, 39.5 s |
| u20_a1.json | 32e89db4a7a107594817e491720e0451 | full ledger |
| u20_a1.log | ec6f29e4a3a7456e068645d34a3344ec | stdout |
| u20_a0.DONE | 953e869cf388a753b6d7f46cc9ec1897 | even χ, m ∈ [5, 10⁸], t ∈ [10⁻⁴, 0.499], p = 20, CF = 0.36: 3,456 + 216 certified, 3,672 evaluations, worst G1 0.3640072680, worst LX 1.8113462562, 0 failed, complete, 39.3 s |
| u20_a0.json | 9886ba5fbf3e3ad0630d2483b9ccfdae | full ledger |
| u20_a0.log | b6f4b657f21f948f331f3efe0f1af952 | stdout |
| c25_a1.DONE | 9a2aa6dd6644ea92307adc7ce32dcf97 | odd χ, m ∈ [15 848 932, 10⁸], t ∈ [10⁻⁴, 0.282], p = 2.5, CF = −0.55: 3,464 + 201 certified, worst G1 −0.5381503336, worst LX 1.3510822241, 0 failed, 41.9 s (Remark U2) |
| c25_a1.json | 4e548396d1d0c1689496589db09cced1 | full ledger |
| c25_a1.log | 6e8c410d7fce2a88d3bae2bc7015cf6c | stdout |
| c25_a0.DONE | 7166fa3bf77d23792627c028cbf41db4 | even χ, m ∈ [36 307 806, 10⁸], t ∈ [10⁻⁴, 0.282], p = 2.5, CF = −0.76: 4,690 + 201 certified, worst G1 −0.7562929568, worst LX 1.3519438953, 0 failed, 69.5 s (Remark U2) |
| c25_a0.json | c52b2b54deb43b8373efd1b9aa55173e | full ledger |
| c25_a0.log | b4468e1b81ab3755f9fc1ed0979e9043 | stdout |
| y3_bounds.py | 628c43bdeda4a566483bcafad03740d6 | the landing bound in Arb (128-bit balls, outward): k = 4(L/4 + CF)/p − 8/(p² − q₀), T = t_min + log((2 + k(q₀ − 2t_min))/(2 + kb))/k, Λ ≤ T + b/2, asserting p² ≥ 5q₀, k > 0, T ≤ t_hi. Usage: `python3 y3_bounds.py p CF0 CF1 q0 [t_hi]` |
| bounds_u20_q916.json | a4dafb2eba8e1208ce81a68d9ca45496 | its output at q₀ = 9/16 (Theorem Y3): even m = 5 → Λ ≤ 0.27831885636621484; odd m = 3 → 0.2791114 (the first rows are shown in the paper) |
| bounds_u20_q1.json | f6a00ed3129d30b4666c8970e2c1343a | its output at q₀ = 1 (Theorem U1): even m = 5 → 0.49083455059567443; odd m = 3 → 0.4932941 |
| y3_table.py | fcbc63ed438cd2929b789516882e550a | builds the per-conductor table of Y3 memo §3.4 / §3.5 from the ten band ledgers |
| y3_table.json | a50f2af4edb1799693f3cfa058fc315d | that table (lists the ten ledgers it used; the b6/b38/b28 bands are not copied here) |
| y3_lean_consts.py | 81112efe78e2e46b8756eb1b68eddc0a | checks that the Lean-rational floors (385/1000, 3599/10000) are ≤ the float floors the sweeps compared against, and prints the Lean-rational constants 0.2791113 / 0.2783196 |
| p2z_small.py | b3753b2f721fc14735a3ce7d4de8516c | Lemma Z′ for 3 ≤ m ≤ 10⁸ (the Y3 range): P5's p2z_arb.py with only the region loop changed (L ∈ [log(3/π)↓, log(10⁸/π)↑], 200 cells, t_min = 10⁻⁴, y_b = 0.01, ℓ = 3.2·10⁵) |
| p2z_small.json | 002d6e66df8dc5ca810db4cca2c45af3 | its ledger |
| p2z_small.DONE | 5cacd90ef9eb397d8fe99c101085a9e1 | summary: 76,800 boxes, 0 failed, worst Q 0.9455107877, 2.0 s, complete |
| p2z_small.log | e91df616aa1b87d0224edec56beb3186 | stdout |

## Not copied

- P5's superseded G1 ledgers (g1_corner_a0/a1, g1_rem_a0_m3, g1_rem_a1_s1) and lx_cover_Rx.out 77cadb55: superseded, kept as
  history in `dq1/P5/scripts/`; the lead may archive them under provenance/superseded/ if a record of the defective runs is wanted.
- P5's tl_arb_cert.py 4a001119, tl_big.py 82333fd9, tl_big2.py cc065977, g1_sweep.py 5374c662: the pre-patch certifiers. The
  Y3 copies above differ from them exactly by the B1–B4 patches (`diff` reproduces them; Y3 memo §9).
- Y3's b6/b38/b28 band ledgers (the middle-range ladder) and the probe/pilot scripts: not used by any statement in the paper.
- bb's reproduction files (scratchpad y3c/, y3g1rep/, lxrep/): bb's own, listed with md5s in REVIEW_Y3 and REVIEW_Y3_G1.
