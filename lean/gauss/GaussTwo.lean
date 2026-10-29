import Mathlib
import GaussPow
import GenChi4

/-! Gauss's sign theorem, stage S3b′: **levels 1, 2, 4, 8.**

* no primitive character mod `2`;
* the only real nontrivial character mod `4` is `χ₋₄`;
* the real primitive characters mod `8` are `χ₈` and `χ₋₈` (`= χ₈'`);
* `rootNumber = 1` for `χ₈`, `χ₋₈` (`τ(χ₈) = √8`, `τ(χ₋₈) = i√8`).
conjecture1_proved = False. -/

open Real Complex ZMod

namespace DBN.Gen

/-- `χ₈` as a complex Dirichlet character mod 8. -/
noncomputable def chi8 : DirichletCharacter ℂ 8 := ZMod.χ₈.ringHomComp (Int.castRingHom ℂ)

/-- `χ₋₈ = χ₈'` as a complex Dirichlet character mod 8. -/
noncomputable def chiM8 : DirichletCharacter ℂ 8 := ZMod.χ₈'.ringHomComp (Int.castRingHom ℂ)

theorem chi8_apply (a : ZMod 8) : chi8 a = (ZMod.χ₈ a : ℂ) := rfl
theorem chiM8_apply (a : ZMod 8) : chiM8 a = (ZMod.χ₈' a : ℂ) := rfl

theorem not_isPrimitive_mod_two (χ : DirichletCharacter ℂ 2) : ¬ χ.IsPrimitive := by
  have h1 : χ = 1 := by
    ext u
    have : u = 1 := by revert u; decide
    rw [this]; simp
  rw [h1, DirichletCharacter.isPrimitive_def, DirichletCharacter.conductor_one]
  norm_num

theorem units_four (u : (ZMod 4)ˣ) : (u : ZMod 4) = 1 ∨ (u : ZMod 4) = 3 := by
  revert u; decide

theorem units_eight (u : (ZMod 8)ˣ) :
    (u : ZMod 8) = 1 ∨ (u : ZMod 8) = 3 ∨ (u : ZMod 8) = 5 ∨ (u : ZMod 8) = 7 := by
  revert u; decide

/-- The only real nontrivial character mod 4 is `χ₋₄`. -/
theorem eq_chiM4 (χ : DirichletCharacter ℂ 4) (hχ1 : χ ≠ 1) (hreal : ∀ n : ℕ, (χ n).im = 0) :
    χ = chiM4 := by
  have h3u : IsUnit (3 : ZMod 4) := by decide
  have h3 : χ 3 = -1 := by
    rcases real_char_pm' χ hreal h3u with h | h
    · exfalso; apply hχ1; ext u
      rcases units_four u with hu | hu <;> rw [MulChar.one_apply_coe, hu]
      · exact map_one χ
      · exact h
    · exact h
  ext u
  rcases units_four u with hu | hu <;> rw [hu]
  · rw [map_one, map_one]
  · rw [h3, chiM4_three]

/-- The real primitive characters mod 8 are `χ₈` and `χ₋₈`. -/
theorem eq_chi8_or (χ : DirichletCharacter ℂ 8) (hprim : χ.IsPrimitive)
    (hreal : ∀ n : ℕ, (χ n).im = 0) : χ = chi8 ∨ χ = chiM8 := by
  have h5u : IsUnit (5 : ZMod 8) := by decide
  have h3u : IsUnit (3 : ZMod 8) := by decide
  have h5 : χ 5 = -1 := by
    rcases real_char_pm' χ hreal h5u with h | h
    · exfalso
      have hd : (4 : ℕ) ∣ 8 := by norm_num
      have hf : DirichletCharacter.FactorsThrough χ 4 := by
        rw [DirichletCharacter.factorsThrough_iff_ker_unitsMap hd]
        intro u hu
        rw [unitsMap_ker_val] at hu
        rw [MonoidHom.mem_ker, Units.ext_iff, MulChar.coe_toUnitHom, Units.val_one]
        have key : ∀ v : (ZMod 8)ˣ, ((((v : ZMod 8).val : ℕ)) : ZMod 4) = 1 →
            (v : ZMod 8) = 1 ∨ (v : ZMod 8) = 5 := by decide
        rcases key u hu with h' | h' <;> rw [h']
        · exact map_one χ
        · exact h
      have hle : DirichletCharacter.conductor χ ≤ 4 := Nat.sInf_le hf
      rw [(DirichletCharacter.isPrimitive_def χ).mp hprim] at hle
      norm_num at hle
    · exact h
  have h7 : χ 7 = χ 3 * χ 5 := by rw [← map_mul]; congr 1
  rcases real_char_pm' χ hreal h3u with h3 | h3
  · right; ext u
    rcases units_eight u with hu | hu | hu | hu <;> rw [hu]
    · rw [map_one, map_one]
    · rw [h3, chiM8_apply, show ZMod.χ₈' 3 = 1 from rfl]; simp
    · rw [h5, chiM8_apply, show ZMod.χ₈' 5 = -1 from rfl]; simp
    · rw [h7, h3, h5, chiM8_apply, show ZMod.χ₈' 7 = -1 from rfl]; simp
  · left; ext u
    rcases units_eight u with hu | hu | hu | hu <;> rw [hu]
    · rw [map_one, map_one]
    · rw [h3, chi8_apply, show ZMod.χ₈ 3 = -1 from rfl]; simp
    · rw [h5, chi8_apply, show ZMod.χ₈ 5 = -1 from rfl]; simp
    · rw [h7, h3, h5, chi8_apply, show ZMod.χ₈ 7 = 1 from rfl]; simp

/-- `ζ₈ = e^{2πi/8} = (√2/2)(1 + i)`. -/
theorem zeta8 : cexp (2 * π * I * (1 : ℕ) / (8 : ℕ)) = ((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I) := by
  rw [show 2 * (π : ℂ) * I * ((1 : ℕ) : ℂ) / ((8 : ℕ) : ℂ) = ((π / 4 : ℝ) : ℂ) * I by push_cast; ring,
    Complex.exp_mul_I, ← ofReal_cos, ← ofReal_sin, Real.cos_pi_div_four, Real.sin_pi_div_four]
  ring

theorem stdAddChar_eight_pow (k : ℕ) :
    (stdAddChar ((k : ℕ) : ZMod 8) : ℂ) = (((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) ^ k := by
  rw [stdAddChar_natCast', ← zeta8, ← Complex.exp_nat_mul]
  congr 1; push_cast; ring

theorem zeta8_sq : (((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) ^ 2 = I := by
  have h2 : ((Real.sqrt 2 : ℝ) : ℂ) ^ 2 = 2 := by exact_mod_cast Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)
  push_cast
  ring_nf
  rw [I_sq, h2]
  ring

theorem sqrt_eight : Real.sqrt 8 = 2 * Real.sqrt 2 := by
  rw [show (8 : ℝ) = 2 ^ 2 * 2 by norm_num, Real.sqrt_mul (by norm_num), Real.sqrt_sq (by norm_num)]

theorem pow_of_sq_eq_I {z : ℂ} (hz : z ^ 2 = I) :
    z ^ 1 = z ∧ z ^ 3 = z * I ∧ z ^ 5 = -z ∧ z ^ 7 = -(z * I) := by
  refine ⟨pow_one z, ?_, ?_, ?_⟩
  · rw [pow_succ, hz, mul_comm]
  · rw [show z ^ 5 = (z ^ 2) ^ 2 * z by ring, hz, I_sq]; ring
  · rw [show z ^ 7 = (z ^ 2) ^ 3 * z by ring, hz, show I ^ 3 = -I by rw [pow_succ, I_sq]; ring]; ring

theorem gaussSum_eight (χ : DirichletCharacter ℂ 8) (h0 : χ 0 = 0) (h2 : χ 2 = 0) (h4 : χ 4 = 0)
    (h6 : χ 6 = 0) : gaussSum χ stdAddChar =
      χ 1 * (((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) + χ 3 * ((((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) * I) -
      χ 5 * (((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) - χ 7 * ((((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) * I) := by
  obtain ⟨p1, p3, p5, p7⟩ := pow_of_sq_eq_I zeta8_sq
  have e : ∀ k : ℕ, (stdAddChar (((k : ℕ)) : ZMod 8) : ℂ) =
      (((Real.sqrt 2 / 2 : ℝ) : ℂ) * (1 + I)) ^ k := stdAddChar_eight_pow
  have e1 := e 1; have e3 := e 3; have e5 := e 5; have e7 := e 7
  rw [p1] at e1; rw [p3] at e3; rw [p5] at e5; rw [p7] at e7
  push_cast at e1 e3 e5 e7
  rw [gaussSum, show (Finset.univ : Finset (ZMod 8)) = {0, 1, 2, 3, 4, 5, 6, 7} by decide]
  simp only [Finset.sum_insert (show (0 : ZMod 8) ∉ ({1, 2, 3, 4, 5, 6, 7} : Finset (ZMod 8)) by decide),
    Finset.sum_insert (show (1 : ZMod 8) ∉ ({2, 3, 4, 5, 6, 7} : Finset (ZMod 8)) by decide),
    Finset.sum_insert (show (2 : ZMod 8) ∉ ({3, 4, 5, 6, 7} : Finset (ZMod 8)) by decide),
    Finset.sum_insert (show (3 : ZMod 8) ∉ ({4, 5, 6, 7} : Finset (ZMod 8)) by decide),
    Finset.sum_insert (show (4 : ZMod 8) ∉ ({5, 6, 7} : Finset (ZMod 8)) by decide),
    Finset.sum_insert (show (5 : ZMod 8) ∉ ({6, 7} : Finset (ZMod 8)) by decide),
    Finset.sum_insert (show (6 : ZMod 8) ∉ ({7} : Finset (ZMod 8)) by decide),
    Finset.sum_singleton, h0, h2, h4, h6, zero_mul, zero_add, add_zero]
  rw [e1, e3, e5, e7]
  push_cast
  ring

theorem chi8_even : chi8.Even := by
  show chi8 (-1) = 1
  rw [show (-1 : ZMod 8) = 7 by decide, chi8_apply, show ZMod.χ₈ 7 = 1 from rfl]; simp

theorem chiM8_odd : chiM8.Odd := by
  show chiM8 (-1) = -1
  rw [show (-1 : ZMod 8) = 7 by decide, chiM8_apply, show ZMod.χ₈' 7 = -1 from rfl]; simp

theorem natCast_cpow_half_eight : ((8 : ℕ) : ℂ) ^ (1 / 2 : ℂ) = ((2 * Real.sqrt 2 : ℝ) : ℂ) := by
  rw [natCast_cpow_half, ← Real.sqrt_eq_rpow, Nat.cast_ofNat, sqrt_eight]

theorem rootNumber_chi8 : DirichletCharacter.rootNumber chi8 = 1 := by
  have hg := gaussSum_eight chi8
    (by rw [chi8_apply, show ZMod.χ₈ 0 = 0 from rfl, Int.cast_zero])
    (by rw [chi8_apply, show ZMod.χ₈ 2 = 0 from rfl, Int.cast_zero])
    (by rw [chi8_apply, show ZMod.χ₈ 4 = 0 from rfl, Int.cast_zero])
    (by rw [chi8_apply, show ZMod.χ₈ 6 = 0 from rfl, Int.cast_zero])
  rw [chi8_apply 1, chi8_apply 3, chi8_apply 5, chi8_apply 7, show ZMod.χ₈ 1 = 1 from rfl,
    show ZMod.χ₈ 3 = -1 from rfl, show ZMod.χ₈ 5 = -1 from rfl, show ZMod.χ₈ 7 = 1 from rfl] at hg
  rw [DirichletCharacter.rootNumber, hg, if_pos chi8_even, pow_zero, div_one, natCast_cpow_half_eight]
  have h2 : ((Real.sqrt 2 : ℝ) : ℂ) ^ 2 = 2 := by exact_mod_cast Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)
  have hs : ((Real.sqrt 2 : ℝ) : ℂ) ≠ 0 := by
    exact_mod_cast (Real.sqrt_pos.mpr (by norm_num : (0:ℝ) < 2)).ne'
  push_cast
  field_simp
  ring_nf
  rw [I_sq]
  ring

theorem rootNumber_chiM8 : DirichletCharacter.rootNumber chiM8 = 1 := by
  have hg := gaussSum_eight chiM8
    (by rw [chiM8_apply, show ZMod.χ₈' 0 = 0 from rfl, Int.cast_zero])
    (by rw [chiM8_apply, show ZMod.χ₈' 2 = 0 from rfl, Int.cast_zero])
    (by rw [chiM8_apply, show ZMod.χ₈' 4 = 0 from rfl, Int.cast_zero])
    (by rw [chiM8_apply, show ZMod.χ₈' 6 = 0 from rfl, Int.cast_zero])
  rw [chiM8_apply 1, chiM8_apply 3, chiM8_apply 5, chiM8_apply 7, show ZMod.χ₈' 1 = 1 from rfl,
    show ZMod.χ₈' 3 = 1 from rfl, show ZMod.χ₈' 5 = -1 from rfl, show ZMod.χ₈' 7 = -1 from rfl] at hg
  rw [DirichletCharacter.rootNumber, hg, if_neg chiM8_odd.not_even, pow_one, natCast_cpow_half_eight]
  have hs : ((Real.sqrt 2 : ℝ) : ℂ) ≠ 0 := by
    exact_mod_cast (Real.sqrt_pos.mpr (by norm_num : (0:ℝ) < 2)).ne'
  push_cast
  field_simp
  ring_nf
  rw [I_sq]
  ring

end DBN.Gen
