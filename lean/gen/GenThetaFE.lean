import Mathlib
import GenStrip

/-! Generic dBN island, part 6 (D2b′): **the theta functional equation and evenness of `Φ_χ`.**

For a real primitive Dirichlet character `χ` mod `N` with parity `k` (`k = 0` even, `k = 1` odd),
`θ_χ(x) = Σ_{n ≥ 1} χ(n) n^k e^{−πn²x/N}` satisfies

`θ_χ(x) = ε(χ) · x^{−(k + 1/2)} · θ_χ(1/x)`   (`x > 0`),

where `ε(χ) = rootNumber χ`.  Proof: split `Σ_{n ∈ ℤ}` into residue classes mod `N` (Hurwitz
kernels), apply Mathlib's `evenKernel_functional_equation` / `oddKernel_functional_equation`, and
recombine with the Gauss-sum identity `IsPrimitive.fourierTransform_eq_inv_mul_gaussSum`.

Consequence: **`rootNumber χ = 1 ⇒ Φ_χ` even**, which discharges the hypothesis `heven`.
(`rootNumber χ = 1` for every real primitive `χ` is Gauss's sign theorem, which is NOT in Mathlib;
it stays an explicit hypothesis.)  conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology Complex HurwitzZeta ZMod

namespace DBN.Gen

variable {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)

/-- The two-sided theta term `χ(n) n^k e^{−πn²x/N}` on `ℤ`. -/
noncomputable def thZ (k : ℕ) (x : ℝ) (n : ℤ) : ℂ :=
  χ n * (n : ℂ) ^ k * (rexp (-π * (n : ℝ) ^ 2 * x / N) : ℂ)

variable {χ} {c : ℕ → ℝ} {k : ℕ}

/-- **Step A.** The two-sided sum is `2 θ_χ(x)`. -/
theorem hasSum_thZ (hχc : ∀ n : ℕ, χ n = (c n : ℂ)) (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0)
    (hpar : χ (-1) = (-1) ^ k) {x : ℝ} (hx : 0 < x) :
    HasSum (thZ χ k x) (2 * (thetaC c k N x : ℂ)) := by
  have hq : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  have hsum : Summable fun n : ℕ ↦ c n * (n : ℝ) ^ k * rexp (-π * (n : ℝ) ^ 2 * x / N) :=
    Summable.of_norm_bounded (summable_bound (k := k) hq hx)
      (fun n ↦ norm_term_le hc hq hx le_rfl n)
  have hT : HasSum (fun n : ℕ ↦ ((c n * (n : ℝ) ^ k * rexp (-π * (n : ℝ) ^ 2 * x / N) : ℝ) : ℂ))
      (thetaC c k N x : ℂ) := by
    rw [hasSum_ofReal]; exact hsum.hasSum
  have h1 : HasSum (fun n : ℕ ↦ thZ χ k x n) (thetaC c k N x : ℂ) := by
    refine hT.congr_fun fun n ↦ ?_
    simp only [thZ, Int.cast_natCast, hχc]
    push_cast; ring
  have h2 : HasSum (fun n : ℕ ↦ thZ χ k x (-n)) (thetaC c k N x : ℂ) := by
    refine hT.congr_fun fun n ↦ ?_
    simp only [thZ, Int.cast_neg, Int.cast_natCast]
    rw [show (-(n : ZMod N)) = (-1) * (n : ZMod N) by ring, map_mul, hpar, hχc]
    push_cast
    have h11 : (-1 : ℂ) ^ k * (-1) ^ k = 1 := by rw [← mul_pow]; norm_num
    rw [neg_pow (n : ℂ), neg_sq]
    linear_combination (↑(c n) * (n : ℂ) ^ k * cexp (-↑π * ↑n ^ 2 * ↑x / ↑N)) * h11
  have h0 : thZ χ k x 0 = 0 := by
    have hχ0 : χ 0 = 0 := by
      have := hχc 0; rw [Nat.cast_zero] at this; rw [this, hc0]; simp
    simp [thZ, hχ0]
  have := h1.of_nat_of_neg h2
  rwa [h0, sub_zero, ← two_mul] at this

