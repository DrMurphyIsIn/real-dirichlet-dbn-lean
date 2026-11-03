# REVIEW_W2B3: bb's review of W2B3 (H-B Theorem 12 on the uniform route; walls 1.65·10⁶ odd / 3.7·10⁶ even)

2026-11-02. **AI review by bb, NOT an operator read-back.** Nothing here is progress on RH.

**Object.**
- **Memo:** Z3/W2B3_memo.md **ec5e2fdd**.
- **Files:** all 17 md5s in its §9 recomputed by bb and matching (cert adaf2ee3, big2 e7f43d44, phi 797ff1d8, bound 4b4ca675,
  sweep 9c5babc3, ledger concatenations d496a4f8 / feb27a07, bound JSONs 87e26183 / 55c37c93, …).
- **Timeline consistent with "edited before the runs of record":** certifier 22:15, measurement 22:26, sweeps 22:43–22:45.

**What I read and ran.**
- **Read:**
  - both certifier diffs in full, and the G1 bulk loop, the G1 tails, the LX integrand_bounds, log_q and the IIa/IIb code;
  - H-B 2610.12803 pp. 13–18 and 21–25 at source (alphaXiv).
- **Ran, in bb's scratchpad (bbw2b3/), on copies only:**
  - my own exact Bernstein checker (bb_phi.py);
  - my own landing (bb_land.py, mpmath 50 digits);
  - a fixed-code copy of the certifier with all 78 slab sweeps re-run (2 workers, BLAS pinned; ≈ 8 CPU-min);
  - a v-monotonicity scan.

No team file other than this one was written.

## Verdict: PASS after one required fix (F1). The bug is real but not load-bearing: the covers re-run with it fixed still pass 39/39 per parity

### F1 (required): a bound-direction bug in the new G1 accumulator

**Where.** w2b3_cert.py :113:

    dL = tau * absg * Z2_up(uZ),   uZ = max(lo(u), u0)

**Why it is wrong.**
- The mean value theorem on the segment [c, w] needs sup |(L′/L)′| over the segment, that is Z2 at the segment's **minimum**
  real part.
- For bulk cells with g ≥ 0, Re w ≥ R, so that minimum is R. The S path already uses it (`umin = Rb`), and so do numc's ψ
  part and the LX certifier (big2 `uminL = Rc1`).
- uZ is the cell's own real part. Z2 is decreasing, so for g > 0 the code takes Z2(Re w) ≤ Z2(R).
- dL then *under*-estimates |L′/L(w) − L′/L(c)|. The sharp bound is Z(R) − Z(Re w) ≥ τg·Z2(Re w). And because the min(dL, dL2) picks
  dL for small and moderate g, the error reaches the bulk mass, which sits at g ≈ τρ > 0.

**The fix.** `dL = tau * absg * Z2_up(umin)`, keeping `Z2u = Z2_up(uZ)` for the pointwise |f′(w)| term, which is correct.

**Its effect, measured** (bb's copy, all 39 slabs per parity, the ledgers' own CF/CG/t/τ arguments, Y3_P = 7/2):

| parity | slabs | failures | evals (record → fixed) | largest rise in maxG_g1 | smallest CG − max G |
|---|---|---|---|---|---|
| odd | 39 | **0** | 5 962 → 6 078 | +2.6·10⁻³ (slab 28) | 1.9·10⁻⁵ (slab 8) |
| even | 39 | **0** | 8 002 → 8 076 | +1.1·10⁻³ | 3.3·10⁻⁵ (slab 7) |

So every box still meets the same CG_i, the landing inputs are unchanged, and Theorem W2B3-U's numbers stand. But the ledgers
of record were produced by the unsound accumulator.

**Required.**
1. Apply the one-line fix.
2. Re-sweep both parities as the record, about 3 minutes each.
3. Re-run w2b3_bound on the new ledgers.
4. Archive with md5s.
5. Label the old ledgers superseded.

