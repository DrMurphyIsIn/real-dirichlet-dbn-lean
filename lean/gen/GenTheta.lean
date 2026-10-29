import Mathlib
import GenScale

/-! Generic dBN island, part 3: **theta-series kernels.**

For real coefficients `c` with `|c n| ≤ 1`, `c 0 = 0`, `c 1 = 1`, a weight `k ∈ ℕ` and `q > 0`:
`θ_c(x) = Σ c(n) n^k e^{−πn²x/q}` and `Φ_c(u) = e^{(1+2k)u} θ_c(e^{4u})`.  For a real primitive
Dirichlet character `χ` mod `q` of parity `k` (`c = χ`), `Φ_c` is the Dirichlet analogue of
Riemann's `Φ`.

Proved here: `Φ_c` is continuous, has decay `|Φ_c(u)| ≤ S e^{(1+2k)u} exp(−(π/2q) e^{4u})`, and is
not identically zero.  Its **evenness** is the theta functional equation with root number `+1`
(Gauss's sign theorem for `χ`); it is taken as the explicit hypothesis `heven` of
`thetaDecayKernel`.  conjecture1_proved = False. -/

open Real MeasureTheory Set Filter Topology

namespace DBN.Gen

variable (c : ℕ → ℝ) (k : ℕ) (q : ℝ)

/-- `θ_c(x) = Σ_n c(n) n^k exp(−π n² x / q)`. -/
noncomputable def thetaC (x : ℝ) : ℝ :=
  ∑' n : ℕ, c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)

/-- `Φ_c(u) = e^{(1+2k)u} θ_c(e^{4u})`. -/
noncomputable def PhiC (u : ℝ) : ℝ :=
  Real.exp ((1 + 2 * k) * u) * thetaC c k q (Real.exp (4 * u))

variable {c k q}

theorem norm_term_le (hc : ∀ n, |c n| ≤ 1) (hq : 0 < q) {x₀ x : ℝ} (hx₀ : 0 < x₀)
    (hx : x₀ ≤ x) (n : ℕ) :
    ‖c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)‖ ≤
      (n : ℝ) ^ k * Real.exp (-(π * x₀ / q) * n) := by
  rw [Real.norm_eq_abs, abs_mul, abs_mul, abs_of_pos (Real.exp_pos _),
    abs_of_nonneg (show (0:ℝ) ≤ (n:ℝ) ^ k by positivity)]
  have h1 : |c n| * (n : ℝ) ^ k ≤ (n : ℝ) ^ k := by
    have := hc n; nlinarith [pow_nonneg (Nat.cast_nonneg n : (0 : ℝ) ≤ n) k]
  have h2 : Real.exp (-π * (n : ℝ) ^ 2 * x / q) ≤ Real.exp (-(π * x₀ / q) * n) := by
    apply Real.exp_le_exp.mpr
    have hn : (n : ℝ) ≤ (n : ℝ) ^ 2 := by
      rcases Nat.eq_zero_or_pos n with h | h
      · simp [h]
      · have : (1 : ℝ) ≤ n := by exact_mod_cast h
        nlinarith
    rw [neg_mul, neg_mul, neg_div, neg_mul, neg_le_neg_iff, div_mul_eq_mul_div,
      div_le_div_iff_of_pos_right hq]
    have := Real.pi_pos
    have hx0 : 0 ≤ x := by linarith
    nlinarith [mul_le_mul hn hx (by linarith) (by positivity : (0 : ℝ) ≤ (n : ℝ) ^ 2)]
  calc |c n| * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)
      ≤ (n : ℝ) ^ k * Real.exp (-(π * x₀ / q) * n) :=
        mul_le_mul h1 h2 (Real.exp_pos _).le (by positivity)

theorem summable_bound (hq : 0 < q) {x₀ : ℝ} (hx₀ : 0 < x₀) :
    Summable fun n : ℕ ↦ (n : ℝ) ^ k * Real.exp (-(π * x₀ / q) * n) :=
  Real.summable_pow_mul_exp_neg_nat_mul k (by positivity)

