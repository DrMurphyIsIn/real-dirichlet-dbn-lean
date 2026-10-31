# bb review of (2) D2c: the zero strip and Λ_L ≤ 9/32 in hypothesis form (GenStrip.lean 8aa81558)

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

**Inputs.** GenStrip.lean, md5 8aa81558 (4346 bytes), decoded from the relay. bb built it on its own D1/D2a/D2b build (Mathlib
0493595e, Lean v4.35.0-rc3), with rc 0 and no sorry.

## Verdict: PASS (hypothesis form, CONDITIONAL on heven)

**Statements**, from BbD2cCheck.lean 3a297289, out a2700ab0:
- `zero_strip`: hprim, χ ≠ 1, real values, hgam, heven and hL give, for every zero z of Hd₀, (Im z)² ≤ 9/16.
- `dirichlet_real_zeros`: under the same hypotheses, for every t ≥ 9/32, every zero of Hd_t is real.
- Axioms: the standard 3 for `inv_eq_self_of_real`, `completed_ne_zero`, `zero_strip`, `dirichlet_real_zeros` and bb's
  `dirichlet_real_zeros_of_oai`. The closure walk (62,598 constants) agrees with collectAxioms.

**The strip argument is correct.**
- The bridge, with N^(…) ≠ 0, gives Λ(s,χ) = 0 at s = ½ + iz/2, so Re s = ½ − Im z/2.
- hL together with Γℝ ≠ 0 on Re > 0 excludes Re s > 7/8.
- `IsPrimitive.completedLFunction_one_sub` with χ⁻¹ = χ makes 1 − s a zero too, which excludes Re s < 1/8.
- So |Im z| ≤ 3/4.
- Primitivity is genuinely used, and only here.
- `inv_eq_self_of_real` is right: |χ(a)| = 1 on units with real values forces χ(a) = ±1, so the inverse equals the character.

**hL against OpenAI's verbatim statement.** OpenAI's theorem, copied verbatim with binders closed from ~/oai-math @adc7f124
ComparatorChallenges/DirichletSevenEighths.lean (md5 4870cf09), is
`∀ {q} [NeZero q] (χ : DirichletCharacter ℂ q) {s}, (7/8 : ℝ) < s.re → ¬(χ = 1 ∧ s = 1) → LFunction χ s ≠ 0`.
- bb proved `hL_of_oai : OAI → χ ≠ 1 → hL`, so your generic hL is implied for every χ ≠ 1.
- bb also proved `dirichlet_real_zeros_of_oai`, the D2c conclusion with OpenAI's verbatim statement as the only L-function
  hypothesis.
- **Pin caveat:** OpenAI proved its theorem on Lean v4.34.1 / Mathlib d13f23b, not on 0493595e.
  - Discharging hL by OpenAI's theorem needs `DirichletCharacter.LFunction`, and its closure, to agree across those two Mathlib
    pins.
  - That is the same kind of seam as the 267-definition `riemannZeta` closure difference between de5ce8a9 and d13f23b found on
    10-07.
  - Until that seam is checked, or OpenAI's proof is ported, D2c stays in hypothesis form on these pins.

**The normalisation matches 2610.27343.**
- Their H^L_t(z) = ∫_ℝ e^{tu²}Φ_L(u)e^{izu}du. Ours is Hd_t(z) = ∫₀^∞ e^{tu²}PhiC(u)cos(zu)du, with the same heat parameter t in
  e^{tu²}.
- With Φ_L = 4·PhiC and evenness, H^L_t = 8·Hd_t for every t. So the zero sets agree for every t, and their Λ_L convention is ours.
- The strip D = 3/4 gives Λ_L ≤ D²/2 = 9/32, matching their Remark 3.4 (Theorem 2.6 with y₀ = D at t₀ = 0).

**Control** (BbD2cTamper.lean 911b2350, out 7a1d37b6): heat time 1/4 with the same proof is REJECTED (linarith). As you say, this
is a proof-reach control, not a falsity test.

**Labels and next steps.**
- CONDITIONAL (Φ_χ even ⇔ ε = 1), plus hL in hypothesis form.
- Still to do: D2b′ (heven ⇐ rootNumber χ = 1) and the χ₋₄ (or χ₋₃) non-vacuity discharge.
- Only after D2b′ may this be called "Λ_L ≤ 9/32 for every real primitive χ, conditional on the Dirichlet 7/8 half-plane".
- Unconditional on these pins only after the OpenAI pin seam is resolved. Alternatively, CT's heckeCorollary would give an
  OpenAI-free 225/512.
