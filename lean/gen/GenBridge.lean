import Mathlib
import GenMellin2

/-! Generic dBN island, part 4 (D2b, step 3): **the bridge `H₀^χ = (1/8) N^{(s+k)/2} Λ(s, χ)`.**

For a nontrivial Dirichlet character `χ` mod `N` with real values `c n` (`χ n = c n`) and parity
`k` (`gammaFactor χ s = Γ_ℝ(s + k)`), and the theta kernel `Φ_χ = PhiC c k N` (taken EVEN, the
hypothesis `heven`: CONDITIONAL, Φ_χ even ⇔ ε(χ) = 1):

`Hd 0 z = (1/8) · N^{(s+k)/2} · completedLFunction χ s`,  `s = 1/2 + iz/2`, for EVERY `z ∈ ℂ`.

Proof: on `Re s > 1` from `Hd_zero_eq_half_fourier`, `fourier_PhiC_eq_mellin`, `mellin_thetaC`,
`LFunction_eq_LSeries` and `LFunction_eq_completed_div_gammaFactor`; then everywhere by the identity
theorem (both sides entire).  conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology Complex

namespace DBN.Gen

variable {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N} {c : ℕ → ℝ} {k : ℕ}

/-- `(q/π)^w Γ(w) = q^w Γ_ℝ(2w)` for `q > 0`. -/
theorem div_pi_cpow_mul_Gamma {q : ℝ} (hq : 0 < q) (w : ℂ) :
    ((q / π : ℝ) : ℂ) ^ w * Complex.Gamma w = (q : ℂ) ^ w * Gammaℝ (2 * w) := by
  rw [Gammaℝ_def, show 2 * w / 2 = w by ring, show -(2 * w) / 2 = -w by ring,
    ofReal_cpow_eq_exp (by have := Real.pi_pos; positivity), ofReal_cpow_eq_exp hq,
    show (π : ℂ) = ((π : ℝ) : ℂ) from rfl, ofReal_cpow_eq_exp Real.pi_pos,
    Real.log_div hq.ne' Real.pi_pos.ne']
  rw [← mul_assoc, ← Complex.exp_add]
  congr 2
  push_cast; ring

/-- The bridge on `Re s > 1`. -/
theorem bridge_of_re_gt (hχc : ∀ n : ℕ, χ n = (c n : ℂ)) (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0)
    (hc1 : c 1 = 1) (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (heven : ∀ u, PhiC c k N (-u) = PhiC c k N u) {z : ℂ} (hz : z.im < -1) :
    (thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd 0 z =
      (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + k) / 2) *
        DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) := by
  have hq : (0 : ℝ) < N := by exact_mod_cast (NeZero.pos N)
  set s : ℂ := 1 / 2 + I * z / 2 with hs_def
  have hsre : s.re = 1 / 2 - z.im / 2 := by simp [hs_def]; ring
  have hs : 1 < s.re := by rw [hsre]; linarith
  set D := thetaDecayKernel hc hc0 hc1 hq heven with hD
  have hΦ : D.Φ = PhiC c k N := rfl
  rw [D.Hd_zero_eq_half_fourier, hΦ, fourier_PhiC_eq_mellin]
  have hw : (1 + 2 * (k : ℂ) + I * z) / 4 - 1 = (s + k) / 2 - 1 := by rw [hs_def]; ring
  rw [hw, mellin_thetaC hc hc0 hq hs]
  have hL : LSeries (fun n ↦ (c n : ℂ)) s = DirichletCharacter.LFunction χ s := by
    rw [DirichletCharacter.LFunction_eq_LSeries χ hs]
    congr 1; funext n; rw [hχc]
  have hgne : χ.gammaFactor s ≠ 0 := by
    rw [hgam]; exact Gammaℝ_ne_zero_of_re_pos (by simp; linarith)
  have hΛ : DirichletCharacter.completedLFunction χ s =
      χ.gammaFactor s * DirichletCharacter.LFunction χ s := by
    rw [DirichletCharacter.LFunction_eq_completed_div_gammaFactor χ s
      (Or.inl (by intro h; rw [h] at hs; simp at hs; linarith))]
    field_simp
  rw [hL, hΛ, hgam, div_pi_cpow_mul_Gamma hq, show 2 * ((s + k) / 2) = s + k by ring]
  push_cast
  ring

/-- **The bridge, everywhere** (identity theorem). -/
theorem bridge (hχ1 : χ ≠ 1) (hχc : ∀ n : ℕ, χ n = (c n : ℂ)) (hc : ∀ n, |c n| ≤ 1)
    (hc0 : c 0 = 0) (hc1 : c 1 = 1) (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (heven : ∀ u, PhiC c k N (-u) = PhiC c k N u) (z : ℂ) :
    (thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd 0 z =
      (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + k) / 2) *
        DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) := by
  set D := thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven with hD
  set f₁ : ℂ → ℂ := fun z ↦ D.Hd 0 z with hf₁
  set f₂ : ℂ → ℂ := fun z ↦ (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + k) / 2) *
    DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) with hf₂
  have hd₁ : Differentiable ℂ f₁ := by
    have e : f₁ = fun z ↦ 2 * H D.toKernel (4 * 0) (2 * z) := by
      funext z; exact D.Hd_eq 0 z
    rw [e]
    exact (differentiable_const _).mul ((differentiable_H (K := D.toKernel) _).comp
      (differentiable_const _ |>.mul differentiable_id))
  have hd₂ : Differentiable ℂ f₂ := by
    have hN : (N : ℂ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
    refine ((differentiable_const _).mul ?_).mul ?_
    · exact Differentiable.const_cpow (by fun_prop) (Or.inl hN)
    · exact (DirichletCharacter.differentiable_completedLFunction hχ1).comp (by fun_prop)
  have ha₁ : AnalyticOnNhd ℂ f₁ univ := hd₁.differentiableOn.analyticOnNhd isOpen_univ
  have ha₂ : AnalyticOnNhd ℂ f₂ univ := hd₂.differentiableOn.analyticOnNhd isOpen_univ
  have hU : IsOpen {w : ℂ | w.im < -1} := isOpen_lt Complex.continuous_im continuous_const
  have hz₀ : (-2 * I : ℂ) ∈ {w : ℂ | w.im < -1} := by simp
  have hev : f₁ =ᶠ[𝓝 (-2 * I)] f₂ := by
    filter_upwards [hU.mem_nhds hz₀] with w hw
    exact bridge_of_re_gt hχc hc hc0 hc1 hgam heven hw
  have := ha₁.eq_of_eventuallyEq ha₂ hev
  exact congrFun this z

end DBN.Gen
