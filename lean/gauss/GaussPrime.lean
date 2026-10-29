import Mathlib
import GaussQuad

/-! Gauss's sign theorem, stage S2: **prime conductor.**

For an odd prime `p` and a real-valued Dirichlet character `χ ≠ 1` mod `p`:
* `χ` is the quadratic (Legendre) character;
* `τ(χ) = Σ_x e^{2πi x²/p} = G(p)`;
* hence (by S1) `τ(χ) = √p` (`p ≡ 1 mod 4`) or `i√p` (`p ≡ 3 mod 4`), i.e. **`rootNumber χ = 1`**;
* `χ` is primitive.
conjecture1_proved = False. -/

open Complex ZMod

namespace DBN.Gen

/-- `G(N)` as a sum over `ZMod N` of `ψ(x²)`. -/
theorem gaussG_eq_sum_zmod (N : ℕ) [NeZero N] :
    gaussG N = ∑ x : ZMod N, (stdAddChar (x ^ 2) : ℂ) := by
  unfold gaussG
  refine Fintype.sum_bijective _ bijective_fin_cast _ _ fun j ↦ ?_
  rw [show ((j : ℕ) : ZMod N) ^ 2 = (((((j : ℕ) ^ 2 : ℕ)) : ℤ) : ZMod N) by push_cast; ring,
    stdAddChar_coe]
  push_cast
  ring_nf

/-- `Σ_x ψ(x²) = Σ_a #{x | x² = a} ψ(a)`. -/
theorem sum_sq_eq_sum_card {R : Type*} [CommRing R] [Fintype R] [DecidableEq R] (ψ : R → ℂ) :
    ∑ x : R, ψ (x ^ 2) = ∑ a : R, (({x : R | x ^ 2 = a}.toFinset.card : ℕ) : ℂ) * ψ a := by
  simp only [Set.toFinset_setOf, Finset.card_filter, Nat.cast_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ ↦ ?_
  simp

variable {p : ℕ} [hp : Fact p.Prime]

/-- Values of a real character mod `p` at nonzero points are `±1`. -/
theorem real_char_pm (χ : DirichletCharacter ℂ p) (hreal : ∀ n : ℕ, (χ n).im = 0) {a : ZMod p}
    (ha : a ≠ 0) : χ a = 1 ∨ χ a = -1 := by
  have hu : IsUnit a := ha.isUnit
  have hnorm : ‖χ a‖ = 1 := by
    obtain ⟨u, rfl⟩ := hu; exact DirichletCharacter.unit_norm_eq_one χ u
  have him : (χ a).im = 0 := by rw [← ZMod.natCast_zmod_val a]; exact hreal _
  have hre : χ a = ((χ a).re : ℂ) := Complex.ext (by simp) (by simp [him])
  rw [hre] at hnorm ⊢
  rw [Complex.norm_real, Real.norm_eq_abs] at hnorm
  rcases (abs_eq zero_le_one).mp hnorm with h | h
  · left; rw [h]; simp
  · right; rw [h]; simp

/-- **A real nontrivial character mod an odd prime is the quadratic character.** -/
theorem real_char_eq_quadraticChar (hp2 : p ≠ 2) (χ : DirichletCharacter ℂ p) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) (a : ZMod p) :
    χ a = (quadraticChar (ZMod p) a : ℂ) := by
  have hp1 : p ≠ 1 := hp.out.ne_one
  -- a nonzero point where `χ = −1`
  obtain ⟨a₀, ha₀, hχa₀⟩ : ∃ a₀ : ZMod p, a₀ ≠ 0 ∧ χ a₀ = -1 := by
    by_contra hcon
    push Not at hcon
    apply hχ1
    ext u
    rw [MulChar.one_apply_coe]
    have hu0 : (u : ZMod p) ≠ 0 := u.ne_zero
    rcases real_char_pm χ hreal hu0 with h | h
    · exact h
    · exact absurd h (hcon _ hu0)
  have hsq : ∀ b : ZMod p, IsSquare b → b ≠ 0 → χ b = 1 := by
    rintro b ⟨c, rfl⟩ hb
    have hc : c ≠ 0 := by rintro rfl; simp at hb
    rw [map_mul]
    rcases real_char_pm χ hreal hc with h | h <;> rw [h] <;> norm_num
  have hnsq₀ : ¬ IsSquare a₀ := fun h ↦ by
    have := hsq a₀ h ha₀; rw [hχa₀] at this; norm_num at this
  by_cases h0 : a = 0
  · subst h0
    rw [χ.map_zero' hp1, MulChar.map_zero]; simp
  by_cases hs : IsSquare a
  · rw [hsq a hs h0, (quadraticChar_one_iff_isSquare h0).mpr hs]; simp
  · rw [quadraticChar_neg_one_iff_not_isSquare.mpr hs]
    have hq : quadraticChar (ZMod p) (a * a₀) = 1 := by
      rw [map_mul, quadraticChar_neg_one_iff_not_isSquare.mpr hs,
        quadraticChar_neg_one_iff_not_isSquare.mpr hnsq₀]; norm_num
    have hsq' := (quadraticChar_one_iff_isSquare (mul_ne_zero h0 ha₀)).mp hq
    have := hsq _ hsq' (mul_ne_zero h0 ha₀)
    rw [map_mul, hχa₀] at this
    push_cast
    linear_combination -this

/-- `ringChar (ZMod p) ≠ 2` for an odd prime. -/
theorem ringChar_ne_two (hp2 : p ≠ 2) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]; exact hp2

