import Mathlib

/-! DQ-1 P5 statement layer (P5/memo.md §A.13.4, C2), with bb's three REVIEW_P5_FINAL notes applied, built by the DQ-1 Lean
builder. The shared definitions are verbatim from §A.13.4.
- `C2bound_lt_9_32` and `STL_applies` are PROVED by pure real analysis. No Arb input is used: the monotonicity of T on
  [L₀, 4·10⁴] is replaced by the bound T ≤ 10⁻⁴ + f(k) with f(k) = log(1 + k/2)/k, and f is antitone on (0, ∞).
- `STL` carries bb's added hypothesis `hL : 40000 < Lc m` (note 1).
- bb's note 3 (negative x in `TL_floor_C2`) is handled by `S_neg`/`TL_floor_C2_of_nonneg`. They reduce negative x to x ≥ 0
  under the reflection hypothesis L(s̄, χ) = conj L(s, χ). That hypothesis is true for real χ, but it is not in Mathlib, so here
  it is stated explicitly.
- The cited / Arb-certified items (`C2_large_conductor`, `TL_floor_C2`, `P2'_uniform`, `LX`, `STL`) are recorded as `Prop`s.
  No `axiom` and no `sorry` is used. -/

open Complex MeasureTheory

noncomputable section

namespace C2

variable {m : ℕ} [NeZero m]

/-- parity a ∈ {0,1}: a = 0 for even χ, a = 1 for odd χ -/
def parity (χ : DirichletCharacter ℂ m) : ℕ := if χ (-1) = 1 then 0 else 1

/-- real-valued character -/
def IsRealChar (χ : DirichletCharacter ℂ m) : Prop := ∀ n : ZMod m, (χ n).im = 0

/-- completed L-function ξ_L(s) = (m/π)^{(s+a)/2} Γ((s+a)/2) L(s,χ)  (FGMPS §2.3) -/
def xi (χ : DirichletCharacter ℂ m) (s : ℂ) : ℂ :=
  ((m : ℂ) / (Real.pi : ℂ)) ^ ((s + (parity χ : ℂ)) / 2) * Complex.Gamma ((s + (parity χ : ℂ)) / 2) *
    DirichletCharacter.LFunction χ s

/-- heat flow, FGMPS (4.1), for t > 0:  H_t(z) = ∫ ξ((1+iz)/2 + √t v) e^{-v²}/√π dv -/
def H (χ : DirichletCharacter ℂ m) (t : ℝ) (z : ℂ) : ℂ :=
  ∫ v : ℝ, xi χ ((1 + I * z) / 2 + ((Real.sqrt t * v : ℝ) : ℂ)) * ((Real.exp (-v ^ 2) / Real.sqrt Real.pi : ℝ) : ℂ)

