import Mathlib
import GenMellin

/-! Generic dBN island, part 4 (D2b, step 2): **from the cosine transform to the Mellin
transform.**

* `fourier_PhiC_eq_mellin`: `∫_ℝ Φ_c(u) e^{izu} du = (1/4) ∫_0^∞ y^{w-1} θ_c(y) dy`,
  `w = (1 + 2k + iz)/4` (substitutions `u = v/4`, `y = e^v`; no integrability needed).
* `DecayKernel.Hd_zero_eq_half_fourier`: for an even decay kernel,
  `Hd 0 z = (1/2) ∫_ℝ Φ(u) e^{izu} du`.
conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology Complex

namespace DBN.Gen

variable {c : ℕ → ℝ} {k : ℕ} {q : ℝ}

theorem ofReal_exp_cpow (v : ℝ) (a : ℂ) : ((Real.exp v : ℝ) : ℂ) ^ a = Complex.exp (a * v) := by
  rw [ofReal_cpow_eq_exp (Real.exp_pos v), Real.log_exp]

/-- **Change of variables.** -/
theorem fourier_PhiC_eq_mellin (z : ℂ) :
    ∫ u : ℝ, (PhiC c k q u : ℂ) * Complex.exp (I * z * u) =
      (1 / 4) * ∫ y in Ioi (0 : ℝ), (y : ℂ) ^ ((1 + 2 * k + I * z) / 4 - 1) * (thetaC c k q y : ℂ) := by
  set g : ℝ → ℂ := fun y ↦ (y : ℂ) ^ ((1 + 2 * k + I * z) / 4 - 1) * (thetaC c k q y : ℂ) with hg
  set f : ℝ → ℂ := fun u ↦ (PhiC c k q u : ℂ) * Complex.exp (I * z * u) with hf
  have h1 : ∫ v : ℝ, f (v / 4) = (4 : ℝ) • ∫ u : ℝ, f u := by
    rw [Measure.integral_comp_div f 4]; norm_num
  have h2 : ∀ v : ℝ, f (v / 4) = Real.exp v • g (Real.exp v) := by
    intro v
    simp only [hf, hg, PhiC, Complex.real_smul]
    rw [show 4 * (v / 4) = v by ring, ofReal_exp_cpow]
    push_cast
    rw [show (Complex.exp ((1 + 2 * k) * (v / 4)) * (thetaC c k q (Real.exp v) : ℂ)) *
        Complex.exp (I * z * (v / 4)) = Complex.exp ((1 + 2 * k) * (v / 4) + I * z * (v / 4)) *
          (thetaC c k q (Real.exp v) : ℂ) by rw [Complex.exp_add]; ring]
    rw [← mul_assoc, ← Complex.exp_add]
    congr 2; ring
  have h3 := integral_comp_exp g
  simp_rw [← h2] at h3
  rw [← h3, h1, Complex.real_smul]
  push_cast
  ring

namespace DecayKernel

variable (D : DecayKernel)

/-- `A u − b e^{4u} ≤ M − u` on `u ≥ 0`. -/
theorem exp_decay_le (A : ℝ) {u : ℝ} (hu : 0 ≤ u) :
    A * u - D.b * Real.exp (4 * u) ≤ (A + 1) ^ 2 / (32 * D.b) - u := by
  have hb := D.hb
  have hq := Real.quadratic_le_exp_of_nonneg (by linarith : (0 : ℝ) ≤ 4 * u)
  have h1 : D.b * (1 + 4 * u + (4 * u) ^ 2 / 2) ≤ D.b * Real.exp (4 * u) :=
    mul_le_mul_of_nonneg_left hq hb.le
  have h2 : (A + 1) * u - 8 * D.b * u ^ 2 ≤ (A + 1) ^ 2 / (32 * D.b) := by
    rw [le_div_iff₀ (by positivity)]
    nlinarith [sq_nonneg (16 * D.b * u - (A + 1))]
  nlinarith

theorem norm_cexp_I_mul (z : ℂ) (u : ℝ) : ‖Complex.exp (I * z * u)‖ ≤ Real.exp (‖z‖ * |u|) := by
  rw [Complex.norm_exp]
  apply Real.exp_le_exp.mpr
  have : (I * z * u).re = -(z.im * u) := by simp
  rw [this]
  have h := Complex.abs_im_le_norm z
  calc -(z.im * u) ≤ |z.im * u| := neg_le_abs _
    _ = |z.im| * |u| := abs_mul _ _
    _ ≤ ‖z‖ * |u| := mul_le_mul_of_nonneg_right h (abs_nonneg _)

