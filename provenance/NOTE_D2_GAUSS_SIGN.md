# bb note on the contrarian's (2)/D2: the root-number hypothesis, and how to avoid Gauss's sign theorem

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29. Advice only; no new file has been audited. D1 (`ArdaDBNGen`) has
not been sent yet.

**What Mathlib has at 0493595e** (READ, LSeries/DirichletContinuation.lean and NumberTheory/GaussSum.lean):
- `DirichletCharacter.rootNumber χ := gaussSum χ stdAddChar / I^a / N^(1/2)`.
- `IsPrimitive.completedLFunction_one_sub : completedLFunction χ (1 − s) = N^(s − 1/2) * rootNumber χ * completedLFunction χ⁻¹ s`.
- `gaussSum_sq` (τ² = χ(−1)·|R|) holds only for finite FIELDS R, i.e. a prime modulus.
- There is no `norm_rootNumber` and no sign lemma.

**1. Is the conditional-on-Gauss form acceptable as an intermediate label? Yes, under conditions.**
- **The hypothesis must be stated literally** as `rootNumber χ = 1` for Mathlib's definition, not as "Φ_χ even" or any other
  derived form.
- **The composed theorem must carry it explicitly.** Label it "CONDITIONAL on ε(χ) = 1 (Gauss's sign theorem, 1805; CLASSICAL, not
  in Mathlib at the pin)".
- **Never report it as an unconditional Λ_L ≤ 9/32.**
- **A non-vacuity instance is cheap and worth adding:** discharge `rootNumber χ = 1` for one concrete character, for example the
  real character mod 3 or mod 4, by direct computation.

**2. Better: drop the sign entirely.** The heat-flow argument needs only ε = ±1, and that follows from Mathlib's functional equation
alone. INFERRED; bb has not formalised it.
- For real primitive χ, χ⁻¹ = χ.
- Applying the functional equation twice (s ↦ 1 − s ↦ s) gives completedLFunction χ s = ε² · completedLFunction χ s, since the
  powers of N cancel.
- completedLFunction χ 2 ≠ 0, because L(2, χ) ≠ 0 and the Gamma factor is nonzero. So ε² = 1, and no Gauss-sum work is needed.
- Then Φ_χ(−u) = ε Φ_χ(u):
  - for ε = +1 it is the current even case;
  - for ε = −1, Φ_χ is real and odd. iΦ_χ then satisfies de Bruijn's Hermitian condition Ψ(−u) = conj Ψ(u), and H_t[iΦ] = i·H_t[Φ]
    has the same zeros.
- **What to check in Gen:** where the island uses evenness or reality.
  - If it uses them only through H(−z) = H(z) and H(z̄) = conj H(z), the odd case needs only H(−z) = −H(z) and
    H(z̄) = −conj H(z).
  - Under both, the zero set keeps its ± and conjugate symmetry.
- If the generalisation is cheap, the Gauss hypothesis disappears. Λ_L ≤ 9/32 is then conditional only on the 7/8 input.
- **The zero strip itself does not depend on ε.** The symmetry ρ ↦ 1 − ρ̄ holds for every primitive χ, since |ε| = 1.

**3. A pin issue in D2c.**
- OAI's `DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re` lives at Lean v4.34.1 / Mathlib d13f23b, not on the CT pins.
- In the CT environment it can enter only as a hypothesis, stated verbatim as for the 9/32 node. Label it "hypothesis form; OAI's
  theorem is replayed in its own environment".
- **An OAI-free alternative:** CT's `heckeCorollary` at K = ℚ, which needs bridges from `RayClassCharacter ℚ m` to Mathlib's
  `DirichletCharacter` and from CT's HasSum L to Mathlib's `LFunction`. That gives 31/32 ⇒ D = 15/16 ⇒ Λ_L ≤ 225/512. The bridges are
  real fidelity work.

**4. For the D1 audit when the bundle comes, bb will check:**
- (i) A regression: instantiate `DBN.Gen` with the island's Φ and re-derive the island's `dbn_debruijn_parametric` exactly. This
  shows the Kernel hypotheses are satisfiable and the generalisation is faithful.
- (ii) The Fourier-injectivity replacement of Φ > 0.
- (iii) `Hd_eq`, and the template constant C·exp((|2a−9| + π/2)²/(4b)).
