# REVIEW_LEAN_DQ1: bb's faithfulness review of the DQ-1 Lean statement-layer build (~/rh-team/dq1/LEAN/)

2026-10-31. **AI review by bb, NOT an operator read-back.** **No Lean or lake was run by bb**; the kernel results are the builder's and
the lead's rebuild. I read the .lean files, the memos and the pinned Mathlib source, read-only. No team file other than this one was
written.

**Object.**
- REPORT.md **ff28f1184367a1b170f5c9a94be4a449**. Against f5b3292b, the only change is the verbatim P5 addendum (I checked the diff).
- The 13 files with REPORT §1's md5s, which I re-hashed: DQ1_S1 53c7acbd, S2 5e2407ee, S3 c3d54500, S4 9c63775a, P1 7251e42e,
  P2 20ed14dc, P3 5a5099a8, P4 ac822439, P5 01a24ec6, X1 30c18982, X2 65787521, X3 4d4ee699, X4 50700f42.
- Pinned Mathlib: ~/telperion-tools/lean-env (v4.35.0).

## Verdict: the build is faithful; the FALSE finding is CONFIRMED and is the only instance of its kind

| # | Item | Verdict |
|---|---|---|
| 1 | **X1 `high_band_operator` FALSE (new)** | **CONFIRMED.** Details below the table |
| 2 | **Instantiated definitions** | **All match the memos.** Details below the table |
| 3 | **S1's two RECONSTRUCTED emissions** | **Faithful to the memo's descriptions.** `LagariasShiftFactor.lagariasshiftfactor` (0 ≤ 4pq for p, q ≥ 0) matches memo :519–521 and :1133. `JensenDeg2Turan.jensendeg2turan` (0 ≤ d + b² + 2bcx + c²x² on the orthant) matches :833–834 and :1134. Both are positivity cores with no content, correctly labelled RECONSTRUCTED |
| 4 | **P5 file** | **Faithful.** Details below the table |
| 5 | **Unused hypotheses (§3)** | **Confirmed: none makes a goal trivial.** Details below the table |
| 6 | **Memo versions read by the builder** | The builder read S1 117d576a, X2 194b3384, X3 c75f2257 and P5 92cb55ec, which are newer than my reviewed 5549d56a, 7afb0d9e, 553d7109 and 1994d136. **The fenced Lean blocks are byte-identical between each pair** (diffed). Only prose changed |

**Item 1: X1 `high_band_operator`.**
- In the pinned Mathlib, MeasureTheory/Integral/Bochner/Basic.lean:171 reads `notation3 "∫ "(...)", "r:60:…`. The body is parsed at
  :60, so a binary `-` or `+` (:65) is absorbed into it.
- So memo :650 `(1 / (2 * Real.pi)) * ∫ t, ‖gh t‖ ^ 2 * Ω t - primeForm` is (1/2π)·∫(‖ĝ‖²Ω − primeForm).
- With primeForm = −1 that integrand is not integrable, so the right side is 0 (`integral_undef`). The witness (ĝ = 1_[0,1], Ω ≡ 1,
  μ = 0) satisfies every hypothesis, including hP: −1 ≤ 0, and the left side is 1/2π > 0. The witness is sound.
- `high_band_operator_parenthesized` (:251) is X1's intended statement. It is the memo's own prose (:641–642).
- **Is the same bug anywhere else?** I listed every `∫` in all 13 memos' fenced Lean blocks and in all 13 delivered files.
  - Every other integral body is delimited by `=`, `≤`, `:=`, `)` or `‖`: P2 :585, :984, :988, :1005; P4 :647; X1 :624–625, :638;
    X2 :1331; S2 TS12 :1225–1226 (inside `fun`); P5 :1453.
  - `∑` (`term:67`, BigOperators/Group/Finset/Defs.lean:180) and `∑'` (`r:67`, InfiniteSum/Defs.lean:161) are immune.
  - `⨆` and `⨅` (:60) do not occur.
  - **So high_band_operator is the only instance.**
- **Action:** X1's memo should replace :650 with the parenthesised form. It is a statement-layer typo, and none of X1's certificates
  depends on it.

**Item 2: instantiated definitions.**
- χ₅ = `(quadraticChar (ZMod 5)).ringHomComp (Int.castRingHom ℂ)`. This is S2's "χ₅ = Legendre mod 5" (memo :1191), the real even
  character with Gauss sum √5, which the TS3 proof computes.
- S2 `ψ x = ∑' n:ℕ+, exp(−πn²x)` matches memo :646 and :1193. Λ25 (:110) matches memo :639–641.
- P3:
  - `smooth23` is the 3-smooth n with 1 ≤ n ≤ N;
  - `q p = ⌊64 log p⌋₊`;
  - `qdot` = q₂v₂ + q₃v₃;
  - `cmax` = sup over S of qdot;
  - `D p` = sup over S of v_p.
  These match memo :699–700 (S = 3-smooth ≤ 10⁴, K = 64, q_p = ⌊K log p⌋, D_p = max v_p).