theorem integrableOn_fourier (z : ℂ) :
    IntegrableOn (fun u : ℝ ↦ (D.Φ u : ℂ) * Complex.exp (I * z * u)) (Ioi 0) := by
  set A := D.a + ‖z‖ with hA
  set M := (A + 1) ^ 2 / (32 * D.b) with hM
  have hint : IntegrableOn (fun u : ℝ ↦ D.C * Real.exp M * Real.exp (-1 * u)) (Ioi 0) :=
    (exp_neg_integrableOn_Ioi 0 one_pos).const_mul (D.C * Real.exp M)
  refine hint.mono' ?_ ?_
  · exact ((Complex.continuous_ofReal.comp D.cont).mul (by fun_prop)).aestronglyMeasurable
  · rw [ae_restrict_iff' measurableSet_Ioi]
    refine Eventually.of_forall fun u hu ↦ ?_
    have hu0 : 0 ≤ u := le_of_lt hu
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs]
    have h1 := D.bound hu0
    have h2 := norm_cexp_I_mul z u
    rw [abs_of_nonneg hu0] at h2
    have h3 := D.exp_decay_le A hu0
    calc |D.Φ u| * ‖Complex.exp (I * z * u)‖
        ≤ (D.C * (Real.exp (D.a * u) * Real.exp (-D.b * Real.exp (4 * u)))) * Real.exp (‖z‖ * u) :=
          mul_le_mul h1 h2 (norm_nonneg _) (by have := D.C_nonneg; positivity)
      _ = D.C * Real.exp (A * u - D.b * Real.exp (4 * u)) := by
          rw [mul_assoc, ← Real.exp_add, ← Real.exp_add, hA]; ring_nf
      _ ≤ D.C * Real.exp (M - u) := by gcongr; exact D.C_nonneg
      _ = D.C * Real.exp M * Real.exp (-1 * u) := by
          rw [mul_assoc, ← Real.exp_add]; ring_nf

/-- **Evenness halves the full-line Fourier integral.** -/
theorem Hd_zero_eq_half_fourier (z : ℂ) :
    D.Hd 0 z = (1 / 2) * ∫ u : ℝ, (D.Φ u : ℂ) * Complex.exp (I * z * u) := by
  set g : ℝ → ℂ := fun u ↦ (D.Φ u : ℂ) * Complex.exp (I * z * u) with hg
  set h : ℝ → ℂ := fun u ↦ (D.Φ u : ℂ) * Complex.exp (I * (-z) * u) with hh
  have hgI : Integrable ((Ioi (0 : ℝ)).indicator g) :=
    (integrable_indicator_iff measurableSet_Ioi).mpr (D.integrableOn_fourier z)
  have hhI : Integrable ((Ioi (0 : ℝ)).indicator h) :=
    (integrable_indicator_iff measurableSet_Ioi).mpr (D.integrableOn_fourier (-z))
  have hhI' : Integrable (fun x ↦ (Ioi (0 : ℝ)).indicator h (-x)) := hhI.comp_neg
  have hsplit : ∀ᵐ x ∂(volume : Measure ℝ),
      (Ioi (0 : ℝ)).indicator g x + (Ioi (0 : ℝ)).indicator h (-x) = g x := by
    filter_upwards [compl_mem_ae_iff.mpr (measure_singleton (0 : ℝ))] with x hx
    simp only [mem_compl_iff, mem_singleton_iff] at hx
    simp only [Set.indicator_apply, mem_Ioi]
    rcases lt_or_gt_of_ne hx with hlt | hgt
    · rw [if_neg (by linarith), if_pos (by linarith), zero_add]
      simp only [hh, hg]
      rw [D.even]; congr 2; push_cast; ring
    · rw [if_pos hgt, if_neg (by linarith), add_zero]
  have hfull : ∫ u : ℝ, g u = (∫ u in Ioi (0 : ℝ), g u) + ∫ u in Ioi (0 : ℝ), h u := by
    rw [← integral_congr_ae hsplit, integral_add hgI hhI', integral_indicator measurableSet_Ioi,
      integral_neg_eq_self (fun x ↦ (Ioi (0 : ℝ)).indicator h x) volume,
      integral_indicator measurableSet_Ioi]
  rw [hfull, ← integral_add (D.integrableOn_fourier z) (D.integrableOn_fourier (-z))]
  unfold Hd
  rw [← integral_const_mul]
  refine setIntegral_congr_fun measurableSet_Ioi fun u _ ↦ ?_
  simp only [hg, hh, mul_zero, zero_mul, Real.exp_zero, ofReal_one, one_mul, Complex.cos]
  ring_nf

end DecayKernel

end DBN.Gen