/-- **Step B.** Splitting a two-sided sum into residue classes mod `N`. -/
theorem hasSum_residue {f : ℤ → ℂ} {a : ℂ} (ha : HasSum f a) {g : Fin N → ℂ}
    (hg : ∀ j : Fin N, HasSum (fun m : ℤ ↦ f (m * N + j)) (g j)) : a = ∑ j, g j := by
  set e : Fin N × ℤ ≃ ℤ := (Equiv.prodComm (Fin N) ℤ).trans (Int.divModEquiv N).symm with he
  have h1 : HasSum (f ∘ e) a := e.hasSum_iff.mpr ha
  have h2 : HasSum g a := h1.prod_fiberwise fun j ↦ by
    simpa [he, Function.comp_def] using hg j
  exact h2.unique (hasSum_fintype g)

/-- `j ↦ (j : ZMod N)` is a bijection `Fin N → ZMod N`. -/
theorem bijective_fin_cast : Function.Bijective (fun j : Fin N ↦ ((j : ℕ) : ZMod N)) := by
  refine (Fintype.bijective_iff_injective_and_card _).mpr ⟨fun a b hab ↦ ?_, by simp⟩
  have h := congrArg ZMod.val hab
  simp only [ZMod.val_natCast, Nat.mod_eq_of_lt a.isLt, Nat.mod_eq_of_lt b.isLt] at h
  exact Fin.ext h

/-- **Gauss sum.** For primitive real `χ`: `Σ_j χ(j) e^{2πi j n/N} = χ(n) τ(χ)`. -/
theorem sum_char_exp (hprim : χ.IsPrimitive) (hinv : χ⁻¹ = χ) (n : ℤ) :
    ∑ j : Fin N, χ ((j : ℕ) : ZMod N) * cexp (2 * π * I * (((j : ℕ) : ℝ) / N : ℝ) * n) =
      χ n * gaussSum χ stdAddChar := by
  have h := hprim.fourierTransform_eq_inv_mul_gaussSum (-(n : ZMod N))
  rw [neg_neg, hinv] at h
  rw [← h, dft_apply]
  refine (Fintype.sum_bijective _ bijective_fin_cast _ _ fun j ↦ ?_)
  rw [smul_eq_mul, mul_comm]
  congr 1
  have : -(((j : ℕ) : ZMod N) * -(n : ZMod N)) = (((j : ℕ) * n : ℤ) : ZMod N) := by push_cast; ring
  rw [this, stdAddChar_coe]
  congr 1
  push_cast
  ring

/-- **Step C (even).** The residue class `j` of the two-sided sum is a Hurwitz even kernel. -/
theorem hasSum_fiber_even {x : ℝ} (hx : 0 < x) (j : Fin N) :
    HasSum (fun m : ℤ ↦ thZ χ 0 x (m * N + j))
      (χ ((j : ℕ) : ZMod N) * (evenKernel ((((j : ℕ) : ℝ) / N : ℝ)) (N * x) : ℂ)) := by
  have hN : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have h := hasSum_int_evenKernel (((j : ℕ) : ℝ) / N) (t := N * x) (by positivity)
  refine ((hasSum_ofReal.mpr h).mul_left (χ ((j : ℕ) : ZMod N))).congr_fun fun m ↦ ?_
  have hcast : (((m * N + ((j : ℕ) : ℤ) : ℤ)) : ZMod N) = ((j : ℕ) : ZMod N) := by
    push_cast; simp
  simp only [thZ, pow_zero, mul_one] at *
  rw [show ((m * (N : ℤ) + ((j : ℕ) : ℤ) : ℤ) : ZMod N) = ((j : ℕ) : ZMod N) from hcast]
  congr 3
  push_cast
  field_simp

