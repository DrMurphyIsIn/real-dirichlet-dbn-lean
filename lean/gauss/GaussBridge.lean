import Mathlib
import GaussSign

/-! **Meaning link for general `χ`.**  For every real primitive `χ ≠ 1` mod `N`, the explicit heat
family `Hchi χ` at `t = 0` is the completed Dirichlet L-function:
`Hchi χ 0 z = (1/8) N^{(s+k)/2} Λ(s, χ)`, `s = 1/2 + iz/2`, `k = parityK χ`.
No hypothesis beyond `χ` real primitive nontrivial (evenness of `Φ_χ` from Gauss's sign theorem).
conjecture1_proved = False. -/

open Real Complex

namespace DBN.Gen

open scoped Classical in
theorem Hchi_bridge {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hprim : χ.IsPrimitive)
    (hχ1 : χ ≠ 1) (hreal : ∀ n : ℕ, (χ n).im = 0) (z : ℂ) :
    Hchi χ 0 z = (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + parityK χ) / 2) *
      DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) := by
  set c : ℕ → ℝ := fun n ↦ (χ n).re with hc_def
  have hχc : ∀ n : ℕ, χ n = (c n : ℂ) := fun n ↦ Complex.ext (by simp [c]) (by simp [c, hreal n])
  have hc : ∀ n, |c n| ≤ 1 := fun n ↦
    (Complex.abs_re_le_norm _).trans (DirichletCharacter.norm_le_one χ _)
  have hN1 : N ≠ 1 := fun h ↦ hχ1 (DirichletCharacter.level_one' χ h)
  have hc0 : c 0 = 0 := by simp [c, Nat.cast_zero, χ.map_zero' hN1]
  have hc1 : c 1 = 1 := by simp [c]
  have hk : parityK χ = if χ.Even then 0 else 1 := rfl
  have hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + parityK χ) := by
    intro s
    by_cases hev : χ.Even
    · rw [hk, if_pos hev, hev.gammaFactor_def]; simp
    · rw [hk, if_neg hev, (χ.even_or_odd.resolve_left hev).gammaFactor_def]; simp
  have heven := PhiC_even_of_rootNumber hprim hχc hc hc0
    (rootNumber_eq_one_of_real_primitive χ hprim hreal) hk
  exact bridge hχ1 hχc hc hc0 hc1 hgam heven z

end DBN.Gen
