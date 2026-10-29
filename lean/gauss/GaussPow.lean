import Mathlib
import GaussCRT

/-! Gauss's sign theorem, stage S3b: **real primitive characters of prime-power level.**

* A real character is `1` on squares of units.
* `u ≡ 1 mod p^{e−1}` is a square mod `p^e` (`p` odd, `e ≥ 2`; or `p = 2`, `e ≥ 4`), so a real
  character mod `p^e` factors through `p^{e−1}`: **no real primitive character mod `p^e` for odd
  `p`, `e ≥ 2`, nor mod `2^e`, `e ≥ 4`.**
conjecture1_proved = False. -/

open Real Complex ZMod

namespace DBN.Gen

variable {N : ℕ} [NeZero N]

/-- Values of a real character at units are `±1` (any level). -/
theorem real_char_pm' (χ : DirichletCharacter ℂ N) (hreal : ∀ n : ℕ, (χ n).im = 0)
    {a : ZMod N} (hu : IsUnit a) : χ a = 1 ∨ χ a = -1 := by
  have hnorm : ‖χ a‖ = 1 := by
    obtain ⟨u, rfl⟩ := hu; exact DirichletCharacter.unit_norm_eq_one χ u
  have him : (χ a).im = 0 := by rw [← ZMod.natCast_zmod_val a]; exact hreal _
  have hre : χ a = ((χ a).re : ℂ) := Complex.ext (by simp) (by simp [him])
  rw [hre] at hnorm ⊢
  rw [Complex.norm_real, Real.norm_eq_abs] at hnorm
  rcases (abs_eq zero_le_one).mp hnorm with h | h
  · left; rw [h]; simp
  · right; rw [h]; simp

/-- A real character is `1` on squares of units. -/
theorem real_char_sq (χ : DirichletCharacter ℂ N) (hreal : ∀ n : ℕ, (χ n).im = 0)
    {w : ZMod N} (hw : IsUnit w) : χ (w ^ 2) = 1 := by
  rw [map_pow]
  rcases real_char_pm' χ hreal hw with h | h <;> rw [h] <;> norm_num

/-- If every unit `≡ 1 mod d` is a square, a real character factors through `d`. -/
theorem factorsThrough_of_sq {d : ℕ} (hd : d ∣ N) (χ : DirichletCharacter ℂ N)
    (hreal : ∀ n : ℕ, (χ n).im = 0)
    (hsq : ∀ u : (ZMod N)ˣ, (((u : ZMod N).val : ℕ) : ZMod d) = 1 → ∃ w : ZMod N, (u : ZMod N) = w ^ 2) :
    DirichletCharacter.FactorsThrough χ d := by
  rw [DirichletCharacter.factorsThrough_iff_ker_unitsMap hd]
  intro u hu
  rw [unitsMap_ker_val] at hu
  obtain ⟨w, hw⟩ := hsq u hu
  have hwu : IsUnit w := by
    have : IsUnit (w * w) := by rw [← sq, ← hw]; exact u.isUnit
    exact isUnit_of_mul_isUnit_left this
  rw [MonoidHom.mem_ker, Units.ext_iff, MulChar.coe_toUnitHom, Units.val_one, hw,
    real_char_sq χ hreal hwu]

/-- From `n ≡ 1 mod m` (as a `ZMod m` equation) to an integer witness. -/
theorem exists_eq_one_add_mul {m n : ℕ} (h : ((n : ℕ) : ZMod m) = 1) :
    ∃ k : ℤ, (n : ℤ) = 1 + m * k := by
  have h' : (((n : ℤ)) : ZMod m) = ((1 : ℤ) : ZMod m) := by push_cast; exact h
  rw [ZMod.intCast_eq_intCast_iff_dvd_sub] at h'
  obtain ⟨k, hk⟩ := h'
  exact ⟨-k, by linarith⟩

/-- If `(p^e : ℤ) ∣ w² − n`, then `(n : ZMod p^e) = w²`. -/
theorem natCast_eq_sq {m n : ℕ} {w : ℤ} (h : (m : ℤ) ∣ w ^ 2 - n) :
    ((n : ℕ) : ZMod m) = ((w : ℤ) : ZMod m) ^ 2 := by
  have : (((n : ℤ)) : ZMod m) = ((w ^ 2 : ℤ) : ZMod m) :=
    (ZMod.intCast_eq_intCast_iff_dvd_sub _ _ _).mpr h
  push_cast at this
  exact this