/-- **Step C (odd).** -/
theorem hasSum_fiber_odd {x : ℝ} (hx : 0 < x) (j : Fin N) :
    HasSum (fun m : ℤ ↦ thZ χ 1 x (m * N + j))
      (χ ((j : ℕ) : ZMod N) * N * (oddKernel ((((j : ℕ) : ℝ) / N : ℝ)) (N * x) : ℂ)) := by
  have hN : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have h := hasSum_int_oddKernel (((j : ℕ) : ℝ) / N) (x := N * x) (by positivity)
  refine ((hasSum_ofReal.mpr h).mul_left (χ ((j : ℕ) : ZMod N) * N)).congr_fun fun m ↦ ?_
  have hcast : (((m * N + ((j : ℕ) : ℤ) : ℤ)) : ZMod N) = ((j : ℕ) : ZMod N) := by
    push_cast; simp
  simp only [thZ, pow_one, Int.cast_natCast] at *
  rw [show ((m * (N : ℤ) + ((j : ℕ) : ℤ) : ℤ) : ZMod N) = ((j : ℕ) : ZMod N) from hcast]
  push_cast
  have he : (-↑π * ((m : ℂ) + ((j : ℕ) : ℂ) / (N : ℂ)) ^ 2 * ((N : ℂ) * (x : ℂ))) =
      -↑π * ((m : ℂ) * N + ((j : ℕ) : ℂ)) ^ 2 * x / N := by
    have hNc : (N : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
    field_simp
  rw [he]
  have hNc : (N : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  field_simp

/-- **Step D (even).** -/
theorem sum_cosKernel (hprim : χ.IsPrimitive) (hinv : χ⁻¹ = χ) {t : ℝ} (ht : 0 < t) :
    HasSum (fun n : ℤ ↦ gaussSum χ stdAddChar * (χ n * (rexp (-π * (n : ℝ) ^ 2 * t) : ℂ)))
      (∑ j : Fin N, χ ((j : ℕ) : ZMod N) * (cosKernel ((((j : ℕ) : ℝ) / N : ℝ)) t : ℂ)) := by
  have h := hasSum_sum (s := Finset.univ) fun (j : Fin N) _ ↦
    (hasSum_int_cosKernel (((j : ℕ) : ℝ) / N) ht).mul_left (χ ((j : ℕ) : ZMod N))
  refine h.congr_fun fun n ↦ ?_
  rw [← mul_assoc, mul_comm (gaussSum χ stdAddChar), ← sum_char_exp hprim hinv n, Finset.sum_mul]
  refine Finset.sum_congr rfl fun j _ ↦ ?_
  ring

/-- **Step D (odd).** -/
theorem sum_sinKernel (hprim : χ.IsPrimitive) (hinv : χ⁻¹ = χ) {t : ℝ} (ht : 0 < t) :
    HasSum (fun n : ℤ ↦ -I * gaussSum χ stdAddChar * (χ n * n * (rexp (-π * (n : ℝ) ^ 2 * t) : ℂ)))
      (∑ j : Fin N, χ ((j : ℕ) : ZMod N) * (sinKernel ((((j : ℕ) : ℝ) / N : ℝ)) t : ℂ)) := by
  have h := hasSum_sum (s := Finset.univ) fun (j : Fin N) _ ↦
    (hasSum_int_sinKernel (((j : ℕ) : ℝ) / N) ht).mul_left (χ ((j : ℕ) : ZMod N))
  refine h.congr_fun fun n ↦ ?_
  have := sum_char_exp hprim hinv n
  symm
  calc ∑ j : Fin N, χ ((j : ℕ) : ZMod N) * (-I * n * cexp (2 * π * I * (((j : ℕ) : ℝ) / N : ℝ) * n) *
        (rexp (-π * (n : ℝ) ^ 2 * t) : ℂ))
      = (-I * n * (rexp (-π * (n : ℝ) ^ 2 * t) : ℂ)) * ∑ j : Fin N, χ ((j : ℕ) : ZMod N) *
          cexp (2 * π * I * (((j : ℕ) : ℝ) / N : ℝ) * n) := by
        rw [Finset.mul_sum]; refine Finset.sum_congr rfl fun j _ ↦ ?_; ring
    _ = _ := by rw [this]; ring

/-- **Theta FE (even `χ`).** `2θ(x) = (Nx)^{−1/2} τ(χ) · 2θ(1/x)`. -/
theorem theta_fe_even (hprim : χ.IsPrimitive) (hinv : χ⁻¹ = χ) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hev : χ.Even) {x : ℝ} (hx : 0 < x) :
    2 * (thetaC c 0 N x : ℂ) = ((1 / (N * x) ^ (1 / 2 : ℝ) : ℝ) : ℂ) *
      (gaussSum χ stdAddChar * (2 * (thetaC c 0 N (1 / x) : ℂ))) := by
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  have hpar : χ (-1) = (-1) ^ 0 := by rw [pow_zero]; exact hev
  have h1 := hasSum_residue (hasSum_thZ hχc hc hc0 hpar hx) (fun j ↦ hasSum_fiber_even hx j)
  rw [h1]
  have h2 : ∀ j : Fin N, χ ((j : ℕ) : ZMod N) *
      (evenKernel ((((j : ℕ) : ℝ) / N : ℝ)) (N * x) : ℂ) =
      ((1 / (N * x) ^ (1 / 2 : ℝ) : ℝ) : ℂ) *
        (χ ((j : ℕ) : ZMod N) * (cosKernel ((((j : ℕ) : ℝ) / N : ℝ)) (1 / (N * x)) : ℂ)) := by
    intro j; rw [evenKernel_functional_equation]; push_cast; ring
  rw [Finset.sum_congr rfl fun j _ ↦ h2 j, ← Finset.mul_sum]
  congr 1
  have hD := sum_cosKernel hprim hinv (t := 1 / (N * x)) (by positivity)
  have hA := (hasSum_thZ hχc hc hc0 hpar (x := 1 / x) (by positivity)).mul_left
    (gaussSum χ stdAddChar)
  refine hD.unique (hA.congr_fun fun n ↦ ?_)
  simp only [thZ, pow_zero, mul_one]
  congr 4
  field_simp

/-- **Theta FE (odd `χ`).** `2θ(x) = N (Nx)^{−3/2} (−i τ(χ)) · 2θ(1/x)`. -/
theorem theta_fe_odd (hprim : χ.IsPrimitive) (hinv : χ⁻¹ = χ) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hodd : χ.Odd) {x : ℝ} (hx : 0 < x) :
    2 * (thetaC c 1 N x : ℂ) = ((N / (N * x) ^ (3 / 2 : ℝ) : ℝ) : ℂ) *
      (-I * gaussSum χ stdAddChar * (2 * (thetaC c 1 N (1 / x) : ℂ))) := by
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  have hpar : χ (-1) = (-1) ^ 1 := by rw [pow_one]; exact hodd
  have h1 := hasSum_residue (hasSum_thZ hχc hc hc0 hpar hx) (fun j ↦ hasSum_fiber_odd hx j)
  rw [h1]
  have h2 : ∀ j : Fin N, χ ((j : ℕ) : ZMod N) * N *
      (oddKernel ((((j : ℕ) : ℝ) / N : ℝ)) (N * x) : ℂ) =
      ((N / (N * x) ^ (3 / 2 : ℝ) : ℝ) : ℂ) *
        (χ ((j : ℕ) : ZMod N) * (sinKernel ((((j : ℕ) : ℝ) / N : ℝ)) (1 / (N * x)) : ℂ)) := by
    intro j; rw [oddKernel_functional_equation]; push_cast; ring
  rw [Finset.sum_congr rfl fun j _ ↦ h2 j, ← Finset.mul_sum]
  congr 1
  have hD := sum_sinKernel hprim hinv (t := 1 / (N * x)) (by positivity)
  have hA := (hasSum_thZ hχc hc hc0 hpar (x := 1 / x) (by positivity)).mul_left
    (-I * gaussSum χ stdAddChar)
  refine hD.unique (hA.congr_fun fun n ↦ ?_)
  simp only [thZ, pow_one]
  congr 3
  field_simp

