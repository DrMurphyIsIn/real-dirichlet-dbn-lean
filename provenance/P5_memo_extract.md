# P5 memo, EXTRACT for the version-2 release (sections A.3 and A.6–A.13 only)

This file is an extract of the P5 session's memo `dq1/P5/memo.md`, whose full md5 is
**e3676c4cd7e0dd16a68e1d04c8d33511** (1,775 lines; dated 2026-10-31; title "DQ-1 repair wave, agent P5: DQ-1's plan review,
dive 1 (R1-R4) and E3"). The full memo is held internally by the programme and is not published: most of it concerns a research
dive on other questions and is unrelated to the bounds on Λ_χ. The sections below are reproduced VERBATIM (byte for byte) from
the full memo, at the line ranges given; nothing inside them was edited. The reviews REVIEW_P5*.md cite the full memo by its
md5 and by section number; the section numbers are unchanged here.

| extract part | full-memo lines | content |
|---|---|---|
| §A.3 | 139–151 | the t = 0 floor, uniform in x (PROVED) |
| §A.6–§A.13 | 410–1530 | addenda 1–7 (the Gaussian tilt §A.6; the transfer lemma §A.7; G1 certification and the C2 statement §A.8; LX, LL and the (R, τ, x) reparametrisation §A.9; responses to bb §A.10–A.11; P2′ in Arb §A.12) and §A.13, the C2 statement of record |

Labels used in the memo (from its header): CITED-READ = read at source with the page given; PROVED = an argument written out,
elementary, not reviewed at the time of writing; COMPUTED = float, not certified; CERTIFIED (Arb) = python-flint ball
arithmetic; FROM MEMORY = never load-bearing; RECORD = an earlier team memo, context only. The memo's own header states:
"This is AI work by P5 alone. It has had four bb reviews: REVIEW_P5 e909a59c (answered in §A.10), REVIEW_P5_DELTA 206b88e7
(answered in §A.11), REVIEW_P5_A11 e570fc33 and REVIEW_P5_A12 f6cade54." and "Nothing here is progress on RH. C2 is a
large-conductor bound on Λ_χ, not GRH." The G1 and LX outputs named in §A.13.3 rows 4a and 4b were later SUPERSEDED
(P5_SUPERSEDED.md); the certificates of record are in certificates/.

---

<!-- full memo lines 139-151: §A.3 -->
**A.3 The t = 0 floor, uniform in x (PROVED).**
- With s′ = (1+p)/2 − ix/2 and σ′ = (1+p)/2, the functional equation ξ_L(s) = ξ_L(1−s) (ε = 1 for real χ: FGMPS (2.9)–(2.10))
  gives
  S(x, p, 0) = ¼ log(m/π) + ¼ Re ψ((s′+a)/2) + ½ Re L′/L(s′).
- Two bounds then apply:
  - Re ψ(σ+iτ) − ψ(σ) = Σ_k [1/(σ+k) − (σ+k)/((σ+k)²+τ²)] ≥ 0;
  - |L′/L(s′)| ≤ −ζ′/ζ(σ′).
- So, for every x ∈ ℝ:
  **S(x, p, 0) ≥ F(m, p, a) := ¼ log(m/π) + ¼ ψ((σ′+a)/2) + ½ ζ′/ζ(σ′).**
  This is unconditional. It needs no zero verification and survives a Siegel zero.
- Validation (`c2_validate`): the u-quadrature of S agrees with the formula's exact value to ≤ 8e−9 at x ≤ 45, for m = 1009
  and m = 1019.


<!-- full memo lines 410-1530: §A.6-§A.13 -->
### A.6 Addendum 1: follow-up on bb's review of dive 1 (REVIEW_DQ1_DIVE.md, md5 079d10c5, §1.2, §5 and §7)

**(i) Falsifier on bb's full scope (COMPUTED, `c2_scan2`, `c2_mp_largex_q916`).**
- Grid:
  - p = √(5q₀), for q₀ = 1 (p = √5) and q₀ = 9/16 (p = 3√5/4 = 1.677, the column conditional on OAI);
  - t ∈ [0, 0.5] in steps of 0.025, which contains [0, T(m)] in every case (T(m) ≤ 0.461);
  - x ∈ [0, 1] in steps of 0.005, plus [1, 60] in steps of 0.05, in float64;
  - a 60-digit re-check of x ∈ [40, 200] at m = 1000033 for both p.
- **Result at all 8 conductors (10³–10⁶, both parities) × both q₀:**
  - inf_x S(x, p, t) is non-decreasing in t on the whole of [0, 0.5];
  - the minimum over (x, t) is at t = 0 (at x = 0, or x ≈ 4 for odd m ≈ 10⁵, 10⁶);
  - for x ≥ 40 the floor is far higher (3.62 against 2.47 at q₀ = 9/16).
- **Landing times (unconditional apart from P1/P2):**
  - q₀ = 1: T = 0.434 (10009), 0.394 (10007), 0.350 (100049), 0.322 (100003), 0.312 (1000033), 0.286 (1000003).
  - q₀ = 9/16 (also conditional on OAI): T = 0.268 (10007), 0.242 (100049), 0.218 (100003), 0.216 (1000033),
    0.193 (1000003); none at 1009, 1019 and 10009.
  - bb's sanity rule holds. Every rate here is ≥ log log m/log m ≫ 1/log m, so nothing excludes Siegel zeros.

**(ii) P1: an exact representation that makes bb's "effective abscissa" an identity (PROVED; checked numerically to 1e−15).**
- **Step 1, Gaussian form.** [Prior art (bb N1, CITED-READ): this is FGMPS 2610.27343 (4.1), p.19, H_t(z) = ∫ξ_L((1+iz)/2 + √t v)e^{−v²}/√π dv, which FGMPS take from Polymath §4; set v = g/√2. The contour shift in Step 2 is the same device as FGMPS (4.6)–(4.7), p.21. What is new here is only its use for a uniform-in-x floor on S.] From ∂_tH = −∂_z²H:
  H_t(z) = E_g[H_0(z + i√(2t)g)], with g ~ N(0,1).
  With H_0(z) = ξ_L((1+iz)/2) and the FE, at z = x + ip:
  **H_t(x+ip) = E_g[ξ_L(μ + τg)]**, where μ = (1+p)/2 − ix/2 and τ = √(t/2).
  `c2_gauss_identity`: agreement to ≤ 1e−15 relative at m = 10009, t ∈ {.1, .3, .5}, x ∈ {0, 3, 10}.
- **Step 2, the exact tilt.** Write ξ_L(w) = (m/π)^{(w+a)/2}F(w), with F(w) = Γ((w+a)/2)L(w) entire. Completing the square in g
  absorbs the factor (m/π)^{τg/2} exactly:
  H_t(x+ip) = C·E_g[F(μ_t + τg)], with **μ_t = μ + (t/4)log(m/π)** and C = (m/π)^{(μ+a)/2}e^{(t/16)log²(m/π)}.
  Since dμ/dz = −i/2:
  **S(x, p, t) = ¼ log(m/π) + ½ Re( E_g[F′(μ_t+τg)] / E_g[F(μ_t+τg)] ).**
  bb's sketch "Re s* ≈ (1+p)/2 + (t/4)log(m/π)" is therefore exact as a Gaussian centre.
- **Step 3, the natural predictor.** F_t := ¼log(m/π) + ¼ψ((R+a)/2) + ½ζ′/ζ(R), with R = Re μ_t. This is the t = 0 floor of
  §A.3 evaluated at the shifted centre.
  - Measured, `c2_scan2`: min_t (inf_x S − F_t) ranges from −0.11 (m = 1009) through −0.04 (10009) and −0.001 (1000033) to
    +0.17 for odd m.
  - So F_t is near-sharp, and the defect shrinks as m grows.
- **Step 4, tails (PROVED, the key exponent).**
  - Let v = σ′ − u ≥ 0 measure how far a Gaussian node sits to the left of σ′ = (1+p)/2, with u = Re w.
  - The Gaussian weight at u has exponent −(v + (t/4)L)²/t, with L = log(m/π).
  - For u < 0, the FE growth of ξ_L relative to the centre is (m/π)^{(1/2−u)} (times Γ factors).
  - The net exponent is −[(v/√t − √t L/4)² + (p/2)L] ≤ −(p/2)L.
  - So **the mirror region is suppressed by (m/π)^{−p/2}, uniformly in t ∈ (0, ½]** (for p = √5 that is m^{−1.118}).
  - In the strip 0 ≤ u ≤ 1 the same algebra gives at least (m/π)^{−(σ′−1)/2}, i.e. m^{−0.309} at p = √5. This uses a
    convexity bound for L, FROM MEMORY; it needs a source or a proof.
  - **Telperion:** `prove` returns a kernel-checkable SOS for 0 ≤ v² − tvL/2 + t²L²/16 = (v − tL/4)², and `psd` gives an exact
    LDLᵀ for [[16, −4], [−4, 1]] (rank 1). Both are in §6.
- **Step 5, the bulk (PROVED, elementary).**
  - Write ν = F·φ/E[F], a complex probability measure, and h = F′/F. Then E[F′]/E[F] = ∫h dν and
    Re ∫h dν ≥ Re h(μ_t) − V·τ·E|g|·sup_bulk|h′| − (tails), with V = ∫|F|φ/|E F|.
  - Re h(μ_t) ≥ ½ψ((R+a)/2) + ζ′/ζ(R), as in §A.3.
  - So **P1 reduces to (P1′):** V ≤ V₀ and sup|h′| ≤ H₀ on the Gaussian bulk, uniformly in x, for m ≥ m₀.
  - (P1′) is a Stirling-plus-Dirichlet-series estimate at Re w ≥ 1 + δ. It contains no zero information.
- **What remains for P1:**
  - (P1′), with explicit V₀ and H₀ uniform in x: for large |x| the analytic conductor ℓ = log(m(|x|+3)/π) replaces L in Step 4,
    because Γ adds its own tilt (t/4)log|x/4| and this only helps;
  - a sourced convexity bound in the strip.

  The architecture is complete; the bookkeeping is not done.

**(iii) P2 and bb's competitor are one lemma (KKL_χ; sketch, not proved).**
- On p = 0 at time t, the same tilts put the n-th Dirichlet term at about n^{−1/2−(t/4)(ℓ−log n)}. For n up to the
  Riemann–Siegel cutoff (log n ≤ ℓ/2) that is ≤ n^{−1/2−(t/8)ℓ}.
- The Dirichlet part is therefore 1 + ε with |ε| ≤ ζ(½ + (t/8)ℓ) − 1 < 1 once (t/8)ℓ ≥ 1.23, ignoring the RS remainder and the
  reflected leg.
- That yields:
  - **P2:** zeros with m(|x|+3)/π ≥ e^{9.9/t} are real and simple (finiteness and confinement, with m-dependent constants);
  - **the competitor:** if m/π ≥ e^{9.9/t}, then all zeros are real, i.e. Λ_χ ≲ 9.9/log(m/π).
- This is heuristic. The constant ignores the remainder terms; bb's crude count gives C ≈ 30.
- **Comparison.**
  - C2's (√5 + o(1))log log m/log m is smaller than 9.9/log m until log(log m/2√5) > 9.9/√5, i.e. log m ≳ 390. [SUPERSEDED (bb N4) by §A.7.3: the heuristic constant and this crossover are not used anywhere in C2.]
  - So **C2 is the better bound at every practical m, and KKL_χ wins only asymptotically.**
  - Both are ≫ 1/log m and consistent with the Siegel sanity rule.
  - At m = 10⁷: C2 gives 0.282; KKL_χ (C = 9.9) gives 0.66.
- **Recommendation for a mini-round:** prove KKL_χ first. It is needed anyway as P2, and it gives the clean C/log m statement.
  Then run C2 on top of it for the practical constants.

**(iv) Errata from bb that this memo inherits.**
- **E1.** Under PLAN's definition (inf over all real t), the closed forms carry no max(0, ·):
  - bb's: Λ(cos z + a cos 2z) = ⅓log(1/|a|);
  - mine: Λ(cos √2z + a cos z) = log|a|.

  Both are corrected above.
- **E2.** My §G "chirped class" dichotomy inherits bb's scope correction for R2 C1:
  - it is proved only for t ≤ ½;
  - ζ is in class G at no t, because of the pole;
  - the genuinely instant form is for a pole-free real primitive L(s, χ) under GRH (3 ≤ m ≤ 4·10⁵, via FGMPS Prop 8.2(1)).

  §G is to be read with t ∈ (0, ½].
- **E3.** "(FIN)" in §A.5 is bb's P2. Its route is (iii) above.

### A.7 Addendum 2: the transfer lemma TL, finiteness P2 and bb's KKL competitor (lead's request, 2026-10-31)

Outcome of each step:
- **Step 1, TL:** PARTIAL, the strongest form so far. The proof chain is complete and the final explicit inequality has been
  *evaluated* in float on a grid, but it is not certified.
- **Step 2, P2:** PARTIAL. It reduces to FGMPS's own estimates with m-dependent constants. One FGMPS proof is still unread.
- **Step 3, KKL:** PARTIAL (heuristic). It does give C/log m, with C → 4.95. It beats √5·loglog m/log m only for
  m ≳ 10^{16–17}, and it needs a strictly harder input than TL.

**1a. Obstruction met by the mirror split, and the way around it.**
- The lead's suggested route was H_t = A_t(z) + A_t(−z). Termwise:
  A_t(−z) = Σ_n χ(n) n^{−s′} n^{−(t/4)L} e^{(t/4)log²n} · G_t(c_n, πn²/m)/G_t(c₁, π/m) · (main),
  with incomplete-gamma-type factors G_t. This reproduces the lead's J_n/J_1 formula exactly (PROVED, by the substitution
  u ↦ u − ½log n).
- **The obstruction (PROVED sketch).** Each leg contains the endpoint piece of the split at u = 0, which is
  ≈ (π/m)^{c}/c relative to (m/π)^{c}Γ(c). Its size is ~1/|c| and does not decay in x, while H_t ~ e^{−π|x|/8}.
  - The endpoint pieces of the two legs cancel only against each other.
  - So any termwise absolute bound on the split loses the archimedean cancellation once |x| ≳ (8/π)·Re c·L ≈ 2L.
  - **The mirror split proves TL only on |x| ≲ 2L.**
- **The way around it.** Use the exact Gaussian-tilt form of §A.6, which never splits:
  - S = L/4 + ½Re(D′/D)(c), with D(c) = E_g[Φ(c+τg)], Φ = Γ((w+a)/2)L(w), c = R − ix/2, R = σ′ + tL/4, τ = √(t/2).
  - In the bulk (Re w ≥ 1+δ), Γ is explicit and the archimedean decay is exact.
  - The tails (Re w < 1+δ) are controlled by Rademacher's bound together with the functional equation, and the
    completed-square exponent of §A.6 suppresses them by a power of m.

