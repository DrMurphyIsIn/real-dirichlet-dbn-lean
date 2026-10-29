import Mathlib
import GenM1Parametric

/-! Generic dBN island, part 2: **arbitrary double-exponential decay, by rescaling.**

A `DecayKernel` is an even continuous `Φ ≢ 0` with `|Φ(u)| ≤ C e^{au} exp(−b e^{4u})` (`u ≥ 0`,
any real `a`, any `b > 0`); e.g. a Dirichlet theta kernel has `b = π/q`.  Its heat flow
`Hd t z = ∫_0^∞ e^{tu²} Φ(u) cos(zu) du` satisfies `Hd t z = 2 · H K (4t) (2z)` for the `Kernel`
`K = Φ(2·)`, which meets the island's decay template.  Hence de Bruijn's contraction for every
such kernel (`DecayKernel.real_zeros_of_strip`): a zero strip `(Im z)² ≤ Y` for `Hd 0` gives only
real zeros for `t ≥ Y/2`.  conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology

namespace DBN.Gen

/-- An even kernel with double-exponential decay of arbitrary rate. -/
structure DecayKernel where
  Φ : ℝ → ℝ
  cont : Continuous Φ
  even : ∀ u, Φ (-u) = Φ u
  a : ℝ
  b : ℝ
  C : ℝ
  hb : 0 < b
  C_nonneg : 0 ≤ C
  bound : ∀ {u : ℝ}, 0 ≤ u → |Φ u| ≤ C * (Real.exp (a * u) * Real.exp (-b * Real.exp (4 * u)))
  ne : ∃ u, Φ u ≠ 0

namespace DecayKernel

variable (D : DecayKernel)

/-- The heat flow of a decay kernel. -/
noncomputable def Hd (t : ℝ) (z : ℂ) : ℂ :=
  ∫ u in Ioi (0 : ℝ), ((Real.exp (t * u ^ 2) : ℝ) : ℂ) * ((D.Φ u : ℝ) : ℂ) * Complex.cos (z * u)

/-- The rescaling constant. -/
noncomputable def C₂ : ℝ := D.C * Real.exp ((|2 * D.a - 9| + π / 2) ^ 2 / (4 * D.b))

theorem template (u : ℝ) (hu : 0 ≤ u) :
    (2 * D.a) * u - D.b * Real.exp (4 * (2 * u)) ≤
      (|2 * D.a - 9| + π / 2) ^ 2 / (4 * D.b) + 9 * u - π / 2 * Real.exp (4 * u) := by
  set x := Real.exp (4 * u) with hx
  have hx1 : 1 ≤ x := Real.one_le_exp (by linarith)
  have hux : u ≤ x := by have := Real.add_one_le_exp (4 * u); rw [hx]; linarith
  have hx2 : Real.exp (4 * (2 * u)) = x ^ 2 := by
    rw [hx, ← Real.exp_nat_mul]; push_cast; ring_nf
  rw [hx2]
  set A := |2 * D.a - 9| + π / 2 with hA
  have hA0 : 0 ≤ A := by rw [hA]; positivity
  have h1 : (2 * D.a - 9) * u ≤ |2 * D.a - 9| * x := by
    calc (2 * D.a - 9) * u ≤ |2 * D.a - 9| * u :=
          mul_le_mul_of_nonneg_right (le_abs_self _) (by linarith)
      _ ≤ |2 * D.a - 9| * x := mul_le_mul_of_nonneg_left hux (abs_nonneg _)
  have h2 : A * x - D.b * x ^ 2 ≤ A ^ 2 / (4 * D.b) := by
    have hb := D.hb
    rw [le_div_iff₀ (by positivity)]
    nlinarith [sq_nonneg (2 * D.b * x - A)]
  have : A * x = |2 * D.a - 9| * x + π / 2 * x := by rw [hA]; ring
  nlinarith

