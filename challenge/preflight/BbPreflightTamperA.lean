import ChallengeTamperA
open Lean Elab Command in
/-- bb pre-flight: exact dump of each named constant (Comparator compares full ConstantInfo; for theorem targets only
name/levelParams/type). Expr `repr` includes binder names and is therefore STRICTER than Comparator's Expr BEq. -/
elab "#bb_dump " ids:ident* : command => do
  let env ← getEnv
  for id in ids do
    let n := id.getId
    match env.find? n with
    | none => logInfo m!"DUMP-MISSING {n}"
    | some ci =>
      let kind := match ci with
        | .defnInfo _ => "def" | .thmInfo _ => "theorem" | .axiomInfo _ => "axiom" | .opaqueInfo _ => "opaque"
        | .inductInfo _ => "inductive" | .ctorInfo _ => "ctor" | .recInfo _ => "rec" | .quotInfo _ => "quot"
      let extra := match ci with
        | .defnInfo v =>
          let h := match v.hints with
            | .opaque => "opaque" | .abbrev => "abbrev" | .regular k => s!"regular {k}"
          let sf := match v.safety with | .safe => "safe" | .unsafe => "unsafe" | .partial => "partial"
          s!"hints={h} safety={sf} all={v.all} value={repr v.value}"
        | .thmInfo v => if n.toString == "bb_real_primitive_meaning_oai" then "(target: type only)" else s!"all={v.all} value={repr v.value}"
        | _ => "(not a def/thm)"
      logInfo m!"DUMP-BEGIN {n}
kind={kind} levelParams={ci.levelParams} type={repr ci.type} {extra}
DUMP-END {n}"
#bb_dump bb_real_primitive_meaning_oai DBN.Gen.Hchi DBN.Gen.PhiC DBN.Gen.PhiC._proof_1 DBN.Gen.PhiC._proof_2 DBN.Gen.thetaC DBN.Gen.parityK