**Note.** The fix ate most of the 0.004 G slack (to 1.9·10⁻⁵). That is fine for a certificate, but it says the targets are
tight.

### The memo's §7.6 items

- **(i) The variance identity and tail bookkeeping (§2.2–2.3) ✓.**
  - D′/D = ⟨f⟩ and D″/D = ⟨f′ + f²⟩ follow from Φ″/Φ = f′ + f².
  - Since ⟨1⟩ = 1, the m-shift cancels exactly for any constant m.
  - Linearity gives tail(f′ + (f−m)²) = tail(Φ″/Φ(c)) − 2m·tail(Φ′/Φ(c)) + m²·tail(1).
  - The double by-parts is correct. I re-derived it: ∫Φ″φ = τ⁻²{τ[Φ′φ] + [Φgφ] + ∫Φ(g²−1)φ}, with φ′ = −gφ and φ″ = (g²−1)φ. So
    DT2's boundary term bd·(|g₀|/τ + |Φ′/Φ(w₀)|) is right.
  - Every piece of the G1 right Gaussian tail checks out: M + Z2 + numc² ≤ (MZ+1)e^{2y}, numc ≤ e^{y}, and the erfc closed form
    with B2 and C2. It uses Z2(u₀), so it is unaffected by F1.
  - The LX far-tail factor 5 holds. With X = gm·τ·σ ≥ 2 the bracket is ≤ 1 + 1.5 = 2.5, giving 2.5/σ = 5/rate. Region IIa's
    formula is exact.
  - E1/E2 → G ≤ ¼(E1 + E2²) ✓.
- **(ii) LX boundary-term monotonicity ✓.**
  - At U = u_s the Rademacher factor vanishes. q(u_s) carries exp(−(R − u_s)·gl_(v)).
  - The scan below gives h(v) = exp(−½·gl_(v))·P_up(ut, v) non-increasing on [2500, 2.5·10¹⁵], with step ratio ≤ 0.99846 for
    ut ∈ {0.75, 1.13, 1.25, 2, 3}:

    | R − u_s | h(2500) is the maximum |
    |---|---|
    | 0.5 | yes |
    | 0.75 | yes |
    | 1 | yes |

  - Beyond that range, v·P′/P ~ 1/log v → 0.
  - The asserted R − u_s ≥ ½ gives a factor of about 2 over the 0.256 needed.
  - The gpr_s/τ and Z terms only lower the relative growth.
  - The other factors of q are the inherited P5 A.9.2.
- **(iii) δ = ½ ✓.** Every Rademacher use is at σ ∈ [0.5, 1.5] ⊂ [−δ, 1 + δ]. In G1:
  - u ≥ 0.5 → σ = u;
  - u < 0.5 → σ = 1 − u, with the abs-convergent branch at ≥ 1.5.

  LX's log_q is the same. log ζ(1 + δ) is computed from u₀/u_s, and w2b3_sweep asserts 0 < δ ≤ ½.
- **(iv) The r₀/z term at the imaginary axis ✓.**
  - H-B's own proof of Thm 12 (p.17) gives real zeros **half-pair weight** in Σ′.
  - A zero of order r₀ at z = 0 is r₀/2 pairs at (d, v) = (x, 0). Lemma 10 allows v = 0.
  - S and ∂_pS contain the matching (r₀/2)·K_p(x, 0) = r₀p/(x² + p²) and its p-derivative.
  - Imaginary-axis zeros ±iv_j are ordinary pairs with d = x. If the top zero is at x = 0, its "reflection" is itself and Σ′
    just has fewer terms.
  - Lemma 10 is per-pair and linear with non-negative weights, so it does not interact with the Hermite splitting or Lemma 3.7.
