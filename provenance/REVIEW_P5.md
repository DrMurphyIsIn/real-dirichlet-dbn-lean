# REVIEW_P5: bb's review of P5's C2 statement of record (unconditional large-conductor Λ_χ bound) and its G1 certifier

2026-10-31. **AI review by bb, NOT an operator read-back.** One reviewer, one session. No Lean or lake was run, nothing was built,
and no P5 script was run (I read them and their outputs). No team file other than this one was written.

**Object.** ~/rh-team/dq1/P5/memo.md **661b26a052308da81a2b0949c5442c6d** (1003 lines). I read §0, §A.1–A.8 (:35–775) closely, and the
rest for context. The statement is §A.8.5 (:748–774). The lead's review request 13 has items 1–8 and a run gate (the C2 G1 sweep,
12–25 CPU-h).

Scripts read: tl_arb_cert.py **586cb6ee** (the G1 box certifier) and tl_cover.py **edada417** (the coverage driver). Output read:
tl_cover_pilot2.out. Note: P5/scripts also holds lx_cover.py, lx_proto.py, tl_cover_Rt.py and tl_cover_Rt_a0.out, which the memo does
not describe. They are not reviewed here.

**Read at source this session (alphaXiv).**
- **Planat 2609.37164 v2:**
  - Thm 2.1 (p. 3–4, the collective contraction (y²)′ ≤ −2 − 4y²G and its pair identity (4));
  - Cor. 2.2;
  - Prop. 2.3 (p. 5, the bridge G ≥ L_η/η − 2/(η² − y²) for η ≥ √5y, with the c² ≥ 5, r² ≤ 1 numerator).
- **Hakimoglu-Brown 2610.12803:**
  - p. 9 (q′ ≤ −2 − (4q/p)S + 8q/(p² − q) for p² ≥ 5q, with its numerator factorisation);
  - Thm 9 (p. 12–13, the stepped comparison: strict barriers, compact attainment, Hermite splitting);
  - Prop. 7 (p. 11);
  - p. 11 ("these three functions are decreasing").
