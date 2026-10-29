import Mathlib
import GenTheta

/-! Generic dBN island, part 4 (D2b, step 1): **the Mellin transform of a theta series.**

For `Re s > 1`, with `w = (s + k)/2`:
`∫_0^∞ y^{w-1} θ_c(y) dy = (q/π)^w Γ(w) Σ c(n) n^{-s}`,
by the Gamma integral `∫ y^{w-1} e^{-ry} = r^{-w} Γ(w)` termwise and Fubini
(`integral_tsum_of_summable_integral_norm`).  conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology Complex

namespace DBN.Gen

variable {c : ℕ → ℝ} {k : ℕ} {q : ℝ}

theorem ofReal_cpow_eq_exp {x : ℝ} (hx : 0 < x) (a : ℂ) :
    ((x : ℝ) : ℂ) ^ a = Complex.exp (a * Real.log x) := by
  rw [cpow_def_of_ne_zero (by exact_mod_cast hx.ne'), ← ofReal_log hx.le, mul_comm]

/-- The `n`-th Gamma integral, `n ≥ 1`. -/
theorem integral_term (hq : 0 < q) {w : ℂ} (hw : 0 < w.re) {n : ℕ} (hn : 1 ≤ n) :
    ∫ y in Ioi (0 : ℝ), (y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ) =
      ((q / π : ℝ) : ℂ) ^ w * (n : ℂ) ^ (-(2 * w)) * Complex.Gamma w := by
  have hr : 0 < π * (n : ℝ) ^ 2 / q := by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    have := Real.pi_pos; positivity
  have e : ∀ y : ℝ, (y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ) =
      (y : ℂ) ^ (w - 1) * Complex.exp (-(((π * (n : ℝ) ^ 2 / q : ℝ) : ℂ) * y)) := by
    intro y; congr 1; rw [ofReal_exp]; congr 1; push_cast; ring
  simp_rw [e]
  rw [integral_cpow_mul_exp_neg_mul_Ioi hw hr]
  congr 1
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  rw [show ((1 : ℂ) / ((π * (n : ℝ) ^ 2 / q : ℝ) : ℂ)) = ((1 / (π * (n : ℝ) ^ 2 / q) : ℝ) : ℂ) by
    push_cast; ring]
  rw [ofReal_cpow_eq_exp (by positivity), ofReal_cpow_eq_exp (by have := Real.pi_pos; positivity),
    show (n : ℂ) = ((n : ℝ) : ℂ) by push_cast; rfl, ofReal_cpow_eq_exp hn0, ← Complex.exp_add]
  congr 1
  have h1 : Real.log (1 / (π * (n : ℝ) ^ 2 / q)) = Real.log (q / π) - 2 * Real.log n := by
    rw [show 1 / (π * (n : ℝ) ^ 2 / q) = (q / π) / (n : ℝ) ^ 2 by field_simp,
      Real.log_div (by have := Real.pi_pos; positivity) (by positivity), Real.log_pow]
    push_cast; ring
  rw [h1]; push_cast; ring

/-- The norm integral of the `n`-th term. -/
theorem integral_norm_term (hq : 0 < q) {w : ℂ} (hw : 0 < w.re) {n : ℕ} (hn : 1 ≤ n) :
    ∫ y in Ioi (0 : ℝ), ‖(y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ)‖ =
      (q / π) ^ w.re * (n : ℝ) ^ (-(2 * w.re)) * Real.Gamma w.re := by
  have hr : 0 < π * (n : ℝ) ^ 2 / q := by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    have := Real.pi_pos; positivity
  have e : ∀ y ∈ Ioi (0 : ℝ),
      ‖(y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ)‖ =
        y ^ (w.re - 1) * Real.exp (-((π * (n : ℝ) ^ 2 / q) * y)) := by
    intro y hy
    rw [norm_mul, norm_cpow_eq_rpow_re_of_pos hy, Complex.norm_real,
      Real.norm_of_nonneg (Real.exp_pos _).le]
    simp only [sub_re, one_re]
    congr 2; ring
  rw [setIntegral_congr_fun measurableSet_Ioi e, integral_rpow_mul_exp_neg_mul_Ioi hw hr]
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  rw [show 1 / (π * (n : ℝ) ^ 2 / q) = (q / π) * ((n : ℝ) ^ 2)⁻¹ by field_simp,
    Real.mul_rpow (by have := Real.pi_pos; positivity) (by positivity),
    Real.inv_rpow (by positivity), ← Real.rpow_natCast, ← Real.rpow_mul hn0.le,
    ← Real.rpow_neg hn0.le]
  push_cast; ring_nf

theorem integrable_term (hq : 0 < q) {w : ℂ} (hw : 0 < w.re) {n : ℕ} (hn : 1 ≤ n) :
    IntegrableOn (fun y : ℝ ↦
      (y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ)) (Ioi 0) := by
  have hr : 0 < π * (n : ℝ) ^ 2 / q := by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    have := Real.pi_pos; positivity
  have hint := integrableOn_rpow_mul_exp_neg_mul_rpow (p := 1) (s := w.re - 1)
    (b := π * (n : ℝ) ^ 2 / q) (by linarith) one_pos hr
  refine Integrable.mono' hint ?_ ?_
  · refine ContinuousOn.aestronglyMeasurable ?_ measurableSet_Ioi
    intro y hy
    refine ContinuousAt.continuousWithinAt ?_
    refine ContinuousAt.mul ?_ (by fun_prop)
    exact (continuousAt_ofReal_cpow_const _ _ (Or.inr hy.ne'))
  · rw [ae_restrict_iff' measurableSet_Ioi]
    refine Eventually.of_forall fun y hy ↦ le_of_eq ?_
    rw [norm_mul, norm_cpow_eq_rpow_re_of_pos hy, Complex.norm_real,
      Real.norm_of_nonneg (Real.exp_pos _).le, Real.rpow_one]
    simp only [sub_re, one_re]
    congr 2; ring

/-- **Mellin transform of `θ_c`** for `Re s > 1`. -/
theorem mellin_thetaC (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hq : 0 < q) {s : ℂ} (hs : 1 < s.re) :
    ∫ y in Ioi (0 : ℝ), (y : ℂ) ^ ((s + k) / 2 - 1) * (thetaC c k q y : ℂ) =
      ((q / π : ℝ) : ℂ) ^ ((s + k) / 2) * Complex.Gamma ((s + k) / 2) *
        LSeries (fun n ↦ (c n : ℂ)) s := by
  set w : ℂ := (s + k) / 2 with hw_def
  have hwre : w.re = (s.re + k) / 2 := by simp [hw_def]
  have hw : 0 < w.re := by rw [hwre]; positivity
  set F : ℕ → ℝ → ℂ := fun n y ↦ ((c n * (n : ℝ) ^ k : ℝ) : ℂ) *
    ((y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ)) with hF
  -- (1) the integrand is the tsum
  have hsum : ∀ y : ℝ, ∑' n, F n y = (y : ℂ) ^ (w - 1) * (thetaC c k q y : ℂ) := by
    intro y
    unfold thetaC
    rw [ofReal_tsum, ← tsum_mul_left]
    congr 1; funext n
    simp only [hF]; push_cast; ring
  -- (2) integrability of each term
  have hint : ∀ n, Integrable (F n) (volume.restrict (Ioi 0)) := by
    intro n
    rcases Nat.eq_zero_or_pos n with h | h
    · subst h; simp [hF, hc0]
    · exact (integrable_term hq hw h).const_mul _
  -- (3) the norm integrals
  set C : ℝ := (q / π) ^ w.re * Real.Gamma w.re with hC
  have hC0 : 0 ≤ C := by
    rw [hC]; exact mul_nonneg (by have := Real.pi_pos; positivity) (Real.Gamma_pos_of_pos hw).le
  have hnorm : ∀ n, ∫ y in Ioi (0 : ℝ), ‖F n y‖ ≤ C * (n : ℝ) ^ (-s.re) := by
    intro n
    rcases Nat.eq_zero_or_pos n with h | h
    · subst h; simp [hF, hc0]; positivity
    have hn0 : (0 : ℝ) < n := by exact_mod_cast h
    have e : ∀ y, ‖F n y‖ = |c n * (n : ℝ) ^ k| *
        ‖(y : ℂ) ^ (w - 1) * ((Real.exp (-π * (n : ℝ) ^ 2 * y / q) : ℝ) : ℂ)‖ := by
      intro y; simp only [hF]; rw [norm_mul, Complex.norm_real, Real.norm_eq_abs]
    simp_rw [e]
    rw [integral_const_mul, integral_norm_term hq hw h]
    have hk : |c n * (n : ℝ) ^ k| ≤ (n : ℝ) ^ k := by
      rw [abs_mul, abs_of_nonneg (show (0 : ℝ) ≤ (n : ℝ) ^ k by positivity)]
      have := hc n; nlinarith [pow_nonneg hn0.le k]
    have hpow : (n : ℝ) ^ k * (n : ℝ) ^ (-(2 * w.re)) = (n : ℝ) ^ (-s.re) := by
      rw [← Real.rpow_natCast, ← Real.rpow_add hn0, hwre]; ring_nf
    calc |c n * (n : ℝ) ^ k| * ((q / π) ^ w.re * (n : ℝ) ^ (-(2 * w.re)) * Real.Gamma w.re)
        ≤ (n : ℝ) ^ k * ((q / π) ^ w.re * (n : ℝ) ^ (-(2 * w.re)) * Real.Gamma w.re) := by
          have : 0 ≤ (q / π) ^ w.re * (n : ℝ) ^ (-(2 * w.re)) * Real.Gamma w.re :=
            mul_nonneg (mul_nonneg (by have := Real.pi_pos; positivity) (by positivity))
              (Real.Gamma_pos_of_pos hw).le
          exact mul_le_mul_of_nonneg_right hk this
      _ = C * ((n : ℝ) ^ k * (n : ℝ) ^ (-(2 * w.re))) := by rw [hC]; ring
      _ = C * (n : ℝ) ^ (-s.re) := by rw [hpow]
  have hsummable : Summable fun n ↦ ∫ y in Ioi (0 : ℝ), ‖F n y‖ := by
    refine Summable.of_nonneg_of_le (fun n ↦ integral_nonneg fun _ ↦ norm_nonneg _) hnorm ?_
    exact (Real.summable_nat_rpow.mpr (by linarith)).mul_left C
  -- (4) Fubini and termwise evaluation
  have hfub := integral_tsum_of_summable_integral_norm hint hsummable
  simp_rw [hsum] at hfub
  rw [← hfub]
  have hterm : ∀ n, ∫ y in Ioi (0 : ℝ), F n y =
      ((q / π : ℝ) : ℂ) ^ w * Complex.Gamma w * LSeries.term (fun n ↦ (c n : ℂ)) s n := by
    intro n
    rcases Nat.eq_zero_or_pos n with h | h
    · subst h; simp [hF, hc0, LSeries.term]
    have hn0 : (n : ℂ) ≠ 0 := by exact_mod_cast h.ne'
    simp only [hF]
    rw [integral_const_mul, integral_term hq hw h, LSeries.term_of_ne_zero h.ne']
    have hpow : (n : ℂ) ^ k * (n : ℂ) ^ (-(2 * w)) = 1 / (n : ℂ) ^ s := by
      rw [← cpow_natCast, ← cpow_add _ _ hn0, show (k : ℂ) + -(2 * w) = -s by rw [hw_def]; ring,
        cpow_neg, one_div]
    rw [ofReal_mul, ofReal_pow, ofReal_natCast]
    linear_combination ((c n : ℂ) * ((q / π : ℝ) : ℂ) ^ w * Complex.Gamma w) * hpow
  simp_rw [hterm]
  rw [tsum_mul_left, LSeries]

end DBN.Gen
