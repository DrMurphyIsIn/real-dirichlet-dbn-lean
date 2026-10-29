import GenStrip

/-! bb (AI review, NOT an operator read-back), 2026-10-29: D2c audit.  `oai` below is OpenAI's
`OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re` statement copied verbatim (binders closed) from
~/oai-math @adc7f124 lean/ComparatorChallenges/DirichletSevenEighths.lean (md5 4870cf09); it is a HYPOTHESIS here. -/

open Complex

namespace BbD2c

variable {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N} {c : ℕ → ℝ} {k : ℕ}

/-- OpenAI's verbatim Dirichlet 7/8 statement implies the contrarian's generic `hL` for any χ ≠ 1. -/
theorem hL_of_oai (oai : (∀ {q : ℕ} [NeZero q] (χ : DirichletCharacter ℂ q) {s : ℂ},
      (7 / 8 : ℝ) < s.re → ¬ (χ = 1 ∧ s = 1) → _root_.DirichletCharacter.LFunction χ s ≠ 0)) (hχ1 : χ ≠ 1) :
    ∀ s : ℂ, (7 / 8 : ℝ) < s.re → DirichletCharacter.LFunction χ s ≠ 0 :=
  fun _ hs ↦ oai χ hs (fun h ↦ hχ1 h.1)

/-- D2c with OpenAI's verbatim statement as the only L-function hypothesis (still CONDITIONAL on heven). -/
theorem dirichlet_real_zeros_of_oai (oai : (∀ {q : ℕ} [NeZero q] (χ : DirichletCharacter ℂ q) {s : ℂ},
      (7 / 8 : ℝ) < s.re → ¬ (χ = 1 ∧ s = 1) → _root_.DirichletCharacter.LFunction χ s ≠ 0))
    (hprim : χ.IsPrimitive) (hχ1 : χ ≠ 1) (hχc : ∀ n : ℕ, χ n = (c n : ℂ))
    (hc : ∀ n, |c n| ≤ 1) (hc0 : c 0 = 0) (hc1 : c 1 = 1)
    (hgam : ∀ s, χ.gammaFactor s = Gammaℝ (s + k))
    (heven : ∀ u, DBN.Gen.PhiC c k N (-u) = DBN.Gen.PhiC c k N u) :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ,
      (DBN.Gen.thetaDecayKernel hc hc0 hc1 (by exact_mod_cast (NeZero.pos N)) heven).Hd t z = 0 → z.im = 0 :=
  DBN.Gen.dirichlet_real_zeros hprim hχ1 hχc hc hc0 hc1 hgam heven (hL_of_oai oai hχ1)

end BbD2c

open Lean Meta Elab Command in
/-- Closure walk from `root` over types, values, constructors and recursor rules; returns (axioms in closure, #constants). -/
def bbWalk (env : Environment) (root : Name) : Array Name × Nat := Id.run do
  let mut seen : NameSet := {}
  let mut stack : Array Name := #[root]
  let mut axs : Array Name := #[]
  let mut fuel := 10000000
  while fuel > 0 do
    fuel := fuel - 1
    match stack.back? with
    | none => break
    | some c =>
      stack := stack.pop
      if seen.contains c then continue
      seen := seen.insert c
      match env.find? c with
      | none => pure ()
      | some ci =>
        let mut es : Array Expr := #[ci.type]
        match ci with
        | .axiomInfo _ => axs := axs.push c
        | .thmInfo v => es := es.push v.value
        | .defnInfo v => es := es.push v.value
        | .opaqueInfo v => es := es.push v.value
        | .inductInfo v => stack := stack ++ v.ctors.toArray
        | .ctorInfo v => stack := stack.push v.induct
        | .recInfo v => for r in v.rules do es := es.push r.rhs
        | _ => pure ()
        for e in es do
          for d in e.getUsedConstants do
            unless seen.contains d do stack := stack.push d
  return (axs, seen.size)

open Lean Meta Elab Command in
elab "#bb_audit " id:ident : command => do
  let env ← getEnv
  let n ← liftCoreM (realizeGlobalConstNoOverload id)
  let (axs, k) := bbWalk env n
  let ca ← liftCoreM (collectAxioms n)
  let sw := (axs.map toString).qsort (· < ·)
  let sc := (ca.map toString).qsort (· < ·)
  logInfo m!"bb_audit {n}: closure constants = {k}; walk axioms = {sw}; collectAxioms = {sc}; agree = {sw == sc}"
  let ci ← getConstInfo n
  let mods := env.header.moduleNames
  let mut lines : Array String := #[]
  for c in (ci.type.getUsedConstants.map toString).qsort (· < ·) do
    let m := match env.getModuleIdxFor? c.toName with
      | some i => toString (mods[i.toNat]!)
      | none => "(this file)"
    lines := lines.push s!"{c} <- {m}"
  logInfo m!"bb_audit {n}: statement constants and their modules:\n{String.intercalate "\n" lines.toList}"

set_option pp.numericTypes true in
#check @DBN.Gen.zero_strip
set_option pp.numericTypes true in
#check @DBN.Gen.dirichlet_real_zeros
#print axioms DBN.Gen.inv_eq_self_of_real
#print axioms DBN.Gen.completed_ne_zero
#print axioms DBN.Gen.zero_strip
#print axioms DBN.Gen.dirichlet_real_zeros
#print axioms BbD2c.dirichlet_real_zeros_of_oai
#bb_audit DBN.Gen.dirichlet_real_zeros
#bb_audit BbD2c.dirichlet_real_zeros_of_oai
