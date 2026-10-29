import GenChi4

/-! bb (AI review, NOT an operator read-back), 2026-10-29: D2b' + chi_{-4} audit. `oai` = OpenAI's verbatim Dirichlet 7/8
statement (DirichletSevenEighths.lean 4870cf09) as a HYPOTHESIS. -/

open Complex

namespace BbD2bp

/-- Lambda_{chi_{-4}} <= 9/32 with OpenAI's verbatim statement as the ONLY hypothesis. -/
theorem chiM4_real_zeros_of_oai (oai : (∀ {q : ℕ} [NeZero q] (χ : DirichletCharacter ℂ q) {s : ℂ},
      (7 / 8 : ℝ) < s.re → ¬ (χ = 1 ∧ s = 1) → _root_.DirichletCharacter.LFunction χ s ≠ 0)) :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi DBN.Gen.chiM4 t z = 0 → z.im = 0 :=
  DBN.Gen.chiM4_real_zeros (fun _ hs ↦ oai DBN.Gen.chiM4 hs (fun h ↦ DBN.Gen.chiM4_ne_one h.1))

/-- The bridge for chi_{-4} is now unconditional (heven discharged by rootNumber = 1): Hchi at t = 0 is the completed
L-function, so `Hchi chiM4` really is the heat flow of Lambda(s, chi_{-4}). -/
theorem chiM4_bridge (z : ℂ) :
    DBN.Gen.Hchi DBN.Gen.chiM4 0 z = (1 / 8) * ((4 : ℕ) : ℂ) ^ ((1 / 2 + I * z / 2 + (1 : ℕ)) / 2) *
      DirichletCharacter.completedLFunction DBN.Gen.chiM4 (1 / 2 + I * z / 2) := by
  have hk : DBN.Gen.parityK DBN.Gen.chiM4 = 1 := by
    unfold DBN.Gen.parityK; exact if_neg DBN.Gen.chiM4_odd.not_even
  have hev := fun u ↦ DBN.Gen.PhiC_even_of_rootNumber (N := 4) (χ := DBN.Gen.chiM4) (c := fun n ↦ (DBN.Gen.chiM4 n).re)
    (k := 1) DBN.Gen.chiM4_isPrimitive
    (fun n ↦ Complex.ext (by simp) (by simp [DBN.Gen.chiM4_real n]))
    (fun n ↦ (Complex.abs_re_le_norm _).trans (DirichletCharacter.norm_le_one _ _))
    (by simp [DBN.Gen.chiM4_apply, show ZMod.χ₄ 0 = 0 from rfl]) DBN.Gen.rootNumber_chiM4
    (by exact (if_neg DBN.Gen.chiM4_odd.not_even).symm) u
  have hb := DBN.Gen.bridge (N := 4) (χ := DBN.Gen.chiM4) (c := fun n ↦ (DBN.Gen.chiM4 n).re) (k := 1)
    DBN.Gen.chiM4_ne_one (fun n ↦ Complex.ext (by simp) (by simp [DBN.Gen.chiM4_real n]))
    (fun n ↦ (Complex.abs_re_le_norm _).trans (DirichletCharacter.norm_le_one _ _))
    (by simp [DBN.Gen.chiM4_apply, show ZMod.χ₄ 0 = 0 from rfl]) (by simp [DBN.Gen.chiM4_one])
    (fun s ↦ by rw [DBN.Gen.chiM4_odd.gammaFactor_def]; norm_num) hev z
  rw [← hb]
  unfold DBN.Gen.Hchi
  rw [hk]
  rfl

end BbD2bp

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
#check @DBN.Gen.dirichlet_real_zeros_of_rootNumber
set_option pp.numericTypes true in
#check @DBN.Gen.chiM4_real_zeros
#print DBN.Gen.Hchi
#print axioms DBN.Gen.theta_fe
#print axioms DBN.Gen.PhiC_even_of_rootNumber
#print axioms DBN.Gen.dirichlet_real_zeros_of_rootNumber
#print axioms DBN.Gen.rootNumber_chiM4
#print axioms DBN.Gen.chiM4_isPrimitive
#print axioms DBN.Gen.chiM4_real_zeros
#print axioms BbD2bp.chiM4_real_zeros_of_oai
#print axioms BbD2bp.chiM4_bridge
#bb_audit BbD2bp.chiM4_real_zeros_of_oai
