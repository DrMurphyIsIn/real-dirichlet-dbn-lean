import Mathlib

/-! Generic dBN island, auxiliary: **cosine-transform injectivity.**  An even, continuous,
integrable, not identically zero `w : ℝ → ℝ` has a cosine transform `x ↦ ∫_0^∞ w(u) cos(xu) du`
that is not identically zero on `ℝ` (Fourier inversion, Mathlib `Continuous.fourierInv_fourier_eq`).
This replaces the island's use of `Φ > 0` (which fails for Dirichlet kernels and would otherwise be
replaced by `L(1/2, χ) ≠ 0`, i.e. Chowla).  conjecture1_proved = False. -/

open Real MeasureTheory Set Filter FourierTransform

namespace DBN.Gen

theorem exists_cosTransform_ne_zero {w : ℝ → ℝ} (hc : Continuous w) (heven : ∀ u, w (-u) = w u)
    (hi : Integrable w) (hne : ∃ u, w u ≠ 0) :
    ∃ x : ℝ, ∫ u in Ioi (0 : ℝ), w u * Real.cos (x * u) ≠ 0 := by
  by_contra hall
  push Not at hall
  set f : ℝ → ℂ := fun u ↦ (w u : ℂ) with hf
  have hfc : Continuous f := Complex.continuous_ofReal.comp hc
  have hfi : Integrable f := hi.ofReal
  -- the even and odd parts of the Fourier integrand integrate to zero
  have hcos : ∀ c : ℝ, ∫ v : ℝ, w v * Real.cos (c * v) = 0 := by
    intro c
    have hg : ∀ x : ℝ, w |x| * Real.cos (c * |x|) = w x * Real.cos (c * x) := by
      intro x
      rcases le_or_gt 0 x with hx | hx
      · rw [abs_of_nonneg hx]
      · rw [abs_of_neg hx, heven, mul_neg, Real.cos_neg]
    have h := integral_comp_abs (f := fun y ↦ w y * Real.cos (c * y))
    simp only [hg] at h
    rw [h, hall c, mul_zero]
  have hsin : ∀ c : ℝ, ∫ v : ℝ, w v * Real.sin (c * v) = 0 := by
    intro c
    have h := integral_neg_eq_self (fun v : ℝ ↦ w v * Real.sin (c * v)) volume
    simp only [heven, mul_neg, Real.sin_neg, integral_neg] at h
    linarith
  have hF : 𝓕 f = 0 := by
    funext ξ
    rw [Real.fourier_real_eq_integral_exp_smul]
    have e : ∀ v : ℝ, Complex.exp (↑(-2 * π * v * ξ) * Complex.I) • f v =
        ((w v * Real.cos ((-2 * π * ξ) * v) : ℝ) : ℂ) +
          ((w v * Real.sin ((-2 * π * ξ) * v) : ℝ) : ℂ) * Complex.I := by
      intro v
      rw [Complex.exp_mul_I, smul_eq_mul, hf]
      push_cast
      ring_nf
    simp_rw [e]
    have hb1 : Integrable fun v : ℝ ↦ ((w v * Real.cos ((-2 * π * ξ) * v) : ℝ) : ℂ) := by
      refine (hi.mul_bdd (c := 1) ?_ ?_).ofReal
      · exact (Real.continuous_cos.comp (continuous_const.mul continuous_id)).aestronglyMeasurable
      · exact Eventually.of_forall fun v ↦ by simpa using Real.abs_cos_le_one _
    have hb2 : Integrable fun v : ℝ ↦ ((w v * Real.sin ((-2 * π * ξ) * v) : ℝ) : ℂ) * Complex.I := by
      refine ((hi.mul_bdd (c := 1) ?_ ?_).ofReal).mul_const _
      · exact (Real.continuous_sin.comp (continuous_const.mul continuous_id)).aestronglyMeasurable
      · exact Eventually.of_forall fun v ↦ by simpa using Real.abs_sin_le_one _
    rw [integral_add hb1 hb2, integral_mul_const, integral_complex_ofReal, integral_complex_ofReal,
      hcos, hsin]
    simp
  have hinv := Continuous.fourierInv_fourier_eq hfc hfi (by rw [hF]; exact integrable_zero _ _ _)
  obtain ⟨u, hu⟩ := hne
  have := congrFun hinv u
  rw [hF, fourierInv_eq] at this
  simp [hf] at this
  exact hu (by exact_mod_cast this.symm)

end DBN.Gen