/-- S(x,p,t) = -Im (H_t'/H_t)(x + i p) -/
def S (χ : DirichletCharacter ℂ m) (x p t : ℝ) : ℝ :=
  -((deriv (H χ t) ((x : ℂ) + (p : ℂ) * I)) / H χ t ((x : ℂ) + (p : ℂ) * I)).im

def Lc (m : ℕ) : ℝ := Real.log ((m : ℝ) / Real.pi)
def L0 : ℝ := Real.log (10 ^ 8 / Real.pi)
def tmin (L : ℝ) : ℝ := min (1 / 10000) (4 / L)
def bC2 (L : ℝ) : ℝ := min (1 / 10000) (1 / L ^ 2)
def kC2 (L : ℝ) : ℝ := 4 / Real.sqrt 5 * (L / 4 - 1) - 2
def TC2 (L : ℝ) : ℝ :=
  tmin L + Real.log ((2 + kC2 L * (1 - 2 * tmin L)) / (2 + kC2 L * bC2 L)) / kC2 L
def C2bound (m : ℕ) : ℝ := TC2 (Lc m) + bC2 (Lc m) / 2

/-- the C2 TL domain (memo A.9.0) -/
def InDomain (L t : ℝ) : Prop := L0 ≤ L ∧ tmin L ≤ t ∧ t ≤ TC2 L

/-! ### Real-analysis helpers (new) -/

/-- f(k) = log(1 + k/2)/k is antitone on (0, ∞): tangent-line bound for log, plus log y ≥ 1 - 1/y. -/
lemma logratio_anti {K k : ℝ} (hK : 0 < K) (hKk : K ≤ k) :
    Real.log (1 + k / 2) / k ≤ Real.log (1 + K / 2) / K := by
  have hk : 0 < k := lt_of_lt_of_le hK hKk
  have hy0 : 0 < 1 + K / 2 := by positivity
  have hy : 0 < 1 + k / 2 := by positivity
  -- tangent bound: log(1+k/2) ≤ log(1+K/2) + (k-K)/(2+K)
  have htan : Real.log (1 + k / 2) ≤ Real.log (1 + K / 2) + (k - K) / (2 + K) := by
    have h := Real.log_le_sub_one_of_pos (div_pos hy hy0)
    rw [Real.log_div hy.ne' hy0.ne'] at h
    have : (1 + k / 2) / (1 + K / 2) - 1 = (k - K) / (2 + K) := by field_simp; ring
    linarith
  -- log(1+K/2) ≥ K/(2+K)
  have hlow : K / (2 + K) ≤ Real.log (1 + K / 2) := by
    have h := Real.one_sub_inv_le_log_of_pos hy0
    have : 1 - (1 + K / 2)⁻¹ = K / (2 + K) := by field_simp; ring
    linarith
  rw [div_le_div_iff₀ hk hK]
  have hkK : 0 ≤ k - K := by linarith
  have h1 : Real.log (1 + k / 2) * K ≤ (Real.log (1 + K / 2) + (k - K) / (2 + K)) * K :=
    mul_le_mul_of_nonneg_right htan hK.le
  have h2 : (k - K) * K ≤ (k - K) * Real.log (1 + K / 2) * (2 + K) := by
    have hm := mul_le_mul_of_nonneg_left hlow hkK
    have e : (k - K) * K = (k - K) * (K / (2 + K)) * (2 + K) := by field_simp
    rw [e]; exact mul_le_mul_of_nonneg_right hm (by positivity)
  have h2' : (k - K) / (2 + K) * K ≤ (k - K) * Real.log (1 + K / 2) := by
    rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)]; exact h2
  nlinarith [h1, h2']

/-- T(L) ≤ tmin L + f(k) whenever k > 0, tmin ≤ 10⁻⁴ and b ≥ 0 (N ≤ 2 + k, D ≥ 2). -/
lemma TC2_le (L : ℝ) (hk : 0 < kC2 L) (ht0 : 0 ≤ tmin L) (ht1 : tmin L ≤ 1 / 10000) (hb : 0 ≤ bC2 L) :
    TC2 L ≤ tmin L + Real.log (1 + kC2 L / 2) / kC2 L := by
  unfold TC2
  set k := kC2 L
  have hN : 0 < 2 + k * (1 - 2 * tmin L) := by
    have : 0 < 1 - 2 * tmin L := by linarith
    positivity
  have hD : 2 ≤ 2 + k * bC2 L := by have := mul_nonneg hk.le hb; linarith
  have hratio : (2 + k * (1 - 2 * tmin L)) / (2 + k * bC2 L) ≤ 1 + k / 2 := by
    rw [div_le_iff₀ (by linarith)]
    have : 2 + k * (1 - 2 * tmin L) ≤ 2 + k := by nlinarith
    nlinarith
  have hlog : Real.log ((2 + k * (1 - 2 * tmin L)) / (2 + k * bC2 L)) ≤ Real.log (1 + k / 2) :=
    Real.log_le_log (div_pos hN (by linarith)) hratio
  have := div_le_div_of_nonneg_right hlog hk.le
  linarith

lemma sqrt5_bounds : (2236 / 1000 : ℝ) ≤ Real.sqrt 5 ∧ Real.sqrt 5 ≤ 22361 / 10000 :=
  ⟨Real.le_sqrt_of_sq_le (by norm_num), Real.sqrt_le_iff.mpr ⟨by norm_num, by norm_num⟩⟩

/-- k(L) ≥ ((L - 4)/2.2361) - 2 for L ≥ 4. -/
lemma kC2_ge (L : ℝ) (hL : 4 ≤ L) : (L - 4) / (22361 / 10000) - 2 ≤ kC2 L := by
  obtain ⟨h1, h2⟩ := sqrt5_bounds
  have hs : 0 < Real.sqrt 5 := by linarith
  unfold kC2
  have e : 4 / Real.sqrt 5 * (L / 4 - 1) = (L - 4) / Real.sqrt 5 := by field_simp
  rw [e]
  have : (L - 4) / (22361 / 10000) ≤ (L - 4) / Real.sqrt 5 :=
    div_le_div_of_nonneg_left (by linarith) hs h2
  linarith

/-- exp f ≤ Taylor + Mathlib remainder, for 0 ≤ f ≤ 1. -/
lemma exp_le_taylor (f : ℝ) (hf0 : 0 ≤ f) (hf1 : f ≤ 1) (n : ℕ) (hn : 0 < n) :
    Real.exp f ≤ (∑ i ∈ Finset.range n, f ^ i / i.factorial) + f ^ n * (n.succ / (n.factorial * n)) := by
  have h := Real.exp_bound (x := f) (by rw [abs_of_nonneg hf0]; exact hf1) hn
  rw [abs_of_nonneg hf0] at h
  linarith [(abs_le.mp h).2]

/-- L₀ = log(10⁸/π) ≥ 17.25. -/
lemma L0_ge : (1725 / 100 : ℝ) ≤ L0 := by
  unfold L0
  have hpi := Real.pi_pos
  rw [Real.le_log_iff_exp_le (by positivity)]
  have he : Real.exp 1 < 27182818286 / 10000000000 := by
    have := Real.exp_one_lt_d9; norm_num at this ⊢; linarith
  have h17 : Real.exp 17 ≤ (27182818286 / 10000000000 : ℝ) ^ 17 := by
    rw [show (17 : ℝ) = (17 : ℕ) * 1 by norm_num, Real.exp_nat_mul]
    exact pow_le_pow_left₀ (Real.exp_pos 1).le he.le 17
  have hq := exp_le_taylor (1 / 4) (by norm_num) (by norm_num) 8 (by norm_num)
  have hpiu : Real.pi < 3141593 / 1000000 := by have := Real.pi_lt_d6; norm_num at this ⊢; linarith
  calc Real.exp (1725 / 100) = Real.exp 17 * Real.exp (1 / 4) := by rw [← Real.exp_add]; norm_num
    _ ≤ (27182818286 / 10000000000 : ℝ) ^ 17 *
        ((∑ i ∈ Finset.range 8, (1 / 4 : ℝ) ^ i / i.factorial) + (1 / 4) ^ 8 * ((8 : ℕ).succ / ((8 : ℕ).factorial * 8))) :=
        mul_le_mul h17 hq (Real.exp_pos _).le (by positivity)
    _ ≤ 10 ^ 8 / (3141593 / 1000000) := by norm_num [Finset.sum_range_succ, Nat.factorial]
    _ ≤ 10 ^ 8 / Real.pi := div_le_div_of_nonneg_left (by norm_num) hpi hpiu.le

/-! ### item 10′: the numerical corollary — PROVED (pure real analysis) -/

/-- item 10': the numerical corollary (pure real analysis; Arb-certified in memo A.11.1 / A.13.1) -/
theorem C2bound_lt_9_32 (hm : 10 ^ 8 ≤ m) : C2bound m < 9 / 32 := by
  have hpi := Real.pi_pos
  set L := Lc m
  have hL0 : L0 ≤ L := by
    unfold L Lc L0
    apply Real.log_le_log (by positivity)
    apply div_le_div_of_nonneg_right _ hpi.le
    exact_mod_cast hm
  have hL : (1725 / 100 : ℝ) ≤ L := le_trans L0_ge hL0
  have hLpos : 0 < L := by linarith
  have ht0 : 0 ≤ tmin L := le_min (by norm_num) (by positivity)
  have ht1 : tmin L ≤ 1 / 10000 := min_le_left _ _
  have hb0 : 0 ≤ bC2 L := le_min (by norm_num) (by positivity)
  have hb1 : bC2 L ≤ 1 / (1725 / 100) ^ 2 := by
    refine (min_le_right _ _).trans ?_
    apply one_div_le_one_div_of_le (by positivity)
    exact pow_le_pow_left₀ (by norm_num) hL 2
  have hk : (3925 / 1000 : ℝ) ≤ kC2 L := by
    have := kC2_ge L (by linarith)
    have : (3925 / 1000 : ℝ) ≤ (L - 4) / (22361 / 10000) - 2 := by
      rw [le_sub_iff_add_le, le_div_iff₀ (by norm_num)]; linarith
    linarith
  have hkpos : 0 < kC2 L := by linarith
  have hT := TC2_le L hkpos ht0 ht1 hb0
  have hf := logratio_anti (K := 3925 / 1000) (by norm_num) hk
  -- log(1 + 3.925/2) = log 2.9625 ≤ 1.0862
  have hlog : Real.log (1 + (3925 / 1000 : ℝ) / 2) ≤ 10862 / 10000 := by
    rw [Real.log_le_iff_le_exp (by norm_num)]
    have he : (27182818283 / 10000000000 : ℝ) < Real.exp 1 := by
      have := Real.exp_one_gt_d9; norm_num at this ⊢; linarith
    have hq := Real.quadratic_le_exp_of_nonneg (x := 862 / 10000) (by norm_num)
    calc 1 + (3925 / 1000 : ℝ) / 2 ≤ (27182818283 / 10000000000) * (1 + 862 / 10000 + (862 / 10000) ^ 2 / 2) := by
          norm_num
      _ ≤ Real.exp 1 * Real.exp (862 / 10000) :=
          mul_le_mul he.le hq (by norm_num) (Real.exp_pos _).le
      _ = Real.exp (10862 / 10000) := by rw [← Real.exp_add]; norm_num
  have hfK : Real.log (1 + (3925 / 1000 : ℝ) / 2) / (3925 / 1000) ≤ (10862 / 10000) / (3925 / 1000) :=
    div_le_div_of_nonneg_right hlog (by norm_num)
  unfold C2bound
  have : (1 / 10000 : ℝ) + (10862 / 10000) / (3925 / 1000) + (1 / (1725 / 100) ^ 2) / 2 < 9 / 32 := by norm_num
  linarith

/-! ### item 13′: the domain fact used to apply STL — PROVED -/

/-- item 13': the domain fact used to apply STL (REVIEW_P5_A11, (stl) rule) -/
theorem STL_applies (L t : ℝ) (hL : 40000 < L) (hD : InDomain L t) :
    t ≤ 2 * (175 / 10000) ^ 2 ∧ 2618 / 1000 ≤ (1 + Real.sqrt 5) / 2 + t * L / 4 := by
  obtain ⟨_, htl, htu⟩ := hD
  have hLpos : 0 < L := by linarith
  have h4L : 4 / L ≤ 1 / 10000 := by rw [div_le_div_iff₀ hLpos (by norm_num)]; linarith
  have htmin : tmin L = 4 / L := min_eq_right h4L
  constructor
  · have ht0 : 0 ≤ tmin L := by rw [htmin]; positivity
    have ht1 : tmin L ≤ 1 / 10000 := min_le_left _ _
    have hb0 : 0 ≤ bC2 L := le_min (by norm_num) (by positivity)
    have hk : (17884 : ℝ) ≤ kC2 L := by
      have := kC2_ge L (by linarith)
      have : (17884 : ℝ) ≤ (L - 4) / (22361 / 10000) - 2 := by
        rw [le_sub_iff_add_le, le_div_iff₀ (by norm_num)]; linarith
      linarith
    have hT := TC2_le L (by linarith) ht0 ht1 hb0
    have hf := logratio_anti (K := 17884) (by norm_num) hk
    -- log(1 + 17884/2) = log 8943 ≤ 9.15
    have hlog : Real.log (1 + (17884 : ℝ) / 2) ≤ 915 / 100 := by
      rw [Real.log_le_iff_le_exp (by norm_num)]
      have he : (27182818283 / 10000000000 : ℝ) < Real.exp 1 := by
        have := Real.exp_one_gt_d9; norm_num at this ⊢; linarith
      have h9 : (27182818283 / 10000000000 : ℝ) ^ 9 ≤ Real.exp 9 := by
        rw [show (9 : ℝ) = (9 : ℕ) * 1 by norm_num, Real.exp_nat_mul]
        exact pow_le_pow_left₀ (by norm_num) he.le 9
      have hq := Real.add_one_le_exp (15 / 100 : ℝ)
      calc 1 + (17884 : ℝ) / 2 ≤ (27182818283 / 10000000000) ^ 9 * (15 / 100 + 1) := by norm_num
        _ ≤ Real.exp 9 * Real.exp (15 / 100) := mul_le_mul h9 hq (by norm_num) (Real.exp_pos _).le
        _ = Real.exp (915 / 100) := by rw [← Real.exp_add]; norm_num
    have hfK : Real.log (1 + (17884 : ℝ) / 2) / 17884 ≤ (915 / 100) / 17884 :=
      div_le_div_of_nonneg_right hlog (by norm_num)
    have : (1 / 10000 : ℝ) + (915 / 100) / 17884 ≤ 2 * (175 / 10000) ^ 2 := by norm_num
    linarith
  · rw [htmin] at htl
    have h1 : 1 ≤ t * L / 4 := by
      rw [div_le_iff₀ hLpos] at htl
      linarith
    have := sqrt5_bounds.1
    linarith

/-! ### bb note 3: reflection S(-x) = S(x), from L(s̄, χ) = conj L(s, χ) (explicit hypothesis) -/

/-- H_t(-z̄) = conj H_t(z), given the Schwarz reflection of L(s, χ) (true for real χ; not in Mathlib). -/
lemma H_conj (χ : DirichletCharacter ℂ m)
    (hLconj : ∀ s : ℂ, DirichletCharacter.LFunction χ ((starRingEnd ℂ) s) =
      (starRingEnd ℂ) (DirichletCharacter.LFunction χ s))
    (t : ℝ) (z : ℂ) : H χ t (-(starRingEnd ℂ) z) = (starRingEnd ℂ) (H χ t z) := by
  have hxi : ∀ s : ℂ, xi χ ((starRingEnd ℂ) s) = (starRingEnd ℂ) (xi χ s) := by
    intro s
    unfold xi
    have hw : ((starRingEnd ℂ) s + (parity χ : ℂ)) / 2 = (starRingEnd ℂ) ((s + (parity χ : ℂ)) / 2) := by
      simp [map_div₀, map_add, map_natCast, map_ofNat]
    have hbase : ((m : ℂ) / (Real.pi : ℂ)) = (((m : ℝ) / Real.pi : ℝ) : ℂ) := by push_cast; rfl
    have hpos : 0 < (m : ℝ) / Real.pi := by
      have : (0 : ℝ) < m := by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne m)
      positivity
    rw [hw, Complex.Gamma_conj, hLconj, hbase]
    have hcp : ((((m : ℝ) / Real.pi : ℝ) : ℂ)) ^ ((starRingEnd ℂ) ((s + (parity χ : ℂ)) / 2)) =
        (starRingEnd ℂ) (((((m : ℝ) / Real.pi : ℝ) : ℂ)) ^ ((s + (parity χ : ℂ)) / 2)) := by
      rw [Complex.cpow_conj _ _ (by rw [Complex.arg_ofReal_of_nonneg hpos.le]; exact Real.pi_ne_zero.symm),
        Complex.conj_ofReal]
    rw [hcp, map_mul, map_mul]
  unfold H
  rw [← integral_conj]
  refine integral_congr_ae (Filter.Eventually.of_forall (fun v => ?_))
  simp only
  have hs : (1 + I * -(starRingEnd ℂ) z) / 2 + ((Real.sqrt t * v : ℝ) : ℂ)
      = (starRingEnd ℂ) ((1 + I * z) / 2 + ((Real.sqrt t * v : ℝ) : ℂ)) := by
    simp [map_div₀, map_add, map_mul, Complex.conj_I, map_ofNat]
  rw [hs, hxi, map_mul, Complex.conj_ofReal]

