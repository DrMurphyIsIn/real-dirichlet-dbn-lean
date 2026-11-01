# REVIEW_P5_DELTA: bb's delta check of P5 (§A.9 LX/STL/domain reduction, §A.10 R1/R2 response) and the C2 G1 sweep run gate

2026-10-31. **AI review by bb, NOT an operator read-back.** No Lean or lake was run, and no P5 certifier was run. The only things run
were a copy of c2_domain.py in bb's scratchpad (p5d/) and mpmath spot checks. No team file other than this one was written.

**Object.**
- P5/memo.md **0543c8a2f57bee1eadcba4ff95c028af** (1262 lines). New since REVIEW_P5 (on 661b26a0): §A.9 (:777–878) and §A.10
  (:879–1014), via memo_pre_addendum4 (661b26a0) → memo_pre_addendum5 (b3a0cb60).
- Code read:
  - tl_arb_cert.py 250f6b11 (lgre_box, psi_a_box, floor_box return);
  - tl_cover_hard.py b97cee1d → r2_hard_a0.json f3dc996c (with .DONE);
  - r1_validate.out 22310eb4;
  - lx_cover.py 5e1e362b → lx_cover.out e1fbc08f;
  - the imports of tl_big2.py eed8d0cf and tl_big.py ff75bad7;
  - c2_domain.py f84d38a1.

## Verdict

| # | Item | Verdict |
|---|---|---|
| 1 | **R1 patch** (lgre_box) | **PASS.** The complex centre c_m = Re_mid + i·Im_mid, with r = √(rad_re² + (rad_x/2)²) and the bound r(|½ψ(c_m)| + r·sup¼\|ψ′\|), is the correct centred form. All four call sites pass wim_rad = rad(x)/2 and \|Im\|_lo = \|x\|_lo/2. psi_a_box already carried the x-radius. The 18/18 validation is consistent |
| 2 | **R2 hard-corner pilot** (a = 0) | **PASS.** The region is as specified: L ∈ [log(10⁸/π), log(10^{8.5}/π)], t ∈ [10⁻⁴, 0.05], x ∈ [0, 5]. Complete, frontier 0, 0 failures, 3 155 leaves, 0.0104 s per evaluation. The breadth-first driver tiles exactly (shared float split points) |
| 3 | LX never calls lgre_box | **CONFIRMED** from the code. lx_cover imports only tl_big2.big2 and c2_domain; tl_big2 imports only tl_big. Neither imports tl_arb_cert |
| 4 | **LX** (x ≥ 10⁴) | **PASS in method, with one coverage gap (R-x below; an 18-s fix).** Inequality (a) was spot-checked (margin ≈ γ on a grid). Steps (b)–(g) were read but not fully re-derived |
| 5 | **STL** (τ ≤ 0.0175, R ≥ 2.618) | **PASS.** Constants reproduced (mpmath): ½ψ(1.309) = −0.07952, Z(2.618) = 0.25096, Z(2.44) = 0.31081, Z₂(2.44) = 0.38600, M = 0.37288 ≤ 0.373. Nit N-c |
| 6 | A.9.0 domain reduction | **PASS.** t_min(L) = min(10⁻⁴, 4/L) and b = min(10⁻⁴, L⁻²). Λ ≤ T + b/2 by de Bruijn. k = (4/√5)(L/4 − 1) − 2 is the same k as before. Values reproduced: 0.276428 at L₀, 0.0122908 at 10³, 0.00182589 at 10⁴. L > 4·10⁴ maps into τ ≤ √(T(4·10⁴)/2) = 0.017446 and R ≥ σ′ + 1 ✓ |
| 7 | N1–N4, 9/32 | **PASS.** The N3 one-line proof \|log L\| ≤ Σ p^{−kσ}/k = log ζ(σ) is right. N2 (FGMPS Lemma 4.4, Props. 4.15–4.16, the Thm 4.3 assembly have no m hypothesis) is CITED-READ by P5; bb did not re-read it |
| — | **Run gate: the hybrid C2 G1 sweep** | **SOUND TO RUN, under conditions C1–C6** |

## R-x: a coverage gap in LX (and in any (R, τ) covering built the same way)

- lx_cover.py sets each τ-box's R-range to the min and max of `R_range` at the two τ-endpoints, ±1e−6.
- R_lo(τ) = σ′ + τ²L₀/2 is monotone, so that is fine.
- **R_hi(τ) = σ′ + (2τ²/4)·min(T⁻¹(2τ²), 4·10⁴) is unimodal.** It rises while the L-cap binds and falls after. Its peak is at
  **τ* = √(T(4·10⁴)/2) = 0.0174460**, with R_hi(τ*) = 7.7053.