- **(vi) Transcription ✓.**
  - Lemma 10 ((25)–(26), hypotheses 0 < A² < B, λ, μ ≥ 0, 0 < h² ≤ A², 0 ≤ v ≤ h, (d, v) ≠ (0, h)), Thm 12 and (33) match pp.
    14–17.
  - I re-derived K_p = 2pw/Δ, ∂_pK_p = [(2w + 4B)Δ − 8Bw²]/Δ², the bracket = N/Δ², and K_h/h ≥ 2/(D + A² + 3r) (from v₀ ≥ D ⟺ r
    ≤ h²).
  - The own-pair terms 2p/(B − q) and −2(B + q)/(B − q)², and "the bracket decreases in q", are verified.
  - A²_i ≥ q_i (rather than = q_i) is harmless.
- **(v) ∂_pS = ¼Re[(D′/D)′(c)] ✓.** (log pref)″ = 0 and dc/dz = −i/2. S(−x) = S(x) gives the reflection for G as for S.

### Independent recomputations

- **Φ_i ≥ 0.**
  - bb_phi.py is my own exact-rational implementation of (25), (34) and (35).
  - It reproduces **every** row's min_coeff **exactly** (asserted equal) for all 78 rows, and all are > 0 (min 1.34·10⁻⁴).
  - Self-tests: H-B Table 3 row 0 gives 7.1·10⁻³; (1, 0) at B = 49/4, A² = 1 gives exactly 0; (5/2, 0) gives −3. These match the
    memo.
- **The landing.**
  - bb_land.py is my own: mpmath, L_lo = log(m_lo/π), C_i = L_lo/4 + CF_i, (33), the barrier recursion, and t-edges from the
    ledgers' padded τ-ranges. Seams overlap: th[i] ≥ tl[i+1] is asserted, and t₀ ≤ 10⁻⁴.
  - **odd: T = 0.2806725, Λ ≤ 0.2807225** (margin 5.275·10⁻⁴); **even: T = 0.2808311, Λ ≤ 0.2808811** (margin 3.689·10⁻⁴). Both
    land in slab 38, and k₀/k₃₈ = 3.421/4.438 and 3.435/4.454.
  - These agree with w2b3_bound to 10⁻⁷. Theirs are the rounded-up 0.2807226 / 0.2808812.
- **Arithmetic in §0:**
  - 0.760 / 0.754 decades over Z3-U;
  - 0.982 / 0.992 over U2;
  - margins as stated.

### Certifier review: the four checks

| check | finding |
|---|---|
| ball domain | Z, Z2 at ≥ u₀ = 1.5; ψ′ at ≥ 0.75; logs of positives; P_up on a v-ball is monotone-safe ✓ |
| **bound direction** | **F1** (above). Every other new piece is an upper bound built from hi() and fhi(); M_G = min(M, ¼ψ′(…)) ✓ |
| tail integrability | DT2 (Riemann plus half-line with Q2 > 0), LX far tail (factor 5 under its checked condition), IIa exact; IIb ≈ e^{−1.5·10⁶} (see N2) ✓ |
| split consistency | the bulk/tail split is the same for G as for S; slab seams overlap (verified); G1/LX at x = 10⁴ = 4v₀; the band [m_lo, 10⁸] and then C2; q₀ = 1 − 2·10⁻⁴ ≤ A²₀; q_i ≤ A²_i < B per row (asserted in bb_land) ✓ |

### Nits (in-file only)

- **N1.** §5's "boxes certified 5 962 / 8 002" are the **evals**. The certified boxes are 4 868 / 5 888 (g1_cert + lx_cert).
- **N2.** IIb: cite where the slack e^{−s²/(16τ²)} comes from in eIIb's derivation (P5 A.9.1). T1 already relies on it for the
  linear multiplier.
- **N3.** w2b3_big2's module docstring, lines 6–7, describes the β² + eps2 form with 2Pb_K. The code uses the (sharper) variance
  form ¼(K3 + K²). Align the docstring.
- **N4.** The ledgers carry no certifier md5. Add it to the record-run ledgers (R-asrun).

