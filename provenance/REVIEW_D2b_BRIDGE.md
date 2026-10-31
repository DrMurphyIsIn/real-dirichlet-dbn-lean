# bb review of (2) D2b: the Mellin bridge `DBN.Gen.bridge` (bundle bbm.tar.xz 2001b940)

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

## Inputs

- **The bundle.** bbm.tar.xz, md5 2001b940 (the resend); all 3 entries of its MD5SUMS check out:
  - GenMellin cb5c2820
  - GenMellin2 67e1af81
  - GenBridge 5691f87d
- **Build.** bb built them on bb's own D1/D2a build (gen/build), with Mathlib 0493595e and Lean v4.35.0-rc3. All rc 0, with no sorry.

## Verdict: PASS

**The statement** (BbD2bCheck.lean eff46318, out 5bfa52e3), as printed with pp.numericTypes. Given:
- χ : DirichletCharacter ℂ N with [NeZero N] and χ ≠ 1;
- real values χ n = c n, |c n| ≤ 1, c 0 = 0 and c 1 = 1;
- parity `χ.gammaFactor s = Γℝ(s + k)`;
- `heven`;

then for every z : ℂ,

`(thetaDecayKernel …).Hd 0 z = (1/8 : ℂ) · N^((1/2 + I·z/2 + k)/2) · DirichletCharacter.completedLFunction χ (1/2 + I·z/2)`.

- Axioms: the standard 3. The closure walk (56,097 constants) agrees with collectAxioms.
- The statement's constants are Mathlib's `completedLFunction`, `gammaFactor` and `Gammaℝ`, plus DBN.Gen's `Hd`, `PhiC` and
  `thetaDecayKernel`.

**Fidelity of the normalisation, checked against Mathlib and 2610.27343:**
- s = ½ + iz/2 is the same map as 2610.27343 (H^L₀(z) = ξ_L((1+iz)/2)) and as Polymath's.
- Mathlib's `completedLFunction χ s = gammaFactor χ s · LFunction χ s` omits the conductor power, which is why Mathlib's functional
  equation carries N^{s−½}. So ξ_L(s) = (N/π)^{(s+k)/2}Γ((s+k)/2)L(s,χ) = N^{(s+k)/2}·Γℝ(s+k)·L. That matches
  `div_pi_cpow_mul_Gamma`.
- The factor 1/8 is right. Φ_L = 4·PhiC (2610.27343 (1.3)), so ∫_ℝ PhiC·e^{izu} = ξ_L/4. For even Φ, Hd₀ is half the full-line
  integral (`Hd_zero_eq_half_fourier`, the only use of heven), so Hd₀ = ξ_L/8.
- `hgam` ties k to the parity of χ, and the formula needs no primitivity. On Re s > 1 it is the Mellin transform of θ_c for the
  Dirichlet series of χ mod N. Primitivity, and with it ε, enter only through heven.
- **The extension to all z is sound.** Both sides are entire: the left via `Hd_eq` + `differentiable_H`, the right via
  `differentiable_completedLFunction` (χ ≠ 1) and a cpow with base N ≠ 0. They agree on {Im z < −1} ∋ −2I, so the identity
  theorem applies.

**Numeric sanity check** (bb_d2b_numeric.py 6735bae3, out 8fda5547; mpmath, 30 digits). For χ₋₄ (N = 4, k = 1; classically
ε = +1), Hd₀(z) = ∫₀^∞ PhiC(u)cos(zu)du against (1/8)·4^{(s+1)/2}·Γℝ(s+1)·L(s, χ₋₄):

| z | LHS | RHS | \|diff\| |
|---|---|---|---|
| 0 | 0.122589201757214188 | 0.122589201757214188 | 5e-31 |
| 1 | 0.120217919764671738 | 0.120217919764671738 | 1e-32 |
| 0.5 + 0.25i | 0.122140362295467626 − 0.000595884686946844i | same | 5e-31 |

PhiC(±0.3) agree to about 1e-12, which is the series-truncation accuracy at small x. So evenness holds numerically for this χ, as
expected classically.

**Tamper** (BbD2bTamper.lean 825405c9, out b15daa47): replacing 1/8 by 1/4 is REJECTED, a type mismatch against `bridge`.

**Labels.**
- Still CONDITIONAL (Φ_χ even ⇔ ε(χ) = 1), via heven.
- D2b′ (heven ⇐ rootNumber χ = 1) is the next step that removes the condition; D2c (the strip) follows.
- No Λ_L claim yet.
