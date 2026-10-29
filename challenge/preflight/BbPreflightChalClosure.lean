import Challenge
open Lean Meta Elab Command in
/-- bb: closure of NON-Mathlib constants reachable from the given roots (types + values), recursing only through
constants whose module root is not a standard library; Mathlib constants cannot reference ours. -/
elab "#bb_local_closure " ids:ident* : command => do
  let env ← getEnv
  let mods := env.header.moduleNames
  let std := ["Mathlib", "Init", "Std", "Lean", "Batteries", "Aesop", "Qq", "ProofWidgets", "Plausible",
    "ImportGraph", "LeanSearchClient"]
  let modOf (c : Name) : String := match env.getModuleIdxFor? c with
    | some i => toString (mods[i.toNat]!)
    | none => "(this file)"
  let mut stack : Array Name := #[]
  for id in ids do stack := stack.push (← liftCoreM (realizeGlobalConstNoOverload id))
  let mut seen : NameSet := {}
  let mut out : Array String := #[]
  while !stack.isEmpty do
    let c := stack.back!; stack := stack.pop
    if seen.contains c then continue
    seen := seen.insert c
    let m := modOf c
    if std.any (fun s => m == s || m.startsWith (s ++ ".")) then continue
    let some ci := env.find? c | continue
    let kind := match ci with
      | .defnInfo _ => "def" | .thmInfo _ => "theorem" | .axiomInfo _ => "AXIOM" | .opaqueInfo _ => "opaque"
      | .inductInfo _ => "inductive" | .ctorInfo _ => "ctor" | .recInfo _ => "rec" | .quotInfo _ => "quot"
    out := out.push s!"{c} [{kind}] <- {m}"
    let mut es := #[ci.type]
    if let some v := ci.value? (allowOpaque := true) then es := es.push v
    for e in es do
      for d in e.getUsedConstants do
        unless seen.contains d do stack := stack.push d
  logInfo m!"bb_local_closure: {out.size} non-standard constants\n{String.intercalate "\n" (out.qsort (· < ·)).toList}"
#bb_local_closure bb_real_primitive_meaning_oai
