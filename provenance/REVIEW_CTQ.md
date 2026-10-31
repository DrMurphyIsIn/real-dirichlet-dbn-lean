# bb review of the CT@Q corollary (CTRatZeta.lean, md5 20d8d72e)

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

**What was asked.** The contrarian asked for a statement-fidelity audit of its Lean corollary
`CTRat.riemannZeta_ne_zero_of_thirtyone_div_thirtytwo_lt_re`. It derives ζ(s) ≠ 0 for 31/32 < Re s, s ≠ 1, from
Cureton–Thorner's `DedekindZetaZeroFree.main ℚ`. bb had listed three checks:
- (a) the statement uses Mathlib's own `riemannZeta`, with nothing shadowing it;
- (b) the binders and coercions are right;
- (c) bb's own replay, with a tamper control.

## Inputs

- **The file.** It came in the contrarian's message (md5 and `cat` printed by one command). The relay HTML-escaped `<` and `>`
  and turned `⟨ ⟩` into `&lt; &gt;`. bb rebuilt the bytes: of 24 candidate decodings, exactly one hashes to
  20d8d72e74c5c1047c0c5a367bbe1bb3. So bb holds the file byte for byte.
  - reconstruct.py aaedad36 / reconstruct.out 599622a2; relayed_raw.txt 3930e70e.
- **Upstream.** AxiomMath/DedekindZetaZeroFree at 09afbb4ce657, which is origin HEAD ("add Hecke zero-free corollary",
  2026-10-13). Read only, from a blobless clone; nothing of it was run.
  - Solution/DedekindZetaSolution.lean 87c46452, Challenge/DedekindZetaChallenge.lean 1b4c9117.
  - comparator.json names `main` and `heckeCorollary`, with the three standard axioms permitted.
- **Mathlib.** Mathlib 0493595e and its dependencies. Every rev equals CT's manifest at 09afbb4. bb used the oleans built in the
  lead's 10-12 replay (~/axiom-dzf/repo-adapted), through LEAN_PATH only, with no lake. Lean v4.35.0-rc3 (commit 470d5ce1),
  run under leanlock with 1 slot.

## Verdict

**(a) and (b) PASS. (c) PASS for the reduction.**
- The statement is about Mathlib's `riemannZeta`.
- Its hypotheses are exactly "s : ℂ, (31/32 : ℝ) < s.re, s ≠ 1".
- The step from CT's Challenge statement of `main` to the ζ half-plane is kernel-checked by bb using Mathlib only, and both tamper
  controls are rejected.
- **Not replayed by bb:** the proof of `main` itself. It lives in CT's closure, and team rule says external code is read, not run.
  It rests on CT's Comparator pair (open item below).

## (a) Mathlib's riemannZeta, no shadowing: PASS

- **The file itself.** It declares four theorems (card_ideals_rat, dedekindZeta_rat, riemannZeta_ne_zero_of_ct and the final one)
  and no def, notation or instance. `open NumberField` is its only open.
- **The 5,528 .lean files at 09afbb4** (CT plus the vendored class-field-theory):
  - the string `riemannZeta` occurs nowhere;
  - there is no `namespace CTRat`;
  - there is no instance on an ℝ or ℂ arithmetic head;
  - there is no metaprogramming (initialize, elab, macro, IO, open Lean and elaborator attributes: 0 lines);
  - outside Challenge/ there is no sorry, admit, native_decide, axiom, implemented_by, extern or skipKernelTC.
  - **Positive controls:** the same greps find 31 files with `dedekindZeta`, 34,677 theorem lines and 1,422 instance lines.
- **Imports.** TauCeti is in the manifest but no file imports it. The import roots are DedekindZetaZeroFree, ClassFieldTheory,
  ValuedFieldTheory, GaloisCohomology, ProCGroups and Mathlib, so no openai/math module is imported. This confirms "Nothing from
  openai/math is imported" at module level; CT still adapts openai/math files, as the contrarian said.
- **In bb's replay** (Mathlib only):
  - `riemannZeta` is declared in Mathlib.NumberTheory.LSeries.RiemannZeta.
  - Every constant in the statement comes from Init or Mathlib (the list is in BbCTQCheck.out).
  - The contrarian's signature, elaborated in its own naming context (namespace CTRat, open NumberField), is Expr.eqv to bb's
    `_root_.riemannZeta` version.

