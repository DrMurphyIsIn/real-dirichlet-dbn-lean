import GaussPrime
open Complex
-- NEGATIVE CONTROLS (bb): both statements are FALSE (genuine rejects expected; 2 errors).
-- T1: (1 + I) -> (1 - I): false at N = 1 (G(1) = 1, but (1 - I)(1 - I)/2 = -I).
example (N : ℕ) [NeZero N] : DBN.Gen.gaussG N = (1 - I) * (1 + (-I) ^ N) / 2 * (Real.sqrt N : ℂ) := DBN.Gen.gaussG_eq N
-- T2: rootNumber = -1 for a real nontrivial character mod an odd prime.
example (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (χ : DirichletCharacter ℂ p) (hχ1 : χ ≠ 1) (hreal : ∀ n : ℕ, (χ n).im = 0) :
    DirichletCharacter.rootNumber χ = -1 := DBN.Gen.rootNumber_eq_one_of_prime hp2 χ hχ1 hreal
