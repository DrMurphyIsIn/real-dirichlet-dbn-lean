# Comparator challenge

This directory holds the statement-identity challenge for `bb_real_primitive_meaning_oai`: the file that a
[Comparator](https://github.com/leanprover/comparator) run checks the proof against. It was written by bb, the
independent auditor who verified the chain, not by the authors of the proof. Every file here is a byte-for-byte
copy of bb's, as listed in bb's own manifests `MD5SUMS.txt` (md5 `6c933c842d470ecd6cf8f32a5fba388a`) and
`preflight/MD5SUMS.txt` (md5 `9a359979399403987799f0e02a606ae5`). This README is the only file added; it is not
part of bb's manifests. `CHALLENGE_NOTES.md` is bb's full design note, and this page summarises it.

**The sandboxed Comparator run is still pending.** Nothing here has been through Comparator yet. What has run is
bb's local, unsandboxed pre-flight in `preflight/`, described below.

## What is in here

| File | Role |
|---|---|
| `ChallengeDefs.lean` | the trusted definitions; imports Mathlib only |
| `Challenge.lean` | the statement of `bb_real_primitive_meaning_oai`, copied verbatim from `lean/main/BbOaiMeaning.lean`, with `:= sorry` |
| `ChallengeTamperA.lean` | the same, with the heat time 9/32 changed to 1/4 in the first conjunct. It MUST be rejected |
| `ChallengeTamperB.lean` | the same, with the bridge constant 1/8 changed to 1/4 in the second conjunct. It MUST be rejected |
| `config.json` | the Comparator config: challenge `Challenge` against solution `BbOaiMeaning`; permitted axioms `propext`, `Quot.sound`, `Classical.choice`; nanoda enabled |
| `config_tamperA.json`, `config_tamperB.json` | the same config with `challenge_module` pointed at the tampers |
| `CHALLENGE_NOTES.md` | bb's notes: the trusted base, how Comparator matches definitions, the design choices, and the pre-flight |
| `preflight/` | bb's local pre-flight: scripts, the check files and their outputs |

## The trusted base

A Comparator run proves that the solution's theorem has exactly the type written in `Challenge.lean`, with only
the three standard axioms. You still have to trust what the words in that type mean. Here they mean Mathlib's
definitions at `d13f23b`, OpenAI's pin, plus exactly **six non-Mathlib constants**, all defined in
`ChallengeDefs.lean`:

- `DBN.Gen.thetaC`: θ_c(x) = Σ_{n≥0} c(n)·n^k·e^{−πn²x/q};
- `DBN.Gen.PhiC`: Φ_c(u) = e^{(1+2k)u}·θ_c(e^{4u});
- `DBN.Gen.PhiC._proof_1` and `DBN.Gen.PhiC._proof_2`: two auxiliary proof terms that Lean generates from the body
  of `PhiC`. They are bookkeeping, not mathematics, but Comparator compares them too;
- `DBN.Gen.parityK`: k(χ) = 0 if χ is even and 1 if χ is odd;
- `DBN.Gen.Hchi`: Hchi χ t z = ∫₀^∞ e^{tu²}·Φ_χ(u)·cos(zu) du, where Φ_χ = Φ_c with c(n) = Re χ(n), k = k(χ) and
  q = N.

The text is **verbatim** from the audited sources, with the same `open`s and `variable`s. `thetaC` and `PhiC` are
lines 16–28 of `lean/gen/GenTheta.lean` (md5 `3dbf6dec…`). `parityK` and `Hchi` are lines 19–23, 29 and 264–273 of
`lean/gen/GenThetaFE.lean` (md5 `8aeec9b0…`). Each of those blocks appears unchanged in `ChallengeDefs.lean`
(checked when the files were copied in). The list of six was produced mechanically: bb walked the non-Mathlib closure of the
statement in both environments (`preflight/BbDefsClosure.out`, `preflight/BbPreflightChalClosure.out`).

Four short formulas are all a reader has to check. The second conjunct of the theorem helps here. It says that
`Hchi χ 0` is (1/8)·Λ(½ + iz/2, χ) for every z, and that pins down the integrand of `Hchi` whatever the formulas
say internally. CHALLENGE_NOTES §"Design question" gives the argument, and explains why bb kept this design
rather than defining `Hchi` through `completedLFunction` or making the statement existential.

## The solution must NOT import ChallengeDefs

Comparator does not compare module names. It starts from the constants in the challenge theorem's type. For each
constant it reaches, it requires the `ConstantInfo` in the challenge environment to equal the one in the solution
environment: the same name, universe parameters, type, value, reducibility hints and safety, with expressions
compared up to alpha-equivalence. The solution chain already defines all six constants itself, in `GenTheta` and
`GenThetaFE`. So:

- the solution module is the unchanged `BbOaiMeaning` (md5 `23ea25e9…`) over the audited chain in `lean/`;
- **nothing in the solution may import `ChallengeDefs`**. It would be a duplicate declaration of the same six
  names, and it is not needed, because Comparator checks that the two copies are identical;
- the challenge side is only Mathlib, `ChallengeDefs` and `Challenge`, with no chain module and no OpenAI code.

## The pre-flight (local, NOT Comparator)

bb ran a pre-flight on macOS with plain `lean`, unsandboxed (`preflight/preflight.sh`; progress in
`preflight/preflight_progress.txt`).

- **Builds.** All four challenge files compile, with the expected `sorry` warnings only.
- **Trusted constants.** Exact `ConstantInfo` dumps show the six constants byte-identical between the challenge
  and solution environments.
- **Theorem type.** The challenge theorem's type differs from the solution's only in hygienic binder names that
  embed the module name. Comparator's alpha-equivalence ignores those, as bb confirmed with `preflight/BbBeqTest.lean`.
- **Tampers.** Both tampers differ from the solution's type in substance.

This shows that the challenge *should* match and the tampers *should* be rejected. It is not the evidence itself:
there was no sandbox, no export comparison and no kernel replay.

## Still to come

The run itself, per the publication's run spec:
- Comparator v4.34.0, built for toolchain v4.34.1, with `--paranoid`;
- inside a bwrap sandbox on Linux;
- every checker Comparator supports;
- both tampers, which must be rejected.

bb will then verify the logs against these md5s and `lean/MD5SUMS.txt`. The full logs will go in
`logs/comparator_sandboxed/`.