## (b) Binders and coercions: PASS

- **Printed with pp.numericTypes:** `∀ {s : ℂ}, (31 / 32 : ℝ) < s.re → s ≠ (1 : ℂ) → riemannZeta s ≠ (0 : ℂ)`.
- **31/32 is real division.** In ℕ it would be 0; it is not.
- **s is an implicit binder,** not explicit as bb's request wrote. That is the same statement: Expr.eqv is true and isDefEq is
  true against bb's explicit form.
- **s ≠ 1 is correctly present.** Mathlib's `riemannZeta 1` is a junk value, so the exclusion is the right form.

## (c) Replay: PASS for the reduction

- **BbCTQCheck.lean (637777a0).** Lines 5-72 are CTRatZeta.lean lines 8-75 verbatim (diff-checked), and
  `import DedekindZetaSolution` is dropped.
  - CT's Challenge statement of `main` at 09afbb4 becomes the hypothesis of `bb_ctq_main_implies_zeta`. It is stated in the
    Challenge's own context: noncomputable section, `open scoped NumberField Classical`.
  - The conclusion is `∀ s : ℂ, 31/32 < s.re → s ≠ 1 → _root_.riemannZeta s ≠ 0`.
  - Exit 0 in 10 s, 6.1 GB RSS. `#print axioms` gives [propext, Classical.choice, Quot.sound].
  - bb's own closure walk over 62,768 constants finds exactly the same three, agreeing with collectAxioms.
  - Output: BbCTQCheck.out ddb97b6a.
- **BbCTQTamper.lean (9a4dc19c)** contains the same verbatim block plus two controls. Both are REJECTED, and there are exactly two
  errors (BbCTQTamper.out a8c6ad30):
  - **T1** strengthens the conclusion to 7/8 < Re s. Rejected at line 81, `hs` type mismatch.
  - **T2** weakens the hypothesis to the 284348a4 statement (5999/6000). Rejected at line 88, `main ℚ` type mismatch.
- **The generator** is gen_bb_ctq.py adbf32e9 / .out afaedfe1. The first run had a namespace bug: the verbatim block ends inside
  `namespace CTRat`. Its run1 outputs are kept as *_run1_nsbug.*, and its tamper result was the same.

**What this establishes.** Take the Mathlib-elaborated Challenge statement of `main`, which is what CT's Comparator pair certifies.
From it, ζ(s) ≠ 0 for every s with 31/32 < Re s and s ≠ 1 follows by a Mathlib-only, kernel-checked argument: ideal counting,
the identity theorem on ℂ∖{1}, and agreement on Re s > 1.

## Open item (for the record)

**The kernel-level guarantee for `main` at 09afbb4 is CT's Comparator pair.** Its statements are compared by Expr ==, its axioms
are checked, and it replays in two kernels.
- This message reports only `#print axioms` on the final theorem. For the imported `main`, that reads the module's cached axiom
  set; it does not walk the proof (see bb's #print-axioms-cache note).
- At its last FYI, the contrarian's `lake comparator --paranoid` was still running. **bb asks for its result** (log md5, and
  whether nanoda ran).
- The lead's 10-12 replay covered 284348a4 (the 5999/6000 statement), not 09afbb4.
- bb did not compare its hypothesis Expr against the Challenge olean, because that would mean running CT's build. The comparison
  is not needed for the logic: any instance-path difference (e.g. NormedCommRing ℂ via instCommCStarAlgebraComplex, which bb's
  statement uses) is definitional.

## Notes

- **The 1−1/6000 vs 31/32 question is resolved.** 284348a4 states 5999/6000. Commit 201bc40 (10-13) strengthens `main` to 31/32,
  and 09afbb4 adds `heckeCorollary`.
- **Strength.** For ζ, 31/32 is weaker than openai/math's 7/8 and Liu's 0.874957. The value of this corollary is a second formal
  library, independent as a check but not as a method.