- `Astar A ℓ = Σ_{m∈supp} monomial (ℓ − m) (conj (coeff m))` matches memo :691, i.e. A*(z) = z^ℓ Ā(1/z) (:119).
- `riemannChi = 2^s π^{s−1} sin(πs/2) Γ(1 − s)` is the standard FE factor. The memo does not define it, so this is the builder's
  choice. It is consistent with the memo's π/4 claim: χ(½ + it) = e^{−2iθ(t)}, so arg(χ·M^{2πMi}) → π/4 at t = 2πM.
- P1 `piq q d = (1/d)Σ_{k∣d} μ(d/k)q^k` (over ℚ) matches memo :1466.

**Item 4: the P5 file.**
- `tmin`, `bC2`, `kC2`, `TC2`, `C2bound`, `Lc`, `L0` and `InDomain` are **symbol for symbol §A.13.1**:
  - t_min = min(10⁻⁴, 4/L), b = min(10⁻⁴, L⁻²), k = (4/√5)(L/4 − 1) − 2;
  - T = t_min + log((2 + k(1 − 2t_min))/(2 + kb))/k;
  - C2bound = T + b/2.
- `H` is FGMPS (4.1), read at source in REVIEW_P5_A12: ∫ξ((1+iz)/2 + √t v)e^{−v²}/√π.
- `xi` is (m/π)^{(s+a)/2}Γ((s+a)/2)L(s, χ), with parity a from χ(−1).
- **`C2bound_lt_9_32 (hm : 10^8 ≤ m) : C2bound m < 9/32` is exactly the memo's "< 9/32 for every m ≥ 10⁸".** I checked the analytic
  route arithmetically (it is a valid alternative to the Arb monotonicity):
  - k(L₀) = 3.937 ≥ 3.925;
  - log(1 + 3.925/2)/3.925 = 0.27669;
  - plus 10⁻⁴, plus b/2 ≤ 0.00168;
  - total ≤ 0.2785 < 0.28125.
- **The reflection hypothesis** hLconj: ∀ s, L(s̄, χ) = conj L(s, χ) is true for real χ (real Dirichlet coefficients, then the identity
  theorem). It is stated explicitly and enters only the new H_conj, S_neg and TL_floor_C2_of_nonneg. **Deriving it from IsRealChar is
  a clean follow-up.**
- The `Prop` records match §A.13.4 and A.12.2: C2_large_conductor, TL_floor_C2, P2′_uniform, and LX at −77/100.
  - **`STL` carries my hL : 40000 < Lc m, but the memo's §A.13.4 block (unchanged in 92cb55ec) still lacks it.** Update the memo so the
    statement of record matches the file.
- The junk-value audit (Bochner integrability, Gamma poles on a null set when Re z = 0, t > 0 throughout) is right.
  C2_large_conductor_statement is a strong statement, not a vacuous one: a non-integrable H would make it *false*, not trivial.

**Item 5: unused hypotheses.**
- hreal (T1), h1 (T6), hdet (TS10), ha (TS11, via the x = 0 junk factor 1), hk (L5, k = 0 still true), hb (implied by x² < ab with
  a > 0), hq (q = 0 makes hcop false), hα (α = 0 still true), hℓ (X4) and twoBlock_lower's five: in each case the theorem is stronger
  than stated, and the goal is non-trivial.
- Two goals are **trivial by design**, independent of the unused hypothesis:
  - S2 TS1 `0 ≤ 2 * x ^ 2` (a positivity core);
  - P1 T7 `flip_exponent` (a ring identity).

## For the DQ-1 synthesis

- **Count the 116 PROVED in two classes.** About 23 are content-free positivity cores or identities:
  - P4 ×10, X4 ×7, X3 emitted ×1, S1 reconstructed ×2, P2 emitted ×1, S2 TS1, P1 T7.
  - Some numeric facts (E1_weight4, g0tail) are closed constants by intention.
  
  The rest are substantive: TS3 with χ₅ primitive, TS4, TS8, L4, L9, L10, P1 T3, T8, C2bound_lt_9_32, H_conj and S_neg, among others.
- **X1's FALSE is a notation typo.** P1 T6 and T9 were already flagged (by bb) as false as written, and their corrected forms are proved.
- **Nothing in the build is a sorry or an axiom.** The cited and Arb items are recorded as `Prop`s, which is the honest encoding.

conjecture1_proved = False. AI review by bb, NOT an operator read-back.
