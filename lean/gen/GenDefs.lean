import Mathlib
import GenFourier

/-! Generic dBN island, part 1: **the heat flow of an abstract kernel.**

A `Kernel` is an even continuous `Φ : ℝ → ℝ`, not identically zero, with the decay template of
the Riemann kernel, `|Φ(u)| ≤ C e^{9u} exp(−(π/2) e^{4u})` for `u ≥ 0`.  `H K t z =
∫_0^∞ e^{tu²} Φ(u) cos(zu) du`.  Everything below is the Arda dBN island (`DBNDefs`,
qrh-debruijn-newman afd94c7) with `Φ` abstracted; proofs are carried over mechanically.
Other decay rates reduce to this template by rescaling `u` (see the Dirichlet instance).
conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology

namespace DBN.Gen

/-- An abstract de Bruijn–Newman kernel. -/
structure Kernel where
  Φ : ℝ → ℝ
  cont : Continuous Φ
  even : ∀ u, Φ (-u) = Φ u
  C : ℝ
  C_nonneg : 0 ≤ C
  bound : ∀ {u : ℝ}, 0 ≤ u → |Φ u| ≤ C * (Real.exp (9 * u) * Real.exp (-(π / 2) * Real.exp (4 * u)))
  ne : ∃ u, Φ u ≠ 0

variable {K : Kernel}

attribute [fun_prop] Kernel.cont

/-! ### Integrability of the heat-flow integrand -/

/-- `exp(a u² + b u) · exp(−(π/2) e^{4u})` is integrable on `(0, ∞)` for every `a, b`
(the double-exponential factor beats any Gaussian growth). -/
lemma integrableOn_exp_quad_mul_exp_neg_exp (a b : ℝ) :
    IntegrableOn (fun u : ℝ ↦ Real.exp (a * u ^ 2 + b * u) * Real.exp (-(π / 2) * Real.exp (4 * u)))
      (Ioi 0) := by
  apply integrable_of_isBigO_exp_neg (b := 1) one_pos
  · exact Continuous.continuousOn (by fun_prop)
  · have hfun : (fun u : ℝ ↦ Real.exp (a * u ^ 2 + b * u) * Real.exp (-(π / 2) * Real.exp (4 * u)))
        = fun u ↦ Real.exp (a * u ^ 2 + b * u + -(π / 2) * Real.exp (4 * u)) := by
      funext u; rw [← Real.exp_add]
    rw [hfun]
    apply Real.isBigO_exp_comp_exp_comp.mpr
    apply Filter.Tendsto.isBoundedUnder_le_atBot
    have hfact : ((fun u : ℝ ↦ a * u ^ 2 + b * u + -(π / 2) * Real.exp (4 * u)) - fun u ↦ -1 * u)
        = fun u ↦ Real.exp (4 * u) *
            (a * (u ^ 2 * Real.exp (-(4 * u))) + (b + 1) * (u * Real.exp (-(4 * u))) - π / 2) := by
      funext u
      simp only [Pi.sub_apply]
      rw [Real.exp_neg]
      field_simp
      ring
    rw [hfact]
    have h4 : Tendsto (fun u : ℝ ↦ 4 * u) atTop atTop := tendsto_id.const_mul_atTop (by norm_num)
    apply Filter.Tendsto.atTop_mul_neg (by linarith [Real.pi_pos] : -(π / 2) < 0)
    · exact Real.tendsto_exp_atTop.comp h4
    · have h2 : Tendsto (fun u : ℝ ↦ u ^ 2 * Real.exp (-(4 * u))) atTop (𝓝 0) := by
        have := ((Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 2).comp h4).const_mul (1 / 16)
        rw [mul_zero] at this
        refine this.congr fun u ↦ ?_
        simp only [Function.comp]
        ring
      have h1 : Tendsto (fun u : ℝ ↦ u * Real.exp (-(4 * u))) atTop (𝓝 0) := by
        have := ((Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1).comp h4).const_mul (1 / 4)
        rw [mul_zero] at this
        refine this.congr fun u ↦ ?_
        simp only [Function.comp]
        ring
      have := ((h2.const_mul a).add (h1.const_mul (b + 1))).sub_const (π / 2)
      simpa using this