/-- **`τ(χ) = G(p)`.** -/
theorem gaussSum_eq_gaussG (hp2 : p ≠ 2) (χ : DirichletCharacter ℂ p) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) : gaussSum χ stdAddChar = gaussG p := by
  rw [gaussG_eq_sum_zmod, sum_sq_eq_sum_card (fun x ↦ (stdAddChar x : ℂ)), gaussSum]
  have hne : (stdAddChar : AddChar (ZMod p) ℂ) ≠ 1 := by
    intro h
    have h1 := congrArg (fun f : AddChar (ZMod p) ℂ ↦ f 1) h
    simp only [AddChar.one_apply] at h1
    rw [← (stdAddChar (N := p)).map_zero_eq_one, injective_stdAddChar.eq_iff] at h1
    exact one_ne_zero h1
  have hψ : ∑ a : ZMod p, (stdAddChar a : ℂ) = 0 := AddChar.sum_eq_zero_of_ne_one hne
  have : ∀ a : ZMod p, (({x : ZMod p | x ^ 2 = a}.toFinset.card : ℕ) : ℂ) * stdAddChar a =
      χ a * stdAddChar a + stdAddChar a := by
    intro a
    have hc := quadraticChar_card_sqrts (ringChar_ne_two hp2) a
    rw [real_char_eq_quadraticChar hp2 χ hχ1 hreal a]
    have hc' : (({x : ZMod p | x ^ 2 = a}.toFinset.card : ℕ) : ℂ) =
        (quadraticChar (ZMod p) a : ℂ) + 1 := by exact_mod_cast hc
    rw [hc']; ring
  rw [Finset.sum_congr rfl fun a _ ↦ this a, Finset.sum_add_distrib, hψ, add_zero]

/-- A nontrivial character mod a prime is primitive. -/
theorem isPrimitive_of_prime (χ : DirichletCharacter ℂ p) (hχ1 : χ ≠ 1) : χ.IsPrimitive := by
  rw [DirichletCharacter.isPrimitive_def]
  rcases hp.out.eq_one_or_self_of_dvd _ (DirichletCharacter.conductor_dvd_level χ) with h | h
  · exact absurd (DirichletCharacter.eq_one_iff_conductor_eq_one.mpr h) hχ1
  · exact h

theorem negI_pow_mod_four (n : ℕ) : (-I) ^ n = (-I) ^ (n % 4) := by
  conv_lhs => rw [← Nat.div_add_mod n 4, pow_add, pow_mul]
  rw [show (-I) ^ 4 = (1 : ℂ) by rw [neg_pow, I_pow_four]; norm_num, one_pow, one_mul]

/-- **Stage S2: Gauss's sign theorem for prime conductor.**  For an odd prime `p` and a real
Dirichlet character `χ ≠ 1` mod `p`, `rootNumber χ = 1`. -/
theorem rootNumber_eq_one_of_prime (hp2 : p ≠ 2) (χ : DirichletCharacter ℂ p) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) : DirichletCharacter.rootNumber χ = 1 := by
  have hpr : (0 : ℝ) < p := by exact_mod_cast hp.out.pos
  have hsN : (p : ℂ) ^ (1 / 2 : ℂ) = (Real.sqrt p : ℂ) := by
    rw [natCast_cpow_half, Real.sqrt_eq_rpow]
  have hs : (Real.sqrt p : ℂ) ≠ 0 := by exact_mod_cast (Real.sqrt_pos.mpr hpr).ne'
  have hτ := gaussSum_eq_gaussG hp2 χ hχ1 hreal
  rw [gaussG_eq] at hτ
  -- parity of `χ` from `IsSquare (−1) ↔ p % 4 ≠ 3` (the `-1` is Mathlib's, via `unfold`)
  have hev_iff : χ.Even ↔ p % 4 ≠ 3 := by
    unfold DirichletCharacter.Even
    rw [real_char_eq_quadraticChar hp2 χ hχ1 hreal, ← ZMod.exists_sq_eq_neg_one_iff]
    constructor
    · intro h
      by_contra hns
      rw [quadraticChar_neg_one_iff_not_isSquare.mpr hns] at h
      norm_num at h
    · intro hs
      rw [(quadraticChar_one_iff_isSquare (neg_ne_zero.mpr one_ne_zero)).mpr hs]
      simp
  have hodd : p % 2 = 1 := Nat.odd_iff.mp (hp.out.odd_of_ne_two hp2)
  have hmod : p % 4 = 1 ∨ p % 4 = 3 := by omega
  unfold DirichletCharacter.rootNumber
  rw [hsN, hτ, negI_pow_mod_four]
  rcases hmod with h4 | h4
  · have hev : χ.Even := hev_iff.mpr (by omega)
    rw [if_pos hev, h4, pow_zero, div_one, pow_one]
    field_simp
    ring_nf
    rw [I_sq]
    ring
  · have hnev : ¬ χ.Even := fun h ↦ hev_iff.mp h h4
    rw [if_neg hnev, h4, pow_one]
    field_simp
    ring_nf
    have h3 : I ^ 3 = -I := by rw [pow_succ, I_sq]; ring
    simp only [h3, I_pow_four, I_sq]
    ring
/-- **`Λ_χ ≤ 9/32` for every real character `χ ≠ 1` of odd prime conductor**, conditional only on
the Dirichlet `7/8` half-plane (`hL`); `ε(χ) = 1` and primitivity are PROVED. -/
theorem prime_real_zeros (hp2 : p ≠ 2) (χ : DirichletCharacter ℂ p) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0)
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0) :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, Hchi χ t z = 0 → z.im = 0 :=
  dirichlet_real_zeros_of_rootNumber (isPrimitive_of_prime χ hχ1) hχ1 hreal
    (rootNumber_eq_one_of_prime hp2 χ hχ1 hreal) hL

end DBN.Gen
