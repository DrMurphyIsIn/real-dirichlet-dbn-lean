import GaussSign
import OAI.NumberTheory.DirichletL.Nonvanishing

/-! bb (AI work, NOT an operator read-back), 2026-10-29, user-approved: ONE environment at OpenAI's pins (v4.34.1, Mathlib
d13f23b) with OpenAI's proved Dirichlet 7/8 theorem and our unchanged chain incl. the contrarian's Gauss sign theorem (S1-S3). -/

/-- **Lambda_chi <= 9/32 for EVERY real primitive Dirichlet character chi != 1**: every zero of `Hchi chi t` is real for
`t >= 9/32`.  No hypotheses beyond the data. -/
theorem bb_real_primitive_real_zeros_oai :
    ∀ {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N), χ.IsPrimitive → χ ≠ 1 → (∀ n : ℕ, (χ n).im = 0) →
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi χ t z = 0 → z.im = 0 :=
  fun χ hprim hχ1 hreal ↦ DBN.Gen.real_primitive_real_zeros χ hprim hχ1 hreal (fun _ hs ↦
    OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re χ hs (fun h ↦ hχ1 h.1))