## Status

- **Theorem W2B3-U** (odd m ≥ 1.65·10⁶: Λ_χ ≤ 0.2807226; even m ≥ 3.7·10⁶: Λ_χ ≤ 0.2808812; m ≥ 10⁸ by C2) is CONFIRMED as
  a statement. Its certificate of record must be re-issued under F1. Trust class T3 with T2 certificates. Lemma Z′ beyond
  4·10⁵ carries both labels, as in Z3-U.
- H-B 2610.12803 is an unrefereed working draft (T4). bb checked Lemma 10 and Thm 12 at source and re-derived them.

No RH-facing claim. AI review by bb, NOT an operator read-back.

## Add.1 (2026-11-03): the F1 delta. CONFIRMED, F1 RESOLVED

**Objects.** Memo **c5cd8f39** (erratum §0); w2b3_cert.py **f2e56a85**; w2b3_big2.py 4b780036; w2b3_sweep.py 9efa5464.

- **F1 ✓.** The fixed line of w2b3_cert.py is bb's fix verbatim (`dL = tau * absg * Z2_up(umin)`); only the comment differs. The
  pre-fix code is archived as superseded_w2b3/prefix_F1/w2b3_cert_adaf2ee3.py (md5 adaf2ee3 ✓).
- **Ledgers of record ✓.**
  - w2b3_cov2_*: 234 files; concatenated DONE md5s **696148f1 / 0be5d4cf** recomputed by bb.
  - 39/39 per parity, 0 failures, 6 078 / 8 076 evaluations.
  - **Field by field equal to bb's scratch re-run** (g1/lx_cert, evals, worst, maxG, CF, CG, t, τ, n_failed, complete): 0
    differences in 78 slabs.
  - Every ledger is stamped certifier_md5 = {cert f2e56a85, big2 4b780036, sweep 9efa5464, y3_big aa232458} (N4 ✓).
- **Landing ✓.**
  - w2b3_bound2_a1 / a0 are 87e26183 / 55c37c93, byte-identical to the pre-fix landings, as expected: CF/CG/τ are unchanged.
  - bb's bb_land re-run on the cov2 ledgers gives Λ ≤ 0.2807225 / 0.2808811, margins 5.275·10⁻⁴ / 3.689·10⁻⁴ ✓.
- **N1–N3 ✓.**
  - §5 now gives certified boxes, with the evaluations in parentheses.
  - The big2 changes are comment/docstring only (diffed). N2 cites Y3 §4.3 / P5 A.9.1 for the e^{−s₁²/(8τ²)} source, half of
    which absorbs the multiplier. N3's docstring now states the variance form the code uses.
  - The sweep change is the N4 stamping only (diffed).

**Theorem W2B3-U stands on the re-issued record:** odd m ≥ 1.65·10⁶, Λ_χ ≤ 0.2807226; even m ≥ 3.7·10⁶, Λ_χ ≤ 0.2808812. It is
T3 with T2 certificates. Release is the user's.

No RH-facing claim. AI review by bb, NOT an operator read-back.

## Add.2 (2026-11-03): erratum, bb's own error

In the F1 table above, the even-parity "largest rise in maxG_g1" **+1.1·10⁻³** is wrong. bb read it off an interim summary taken when
only 18 of the 39 even slabs had finished.

Over all 39 slabs, recomputed from the ledgers (pre-fix w2b3_cov_* against the record w2b3_cov2_*), the rise is:

| parity | largest rise | slab |
|---|---|---|
| odd | **2.60·10⁻³** | 28 (unchanged) |
| even | **3.07·10⁻³** | 33 |

The other figures stand: 0 failures, the evaluation counts, and the smallest CG − max G (1.9·10⁻⁵ / 3.3·10⁻⁵, computed on all 39 slabs).
The error is not load-bearing.

AI review by bb, NOT an operator read-back.