/-- S is even in x under the reflection hypothesis (bb note 3). -/
lemma S_neg (χ : DirichletCharacter ℂ m)
    (hLconj : ∀ s : ℂ, DirichletCharacter.LFunction χ ((starRingEnd ℂ) s) =
      (starRingEnd ℂ) (DirichletCharacter.LFunction χ s))
    (x p t : ℝ) : S χ (-x) p t = S χ x p t := by
  set F := H χ t
  have hF : ∀ z, F z = (starRingEnd ℂ) (F (-(starRingEnd ℂ) z)) := by
    intro z
    have := H_conj χ hLconj t (-(starRingEnd ℂ) z)
    simp only [map_neg, Complex.conj_conj, neg_neg] at this
    simp only [F]
    rw [this]
  have hFeq : F = (starRingEnd ℂ) ∘ (fun u => F (-u)) ∘ (starRingEnd ℂ) := by
    funext z; simp only [Function.comp]; exact hF z
  have hderiv : ∀ w, deriv F w = -(starRingEnd ℂ) (deriv F (-(starRingEnd ℂ) w)) := by
    intro w
    conv_lhs => rw [hFeq]
    rw [deriv_conj_conj]
    simp only [Function.comp]
    rw [deriv_comp_neg, map_neg]
  set w : ℂ := ((-x : ℝ) : ℂ) + (p : ℂ) * I
  have hw : -(starRingEnd ℂ) w = (x : ℂ) + (p : ℂ) * I := by
    simp [w, Complex.conj_ofReal, Complex.conj_I]
    ring
  unfold S
  simp only [F] at hderiv hF
  rw [hderiv w, hF w, hw]
  rw [neg_div, ← map_div₀]
  simp only [Complex.neg_im, Complex.conj_im, neg_neg]

