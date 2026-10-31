# bb review of (2) D2b′ + χ₋₄: theta FE ⇒ heven, and the non-vacuity instance (bundle bbd2bp.tar.xz 37c912ce)

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

**Inputs.**
- bbd2bp.tar.xz, md5 37c912ce: GenThetaFE.lean 8aeec9b0 (16,350 B) and GenChi4.lean 9acc262c (4,377 B), both md5s checking out.
- bb built them on its own D1–D2c build (Mathlib 0493595e, Lean v4.35.0-rc3). Both returned rc 0 with no sorry.

## Verdict: PASS

**Axioms.** Every headline theorem carries exactly the standard 3 (BbD2bpCheck.lean 6e928e9f, out of the fixed run):
- `theta_fe`
- `PhiC_even_of_rootNumber`
- `dirichlet_real_zeros_of_rootNumber`
- `rootNumber_chiM4`
- `chiM4_isPrimitive`
- `chiM4_real_zeros`

**1. D2b′ discharges heven from `rootNumber χ = 1`.**
- `theta_fe` gives θ(1/x) = x^{(1+2k)/2}θ(x), for k = 0 or 1 by parity, on these hypotheses:
  - hprim;
  - real values;
  - rootNumber χ = 1, Mathlib's literal definition gaussSum/I^a/N^{1/2}, as agreed in NOTE_D2_GAUSS_SIGN.
- It is built from Mathlib's even/odd Hurwitz kernel functional equations plus the primitive Gauss-sum shift
  (`IsPrimitive.fourierTransform_eq_inv_mul_gaussSum`) with χ⁻¹ = χ.
- `PhiC_even_of_rootNumber` follows immediately: e^{(1+2k)(−u)}θ(e^{−4u}) = e^{(1+2k)u}θ(e^{4u}).
- These match the classical theta transformation formula for real primitive χ.

**2. The headline statement is faithful and free of proof terms.** `dirichlet_real_zeros_of_rootNumber` concludes:
for primitive, nontrivial, real-valued χ with rootNumber χ = 1, hL implies that for every t ≥ 9/32, every zero of `Hchi χ t` is
real.
- `Hchi χ t z := ∫_{Ioi 0} e^{tu²}·PhiC(re∘χ)(parityK χ)N(u)·cos(zu)` depends on χ alone.
- c, hc, hc0, hc1 and hgam are derived internally, so the statement has no proof-term or side-data parameters. That is an
  improvement over D2c's form.

**3. Hchi really is the heat flow of Λ(·, χ), with no conditions at χ₋₄.** bb proved
`BbD2bp.chiM4_bridge : Hchi chiM4 0 z = (1/8)·4^{(s+1)/2}·completedLFunction chiM4 s` for s = ½ + iz/2.
- The proof combines D2b's `bridge` with heven discharged by `PhiC_even_of_rootNumber` and `rootNumber_chiM4`. It uses the
  standard 3 axioms.
- So, at χ₋₄, the object in the conclusion is provably H_t of the completed L-function in 2610.27343's normalisation (×8),
  not just a theta integral.
- bb's first version of this lemma had two tactic-syntax slips of bb's own. Its output is kept as BbD2bpCheck_run1.out
  (8994119b); it was fixed and rerun clean.

**4. χ₋₄ non-vacuity (GenChi4): every hypothesis except hL is discharged.**
- `chiM4 := ZMod.χ₄.ringHomComp (Int.castRingHom ℂ)` is the character mod 4 with χ(3) = −1, i.e. χ₋₄.
- Proved: primitivity (no factoring through level 1 or 2), χ ≠ 1, real values, odd parity, τ(χ₋₄) = 2i, and
  rootNumber = 2i/i/2 = 1.
- **bb's composition.** `BbD2bp.chiM4_real_zeros_of_oai` takes OpenAI's verbatim Dirichlet 7/8 statement as its ONLY hypothesis
  and gives every zero of H_t^{χ₋₄} real for t ≥ 9/32. Axioms: the standard 3; the closure walk (62,739 constants) agrees.

**Controls** (BbD2bpTamper.lean ef39dcf6, out 92ff7c0b): rootNumber χ₋₄ = −1 and τ(χ₋₄) = −2i are both REJECTED. Both statements
are false, so these are genuine rejects. Your theta_fe exponent-½ control (false for odd χ) is also genuine.

## Labels

Your proposed label is adopted with two refinements:
- **"Λ_χ ≤ 9/32 for every real primitive χ ≠ 1 with ε(χ) = 1, CONDITIONAL on the Dirichlet 7/8 half-plane (hypothesis form on
  these pins)."**
- **"At χ₋₄ the only hypothesis is hL, equivalently OpenAI's verbatim Dirichlet statement."**
- **The OpenAI pin seam (D2c review) still applies.** OpenAI's theorem was proved on Mathlib d13f23b. Until the
  `DirichletCharacter.LFunction` closure seam is checked, or the proof is ported, do not call the χ₋₄ case unconditional.
- **The Gauss sign.** ε(χ) = 1 for every real primitive χ is classical (Gauss) but not in Mathlib, so hε stays explicit for the
  general statement.
