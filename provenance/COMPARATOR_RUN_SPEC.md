# Sandboxed Comparator run: Λ_χ ≤ 9/32 for every real primitive χ ≠ 1 (lead, 2026-10-29)

The user said: "This seems worth preparing for publication. Please set up the comparative run in collaboration with the
contrarian." This is the step that turns bb's five-checker local replays (unsandboxed, macOS) into a sandboxed,
statement-identity-checked result. Nothing is public. Publication is the user's call after this run.

## Target
`bb_real_primitive_meaning_oai`, the conjunction of:
- (a) `bb_real_primitive_real_zeros_oai`: ∀ real primitive χ ≠ 1, ∀ t ≥ 9/32, every zero z of `DBN.Gen.Hchi χ t` has
  z.im = 0;
- (b) `Hchi_bridge`: `DBN.Gen.Hchi χ 0 z = (1/8)·N^((s+k)/2)·completedLFunction χ s`, with s = 1/2 + iz/2.

Sources (bb's records): REVIEW_GAUSS_SIGN_AND_OAI.md 60956a72 and REVIEW_GAUSS_BRIDGE_ADD1.md cade7fd1, under
~/rh-team/contrarian/synthesis_1029/bb/. The OAI env is v4.34.1 / Mathlib d13f23b @ openai/math adc7f124.

## Roles
- **bb (independent author of the challenge).**
  - (1) Write `Challenge.lean`: the statement of the conjunction above, verbatim, with `:= sorry`.
  - (2) Write `ChallengeDefs.lean`: the MINIMAL definitions the statement needs (`DBN.Gen.Hchi` and whatever it unfolds
    to that is not Mathlib, plus `parityK`), copied from the reviewed Gen sources and pinned by md5. This file is the
    trusted base; list every non-Mathlib constant it introduces.
  - (3) Write `config.json`: challenge/solution modules, theorem names, `permitted_axioms` = [propext, Quot.sound,
    Classical.choice], `enable_nanoda` = true.
  - (4) Write the tamper challenge: the same with 9/32 → 1/4, and with (1/8) → (1/4) in the bridge. Each must be REJECTED.
  - (5) Send the contrarian the files inline, each with an md5 printed in the same command.
- **Contrarian (runner).** In its Linux container, inside a bwrap sandbox:
  - (1) Solution = the OAI env plus our chain (island, Gen, GaussSign, GaussBridge, BbOaiRealPrim, BbOaiMeaning) at the
    md5s in bb's records, building the solution module against bb's ChallengeDefs.
  - (2) Run Comparator (the v4.34.0 tag built for v4.34.1, as it did for SiegelZeros) with `--paranoid` and every
    checker it supports: Lean kernel, nanoda, and lean4lean if it can read v4.34.1 exports, else recorded N/A, plus
    con-leche, con-ron and leanchecker-paranoid.
  - (3) Run both tampers, which must be rejected.
  - (4) Save the FULL logs, not tails: last time the head was lost to `tail`. Report md5s and the verdict lines, and put the
    log files where bb can fetch them, or send them inline in chunks.
  - (5) Guard against the empty-export failure: assert that the export is non-empty, and report its declaration count.
- **bb (verifier):** check the logs against the challenge md5s and the solution md5s. Confirm that the statement-match
  line, the axiom check and every checker verdict appear, and that the tampers fail. Write REVIEW_COMPARATOR_LAMBDA_CHI.md.
- **Lead:** keep this spec, track it, and report to the user.

## Known constraints to record honestly
- The trusted base is ChallengeDefs (our Hchi definition) plus Mathlib's definitions. The bridge conjunct (b) is what lets a
  reader check that Hchi means "the heat flow of Λ(s, χ)".
- The result rests on OAI's kernel-checked Dirichlet 7/8. Their manuscript is unrefereed.
- The bwrap sandbox runs on the contrarian's Linux container, not on this Mac.
- The CT-based, OAI-free companion (Λ ≤ 225/512, Ingham) has its own Comparator run in progress (P2).

## Publication prep (after this run; nothing public without the user)
- A clean artifact repo layout (statement files, solution chain, pins, logs, md5 manifest, README).
- A short write-up crediting arXiv 2610.27343 (Remarks 3.1/3.4) for the conditional statement and OpenAI for 7/8. Our
  contribution is the end-to-end kernel proof, the generic de Bruijn theorem in Lean, and Gauss's sign theorem.
- An outside human read of the statements.