/-- `‖cos w‖ ≤ exp ‖w‖` for complex `w`. -/
lemma norm_cos_le_exp_norm (w : ℂ) : ‖Complex.cos w‖ ≤ Real.exp ‖w‖ := by
  have him := Complex.abs_im_le_norm w
  have h1 : ‖Complex.exp (w * Complex.I)‖ ≤ Real.exp ‖w‖ := by
    rw [Complex.norm_exp]
    apply Real.exp_le_exp.mpr
    simp only [Complex.mul_re, Complex.I_re, mul_zero, Complex.I_im, mul_one, zero_sub]
    linarith [neg_abs_le w.im]
  have h2 : ‖Complex.exp (-w * Complex.I)‖ ≤ Real.exp ‖w‖ := by
    rw [Complex.norm_exp]
    apply Real.exp_le_exp.mpr
    simp only [Complex.mul_re, Complex.neg_re, Complex.I_re, mul_zero, Complex.neg_im, Complex.I_im,
      mul_one, zero_sub, neg_neg]
    linarith [le_abs_self w.im]
  calc ‖Complex.cos w‖ = ‖(Complex.exp (w * Complex.I) + Complex.exp (-w * Complex.I)) / 2‖ := rfl
    _ = ‖Complex.exp (w * Complex.I) + Complex.exp (-w * Complex.I)‖ / 2 := by
        rw [norm_div, Complex.norm_two]
    _ ≤ (Real.exp ‖w‖ + Real.exp ‖w‖) / 2 := by
        gcongr
        exact (norm_add_le _ _).trans (add_le_add h1 h2)
    _ = Real.exp ‖w‖ := by ring

/-! ### The heat-flow family `H_t` -/

variable (K) in
/-- The `H_t` integrand `e^{t u²} K.Φ(u) cos(z u)` (Polymath15 / Rodgers-Tao convention). -/
noncomputable def HIntegrand (t : ℝ) (z : ℂ) (u : ℝ) : ℂ :=
  ((Real.exp (t * u ^ 2) : ℝ) : ℂ) * ((K.Φ u : ℝ) : ℂ) * Complex.cos (z * u)

variable (K) in
/-- `H_t(z) := ∫_0^∞ e^{tu²} K.Φ(u) cos(zu) du`.  For `t = 0` this is, classically,
`(1/8) ξ(1/2 + iz/2)` (registry statement `RH.dbn_H0_eq_xi`, NOT proved here). -/
noncomputable def H (t : ℝ) (z : ℂ) : ℂ := ∫ u in Set.Ioi (0 : ℝ), HIntegrand K t z u

@[fun_prop]
lemma continuous_HIntegrand (t : ℝ) (z : ℂ) : Continuous (HIntegrand K t z) := by
  unfold HIntegrand
  fun_prop

/-- **The `H_t` integrand is integrable on `(0, ∞)` for every `t ∈ ℝ` and `z ∈ ℂ`.** -/
theorem integrableOn_HIntegrand (t : ℝ) (z : ℂ) : IntegrableOn (HIntegrand K t z) (Ioi 0) := by
  have hg := (integrableOn_exp_quad_mul_exp_neg_exp t (9 + ‖z‖)).const_mul K.C
  refine hg.mono' (continuous_HIntegrand (K := K) t z).aestronglyMeasurable ?_
  rw [ae_restrict_iff' measurableSet_Ioi]
  refine Eventually.of_forall fun u hu ↦ ?_
  have hu0 : (0 : ℝ) ≤ u := le_of_lt hu
  have hcos : ‖Complex.cos (z * u)‖ ≤ Real.exp (‖z‖ * u) := by
    refine (norm_cos_le_exp_norm _).trans ?_
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hu0]
  have hΦ := K.bound hu0
  have hC := K.C_nonneg
  unfold HIntegrand
  rw [norm_mul, norm_mul, Complex.norm_real, Complex.norm_real, Real.norm_eq_abs, Real.norm_eq_abs,
    abs_of_pos (Real.exp_pos _)]
  calc Real.exp (t * u ^ 2) * |K.Φ u| * ‖Complex.cos (z * u)‖
      ≤ Real.exp (t * u ^ 2) * (K.C * (Real.exp (9 * u) * Real.exp (-(π / 2) * Real.exp (4 * u))))
          * Real.exp (‖z‖ * u) := by gcongr
    _ = K.C * (Real.exp (t * u ^ 2 + (9 + ‖z‖) * u) * Real.exp (-(π / 2) * Real.exp (4 * u))) := by
        rw [Real.exp_add, add_mul, Real.exp_add]; ring

