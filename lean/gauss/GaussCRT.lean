import Mathlib
import GaussPrime

/-! Gauss's sign theorem, stage S3a: **CRT decomposition of Dirichlet characters and the twisted
multiplicativity of Gauss sums.**

For coprime `q, M` and `χ` mod `qM`: `χ = χ₁ · χ₂` with `χ₁` mod `q`, `χ₂` mod `M`
(`χ₁(a) = χ(crt⁻¹(a, 1))`, `χ₂(b) = χ(crt⁻¹(1, b))`), and

`τ(χ) = χ₁(M) χ₂(q) τ(χ₁) τ(χ₂)`.

conjecture1_proved = False. -/

open Real Complex ZMod

namespace DBN.Gen

variable {q M : ℕ}

/-- First CRT component `χ₁(a) = χ(crt⁻¹(a, 1))`. -/
noncomputable def comp1 (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) :
    DirichletCharacter ℂ q where
  toFun a := χ ((ZMod.chineseRemainder h).symm (a, 1))
  map_one' := by simp [← Prod.one_eq_mk]
  map_mul' a b := by
    rw [← map_mul χ, ← map_mul (ZMod.chineseRemainder h).symm, Prod.mk_mul_mk, mul_one]
  map_nonunit' a ha := by
    apply MulChar.map_nonunit
    rw [isUnit_map_iff]
    exact fun hu ↦ ha (Prod.isUnit_iff.mp hu).1

/-- Second CRT component `χ₂(b) = χ(crt⁻¹(1, b))`. -/
noncomputable def comp2 (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) :
    DirichletCharacter ℂ M where
  toFun b := χ ((ZMod.chineseRemainder h).symm (1, b))
  map_one' := by simp [← Prod.one_eq_mk]
  map_mul' a b := by
    rw [← map_mul χ, ← map_mul (ZMod.chineseRemainder h).symm, Prod.mk_mul_mk, mul_one]
  map_nonunit' a ha := by
    apply MulChar.map_nonunit
    rw [isUnit_map_iff]
    exact fun hu ↦ ha (Prod.isUnit_iff.mp hu).2

theorem comp1_apply (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) (a : ZMod q) :
    comp1 h χ a = χ ((ZMod.chineseRemainder h).symm (a, 1)) := rfl

theorem comp2_apply (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) (b : ZMod M) :
    comp2 h χ b = χ ((ZMod.chineseRemainder h).symm (1, b)) := rfl

/-- **Decomposition.** `χ(x) = χ₁(x mod q) χ₂(x mod M)`. -/
theorem decomp (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) (x : ZMod (q * M)) :
    χ x = comp1 h χ ((ZMod.chineseRemainder h) x).1 * comp2 h χ ((ZMod.chineseRemainder h) x).2 := by
  rw [comp1_apply, comp2_apply, ← map_mul, ← map_mul, Prod.mk_mul_mk, mul_one, one_mul]
  simp

theorem crt_natCast (h : q.Coprime M) (n : ℕ) :
    (ZMod.chineseRemainder h) (n : ZMod (q * M)) = ((n : ZMod q), (n : ZMod M)) := by
  rw [map_natCast]; rfl

/-- `χ(n) = χ₁(n) χ₂(n)` on naturals. -/
theorem decomp_nat (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) (n : ℕ) :
    χ n = comp1 h χ n * comp2 h χ n := by
  rw [decomp h χ, crt_natCast]

/-- Realness passes to the components. -/
theorem comp_real (h : q.Coprime M) (χ : DirichletCharacter ℂ (q * M)) [NeZero (q * M)]
    (hreal : ∀ n : ℕ, (χ n).im = 0) :
    (∀ n : ℕ, (comp1 h χ n).im = 0) ∧ (∀ n : ℕ, (comp2 h χ n).im = 0) := by
  have hall : ∀ y : ZMod (q * M), (χ y).im = 0 := fun y ↦ by
    rw [← ZMod.natCast_zmod_val y]; exact hreal _
  exact ⟨fun n ↦ hall _, fun n ↦ hall _⟩

/-- `stdAddChar` on a natural cast. -/
theorem stdAddChar_natCast' (N : ℕ) [NeZero N] (n : ℕ) :
    (stdAddChar (n : ZMod N) : ℂ) = cexp (2 * π * I * n / N) := by
  have := ZMod.stdAddChar_coe (N := N) (n : ℤ)
  push_cast at this
  exact this

