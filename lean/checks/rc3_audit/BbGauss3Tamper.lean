import GaussSign
-- NEGATIVE CONTROLS (bb): FALSE statements, genuine rejects expected (2 errors).
-- T1: root number -1 for every real primitive chi (false already for the trivial character mod 1).
example {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hprim : χ.IsPrimitive) (hreal : ∀ n : ℕ, (χ n).im = 0) :
    χ.rootNumber = -1 := DBN.Gen.rootNumber_eq_one_of_real_primitive χ hprim hreal
-- T2: drop primitivity (false: the trivial character mod 2 is real, imprimitive, with junk root number != 1).
example {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (hreal : ∀ n : ℕ, (χ n).im = 0) :
    χ.rootNumber = 1 := DBN.Gen.rootNumber_eq_one_of_real_primitive χ (by assumption) hreal