/-- The rescaled kernel `Φ(2u)`, in the island's decay template. -/
noncomputable def toKernel : Kernel where
  Φ := fun u ↦ D.Φ (2 * u)
  cont := D.cont.comp (continuous_const.mul continuous_id)
  even := fun u ↦ by simp only [mul_neg]; exact D.even (2 * u)
  C := D.C₂
  C_nonneg := mul_nonneg D.C_nonneg (Real.exp_pos _).le
  bound := by
    intro u hu
    have h := D.bound (u := 2 * u) (by linarith)
    have ht := D.template u hu
    calc |D.Φ (2 * u)| ≤ D.C * (Real.exp (D.a * (2 * u)) * Real.exp (-D.b * Real.exp (4 * (2 * u)))) := h
      _ = D.C * Real.exp ((2 * D.a) * u - D.b * Real.exp (4 * (2 * u))) := by
          rw [← Real.exp_add]; ring_nf
      _ ≤ D.C * Real.exp ((|2 * D.a - 9| + π / 2) ^ 2 / (4 * D.b) + 9 * u - π / 2 * Real.exp (4 * u)) := by
          gcongr; exact D.C_nonneg
      _ = D.C₂ * (Real.exp (9 * u) * Real.exp (-(π / 2) * Real.exp (4 * u))) := by
          unfold C₂
          rw [mul_assoc, ← Real.exp_add, ← Real.exp_add]; ring_nf
  ne := by
    obtain ⟨u, hu⟩ := D.ne
    exact ⟨u / 2, by show D.Φ (2 * (u / 2)) ≠ 0; rw [show 2 * (u / 2) = u by ring]; exact hu⟩

/-- **Rescaling identity.** `Hd t z = 2 · H (Φ(2·)) (4t) (2z)`. -/
theorem Hd_eq (t : ℝ) (z : ℂ) : D.Hd t z = 2 * H D.toKernel (4 * t) (2 * z) := by
  unfold H HIntegrand
  set f : ℝ → ℂ := fun v ↦
    ((Real.exp (t * v ^ 2) : ℝ) : ℂ) * ((D.Φ v : ℝ) : ℂ) * Complex.cos (z * v) with hf
  have e : ∀ u : ℝ, ((Real.exp (4 * t * u ^ 2) : ℝ) : ℂ) * ((D.toKernel.Φ u : ℝ) : ℂ) *
      Complex.cos (2 * z * u) = f (2 * u) := by
    intro u
    simp only [hf, toKernel]
    congr 2
    · congr 1; ring_nf
    · push_cast; ring_nf
  simp_rw [e]
  rw [integral_comp_mul_left_Ioi f 0 (by norm_num : (0 : ℝ) < 2), mul_zero, Complex.real_smul]
  have hHd : D.Hd t z = ∫ x in Ioi (0 : ℝ), f x := rfl
  rw [hHd]
  generalize (∫ x in Ioi (0 : ℝ), f x) = J
  push_cast
  ring

/-- **De Bruijn's contraction for every decay kernel.**  If every zero of `Hd 0` satisfies
`(Im z)² ≤ Y`, then for every `t ≥ Y/2` every zero of `Hd t` is real. -/
theorem real_zeros_of_strip {Y : ℝ} (hY : 0 ≤ Y) (h0 : ∀ z : ℂ, D.Hd 0 z = 0 → z.im ^ 2 ≤ Y) :
    ∀ t : ℝ, Y / 2 ≤ t → ∀ z : ℂ, D.Hd t z = 0 → z.im = 0 := by
  intro t ht z hz
  have hK0 : ∀ w : ℂ, H D.toKernel 0 w = 0 → w.im ^ 2 ≤ 4 * Y := by
    intro w hw
    have h := D.Hd_eq 0 (w / 2)
    rw [mul_zero, show 2 * (w / 2) = w by ring, hw, mul_zero] at h
    have := h0 (w / 2) h
    have him : (w / 2).im = w.im / 2 := by simp
    rw [him] at this
    nlinarith
  have hzK : H D.toKernel (4 * t) (2 * z) = 0 := by
    have h := D.Hd_eq t z
    rw [hz] at h
    exact (mul_eq_zero.mp h.symm).resolve_left two_ne_zero
  have h := dbn_debruijn_parametric (K := D.toKernel) 0 (4 * Y) hK0 (4 * t) (by linarith)
    (2 * z) hzK
  rw [max_eq_right (by linarith)] at h
  have him : (2 * z).im = 2 * z.im := by simp
  rw [him] at h
  nlinarith [sq_nonneg z.im]

end DecayKernel

end DBN.Gen