- **FGMPS 2610.27343:**
  - abstract and p. 7 (the conductor range 3 ≤ m ≤ 4·10⁵ for the uniform constants);
  - p. 10 (Thm 2.6, de Bruijn's strip theorem for H_t^L; Thm 2.7, finiteness for m ≤ 4·10⁵);
  - p. 19 ((4.1), the heat-kernel representation);
  - p. 34 (Thm 4.11 and (4.31), "for m ≥ 3"; (4.32) only for m ≤ 4·10⁵);
  - p. 37 (Prop. 4.14, which has no m bound);
  - pp. 43–46 (Prop. 4.17, Prop. 4.18 and its proof);
  - pp. 57–61 (§6.5 monotonicity).
- **BMOR 2005.02989:** Lemma 2.1 (p. 4), Prop. 2.2 (p. 4) and Lemma 5.6 (p. 12; (5.3) with η ∈ (0, ½]).

---

## 0. Verdict

| # | Item | Verdict |
|---|---|---|
| 1 | The t = 0 floor, for all x | **PASS** (re-derived) |
| 2 | The Gaussian-tilt identity and the effective abscissa | **PASS** (re-derived). The Gaussian form is FGMPS (4.1), which is prior art; the tilt is the completed square. N1 |
| 3 | Planat Thm 2.1 / Prop. 2.3 and H-B (18) / Thm 9 / Prop. 7, at source | **PASS.** All are as cited. The transfer to χ is correct (§3) |
| 4 | P2′ (Lemma Z): FGMPS Thm 4.3 and Prop. 4.18 beyond 4·10⁵; contact; de Bruijn at b = 10⁻⁴ | **PASS on Prop. 4.18 (re-derived)**, with one gap: N2 (Props. 4.15–4.16). Lemma Z is float-evaluated, as P5 says |
| 5 | G2 citations | **PASS.** DLMF-derived majorants re-derived; BMOR read at source. N3 |
| 6 | G1 box certifier soundness | **R1 (required): the x-radius is not enclosed in the Γ tail factors or in the normaliser.** Otherwise sound. **R2:** the pilot never reached the hard region |
| 7 | Siegel sanity | **PASS** |
| 8 | KKL_χ heuristic and its crossover | **PASS** as heuristic. N4 (supersession) |
| — | **Run gate: the C2 G1 sweep (12–25 CPU-h)** | **NOT YET. It is sound to run once R1 is patched and a targeted hard-region pilot (R2) passes.** Even a complete sweep leaves LX and LL open, so C2 stays PARTIAL (§6) |

**No RH-facing claim. Nothing left the team.** C2 is not RH: it bounds Λ_χ for large conductor, and Λ_χ ≤ 0 is GRH(χ).

---

## 1. The t = 0 floor (PASS)

- From H_0(z) = ξ_L((1 − iz)/2) and dμ/dz = −i/2, S = −Im(H′/H) = ½Re(ξ_L′/ξ_L)(μ), with μ = σ′ − ix/2 and σ′ = (1+p)/2.
- Then ξ_L′/ξ_L = ½log(m/π) + ½ψ((w+a)/2) + L′/L ✓.
- Re ψ(σ + iτ) − ψ(σ) = Σ_k[1/(σ+k) − (σ+k)/((σ+k)² + τ²)] ≥ 0, by DLMF 5.7.6 term by term ✓.
- |L′/L| ≤ −ζ′/ζ(σ′), since σ′ = 1.618 > 1 at p = √5 ✓.
- So S(x, p, 0) ≥ F for every x ✓. It is unconditional and survives a Siegel zero ✓.

## 2. The Gaussian-tilt identity (PASS; N1)

- H_t(z) = ∫e^{tu²}Φe^{izu}, and E_g[e^{i(z + i√(2t)g)u}] = e^{izu}E[e^{−√(2t)gu}] = e^{izu}e^{tu²}. So **H_t(z) = E_g[H_0(z + i√(2t)g)] exactly**
  (Fubini is fine: Φ decays doubly exponentially) ✓.
- Hence H_t(x + ip) = E[ξ_L(μ + τg)], with τ = √(t/2) ✓.
- **Tilt.** ξ_L(w) = (m/π)^{(w+a)/2}F(w), and Cameron–Martin, E[e^{βg}f(g)] = e^{β²/2}E[f(g + β)] with β = τℓ/2, gives μ_t = μ + (t/4)ℓ and
  C = (m/π)^{(μ+a)/2}e^{tℓ²/16} ✓.
- F = Γ((w+a)/2)L(w) is entire, because Γ's poles at w = −a − 2k meet L's trivial zeros ✓. E[|F|·e^{…}] converges, since the Gaussian beats
  Γ's factorial growth ✓.
- S = ¼ℓ + ½Re(E[F′]/E[F]) ✓.
- **N1.** The Gaussian representation is **FGMPS (4.1)** (and Polymath §4), not new. Cite it. "bb's effective abscissa is exact as a
  Gaussian centre" is a fair reading of the completed square.

## 3. Planat and H-B at source, and the transfer to χ (PASS)

- Planat Thm 2.1, Cor. 2.2 and Prop. 2.3 are as quoted. The bridge proof uses only "even, real, order one" and maximality (r = v/y ≤ 1)
  ✓. FGMPS Lemma 2.5 gives evenness and reality for H_t^L, and FGMPS's setting gives order 1 ✓.
- H-B p. 9 (18), Thm 9 and Prop. 7 are as quoted. With p = √5 and q ≤ 1, 8q/(5 − q) ≤ 2q, so q′ ≤ −2 − kq with **k = 4C/√5 − 2** ✓.
- **Two adaptations, both correctly made by P5.**
  - (i) H-B needs the S-floor only for x ≥ X, because Polymath's finite-region computation (their Lemma 2) puts the contact zero
    there. **For χ there is no such input, so the floor must hold for all x.** P5 states it that way ✓. That is exactly why lemma LX
    (x ≥ 10⁴) is load-bearing: by P2′, contact zeros can sit at |x| up to X(m, t), which is 10^{60} at t = 0.1 and ≈ 10^{4·10⁴} at
    t = 10⁻⁴.
  - (ii) H-B's compactness, via Polymath Thm 1.5(i) (|x| < e^{C/t}), is replaced by P2′. X(m, t) is finite and non-increasing in t, so it
    is uniform on [t_min, ½] ✓.
- **The bound's arithmetic (bb).** On [0, t_min], de Bruijn gives M² ≤ 1 − 2t_min. The comparison from there to q = b takes
  Δ = k⁻¹log((2 + k(1 − 2t_min))/(2 + kb)), and de Bruijn adds b/2 (FGMPS Thm 2.6) ✓.
  - **T(10⁸) = 0.2764282** ✓ (C = 3.3190, k = 3.9372).
  - The formula equals 9/32 at m = 10^{7.8328} ✓.
  - Values: 0.2312 (10¹⁰), 0.1690 (10¹⁵), 0.1359 (10²⁰), 0.0680 (10⁵⁰).
  - Asymptotically √5·loglog m/log m ✓.
- **Statement nit.** The theorem is stated for m ≥ 10⁸, so "below 9/32 for every m ≥ 10^{7.83}" should read "for every m ≥ 10⁸ (the
  formula itself crosses 9/32 at 10^{7.833})".