/-- `H_t` is even in `z`. -/
theorem H_neg (t : ℝ) (z : ℂ) : H K t (-z) = H K t z := by
  unfold H HIntegrand
  simp only [neg_mul, Complex.cos_neg]

/-- On the real axis `H_t` is the real integral `∫_0^∞ e^{tu²} K.Φ(u) cos(xu) du` (cast to `ℂ`). -/
theorem H_ofReal (t x : ℝ) :
    H K t x = ((∫ u in Ioi (0 : ℝ), Real.exp (t * u ^ 2) * K.Φ u * Real.cos (x * u) : ℝ) : ℂ) := by
  have hfun : (fun u ↦ HIntegrand K t x u)
      = fun u ↦ ((Real.exp (t * u ^ 2) * K.Φ u * Real.cos (x * u) : ℝ) : ℂ) := by
    funext u
    unfold HIntegrand
    push_cast
    ring
  unfold H
  rw [hfun]
  exact integral_ofReal

/-- **`H_t(z)` is real for real `z`.** -/
theorem H_ofReal_im (t x : ℝ) : (H K t x).im = 0 := by
  rw [H_ofReal (K := K)]; simp

/-! ### `H_t` is entire -/

/-- `‖sin w‖ ≤ exp ‖w‖` for complex `w`. -/
lemma norm_sin_le_exp_norm (w : ℂ) : ‖Complex.sin w‖ ≤ Real.exp ‖w‖ := by
  have him := Complex.abs_im_le_norm w
  have h1 : ‖Complex.exp (w * Complex.I)‖ ≤ Real.exp ‖w‖ := by
    rw [Complex.norm_exp]
    apply Real.exp_le_exp.mpr
    simp only [Complex.mul_re, Complex.I_re, mul_zero, Complex.I_im, mul_one, zero_sub]
    linarith [neg_abs_le w.im]
  have h2 : ‖Complex.exp (-w * Complex.I)‖ ≤ Real.exp ‖w‖ := by
    rw [Complex.norm_exp]
    apply Real.exp_le_exp.mpr
    simp only [Complex.mul_re, Complex.neg_re, Complex.I_re, mul_zero, Complex.neg_im, Complex.I_im,
      mul_one, zero_sub, neg_neg]
    linarith [le_abs_self w.im]
  calc ‖Complex.sin w‖
      = ‖(Complex.exp (-w * Complex.I) - Complex.exp (w * Complex.I)) * Complex.I / 2‖ := rfl
    _ = ‖Complex.exp (-w * Complex.I) - Complex.exp (w * Complex.I)‖ / 2 := by
        rw [norm_div, norm_mul, Complex.norm_I, mul_one, Complex.norm_two]
    _ ≤ (Real.exp ‖w‖ + Real.exp ‖w‖) / 2 := by
        gcongr
        exact (norm_sub_le _ _).trans (add_le_add h2 h1)
    _ = Real.exp ‖w‖ := by ring

variable (K) in
/-- The `z`-derivative of the `H_t` integrand: `e^{tu²} K.Φ(u) · (−u sin(zu))`. -/
noncomputable def HIntegrand' (t : ℝ) (z : ℂ) (u : ℝ) : ℂ :=
  ((Real.exp (t * u ^ 2) : ℝ) : ℂ) * ((K.Φ u : ℝ) : ℂ) * (-Complex.sin (z * u) * u)

lemma hasDerivAt_HIntegrand (t u : ℝ) (z : ℂ) :
    HasDerivAt (fun w ↦ HIntegrand K t w u) (HIntegrand' K t z u) z := by
  have h : HasDerivAt (fun w : ℂ ↦ Complex.cos (w * u)) (-Complex.sin (z * u) * u) z := by
    have := ((hasDerivAt_id z).mul_const (u : ℂ)).ccos
    simpa using this
  exact h.const_mul _

@[fun_prop]
lemma continuous_HIntegrand' (t : ℝ) (z : ℂ) : Continuous (HIntegrand' K t z) := by
  unfold HIntegrand'
  fun_prop