theorem natCast_cpow_half : (N : ℂ) ^ (1 / 2 : ℂ) = (((N : ℝ) ^ (1 / 2 : ℝ) : ℝ) : ℂ) := by
  rw [ofReal_cpow (Nat.cast_nonneg _)]; push_cast; rfl

open scoped Classical in
/-- **Theta FE with root number `1`:** `θ(1/x) = x^{(1+2k)/2} θ(x)`. -/
theorem theta_fe (hprim : χ.IsPrimitive) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hε : DirichletCharacter.rootNumber χ = 1)
    (hk : k = if χ.Even then 0 else 1) {x : ℝ} (hx : 0 < x) :
    thetaC c k N (1 / x) = x ^ (((1 : ℝ) + 2 * k) / 2) * thetaC c k N x := by
  classical
  have hinv := inv_eq_self_of_real hχc
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  have hNc : (N : ℂ) ^ (1 / 2 : ℂ) ≠ 0 := by
    rw [natCast_cpow_half]; exact_mod_cast (Real.rpow_pos_of_pos hNr _).ne'
  unfold DirichletCharacter.rootNumber at hε
  have hsN : (0 : ℝ) < (N : ℝ) ^ (1 / 2 : ℝ) := Real.rpow_pos_of_pos hNr _
  have hsx : (0 : ℝ) < x ^ (1 / 2 : ℝ) := Real.rpow_pos_of_pos hx _
  by_cases hev : χ.Even
  · rw [if_pos hev] at hε hk
    subst hk
    rw [pow_zero, div_one, div_eq_one_iff_eq hNc, natCast_cpow_half] at hε
    have h := theta_fe_even hprim hinv hχc hc hc0 hev hx
    rw [hε] at h
    have hR : 2 * thetaC c 0 N x = 1 / (N * x) ^ (1 / 2 : ℝ) *
        ((N : ℝ) ^ (1 / 2 : ℝ) * (2 * thetaC c 0 N (1 / x))) := by exact_mod_cast h
    rw [Real.mul_rpow hNr.le hx.le] at hR
    norm_num
    field_simp at hR ⊢
    linarith
  · rw [if_neg hev] at hε hk
    subst hk
    have hodd : χ.Odd := χ.even_or_odd.resolve_left hev
    rw [pow_one, div_div, div_eq_one_iff_eq (mul_ne_zero I_ne_zero hNc), natCast_cpow_half] at hε
    have h := theta_fe_odd hprim hinv hχc hc hc0 hodd hx
    rw [hε, show -I * (I * (((N : ℝ) ^ (1 / 2 : ℝ) : ℝ) : ℂ)) = (((N : ℝ) ^ (1 / 2 : ℝ) : ℝ) : ℂ) by
      rw [← mul_assoc, neg_mul, I_mul_I, neg_neg, one_mul]] at h
    have hR : 2 * thetaC c 1 N x = N / (N * x) ^ (3 / 2 : ℝ) *
        ((N : ℝ) ^ (1 / 2 : ℝ) * (2 * thetaC c 1 N (1 / x))) := by exact_mod_cast h
    have h32N : (N : ℝ) ^ (3 / 2 : ℝ) = N * (N : ℝ) ^ (1 / 2 : ℝ) := by
      rw [show (3 / 2 : ℝ) = 1 + 1 / 2 by norm_num, Real.rpow_add hNr, Real.rpow_one]
    have h32x : x ^ (3 / 2 : ℝ) = x * x ^ (1 / 2 : ℝ) := by
      rw [show (3 / 2 : ℝ) = 1 + 1 / 2 by norm_num, Real.rpow_add hx, Real.rpow_one]
    rw [Real.mul_rpow hNr.le hx.le, h32N, h32x] at hR
    norm_num
    rw [h32x]
    field_simp at hR ⊢
    linarith