## 4. P2′ and FGMPS Prop. 4.18 beyond 4·10⁵ (PASS; N2)

- **At source, Prop. 4.18 assumes 3 ≤ m ≤ 4·10⁵.** Its proof's m-dependence is only through ℓ = log m + log(x/4π) (eq. 4.42 and items (1), (4),
  (5)) and through B*_m (item (6)). bb re-derived each item:
  - **Item (1):** the m-free part 4/x² + log(x/4π)/(8·478) + π/(16·478) + 1/(2·478²) = 0.001384 ≤ 0.002 at x = 480, and it decreases. The m
    part is log m/3824 ≤ log m/3800 ✓.
  - **Items (4)–(5):** 5/4 + π²/256 + (log(x/4π) + π/2)/3824 + … = 1.2901 ≤ 1.3, and log m/3824 ≤ log m/2250 ✓.
  - **Item (6)** keeps B*_m. Thm 4.11 (4.31) is stated **for m ≥ 3** at source. The 3.33 constant is (4.32), range-specific ✓.
  - Prop. 4.14 has no m bound ✓. The §6.5 monotonicity steps (√(a/c) < 0.110 since c ≥ 1.3; mT′/2π > 81) hold for all m ✓.
- **N2 (gap in "line by line").** Props. **4.15 and 4.16** (the e_A and e_B bounds) and the assembly of Theorem 4.3 are not listed among
  the results P5 checked for m-range. Check them, or cite their hypotheses, before calling Thm 4.3 valid for every m ≥ 3.
- **Contact argument.**
  - Contact happens only while Q ≥ b. P2′ with y_b = √b confines such zeros to |x| < X(m, t). The strict-barrier and Hermite-splitting
    argument (H-B Thm 9 proof) then applies ✓.
  - Finiteness of all non-real zeros is not needed ✓.
  - de Bruijn at b = 10⁻⁴ adds b/2 ✓.
- **Lemma Z** is float-evaluated (log₁₀X = 32.3 … ≈ 4·10⁴), as P5 says. An elementary Arb check remains.

## 5. G2 citations (PASS; N3)

- **DLMF 5.15.1, 5.7.6 and 5.6.6.** The derived majorants are re-derived:
  - |ψ′(u+iv)| ≤ 1/(u²+v²) + min(1/u, π/(2v)), via ∫₀^∞ds/((u+s)² + v²) = (π/2 − arctan(u/v))/v ≤ min(π/(2v), 1/u) ✓;
  - |Im ψ(u+iv)| ≤ π/2 + 1/(2u) ✓;
  - Re ψ(u+iv) ≥ ψ(u) ✓.