theorem continuousOn_thetaC (hc : ∀ n, |c n| ≤ 1) (hq : 0 < q) :
    ContinuousOn (thetaC c k q) (Ioi 0) := by
  intro x hx
  have hx0 : 0 < x / 2 := by simp at hx; linarith
  have hon : ContinuousOn (thetaC c k q) (Ioi (x / 2)) := by
    refine continuousOn_tsum (fun n ↦ by fun_prop) (summable_bound (k := k) hq hx0) fun n y hy ↦ ?_
    exact norm_term_le hc hq hx0 (le_of_lt hy) n
  exact (hon.continuousAt (Ioi_mem_nhds (by simp at hx; linarith))).continuousWithinAt

theorem continuous_PhiC (hc : ∀ n, |c n| ≤ 1) (hq : 0 < q) : Continuous (PhiC c k q) := by
  unfold PhiC
  refine (Real.continuous_exp.comp (continuous_const.mul continuous_id)).mul ?_
  exact (continuousOn_thetaC hc hq).comp_continuous (by fun_prop) fun u ↦ Real.exp_pos _

/-- The decay constant `S = Σ n^k e^{−πn²/(2q)}`. -/
noncomputable def decayS (k : ℕ) (q : ℝ) : ℝ := ∑' n : ℕ, (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 / (2 * q))

theorem summable_decayS (hq : 0 < q) :
    Summable fun n : ℕ ↦ (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 / (2 * q)) := by
  refine (summable_bound (k := k) hq (by norm_num : (0 : ℝ) < 1 / 2)).of_nonneg_of_le
    (fun n ↦ by positivity) fun n ↦ ?_
  have hn : (n : ℝ) ≤ (n : ℝ) ^ 2 := by
    rcases Nat.eq_zero_or_pos n with h | h
    · simp [h]
    · have : (1 : ℝ) ≤ n := by exact_mod_cast h
      nlinarith
  gcongr
  rw [neg_mul, neg_div, neg_mul, neg_le_neg_iff,
    show π * (1 / 2) / q * (n : ℝ) = π * n / (2 * q) by ring]
  apply div_le_div_of_nonneg_right _ (by positivity)
  have := Real.pi_pos
  nlinarith

/-- **Decay of `Φ_c`.** -/
theorem abs_PhiC_le (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hq : 0 < q) {u : ℝ} (hu : 0 ≤ u) :
    |PhiC c k q u| ≤ decayS k q *
      (Real.exp ((1 + 2 * k) * u) * Real.exp (-(π / (2 * q)) * Real.exp (4 * u))) := by
  set x := Real.exp (4 * u) with hx
  have hx1 : 1 ≤ x := Real.one_le_exp (by linarith)
  have hterm : ∀ n : ℕ, ‖c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)‖ ≤
      Real.exp (-(π / (2 * q)) * x) * ((n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 / (2 * q))) := by
    intro n
    rcases Nat.eq_zero_or_pos n with h | h
    · subst h; simp [hc0]; positivity
    have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast h
    rw [Real.norm_eq_abs, abs_mul, abs_mul, abs_of_pos (Real.exp_pos _),
      abs_of_nonneg (show (0:ℝ) ≤ (n:ℝ) ^ k by positivity)]
    have h1 : |c n| * (n : ℝ) ^ k ≤ (n : ℝ) ^ k := by
      have := hc n; nlinarith [pow_nonneg (Nat.cast_nonneg n : (0 : ℝ) ≤ n) k]
    have h2 : Real.exp (-π * (n : ℝ) ^ 2 * x / q) ≤
        Real.exp (-(π / (2 * q)) * x) * Real.exp (-π * (n : ℝ) ^ 2 / (2 * q)) := by
      rw [← Real.exp_add]
      apply Real.exp_le_exp.mpr
      have := Real.pi_pos
      have hn2 : (1 : ℝ) ≤ (n : ℝ) ^ 2 := by nlinarith
      have key : (n : ℝ) ^ 2 + x ≤ 2 * ((n : ℝ) ^ 2 * x) := by
        nlinarith [mul_nonneg (sub_nonneg.mpr hn2) (sub_nonneg.mpr hx1)]
      rw [show -(π / (2 * q)) * x + -π * (n : ℝ) ^ 2 / (2 * q) = -(π * ((n : ℝ) ^ 2 + x)) / (2 * q) by
        ring, show -π * (n : ℝ) ^ 2 * x / q = -(π * (2 * ((n : ℝ) ^ 2 * x))) / (2 * q) by
        field_simp; try ring]
      apply div_le_div_of_nonneg_right _ (by positivity)
      nlinarith
    calc |c n| * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)
        ≤ (n : ℝ) ^ k * (Real.exp (-(π / (2 * q)) * x) * Real.exp (-π * (n : ℝ) ^ 2 / (2 * q))) :=
          mul_le_mul h1 h2 (Real.exp_pos _).le (by positivity)
      _ = _ := by ring
  have hsum : Summable fun n : ℕ ↦
      Real.exp (-(π / (2 * q)) * x) * ((n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 / (2 * q))) :=
    (summable_decayS hq).mul_left _
  have hθ : |thetaC c k q x| ≤ Real.exp (-(π / (2 * q)) * x) * decayS k q := by
    unfold thetaC decayS
    rw [← tsum_mul_left]
    have hs : Summable fun n : ℕ ↦ c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q) :=
      Summable.of_norm_bounded hsum hterm
    calc |∑' n : ℕ, c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)|
        = ‖∑' n : ℕ, c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)‖ := rfl
      _ ≤ ∑' n : ℕ, ‖c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)‖ :=
          norm_tsum_le_tsum_norm hs.norm
      _ ≤ _ := hs.norm.tsum_le_tsum hterm hsum
  unfold PhiC
  rw [abs_mul, abs_of_pos (Real.exp_pos _)]
  calc Real.exp ((1 + 2 * k) * u) * |thetaC c k q x|
      ≤ Real.exp ((1 + 2 * k) * u) * (Real.exp (-(π / (2 * q)) * x) * decayS k q) := by gcongr
    _ = _ := by ring