**1b. The explicit floor (all labels as marked; code `tl_bound.py` and `tl_bound2.py`).**
- **Inputs:**
  - BMOR 2005.02989, Lemma 2.1 (p.4, CITED-READ): ζ(2σ)/ζ(σ) ≤ |L| ≤ ζ(σ) for σ > 1;
  - BMOR Lemma 5.6, (5.3) (p.12, CITED-READ; Rademacher 1959): |L(s)| ≤ ζ(1+η)((q/2π)|s+1|)^{(1+η−σ)/2} on
    −η ≤ σ ≤ 1+η, for primitive χ with q > 1;
  - |L′/L(σ+iv)| ≤ −ζ′/ζ(σ) and |(L′/L)′| ≤ (ζ′/ζ)′(σ) = Σ Λ(n)log n·n^{−σ} (Euler product; PROVED);
  - the functional equation |ξ_L(w)| = |ξ_L(1−w)| (FGMPS (2.9)–(2.10), CITED-READ);
  - the trigamma series majorant |ψ′(u+iv)| ≤ 1/(u²+v²) + min(1/u, (π/2 − arctan(u/v))/v);
  - Re ψ(u+iv) ≥ ψ(u) and |Γ(u+iv)| ≤ Γ(u).

  The last two lines use the standard series and integral definitions. They are FROM MEMORY as identities, PROVED from them,
  and checked numerically in `tl_checks.py` (COMPUTED).
- **Version 1 (first order around ψ_a(c)):**
  S ≥ L/4 + ½Re ψ_a(c) − ½K₂, with K₂ = (Δ₁ + Δ_T1 + |ψ_a(c)|Δ_T0)/(Δ₀ − Δ_T0), where:
  - Δ₀ = e^{−τ²ι²/2} − P(B^c) − ∫_B (e^{e(g)} − 1) dN(τρ, 1);
  - Δ₁ = ∫_B e^{e(g)}(τ|g|M + Z(u)) dN(τρ, 1);
  - e(g) = (τg)²M/2 + τ|g|Z(u_min);
  - Δ_T0 and Δ_T1 are the Rademacher/FE tail integrals, normalised by |Γ_a(c)|·ζ(2R)/ζ(R)·e^{τ²ρ²/2}.
  - The Φ′-tail is integrated by parts in g, so that only |Φ| is needed:
    E[Φ′1_{g<g₀}] = τ^{−1}[Φ(w₀)φ(g₀) + ∫_{g<g₀} Φ·g·φ].
- **Version 2 (second order around β = ψ_a(c) + L′/L(c)):**
  - The remainder is |E| ≤ (τg)²(M + Z₂)/2.
  - The bound is minimised over the unknown Re L′/L(c) ∈ [−Z(R), Z(R)], with |Im β| ≤ |ι| + Z(R).
  - The floor is the larger of versions 1 and 2, maximised over δ ∈ {0.1, …, 0.5}. Every choice gives a valid bound.
- As t → 0 the floor tends to the PROVED t = 0 floor F of §A.3.

**1c. Results (float; `tl_grid.py`).**
- **Grid:**
  - 15 times in (0, 0.5], covering [0, T(m)];
  - 23 heights x ∈ [0, 10⁵];
  - the conductor ladder m = 10⁵ to 10⁵⁰, both parities;
  - p = √5 (q₀ = 1, the unconditional column).
- **Validation (`tl_validate.out`):** the explicit floor is ≤ the measured inf_x S at all 12 checked (m, a, t). This is the
  expected direction; no evidence of a bug.

| log₁₀ m | C_low even (argmin) | T(C_low) even | C_low odd | T(C_low) odd | ¼L − C_low (even / odd) |
|---|---|---|---|---|---|
| 6 | 1.937 (t=.125, x=0) | 0.375 | 2.349 | 0.337 | 1.23 / 0.82 |
| 7 | 2.809 (t=.075) | 0.305 | 3.073 | 0.289 | 0.93 / 0.67 |
| 7.25 | 2.990 | 0.294 | 3.234 | **0.2806** | 0.90 / 0.65 |
| 7.75 | 3.318 | **0.2764** | 3.533 | 0.266 | 0.86 / 0.64 |
| 8 | 3.477 (t → 0) | 0.269 | 3.679 | 0.260 | 0.84 / 0.64 |
| 10 | 4.638 | 0.226 | 4.838 | 0.220 | 0.83 / 0.63 |
| 15 | 7.528 | 0.166 | 7.726 | 0.164 | 0.82 / 0.62 |
| 20 | 10.417 | 0.134 | 10.614 | 0.133 | 0.81 / 0.61 |
| 50 | 27.690 | 0.0675 | 27.886 | 0.0672 | 0.81 / 0.61 |

- **m₀, explicit.** The floor gives k > 0 (the contraction applies) from m = 10⁵ (odd) and 10⁶ (even).
- **Λ_χ < 9/32 unconditionally** from m ≈ 10^{7.25} (odd) and m ≈ 10^{7.75} (even), given P2.
- From m ≈ 10⁸ on, the argmin is at t → 0. The explicit t > 0 floor then sits within 0.01 of the t = 0 floor F, so §A.5's
  T(m) table applies as stated.
- **The TL statement this supports:** for every real primitive χ with conductor m ≥ 10⁸, every x ∈ ℝ and every
  t ∈ [0, ½],
  **S_χ(x, √5, t) ≥ ¼log(m/π) − 0.85.**
  Consequently, given P2, Λ_χ ≤ T(¼log(m/π) − 0.85) (≤ 0.269 at 10⁸, and ~√5·loglog m/log m).
- **Siegel sanity:** every rate here is ≥ (√5 + o(1))loglog m/log m ≫ 1/log m. A Siegel zero enters only through
  q₀ = 1, which is unconditional.
- **Gaps that keep TL at PARTIAL:**
  - (G1) The final inequality is float-evaluated on a (t, x) grid and on ladder points of m. It is not certified, and
    monotonicity between grid points is not proved. Certifying it needs Arb over parameter boxes, which is a Telperion-shaped
    job for the lead.
  - (G2) The special-function series identities are FROM MEMORY. They are textbook and numerically checked, but they should
    be cited (DLMF 5.15.1, 5.4) before the gate.

**2. P2: finiteness and confinement of the non-real zeros for every m (PARTIAL).**
- **Read at source this session** (FGMPS 2610.27343):
  - Thm 2.7 and its proof for 0 < t ≤ ½ (p.10): Thm 8.1(i)–(ii) imply that zeros of large |Re| are real and simple;
  - Thm 8.1 (p.80);
  - Prop 8.2 and the proof of (1) (pp.81–82);
  - Thm 4.3 and Prop 4.18 (pp.19, 43–44, with explicit m-dependence: a_m = 0.002 + log m/3800, the log m/2250 terms, and
    B*_m);
  - the B*_m bound via f(m) = e^{π/(4m)}(log m/(2π) + A₀ + 10⁻⁹)√m-type, increasing in m (p.35).
- **Where m ≤ 4·10⁵ is used (CITED-READ, p.82):** "The fixed conductor range also gives ℓ = log x + O(1) and
  B*_m + φ(m)/√x = O(1)", plus the numeric B*_m < 3.33√m (p.44).
- **The per-m version.**
  - Keep ℓ = log(mx/4π) and B*_m ≤ f(m)√m.
  - The key step of Prop 8.2(1) becomes, using log n ≤ ℓ/2:
    (1+y)/2 + (t/4)(ℓ − log n) ≥ (t/8)ℓ.
    This is better than FGMPS's (t/16)log x.
  - With r = (t/8)ℓ ≥ 2, the Dirichlet tail is ≤ 3·2^{−r}.
  - The remaining errors are ℓ²/x + x^{−1/4} and e_{C,0} ≪ (mx)^{−1/4}e^{−tℓ²/16}(f(m)√m + m/√x). Both are explicit and small
    for x ≥ X(m, t).
  - Here X(m, t) := max{(4π/m)e^{16/t}, X_err(t), X_C(m, t)}. It is finite for every m and non-increasing in t.
  - Hence (sketch): every zero of H_t^χ with |Re z| ≥ X(m, t) is real and simple.
  - The zeros in the compact set |Re z| ≤ X, |Im z| ≤ 1 are finitely many, so there are finitely many non-real and
    multiple zeros (Prop 3.2 splitting).
  - Confinement is uniform on any [t₁, ½] with t₁ > 0, which is what H-B's contact argument (Thm 9 proof) needs.
- **Not done:**
  - the disk-counting step Thm 8.1(2) for general m (its proof was not read);
  - the explicit X_err and X_C;
  - a check that Prop 4.18's printed formulas hold beyond m = 4·10⁵ (only the "3.33" step is visibly range-specific).

  This matches bb's assessment: routine, but not on the record.

**3. bb's competitor: KKL with the analytic conductor (`kkl_constant.py`; PARTIAL, heuristic).**
- On y = 0, the n-th effective term is n^{−½−(t/4)(ℓ−log n)} for n ≤ e^{ℓ/2} (FGMPS Prop 4.18(2)).
- KKL's phase argument needs the non-leading part below 1. Let t_K(ℓ) be the least t with
  Σ_{2≤n≤e^{ℓ/2}} n^{−½−(t/4)(ℓ−log n)} ≤ 1. Then C_K = t_K·ℓ takes the values:

| ℓ | 10 | 14 | 18 | 25 | 35 | 50 | 100 | 200 | 400 |
|---|---|---|---|---|---|---|---|---|---|
| C_K | 6.60 | 6.40 | 6.19 | 5.88 | 5.59 | 5.34 | 5.07 | 4.99 | 4.95 |

- **So the KKL route does give Λ_χ ≲ C/log m**, with C → 4.95. That is the optimistic constant, ignoring e_A, e_B, e_{C,0}
  and the reflected-leg phase. bb's crude count is C ≈ 30. Asymptotically it beats √5·loglog m/log m.
- **Crossover against the explicit C2 floor (ℓ ≈ L − log 4 at x ≈ 1):**

  | m | 10¹⁰ | 10¹⁵ | 10²⁰ |
  |---|---|---|---|
  | KKL t_K | ≈ 0.28 | ≈ 0.171 | ≈ 0.12 |
  | C2 T | 0.226 | 0.166 | 0.134 |

  **KKL wins only for m ≳ 10^{16–17}, even in its most optimistic form.** With C ≈ 30 the crossover is astronomically far
  out.
- Both are ≫ 1/log m, so the Siegel sanity rule holds.
- **A structural obstruction for KKL (PROVED, from the §A.6 exponent).** The Gaussian route that closes TL at p ≥ √5 does not
  close at p = 0. The mirror suppression (m/π)^{−p/2} equals 1 there: both saddles are equal on the line, |γ| = 1.
  - So KKL needs the two-leg phase argument at *small* x for large m, i.e. an RS-type approximation valid down to x ≈ 1.
  - That is a strictly harder input than TL.
- **Recommendation:**
  - prove C2 first, from TL (G1–G2 certification) and P2;
  - keep KKL as the asymptotic statement (Λ_χ ≤ C/log m) once an effective small-x RS approximation for large m exists;
  - P2 at large x is shared by both routes.

**Telperion pieces run (pure Python, emitted, nothing built, no file written):**
- `prove` certifies **Planat's Prop 2.3 bridge numerator** for c² ≥ 5, 0 < r² ≤ 1. With c² = 5 + γ and r² = 1/(1+λ), the
  numerator times (1+λ)² is a 14-monomial positive polynomial. It is closed by `ring` + `positivity`. This is the √5
  threshold of §A.2, now certificate-shaped.
- `prove` handled the tilt identity −g²/2 + lg = −(g−l)²/2 + l²/2 in both directions (trivial).
- The earlier §A.6 tail square and `psd` LDLᵀ are re-used.

### A.8 Addendum 3: KKL_χ / P2, (P1′), G1 certification, G2 citations, and the C2 statement of record (lead's requests, 2026-10-31)

This addendum answers both of the lead's messages. Outcome of each step:

| Step | Outcome |
|---|---|
| KKL_χ ⇒ P2 | **P2′ WORKS**, explicit (float-evaluated elementary inequality; Arb is a one-line change). **The full KKL_χ FAILS for now** (obstruction below). |
| (P1′) bulk bound, x-uniform | **WORKS** as the explicit floor of §A.7, version 1, now with certified primitives (below). |
| G2 citations | **WORKS.** Every special-function identity is now CITED-READ (DLMF, FGMPS, BMOR, H-B) or PROVED. Nothing load-bearing is FROM MEMORY. |
| G1 Arb certification | **PARTIAL.** The certified box evaluator works and is validated. The pilot certified 8 669 boxes with 0 failures in one 25-minute job. Full coverage is not done; the plan and cost are given below. |
| P2: Thm 8.1(2) and Prop 4.18 | **Prop 4.18 holds for every m ≥ 3 (WORKS, line by line).** Thm 8.1(2) was read; its constants are inexplicit ("sufficiently large/small"). P2′ bypasses it. |

**1. KKL_χ and P2.**
- **Read at source (FGMPS 2610.27343):**
  - Thm 8.1(2)'s proof (pp.84–85): Rouché on |z − x_n| = c/log(mx_n) against 2i·sin(ℓ_n w/4). It rests on Prop 8.2(i) and the phase Lemma 8.3, with "C sufficiently large, c sufficiently small", so no explicit constants.
  - Prop 4.14 (pp.37–41). Its hypotheses contain no bound on m.
  - Thm 4.6 and Thm 4.12 ("Let m > 1", pp.28, 35).
  - Thm 4.11 / (4.31) (pp.33–35): B*_m/√m ≤ e^{π/(4m)}[φ(m)/(2√2m) + (1 + ½log(2πm) + ½γ + log 2)/π + √2e^{−2πm}/(2π²√m)] **for m ≥ 3**. Hence B*_m ≤ √m·f(m), with f(m) = e^{π/(4m)}(log m/(2π) + A₀ + 10⁻⁹) and A₀ < 1.276873.
- **Prop 4.18 checked line by line beyond 4·10⁵ (pp.44–46).**
  - Item (1): the inequality 4/x² + ℓ/(8(x−2)) + π/(16(x−2)) + 1/(2(x−2)²) ≤ 0.002 + log m/3800 uses only x ≥ 480. Split ℓ = log m + log(x/4π): the m-free part is ≤ 0.00148 < 0.002, and log m/(8·478) ≤ log m/3800.
  - Items (4)–(5): 5/4 + π²/256 + (|L_n| + π/2)/(8(x−2)) + 1/(4(x−2)²) ≤ log m/2250 + 1.3 holds by the same split, since 1.2886 + 0.0015 ≤ 1.3.
  - Items (2), (3) and (6) contain no m-specific step; item (6) keeps B*_m.
  - **So Thm 4.3 and Prop 4.18 hold for every m ≥ 3** with B*_m ≤ √m·f(m). The constant 3.33 is just f(4·10⁵).