/-- bb note 3: the TL floor for x ≥ 0 extends to all real x under the reflection hypothesis. -/
theorem TL_floor_C2_of_nonneg (χ : DirichletCharacter ℂ m)
    (hLconj : ∀ s : ℂ, DirichletCharacter.LFunction χ ((starRingEnd ℂ) s) =
      (starRingEnd ℂ) (DirichletCharacter.LFunction χ s))
    (hfloor : ∀ t x : ℝ, InDomain (Lc m) t → 0 ≤ x → Lc m / 4 - 1 ≤ S χ x (Real.sqrt 5) t)
    (t x : ℝ) (hD : InDomain (Lc m) t) : Lc m / 4 - 1 ≤ S χ x (Real.sqrt 5) t := by
  rcases le_or_gt 0 x with hx | hx
  · exact hfloor t x hD hx
  · have := hfloor t (-x) hD (by linarith)
    have hs := S_neg χ hLconj (-x) (Real.sqrt 5) t
    rw [neg_neg] at hs
    linarith

/-! ### Cited / Arb-certified items, recorded as `Prop`s (NOT proved; no `axiom`) -/

/-- item 10: Theorem C2 (statement of record, memo A.13.1) — CITED-INPUT (assembly of FGMPS Thm 2.6, Planat Thm 2.1 /
Prop 2.3, H-B Thm 9, P2′ and the TL floor). -/
def C2_large_conductor_statement : Prop :=
  ∀ {m : ℕ} [NeZero m], 10 ^ 8 ≤ m → ∀ (χ : DirichletCharacter ℂ m), χ.IsPrimitive → IsRealChar χ →
    ∀ t : ℝ, C2bound m ≤ t → ∀ z : ℂ, H χ t z = 0 → z.im = 0

