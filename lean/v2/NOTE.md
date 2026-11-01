# lean/DQ1_P5.lean — what it states, what it proves, and what it does not

`DQ1_P5.lean` (md5 01a24ec68592020eb4c33192cfb91b9d, 346 lines) is a byte-for-byte copy of the programme's internal `dq1/LEAN/DQ1_P5.lean`, the
DQ-1 Lean builder's build of the Telperion statement layer of P5 memo §A.13.4 with bb's three REVIEW_P5_FINAL notes applied. It
was reviewed for faithfulness by bb in REVIEW_LEAN_DQ1 (e4e14877; bb did not run Lean). Build record (the builder's REPORT.md, P5 addendum):
Lean v4.35.0, Mathlib v4.35.0 (a private `import Mathlib` environment, not the OpenAI environment of version 1), exit 0, 0 errors, 18 s;
five `#print axioms` lines, all `[propext, Classical.choice, Quot.sound]`; no `sorry`, no `axiom`, no `native_decide`.

It is **not** in OpenAI's environment, is **not** linked to version 1's chain, and was checked by **one kernel in one build**: no
five-checker replay, no Comparator run, no tamper test. The lead builds it for the release.

## Definitions (namespace `C2`; verbatim from P5 memo §A.13.4)

| name | meaning |
|---|---|
| `parity χ` | a ∈ {0,1}: 0 if χ(−1) = 1, else 1 |
| `IsRealChar χ` | every value χ n (n : ZMod m) has imaginary part 0 |
| `xi χ s` | ξ_L(s) = (m/π)^{(s+a)/2} Γ((s+a)/2) L(s, χ), with Mathlib's `DirichletCharacter.LFunction` and `Complex.Gamma` (FGMPS §2.3) |
| `H χ t z` | FGMPS (4.1): ∫_ℝ ξ((1+iz)/2 + √t v) e^{−v²}/√π dv, a Bochner integral. Meaningful for t > 0 (Mathlib's Γ takes junk values at its poles, a null set) |
| `S χ x p t` | −Im (H_t′/H_t)(x + ip) via Mathlib's `deriv` |
| `Lc m` | log(m/π) (the paper's ℓ, the memos' L) |
| `L0` | log(10⁸/π) |
| `tmin L`, `bC2 L`, `kC2 L`, `TC2 L`, `C2bound m` | t_min = min(10⁻⁴, 4/L), b = min(10⁻⁴, L⁻²), k = (4/√5)(L/4 − 1) − 2, T = t_min + log((2 + k(1 − 2t_min))/(2 + kb))/k, C2bound = T(Lc m) + b(Lc m)/2: the bound of Theorem C2 |
| `InDomain L t` | L₀ ≤ L ∧ t_min(L) ≤ t ∧ t ≤ T(L): the C2 TL domain (memo A.9.0) |

## PROVED (kernel-checked in the builder's environment; standard axioms only)

1. **`C2bound_lt_9_32 (hm : 10 ^ 8 ≤ m) : C2bound m < 9 / 32`.** The arithmetic step of Theorem C2: the explicit bound is below
   9/32 for every m ≥ 10⁸. Pure real analysis, no Arb input and no Arb-certified hypothesis. Route (helpers `logratio_anti`,
   `TC2_le`, `sqrt5_bounds`, `kC2_ge`, `exp_le_taylor`, `L0_ge`): T ≤ 10⁻⁴ + f(k) with f(k) = log(1 + k/2)/k; f is antitone on
   (0, ∞); L ≥ L₀ ≥ 17.25 (from e < 2.7182818286 and π < 3.141593); so k ≥ 3.925 and b ≤ 1/17.25²; log(2.9625) ≤ 1.0862; total
   ≤ 10⁻⁴ + 1.0862/3.925 + 1/(2·17.25²) = 0.27852 < 0.28125. (Arb gives 0.27643 at 10⁸; the Lean route is cruder and sufficient.)
   This is the only statement of version 2 that is kernel-checked. It says: IF Theorem C2 holds, THEN its bound is < 9/32 for all
   m ≥ 10⁸. It does not prove Theorem C2.
2. **`STL_applies (L t) (hL : 40000 < L) (hD : InDomain L t) : t ≤ 2·(175/10000)² ∧ 2618/1000 ≤ (1 + √5)/2 + tL/4`.** Every
   domain point with L > 4·10⁴ satisfies the hypotheses of Lemma STL (τ ≤ 0.0175, R ≥ 2.618). Proved from T ≤ 10⁻⁴ + f(k) with
   k ≥ 17884 and from t ≥ t_min = 4/L.
3. **`H_conj`**: H_t(−conj z) = conj(H_t z), under the explicit hypothesis `hLconj : ∀ s, L(conj s, χ) = conj (L(s, χ))`.
4. **`S_neg`**: S χ (−x) p t = S χ x p t, under the same hypothesis.
5. **`TL_floor_C2_of_nonneg`**: if the floor Lc m/4 − 1 ≤ S χ x √5 t holds on the domain for x ≥ 0, it holds for all real x,
   under the same hypothesis. (bb's REVIEW_P5_FINAL note 3: the certificates cover x ≥ 0 and the reflection supplies x < 0.)

The reflection hypothesis `hLconj` is true for real χ (real Dirichlet coefficients and the identity theorem) but is not in Mathlib;
deriving it from `IsRealChar` is a clean follow-up (REVIEW_LEAN_DQ1 item 4).

## STATED ONLY, as `Prop`-valued `def`s (not proved; no `axiom`, no `sorry`; nothing in the file claims them)

| name | content | source class |
|---|---|---|
| `C2_large_conductor_statement` | ∀ m ≥ 10⁸, ∀ real primitive χ mod m, ∀ t ≥ C2bound m, ∀ z, H χ t z = 0 → z.im = 0. **This is Theorem C2 itself.** | AI-written assembly (P5 memo A.13.3) of FGMPS Thm 2.6, Planat Thm 2.1 / Prop 2.3, H-B Thm 9, P2′ and the TL floor |
| `TL_floor_C2_statement` | the floor Lc m/4 − 1 ≤ S χ x √5 t on the whole domain, all real x | Arb certificates G1 + LX + STL (certificates/) |
| `P2'_uniform_statement` | Lemma Z′: H χ t (x + iy) ≠ 0 for \|x\| ≥ 4e^{8max(4·10⁴, L) − L}, min(0.01, 1/L) ≤ \|y\| ≤ 1, t_min ≤ t ≤ 1/2 | FGMPS Thm 4.3 / Prop 4.18 (stated by FGMPS for m ≤ 4·10⁵; extended by P5's reading of the proof) + Arb constants (p2z_arb) |
| `LX_statement` | Lc m/4 − 77/100 ≤ S χ x √5 t for Lc m ≤ 40000, InDomain, \|x\| ≥ 10⁴ | Arb cover lx_cover_p5patched (worst −0.7689) + proved x-monotonicity |
| `STL_statement` | Lc m/4 − 18/100 ≤ S χ x √5 t for 40000 < Lc m, 0 < t ≤ 2·0.0175², 2.618 ≤ (1+√5)/2 + tL/4 (bb's added hypothesis `40000 < Lc m`) | analytic lemma A.9.3 with Arb constants |

## What to add to the release

- `lean/v2/DQ1_P5.lean` (this file), with its md5 in `lean/MD5SUMS.txt`.
- A build note: it imports all of Mathlib (`import Mathlib`) and was built at Lean v4.35.0 / Mathlib v4.35.0, outside the
  `materialize.sh` environment of version 1 (which is at v4.34.1 / Mathlib d13f23b). The lead decides whether to add a second
  lakefile stanza or to leave it as a standalone file with the toolchain named.
- Not included: the Y3 memo's §8 Lean statement layer for Theorems Y3 and U1 (`Y3.landing`, `boundY3_*`, `gamma_norm_lower`,
  `TL_floor_p20`, `Y3_all_conductors`, `Y3_uncond_half`, `Y3_uncond_below_9_32`). Those are `sorry` sketches that were never
  built, and the paper says so (§7 and Limitations). The two pure-real-analysis items there (`landing_antitone`, the four
  `boundY3_*_le` constants) are natural first targets if the lead wants them.