- **P2′ (Lemma Z), PROVED from the above, `lemma_z.py`.** For 0 < t ≤ ½, y_b ∈ (0, 1] and every m ≥ 3, there is an explicit X(m, t, y_b) such that H_t^χ(x+iy) ≠ 0 for |x| ≥ X and y_b ≤ |y| ≤ 1. The certificate is the inequality
  1 − (ζ(r) − 1) − ĝζ(r′) > η(ζ(r) + ĝζ(r′)) + e_{C,0},
  with:
  - r = (1+y)/2 + (t/4)ℓ′ and r′ = (1−y)/2 + (t/4)ℓ′, where ℓ′ = ℓ/2 − O(t/x);
  - ĝ = e^{a_m y}q^{−y/2}M^{|κ|}, η = the Prop 4.18(4)–(5) factor, and e_{C,0} from Prop 4.18(6).

  Every term is non-increasing in x for x ≥ 480 (FGMPS pp.59–60), so the inequality at X gives all x ≥ X. Values:
  - m = 10⁸, t = 0.1: log₁₀X = 32.3 (y_b = 0.2) and 60.2 (y_b = 0.01).
  - t = 0.3: log₁₀X = 6.8 and 23.8.
  - t = 10⁻⁴: log₁₀X ≈ 4·10⁴.

  These are astronomically large but finite, and **finiteness is all the contact argument needs**.
- **Why P2′ suffices for C2.**
  - H-B's Thm 9 argument needs the first contact of the barrier √Q(t) with the zeros to be attained at finite |x|.
  - Contact happens only while Q ≥ b, i.e. at heights y ≥ √b. P2′ with y_b = √b confines all such zeros to |x| < X(m, t), so contact is compactly attained.
  - Finiteness of all non-real zeros is not needed.
  - Once Q reaches b = 10⁻⁴, de Bruijn's strip theorem (FGMPS Thm 2.6, CITED-READ p.10) adds b/2.
  - **On [0, t_min] (t_min = 10⁻⁴) the classical (y²)′ ≤ −2 is used, so no S-floor is needed near t = 0.** This costs ≤ t_min in the bound and removes the t → 0 regime from G1 entirely.
- **The full KKL_χ** (every zero real once t ≥ C/log m) **FAILS for now**, on two counts:
  - at x < 480 there is no effective approximation (FGMPS Thm 4.3 needs T = x/2 ≥ 240);
  - on y = 0 the Gaussian route has no mirror suppression ((m/π)^{−p/2} = 1 at p = 0, §A.7 item 3).

  Its large-x half is P2′. The heuristic constant of §A.7 (C_K → 4.95) stands as heuristic.

**2. (P1′).** The bulk bound at Re w ≥ 1+δ is the §A.7 floor.
- Γ is evaluated exactly, by centred forms over boxes. The Taylor remainder uses sup|ψ_a′| ≤ ¼[1/(ũ²+v²) + min(1/ũ, π/(2v))] (DLMF 5.15.1).
- The Dirichlet part uses |L′/L| ≤ −ζ′/ζ, which is decreasing (H-B p.11, CITED-READ).
- Uniformity in x comes from the exact complex Γ values, not from analytic-conductor asymptotics. The bound improves with x (ρ increases with |x|, by the DLMF 5.7.6 series).
- **Remaining for x ≥ 10⁴:** the certified covering stops at x = 10⁴. Beyond that, the floor is above target by ≥ ¼log(x/8) − 1, but no certified unbounded-box argument has been written. That is lemma LX, open; a sketch is in §A.8 G1.

**3. G2: citations read at source this session.**
- **DLMF 5.15.1:** ψ′(z) = Σ_{k≥0} (k+z)^{−2}. This gives the trigamma majorant (PROVED: the k = 0 term plus ∫_0^∞ ds/((u+s)²+v²) ≤ min(1/u, π/(2v))).
- **DLMF 5.7.6:** ψ(z) = −γ + Σ_{k≥0}(1/(k+1) − 1/(k+z)). Term by term this gives Re ψ(u+iv) ≥ ψ(u), Re ψ increasing in |v|, and |Im ψ(u+iv)| ≤ π/2 + 1/(2u) (PROVED).
- **DLMF 5.6.6:** |Γ(x+iy)| ≤ |Γ(x)|.
- **FGMPS Lemma 4.2(5)** (p.22): an explicit Stirling bound. It gives log Γ(y) ≤ y log y − y + 1 for y ≥ 3.5, which is used in the far tail. Check: −½log y + 0.919 + 1/(12(y−½)) ≤ 1 at y = 3.5, and the left side decreases.
- **BMOR 2005.02989:**
  - Lemma 2.1: ζ(2σ)/ζ(σ) ≤ |L| ≤ ζ(σ);
  - Prop 2.2 is the arg bound; the inequality |log L(σ+it)| ≤ log ζ(σ), σ > 1, is a step in its proof (corrected per bb N3; also PROVED directly: log L = Σ_p Σ_k χ(p)^k/(k p^{ks}), so |log L| ≤ Σ_p Σ_k 1/(k p^{kσ}) = log ζ(σ));
  - Lemma 5.6 (5.3): Rademacher's convexity bound. It is read at source as stated by BMOR, citing Rademacher, Math. Z. 72 (1959). The original is not on arXiv and was not read.
- **H-B 2610.12803** p.11: "These three functions are decreasing", for ζ, −ζ′ and −ζ′/ζ on u > 1.
- **Status:** no load-bearing step is FROM MEMORY. The Rademacher constant is read in a secondary source; the lead may want the 1959 original checked.

**4. G1: Arb certification (`tl_arb_cert.py`, `tl_cover.py`).**
- **The method:** python-flint balls, with:
  - (i) monotone primitives (Z and ζ decreasing; trig majorant decreasing);
  - (ii) centred forms, by the mean value theorem, for ψ_a and Re log Γ_a over boxes;
  - (iii) every integral as an interval Riemann sum of a non-negative integrand;
  - (iv) closed-form Gaussian majorants for the right tail and the far left tail. The far tail is half-line, and is cut at
    U_MIN ≤ R − √(t(πx/8 + 60)) so that the Gaussian beats the archimedean decay absorbed in the normalisation.

  The output is a rigorous lower bound for S − L/4 on the whole box (L, t, x). The ¼L cancels exactly.
- **Validation:** certified point values sit ≤ the float floor by 0.004–0.08 at the four test points. A box at L = 18.41,
  t = 0.456, x = 49.8 was debugged twice: a whole-line tail bound and the far-tail cut were fixed, and the history is in the
  scripts.
- **Pilot** (`tl_cover_pilot2.out`): a = 0, L ∈ [log(10⁸/π), log(10^{8.5}/π)], t ∈ [10⁻⁴, ½], x ∈ [0, 50], target
  S − L/4 ≥ −1.0. In 1 500 s: **8 669 boxes certified, 0 failures**. The run was incomplete: 233 boxes remain, mostly the
  untouched small-t initial boxes, because of the depth-first order.
- **Per-box cost** about 0.17 s. Near the minimum (t ≲ 0.05, x ≲ 5) boxes of about Δt = 10⁻³, Δx = 0.05, ΔL = 0.05 are
  needed (margin ≈ 0.1).
- **Plan and cost:**
  - (a) Re-parametrise the boxes by (R, τ, x). The bulk depends on L only through R, so wide L-slabs become cheap.
  - (b) Split t and x before L.
  - (c) Estimated 5–8 CPU-hours per half-decade of m per parity with the current code, about 1–2 CPU-hours after (a)–(b).
    For m ∈ [10⁸, 10²⁰] that is about 50–100 CPU-hours now, or 25–50 jobs of 30 minutes at 2 cores after the optimisation.
  - (d) **Open analytic lemmas:**
    - (LX) x ≥ 10⁴: an unbounded-x box via the monotonicity in |x| from DLMF 5.7.6, plus the bounded-change version
      |log L(w) − log L(c)| ≤ log ζ(u) + log ζ(R) (the |log L| ≤ log ζ step in the proof of BMOR Prop 2.2; PROVED directly in item 3) so that the tilt does not blow up;
    - (LL) m > 10²⁰: a large-L monotonicity, or one unbounded R-box.

    Without (LX) and (LL), the certified statement is limited to the covered region.
- **Telperion:** the box inequality is not polynomial, so `prove`/`hunt` do not apply. The certificate is Arb, of the same
  trust class as `arb_winding`. The polynomial pieces (H-B and Planat numerators, the tail square) are Telperion-certified,
  as recorded earlier.

**5. C2 statement of record** (the exact theorem, its hypotheses and its m-range; for the lead and bb):

> **Theorem C2 (unconditional large-conductor bound; not RH).** Let χ be a real primitive Dirichlet character of conductor
> m ≥ 10⁸ and parity a. Let Λ_χ be its generalized de Bruijn–Newman constant (H_t^χ as in FGMPS 2610.27343 (1.2)–(1.3)).
> Put
> C(m) = ¼log(m/π) − 1, k = (4/√5)C(m) − 2, t_min = min(10⁻⁴, 4/L), b = min(10⁻⁴, L⁻²) with L = log(m/π)
> (revised in §A.9.0; for L ≤ 4·10⁴ this is the original t_min = b = 10⁻⁴).
> Then
> **Λ_χ ≤ t_min + k⁻¹·log((2 + k(1 − 2t_min))/(2 + kb)) + b/2.**
> This equals 0.2764 at m = 10⁸, which is < 9/32, and **the bound is < 9/32 for every m ≥ 10⁸** (restated per bb; the formula itself crosses 9/32 near m = 10^{7.833}, but the theorem is stated only for m ≥ 10⁸). It is (√5 + o(1))·log log m/log m
> as m → ∞.
> - **Hypotheses used:** none beyond χ real primitive. No GRH, no zero-free half-plane (q₀ = 1 is the trivial strip), and no
>   numerical zero verification. A possible Siegel zero is allowed.
> - **Proof:**
>   - classical contraction on [0, t_min];
>   - Planat 2609.37164 Thm 2.1 and Prop 2.3, with the bridge numerator Telperion-certified;
>   - Hakimoglu-Brown 2610.12803's comparison (Thm 9, one step, p = √5);
>   - the TL floor S_χ(x, √5, t) ≥ ¼log(m/π) − 1 for all x and all t ∈ [10⁻⁴, ½] (§A.6–A.8);
>   - the confinement P2′ (FGMPS Thm 4.3 and Prop 4.18, valid for every m ≥ 3);
>   - de Bruijn's strip theorem at the end.
> - **Status, PARTIAL:**
>   - the TL floor is certified (Arb) only on part of {m ∈ [10⁸, 10^{8.5}], t ∈ [10⁻⁴, ½], x ∈ [0, 50]};
>   - elsewhere it is float-evaluated (§A.7, x ≤ 10⁵, m ≤ 10⁵⁰);
>   - lemmas LX (x ≥ 10⁴) and LL (m ≥ 10²⁰) are open;
>   - P2′ is float-evaluated, and an elementary Arb check remains. [SUPERSEDED by §A.12: Lemma Z′, uniform X(L), analytic plus Arb.]
>
>   **It is a theorem only once G1 coverage, LX and LL are complete.** Until then it is a fully specified, partially certified
>   proof. Siegel sanity: the rate is ≫ 1/log m.

### A.9 Addendum 4: Lemma LX, Lemma LL and the (R, τ, x) reparametrisation (lead's request; desk work, G1 full coverage on HOLD)

Outcome of each step:

| Step | Outcome |
|---|---|
| LX (x ≥ 10⁴) | **WORKS** on the whole C2 domain with L ≤ 4·10⁴ [after the R-x re-run, §A.11.1: 3 069 boxes, 0 failed, worst −0.769]. It combines a proved v-monotonicity lemma with an Arb certification over (R, τ) boxes: 3 060 boxes, 0 failures, worst S − L/4 ≥ −0.49, in 18 s. For L > 4·10⁴ it is covered by STL. |
| LL (all m ≥ 10⁸ beyond the compact domain) | **WORKS, analytically:** the domain reduction A.9.0 plus Lemma STL (A.9.3). |
| (R, τ, x) reparametrisation | **WORKS.** The G1 domain is now compact and independent of m. The cost was measured on one 30-minute job (A.9.4). |

**A.9.0 Domain reduction (PROVED). TL is needed only for t ∈ [t_min(L), T(L)].**
- In the C2 argument, the S-floor is used only during the contraction phase:
  - on [0, t_min] the classical (y²)′ ≤ −2 is used;
  - after time T(L) the barrier has reached b, and de Bruijn's strip theorem finishes.
- I now take t_min(L) = min(10⁻⁴, 4/L) and b(L) = min(10⁻⁴, L⁻²). The record bound becomes
  Λ_χ ≤ T(L) + b/2, with T(L) = t_min + k⁻¹·log((2 + k(1 − 2t_min))/(2 + kb)) and k = (4/√5)(L/4 − 1) − 2.
- Values (`c2_domain.py`):
  - at m = 10⁸ (L = 17.28) it is unchanged, 0.27643;
  - L = 10³: 0.01229; L = 10⁴: 0.001826;
  - asymptotically (√5 + o(1))·log log m/log m, now genuinely, because t_min and b → 0.
- In R = σ′ + tL/4 and τ = √(t/2) this gives two regions:
  - **L ∈ [L₀, 4·10⁴]** (t_min = 10⁻⁴): τ ∈ [0.00707, 0.3717] and σ′ + τ²L₀/2 ≤ R ≤ R_hi(τ) ≤ 7.71. **Compact.**
  - **L > 4·10⁴** (t_min = 4/L): R ≥ σ′ + 1 = 2.618 and τ ≤ √(T(4·10⁴)/2) = 0.01745.
- **So the G1 grid never needs large m.** Large m lives in the small-τ region, which Lemma STL handles analytically.

**A.9.1 The double contour shift (PROVED; `tl_big2.py`).**
- Definitions: β₁ = ψ_a(c), c₁ = c + τ²β₁; β₂ = L′/L(c₁), c₂ = c₁ + τ²β₂; κ = τ(β₁ + β₂).
- Shifting the Gaussian contour by κ is legitimate: the integrand is entire in g with Gaussian decay on horizontal strips. Then
  D(c) = Γ_a(c)L(c₁)e^{τ²(β₁²+β₂²)/2}[∫_bulk e^{r_Γ + r_L}φ + T₀], with w = c₂ + τg.
- Remainders:
  - |r_Γ| ≤ |h_Γ|²M/2, h_Γ = w − c;
  - |r_L| ≤ min(|h_L|²Z₂/2, log ζ(U) + log ζ(Re c₁) + |h_L|Z(Re c₁)) (the |log L| ≤ log ζ step in the proof of BMOR Prop 2.2; PROVED in §A.8 item 3), h_L = w − c₁. [Prior art (bb N1): the Gaussian form is FGMPS (4.1), p.19, and the contour shift is FGMPS (4.6)–(4.7), p.21.]