- **BMOR at source.** Lemma 2.1 ✓. Lemma 5.6 (5.3) is Rademacher's convexity bound for −η ≤ σ ≤ 1+η, **with η ∈ (0, ½]**. P5's
  δ ∈ [0.1, 0.5] and the certifier's δ = 0.25 are in range ✓.
  - **N3.** BMOR Prop. 2.2 is the *argument* bound. The |log L| ≤ log ζ(σ) step is in its proof (via Lemma 2.1). Cite it that way.
  - The Rademacher original (1959) is read through BMOR only, as P5 states.
- **FGMPS Lemma 4.2(5)** (log Γ(y) ≤ y log y − y + 1, y ≥ 3.5) was not read by bb. It is TRUE independently by Stirling:
  −½log y + ½log 2π + 1/(12y) ≤ 0.317 ≤ 1 at y = 3.5, decreasing.

## 6. The G1 certifier (R1, R2) and the run gate

**What is sound** (tl_arb_cert.py read in full):
- **Bulk (Re w ≥ 1 + δ).** The exponent e(g) = (τg)²M/2 + τ|g|Z(u_min) bounds both pieces:
  - |log Γ_a(c+τg) − log Γ_a(c) − τgψ_a(c)|, by Taylor along the segment with M = sup|ψ_a′| from the trig majorant at Im = −x/2 and
    |x| ≥ x_lo;
  - |log L(c+τg) − log L(c)|, by the first-order bound with −ζ′/ζ decreasing ✓.
  - The tilted Gaussian N(τρ, 1), and D₀ ≥ e^{−τ²ι²/2} − P(B^c) − ∫_B(e^{e} − 1), are correct ✓.
  - D₁ uses |h − ψ_a(c)| ≤ τ|g|M + Z(u) ✓.
  - The right-tail closed form uses x + Z ≤ (1 + Z)eˣ and A₂ = 1 − τ²M_max > 0 ✓.
  - Interval Riemann sums of non-negative integrands ✓.
- **Tails (Re w < 1 + δ).**
  - The Rademacher branch for u ≥ ½ and the FE branch for u < ½ (|F(w)| = (m/π)^{(1−2u)/2}|Γ_a(1−w)||L(1−w)|, ε = 1) are right ✓.
  - The F′ tail by integration by parts, including the boundary term φ(g₀)/τ ✓.
  - The far-left half-line: Stirling at y_m ≥ 3.5, the v²/(8y_m) ≤ v²/(4y_m) curvature allowance, and ζ(2) for 1 − u ≥ 2 ✓.
  - U_MIN is cut so that the Gaussian beats e^{−πx/8} ✓.
- **Normalisation.** Tails are normalised by |Γ_a(c)|ζ(2R)/ζ(R) without the e^{τ²ρ²/2} factor. That over-estimates the tail, which is
  conservative ✓.
- **The coverage driver** (tl_cover.py) is sound: a box counts only if its certified value is ≥ −K₀, failures are kept, and "complete"
  means stack empty and no failures ✓.

**R1 (required, before any sweep): the box's x-width is not enclosed in the Γ factors of the tails or in the normaliser.**
- `lgre_box(wre, wim_abs_lo, wim_mid, a)` evaluates Re log Γ((w+a)/2) at the centre (wre.mid, **wim_mid**). Its error radius is
  r = wre.rad() only, the u-direction.
- The imaginary part is fixed at −x_mid/2 (or +x_mid/2 in the FE branch). It is used:
  - (a) for every tail cell's Γ factor (lgw, lgs, lgw0);
  - (b) for **lognorm** = lo(Re log Γ_a(c)) + …, also at x_mid.
- But **|Γ| decreases in |Im|**, so the box's sup of the tail and inf of the normaliser sit at different x. The returned bound is
  therefore **not valid over the whole x-box**.
