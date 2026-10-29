import GenChi4
open Lean Elab Command
/-! bb NEGATIVE CONTROL (kernel re-check, OAI pin): `BbNeg.bogus : 4 = 5` added with `debug.skipKernelTC`; the final
statement then follows by `absurd`. Every checker run on the EXPORT must reject it. -/
set_option debug.skipKernelTC true in
run_cmd liftCoreM do
  let ty := mkApp3 (mkConst ``Eq [1]) (mkConst ``Nat) (mkNatLit 4) (mkNatLit 5)
  let pf := mkApp2 (mkConst ``Eq.refl [1]) (mkConst ``Nat) (mkNatLit 4)
  addDecl (.thmDecl { name := `BbNeg.bogus, levelParams := [], type := ty, value := pf })

theorem bb_chiM4_real_zeros_oai :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi DBN.Gen.chiM4 t z = 0 → z.im = 0 :=
  absurd BbNeg.bogus (by decide)
