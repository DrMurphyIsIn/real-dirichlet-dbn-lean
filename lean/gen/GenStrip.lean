import Mathlib
import GenBridge

/-! Generic dBN island, part 5 (D2c): **the zero strip and `Λ_L ≤ 9/32`.**

For a real primitive Dirichlet character `χ` mod `N` (`χ ≠ 1`, parity `k`) whose theta kernel
`Φ_χ` is even (CONDITIONAL: `Φ_χ` even ⇔ `ε(χ) = 1`), and the hypothesis `hL` that `L(s, χ) ≠ 0`
for `Re s > 7/8` (OpenAI's Dirichlet quasi-RH, taken as a HYPOTHESIS here):

* `zero_strip`: every zero of `H₀^χ` has `(Im z)² ≤ 9/16` (from the bridge, `Γ_ℝ ≠ 0`, and the
  functional equation with `χ⁻¹ = χ`);
* `dirichlet_real_zeros`: every zero of `H_t^χ` is real for `t ≥ 9/32` (de Bruijn, generic).

conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology Complex

namespace DBN.Gen

variable {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N} {c : ℕ → ℝ} {k : ℕ}

/-- A real-valued Dirichlet character is its own inverse. -/
theorem inv_eq_self_of_real (hχc : ∀ n : ℕ, χ n = (c n : ℂ)) : χ⁻¹ = χ := by
  ext a
  rw [MulChar.inv_apply_eq_inv']
  have hnorm : ‖χ a‖ = 1 := DirichletCharacter.unit_norm_eq_one χ a
  have hreal : χ (a : ZMod N) = (c (a : ZMod N).val : ℂ) := by rw [← hχc, ZMod.natCast_zmod_val]
  rw [hreal] at hnorm ⊢
  rw [Complex.norm_real, Real.norm_eq_abs] at hnorm
  rcases (abs_eq zero_le_one).mp hnorm with h | h <;> rw [h] <;> norm_num

/-- `Λ(s, χ) ≠ 0` for `Re s > 7/8`, from `L ≠ 0` there and `Γ_ℝ ≠ 0`. -/
theorem completed_ne_zero (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0) {s : ℂ}
    (hs : (7 / 8 : ℝ) < s.re) : DirichletCharacter.completedLFunction χ s ≠ 0 := by
  have hs0 : s ≠ 0 := by intro h; rw [h] at hs; simp at hs; linarith
  have hg : χ.gammaFactor s ≠ 0 := by
    rw [hgam]; exact Gammaℝ_ne_zero_of_re_pos (by simp; positivity)
  have h := DirichletCharacter.LFunction_eq_completed_div_gammaFactor χ s (Or.inl hs0)
  intro hΛ
  rw [hΛ, zero_div] at h
  exact hL s hs h

/-- **The zero strip of `H₀^χ`.** -/
theorem zero_strip (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1)
    (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (heven : ∀ u, PhiC c k N (-u) = PhiC c k N u)
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0) (z : ℂ)
    (hz : (thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd 0 z = 0) :
    z.im ^ 2 ≤ 9 / 16 := by
  set s : ℂ := 1 / 2 + I * z / 2 with hs_def
  have hsre : s.re = 1 / 2 - z.im / 2 := by simp [hs_def]; ring
  have hΛ : DirichletCharacter.completedLFunction χ s = 0 := by
    rw [bridge hχ1 hχc hc hc0 hc1 hgam heven z] at hz
    have hN : (N : ℂ) ^ ((1 / 2 + I * z / 2 + k) / 2) ≠ 0 :=
      cpow_ne_zero_iff.mpr (Or.inl (by exact_mod_cast (NeZero.ne N)))
    rcases mul_eq_zero.mp hz with h | h
    · rcases mul_eq_zero.mp h with h' | h'
      · norm_num at h'
      · exact absurd h' hN
    · exact h
  have h1 : s.re ≤ 7 / 8 := by
    by_contra h; push Not at h
    exact completed_ne_zero hgam hL h hΛ
  have h2 : 1 / 8 ≤ s.re := by
    by_contra h; push Not at h
    have hre : (7 / 8 : ℝ) < (1 - s).re := by simp; linarith
    apply completed_ne_zero hgam hL hre
    rw [DirichletCharacter.IsPrimitive.completedLFunction_one_sub hprim s,
      inv_eq_self_of_real hχc, hΛ, mul_zero]
  rw [hsre] at h1 h2
  nlinarith

/-- **`Λ_L ≤ 9/32` (heat-flow form).**  Under the hypotheses of `zero_strip`, every zero of
`H_t^χ` is real for `t ≥ 9/32`. -/
theorem dirichlet_real_zeros (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1)
    (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (heven : ∀ u, PhiC c k N (-u) = PhiC c k N u)
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0) :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ,
      (thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd t z = 0 →
        z.im = 0 := by
  intro t ht
  exact DecayKernel.real_zeros_of_strip _ (by norm_num)
    (zero_strip hprim hχ1 hχc hc hc0 hc1 hgam heven hL) t (by linarith)

end DBN.Gen