- The size: |∂_x log|Γ((u+a)/2 ∓ ix/4)|| = ¼|Im ψ| ≤ ¼(π/2 + 1/(2σ)) ≤ 0.893 for σ ≥ ¼. So the tail ratio can be off by a factor up to
  **e^{1.79·r_x}**, where r_x is the box's x-half-width: 1.25 at r_x = 0.125.
- **Patch, either way:**
  - pass the x-ball into the centred form, with r = √(wre.rad² + (xb.rad/2)²) and the derivative bound already present; or
  - multiply DT0 and DT1 by exp(2·¼(π/2 + 1/(2σ_min))·xb.rad()).
- Numerically this is small: the tails are ~(m/π)^{−0.31} ≈ 4e−3 at m = 10⁸, against a margin of ~0.1–0.2. But **as written the certificate
  is not rigorous over x-boxes**. Re-run the validation points after patching.

**R2 (required before committing the CPU): the pilot never reached the hard region.**
- tl_cover_pilot2.out reports **worst_certified = +0.416** (S − L/4) against the target −1.0, with **233 boxes remaining**.
- Those remaining boxes are the untouched small-t initial boxes (depth-first order), i.e. exactly the region near the true minimum
  (S − L/4 ≈ −0.84 as t → 0, x ≲ 5, where P5's own estimate puts the margin at ≈ 0.1–0.2).
- So "8 669 boxes, 0 failures" certifies only the easy region. **Run a targeted pilot on t ∈ [10⁻⁴, 0.05], x ∈ [0, 5]** (one parity,
  one L-slab) with the R1 patch, to measure feasibility and the real per-box cost before the sweep.

**Run gate: NOT YET.**
- The method is sound in architecture: the bulk, tails and coverage are correct, and the inputs are confirmed at source.
- **Once R1 is patched and the targeted hard-region pilot passes, the G1 sweep is SOUND TO RUN.**
- Recommendation on order. A complete G1 sweep over [10⁸, 10²⁰] × x ≤ 10⁴ still leaves:
  - **LX (x ≥ 10⁴)**, load-bearing because contact zeros can sit at |x| ≤ X(m, t), which is astronomically large;
  - **LL (m > 10²⁰)**.
- C2 stays PARTIAL until both are done. LX is analytic and cheap to attempt: at x = 10⁴ the floor already clears the target by
  ≈ ¼log(x/8) − 1 ≈ 0.78, and |x|-monotonicity comes from DLMF 5.7.6. **Attempt LX before, or in parallel with, the sweep**, so the
  12–25 CPU-h buys a theorem.

## 7. Siegel sanity and KKL (PASS; N4)

- **Siegel.** A real zero β of L gives an imaginary-axis zero of H_0 at height |1 − 2β| ≤ 1. That is inside q₀ = 1, so it is allowed ✓. The
  rate is ≥ (√5 + o(1))loglog m/log m ≫ 1/log m ✓, so nothing excludes Siegel zeros.
- **KKL.** The C_K(ℓ) table and the crossover are re-checked:
  - at 10¹⁵ (ℓ ≈ 32), C_K ≈ 5.65 gives t_K ≈ 0.177, against C2's 0.169;
  - at 10²⁰ (ℓ ≈ 43.5), C_K ≈ 5.41 gives t_K ≈ 0.124, against 0.136.
  - So **KKL wins only from about 10^{16–17}**, and only heuristically ✓.
- **N4.** §A.6(iii) ("KKL wins only at log m ≳ 390", with C = 9.9) is superseded by §A.7.3 (C_K → 4.95, crossover 10^{16–17}). Mark the
  supersession.

## 8. Not checked

- Lemma Z's numerics.
- FGMPS Props. 4.15–4.16 and Thm 8.1(2) (N2).
- The c2/tl float scans.
- lx_cover.py, lx_proto.py and tl_cover_Rt.py (not in the memo).
- The Telperion-emitted numerators (H-B, Planat bridge, tail square). I note that the Planat numerator in the memo, (c²−1)(c²−5) at
  r² = 1, is exactly Prop. 2.3's.

conjecture1_proved = False. AI review by bb, NOT an operator read-back.