- The τ-box [0.0171462, 0.0176606] contains τ*. bb's dense sampling of the same c2_domain functions gives:
  - covered up to R = 7.65476;
  - true sup **7.70530**;
  - **gap 0.0505**.
  This is the only τ-box with a gap.
- STL covers τ ≤ 0.0175, so the part of the sliver with τ ∈ (0.0175, 0.01766] and R ∈ (7.6548, R_hi(τ)] stays uncovered
  (R_hi(0.0175) = 7.6924).
- The points there have L ≈ 3.9·10⁴ ≤ 4·10⁴ and t ≤ T(L), so they are in the C2 domain.
- **Fix:** add τ* as a τ breakpoint (R_hi is monotone on each side, so endpoint evaluation is then valid), or compute the τ-box sup
  directly. Then re-run lx_cover, about 18 s.
- **The same rule must be used for the (R, τ, x) part of the sweep** (C3). "LX on the whole compact domain" (:1011) holds only after
  this fix.

## Run gate: SOUND TO RUN, under these conditions

- **C1 (acceptance in Arb).** `floor_box` returns `float(S.lower())`, which rounds to nearest, and the driver tests `S >= -K0` on that
  float. A leaf within ½ ulp of −K0 could be accepted wrongly.
  - The R2 pilot is safe, since its worst leaf is −0.99999895 (margin 1e−6 ≫ 1e−16).
  - For the sweep, return the Arb lower bound (or `math.nextafter(·, -inf)`) and compare in Arb. lx_cover's `S < -K0` test needs the
    same treatment.
- **C2 (outward domain edges).** float(log(10⁸/π)) = 17.275950858102966 lies **above** the true 17.27595085810296530 (by 7e−16), and
  float(1e−4) lies above 10⁻⁴ (by 4.8e−21). As built, the boxes miss the slivers m ∈ [10⁸, 10⁸(1 + 7e−16)) and t ∈ [10⁻⁴, 10⁻⁴ + 5e−21).
  - Round the first edges down, or state C2 with t_min := float(10⁻⁴) and m ≥ πe^{L0_float}. The bound changes only in the 16th
    digit.
  - lx_cover's τ_min·0.999 is already outward ✓.
- **C3 (τ-box R-ranges).** Use the R-x rule for every (R, τ) box: split at τ*, or take the true sup and inf over the τ-box.
- **C4 (the hybrid tiles D).**
  - Define the (L, t, x) corner explicitly, e.g. L ≤ L_c, t ≤ t_c, x ≤ x_c.
  - Exclude an (R, τ, x) box from the remainder only if an **Arb containment test** shows it lies inside the corner's image, with
    L = 2(R − σ′)/τ² and t = 2τ² enclosed. Otherwise cover it.
  - Record the corner and remainder ledgers separately, and the union argument in the memo.
- **C5 (order and cost).**
  - First run P5's two cheap measurements: the a = 1 corner pilot, and one (R, τ, x) remainder job with C1–C3 in place.
  - Then re-estimate. Keep the stated limits: ≤ 6 workers, ≤ 30-min jobs, DONE files, a running ledger.
  - The earlier 3–8 CPU-h figure came from a void (pre-R1) run and is only indicative.
- **C6 (status after a complete sweep).** C2 becomes complete only when **all** of the following hold:
  - the sweep covers the compact domain for both parities;
  - LX is re-run with the R-x fix;
  - STL holds;
  - **the Arb version of P2′ (Lemma Z)** is done. That is still float-evaluated, and it is load-bearing for the contact argument at
    b(L) = L⁻² (small b gives large X).

  Until then C2 stays PARTIAL, as P5 says.

## Nits

- **N-c (STL).** "Z(Re c₁) ≤ Z(2.618)" needs Re c₁ ≥ 2.618. But Re c₁ = R + τ²ρ, and ρ can be as low as −0.0795 at R = 2.618, a = 0.
  So Re c₁ ≥ 2.618 − 2.5e−5. Use Z(2.6179) (immaterial, since −0.175 against −1).
- **N-v.** §A.10's "LX on the whole compact domain" (:1011) and §A.9's "WORKS on the whole C2 domain" (:783) should carry R-x's
  qualifier until the re-run.

## bb's files (scratchpad p5d/)

c2_domain.py copy (f84d38a19aa6bf635cbb27a3120ef241). The gap scan was inline (dense τ sampling, 4 001 points per τ-box) and is
reproducible from the code shown in §R-x.

No RH-facing claim. C2 bounds Λ_χ for large conductor; it is not GRH. conjecture1_proved = False. AI review by bb, NOT an operator
read-back.
