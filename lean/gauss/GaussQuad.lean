import Mathlib
import GenThetaFE

/-! Gauss's sign theorem, stage S1: **the quadratic Gauss sum.**

`G(N) = Σ_{j < N} e^{2πi j²/N} = (1 + i)(1 + (−i)^N) √N / 2`   for every `N ≥ 1`.

Proof (analytic, via the Jacobi theta functional equation): put `τ_t = 2/N + it`, `t → 0⁺`.
* Left side: `θ(0, τ_t) = Σ_j e^{2πij²/N} evenKernel(j/N)(N²t)` EXACTLY (residue classes mod `N`),
  so `√t θ(0, τ_t) → G(N)/N`.
* Right side: `θ(0, τ_t) = (−iτ_t)^{−1/2} θ(0, −1/τ_t)`, and `−1/τ_t = −N/2 + δ + iv` with
  `δ = O(t²)`, `v ~ N²t/4`; the phase `e^{−πiNn²/2}` is `1` (n even) / `(−i)^N` (n odd), and the
  `δ`-error is `O(t)` after the `√t` normalisation; so `√t θ → (−2i/N)^{−1/2} (1 + (−i)^N)/N`.

conjecture1_proved = False. -/

open Real Complex Filter Topology HurwitzZeta

namespace DBN.Gen

/-- The quadratic Gauss sum `G(N) = Σ_{j < N} e^{2πi j²/N}`. -/
noncomputable def gaussG (N : ℕ) : ℂ := ∑ j : Fin N, cexp (2 * π * I * ((j : ℕ) : ℂ) ^ 2 / N)

/-- `cosKernel a y → 1` as `y → ∞`. -/
theorem tendsto_cosKernel (a : UnitAddCircle) : Tendsto (cosKernel a) atTop (𝓝 1) := by
  obtain ⟨p, hp, h⟩ := isBigO_atTop_cosKernel_sub a
  have h0 : Tendsto (fun x ↦ Real.exp (-p * x)) atTop (𝓝 0) := by
    have h1 := Real.tendsto_exp_neg_atTop_nhds_zero.comp (tendsto_id.const_mul_atTop hp)
    refine h1.congr fun x ↦ ?_
    simp [Function.comp, neg_mul]
  have := h.trans_tendsto h0
  simpa using this.add_const 1

/-- The even-kernel functional equation in `√` form. -/
theorem evenKernel_sqrt (a : UnitAddCircle) (x : ℝ) :
    evenKernel a x = 1 / Real.sqrt x * cosKernel a (1 / x) := by
  rw [evenKernel_functional_equation, Real.sqrt_eq_rpow]

/-- `θ` at `2/N + it` term: `e^{πi n² τ} = e^{2πi n²/N} e^{−πn²t}`. -/
theorem theta_term_split (N : ℕ) (t : ℝ) (n : ℤ) :
    jacobiTheta₂_term n 0 (2 / N + I * t) =
      cexp (2 * π * I * (n : ℂ) ^ 2 / N) * (Real.exp (-π * (n : ℝ) ^ 2 * t) : ℂ) := by
  rw [jacobiTheta₂_term, ofReal_exp, ← Complex.exp_add]
  congr 1
  push_cast
  ring_nf
  rw [I_sq]
  ring