/-- **Odd prime powers.** `u ≡ 1 mod p^{e−1}` is a square mod `p^e` (`e ≥ 2`). -/
theorem sq_of_one_mod_odd {p e : ℕ} (hp2 : p % 2 = 1) (he : 2 ≤ e) {n : ℕ}
    (h : ((n : ℕ) : ZMod (p ^ (e - 1))) = 1) : ∃ w : ZMod (p ^ e), ((n : ℕ) : ZMod (p ^ e)) = w ^ 2 := by
  obtain ⟨k, hk⟩ := exists_eq_one_add_mul h
  obtain ⟨c, hc⟩ : ∃ c : ℕ, p + 1 = 2 * c := ⟨(p + 1) / 2, by omega⟩
  refine ⟨((1 + k * c * p ^ (e - 1) : ℤ) : ZMod (p ^ e)), natCast_eq_sq ?_⟩
  rw [hk]
  have hpe : (p : ℤ) ^ e = p * p ^ (e - 1) := by
    rw [← pow_succ']; congr 1; omega
  have h2 : (p : ℤ) ^ e ∣ (p : ℤ) ^ (e - 1) * p ^ (e - 1) := by
    rw [← pow_add]; exact pow_dvd_pow _ (by omega)
  have hc' : (p : ℤ) + 1 = 2 * c := by exact_mod_cast hc
  push_cast
  have : (1 + k * c * (p : ℤ) ^ (e - 1)) ^ 2 - (1 + (p : ℤ) ^ (e - 1) * k) =
      k * (p : ℤ) ^ e + (k * c) ^ 2 * ((p : ℤ) ^ (e - 1) * p ^ (e - 1)) := by
    rw [hpe]; linear_combination (-(k * (p : ℤ) ^ (e - 1))) * hc'
  rw [this]
  exact dvd_add (dvd_mul_left _ _) (dvd_mul_of_dvd_right h2 _)

/-- **Powers of two.** `u ≡ 1 mod 2^{e−1}` is a square mod `2^e` (`e ≥ 4`). -/
theorem sq_of_one_mod_two {e : ℕ} (he : 4 ≤ e) {n : ℕ}
    (h : ((n : ℕ) : ZMod (2 ^ (e - 1))) = 1) : ∃ w : ZMod (2 ^ e), ((n : ℕ) : ZMod (2 ^ e)) = w ^ 2 := by
  obtain ⟨k, hk⟩ := exists_eq_one_add_mul h
  refine ⟨((1 + k * 2 ^ (e - 2) : ℤ) : ZMod (2 ^ e)), natCast_eq_sq ?_⟩
  rw [hk]
  have h1 : (2 : ℤ) ^ (e - 1) = 2 * 2 ^ (e - 2) := by rw [← pow_succ']; congr 1; omega
  have h2 : (2 : ℤ) ^ e ∣ (2 : ℤ) ^ (e - 2) * 2 ^ (e - 2) := by
    rw [← pow_add]; exact pow_dvd_pow _ (by omega)
  push_cast
  have : (1 + k * (2 : ℤ) ^ (e - 2)) ^ 2 - (1 + (2 : ℤ) ^ (e - 1) * k) =
      k ^ 2 * ((2 : ℤ) ^ (e - 2) * 2 ^ (e - 2)) := by rw [h1]; ring
  rw [this]
  exact dvd_mul_of_dvd_right h2 _

/-- **No real primitive character mod `p^e`, `p` odd, `e ≥ 2`.** -/
theorem not_isPrimitive_odd_pow {p e : ℕ} [NeZero (p ^ e)] (hp1 : 1 < p) (hp2 : p % 2 = 1)
    (he : 2 ≤ e) (χ : DirichletCharacter ℂ (p ^ e)) (hreal : ∀ n : ℕ, (χ n).im = 0) :
    ¬ χ.IsPrimitive := by
  intro hprim
  have hd : p ^ (e - 1) ∣ p ^ e := pow_dvd_pow p (Nat.sub_le e 1)
  have hf := factorsThrough_of_sq hd χ hreal fun u hu ↦ by
    obtain ⟨w, hw⟩ := sq_of_one_mod_odd hp2 he hu
    exact ⟨w, by rw [← hw, ZMod.natCast_zmod_val]⟩
  have hle : DirichletCharacter.conductor χ ≤ p ^ (e - 1) := Nat.sInf_le hf
  rw [(DirichletCharacter.isPrimitive_def χ).mp hprim] at hle
  have : p ^ (e - 1) < p ^ e := Nat.pow_lt_pow_right hp1 (by omega)
  omega

/-- **No real primitive character mod `2^e`, `e ≥ 4`.** -/
theorem not_isPrimitive_two_pow {e : ℕ} [NeZero (2 ^ e)] (he : 4 ≤ e)
    (χ : DirichletCharacter ℂ (2 ^ e)) (hreal : ∀ n : ℕ, (χ n).im = 0) : ¬ χ.IsPrimitive := by
  intro hprim
  have hd : 2 ^ (e - 1) ∣ 2 ^ e := pow_dvd_pow 2 (Nat.sub_le e 1)
  have hf := factorsThrough_of_sq hd χ hreal fun u hu ↦ by
    obtain ⟨w, hw⟩ := sq_of_one_mod_two he hu
    exact ⟨w, by rw [← hw, ZMod.natCast_zmod_val]⟩
  have hle : DirichletCharacter.conductor χ ≤ 2 ^ (e - 1) := Nat.sInf_le hf
  rw [(DirichletCharacter.isPrimitive_def χ).mp hprim] at hle
  have : 2 ^ (e - 1) < 2 ^ e := Nat.pow_lt_pow_right (by norm_num) (by omega)
  omega

end DBN.Gen
