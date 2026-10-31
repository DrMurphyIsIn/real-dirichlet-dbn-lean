# bb: OAI-pin port and composition. Λ_{χ₋₄} ≤ 9/32 proved in one environment

*AI work by bb, NOT an operator read-back.* Thu 2026-10-29.
- **Authorisation.** Run on this Mac with the user's direct approval in bb's session (AskUserQuestion: "Yes, run it all here").
- **Audit.** The contrarian audited it: PASS on logic and statement, CONDITIONAL on (a)–(c) below. All three are now met.

## The result

**Statement** (BbOaiComp.lean e4c6b112). No hypotheses:

```
theorem bb_chiM4_real_zeros_oai :
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi DBN.Gen.chiM4 t z = 0 → z.im = 0 :=
  DBN.Gen.chiM4_real_zeros (fun _ hs ↦
    OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re DBN.Gen.chiM4 hs
      (fun h ↦ DBN.Gen.chiM4_ne_one h.1))
```

**The environment** is Lean v4.34.1 with Mathlib d13f23b. It holds OpenAI's built openai/math @ adc7f124 from the 10-07 replay
(~/oai-replay), plus our chain compiled UNCHANGED. **The port diff is empty**:
- 7 island files: afd94c7 plus the 2 port lines already audited;
- 13 Gen files at the audited md5s: 261aa493, c5c6e856, 282fe6c7, 23f22b65, 99f5dfdc, 6f608628, 3dbf6dec, cb5c2820, 67e1af81,
  5691f87d, 8aa81558, 8aeec9b0, 9acc262c.

The build script is build.sh b0edbe53; log/progress.txt has rc 0 for all 20 modules.

## Checks

**Axioms.**
- `bb_chiM4_real_zeros_oai` and OpenAI's theorem both show [propext, Classical.choice, Quot.sound].
- bb's term-level closure walk over 126,416 constants agrees with collectAxioms (BbOaiCheck.out f31730cc).
- The environment has 13,708 modules. Origins are correct, there are no module-name collisions, and 0 `DBN.*` constants come from
  foreign modules.

**The statement is pin- and environment-independent.** Its `pp.all` text is byte-identical with and without OpenAI in the
environment (BbOaiRef.out 22ff330f).

**Tampers** (BbOaiTamper.out 68488ff1): 2 errors.
- 7/8 → 3/4 fails at OpenAI's theorem: a genuine reject.
- Heat time 1/4 is a proof-reach control.

**(a) Checker replay** (kernels.sh 2d582dfc; log/kernels_progress.txt 67593cba).
- Method: v4.34.1 `lean4export` 3.1.0 (~/e9-tools) produced exports, which were fed to the checkers bundled with Lean v4.35.0-rc3
  (same export format 3.1.0).
- Exports: composition 1,725,901,663 B (7c142b2c); skipKernelTC control 171,761,220 B (bf973608).

| Checker | composition | control (BbNeg.bogus : 4 = 5) |
|---|---|---|
| leanchecker-paranoid | rc 0 (322 s) | rc 1, REJECT |
| nanoda | rc 0 | rc 101, REJECT (panic) |
| con-leche | rc 0, "accepted 124395 declarations (--verified)" | rc 1, "invalid: type mismatch in theorem BbNeg.bogus" |
| con-ron | rc 0, "accepted 124395 declarations (--verified)" | rc 1, "rejected: type mismatch … BbNeg.bogus" |
| leanchecker | rc 0 (266 s) | rc 1, REJECT |
| lean4lean | **N/A**: "uncaught exception: at Nat.mod: (kernel) unknown constant 'Decidable.intro'" | **N/A, same crash** |

- **Correction of bb's earlier message.** bb first reported the control "rejected 6/6". lean4lean's "rejection" was this same
  cross-version crash, which happens before it reaches any target. The rc3 lean4lean does not support v4.34.1 exports.
- **The valid count is five checkers:** each accepts the composition and genuinely rejects the control.

**(b) Provenance.**
- ~/oai-replay is a materialised copy of openai/math `lean/`, not a git repository.
- `diff -rq ~/oai-replay/OAI ~/oai-math/lean/OAI` is EMPTY. That is 121,734 `.lean` files compared against bb's git clone, whose
  `rev-parse HEAD` is adc7f1241b42e322a6451854ab7e4b4c146bf78a.
- lakefile.lean c8078fb2, lake-manifest.json 8c3ec864 (Mathlib d13f23b723b8…) and lean-toolchain (leanprover/lean4:v4.34.1)
  are identical in both, as is patches/.
- `OAI/NumberTheory/DirichletL/Nonvanishing.lean` has md5 ea8efdb1, which matches your read-only fetch from the public repo.
- **That file was re-elaborated from source against the 10-07 oleans:** rc 0, with no output (prov.sh 57fc51be,
  log/prov_progress.txt 4df46ba5).

**(c) Meaning link in the same environment** (BbOaiBridge.lean 9be8fdf9, out 684c02bb).
- `BbD2bp.chiM4_bridge : Hchi chiM4 0 z = (1/8)·4^{(s+1)/2}·completedLFunction chiM4 s`, for s = ½ + iz/2, compiles in the OpenAI
  environment with the standard 3 axioms, alongside `bb_chiM4_real_zeros_oai`.
- So, in the same environment, `Hchi chiM4` is provably the heat flow of Λ(·, χ₋₄): 1/8 of 2610.27343's H^L, which has the same
  zero set.

## Label

**"Λ_{χ₋₄} ≤ 9/32: PROVED in one environment (OpenAI's Dirichlet 7/8 @ adc7f124 + our unchanged chain, v4.34.1/d13f23b),
axioms standard 3, replayed by five independent checkers (leanchecker, leanchecker-paranoid, nanoda, con-leche, con-ron; lean4lean
N/A across versions); NOT a sandboxed Comparator run."**

- The general real-primitive result stays CONDITIONAL on ε(χ) = 1 (Gauss's sign theorem, not in Mathlib).
- In this environment, its 7/8 hypothesis can be discharged for any χ ≠ 1 by the same one-line application.
- **Caveats:**
  - OpenAI's manuscript is unrefereed; the kernel-level trust rests on the 10-07 replay plus these checkers.
  - The run was unsandboxed on macOS.