/-- item 10'': the TL floor on the whole C2 domain — NEEDS-MACHINERY (Arb certificates G1 / LX / STL). For negative x see
`TL_floor_C2_of_nonneg` (bb note 3). -/
def TL_floor_C2_statement : Prop :=
  ∀ {m : ℕ} [NeZero m], 10 ^ 8 ≤ m → ∀ (χ : DirichletCharacter ℂ m), χ.IsPrimitive → IsRealChar χ →
    ∀ (t x : ℝ), InDomain (Lc m) t → Lc m / 4 - 1 ≤ S χ x (Real.sqrt 5) t

/-- item 11: P2′, uniform confinement (Lemma Z′, memo A.12.2) — CITED-INPUT (FGMPS Thm 4.3 / Prop 4.18) + Arb. -/
def P2'_uniform_statement : Prop :=
  ∀ {m : ℕ} [NeZero m], 10 ^ 8 ≤ m → ∀ (χ : DirichletCharacter ℂ m), χ.IsPrimitive → IsRealChar χ →
    ∀ (t : ℝ), (tmin (Lc m) ≤ t ∧ t ≤ 1 / 2) → ∀ (x y : ℝ),
    4 * Real.exp (8 * max 40000 (Lc m) - Lc m) ≤ |x| →
    (min (1 / 100) (1 / Lc m) ≤ |y| ∧ |y| ≤ 1) →
    H χ t ((x : ℂ) + (y : ℂ) * I) ≠ 0

