import GaussBridge
-- NEGATIVE CONTROLS (bb): T1, T3 FALSE statements (genuine rejects expected); T2 proof-reach control. 3 errors expected.
open Complex in
-- T1: constant 1/4 instead of 1/8 (false: Lambda(., chi) is not identically zero).
example {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) (z : ℂ) :
    DBN.Gen.Hchi χ 0 z = (1 / 4) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + DBN.Gen.parityK χ) / 2) *
      DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) := DBN.Gen.Hchi_bridge χ hprim hχ1 hreal z
open Complex in
-- T2: drop primitivity (proof-reach control).
example {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) (z : ℂ) :
    DBN.Gen.Hchi χ 0 z = (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + DBN.Gen.parityK χ) / 2) *
      DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) := DBN.Gen.Hchi_bridge χ (by assumption) hχ1 hreal z
open Complex in
-- T3: wrong parity shift k -> 1 - k in the N-power (false for N > 1).
example {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1)
    (hreal : ∀ n : ℕ, (χ n).im = 0) (z : ℂ) :
    DBN.Gen.Hchi χ 0 z = (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + (1 - (DBN.Gen.parityK χ : ℂ))) / 2) *
      DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) := DBN.Gen.Hchi_bridge χ hprim hχ1 hreal z
