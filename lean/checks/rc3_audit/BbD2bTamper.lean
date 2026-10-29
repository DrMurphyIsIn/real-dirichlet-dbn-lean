import GenBridge

open Complex
-- NEGATIVE CONTROL (bb): the bridge with factor 1/4 instead of 1/8 must FAIL (1 error expected).
example {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N} {c : ℕ → ℝ} {k : ℕ} (hχ1 : χ ≠ 1)
    (hχc : ∀ n : ℕ, χ n = (c n : ℂ)) (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1)
    (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k)) (heven : ∀ u, DBN.Gen.PhiC c k N (-u) = DBN.Gen.PhiC c k N u)
    (z : ℂ) :
    (DBN.Gen.thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd 0 z =
      (1 / 4) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + k) / 2) *
        DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2) :=
  DBN.Gen.bridge hχ1 hχc hc hc0 hc1 hgam heven z
