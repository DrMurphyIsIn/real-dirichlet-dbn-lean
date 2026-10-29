import Mathlib
import GenThetaFE

/-! Generic dBN island, part 7: **non-vacuity check at `χ₋₄`.**

For the character `χ₋₄` mod 4 (`χ₄` with values in `ℂ`), every hypothesis of
`dirichlet_real_zeros_of_rootNumber` except the zero-free half-plane `hL` is PROVED here:
primitive, nontrivial, real-valued, root number `1` (the Gauss sum is computed: `τ(χ₋₄) = 2i`).
`hL` for `L(s, χ₋₄)` on `Re s > 7/8` stays a HYPOTHESIS.  conjecture1_proved = False. -/

open Real Complex DBN.Gen

namespace DBN.Gen

/-- `χ₋₄` as a complex Dirichlet character mod 4. -/
noncomputable def chiM4 : DirichletCharacter ℂ 4 := ZMod.χ₄.ringHomComp (Int.castRingHom ℂ)

theorem chiM4_apply (a : ZMod 4) : chiM4 a = (ZMod.χ₄ a : ℂ) := rfl

theorem chiM4_three : chiM4 3 = -1 := by
  rw [chiM4_apply]; have : ZMod.χ₄ 3 = -1 := rfl; rw [this]; simp

theorem chiM4_one : chiM4 1 = 1 := map_one _

theorem chiM4_ne_one : chiM4 ≠ 1 := by
  intro h
  have h3 := chiM4_three
  rw [h, MulChar.one_apply (by decide : IsUnit (3 : ZMod 4))] at h3
  norm_num at h3

theorem chiM4_real (n : ℕ) : (chiM4 n).im = 0 := by
  rw [chiM4_apply]; simp

theorem chiM4_odd : chiM4.Odd := by
  show chiM4 (-1) = -1
  rw [show (-1 : ZMod 4) = 3 by decide, chiM4_three]

theorem chiM4_isPrimitive : chiM4.IsPrimitive := by
  rw [DirichletCharacter.isPrimitive_def]
  obtain ⟨h, χ₀, hχ₀⟩ := DirichletCharacter.factorsThrough_conductor chiM4
  have hd := DirichletCharacter.conductor_dvd_level chiM4
  have hle := Nat.le_of_dvd (by norm_num) hd
  generalize DirichletCharacter.conductor chiM4 = d at h χ₀ hχ₀ hd hle ⊢
  have key : d ∣ 2 → False := by
    intro h2
    have hcop : IsCoprime (3 : ℤ) ((4 : ℕ) : ℤ) := by rw [Int.isCoprime_iff_gcd_eq_one]; rfl
    have h3 := DirichletCharacter.changeLevel_eq_cast_of_dvd' χ₀ h hcop
    rw [← hχ₀] at h3
    have h31 : ((3 : ℤ) : ZMod d) = 1 := by
      rw [show (1 : ZMod d) = ((1 : ℤ) : ZMod d) by simp, ZMod.intCast_eq_intCast_iff_dvd_sub]
      exact (Int.natCast_dvd_natCast.mpr h2).trans (by norm_num)
    rw [h31, map_one] at h3
    have : chiM4 ((3 : ℤ) : ZMod 4) = -1 := by
      rw [show ((3 : ℤ) : ZMod 4) = 3 by rfl]; exact chiM4_three
    rw [this] at h3
    norm_num at h3
  interval_cases hdv : d
  · exact absurd hd (by norm_num)
  · exact (key (one_dvd 2)).elim
  · exact (key dvd_rfl).elim
  · exact absurd hd (by norm_num)
  · rfl

theorem stdAddChar_one_four : (ZMod.stdAddChar (1 : ZMod 4) : ℂ) = I := by
  have := ZMod.stdAddChar_coe (N := 4) 1
  push_cast at this
  rw [this, show 2 * (π : ℂ) * I * 1 / 4 = π / 2 * I by ring, exp_pi_div_two_mul_I]

theorem stdAddChar_three_four : (ZMod.stdAddChar (3 : ZMod 4) : ℂ) = -I := by
  have := ZMod.stdAddChar_coe (N := 4) 3
  push_cast at this
  rw [this, show 2 * (π : ℂ) * I * 3 / 4 = π * I + π / 2 * I by ring, Complex.exp_add,
    exp_pi_mul_I, exp_pi_div_two_mul_I]
  ring

theorem gaussSum_chiM4 : gaussSum chiM4 ZMod.stdAddChar = 2 * I := by
  rw [gaussSum, show (Finset.univ : Finset (ZMod 4)) = {0, 1, 2, 3} by decide,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_singleton]
  have h0 : chiM4 0 = 0 := by rw [chiM4_apply]; have : ZMod.χ₄ 0 = 0 := rfl; simp [this]
  have h2 : chiM4 2 = 0 := by rw [chiM4_apply]; have : ZMod.χ₄ 2 = 0 := rfl; simp [this]
  rw [h0, chiM4_one, h2, chiM4_three, stdAddChar_one_four, stdAddChar_three_four]
  ring

theorem rootNumber_chiM4 : DirichletCharacter.rootNumber chiM4 = 1 := by
  classical
  rw [DirichletCharacter.rootNumber, gaussSum_chiM4, if_neg chiM4_odd.not_even, pow_one]
  have h4 : ((4 : ℕ) : ℂ) ^ (1 / 2 : ℂ) = 2 := by
    rw [natCast_cpow_half]
    rw [show ((4 : ℕ) : ℝ) = 2 ^ (2 : ℝ) by norm_num, ← Real.rpow_mul (by norm_num)]
    norm_num
  rw [h4]
  field_simp

/-- **Non-vacuity at `χ₋₄`:** if `L(s, χ₋₄) ≠ 0` on `Re s > 7/8`, then every zero of `H_t^{χ₋₄}` is
real for `t ≥ 9/32`.  Every other hypothesis is discharged. -/
theorem chiM4_real_zeros
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction chiM4 s ≠ 0) :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, Hchi chiM4 t z = 0 → z.im = 0 :=
  dirichlet_real_zeros_of_rootNumber chiM4_isPrimitive chiM4_ne_one chiM4_real rootNumber_chiM4 hL

end DBN.Gen