/-- Periodicity of `e^{2πi n²/N}` in `n` mod `N`. -/
theorem exp_sq_periodic (N : ℕ) [NeZero N] (m j : ℤ) :
    cexp (2 * π * I * ((m * N + j : ℤ) : ℂ) ^ 2 / N) = cexp (2 * π * I * (j : ℂ) ^ 2 / N) := by
  have hN : (N : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have : 2 * π * I * ((m * N + j : ℤ) : ℂ) ^ 2 / N =
      2 * π * I * (j : ℂ) ^ 2 / N + ((m ^ 2 * N + 2 * m * j : ℤ) : ℂ) * (2 * π * I) := by
    push_cast; field_simp; ring
  rw [this, Complex.exp_add, exp_int_mul_two_pi_mul_I, mul_one]

/-- **LHS, exact.** `θ(0, 2/N + it) = Σ_j e^{2πij²/N} evenKernel(j/N)(N² t)`. -/
theorem theta_lhs (N : ℕ) [NeZero N] {t : ℝ} (ht : 0 < t) :
    jacobiTheta₂ 0 (2 / N + I * t) = ∑ j : Fin N, cexp (2 * π * I * ((j : ℕ) : ℂ) ^ 2 / N) *
      (evenKernel ((((j : ℕ) : ℝ) / N : ℝ)) ((N : ℝ) ^ 2 * t) : ℂ) := by
  have hNr : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have hτ : 0 < (2 / (N : ℂ) + I * t).im := by simpa using ht
  refine hasSum_residue (hasSum_jacobiTheta₂_term 0 hτ) fun j ↦ ?_
  have h := hasSum_int_evenKernel (((j : ℕ) : ℝ) / N) (t := (N : ℝ) ^ 2 * t) (by positivity)
  refine ((hasSum_ofReal.mpr h).mul_left (cexp (2 * π * I * ((j : ℕ) : ℂ) ^ 2 / N))).congr_fun
    fun m ↦ ?_
  rw [theta_term_split]
  have hj := exp_sq_periodic N m ((j : ℕ) : ℤ)
  push_cast at hj ⊢
  rw [hj]
  have hNc : (N : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  congr 2
  first | (field_simp; ring) | field_simp

/-- `c/t → ∞` as `t → 0⁺` for `c > 0`. -/
theorem tendsto_const_div_nhdsGT {c : ℝ} (hc : 0 < c) :
    Tendsto (fun t : ℝ ↦ c / t) (𝓝[>] 0) atTop := by
  refine (tendsto_inv_nhdsGT_zero.const_mul_atTop hc).congr fun t ↦ ?_
  rw [div_eq_mul_inv]

/-- **LHS limit.** `√t θ(0, 2/N + it) → G(N)/N` as `t → 0⁺`. -/
theorem lhs_tendsto (N : ℕ) [NeZero N] :
    Tendsto (fun t : ℝ ↦ (Real.sqrt t : ℂ) * jacobiTheta₂ 0 (2 / N + I * t)) (𝓝[>] 0)
      (𝓝 (gaussG N / N)) := by
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  set c : Fin N → ℂ := fun j ↦ cexp (2 * π * I * ((j : ℕ) : ℂ) ^ 2 / N) with hc
  have key : ∀ t : ℝ, 0 < t → (Real.sqrt t : ℂ) * jacobiTheta₂ 0 (2 / N + I * t) =
      ∑ j : Fin N, c j * ((1 / N : ℂ) *
        (cosKernel ((((j : ℕ) : ℝ) / N : ℝ)) (1 / ((N : ℝ) ^ 2 * t)) : ℂ)) := by
    intro t ht
    rw [theta_lhs N ht, Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ ↦ ?_
    rw [evenKernel_sqrt]
    have hs : Real.sqrt ((N : ℝ) ^ 2 * t) = N * Real.sqrt t := by
      rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hNr.le]
    have hst : 0 < Real.sqrt t := Real.sqrt_pos.mpr ht
    rw [hs]
    push_cast
    have : (Real.sqrt t : ℂ) ≠ 0 := by exact_mod_cast hst.ne'
    have hNc : (N : ℂ) ≠ 0 := by exact_mod_cast hNr.ne'
    field_simp
    simp only [hc]
    ring
  have hlim : Tendsto (fun t : ℝ ↦ ∑ j : Fin N, c j * ((1 / N : ℂ) *
      (cosKernel ((((j : ℕ) : ℝ) / N : ℝ)) (1 / ((N : ℝ) ^ 2 * t)) : ℂ))) (𝓝[>] 0)
      (𝓝 (∑ j : Fin N, c j * ((1 / N : ℂ) * ((1 : ℝ) : ℂ)))) := by
    refine tendsto_finsetSum _ fun j _ ↦ tendsto_const_nhds.mul (tendsto_const_nhds.mul ?_)
    have hinv : Tendsto (fun t : ℝ ↦ 1 / ((N : ℝ) ^ 2 * t)) (𝓝[>] 0) atTop := by
      refine (tendsto_const_div_nhdsGT (c := 1 / (N : ℝ) ^ 2) (by positivity)).congr fun t ↦ ?_
      rw [div_div]
    exact (continuous_ofReal.tendsto _).comp ((tendsto_cosKernel _).comp hinv)
  have hval : ∑ j : Fin N, c j * ((1 / N : ℂ) * ((1 : ℝ) : ℂ)) = gaussG N / N := by
    simp only [ofReal_one, mul_one, gaussG, Finset.sum_div, hc]
    refine Finset.sum_congr rfl fun j _ ↦ ?_
    ring
  rw [← hval]
  refine hlim.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with t ht
  exact (key t ht).symm

/-- The phase `s(n) = e^{−πi N n²/2}`. -/
noncomputable def cuspPhase (N : ℕ) (n : ℤ) : ℂ := cexp (-π * I * N * (n : ℂ) ^ 2 / 2)

theorem cuspPhase_periodic (N : ℕ) (m j : ℤ) : cuspPhase N (m * 2 + j) = cuspPhase N j := by
  unfold cuspPhase
  have : -π * I * N * (((m * 2 + j : ℤ)) : ℂ) ^ 2 / 2 =
      -π * I * N * (j : ℂ) ^ 2 / 2 + ((-(N : ℤ) * (m ^ 2 + m * j) : ℤ) : ℂ) * (2 * π * I) := by
    push_cast; ring
  rw [this, Complex.exp_add, exp_int_mul_two_pi_mul_I, mul_one]

theorem norm_cuspPhase (N : ℕ) (n : ℤ) : ‖cuspPhase N n‖ = 1 := by
  have h : cuspPhase N n = cexp (((-π * N * (n : ℝ) ^ 2 / 2 : ℝ) : ℂ) * I) := by
    unfold cuspPhase; congr 1; push_cast; ring
  rw [h, Complex.norm_exp_ofReal_mul_I]

theorem cuspPhase_zero (N : ℕ) : cuspPhase N 0 = 1 := by simp [cuspPhase]

theorem cuspPhase_one (N : ℕ) : cuspPhase N 1 = (-I) ^ N := by
  unfold cuspPhase
  have h : cexp (-(π / 2 * I)) = -I := by
    rw [Complex.exp_neg, exp_pi_div_two_mul_I, inv_I]
  rw [← h, ← Complex.exp_nat_mul]
  congr 1
  push_cast
  ring

/-- `y e^{−y} ≤ 2 e^{−y/2}` for `y ≥ 0`. -/
theorem mul_exp_neg_le (y : ℝ) : y * Real.exp (-y) ≤ 2 * Real.exp (-(y / 2)) := by
  have h1 := Real.add_one_le_exp (y / 2)
  have h2 : Real.exp (-y) = Real.exp (-(y / 2)) * Real.exp (-(y / 2)) := by
    rw [← Real.exp_add]; ring_nf
  have h3 := Real.exp_pos (-(y / 2))
  have h4 : Real.exp (y / 2) * Real.exp (-(y / 2)) = 1 := by
    rw [← Real.exp_add]; simp
  rw [h2]
  nlinarith [mul_le_mul_of_nonneg_right h1 h3.le]

/-- **The theta function near the cusp `−N/2`.**  For `δ ≥ 0`, `v > 0`:
`‖θ(0, −N/2 + δ + iv) − Σ_{j<2} s(j) evenKernel(j/2)(4v)‖ ≤ (2δ/v) evenKernel(0)(v/2)`. -/
theorem theta_near_cusp (N : ℕ) {δ v : ℝ} (hδ : 0 ≤ δ) (hv : 0 < v) :
    ‖jacobiTheta₂ 0 (((-(N : ℝ) / 2 + δ : ℝ) : ℂ) + I * v) -
      ∑ j : Fin 2, cuspPhase N ((j : ℕ) : ℤ) * (evenKernel ((((j : ℕ) : ℝ) / 2 : ℝ)) (4 * v) : ℂ)‖
      ≤ 2 * δ / v * evenKernel ((0 : ℝ)) (v / 2) := by
  set w : ℂ := ((-(N : ℝ) / 2 + δ : ℝ) : ℂ) + I * v with hw
  have hwim : 0 < w.im := by simpa [hw] using hv
  have hT := hasSum_jacobiTheta₂_term 0 hwim
  set B : ℤ → ℂ := fun n ↦ cuspPhase N n * (Real.exp (-π * (n : ℝ) ^ 2 * v) : ℂ) with hB
  have hK := hasSum_int_evenKernel (0 : ℝ) (t := v) hv
  have hBs : Summable B := by
    refine Summable.of_norm_bounded hK.summable fun n ↦ ?_
    rw [hB, norm_mul, norm_cuspPhase, one_mul, norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]
    simp
  have hA : ∑' n, B n = ∑ j : Fin 2,
      cuspPhase N ((j : ℕ) : ℤ) * (evenKernel ((((j : ℕ) : ℝ) / 2 : ℝ)) (4 * v) : ℂ) := by
    refine hasSum_residue hBs.hasSum fun j ↦ ?_
    have h := hasSum_int_evenKernel (((j : ℕ) : ℝ) / 2) (t := 4 * v) (by positivity)
    refine ((hasSum_ofReal.mpr h).mul_left (cuspPhase N ((j : ℕ) : ℤ))).congr_fun fun m ↦ ?_
    simp only [hB]
    rw [show ((m * ((2 : ℕ) : ℤ) + ((j : ℕ) : ℤ)) : ℤ) = m * 2 + ((j : ℕ) : ℤ) by push_cast; ring,
      cuspPhase_periodic]
    congr 2
    push_cast
    ring
  rw [← hA]
  have hdiff := hT.sub hBs.hasSum
  have hbound : HasSum (fun n : ℤ ↦ 2 * δ / v * Real.exp (-π * (n + 0 : ℝ) ^ 2 * (v / 2)))
      (2 * δ / v * evenKernel ((0 : ℝ)) (v / 2)) :=
    (hasSum_int_evenKernel (0 : ℝ) (t := v / 2) (by positivity)).mul_left _
  refine hdiff.norm_le_of_bounded hbound fun n ↦ ?_
  have hterm : jacobiTheta₂_term n 0 w =
      cuspPhase N n * cexp (I * ((π * (n : ℝ) ^ 2 * δ : ℝ) : ℂ)) *
        (Real.exp (-π * (n : ℝ) ^ 2 * v) : ℂ) := by
    rw [jacobiTheta₂_term, cuspPhase, ofReal_exp, ← Complex.exp_add, ← Complex.exp_add, hw]
    congr 1
    push_cast
    ring_nf
    rw [I_sq]
    ring
  rw [hterm, hB]
  simp only
  rw [show cuspPhase N n * cexp (I * ((π * (n : ℝ) ^ 2 * δ : ℝ) : ℂ)) *
      (Real.exp (-π * (n : ℝ) ^ 2 * v) : ℂ) - cuspPhase N n * (Real.exp (-π * (n : ℝ) ^ 2 * v) : ℂ)
      = cuspPhase N n * (Real.exp (-π * (n : ℝ) ^ 2 * v) : ℂ) *
        (cexp (I * ((π * (n : ℝ) ^ 2 * δ : ℝ) : ℂ)) - 1) by ring]
  rw [norm_mul, norm_mul, norm_cuspPhase, one_mul, norm_real,
    Real.norm_of_nonneg (Real.exp_pos _).le]
  have hE := norm_exp_I_mul_ofReal_sub_one_le (x := π * (n : ℝ) ^ 2 * δ)
  rw [Real.norm_of_nonneg (by positivity)] at hE
  have hy := mul_exp_neg_le (π * (n : ℝ) ^ 2 * v)
  have hexp := Real.exp_pos (-π * (n : ℝ) ^ 2 * v)
  calc Real.exp (-π * (n : ℝ) ^ 2 * v) * ‖cexp (I * ((π * (n : ℝ) ^ 2 * δ : ℝ) : ℂ)) - 1‖
      ≤ Real.exp (-π * (n : ℝ) ^ 2 * v) * (π * (n : ℝ) ^ 2 * δ) :=
        mul_le_mul_of_nonneg_left hE hexp.le
    _ = δ / v * ((π * (n : ℝ) ^ 2 * v) * Real.exp (-(π * (n : ℝ) ^ 2 * v))) := by
        rw [show -π * (n : ℝ) ^ 2 * v = -(π * (n : ℝ) ^ 2 * v) by ring]
        field_simp
    _ ≤ δ / v * (2 * Real.exp (-(π * (n : ℝ) ^ 2 * v / 2))) :=
        mul_le_mul_of_nonneg_left hy (by positivity)
    _ = 2 * δ / v * Real.exp (-π * (n + 0 : ℝ) ^ 2 * (v / 2)) := by
        rw [add_zero]; ring_nf

/-- `D(t) = 4/N² + t²`, `v = t/D`, `δ = N t²/(2D)`. -/
noncomputable def cD (N : ℕ) (t : ℝ) : ℝ := 4 / (N : ℝ) ^ 2 + t ^ 2

theorem cD_pos (N : ℕ) [NeZero N] (t : ℝ) : 0 < cD N t := by
  have : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  unfold cD; positivity

/-- `−1/(2/N + it) = (−N/2 + δ) + iv`. -/
theorem neg_inv_tau (N : ℕ) [NeZero N] (t : ℝ) :
    -1 / (2 / (N : ℂ) + I * t) =
      ((-(N : ℝ) / 2 + N * t ^ 2 / (2 * cD N t) : ℝ) : ℂ) + I * ((t / cD N t : ℝ) : ℂ) := by
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  have hD := cD_pos N t
  have hτ : (2 / (N : ℂ) + I * t) ≠ 0 := by
    intro h
    have h2 : (2 / (N : ℂ) + I * t).re = 2 / N := by simp
    rw [h, zero_re] at h2
    exact absurd h2.symm (div_pos two_pos hNr).ne'
  set x : ℝ := -(N : ℝ) / 2 + N * t ^ 2 / (2 * cD N t) with hx
  set y : ℝ := t / cD N t with hy
  have e1 : x * (2 / N) - y * t = -1 := by
    simp only [hx, hy, cD]; field_simp; ring
  have e2 : x * t + y * (2 / N) = 0 := by
    simp only [hx, hy, cD]; field_simp; ring
  rw [div_eq_iff hτ, show (2 / (N : ℂ)) = ((2 / N : ℝ) : ℂ) by push_cast; rfl]
  apply Complex.ext
  · simp; linarith
  · simp; linarith

/-- **RHS limit.** `√t θ(0, 2/N + it) → (−2i/N)^{−1/2} (1 + (−i)^N)/N`. -/
theorem rhs_tendsto (N : ℕ) [NeZero N] :
    Tendsto (fun t : ℝ ↦ (Real.sqrt t : ℂ) * jacobiTheta₂ 0 (2 / N + I * t)) (𝓝[>] 0)
      (𝓝 (1 / (-I * (2 / N)) ^ (1 / 2 : ℂ) * ((1 + (-I) ^ N) / N + 0))) := by
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  set M : ℝ → ℂ := fun t ↦ ∑ j : Fin 2, cuspPhase N ((j : ℕ) : ℤ) *
    (evenKernel ((((j : ℕ) : ℝ) / 2 : ℝ)) (4 * (t / cD N t)) : ℂ) with hM
  set P : ℝ → ℂ := fun t ↦ 1 / (-I * (2 / N + I * t)) ^ (1 / 2 : ℂ) with hP
  -- decomposition for t > 0
  have key : ∀ t : ℝ, 0 < t → (Real.sqrt t : ℂ) * jacobiTheta₂ 0 (2 / N + I * t) =
      P t * ((Real.sqrt t : ℂ) * M t +
        (Real.sqrt t : ℂ) * (jacobiTheta₂ 0 (-1 / (2 / N + I * t)) - M t)) := by
    intro t ht
    rw [jacobiTheta₂_functional_equation 0 (2 / N + I * t)]
    simp only [hP, zero_div, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, mul_zero,
      Complex.exp_zero, mul_one]
    ring
  -- (P) prefactor
  have hPlim : Tendsto P (𝓝[>] 0) (𝓝 (1 / (-I * (2 / N)) ^ (1 / 2 : ℂ))) := by
    have hslit : -I * (2 / (N : ℂ)) ∈ slitPlane := by
      rw [mem_slitPlane_iff]; right
      intro h; simp at h; exact (NeZero.ne N) h
    have hne : (-I * (2 / (N : ℂ))) ^ (1 / 2 : ℂ) ≠ 0 := by
      rw [Ne, cpow_eq_zero_iff]; push Not; intro h; exfalso
      simp at h; exact (NeZero.ne N) h
    have hc : ContinuousAt (fun t : ℝ ↦ -I * (2 / (N : ℂ) + I * t)) 0 := by fun_prop
    have hcp : ContinuousAt (fun z : ℂ ↦ z ^ (1 / 2 : ℂ)) (-I * (2 / (N : ℂ) + I * ((0 : ℝ) : ℂ))) :=
      continuousAt_cpow_const (by simpa using hslit)
    have h1 := ContinuousAt.comp (x := (0 : ℝ)) hcp hc
    have h2 := (continuousAt_const (y := (1 : ℂ))).div h1 (by simpa using hne)
    have h3 := h2.tendsto.mono_left (nhdsWithin_le_nhds (s := Set.Ioi (0 : ℝ)))
    convert h3 using 1
    · funext t; simp [hP, Function.comp_def]
    · simp
  -- (M) main term
  have hD0 : Tendsto (fun t : ℝ ↦ Real.sqrt (cD N t) / 2) (𝓝[>] 0) (𝓝 (1 / N)) := by
    have hc : Continuous (fun t : ℝ ↦ Real.sqrt (cD N t) / 2) := by unfold cD; fun_prop
    have := (hc.tendsto 0).mono_left (nhdsWithin_le_nhds (s := Set.Ioi (0 : ℝ)))
    convert this using 2
    simp only [cD]
    rw [show (4 : ℝ) / (N : ℝ) ^ 2 + 0 ^ 2 = (2 / N) ^ 2 by ring, Real.sqrt_sq (by positivity)]
    ring
  have hinv4 : Tendsto (fun t : ℝ ↦ 1 / (4 * (t / cD N t))) (𝓝[>] 0) atTop := by
    refine tendsto_atTop_mono' _ ?_ (tendsto_const_div_nhdsGT (c := 1 / (N : ℝ) ^ 2)
      (by positivity))
    filter_upwards [self_mem_nhdsWithin] with t ht
    have hD := cD_pos N t
    have ht' : (0 : ℝ) < t := ht
    rw [div_le_div_iff₀ ht' (by positivity)]
    simp only [cD]
    field_simp
    nlinarith [sq_nonneg t]
  have hMlim : Tendsto (fun t : ℝ ↦ (Real.sqrt t : ℂ) * M t) (𝓝[>] 0)
      (𝓝 ((1 + (-I) ^ N) / N)) := by
    have hterm : ∀ j : Fin 2, Tendsto (fun t : ℝ ↦ cuspPhase N ((j : ℕ) : ℤ) *
        (((Real.sqrt (cD N t) / 2 : ℝ) : ℂ) *
          (cosKernel ((((j : ℕ) : ℝ) / 2 : ℝ)) (1 / (4 * (t / cD N t))) : ℂ))) (𝓝[>] 0)
        (𝓝 (cuspPhase N ((j : ℕ) : ℤ) * (((1 / N : ℝ) : ℂ) * ((1 : ℝ) : ℂ)))) :=
      fun j ↦ tendsto_const_nhds.mul (((continuous_ofReal.tendsto _).comp hD0).mul
        ((continuous_ofReal.tendsto _).comp ((tendsto_cosKernel _).comp hinv4)))
    have hsum := tendsto_finsetSum (s := Finset.univ) fun j _ ↦ hterm j
    have hval : ∑ j : Fin 2, cuspPhase N ((j : ℕ) : ℤ) * (((1 / N : ℝ) : ℂ) * ((1 : ℝ) : ℂ)) =
        (1 + (-I) ^ N) / N := by
      rw [Fin.sum_univ_two]
      simp only [Fin.val_zero, Fin.val_one, Nat.cast_zero, Nat.cast_one, cuspPhase_zero,
        cuspPhase_one]
      push_cast; ring
    rw [hval] at hsum
    refine hsum.congr' ?_
    filter_upwards [self_mem_nhdsWithin] with t ht
    have ht' : (0 : ℝ) < t := ht
    have hD := cD_pos N t
    simp only [hM, Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ ↦ ?_
    rw [evenKernel_sqrt]
    have hs : Real.sqrt (4 * (t / cD N t)) = 2 * Real.sqrt t / Real.sqrt (cD N t) := by
      rw [Real.sqrt_mul (by norm_num), Real.sqrt_div ht'.le,
        show Real.sqrt 4 = 2 by rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]]
      ring
    rw [hs]
    have h1 : 0 < Real.sqrt t := Real.sqrt_pos.mpr ht'
    have h2 : 0 < Real.sqrt (cD N t) := Real.sqrt_pos.mpr hD
    push_cast
    have h1c : (Real.sqrt t : ℂ) ≠ 0 := by exact_mod_cast h1.ne'
    have h2c : (Real.sqrt (cD N t) : ℂ) ≠ 0 := by exact_mod_cast h2.ne'
    field_simp
  -- (E) error term
  have hElim : Tendsto (fun t : ℝ ↦
      (Real.sqrt t : ℂ) * (jacobiTheta₂ 0 (-1 / (2 / N + I * t)) - M t)) (𝓝[>] 0) (𝓝 0) := by
    set bnd : ℝ → ℝ := fun t ↦ N * t * Real.sqrt (2 * cD N t) *
      cosKernel ((0 : ℝ)) (1 / ((t / cD N t) / 2)) with hbnd
    have hinv2 : Tendsto (fun t : ℝ ↦ 1 / ((t / cD N t) / 2)) (𝓝[>] 0) atTop := by
      refine tendsto_atTop_mono' _ ?_ hinv4
      filter_upwards [self_mem_nhdsWithin] with t ht
      have ht' : (0 : ℝ) < t := ht
      have hD := cD_pos N t
      rw [div_le_div_iff₀ (by positivity) (by positivity)]
      nlinarith [div_pos ht' hD]
    have hb : Tendsto bnd (𝓝[>] 0) (𝓝 (N * 0 * Real.sqrt (2 * cD N 0) * 1)) := by
      have hc : Continuous (fun t : ℝ ↦ N * t * Real.sqrt (2 * cD N t)) := by unfold cD; fun_prop
      exact ((hc.tendsto 0).mono_left (nhdsWithin_le_nhds (s := Set.Ioi (0 : ℝ)))).mul ((tendsto_cosKernel _).comp hinv2)
    rw [mul_zero, zero_mul, zero_mul] at hb
    refine squeeze_zero_norm' ?_ hb
    filter_upwards [self_mem_nhdsWithin] with t ht
    have ht' : (0 : ℝ) < t := ht
    have hD := cD_pos N t
    have hv : 0 < t / cD N t := div_pos ht' hD
    have hδ : 0 ≤ (N : ℝ) * t ^ 2 / (2 * cD N t) := by positivity
    have hcusp := theta_near_cusp N hδ hv
    rw [← neg_inv_tau N t] at hcusp
    rw [norm_mul, norm_real, Real.norm_of_nonneg (Real.sqrt_nonneg _)]
    calc Real.sqrt t * ‖jacobiTheta₂ 0 (-1 / (2 / N + I * t)) - M t‖
        ≤ Real.sqrt t * (2 * ((N : ℝ) * t ^ 2 / (2 * cD N t)) / (t / cD N t) *
            evenKernel ((0 : ℝ)) ((t / cD N t) / 2)) :=
          mul_le_mul_of_nonneg_left hcusp (Real.sqrt_nonneg _)
      _ = bnd t := by
          rw [evenKernel_sqrt]
          have h1 : 0 < Real.sqrt t := Real.sqrt_pos.mpr ht'
          have h2 : 0 < Real.sqrt (2 * cD N t) := Real.sqrt_pos.mpr (by positivity)
          have hs : Real.sqrt ((t / cD N t) / 2) = Real.sqrt t / Real.sqrt (2 * cD N t) := by
            rw [div_div, Real.sqrt_div ht'.le, mul_comm]
          rw [hs, hbnd]
          simp only
          first | (field_simp; ring) | field_simp
  have hall := hPlim.mul (hMlim.add hElim)
  refine hall.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with t ht
  exact (key t ht).symm

/-- `(−2i/N)^{−1/2} = (1 + i)√N / 2`. -/
theorem inv_sqrt_neg_two_I_div (N : ℕ) [NeZero N] :
    1 / (-I * (2 / (N : ℂ))) ^ (1 / 2 : ℂ) = (1 + I) / 2 * (Real.sqrt N : ℂ) := by
  have hNr : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hNr
  have hsc : (Real.sqrt N : ℂ) ≠ 0 := by exact_mod_cast hs.ne'
  have hsq : (Real.sqrt N : ℂ) ^ 2 = N := by exact_mod_cast Real.sq_sqrt hNr.le
  set x : ℂ := (1 - I) / (Real.sqrt N : ℂ) with hx
  have hx2 : x ^ 2 = -I * (2 / (N : ℂ)) := by
    rw [hx, div_pow, hsq]
    have hNc : (N : ℂ) ≠ 0 := by exact_mod_cast hNr.ne'
    field_simp
    ring_nf
    rw [I_sq]
    ring
  have hre : 0 < x.re := by
    have : x = ((1 / Real.sqrt N : ℝ) : ℂ) - I * ((1 / Real.sqrt N : ℝ) : ℂ) := by
      rw [hx]; push_cast; field_simp
    rw [this]; simp; positivity
  have harg : |x.arg| < π / 2 := Complex.abs_arg_lt_pi_div_two_iff.mpr (Or.inl hre)
  have hroot : (-I * (2 / (N : ℂ))) ^ (1 / 2 : ℂ) = x := by
    rw [← hx2, show (1 / 2 : ℂ) = ((2 : ℕ) : ℂ)⁻¹ by norm_num]
    exact pow_cpow_nat_inv (by norm_num) (by push_cast; linarith [(abs_lt.mp harg).1])
      (by push_cast; linarith [(abs_lt.mp harg).2])
  rw [hroot, hx]
  have h2 : (1 - I) * (1 + I) = 2 := by ring_nf; rw [I_sq]; ring
  have h1I : (1 - I) ≠ 0 := by
    intro h; have := congrArg Complex.re h; simp at this
  rw [one_div_div, div_eq_iff h1I]
  linear_combination (-(Real.sqrt N : ℂ) / 2) * h2

/-- **Stage S1: the quadratic Gauss sum.**  `G(N) = (1 + i)(1 + (−i)^N) √N / 2`. -/
theorem gaussG_eq (N : ℕ) [NeZero N] :
    gaussG N = (1 + I) * (1 + (-I) ^ N) / 2 * (Real.sqrt N : ℂ) := by
  have hNc : (N : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have h := tendsto_nhds_unique (lhs_tendsto N) (rhs_tendsto N)
  rw [inv_sqrt_neg_two_I_div, add_zero] at h
  field_simp at h
  linear_combination (1 / 2 : ℂ) * h

end DBN.Gen
