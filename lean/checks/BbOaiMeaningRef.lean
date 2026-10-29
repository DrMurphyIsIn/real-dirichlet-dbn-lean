import GaussSign
set_option pp.all true in
#check (∀ {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N), χ.IsPrimitive → χ ≠ 1 → (∀ n : ℕ, (χ n).im = 0) → ∀ z : ℂ,
    DBN.Gen.Hchi χ 0 z = (1 / 8) * (N : ℂ) ^ ((1 / 2 + Complex.I * z / 2 + DBN.Gen.parityK χ) / 2) *
      DirichletCharacter.completedLFunction χ (1 / 2 + Complex.I * z / 2) : Prop)
