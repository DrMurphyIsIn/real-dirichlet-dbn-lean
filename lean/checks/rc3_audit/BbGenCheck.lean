import GenTheta
import DBNM1Parametric
import DBNHeatApprox

/-! bb (AI review, NOT an operator read-back), 2026-10-29: D1/D2a audit. REGRESSION: the generic library instantiated
with the island's own Phi must re-derive the island's dbn_debruijn_parametric verbatim. -/

open Real

noncomputable def bbIslandKernel : DBN.Gen.Kernel where
  Φ := DBN.Φ
  cont := DBN.continuous_Φ
  even := DBN.Φ_neg
  C := DBN.ΦBoundConst
  C_nonneg := DBN.ΦBoundConst_nonneg
  bound := fun hu ↦ DBN.abs_Φ_le hu
  ne := ⟨0, (DBN.Φ_pos 0).ne'⟩

theorem bb_H_eq (t : ℝ) (z : ℂ) : DBN.Gen.H bbIslandKernel t z = DBN.H t z := rfl

/-- The island's `dbn_debruijn_parametric` statement, verbatim, proved from the GENERIC library only. -/
theorem bb_regression :
    ∀ t0 Y : ℝ, (∀ z : ℂ, DBN.H t0 z = 0 → z.im ^ 2 ≤ Y) →
    ∀ t : ℝ, t0 ≤ t → ∀ z : ℂ, DBN.H t z = 0 → z.im ^ 2 ≤ max (Y - 2 * (t - t0)) 0 := by
  intro t0 Y h0 t ht z hz
  exact DBN.Gen.dbn_debruijn_parametric (K := bbIslandKernel) t0 Y
    (fun w hw ↦ h0 w (by rwa [bb_H_eq] at hw)) t ht z (by rwa [bb_H_eq])

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

open Lean Meta Elab Command in
#eval show CommandElabM Unit from do
  let a := (← getConstInfo ``bb_regression).type
  let b := (← getConstInfo ``dbn_debruijn_parametric).type
  logInfo m!"bb: regression statement Expr.eqv island dbn_debruijn_parametric = {a == b}"

set_option pp.numericTypes true in
#check @DBN.Gen.dbn_debruijn_parametric
#print DBN.Gen.Kernel
#print axioms bb_regression
#bb_audit bb_regression
#bb_audit DBN.Gen.dbn_debruijn_parametric
