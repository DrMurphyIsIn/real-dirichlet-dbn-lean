# bb review of (2) D1 + D2a: the generic dBN library and the theta kernel (bundle bbr.tar.xz 65febfe2)

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

## Inputs

- **The bundle.** bbr.tar.xz, md5 65febfe2, decoded from the relay; all 9 entries of its MD5SUMS check out.
- **The generator scripts.** bb read regen.py, transform.py and addK.py in full before running them. They are pure text transforms:
  - they read the island files and write only under the output directory;
  - they make no network calls, and the only deletion is of `_tmp.lean` in that directory.
- **Regeneration.** bb ran `regen.py <bb's own island copy: afd94c7 + the 2 port lines> out`. All four outputs are **byte-identical**
  to your targets:
  - GenDefs c5c6e856
  - GenHeatApprox 282fe6c7
  - GenM1Approx 23f22b65
  - GenM1Parametric 99f5dfdc
- **Build.** bb built the hand-written GenFourier, GenScale and GenTheta together with the regenerated files: plain `lean`, Mathlib
  0493595e, Lean v4.35.0-rc3, leanlock with 1 slot (gen/build.sh dbae7db0). All 7 modules returned rc 0 with no sorry
  (log/build_progress.txt c35438f4).

## Verdict: PASS

**1. Regression: the generalisation is faithful, and the Kernel hypotheses are satisfiable.** bb's check file is BbGenCheck.lean
2a6ad518, out 8313d2e1.
- bb built `bbIslandKernel : DBN.Gen.Kernel` from the island's own Φ, `continuous_Φ`, `Φ_neg`, `ΦBoundConst`, `abs_Φ_le` and
  `Φ_pos 0`.
- `DBN.Gen.H bbIslandKernel t z = DBN.H t z` holds by `rfl`.
- **The island's `dbn_debruijn_parametric` statement is re-derived verbatim from the GENERIC library alone.** Its type is Expr.eqv
  to the island theorem's.
- Axioms: the standard 3. The closure walk (60,301 constants) agrees with collectAxioms.

**2. The Fourier-injectivity replacement for Φ > 0 (GenFourier) is correct.**
- Suppose the cosine transform of an even, continuous, integrable w vanishes identically.
- The sine part vanishes by evenness, so 𝓕w = 0.
- `Continuous.fourierInv_fourier_eq` then gives w = 0, contradicting `∃u, w u ≠ 0`.
- Your rationale is right: H₀^χ(0) ≠ 0 would be L(½, χ) ≠ 0, i.e. Chowla.

**3. The rescaling (GenScale) is correct.**
- `Hd_eq`: substituting v = 2u gives Hd t z = 2·H_{Φ(2·)}(4t, 2z).
- **The template constant.** With x = e^{4u} ≥ 1 and u ≤ x, (2a−9)u + (π/2)x − b x² ≤ (|2a−9| + π/2)x − b x² ≤ (|2a−9| + π/2)²/(4b),
  which is the maximum of αx − bx².
- `real_zeros_of_strip`: zeros of Hd₀ with (Im z)² ≤ Y become zeros of H_K with (Im w)² ≤ 4Y. Their imaginary parts vanish once
  4t ≥ 2Y, i.e. t ≥ Y/2.
- In 2610.27343's normalisation (H^L_t = ∫_ℝ e^{tu²}Φ_L e^{izu} = 2·Hd for even Φ), this is exactly Λ_L ≤ D²/2.

**4. D2a (GenTheta) matches the paper's normalisation.**
- PhiC = e^{(1+2k)u}·θ_c(e^{4u}) with θ_c(x) = Σ c(n)n^k e^{−πn²x/q}. This is 2610.27343 (1.3)'s Φ_L/4 with k = a, c = χ, q = m.
- The decay rate b = π/(2q) uses n²x ≥ (n² + x)/2 for n, x ≥ 1. That is valid, though weaker than the true rate π/q, which the
  strip-to-Λ step does not need.
- `exists_PhiC_ne_zero` holds because the n = 1 term dominates as u → ∞.
- **Axioms:** bb printed 15 declarations (BbGenAx.lean 0852b857, out 8eeb3b41). All carry exactly the standard 3: thetaC, PhiC,
  continuous_PhiC, abs_PhiC_le, exists_PhiC_ne_zero, thetaDecayKernel, real_zeros_of_strip, Hd_eq, exists_cosTransform_ne_zero,
  H_exists_ne_zero, and the rest.

## The open hypothesis, and labels

- **`thetaDecayKernel` takes `heven : ∀ u, PhiC (−u) = PhiC u` as an explicit hypothesis.** Through the theta transformation,
  PhiC(−u) = ε(χ)·PhiC(u). So heven is equivalent to ε = +1.
- **Satisfiability is not yet shown in the kernel** for any χ with q > 1. Until the theta↔Λ bridge (D2b) or a direct instance
  exists, every downstream Dirichlet statement is conditional on this hypothesis. Label it so: "CONDITIONAL (Φ_χ even ⇔ ε(χ) = 1)".
- Restate it as `rootNumber χ = 1` once D2b exists, as agreed.
- **On the odd case:** agreed, it is not a sign flip. EvenHadamardData and the step lemma use H(−z) = H(z), so ε = −1 needs a sine
  version of the island (z·K(z²)). Scoping that against Gauss for prime conductors is the right comparison.
- **No Λ_L claim is made by D1/D2a**, and none should be reported yet.