- Result: S − L/4 ≥ ½(ρ_lo − Z(Re c₁)) − ½K.
- In U-measure the tail weight is exactly exp(−(U−R)²/(2τ²) − τ²(Re β₁)²/2 + ...). The Re β·(R−U) terms cancel identically, so
  the bound needs no upper bound on Re β.
- Why the double shift: shifting by ψ_a(c) alone leaves the L-remainder linear in τ²ρ ~ (t/4)log x, which is unbounded in
  x. Re-centring log L at c₁ makes the L-remainder independent of x.

**A.9.2 Lemma LX (PROVED, given the certified boxes).**
- **Statement.** For every (R, τ) in the A.9.0 compact domain, both parities, and every x ≥ 10⁴:
  S_χ(x, √5, t) ≥ ¼log(m/π) − 0.50. [Constant superseded: the certificate of record is the post-R-x re-run, §A.11.1, worst −0.7689. So LX is
  stated as S ≥ L/4 − 0.77 (§A.13). C2 needs only −1.]
- **Proof, step 1 (monotonicity).** Every piece of the A.9.1 bound evaluated at v₀ = 2500 (v = x/4) is valid for all
  v ≥ v₀:
  - (a) ρ_lo(v) = max(½ψ(ũ), ½(log v − γ − 1/(2v))) is increasing (DLMF 5.7.6, Re ψ(u+iv) ≥ ½log(u²+v²) − γ − 1/(2v)). So
    Re c₁ and Re c₂ increase, U_lo(g) increases, the split g_s decreases, and P(B) increases.
  - (b) Z, Z₂ and log ζ are decreasing (H-B p.11), so they decrease along the increasing real parts.
  - (c) M(v) = ¼[1/(ũ²+v_m²) + min(1/ũ, π/(2v_m))] is decreasing.
  - (d) The products P·M and P²·M decrease for log v > 2.0002. Proof: d/dv log P ≤ 1/(v log v) and d/dv log M ≤ −0.9999/v,
    since 2vA/π ≤ 2/(πv).
  - (e) Mid-tail and near-FE tails, pointwise in U: the exponent's v-derivative is ≤ (1+δ−R)/(2v) < 0, since R ≥ σ′ > 1+δ.
    The Rademacher growth v^{(1+δ−U)/2} is beaten by the x-aware Γ-ratio decay v^{−(R−U)/2}.
  - (f) Multipliers: P·T₀ and the |g′|-factor in T₁ decrease, because d/dv log P ≤ 1/(v log v) < 0.184/v for log v > 5.43.
    In the far-FE region (1 − U > R), the v-dependence is replaced by its supremum over v ≥ v₀, in closed form:
    max_ℓ [A′ℓ − (τ²/8)(ℓ−c₂)²] with A′ = (s₁−R)/2 + 1/log v₀. The extra 1/log v₀ absorbs P(v)/P(v₀). The Gaussian surplus
    (2R−1)(2s₁−1)/(2τ²) beats the resulting 2A′²/τ².
  - (g) The normalisation and common factors are monotone in the favourable direction.
- **Proof, step 2 (certification, `lx_cover.py`).**
  - Arb boxes in (R, τ): τ-boxes of ratio 1.03; R-boxes covering R_range(τ), adaptively bisected; parities a ∈ {0,1}.
  - Result: **3 060 boxes, 0 failures, worst certified S − L/4 ≥ −0.491, in 18 s.**
  - Far-left tails use exact closed-form decay: d log q/dU ≥ min(p/τ² − c, 1/τ² − 1) beyond U_MIN.
- **Process note.** A first run hit a domain bug: R_range returned a huge interval when τ > τ_max. That run overran 30
  minutes and I killed it. The bug is fixed, and the clean rerun took 18 s.

**A.9.3 Lemma STL (small τ: every L > 4·10⁴ and every x; PROVED analytically, constants via Arb).**
- **Statement.** For τ ≤ 0.0175, R ≥ 2.618, every x ≥ 0 and both parities: S − L/4 ≥ −0.18.
- **Proof.** It uses the A.9.1 bound with crude uniform majorants.
  - ρ_lo ≥ ½ψ((R+a)/2) ≥ ½ψ(1.309) = −0.0795, and Z(Re c₁) ≤ Z(2.618) = 0.2510 (Arb). So it suffices that K ≤ 1.67.
  - **Main bulk, |g| ≤ 10:** τ|g| ≤ 0.175, so U ≥ 2.44 and the minimum real part along each segment is ≥ 2.44. Hence:
    - Z ≤ Z(2.44) = 0.3108 and Z₂ ≤ Z₂(2.44) = 0.3860 (Arb);
    - M ≤ ¼(1/1.22² + 1/1.22) = 0.373;
    - sup_v P·M ≤ 0.90 (C₁: the max of two explicit decreasing functions at ũ = v = 1.309; `stl` check).

    So ε ≤ τ⁴C₂ + τ²g²(M + Z₂)/2 + ... ≤ 0.03, giving I_e ≤ 0.03 and N_b ≤ 1.03·τ·E|g|·(M + Z₂) + τ²C₁ ≤ 0.012.
  - **Far bulk, |g| > 10:** ε ≤ 0.52τ²g² + C ≤ 3.2·10⁻⁴g² + C, against φ. The contribution is ≤ 10⁻²⁰.
  - **Tails, U < 1.25:** with the exact L-substitution, the mid exponent is ≤ −(R−1−δ)²/(2τ²) ≤ −3058. The x-growth of
    Rademacher is cancelled by the x-aware Γ ratio for v ≥ 1, and by Γ(¼)-type constants for v ≤ 1. FE pieces are ≤
    exp(−(p/2)L − ...) with L ≥ 4·10⁴. So T₀, T₁ ≤ e^{−1000}.
  - Hence K ≤ 0.013/0.97 < 0.02, and S − L/4 ≥ ½(−0.0795 − 0.251) − 0.01 = −0.175 ≥ −1. ∎
- **Illustration** (`stl_samples.out`, Arb, not needed for the proof):
  - x-free, v ≤ 2500: S − L/4 ≥ −0.17 (a = 0) and −0.06 (a = 1) at R = 2.62, τ = 0.0175; ≥ 0.98 at R = 100;
  - x-aware, v ≥ 2500: ≥ 1.68.

**A.9.4 Lemma LL, and the reparametrised G1 (`tl_cover_Rt2.py`; one 30-minute job, a = 0).**
- **LL** (every m ≥ 10²⁰, indeed every L > 4·10⁴) = A.9.0 + STL. **The G1 grid needs only the compact domain**
  {τ ∈ [0.00707, 0.3717], σ′ + τ²L₀/2 ≤ R ≤ R_hi(τ) ≤ 7.71, 0 ≤ x ≤ 10⁴}, which covers every L ∈ [L₀, 4·10⁴].
- **Measurement, after the fix:** domain fixed, certifier cached, coarse start of 520 initial boxes, a = 0, target S − L/4 ≥ −1.0. **In 1 750 s: 123 124 evaluations (0.014 s each), 24 941 certified leaves, 0 failures, worst certified −0.9968.** The run is incomplete: a breadth-first frontier of 73 762 boxes remains. All of it sits near the hard corner: L near L₀ (R near σ′ + τ²L₀/2), small t, x ≲ 4, even parity. There the version-1 float margin is only 0.136, so boxes must be small.
- **Earlier pilot (`tl_cover_Rt_a0.out`, before the domain fix and the caching):** 19 417 evaluations and 10 270 certified
  boxes in 1 750 s, 0 failures, worst −0.967. It is superseded: its domain was inflated by the R_range bug.
- **Speed-ups:** monotone zeta tables (`tl_big._lookup`: grid step 0.005 on [1.05, 60], rigorous by monotonicity). They took
  a certifier box from 0.09 s to 0.02 s.
- **Re-estimated cost:** the frontier is concentrated in one corner. **About 5–15 further 30-minute jobs for a = 0, and fewer for a = 1** (its margin is ≈ 0.36 larger), i.e. 3–8 CPU-hours in total. That is down from about 50–100 CPU-hours for m ∈ [10⁸, 10²⁰]. This is only an estimate: the growth of the corner frontier is not measured. Two cheap improvements, untested: use version 2 (second order) in the corner (float margin 0.158 instead of 0.136), and order the frontier by margin. Full coverage stays on HOLD, as instructed.

**Statement-layer additions:** C2 is restated with t_min(L) and b(L) in item 10. New items:
- 12 (LX):
  ```
  ∀ x ≥ 10⁴, (R,τ) ∈ D_C2, a: S ≥ L/4 − 0.5      [superseded: −0.77, see §A.13]
  ```
- 13 (STL):
  ```
  τ ≤ 0.0175 ∧ R ≥ 2.618 → ∀ x, S ≥ L/4 − 0.18
  ```

### A.10 Addendum 5: response to bb's review REVIEW_P5.md (md5 e909a59c; it reviewed memo 661b26a0)

bb's verdicts as received:
- PASS: the t = 0 floor, the Gaussian tilt, the Planat/H-B transfer, Prop 4.18, G2, the Siegel check and KKL.
- R1 is required, and so is an R2 pilot. There are nits N1–N4.
- Run gate: NOT YET.

This addendum answers each item.

| Item | What was done | Outcome |
|---|---|---|
| R1 (x-radius in lgre_box) | Patched, then re-validated against the float floor | **DONE.** 18/18 checks pass (below). |
| R2 (hard-region pilot) | One job, a = 0, with the R1 patch | **COMPLETE in 62.5 s.** 3 155 certified leaves, 0 failures, certified volume fraction 1.0. |
| LX | Already done in §A.9.2 (bb reviewed 661b26a0, which predates §A.9) | Pointer only. R1 does not touch it (below). |
| N1 | FGMPS (4.1) is cited as prior art in §A.6(ii) Step 1 and §A.9.1 | **DONE**, CITED-READ p.19 and p.21 |
| N2 | The m-range of Props 4.15–4.16 and the Thm 4.3 assembly | **DONE**, CITED-READ. No m restriction (below). |
| N3 | The BMOR Prop 2.2 wording | **DONE.** It is now stated correctly, and the inequality is also PROVED directly. |
| N4 | §A.6(iii)'s "log m ≳ 390" | **DONE.** Marked SUPERSEDED by §A.7.3. |
| 9/32 restatement | §A.8 item 5 | **DONE.** "< 9/32 for every m ≥ 10⁸". |
| Scripts bb had not seen | lx_cover.py, lx_proto.py, tl_cover_Rt.py (plus Rt2, tl_cover_hard, r1_validate) | Described below |

**R1. The x-radius of the Γ centred form (PROVED patch; `tl_arb_cert.py`, now md5 250f6b11, was 1309e80f).**
- **The defect (bb).** `lgre_box` built the centre of the centred form from the box midpoint, but its radius term covered only the
  real radius of w. Since Im w = −x/2 + …, an x-box of radius ρ_x moves Im w by ρ_x/2, and that radius was not enclosed. Every
  earlier certified box with a nonzero x-width was therefore unproven.
- **The patch.** Re log Γ((w+a)/2) is evaluated at the complex centre c_m = (Re w)_mid + i·(Im w)_mid. The remainder is enclosed
  over the full complex radius r = √(rad(Re w)² + (rad_x/2)²), using
  |Re logΓ(w′) − Re logΓ(c_m)| ≤ r·(|ψ(c_m)|/2 + r·sup|ψ′|/4)
  (mean value theorem plus the DLMF 5.15.1 trigamma majorant, the same majorant as before). All four call sites (lgc, lgw, lgs and
  lgw0) now pass `wim_rad = rad(x)/2`.
- **Re-validation (`r1_validate.py` aeaa0b4a → `r1_validate.out` 22310eb4).** All 18 checks pass:
  - **12 point checks** at L ∈ {17.276, 17.3, 17.5, 18.41}, t ∈ [5·10⁻⁴, 0.456], x ∈ [0, 49.8], both parities. In each, the
    certified value ≤ the float floor, with gaps of 0.004–0.09. Example: (17.276, 0.01, 0, a = 0) gives −0.9011 ≤ −0.8637.
  - **6 box checks**, including x-widths 0.25–1.0. In each, the certified box value ≤ the minimum over sampled interior points.
    Example: L[17.276, 17.30] × t[0.01, 0.0105] × x[0, 0.5], a = 0 gives −0.9505 ≤ −0.9014.
- **Consequence for earlier runs (stated plainly).** The R1 defect affects every result that used `floor_box` with nonzero x-width:
  - the §A.8 pilot (8 669 boxes);
  - `tl_cover_Rt_a0.out`;
  - `tl_cover_Rt2_a0.out` (the §A.9.4 measurement).

  Their certified leaves are **void as certificates**. They stand only as cost measurements. The C2 status line in §A.8 item 5
  ("certified (Arb) only on part of …") should be read as: certified, post-R1, only on the R2 region below.
- **Not affected:**
  - **LX** (`lx_cover.py` → `tl_big2.big2`, mode 'xaware') never calls `lgre_box`. x enters only at the point v₀ = 2500 and
    through the proved v-monotone majorants of §A.9.2. In 'xfree' mode, x enters through the endpoint majorants vP = v₁, vM = 0.
    I checked this by reading the imports and the v-handling in `tl_big2.py` (lines 14–18, 81–127). bb should re-confirm it.
  - **STL** is analytic.
  - **P2′ (`lemma_z.py`)** is a separate elementary inequality.

