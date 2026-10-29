import BbOaiRealPrim
-- NEGATIVE CONTROLS (bb): 2 errors expected.
-- T1 (genuine): OpenAI's theorem does not give L != 0 on Re s > 3/4.
example {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hχ1 : χ ≠ 1) :
    ∀ s : ℂ, (3 / 4 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0 :=
  fun _ hs ↦ OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re χ hs (fun h ↦ hχ1 h.1)
-- T2 (proof-reach): heat time 1/4.
example : ∀ {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N), χ.IsPrimitive → χ ≠ 1 → (∀ n : ℕ, (χ n).im = 0) →
    ∀ t : ℝ, 1 / 4 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi χ t z = 0 → z.im = 0 := bb_real_primitive_real_zeros_oai