open scoped Classical in
/-- **D2b′: root number `1` ⇒ `Φ_χ` is even.**  This discharges `heven`. -/
theorem PhiC_even_of_rootNumber (hprim : χ.IsPrimitive) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hε : DirichletCharacter.rootNumber χ = 1)
    (hk : k = if χ.Even then 0 else 1) (u : ℝ) : PhiC c k N (-u) = PhiC c k N u := by
  unfold PhiC
  have hX := Real.exp_pos (4 * u)
  rw [show Real.exp (4 * -u) = 1 / Real.exp (4 * u) by rw [mul_neg, Real.exp_neg, one_div],
    theta_fe hprim hχc hc hc0 hε hk hX, Real.rpow_def_of_pos hX, Real.log_exp, ← mul_assoc,
    ← Real.exp_add]
  congr 2
  ring

open scoped Classical in
/-- The parity weight `k(χ) = 0` (even) / `1` (odd). -/
noncomputable def parityK (χ : DirichletCharacter ℂ N) : ℕ := if χ.Even then 0 else 1

open scoped Classical in
/-- **The Dirichlet heat-flow family**, written out explicitly:
`H_t^χ(z) = ∫_0^∞ e^{tu²} Φ_χ(u) cos(zu) du`, `Φ_χ(u) = e^{(1+2k)u} θ_χ(e^{4u})`. -/
noncomputable def Hchi (χ : DirichletCharacter ℂ N) (t : ℝ) (z : ℂ) : ℂ :=
  ∫ u in Ioi (0 : ℝ), ((Real.exp (t * u ^ 2) : ℝ) : ℂ) *
    ((PhiC (fun n ↦ (χ n).re) (parityK χ) N u : ℝ) : ℂ) * Complex.cos (z * u)

open scoped Classical in
/-- **`Λ_χ ≤ 9/32` for a real primitive `χ` with root number `1`, conditional on the Dirichlet
`7/8` half-plane.**  Hypotheses: `χ` primitive, `χ ≠ 1`, real-valued, `rootNumber χ = 1`
(Gauss's sign theorem; not in Mathlib), and `hL`.  Conclusion: every zero of `H_t^χ` is real for
`t ≥ 9/32`. -/
theorem dirichlet_real_zeros_of_rootNumber (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) (hε : DirichletCharacter.rootNumber χ = 1)
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0) :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, Hchi χ t z = 0 → z.im = 0 := by
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
  have heven := PhiC_even_of_rootNumber hprim hχc hc hc0 hε hk
  intro t ht z hz
  exact dirichlet_real_zeros hprim hχ1 hχc hc hc0 hc1 hgam heven hL t ht z hz

end DBN.Gen