/-- **`H_t` is complex-differentiable at every `z₀`**, with derivative
`∫_0^∞ e^{tu²} K.Φ(u) (−u sin(z₀u)) du` (differentiation under the integral sign, dominated on
the unit ball around `z₀` by the integrable majorant of `integrableOn_exp_quad_mul_exp_neg_exp`). -/
theorem hasDerivAt_H (t : ℝ) (z₀ : ℂ) :
    HasDerivAt (H K t) (∫ u in Set.Ioi (0 : ℝ), HIntegrand' K t z₀ u) z₀ := by
  have hC := K.C_nonneg
  have hbound := (integrableOn_exp_quad_mul_exp_neg_exp t (11 + ‖z₀‖)).const_mul K.C
  refine (hasDerivAt_integral_of_dominated_loc_of_deriv_le (μ := volume.restrict (Set.Ioi 0))
    (F := fun z u ↦ HIntegrand K t z u) (F' := fun z u ↦ HIntegrand' K t z u)
    (s := Metric.ball z₀ 1) (Metric.ball_mem_nhds z₀ one_pos)
    (Eventually.of_forall fun z ↦ (continuous_HIntegrand (K := K) t z).aestronglyMeasurable)
    (integrableOn_HIntegrand (K := K) t z₀)
    (continuous_HIntegrand' (K := K) t z₀).aestronglyMeasurable ?_ hbound
    (Eventually.of_forall fun u z _ ↦ hasDerivAt_HIntegrand (K := K) t u z)).2
  rw [ae_restrict_iff' measurableSet_Ioi]
  refine Eventually.of_forall fun u hu z hz ↦ ?_
  have hu0 : (0 : ℝ) ≤ u := le_of_lt hu
  have hz' : ‖z‖ ≤ ‖z₀‖ + 1 := by
    have := Metric.mem_ball.mp hz
    rw [Complex.dist_eq] at this
    calc ‖z‖ = ‖z₀ + (z - z₀)‖ := by congr 1; ring
      _ ≤ ‖z₀‖ + ‖z - z₀‖ := norm_add_le _ _
      _ ≤ ‖z₀‖ + 1 := by linarith
  have hsin : ‖-Complex.sin (z * u) * u‖ ≤ Real.exp ((‖z₀‖ + 2) * u) := by
    rw [norm_mul, norm_neg, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hu0]
    have h1 : ‖Complex.sin (z * u)‖ ≤ Real.exp ((‖z₀‖ + 1) * u) := by
      refine (norm_sin_le_exp_norm _).trans ?_
      rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hu0]
      exact Real.exp_le_exp.mpr (by nlinarith)
    have h2 : u ≤ Real.exp u := by linarith [Real.add_one_le_exp u]
    calc ‖Complex.sin (z * u)‖ * u ≤ Real.exp ((‖z₀‖ + 1) * u) * Real.exp u :=
          mul_le_mul h1 h2 hu0 (Real.exp_pos _).le
      _ = Real.exp ((‖z₀‖ + 2) * u) := by rw [← Real.exp_add]; ring_nf
  have hΦ := K.bound hu0
  have e : Real.exp (9 * u) * Real.exp ((‖z₀‖ + 2) * u) = Real.exp ((11 + ‖z₀‖) * u) := by
    rw [← Real.exp_add]; ring_nf
  show ‖HIntegrand' K t z u‖ ≤ _
  unfold HIntegrand'
  rw [norm_mul, norm_mul, Complex.norm_real, Complex.norm_real, Real.norm_eq_abs, Real.norm_eq_abs,
    abs_of_pos (Real.exp_pos _)]
  calc Real.exp (t * u ^ 2) * |K.Φ u| * ‖-Complex.sin (z * u) * u‖
      ≤ Real.exp (t * u ^ 2)
          * (K.C * (Real.exp (9 * u) * Real.exp (-(π / 2) * Real.exp (4 * u))))
          * Real.exp ((‖z₀‖ + 2) * u) := by gcongr
    _ = K.C * (Real.exp (t * u ^ 2 + (11 + ‖z₀‖) * u)
          * Real.exp (-(π / 2) * Real.exp (4 * u))) := by
        rw [Real.exp_add, ← e]; ring

/-- **`H_t` is entire** for every `t ∈ ℝ`. -/
theorem differentiable_H (t : ℝ) : Differentiable ℂ (H K t) :=
  fun z ↦ (hasDerivAt_H (K := K) t z).differentiableAt



end DBN.Gen