/-- item 12: LX (memo A.9.2 + R-x re-run A.11.1; certified worst -0.7689) — NEEDS-MACHINERY (Arb cover). -/
def LX_statement : Prop :=
  ∀ {m : ℕ} [NeZero m], 10 ^ 8 ≤ m → ∀ (χ : DirichletCharacter ℂ m), χ.IsPrimitive → IsRealChar χ →
    Lc m ≤ 40000 → ∀ (t x : ℝ), InDomain (Lc m) t → 10000 ≤ |x| →
    Lc m / 4 - 77 / 100 ≤ S χ x (Real.sqrt 5) t

/-- item 13: STL (memo A.9.3, with N-c), **with bb's added hypothesis `hL : 40000 < Lc m`** (REVIEW_P5_FINAL note 1) —
CITED-INPUT (special-function bounds, FE pieces at L ≥ 4·10⁴) + Arb constants. -/
def STL_statement : Prop :=
  ∀ {m : ℕ} [NeZero m] (χ : DirichletCharacter ℂ m), χ.IsPrimitive → IsRealChar χ →
    40000 < Lc m → ∀ (t x : ℝ), 0 < t →
    t ≤ 2 * (175 / 10000) ^ 2 → 2618 / 1000 ≤ (1 + Real.sqrt 5) / 2 + t * Lc m / 4 →
    Lc m / 4 - 18 / 100 ≤ S χ x (Real.sqrt 5) t

end C2

#print axioms C2.C2bound_lt_9_32
#print axioms C2.STL_applies
#print axioms C2.H_conj
#print axioms C2.S_neg
#print axioms C2.TL_floor_C2_of_nonneg