**R2. The hard-region pilot (`tl_cover_hard.py` b97cee1d → `r2_hard_a0.json` f3dc996c, plus `r2_hard_a0.DONE`).**
- **Region (bb's spec):** a = 0 (the harder parity), L ∈ [log(10⁸/π), log(10^{8.5}/π)] = [17.276, 18.427], t ∈ [10⁻⁴, 0.05],
  x ∈ [0, 5]. Target S − L/4 ≥ −1 (K0 = 1, i.e. C(m) = L/4 − 1, as C2 uses).
- **Method:** the R1-patched `floor_box`, version 1, over (L, t, x) boxes. Breadth-first bisection:
  - 320 initial boxes: 4 L-slabs × 10 t-cells with geometric breakpoints 10⁻⁴, 2·10⁻⁴, 5·10⁻⁴, …, 0.05 × 8 x-cells;
  - split the widest coordinate, with weights ΔL/0.02, Δt/(0.05t) (geometric split) and Δx/0.1;
  - maximum depth 18, past which a box counts as a failure;
  - a JSON ledger every 60 s and a DONE file at the end.

  Budget 1 750 s, one core, BLAS pinned to 1, run in the background and waited on by its DONE file (no pgrep).
- **Result (from the DONE file, verbatim numbers):**
  - **complete = true**, in 62.5 s of wall clock;
  - 5 990 evaluations, **3 155 certified leaves, 0 failed, frontier 0**;
  - certified volume fraction 1.0000 (measure dL·d log t·dx);
  - **real cost 0.0104 s per box evaluation.**
- **Margin, read correctly.** The worst certified leaf is −0.99999895. That is not slack: bisection stops as soon as a box clears
  −1, so the worst leaf always sits just above the threshold. The pointwise certified margin in this corner is 0.10–0.14
  (r1_validate: −0.90 at (17.276, 0.01, 0); −0.83 at t = 5·10⁻⁴, x = 1).
- **Feasibility.** The hard corner is cheap in (L, t, x) coordinates. One half-decade of m for the even parity took about one
  minute. That is far below the §A.9.4 estimate. That run (now void per R1) left a frontier of 73 762 boxes in this same corner in
  (R, τ, x) coordinates.
  - FROM INSPECTION, not measured: I think a fixed-L-width R-box near R_lo(τ) = σ′ + τ²L₀/2 straddles many L at small τ, so
    it needs many more splits than an L-slab does.
- **Proposed sweep design (for bb and the lead; not run):**
  - a **hybrid**: (L, t, x) slabs where the margin is thin (L near L₀, t ≲ 0.05, x ≲ 5), and (R, τ, x) on the remainder of the
    compact §A.9.0 domain;
  - both parities;
  - a running ledger of boxes certified, boxes failed and m-range done;
  - DONE files, sequential jobs of at most 30 minutes, at most 6 workers.
  - The cost needs re-estimating post-R1. The cheap next measurement is the same pilot for a = 1, plus one (R, τ, x) job on
    the non-corner remainder. **Neither has been run**, since bb authorised one pilot job.

**N2. The m-range of FGMPS Thm 4.3 (CITED-READ, 2610.27343).**
- **Lemma 4.1** (p.20): "Fix m, N, a and a compact interval I". This is qualitative and m-general. It licenses the contour shifts
  (4.6)–(4.7) (p.21).
- **Lemma 4.4** (p.24): "Let σ ∈ ℝ, T > 2, n ∈ ℕ, and 0 < t ≤ ½". There is no hypothesis on m. Its error ε_{t,n} contains no m.
- **Props 4.15–4.16** (p.42) are built from Lemma 4.4 and carry no m hypothesis.
- **Prop 4.14** (pp.37–41) has no m bound. Its tail estimate uses only q > 5, L ≥ 30 and 2^{−σ} ≥ ½ (p.41).
- **The Thm 4.3 assembly** (§4.3.4, p.41 onward): "fix 0 < t ≤ ½ and a point x + iy with x ≥ 480 and |y| ≤ 1", through
  (4.38)–(4.40). Again no m hypothesis.
- With Prop 4.18 checked for every m ≥ 3 (§A.8 item 1), **Thm 4.3 holds for every m ≥ 3**. The m ≤ 4·10⁵ range in FGMPS enters
  only through Lemma 3.1 (p.13: Platt's GRH check, for H_t(iy) > 0) and the numerics of §§6–7. C2 uses neither: a Siegel zero is
  allowed, and the imaginary axis is handled by the P2′ / contact argument with y ≥ √b.

**N1. Prior art for the Gaussian form (CITED-READ).** FGMPS (4.1), p.19:
H_t(z) = ∫ξ_L((1+iz)/2 + √t·v)e^{−v²}/√π dv. FGMPS take it from Polymath §4 and also use it in Lemma 3.1, p.13. Putting
v = g/√2 gives our E_g[ξ_L(μ + τg)] with τ = √(t/2). The exact tilt is the same device as FGMPS's contour shifts (4.6)–(4.7),
p.21, with α = log-derivative. Our contribution is only the use: a uniform-in-x lower bound for S via the double shift (§A.9.1),
rather than a Riemann–Siegel main term. §A.6(ii) Step 1 and §A.9.1 now cite it.

**N3.** BMOR 2005.02989 Prop 2.2 is an arg bound. The inequality used, |log L(σ+it)| ≤ log ζ(σ) for σ > 1, is a step in its proof.
- It is now also PROVED in one line in §A.8 item 3: log L = Σ_p Σ_k χ(p)^k/(k p^{ks}), so |log L| ≤ log ζ(σ). The step therefore
  no longer depends on the citation.
- Corrected at §A.8 item 3, §A.8 item 4(d) and §A.9.1.

**N4.** §A.6(iii)'s crossover "log m ≳ 390" is marked SUPERSEDED by §A.7.3. No part of C2 uses it.

**The 9/32 restatement.**
- §A.8 item 5 now reads "the bound is < 9/32 for every m ≥ 10⁸". The formula crosses 9/32 near m = 10^{7.833}, but the theorem is
  stated only for m ≥ 10⁸.
- The older thresholds are historical and are not statements of record: 10^{7.0}/10^{7.3} in §0 and §5, 10^{7.03}/10^{7.33} in
  §2.A, and 10^{7.25}/10^{7.75} in §A.7. They came from earlier floors and domains. §0 and §5 now carry a "superseded" marker.

**The scripts bb had not reviewed.**
- **`lx_cover.py` (5e1e362b → `lx_cover.out` e1fbc08f): the LX certifier, load-bearing for Lemma LX.**
  - It walks τ from √(10⁻⁴/2) to 0.3718 in boxes of ratio 1.03.
  - For each τ-box it covers c2_domain.R_range(τ) with R-boxes, bisecting adaptively, for a ∈ {0, 1}.
  - For each (R, τ) box it calls `tl_big2.big2(R, τ, v₀ = 2500, mode='xaware')`. That is the double-shift lower bound of §A.9.1,
    valid for every x ≥ 10⁴ by the monotonicity of §A.9.2.
  - It records boxes, failures and the worst value.
  - Its arithmetic is all Arb, with the monotone zeta tables from `tl_big._lookup`.
- **`lx_proto.py` (0a6fe05e): the float prototype of the same bound** (numpy/scipy; tails integrated numerically). It was used to
  choose the shift and the cell layout before `tl_big2.py` was written. **Not load-bearing.**
- **`tl_cover_Rt.py` (bc1fb8e4): the first (R, τ, x) covering, using `floor_box`.**
  - It ran with the pre-fix R_range: the domain was inflated for τ > τ_max.
  - It also predates R1.
  - **Superseded and void as a certificate.** Its output tl_cover_Rt_a0.out is kept only as a timing record.
- **`tl_cover_Rt2.py` (0d524d7d): the same covering with the fixed domain, a cached certifier and a coarse start.**
  - It is the §A.9.4 cost measurement (123 124 evaluations at 0.014 s each).
  - It predates R1, so it is **void as a certificate**. It is valid as a cost record only.
- **`tl_cover_hard.py` (b97cee1d) and `r1_validate.py` (aeaa0b4a):** described under R2 and R1 above.

**A.10.1 Lead's follow-up: where the R1 patch is, and the post-R1 re-runs.**
- **Where the patch is.** It implements bb's option (a): the x-ball goes into the centred form.
  - `scripts/tl_arb_cert.py:43–53` is `lgre_box`. It now takes `wim_rad`, uses the complex centre c_m, and encloses the radius
    r = √(rad(Re w)² + wim_rad²).
  - The call sites are at lines 91 (lgc, the normaliser), 104 (lgw), 108 (lgs) and 119 (lgw0). Each passes `wim_rad = rad(x)/2`.
  - `psi_a_box` (lines 35–42) already carried the x-radius, so ρ and ι in the bulk are x-box enclosures.
  - The trigamma majorant uses the minimum |x| over the box (`vlo`). That is valid because the majorant decreases in |Im|.
- **Why this also covers DT0/DT1.** The tail weights q are exp(hi(lgw or lgs) − lognorm). Here lognorm = lo(lgc) + …, the lower
  end of the x-box enclosure. So every tail ratio is bounded by (sup over the box) / (inf over the box), and no separate
  exp(½(π/2 + 1/(2σ_min))·r_x) factor is needed.
  - The far half-line tail uses |Γ(y+iv)| ≤ Γ(y) (DLMF 5.6.6), which is x-free, against the same box-lower lognorm.
- **LX re-run** (`lx_cover.py` → `lx_cover_postR1.out` f91fb7ab):
  - 3 060 boxes, 0 failed, worst −0.4913, in 18.8 s.
  - It is **identical line by line to lx_cover.out except for the timings**.
  - This is as expected: `tl_big2` and `tl_big` never call `lgre_box`, and their md5s eed8d0cf and ff75bad7 are unchanged.
- **The (R, τ, x) measurement re-run post-R1** (`tl_cover_Rt2.py 0 1.0 1750` → `tl_cover_Rt2_a0_postR1.out` 090ab4b4, with
  `.DONE`):
  - 520 initial boxes, 123 232 evaluations;
  - **26 026 certified leaves, 0 failed, worst certified −0.99820**;
  - **complete = false, with 71 700 boxes remaining.** Those remaining boxes are **NOT YET COVERED**.
  - The script does not record where the remaining boxes lie, so I am not claiming their location from this run. The §A.9.4
    statement that they sit in the hard corner was an inspection of the pre-R1 run.
  - These 26 026 leaves, the 3 155 leaves of the R2 pilot and the 3 060 LX boxes are the post-R1 certified set. All
    pre-R1 floor_box leaves remain void.

**Status of C2 after this addendum.** It is unchanged in shape: a fully specified, PARTIAL proof.
- **Certified post-R1:**
  - the R2 region (a = 0; m ∈ [10⁸, 10^{8.5}]; t ∈ [10⁻⁴, 0.05]; x ≤ 5), complete;
  - the 26 026 (R, τ, x) leaves of A.10.1, a partial cover with 71 700 boxes NOT YET COVERED;
  - LX on the whole compact domain (after the R-x re-run, §A.11.1);
  - STL, analytically.
- **Remaining:** G1 coverage of the rest of the compact §A.9.0 domain, for both parities; and the Arb version of P2′.
- **The sweep is NOT started.** It waits for bb's sign-off on R1 and R2 and for the lead's go.

### A.11 Addendum 6: response to REVIEW_P5_DELTA (md5 206b88e7): R-x, C1–C6, the measurements, and the G1 coverage they produced

The delta review PASSED R1, R2, LX's independence from lgre_box, STL and the domain reduction. The run gate was SOUND TO RUN
under C1–C6, after the R-x fix. Below, item by item.

**[Update: REVIEW_P5_A11 (e570fc33) PASSED §A.11 on all 7 items. The G1 coverage is a REVIEWED certificate (Arb trust class,
AI-reviewed). The caveat in the next paragraph is kept for the record.]**

**Read this first.** During the C5 measurements I changed the certifier twice, in A.11.6 (T) and (R1b), to make the large-x
boxes tractable. bb has **not** reviewed either change. Every G1 result in this addendum depends on them. Both are argued
below, and both were validated against point evaluations and the float floor (30/30). **Until bb reviews them, the G1 coverage
below is a candidate certificate, not a reviewed one.**

**A.11.1 R-x: the LX coverage gap (DONE).**
- `lx_cover.py` (fa243994; the pre-fix copy is `lx_cover_preRx.py`, 5e1e362b) now inserts τ* = √(T(4·10⁴)/2) = 0.017446020956
  as a τ breakpoint.
- **Re-run** → `lx_cover_Rx.out` (77cadb55): **3 069 boxes, 0 failed, worst S − L/4 ≥ −0.7689, in 18.0 s.**
  - The two τ-boxes that meet at τ* are [0.0171462, τ*] and [τ*, 0.0179694].
  - The worst value moved from −0.4913 to −0.7689. That reflects box resolution, not a new weak point: shifting the τ grid
    after τ* changes which coarse R-boxes are accepted without splitting. The worst box is at τ ≈ 0.066. It is still ≥ −1.
- **The endpoint rule is now PROVED, not just sampled** (`rhi_monotone.py` 66a25bab → `rhi_monotone.out` 98c86374).
  - For τ ≤ τ*, R_hi = σ′ + 10⁴t, which increases.
  - For τ ≥ τ*, R_hi = σ′ + ¼·t·Tinv(t). This decreases because L·T(L) is strictly increasing on [L₀, 4·10⁴].
  - Arb, forward-mode derivatives over 8 000 boxes covering [L0d, 4·10⁴], with b(L) piecewise and continuous at L = 100:
    d(LT)/dL ≥ 1.5·10⁻⁴ > 0, and dT/dL ≤ −1.1·10⁻⁸ < 0. So T is strictly decreasing and Tinv is well defined.
  - Hence min/max of R_range at the τ-box endpoints is exact on each side of τ*.
- This settles **N-v**: "LX on the whole compact domain" (§A.10) and "WORKS on the whole C2 domain" (§A.9) now hold, with this
  re-run.

**A.11.2 C1: acceptance is outward-rounded (DONE).**
- `tl_big.flo(x)` returns a float f ≤ x.lower() exactly. It rounds float(x.lower()) to nearest, then steps once with
  nextafter toward −∞ if the result lies above the Arb endpoint; a non-finite value returns −∞.
- `floor_box` (tl_arb_cert.py, now 4a001119) and `big2` (tl_big2.py, now cc065977) return flo(S). So every driver's test
  `S >= -K0` (K0 = 1.0 exactly) implies Arb S.lower() ≥ −1.
- The pre-C1 copies are `tl_big_preC1.py`, `tl_big2_preC1.py` and `tl_arb_cert_preC1.py`.

**A.11.3 C2: outward domain edges (DONE).**
- `g1_sweep.py` sets L0d = nextafter(float(log(10⁸/π)), −∞) = 17.275950858102963 and T0d = nextafter(10⁻⁴, 0) =
  9.999999999999999·10⁻⁵. It asserts at 200 bits, in Arb, that L0d < log(10⁸/π) and T0d < 10⁻⁴.
- The corner's lower edges are L0d and T0d.
- The (R, τ) cover is outward by construction:
  - τ_lo = 0.999·√(10⁻⁴/2);
  - R-ranges are padded by ±10⁻⁶. That exceeds the float errors of R_lo (t·7·10⁻¹⁶/4) and of R_hi (from the Tinv bisection;
    below 10⁻¹⁴ by the conditioning bound |ΔL| ≤ |ΔT|/|T′| with |T′| ≥ 1.1·10⁻⁸) by more than 10⁷.
- C2 is therefore stated with the true edges: m ≥ 10⁸ and t_min = 10⁻⁴.

**A.11.4 C3: the τ* split in every (R, τ) cover (DONE).** It is in the initial grids of `g1_sweep.py` (rem mode) and
`lx_cover.py`. Children of a split box keep their parent's R-range, so they only over-cover.

**A.11.5 C4: the hybrid tiles D_G1 (DONE; the union argument).**
- **The domain:** D_G1 = {(L, t, x): L₀ ≤ L ≤ 4·10⁴, 10⁻⁴ ≤ t ≤ T(L), 0 ≤ x ≤ 10⁴}, for each parity a ∈ {0, 1}.
  Recall that t_min = 10⁻⁴ for L ≤ 4·10⁴.
- **The corner:** CORNER = [L0d, LC] × [T0d, TC] × [0, XC], with LC = float(log(10^{8.5}/π)) = 18.427243404599988, TC = 0.05 and
  XC = 5. It is covered in (L, t, x) boxes (`g1_sweep.py corner a`). The initial boxes tile CORNER exactly, and so do the
  bisections, since children share float split points.
- **The remainder:** (R, τ, x) initial boxes cover π(D_G1) = {(R, τ, x)} by A.11.1 and A.11.3. Every node N is handled in one of
  five ways:
  - **(out):** dropped if, in Arb, hi(L_N) < L0d or hi(t_N) < T0d. Then N ∩ D_G1 = ∅.
  - **(stl):** dropped if lo(L_N) > 4·10⁴. Those points are covered by Lemma STL, since D with L > 4·10⁴ has τ ≤ τ* < 0.0175 and
    R ≥ σ′ + 1.
  - **(above):** dropped if hi(L_N) ≤ 4·10⁴ and lo(t_N) > hi(T(L_N)), with T enclosed in Arb (`T_up`). Then t > T(L) on all of
    N, so N ∩ D_G1 = ∅.
  - **(corner):** dropped if hi(L_N) ≤ LC, hi(t_N) ≤ TC and hi(x_N) ≤ XC. D_G1 has L ≥ L₀ ≥ L0d and t ≥ 10⁻⁴ ≥ T0d, so
    N ∩ D_G1 ⊂ CORNER.
  - Otherwise N is certified by floor_box (S ≥ −1 in the outward-rounded sense of C1), or bisected into children that tile it.
  - Here L_N = 2(R − σ′)/τ² and t_N = 2τ² are enclosed in Arb over N, with σ′ an Arb ball.
- **Hence** D_G1 ⊂ (certified corner leaves) ∪ (certified remainder leaves), once every initial box of both modes completes with
  0 failures.
- **Ledgers:** the corner and remainder ledgers are kept separately (A.11.7).

**A.11.6 Two certifier changes made during C5 (NOT yet reviewed by bb).**
- **What happened.** The first remainder measurement (`g1_rem_a0_m1_void.*`, before the "above" drop) produced 111 348 depth-30
  failures with S = −∞.
  - Diagnosis: all of them were at x ≈ 10⁴, τ ≈ 0.304 and R ≈ 3.08, i.e. **above R_hi(τ) and outside D**. That is why the
    (above) rule was added.
  - Probing inside D found that version 1 also returned −∞ at large x·t, e.g. τ = 0.3044 and x ≥ 3 000 at every R. The true
    floor there is about +1.5.
  - The second measurement (`g1_rem_a0_m2`, with (T) below and the above rule) had 0 failures. But 31 of 578 initial boxes hit
    the 240-s cap, all with x ≥ 512. That gives an a = 0 estimate of **at least 21.9 CPU-h**, counting each capped box at 240 s.
    With both parities that is over the envelope.
- **(T): the far-tail cut. A tightness change only, rigour-neutral.**
  - U_MIN now also includes R_lo − s_fe, where s_fe solves (R − U)²/t = πx/8 + (1 − 2U)L/2 + 60 at (L_hi, t_hi, x_hi).
  - So the Gaussian beats the functional-equation growth (m/π)^{(1−2U)/2} as well as the archimedean e^{πx/8}. The old cut ignored
    the FE growth, which made the half-line majorant e^{+360}.
  - The half-line majorant ∫₀^∞ exp(Q0 + Q1v − Q2v²) is valid for every U_MIN ≤ −6. That is what the Stirling bound log Γ(y) ≤
    y log y − y + 1 needs (y ≥ 3.5). So the cut affects only tightness.
- **(R1b): the ratio form for the Riemann-sum tails, and a Lipschitz normaliser for the far half-line.**
  - **The cause of the cost.** After R1, the tail numerator Re lgΓ_a(w) and the normaliser Re lgΓ_a(c) were each enclosed over
    the whole x-box. But both vary like −πx/8 across the box, so separate enclosures lose about (π/8)·Δx. At x ≈ 4 000 with
    Δx ≈ 80 that is e^{30}.
  - **The fix (PROVED).** For a tail cell u, use Δ(u, x) = Re lgΓ_a(u − ix/2) − Re lgΓ_a(R − ix/2):
    - Evaluate it at x = x_mid. Both lgre_box calls there carry only the real radius.
    - Extend it over the box by the mean value theorem in x: ∂Δ/∂x = ¼[Im ψ(z_u) − Im ψ(z_R)], z = (·+a)/2 − ix/4. Then
      |∂Δ/∂x| ≤ ¼·(|u − R|/2)·sup_seg|ψ′|. The segment is horizontal at Im = −x/4, so sup|ψ′| ≤ trig_up((min(u, R) + a)/2, |x|_lo/4)
      (DLMF 5.15.1; Re > 0 because u ≥ ½ on this branch).
    - The FE branch uses us = 1 − u ≥ ½ and Re lgΓ(z̄) = Re lgΓ(z).
    - The boundary term lP0 uses the same rule.
    - **Code:** `ex(ub)` in floor_box.
  - **The far half-line** keeps an x-box lower bound for the normaliser, now the better of:
    - the R1 centred form;
    - lgc(x_mid) − rad_x·(π/2 + 1/(2ũ_lo))/4, from |∂/∂x Re lgΓ((R+a)/2 − ix/4)| = |Im ψ|/4 ≤ (π/2 + 1/(2ũ))/4 (DLMF 5.7.6,
      §A.8 item 3). This is bb's option (b) of R1, applied only where the numerator bound is x-free (|Γ(y+iv)| ≤ Γ(y)).
  - **Consistency check (`r1b_validate.py` 3b5640ef → `r1b_validate.out` 8af9c6f7): 30/30 checks pass.** This is consistency
    evidence only. **The proof of R1b is the derivation above, re-derived and PASSED by bb in REVIEW_P5_A11 (e570fc33) item 5.**
    - The 18 R1 checks: point values are **identical** (R1b is a no-op at x-radius 0). Two boxes became slightly tighter
      (−0.8793 against −0.8818).
    - 12 new large-x (R, τ, x) boxes (x up to 10⁴, Δx up to 100, both parities): the certified box value is ≤ the minimum of 27
      sampled point certificates, and ≤ the float floor at those points. Five box pairs that were −∞ before R1b now certify,
      e.g. R[2.90, 2.91] × τ[0.3040, 0.3044] × x[5 000, 5 100] gives 1.6945 against a point minimum of 1.6963.
  - **Copies:** pre-(T) is `tl_arb_cert_preTail.py`, pre-R1b is `tl_arb_cert_preR1b.py`. The current certifier is 4a001119.
  - **Request to bb:** review `floor_box`'s `ex`, `lognorm_m`, `lip` and the U_MIN line, and the `g1_sweep.py` classifier
    (`classify_rem`, `T_up`).

**A.11.7 C5: the measurements, and the coverage they produced.** All jobs used `g1_sweep.py` 5374c662:
- 6 worker processes, BLAS pinned to 1 thread;
- ≤ 30-min jobs, each with a DONE file;
- foreground waits on the DONE files, no pgrep;
- initial boxes in seeded random order, each completed by one worker, with a 240-s per-box cap.

| Job | Certifier | Region | Result | CPU-s per initial box | Wall |
|---|---|---|---|---|---|
| g1_corner_a0 (json fe0a8ab2) | R1b | CORNER, a = 0 | **complete**: 320/320, 5 722 evaluations, 3 021 leaves, 0 failed, worst −0.99996 | mean 0.20 | 12.7 s |
| g1_corner_a1 (6fdca9d4) | R1b | CORNER, a = 1 | **complete**: 320/320, 446 evaluations, 383 leaves, 0 failed, worst −0.99997 | 0.02 | 1.1 s |
| g1_rem_a0_m1_void (2cb82f01) | R1 + (T) | remainder, a = 0, before the above rule | 111 348 failures, all outside D (above R_hi); superseded | — | 1 724 s |
| g1_rem_a0_m2 (38298e93) | R1 + (T) | remainder, a = 0 | 547/578 completed, 31 capped (x ≥ 512), 0 failed, 563 256 leaves; estimate ≥ 21.9 CPU-h | 4.6 (completed only) | 1 723 s |
| **g1_rem_a0_m3** (40b0898c) | R1b | remainder, a = 0 | **complete**: 4 576/4 576, 452 176 evaluations, **224 903 leaves, 0 failed**, worst −0.999998, max depth 17; dropped: 6 378 out, 69 stl, 499 corner | 1.17 ± 1.86 (max 29) | 897 s |
| **g1_rem_a1_s1** (cc7723f9) | R1b | remainder, a = 1 | **complete**: 4 576/4 576, 422 268 evaluations, **212 686 leaves, 0 failed**, worst −0.99992, max depth 11; dropped: 1 403 out, 69 stl | 1.10 ± 1.54 (max 7.5) | 841 s |

- **Re-estimate (C5).** With R1b the whole G1 grid for both parities cost **about 2.9 CPU-h** (1.49 + 1.40 + 0.02), in four jobs.
  That is far inside the approved 12–25 CPU-h envelope.
  - The lead's instruction was to start the sweep straight away if the re-estimate fell inside the envelope. Because each initial
    box is completed by its own worker, **the a = 0 measurement job was itself the complete a = 0 remainder sweep**. I then ran the
    a = 1 remainder job (one more job of 841 s).
  - No further jobs are needed, and none are queued.
- **Worst leaves near −1** are the bisection stopping rule (§A.10 R2), not slack.
- **Coverage ledger** (boxes certified / failed / region done):
  - **corner:** a = 0 3 021 / 0 / all; a = 1 383 / 0 / all;
  - **remainder:** a = 0 224 903 / 0 / all; a = 1 212 686 / 0 / all;
  - **LX** (x ≥ 10⁴): 3 069 / 0 / all, both parities;
  - **STL** (L > 4·10⁴): analytic;
  - m-range done: every m ≥ 10⁸ (L ∈ [L₀, 4·10⁴] by G1 + LX, L > 4·10⁴ by STL).
- **Pre-R1b certified leaves** (m2's 563 256) are valid under the R1 + (T) certifier but are **not needed and not used**
  (REVIEW_P5_A11 N-old). The certificate of record is the four R1b ledgers.

**A.11.8 Nit N-c (STL), DONE.** Re c₁ ≥ 2.618 − 2.5·10⁻⁵. Using Z(2.6179) = 0.250988 (Arb, 128 bits; it was 0.250959 at 2.618),
STL's bound becomes ½(−0.0795154 − 0.250988) − 0.01 = **−0.17525** (was −0.175). The conclusion S − L/4 ≥ −0.18 ≥ −1 is
unchanged. §A.9.3's "−0.175 ≥ −1" should be read with this constant.

**A.11.9 C6: the plan for P2′ in Arb (not started; it is load-bearing).**
- **What is needed.** For every L ≥ L₀ and every t ∈ [t_min(L), T(L)], there must be a finite X(L) such that H_t has no zeros with
  x ≥ X(L) and √b(L) ≤ |y| ≤ 1. Uniformity in t over the contraction phase is what the first-contact argument uses.
- **Plan (P2′-a), L ∈ [L0d, L₁] with L₁ = 4·10⁴:**
  - Use Arb boxes in (L, t, y), with m = πe^L as a ball, and evaluate `lemma_z.ok` with arb in place of mpmath.
  - Take ℓ = ℓ_box from the float search (`lemma_z.ell_star`), rounded up.
  - y-boxes, rather than the current 61-point y sample, make the y-uniformity rigorous.
  - x ≥ X follows from the CITED monotonicity in x for x ≥ 480 (FGMPS pp.59–60). That monotonicity covers each term and must be
    checked term by term for the m-explicit forms used here. That re-read is the first step.
  - Arb handles ℓ up to 10⁶ (log₁₀X ≈ 4·10⁵) without difficulty.
- **Plan (P2′-b), L > L₁:** an analytic large-L lemma in the style of STL. Choose ℓ(L, t, y_b) explicitly (≍ L²/t at y_b = 1/L)
  so that each error term (η, e_{C,0}, ζ(r) − 1, ĝζ(r′)) is at most 1/10. B*_m ≤ √m·f(m) and the q^{−y/2} decay are explicit.
  This is a desk derivation.
- **Cost:** P2′-a is minutes of Arb. P2′-b is desk work. Neither has been done.

**Status of C2 after A.11.** It is still **PARTIAL**, as bb's C6 says. All of the following are now in place:
- the sweep covers the compact domain for both parities (A.11.7);
- LX is re-run with the R-x fix;
- STL holds.

Still open:
- **bb's review of the two certifier changes (T) and R1b, and of the g1_sweep classifier and union argument;**
- **P2′ in Arb**, i.e. (P2′-a) and (P2′-b).

conjecture1_proved = False. Nothing here is progress on RH: C2 is a large-conductor bound on Λ_χ, not GRH.

### A.12 Addendum 7: C6, P2′ in Arb (lead's request after REVIEW_P5_DELTA)

| Step | Outcome |
|---|---|
| Re-read FGMPS pp.57–60 at source (§6.5–6.6), together with Prop 4.18 (pp.43–46) | **DONE, CITED-READ.** The per-term x-monotonicity used by lemma_z is now justified term by term (A.12.1). A pointer error in lemma_z's docstring is corrected. |
| (a) L ≤ 4·10⁴ | **WORKS, via one uniform analytic lemma (Lemma Z′) with Arb constants.** Independently checked on 46 080 (L, t, y) Arb boxes, 0 failed, worst Q ≥ 0.925. |
| (b) L > 4·10⁴ | **WORKS, the same Lemma Z′ (analytic, all L).** Sample Arb check on 15 360 boxes for L ∈ [4·10⁴, 10¹²], 0 failed, worst Q ≥ 0.908. |

Nothing in P2′ failed, so no workaround was needed. The one design change is that **the confinement radius is now uniform**:
X(L) = 4e^{ℓ(L) − L} for all t ∈ [t_min(L), ½] and all y ∈ [y_b(L), 1]. The earlier float version found a separate X(m, t, y_b)
for each sampled point.

**A.12.1 The source, item by item (CITED-READ, FGMPS 2610.27343).**
- **The criterion, Thm 4.3 (p.22) with p.57.** H_t/B_t = f_t + O≤(e_A + e_B + e_{C,0}) for x ≥ 480, |y| ≤ 1, 0 ≤ t ≤ ½. Since
  B_t ≠ 0, non-vanishing follows from |f_t| > E. Region (c) (§6.6, pp.60–62) uses exactly 1 − |f − 1| − E > 0, with the n = 1
  term isolated. Lemma Z′ uses the same inequality, but bounds |f − 1| by ζ-values instead of FGMPS's Lemma 8.2 tail.
- **Prop 4.18 (pp.43–46).** Its items (1)–(6) give |γ|, Re s*(+), |κ|, e_A, e_B and e_{C,0} with E_RS in (4.41). It is **stated for
  3 ≤ m ≤ 4·10⁵**. The extension to every m ≥ 3 is §A.8 item 1, re-checked from the text as now read:
  - Item (1)'s m-free part, 4/x² + log(x/4π)/(8(x−2)) + π/(16(x−2)) + 1/(2(x−2)²) at x = 480, is 1.38·10⁻³ ≤ 0.002. The m-part,
    log m/(8·478), is ≤ log m/3800.
  - Items (4)–(5): 5/4 + π²/256 + (log(x/4π) + π/2)/(8(x−2)) + 1/(4(x−2)²) at x = 480 is 1.2899 ≤ 1.3. The m-part,
    log m/(8·478), is ≤ log m/2250.
  - Each ratio log(x/4π)/(x−2) is decreasing, as FGMPS use.
  - Item (6) keeps B*_m, with B*_m ≤ √m·f(m) for m ≥ 3 ((4.31), §A.8). E_RS carries c₁(0) = 2φ(m)/5 ≤ 2m/5.
- **The |f − 1| bound** (as in lemma_z; derived from p.57 and Prop 4.18(2)):
  - b_n n^{−Re s*(+)} ≤ n^{−r}, with r = (1+y)/2 − ε₁ + (t/4)ℓ′. This uses n ≤ M ≤ δ₊ = √(q(1 + πt/4x)) (p.57), so
    ℓ − log n ≥ ℓ′ := ℓ/2 − ½log(1 + πt/4x).
  - The γ-sum gives n^{−r′}, with r′ = (1−y)/2 − ε₁ + (t/4)ℓ′, and the factor M^{|κ|} ≤ exp(ty·log δ₊/(2(x−2))).
  - Hence |f − 1| ≤ (ζ(r) − 1) + g·ζ(r′) and e_A + e_B ≤ η(ζ(r) + gζ(r′)), with η = e^{d_m} − 1 and
    d_m = (t²ℓ²/16 + log m/2250 + 1.3)/(x − 5/2) (|L_n| ≤ ℓ, p.45).
- **Monotonicity in x, term by term** (PROVED, using FGMPS's derivative facts on pp.58–59). For fixed (m, t, y):
  - ℓ′ increases and ε₁ decreases, so r and r′ increase, and ζ(r) and ζ(r′) decrease.
  - In g, q^{−y/2} decreases, and log δ₊/(x−2) decreases (p.58, given log δ₊ > 2).
  - d_m decreases (p.58: d log(e^d − 1)/d log x < −0.89, since √(a/c) < 0.110 with c ≥ 1.3, uniformly in m).
  - In e_{C,0}: (mT′/2π)^{−(1+y)/4} and e^{−tℓ²/16} decrease; K_m(x) = exp((¼|ℓ + iπ/2| + 1.54)/(x − 5/2)) decreases (p.59,
    N′(x) ≤ 1/(4x)); and E_RS decreases, since T′ increases.

  So Q(x) := 1 − (ζ(r) − 1) − gζ(r′) − η(ζ(r) + gζ(r′)) − e_{C,0} is non-decreasing in x, and **Q(X) > 0 gives zero-freeness
  for all x ≥ X.**
- **Correction.** lemma_z.py's docstring cites "FGMPS pp.59–60" for monotonicity. FGMPS prove it on pp.58–59 for *their* majorants
  (6.4) and (6.5), which are not term-for-term ours. The per-term argument above is what is used.

**A.12.2 Lemma Z′ (P2′, uniform form; PROVED, with constants in Arb).**
- **Statement.** Let χ be real primitive with conductor m, L = log(m/π) ≥ L₀. Put:
  - t_min = min(10⁻⁴, 4/L) and y_b = √b(L) = min(0.01, 1/L);
  - ℓ(L) = 8·max(4·10⁴, L) (so ℓ ≥ 32/t_min, ℓ ≥ 8/y_b, ℓ ≥ 8L and ℓ ≥ 3.2·10⁵);
  - X(L) = 4e^{ℓ(L) − L}, i.e. q = mX/4π = e^{ℓ}.

  Then H_t^χ(x + iy) ≠ 0 whenever |x| ≥ X(L), y_b ≤ |y| ≤ 1 and t_min ≤ t ≤ ½.
- **Proof.** Fix x = X (larger x by A.12.1, and negative x or y by the symmetries of H_t). All of the following are Arb-checked
  in `p2z_arb.py` part 1:
  - **(i) X is huge.** L ≤ ℓ/8 gives X ≥ 4e^{7ℓ/8} ≥ 480.
  - **(ii) r and r′.** (t/4)ℓ′ ≥ tℓ/8 − πt/(32X) ≥ 4 − 10⁻¹⁰⁰, since tℓ ≥ t_min·ℓ ≥ 32. Also ε₁ ≤ 2/X². So r ≥ 4.49 and r′ ≥ 3.99.
    Hence ζ(r) − 1 ≤ 0.055148 and ζ(r′) ≤ 1.083016.
  - **(iii) g.** a_m = 0.002 + (L + log π)/3800 ≤ 0.0024 + ℓ/30400, and t·log δ₊/(2(X−2)) ≤ 10⁻¹⁰⁰. So
    log g ≤ y(a_m − ℓ/2 + 10⁻¹⁰⁰) ≤ −0.4999·y_b·ℓ ≤ −3.9992, giving g ≤ 0.018331.
  - **(iv) η.** With t ≤ ½ and log m ≤ ℓ/8 + 1.15, η ≤ 2d_m ≤ 2(ℓ²/64 + ℓ/18000 + 1.31)/(4e^{7ℓ/8} − 2.5) ≤ 10^{−121593} at
    ℓ = 3.2·10⁵. This majorant decreases in ℓ.
  - **(v) e_{C,0}.**
    - (mT′/2π)^{−(1+y)/4} ≤ q^{−1/4} = e^{−ℓ/4}, and e^{−tℓ²/16} ≤ 1.
    - B*_m ≤ √π·e^{L/2}·1.0000001·(log m/(2π) + 1.276874) ≤ 1.7726·e^{ℓ/16}(ℓ/50 + 3).
    - c₁(0) ≤ (2π/5)e^{L} ≤ 1.2567·e^{ℓ/8}, and √(T′/7.49) − 1.5 ≥ 0.25·e^{7ℓ/16}.
    - So e_{C,0} ≤ 10^{−26053} at ℓ = 3.2·10⁵, and this majorant also decreases in ℓ.
  - **Conclusion.** Q ≥ 1 − 0.055148 − 0.018331·1.083016 − 10⁻¹⁰⁰(…) ≥ **0.9250 > 0** (Arb lower bound 0.925001). ∎
- **What changed from §A.8.** The old float X(m, t, y_b) (lemma_z.ell_star) had a separate radius per point and a 61-point y sample.
  It is replaced by this uniform X(L), with no y sampling. Uniformity over t ∈ [t_min, T(L)] ⊂ [t_min, ½] is exactly what the
  first-contact argument needs: for every t in the contraction phase, all zeros at height ≥ √b lie in |x| < X(L).

**A.12.3 Independent Arb check** [N-x, REVIEW_P5_A12. Each box is checked on x ≥ X_box = 4e^{ℓ₀ − L_lo}, which is the box *maximum* of
X(L): a larger radius than Lemma Z′ states. That is fine for C2, since any finite radius suffices. The check confirms zero-freeness
on x ≥ X_box, and Lemma Z′'s analytic proof covers X(L) itself exactly.] (`p2z_arb.py` b732f0ef → `p2z_arb.json` 2b41dc9b, `p2z_arb.DONE` 69319cef; 1.6 s, one core).**
- **Method.** `Q_box` evaluates the *unsimplified* Q (every FGMPS term, with m, q, B*_m and c₁(0) carried as logarithms) on
  (L, t, y) boxes, at the single point x = X_box = 4e^{ℓ₀ − L_lo} of each L-box, where ℓ₀ = 8·max(4·10⁴, L_hi). By A.12.1 this covers
  every x ≥ X_box. Each L-box has 24 geometric t-boxes on [t_min(L_hi), ½] and 16 geometric y-boxes on [y_b(L_hi), 1].
- **Region A** (L ∈ [L0d, 4·10⁴], 120 L-boxes): **46 080 boxes, 0 failed, worst Q ≥ 0.92538.**
- **Region B** (L ∈ [4·10⁴, 10¹²], 40 L-boxes; a check only, since B is covered by the lemma for all L): **15 360 boxes, 0 failed,
  worst Q ≥ 0.90844.** The lower worst value comes from the width of the wide L-boxes, through the arb product-of-balls loss.
- **Process note.** A first version computed x = 4e^{ℓ−L} over the L-ball, which produced a ball containing 0 (NaN). A second
  computed √m and m/π over wide balls (NaN). Both are fixed by evaluating at the fixed point X_box and keeping large
  quantities in log form. No result was taken from either broken version.

**A.12.4 DRAFT: the C2 statement of record.** [SUPERSEDED by the FINAL record in §A.13. REVIEW_P5_A12 (f6cade54) PASSED §A.12.]

> **Theorem C2 (unconditional large-conductor bound for Λ_χ; not GRH).** Let χ be a real primitive Dirichlet character of
> conductor m ≥ 10⁸. Let Λ_χ be its generalized de Bruijn–Newman constant (H_t^χ as in FGMPS 2610.27343 (1.2)). Put
> L = log(m/π), t_min = min(10⁻⁴, 4/L), b = min(10⁻⁴, L⁻²), k = (4/√5)(L/4 − 1) − 2 and
> T(L) = t_min + k⁻¹·log((2 + k(1 − 2t_min))/(2 + kb)). Then
> **Λ_χ ≤ T(L) + b/2.**
> - This is 0.27643 at m = 10⁸ and decreases on L ∈ [L₀, 4·10⁴] (A.11.1: T is strictly decreasing there, Arb). For L ≥ 4·10⁴,
>   T(L) ≤ t_min + log(1 + k/2)/k ≤ 10⁻⁴ + 5.1·10⁻⁴, since log(1 + k/2)/k decreases in k and k(4·10⁴) ≈ 17 885 (PROVED).
>   So it is **< 9/32 for every m ≥ 10⁸**, and it equals (√5 + o(1))·log log m/log m.
> - Values: 0.0122908 at L = 10³ and 0.00182589 at L = 10⁴.
> - **Hypotheses:** none beyond χ real primitive with m ≥ 10⁸. No GRH, no zero-free half-plane, no numerical zero verification.
>   Siegel zeros are allowed. The bound is ≫ 1/log m, consistent with the Siegel sanity rule.
> - **Proof components and their trust class:**
>   1. Contraction on [0, t_min] by the classical (y²)′ ≤ −2 (CITED-READ, as in §A.8).
>   2. The S-floor transfer: Planat 2609.37164 Thm 2.1 and Prop 2.3, and Hakimoglu-Brown 2610.12803 Thm 9 (one step, p = √5).
>      CITED-READ; the bridge numerator is Telperion-certified; bb PASS (REVIEW_P5).
>   3. The TL floor S_χ(x, √5, t) ≥ L/4 − 1 on t ∈ [t_min, T(L)], all x:
>      - G1 (Arb, A.11.7; both parities complete, 0 failures; **reviewed: REVIEW_P5_A11 e570fc33 PASS on items 1–7**, with (T),
>        R1b, the classifier and the union argument re-derived, and a 184-box seeded re-run from copied code; the (above) drop
>        rule never fired in the final runs, so no result depends on it);
>      - LX (Arb plus the proved v-monotonicity; bb PASS in method; re-run with R-x, A.11.1);
>      - STL (analytic plus Arb constants; bb PASS, N-c applied).
>   4. The confinement P2′: Lemma Z′ (A.12.2; analytic plus Arb constants; **pending bb**), using FGMPS Thm 4.3 and Prop 4.18
>      (CITED-READ; m-extension checked in §A.8/A.12.1; **N2 now re-read at source by bb in REVIEW_P5_A12**: Prop 4.18's proof is
>      m-general. FGMPS *state* Prop 4.18 only for 3 ≤ m ≤ 4·10⁵; the extension is ours, read off its proof).
>   5. De Bruijn's strip theorem at the end (FGMPS Thm 2.6, CITED-READ).
> - **Trust class:** Arb (python-flint ball arithmetic) certificates, plus sources read at source (FGMPS, Planat, H-B, BMOR,
>   DLMF), plus AI-written proofs, **AI-reviewed (bb)**. No Lean. No operator read-back.
> - **What remains:**
>   - (i) [DONE: REVIEW_P5_A12 PASSED §A.12, and re-read N2 at source. REVIEW_P5_A11 PASSED §A.11.]
>   - (ii) the Rademacher convexity constant used in the certifier's tails is read in BMOR Lemma 5.6, not in Rademacher 1959;
>   - (iii) FGMPS is an October 2026 preprint;
>   - (iv) an optional Lean/Comparator formalization of the statement layer (items 10–13, 11 now uniform);
>   - (v) operator read-back.
>
>   **Until (i) is done, C2 is PARTIAL only on C6.** C6 (P2′, Lemma Z′) is done in §A.12 but not yet reviewed. G1, LX, STL and
>   the domain reduction are reviewed certificates.

**A.12.5 Statement layer, item 11 (replaces the earlier form):**
```
theorem P2'_uniform (χ real primitive mod m) (hL : log (m/π) ≥ L0) (t : ℝ) (ht : tmin L ≤ t ∧ t ≤ 1/2)
    (x y : ℝ) (hx : 4 * exp (8 * max 4e4 L - L) ≤ |x|) (hy : min 0.01 (1/L) ≤ |y| ∧ |y| ≤ 1) :
  H χ t (x + y*I) ≠ 0          -- L := log(m/π); from FGMPS Thm 4.3 + Prop 4.18 (all m ≥ 3) and Lemma Z′
```

### A.13 FINAL: the C2 statement of record (2026-10-31)

This section supersedes §A.8 item 5, §A.12.4 and §6 items 10–13. **Release is the user's decision.** Nothing here has been
posted or pushed.

**A.13.1 The theorem.**

> **Theorem C2 (an unconditional large-conductor bound for the generalized de Bruijn–Newman constant; NOT GRH).**
>
> Let χ be a real primitive Dirichlet character of conductor m ≥ 10⁸. Let H_t^χ be its heat flow (FGMPS 2610.27343 (1.2);
> equivalently (4.1)), and let Λ_χ be its generalized de Bruijn–Newman constant. Put
>
> L = log(m/π), t_min = min(10⁻⁴, 4/L), b = min(10⁻⁴, L⁻²), k = (4/√5)(L/4 − 1) − 2,
> T(L) = t_min + k⁻¹·log((2 + k(1 − 2t_min))/(2 + kb)).
>
> Then all zeros of H_t^χ are real for every t ≥ T(L) + b/2. That is,
>
> **Λ_χ ≤ T(L) + b/2.**

- **Hypotheses:** only that χ is real and primitive with m ≥ 10⁸, of either parity. None of the following is assumed:
  - GRH;
  - a zero-free half-plane (no OAI / quasi-RH input; the initial strip is the trivial |Im z| ≤ 1);
  - a numerical zero verification.

  Siegel zeros are allowed. They lie on iℝ with |y| ≤ 1 and are untouched by the argument.
- **Values** (Arb):
  - at m = 10⁸: **0.2764281989** (0.27642819894712965937… ± 10⁻⁵⁹);
  - **< 9/32 for every m ≥ 10⁸**. On L ∈ [L₀, 4·10⁴], T is strictly decreasing (rhi_monotone, Arb). For L ≥ 4·10⁴,
    T ≤ 10⁻⁴ + log(1 + k/2)/k ≤ 6.09·10⁻⁴;
  - at L = 10³: 0.0122908; at L = 10⁴: 0.00182589; at m with log m = 10⁹: 4.7·10⁻⁸;
  - **asymptotically (√5 + o(1))·log log m/log m.**

  This is ≫ 1/log m, so it is consistent with the Siegel sanity rule. It is a bound on Λ_χ for large conductor, not GRH, and says
  nothing about RH. conjecture1_proved = False.

**A.13.2 Trust class.**
- **Rigour:** Arb certificates (python-flint ball arithmetic, outward-rounded acceptance), sources read at source, and AI-written
  proofs (P5).
- **Review:** reviewed by **one AI reviewer (bb)** across four reviews.
- **Not** a Lean proof. **No** operator read-back.
- The one external load-bearing source with the most weight, FGMPS 2610.27343, is an **unrefereed October 2026 preprint**.
- Also: Rademacher's convexity constant is read in BMOR 2005.02989 Lemma 5.6, not in Rademacher (1959).

**A.13.3 Components, with sources and reviews.**

| # | Component | Content | Source / certificate | Review (md5) |
|---|---|---|---|---|
| 1 | Domain reduction (§A.9.0) | TL is needed only for t ∈ [t_min(L), T(L)]. On [0, t_min] the classical (y²)′ ≤ −2 applies; after T(L), de Bruijn's strip theorem gives + b/2 | PROVED; FGMPS Thm 2.6 (p.10), CITED-READ | REVIEW_P5_DELTA 206b88e76dfe510c9e22b325f5de009a (item 6) |
| 2 | t = 0 floor and the exact Gaussian tilt (§A.3, §A.6) | S = ¼log(m/π) + ½Re(E[F′]/E[F]) at the tilted centre; Gaussian form = FGMPS (4.1) | PROVED; FGMPS (4.1) p.19, CITED-READ | REVIEW_P5 e909a59c66f979ca66c1198579ba3ce1 |
| 3 | The transfer (S-floor ⇒ contraction) | Planat 2609.37164 Thm 2.1 + Prop 2.3; Hakimoglu-Brown 2610.12803 Thm 9, one step at p = √5 | CITED-READ; bridge numerator Telperion-certified (§6 item 9) | REVIEW_P5 e909a59c. **Caveat:** bb did NOT re-check the Telperion-certified bridge numerator (REVIEW_P5 §8); bb only matched (c²−1)(c²−5) to Planat Prop 2.3 |
| 4a | TL floor, compact part G1 | S_χ(x, √5, t) ≥ L/4 − 1 for L ∈ [L₀, 4·10⁴], t ∈ [10⁻⁴, T(L)], 0 ≤ x ≤ 10⁴, both parities | Arb: tl_arb_cert.py 4a001119 (R1 + C1 + (T) + R1b), g1_sweep.py 5374c662; ledgers g1_corner_a0/a1 fe0a8ab2/6fdca9d4, g1_rem_a0_m3 40b0898c, g1_rem_a1_s1 cc7723f9. 440 993 certified leaves, 0 failures | REVIEW_P5_DELTA 206b88e7 (R1, R2, the gate); REVIEW_P5_A11 e570fc33bbb712272d522bcd72643e88 (items 1–7, incl. a 184-box re-run) |
| 4b | TL floor, x ≥ 10⁴ (LX) | S ≥ L/4 − 0.77 for L ≤ 4·10⁴, t ∈ [10⁻⁴, T(L)], \|x\| ≥ 10⁴ | proved v-monotonicity (§A.9.2) + Arb lx_cover.py fa243994 → lx_cover_Rx.out 77cadb55: 3 069 boxes, 0 failed, worst −0.7689 | REVIEW_P5_DELTA 206b88e7 (method); REVIEW_P5_A11 e570fc33 (R-x re-run). **Caveat:** of the v-monotonicity lemma, bb spot-checked part (a) only. Parts (b)–(g) were read but not fully re-derived (REVIEW_P5_DELTA item 4) |
| 4c | TL floor, L > 4·10⁴ (STL) | S ≥ L/4 − 0.18 for τ ≤ 0.0175, R ≥ 2.618, all x. This contains every domain point with L > 4·10⁴ | PROVED; Arb constants (Z(2.6179) = 0.250988 gives −0.17525) | REVIEW_P5_DELTA 206b88e7; REVIEW_P5_A11 e570fc33 (N-c) |
| 4d | Domain tiling | R_hi is monotone on each side of τ* (Arb); outward edges; the hybrid union argument | rhi_monotone.py 66a25bab → .out 98c86374; c2_domain.py f84d38a1 | REVIEW_P5_A11 e570fc33 |
| 5 | Confinement P2′ (Lemma Z′, §A.12.2) | H_t ≠ 0 for \|x\| ≥ 4e^{8max(4·10⁴, L) − L}, min(0.01, 1/L) ≤ \|y\| ≤ 1, t_min ≤ t ≤ ½ | PROVED, constants in Arb (Q ≥ 0.9250); check p2z_arb.py b732f0ef → p2z_arb.json 2b41dc9b (61 440 boxes, 0 failed); FGMPS Thm 4.3 + Prop 4.18 for every m ≥ 3 (CITED-READ; the extension beyond 4·10⁵ is read off FGMPS's proof) | REVIEW_P5_A12 f6cade5446ee9202b103447e8d5367e4 (incl. N2 at source); Prop 4.18 also in REVIEW_P5 e909a59c |
| 6 | Special-function inputs (G2) | DLMF 5.15.1, 5.7.6, 5.6.6; FGMPS Lemma 4.2(5); BMOR Lemma 2.1, Prop 2.2 (proof step; also PROVED), Lemma 5.6; H-B p.11 monotonicity | CITED-READ / PROVED | REVIEW_P5 e909a59c |
| 7 | Values and "< 9/32 for every m ≥ 10⁸" | as in A.13.1 | Arb | REVIEW_P5_A12 f6cade54 (item 7) |

**Assembly.**
1. On [0, t_min] the maximal zero height contracts classically.
2. On [t_min, T(L)] the S-floor C = L/4 − 1 (components 4a–4c) feeds H-B's one-step comparison (component 3) with
   k = 4C/√5 − 2.
3. The first contact of the barrier √Q(t) with a zero is attained, because P2′ (component 5) confines all zeros at height ≥ √b to
   |x| < X(L) uniformly in t.
4. Hence the maximal height² is ≤ b at t = T(L).
5. De Bruijn's strip theorem then gives Λ_χ ≤ T(L) + b/2 (component 1).

**A.13.4 Telperion statement layer, items 10–13, ready for the Lean build** (statements only, with shared definitions; nothing was
built). For the lead, via leanlock + Comparator.

Two notes on the encoding:
- H is defined through FGMPS's heat-kernel form (4.1), for t > 0. Mathlib's `Complex.Gamma` takes a junk value at its poles, but
  those are a null set inside the integral, so every statement is for t > 0. Every t used is ≥ t_min > 0.
- Cited ingredients would enter the build as hypotheses or `axiom`s, and the lead decides which:
  - FGMPS Thm 4.3 / Prop 4.18 (m-general form), Thm 2.6;
  - Planat Thm 2.1 / Prop 2.3;
  - H-B Thm 9;
  - DLMF / BMOR / Rademacher.

```lean
import Mathlib

open Complex MeasureTheory

noncomputable section

namespace C2

variable {m : ℕ} [NeZero m]

/-- parity a ∈ {0,1}: a = 0 for even χ, a = 1 for odd χ -/
def parity (χ : DirichletCharacter ℂ m) : ℕ := if χ (-1) = 1 then 0 else 1

/-- real-valued character -/
def IsRealChar (χ : DirichletCharacter ℂ m) : Prop := ∀ n : ZMod m, (χ n).im = 0

/-- completed L-function ξ_L(s) = (m/π)^{(s+a)/2} Γ((s+a)/2) L(s,χ)  (FGMPS §2.3) -/
def xi (χ : DirichletCharacter ℂ m) (s : ℂ) : ℂ :=
  ((m : ℂ) / (Real.pi : ℂ)) ^ ((s + (parity χ : ℂ)) / 2) * Complex.Gamma ((s + (parity χ : ℂ)) / 2) *
    DirichletCharacter.LFunction χ s

/-- heat flow, FGMPS (4.1), for t > 0:  H_t(z) = ∫ ξ((1+iz)/2 + √t v) e^{-v²}/√π dv -/
def H (χ : DirichletCharacter ℂ m) (t : ℝ) (z : ℂ) : ℂ :=
  ∫ v : ℝ, xi χ ((1 + I * z) / 2 + ((Real.sqrt t * v : ℝ) : ℂ)) * ((Real.exp (-v ^ 2) / Real.sqrt Real.pi : ℝ) : ℂ)

/-- S(x,p,t) = -Im (H_t'/H_t)(x + i p) -/
def S (χ : DirichletCharacter ℂ m) (x p t : ℝ) : ℝ :=
  -((deriv (H χ t) ((x : ℂ) + (p : ℂ) * I)) / H χ t ((x : ℂ) + (p : ℂ) * I)).im

def Lc (m : ℕ) : ℝ := Real.log ((m : ℝ) / Real.pi)
def L0 : ℝ := Real.log (10 ^ 8 / Real.pi)
def tmin (L : ℝ) : ℝ := min (1 / 10000) (4 / L)
def bC2 (L : ℝ) : ℝ := min (1 / 10000) (1 / L ^ 2)
def kC2 (L : ℝ) : ℝ := 4 / Real.sqrt 5 * (L / 4 - 1) - 2
def TC2 (L : ℝ) : ℝ :=
  tmin L + Real.log ((2 + kC2 L * (1 - 2 * tmin L)) / (2 + kC2 L * bC2 L)) / kC2 L
def C2bound (m : ℕ) : ℝ := TC2 (Lc m) + bC2 (Lc m) / 2

/-- the C2 TL domain (memo A.9.0) -/
def InDomain (L t : ℝ) : Prop := L0 ≤ L ∧ tmin L ≤ t ∧ t ≤ TC2 L

/-- item 10: Theorem C2 (statement of record, memo A.13.1) -/
theorem C2_large_conductor (hm : 10 ^ 8 ≤ m) (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive)
    (hreal : IsRealChar χ) :
    ∀ t : ℝ, C2bound m ≤ t → ∀ z : ℂ, H χ t z = 0 → z.im = 0 := by
  sorry

/-- item 10': the numerical corollary (pure real analysis; Arb-certified in memo A.11.1 / A.13.1) -/
theorem C2bound_lt_9_32 (hm : 10 ^ 8 ≤ m) : C2bound m < 9 / 32 := by
  sorry

/-- item 10'': the TL floor on the whole C2 domain (= G1 ∪ LX ∪ STL, memo A.13.3 rows 4a–4d) -/
theorem TL_floor_C2 (hm : 10 ^ 8 ≤ m) (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive)
    (hreal : IsRealChar χ) (t x : ℝ) (hD : InDomain (Lc m) t) :
    Lc m / 4 - 1 ≤ S χ x (Real.sqrt 5) t := by
  sorry

/-- item 11: P2′, uniform confinement (Lemma Z′, memo A.12.2) -/
theorem P2'_uniform (hm : 10 ^ 8 ≤ m) (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive)
    (hreal : IsRealChar χ) (t : ℝ) (ht : tmin (Lc m) ≤ t ∧ t ≤ 1 / 2) (x y : ℝ)
    (hx : 4 * Real.exp (8 * max 40000 (Lc m) - Lc m) ≤ |x|)
    (hy : min (1 / 100) (1 / Lc m) ≤ |y| ∧ |y| ≤ 1) :
    H χ t ((x : ℂ) + (y : ℂ) * I) ≠ 0 := by
  sorry

/-- item 12: LX (memo A.9.2 + R-x re-run A.11.1; certified worst -0.7689) -/
theorem LX (hm : 10 ^ 8 ≤ m) (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive) (hreal : IsRealChar χ)
    (hL : Lc m ≤ 40000) (t x : ℝ) (hD : InDomain (Lc m) t) (hx : 10000 ≤ |x|) :
    Lc m / 4 - 77 / 100 ≤ S χ x (Real.sqrt 5) t := by
  sorry

/-- item 13: STL (memo A.9.3, with N-c); covers every domain point with L > 4e4 -/
theorem STL (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive) (hreal : IsRealChar χ) (t x : ℝ) (ht : 0 < t)
    (hL : 40000 < Lc m) -- [LEAN FIX, lead 2026-11-01: bb REVIEW_P5_FINAL note (i) / REVIEW_LEAN_DQ1 item 4]
    (hτ : t ≤ 2 * (175 / 10000) ^ 2) (hR : 2618 / 1000 ≤ (1 + Real.sqrt 5) / 2 + t * Lc m / 4) :
    Lc m / 4 - 18 / 100 ≤ S χ x (Real.sqrt 5) t := by
  sorry

/-- item 13': the domain fact used to apply STL (REVIEW_P5_A11, (stl) rule) -/
theorem STL_applies (L t : ℝ) (hL : 40000 < L) (hD : InDomain L t) :
    t ≤ 2 * (175 / 10000) ^ 2 ∧ 2618 / 1000 ≤ (1 + Real.sqrt 5) / 2 + t * L / 4 := by
  sorry

end C2
```

Notes for the build:
- **Two items are pure real-analysis lemmas** and are the natural first Lean targets (interval bounds on log, √5 and exp):
  - `C2bound_lt_9_32`;
  - `STL_applies` (it needs T decreasing on [L₀, 4·10⁴] plus T(4·10⁴) ≤ 6.09·10⁻⁴).
- `TL_floor_C2`, `LX` and the G1 part are Arb certificates. A Lean version would need a certified-interval replay; that is a
  separate decision.
- `C2_large_conductor` follows from `TL_floor_C2` + `P2'_uniform` + the cited transfer and strip theorems (A.13.3 assembly).

**A.13.5 What remains (none of it blocks the statement in its trust class).**
- (a) Lean / Comparator formalization of A.13.4. This is optional, and the lead decides.
- (b) An operator read-back.
- (c) Refereeing of FGMPS 2610.27343, which is external.
- (d) Rademacher (1959) read in the original. The constant is currently read via BMOR.
- (e) Release is the user's decision. Any companion note to the published Λ_χ paper is likewise the user's call.

