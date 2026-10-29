import GaussSign

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
#check @DBN.Gen.rootNumber_eq_one_of_real_primitive
set_option pp.numericTypes true in
#check @DBN.Gen.real_primitive_real_zeros
#print axioms DBN.Gen.rootNumber_eq_one_of_real_primitive
#print axioms DBN.Gen.real_primitive_real_zeros
#bb_audit DBN.Gen.rootNumber_eq_one_of_real_primitive
#bb_audit DBN.Gen.real_primitive_real_zeros