/-- **`Φ_c` is not identically zero** (the `n = 1` term dominates as `u → ∞`). -/
theorem exists_PhiC_ne_zero (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1) (hq : 0 < q) :
    ∃ u, PhiC c k q u ≠ 0 := by
  set f : ℝ → ℕ → ℝ := fun x n ↦ c n * (n : ℝ) ^ k * Real.exp (-π * ((n : ℝ) ^ 2 - 1) * x / q)
    with hf
  set g : ℕ → ℝ := fun n ↦ if n = 1 then 1 else 0 with hg
  have hbound : Summable fun n : ℕ ↦
      Real.exp (π / q) * ((n : ℝ) ^ k * Real.exp (-(π * 1 / q) * n)) :=
    (summable_bound (k := k) hq one_pos).mul_left _
  have hlim : Tendsto (fun x ↦ ∑' n, f x n) atTop (𝓝 (∑' n, g n)) := by
    refine tendsto_tsum_of_dominated_convergence hbound (fun n ↦ ?_) ?_
    · rcases Nat.lt_trichotomy n 1 with h | h | h
      · have : n = 0 := by omega
        subst this; simp [hf, hg, hc0]
      · subst h; simp [hf, hg, hc1]
      · have hn : (1 : ℝ) < (n : ℝ) ^ 2 := by
          have : (2 : ℝ) ≤ n := by exact_mod_cast h
          nlinarith
        have hne : n ≠ 1 := by omega
        simp only [hf, hg, hne, ite_false]
        have hr : 0 < π * ((n : ℝ) ^ 2 - 1) / q := by
          have := Real.pi_pos; apply div_pos _ hq; nlinarith
        have h1 : Tendsto (fun x : ℝ ↦ Real.exp (-(π * ((n : ℝ) ^ 2 - 1) / q) * x)) atTop (𝓝 0) := by
          have := Real.tendsto_exp_neg_atTop_nhds_zero.comp (tendsto_id.const_mul_atTop hr)
          refine this.congr fun x ↦ ?_
          simp only [Function.comp, id, neg_mul]
        have := h1.const_mul (c n * (n : ℝ) ^ k)
        rw [mul_zero] at this
        refine this.congr fun x ↦ ?_
        congr 2; ring
    · filter_upwards [eventually_ge_atTop 1] with x hx n
      rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; simp [hf, hc0]; positivity
      rw [Real.norm_eq_abs, abs_mul, abs_mul, abs_of_pos (Real.exp_pos _),
        abs_of_nonneg (show (0:ℝ) ≤ (n:ℝ) ^ k by positivity)]
      have h1 : |c n| * (n : ℝ) ^ k ≤ (n : ℝ) ^ k := by
        have := hc n; nlinarith [pow_nonneg (Nat.cast_nonneg n : (0 : ℝ) ≤ n) k]
      have h2 : Real.exp (-π * ((n : ℝ) ^ 2 - 1) * x / q) ≤
          Real.exp (π / q) * Real.exp (-(π * 1 / q) * n) := by
        rw [← Real.exp_add]
        apply Real.exp_le_exp.mpr
        have hn : (n : ℝ) - 1 ≤ (n : ℝ) ^ 2 - 1 := by
          rcases Nat.eq_zero_or_pos n with h | h
          · simp [h]
          · have : (1 : ℝ) ≤ n := by exact_mod_cast h
            nlinarith
        have := Real.pi_pos
        have hn0 : (0 : ℝ) ≤ (n : ℝ) ^ 2 - 1 ∨ (n : ℝ) ^ 2 - 1 < 0 := le_or_gt _ _
        rw [show π / q + -(π * 1 / q) * n = -(π * ((n : ℝ) - 1)) / q by ring,
          show -π * ((n : ℝ) ^ 2 - 1) * x / q = -(π * (((n : ℝ) ^ 2 - 1) * x)) / q by ring]
        apply div_le_div_of_nonneg_right _ hq.le
        rcases Nat.eq_zero_or_pos n with h | h
        · subst h; simp; nlinarith
        · have : (1 : ℝ) ≤ n := by exact_mod_cast h
          have hsq : 0 ≤ (n : ℝ) ^ 2 - 1 := by nlinarith
          nlinarith [mul_le_mul_of_nonneg_left hx hsq]
      calc |c n| * (n : ℝ) ^ k * Real.exp (-π * ((n : ℝ) ^ 2 - 1) * x / q)
          ≤ (n : ℝ) ^ k * (Real.exp (π / q) * Real.exp (-(π * 1 / q) * n)) :=
            mul_le_mul h1 h2 (Real.exp_pos _).le (by positivity)
        _ = _ := by ring
  have hg1 : ∑' n, g n = 1 := by simp [hg]
  rw [hg1] at hlim
  obtain ⟨X, hX⟩ := (eventually_atTop.mp (hlim.eventually (lt_mem_nhds (by norm_num : (1 / 2 : ℝ) < 1))))
  set x := max X 1 with hxdef
  have hx1 : 1 ≤ x := le_max_right _ _
  have hpos := hX x (le_max_left _ _)
  refine ⟨Real.log x / 4, ?_⟩
  unfold PhiC
  rw [show 4 * (Real.log x / 4) = Real.log x by ring, Real.exp_log (by linarith)]
  refine mul_ne_zero (Real.exp_pos _).ne' ?_
  intro h0
  have e : ∑' n, f x n = Real.exp (π * x / q) * thetaC c k q x := by
    unfold thetaC
    rw [← tsum_mul_left]
    congr 1; funext n
    simp only [hf]
    rw [mul_comm (Real.exp (π * x / q)), mul_assoc (c n * (n : ℝ) ^ k) (Real.exp _) (Real.exp _),
      ← Real.exp_add]
    congr 2; ring
  rw [e, h0, mul_zero] at hpos
  norm_num at hpos

/-- **The theta kernel as a decay kernel**, given its evenness (the theta functional equation with
root number `+1`). -/
noncomputable def thetaDecayKernel (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1)
    (hq : 0 < q) (heven : ∀ u, PhiC c k q (-u) = PhiC c k q u) : DecayKernel where
  Φ := PhiC c k q
  cont := continuous_PhiC hc hq
  even := heven
  a := 1 + 2 * k
  b := π / (2 * q)
  C := decayS k q
  hb := by have := Real.pi_pos; positivity
  C_nonneg := tsum_nonneg fun n ↦ by positivity
  bound := fun hu ↦ abs_PhiC_le hc hc0 hq hu
  ne := exists_PhiC_ne_zero hc hc0 hc1 hq

end DBN.Gen
