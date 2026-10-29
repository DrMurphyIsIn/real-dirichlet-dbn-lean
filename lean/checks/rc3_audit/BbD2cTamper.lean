import GenStrip

open Complex
-- WEAK CONTROL (bb): heat time 1/4 < 9/32 with the same proof must FAIL (proof-reach test, not a falsity test).
example {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N} {c : ℕ → ℝ} {k : ℕ}
    (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1)
    (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (heven : ∀ u, DBN.Gen.PhiC c k N (-u) = DBN.Gen.PhiC c k N u)
    (hL : ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0) :
    ∀ t : ℝ, 1 / 4 ≤ t → ∀ z : ℂ,
      (DBN.Gen.thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd t z = 0 → z.im = 0 := by
  intro t ht
  exact DBN.Gen.DecayKernel.real_zeros_of_strip _ (by norm_num)
    (DBN.Gen.zero_strip hprim hχ1 hχc hc hc0 hc1 hgam heven hL) t (by linarith)