- **Relays mangle Lean.** For future relays of Lean source, use a file under ~/rh-team or base64. The relay mangled ⟨⟩ (above),
  and the reconstruction worked only because exactly one decoding matched the md5.

---

## Addendum 1 (2026-10-29): CT's Comparator result (RELAYED), and a correction to the §(a) scan

*AI review by bb, NOT an operator read-back.* The pre-edit copy is REVIEW_CTQ_pre_add1_306b463d.md.

**The relayed result.** The contrarian ran `lake comparator --config comparator.json --paranoid` on 09afbb4, using the comparator
built into Lean v4.35.0-rc3, in a bwrap 0.9.0 sandbox, with CT's own config (main and heckeCorollary; the three standard
axioms). The verdict lines, as relayed:
- lean4lean: "checked 206507 declarations", accepts;
- nanoda: accepts;
- con-leche and con-ron: "accepted 206506 declarations (--verified)", each accepts;
- Lean default: accepts;
- then "Your solution is okay!".

Exit 0, after 4 h 04 m with about 12.9 GB peak RAM. The log (md5 c3709899) is in the contrarian's cloud scratchpad. bb does not
hold it and has not re-hashed it.

**What "okay" implies.** bb read the toolchain's Lake/CLI/Check.lean (md5 5b6cc8e9), without running anything (CITED-READ):
- `compareIt` prints "Your solution is okay!" only after `verifyMatch` returns.
- `verifyMatch` first runs `compareAt` and then `checkAxioms`, both through `IO.ofExcept`. `compareAt` compares the challenge and
  solution statements of the named theorems, plus definitions and primitives. So a statement mismatch, or a non-permitted axiom,
  throws before any kernel runs.
- `runKernels` then runs every checker. With `--paranoid` these are Lean paranoid (leanchecker-paranoid), lean4lean, nanoda,
  con-leche and con-ron, followed by Lean default. A rejection or an interaction error from any of them is accumulated and thrown
  at the end.
- So the final line implies three things: the statements matched, the axioms passed, and all six checkers accepted. That
  includes the statement-match and leanchecker-paranoid lines that the contrarian's `tail -60` lost (its caveat 1). bb has not
  seen those lines; the inference rests on the source.

**Caveats, carried forward:**
- **(2) No prior compile: NOT met.** `lake build` ran unsandboxed first, and comparator reused that .lake. Comparator's design
  (the Check.lean docstring) is that adversarial code is built only inside bwrap. An unsandboxed build can cheat only by running
  code at build time. bb's partial mitigation, from static reading:
  - both lakefiles (root and vendor) are TOML, so no Lake code runs at build time;
  - the CT tree has no IO, initialize, elab, macro, syntax declaration or init attribute.
  - **Correction to §(a).** The tree DOES contain 6 `run_cmd` blocks using Lean.Elab and Lean.Meta, which bb's first scan missed.
    bb read all six. Each one forces the realization of equation or congr-simp lemmas at their origin (`getEqnsFor?`,
    `mkCongrSimpForConst?`, `executeReservedNameAction`). They do no IO and change the environment only by adding those lemmas,
    which go through the kernel like everything else. So "no metaprogramming" in §(a) should read "no metaprogramming beyond 6
    lemma-realization `run_cmd` blocks".
  - Not load-bearing for the corollary: bb's replay never imports CT.
- **(3) The con-* kernels model Lean.Syntax in-process**, as printed. This does not affect the other four checkers.
- **Minor.** lean4lean says "checked 206507" while con-* say "accepted 206506". bb has not explained the one-declaration
  difference. It is not load-bearing, since every checker, including both Lean kernels, accepted.

**The chain now:**
1. CT's main at 09afbb4, in its Mathlib-elaborated Challenge form, is accepted by six checkers (RELAYED, plus the source-read
   implication above).
2. bb's Mathlib-only, kernel-checked reduction (§(c)) takes it to the ζ statement.
3. Result: riemannZeta s ≠ 0 for every s with 31/32 < Re s and s ≠ 1, with no openai/math module in the closure.

**The open item is CLOSED, as RELAYED** (bb does not hold the log). For ζ this is weaker than 7/8. Its value is a second formal
library, independent as a check but not as a method. Any use outside the team is the user's call.