/-- `stdAddChar a = e^{2πi a.val / N}`. -/
theorem stdAddChar_val (N : ℕ) [NeZero N] (a : ZMod N) :
    (stdAddChar a : ℂ) = cexp (2 * π * I * (a.val : ℕ) / N) := by
  rw [← stdAddChar_natCast', ZMod.natCast_zmod_val]

/-- **Twisted multiplicativity of Gauss sums.** -/
theorem gaussSum_decomp (h : q.Coprime M) [NeZero q] [NeZero M] (χ : DirichletCharacter ℂ (q * M)) :
    gaussSum χ stdAddChar = comp1 h χ M * comp2 h χ q *
      (gaussSum (comp1 h χ) stdAddChar * gaussSum (comp2 h χ) stdAddChar) := by
  set e := ZMod.chineseRemainder h with he
  set φ : ZMod q × ZMod M → ZMod (q * M) :=
    fun p ↦ ((p.1.val * M + p.2.val * q : ℕ) : ZMod (q * M)) with hφ
  have heφ : ∀ p : ZMod q × ZMod M, e (φ p) = (p.1 * M, p.2 * q) := by
    intro p
    rw [hφ, he, crt_natCast]
    push_cast
    simp
  have hinj : Function.Injective φ := by
    intro x y hxy
    have h1 := congrArg e hxy
    rw [heφ, heφ, Prod.mk.injEq] at h1
    have uM : IsUnit ((M : ℕ) : ZMod q) := (ZMod.unitOfCoprime M h.symm).isUnit
    have uq : IsUnit ((q : ℕ) : ZMod M) := (ZMod.unitOfCoprime q h).isUnit
    exact Prod.ext (uM.mul_left_inj.mp h1.1) (uq.mul_left_inj.mp h1.2)
  have hbij : Function.Bijective φ :=
    (Fintype.bijective_iff_injective_and_card φ).mpr ⟨hinj, by simp [ZMod.card]⟩
  have hterm : ∀ p : ZMod q × ZMod M, χ (φ p) * (stdAddChar (φ p) : ℂ) =
      comp1 h χ M * comp2 h χ q *
        ((comp1 h χ p.1 * stdAddChar p.1) * (comp2 h χ p.2 * stdAddChar p.2)) := by
    intro p
    rw [decomp h χ (φ p), heφ, map_mul, map_mul]
    have hψ : (stdAddChar (φ p) : ℂ) = stdAddChar p.1 * stdAddChar p.2 := by
      rw [hφ, stdAddChar_natCast', stdAddChar_val, stdAddChar_val, ← Complex.exp_add]
      congr 1
      have hq : (q : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne q)
      have hM : (M : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne M)
      push_cast
      first | (field_simp; ring) | field_simp
    rw [hψ]
    ring
  unfold gaussSum
  rw [← Fintype.sum_bijective φ hbij (fun p ↦ χ (φ p) * (stdAddChar (φ p) : ℂ)) _ (fun _ ↦ rfl)]
  simp_rw [hterm]
  rw [← Finset.mul_sum, Fintype.sum_prod_type, Finset.sum_mul_sum]

theorem natCast_eq_one_of_dvd {a b : ℕ} (hab : a ∣ b) {n : ℕ} (H : ((n : ℕ) : ZMod b) = 1) :
    ((n : ℕ) : ZMod a) = 1 := by
  have := congrArg (ZMod.castHom hab (ZMod a)) H
  rwa [map_natCast, map_one] at this

/-- For a unit `u` mod `qM`, `u.val` is a unit mod `q` and mod `M`. -/
theorem isUnit_val_cast (h : q.Coprime M) [NeZero q] [NeZero M] (u : (ZMod (q * M))ˣ) :
    IsUnit (((u : ZMod (q * M)).val : ℕ) : ZMod q) ∧ IsUnit (((u : ZMod (q * M)).val : ℕ) : ZMod M) := by
  have hu : IsUnit ((ZMod.chineseRemainder h) (u : ZMod (q * M))) := u.isUnit.map _
  rw [← ZMod.natCast_zmod_val (u : ZMod (q * M)), crt_natCast] at hu
  exact Prod.isUnit_iff.mp hu

/-- The kernel condition in `val` form. -/
theorem unitsMap_ker_val {n d : ℕ} [NeZero n] (hd : d ∣ n) (u : (ZMod n)ˣ) :
    u ∈ (ZMod.unitsMap hd).ker ↔ (((u : ZMod n).val : ℕ) : ZMod d) = 1 := by
  rw [MonoidHom.mem_ker, Units.ext_iff, ZMod.unitsMap_val, Units.val_one, ZMod.cast_eq_val]

/-- **Components of a primitive character are primitive.** -/
theorem comp1_isPrimitive (h : q.Coprime M) [NeZero q] [NeZero M] (χ : DirichletCharacter ℂ (q * M))
    (hprim : χ.IsPrimitive) : (comp1 h χ).IsPrimitive := by
  rw [DirichletCharacter.isPrimitive_def]
  have hdq := DirichletCharacter.conductor_dvd_level (comp1 h χ)
  have hf := DirichletCharacter.factorsThrough_conductor (comp1 h χ)
  generalize DirichletCharacter.conductor (comp1 h χ) = d at hdq hf ⊢
  have hd0 : d ≠ 0 := by rintro rfl; exact NeZero.ne q (Nat.eq_zero_of_zero_dvd hdq)
  have : NeZero d := ⟨hd0⟩
  rw [DirichletCharacter.factorsThrough_iff_ker_unitsMap hdq] at hf
  have hdM : d * M ∣ q * M := Nat.mul_dvd_mul_right hdq M
  have hfχ : DirichletCharacter.FactorsThrough χ (d * M) := by
    rw [DirichletCharacter.factorsThrough_iff_ker_unitsMap hdM]
    intro u hu
    rw [unitsMap_ker_val] at hu
    have hM1 := natCast_eq_one_of_dvd (dvd_mul_left M d) hu
    have hd1 := natCast_eq_one_of_dvd (dvd_mul_right d M) hu
    obtain ⟨v, hv⟩ := (isUnit_val_cast h u).1
    have hmod : ((((u : ZMod (q * M)).val % q : ℕ)) : ZMod d) =
        (((u : ZMod (q * M)).val : ℕ) : ZMod d) := by
      rw [ZMod.natCast_eq_natCast_iff', Nat.mod_mod_of_dvd _ hdq]
    have hvk : v ∈ (ZMod.unitsMap hdq).ker := by
      rw [unitsMap_ker_val, hv, ZMod.val_natCast, hmod, hd1]
    have hc1 := hf hvk
    rw [MonoidHom.mem_ker, Units.ext_iff, MulChar.coe_toUnitHom, Units.val_one] at hc1
    rw [MonoidHom.mem_ker, Units.ext_iff, MulChar.coe_toUnitHom, Units.val_one,
      ← ZMod.natCast_zmod_val (u : ZMod (q * M)), decomp_nat h χ, ← hv, hc1, hM1, map_one, mul_one]
  have hle : DirichletCharacter.conductor χ ≤ d * M := Nat.sInf_le hfχ
  rw [(DirichletCharacter.isPrimitive_def χ).mp hprim] at hle
  exact le_antisymm (Nat.le_of_dvd (NeZero.pos q) hdq)
    (le_of_mul_le_mul_right hle (NeZero.pos M))

theorem comp2_isPrimitive (h : q.Coprime M) [NeZero q] [NeZero M] (χ : DirichletCharacter ℂ (q * M))
    (hprim : χ.IsPrimitive) : (comp2 h χ).IsPrimitive := by
  rw [DirichletCharacter.isPrimitive_def]
  have hdM := DirichletCharacter.conductor_dvd_level (comp2 h χ)
  have hf := DirichletCharacter.factorsThrough_conductor (comp2 h χ)
  generalize DirichletCharacter.conductor (comp2 h χ) = d at hdM hf ⊢
  have hd0 : d ≠ 0 := by rintro rfl; exact NeZero.ne M (Nat.eq_zero_of_zero_dvd hdM)
  have : NeZero d := ⟨hd0⟩
  rw [DirichletCharacter.factorsThrough_iff_ker_unitsMap hdM] at hf
  have hqd : q * d ∣ q * M := Nat.mul_dvd_mul_left q hdM
  have hfχ : DirichletCharacter.FactorsThrough χ (q * d) := by
    rw [DirichletCharacter.factorsThrough_iff_ker_unitsMap hqd]
    intro u hu
    rw [unitsMap_ker_val] at hu
    have hq1 := natCast_eq_one_of_dvd (dvd_mul_right q d) hu
    have hd1 := natCast_eq_one_of_dvd (dvd_mul_left d q) hu
    obtain ⟨v, hv⟩ := (isUnit_val_cast h u).2
    have hmod : ((((u : ZMod (q * M)).val % M : ℕ)) : ZMod d) =
        (((u : ZMod (q * M)).val : ℕ) : ZMod d) := by
      rw [ZMod.natCast_eq_natCast_iff', Nat.mod_mod_of_dvd _ hdM]
    have hvk : v ∈ (ZMod.unitsMap hdM).ker := by
      rw [unitsMap_ker_val, hv, ZMod.val_natCast, hmod, hd1]
    have hc2 := hf hvk
    rw [MonoidHom.mem_ker, Units.ext_iff, MulChar.coe_toUnitHom, Units.val_one] at hc2
    rw [MonoidHom.mem_ker, Units.ext_iff, MulChar.coe_toUnitHom, Units.val_one,
      ← ZMod.natCast_zmod_val (u : ZMod (q * M)), decomp_nat h χ, ← hv, hc2, hq1, map_one, mul_one]
  have hle : DirichletCharacter.conductor χ ≤ q * d := Nat.sInf_le hfχ
  rw [(DirichletCharacter.isPrimitive_def χ).mp hprim] at hle
  exact le_antisymm (Nat.le_of_dvd (NeZero.pos M) hdM)
    (le_of_mul_le_mul_left hle (NeZero.pos q))

end DBN.Gen
