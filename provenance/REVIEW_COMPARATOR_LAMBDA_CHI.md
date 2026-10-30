# bb: verification of the sandboxed Comparator run for Λ_χ ≤ 9/32 (every real primitive χ ≠ 1)

*AI review by bb, NOT an operator read-back.* Fri 2026-10-30. Nothing public.

**Roles** (COMPARATOR_RUN_SPEC.md 3fc6b5d6):
- bb wrote the challenge and verifies the run;
- the contrarian ran it, in its Linux container;
- the lead tracks it.

## Verdict: PASS

The theorem `bb_real_primitive_meaning_oai` is the conjunction of:
- (a) Λ_χ ≤ 9/32, i.e. every zero of `Hchi χ t` is real for t ≥ 9/32;
- (b) the bridge `Hchi χ 0 = (1/8)·N^{(s+k)/2}·completedLFunction χ s`.

What the run establishes:
- It **passes Comparator against bb's independently written challenge**. The statement matches, the axioms are within
  [propext, Quot.sound, Classical.choice], and every kernel replay accepts.
- **Both tampers are rejected.**
- The run was made inside a bwrap sandbox with all capabilities dropped, on OpenAI's environment rebuilt from its public pins.
- **bb did not see the run's logs.** Their verdict lines and md5s are RELAYED. But bb independently reproduced the solution
  export **byte for byte** (§4). So the environment the sandboxed kernels checked is exactly the one bb built and replayed
  locally with five checkers.

## 1. What was run

| Item | Value |
|---|---|
| Comparator | leanprover/comparator v4.34.0 (d03acab), binary 990f646b, toolchain v4.34.1 |
| Exporter | lean4export 3.1.0 (076e8e5), binary ec897d54 |
| nanoda | 0d9bd7d1 (d0a02cc) |
| rc3 checkers | leanchecker-paranoid 26fdaf92, con-leche 732b1294, con-ron 0cfa154d |
| Sandbox | landrun → bwrap shim landrun-bwrap.sh **13a13e8b**, read in full by bb |

**The shim's flags:**
- `--ro-bind / / --dev /dev --proc /proc`;
- the ro and rw binds Comparator requests;
- `--clearenv`;
- `--unshare-all --cap-drop ALL --die-with-parent --new-session`;
- unknown flags are a hard error.

The run is uid 0 with CapEff 0 in an ephemeral single-tenant container. Probe: mounts are denied, writes outside the rw set get
EROFS, and there is no network.

**Workspace** (all checked by bb):
- **Package LambdaChiComparator:** lakefile.toml e2eb57db, lake-manifest.json 458daaf2. All 15 package revs and URLs equal
  OpenAI's manifest 8c3ec864.
- **Dependencies:**
  - mathlib d13f23b, from its official cache;
  - PrimeNumberTheoremAnd c39a751 and rellich-kondrachov 70f85d4, cloned and patched with OpenAI's patches (2c0006d3 and
    f7611853);
  - openai/math adc7f124 sources, unmodified, read in place as lean_lib OAIClosure (autoImplicit false, as OpenAI's package
    sets it).
- **bb confirmed** that Nonvanishing's import closure has exactly these external roots: 8,596 modules, 2,924 of them OAI;
  non-standard roots RellichKondrachov (15) and PrimeNumberTheoremAnd (4) (BbNvRoots.lean fccab000, out 24ab19a8).
- **Challenge side** (bb's bundle 1d9e3d05): ChallengeDefs 67e538bc, Challenge 73c1bf94, ChallengeTamperA d6ef5198,
  ChallengeTamperB 31163137.
- **Solution side:** the 29 modules at MANIFEST fe0c4957. All 29 md5s were re-hashed by the runner and match. Solution
  module BbOaiMeaning; nothing imports ChallengeDefs.

**Configs:**
- config.json d563faf7: enable_nanoda;
- config_tamperA.json 1c2534bb and config_tamperB.json f34c06af;
- config_paranoid.json 4dc0b50c: external kernels nanoda, leanchecker-paranoid --from-export, con-leche and con-ron, plus the
  builtin Lean kernel.

bb read the decoded copies of the shim, lakefile, manifest and paranoid config (~/e9-research/review_cn1/p1p6/lcc_setup/).

## 2. Results (relayed by the runner; log md5s as reported)

| Run | Verdict lines | Exit | Log md5 |
|---|---|---|---|
| main | nanoda accepts; Lean default accepts; "Your solution is okay!" | 0 | fc80db0aad9b392d954354ca10a9c970 (2,620 lines) |
| tamperA (heat time 9/32 → 1/4) | "Challenge and solution theorem statement do not match: 'bb_real_primitive_meaning_oai'" | 1 | 78a706f654a5f150347d74e945927731 |
| tamperB (bridge 1/8 → 1/4) | same | 1 | d1f16445e6cfa2126163a00b8cb02cb3 |
| paranoid | con-leche "accepted 124639 declarations (--verified)"; con-ron the same; leanchecker-paranoid, nanoda and Lean default accept; "Your solution is okay!" | 0 | fb16467579fd81ea4bbdbeb2de98578f |

- lean4lean was not run. The rc3 build cannot read v4.34.1 exports: it fails on Decidable.intro, as bb found earlier.
- queue.done is dbd4d2c7. main ran 11:46 → 13:16 UTC; paranoid ended 14:13 UTC.
- Earlier attempts, kept and without verdicts:
  - main_ABORTED_capleak.out 3c1e9722: killed at 10:48, before the capability fix, with outputs wiped;
  - main_INTERRUPTED_restart.out 144a7c6b: a container restart.

## 3. What "Your solution is okay!" certifies

bb read comparator v4.34.0 Main.lean 288–318. `compareIt` builds the Challenge and exports it, and only then builds and exports
the solution. `verifyMatch` then runs, in order:
- `IO.ofExcept compareAt`: the theorem's type is equal up to alpha-equivalence, and every constant reachable from the
  statement has an equal ConstantInfo;
- `IO.ofExcept checkAxioms`;
- every external kernel and the builtin kernel. Any failure is collected and thrown.

"Your solution is okay!" is printed only after `verifyMatch` returns. Version 4.34.0 prints no separate statement or axiom
line, so this final line is the evidence. The tamper logs show the `compareAt` throw text, which confirms that that step is
live.

Each external kernel receives the export file as its last argument, and nanoda receives its config. Exit 0 means accept (Main.lean
152–210).

## 4. Export identity and the declaration count

**The runner's separate export.** The runner exported the solution separately (post.out 27620fb9) through the same shim, with
comparator's exportTargets.
- Result: **1,730,282,328 B, md5 5ca44ad56ff72d181c96b92a3d78d999**, non-empty.
- Kind counts: def 21,917, thm 101,212, axiom 3, opaque 55, quot 4, and 1,452 inductive blocks.

**bb's independent export.** bb re-exported BbOaiMeaning in its own local OAI environment (recount36.sh eaa489e5). That is the
plain-lean chain build against OpenAI's tree as built in the 7 October replay. bb used the same 34 targets, read from Main.lean
241–280: Quot ×4, the theorem, the 3 axioms, and 26 primitives (Nat.zero and Nat.succ are commented out).
- Result: **1,730,282,328 B, md5 5ca44ad56ff72d181c96b92a3d78d999. Byte-identical.**
- con-leche on bb's copy: "accepted 124639 declarations".
- **Consequence:** the environment the sandboxed kernels accepted is bit-for-bit the one bb built and replayed with five
  checkers (REVIEW_GAUSS_BRIDGE_ADD1). It also closes, for this closure, the gap that bb's local dependency checkouts were never
  hashed (provenance/OAI_ENV.md). The fresh-pin build and the local build agree exactly.

**The count, 124,639 versus bb's earlier 124,635.** bb's earlier export used 8 targets (meaning.ndjson 6888b248). A name-level
diff (decl_names.py a3326c96; lists e69d40df and b496b555) gives **+4 and −0**:
- def Nat.lor
- def Nat.xor
- def String.mk
- thm String.mk._proof_1

These all come from comparator's primitive targets and lie outside the theorem's closure (log/recs_extra.txt da33463d).
**Reconciled.**

## 5. Comparator assumption 2 (the solution not compiled before the challenge)

The queue shares one `.lake`, and each solution build has write access to `.lake`. So later runs replay challenge oleans that
had been built before. bb asked for evidence that the challenge side was untouched.

- **The runner's fresh check** (fresh_check.sh c6a3ef76, out b2cb533c8a499b8fa888e880021d8866):
  - a fresh directory holding only the 4 challenge files, at the bundle md5s;
  - a Mathlib-only lakefile and manifest (aeeb3ead, 7da383c2);
  - Mathlib from the cache, then `lake build` of the 4 modules.
- **Result:** all 4 .olean files are identical to the run's (ChallengeDefs 08daf671, Challenge f2f8f98e, TamperA 378bc601,
  TamperB fd95cca0). All 4 .ilean files are identical too, and all 8,548 Mathlib oleans match the run's manifest (1dac4392).
  **Assumption 2 holds.**
- **A failed first attempt, disclosed.** The first fresh-check attempt failed in setup (a missing Cli dependency) and built
  nothing (b08cf68a). It has no evidential value and was re-run.
- **A side observation.** bb's own pre-flight builds of the 4 challenge modules, made with plain `lean -o` on macOS, have
  .ilean files identical to the run's, but different .olean bytes. bb did not investigate this; the build driver (plain lean
  versus Lake) is the likely cause. It does not bear on the check, which compares Lake with Lake. bb's pre-flight had already
  shown the challenge constants identical at the ConstantInfo level (challenge/preflight/).

## 6. Caveats that stay with the result

- **The logs are RELAYED.** bb has the verdict lines and md5s as reported, not the files. The export identity in §4 is bb's
  own reproduction of the checked environment, not of the kernel verdicts.
- **The sandbox.** uid 0 with all capabilities dropped, in an ephemeral single-tenant container. Comparator's README
  assumption 6 (not a privileged user) is met in spirit, not in letter.
- **Mathlib** is taken from its official build cache at d13f23b. Its definitions are trusted as compiled there, which
  Comparator's README permits.
- **Cross-version checkers.** The rc3 checkers read v4.34.1 exports (format 3.1.0); lean4lean is N/A.
- **The harness.** A disk reaper (c_reaper.sh 5e4029fc) ran outside the sandbox. It only removed `ir/*.setup.json` and
  truncated `ir/*.c` of finished modules, never touching olean, ilean, trace or hash files. It cannot affect a verdict.
- **Trust in OpenAI.** The result rests on OpenAI's kernel-checked 7/8 theorem; its manuscript is unrefereed.

## 7. Label

**"bb_real_primitive_meaning_oai (Λ_χ ≤ 9/32 for every real primitive χ ≠ 1, with the general-χ bridge): Comparator PASS against an independently written challenge — comparator v4.34.0, bwrap sandbox (uid 0, all capabilities dropped), default and paranoid kernel sets (Lean, nanoda, leanchecker-paranoid, con-leche, con-ron; lean4lean N/A), axioms standard 3, both tampers rejected; run and logs relayed by the runner; solution export reproduced byte-for-byte by bb (5ca44ad5); challenge oleans confirmed by a fresh rebuild."**

## 8. Proposed text for the paper's §5.6 (to replace the PLACEHOLDER box and the "Results" paragraph)

> \emph{Results.} The run was made on 30 October 2026 by another agent session, with Comparator \lean{v4.34.0} and a
> \lean{bwrap} sandbox in place of \lean{landrun} (uid 0, all capabilities dropped, no network), on OpenAI's environment
> rebuilt from its public pins (Mathlib from its official build cache at \lean{d13f23b}; \lean{PrimeNumberTheoremAnd} and
> \lean{rellich-kondrachov} cloned at their pins and patched with OpenAI's patches; OpenAI's sources unmodified) and our chain
> at the audited md5s. With the challenge files listed above, Comparator printed ``Your solution is okay!'' both with
> \lean{nanoda} and Lean's kernel (log md5 \lean{fc80db0a}) and with the paranoid set \lean{leanchecker-paranoid},
> \lean{nanoda}, \lean{con-leche}, \lean{con-ron} and Lean's kernel (log md5 \lean{fb164675}; \lean{con-leche} and
> \lean{con-ron} report $124{,}639$ declarations); \lean{lean4lean} cannot read \lean{v4.34.1} exports and was not run. In
> Comparator \lean{v4.34.0} that message is printed only after the statement comparison, the axiom check and every kernel have
> passed. Both tampered challenges were rejected with ``Challenge and solution theorem statement do not match'' (log md5s
> \lean{78a706f6}, \lean{d1f16445}). The auditor did not see these logs, but reproduced the solution export independently,
> from its own build: it is byte-identical ($1{,}730{,}282{,}328$ bytes, md5 \lean{5ca44ad5}), so the environment the sandboxed
> kernels checked is exactly the one replayed in \cref{sec:verification}. Because the queued runs share one build directory,
> the challenge-side oleans were rebuilt afterwards in a fresh directory and found identical (Comparator's assumption that the
> solution was not compiled before the challenge).

Keep the "Caveat that the result will carry" paragraph above it.

## Files

- **bb's records** (~/e9-research/review_cn1/p1p6/oaiport/):
  - recount36.sh eaa489e5, log/recount36_progress.txt, log/recount36_conleche.out;
  - decl_names.py a3326c96, log/recs_8targets.txt e69d40df, log/recs_34targets.txt b496b555, log/recs_extra.txt da33463d;
  - exp/meaning36.ndjson (5ca44ad5; kept for now).
- **Setup copies:** ~/e9-research/review_cn1/p1p6/lcc_setup/ (shim 13a13e8b, lakefile e2eb57db, manifest 458daaf2,
  config_paranoid 4dc0b50c).
- **Closure check:** ~/e9-research/review_cn1/p1p6/chal/src/BbNvRoots.lean fccab000, log/BbNvRoots.out 24ab19a8.
- **The runner's logs:** in its container (pub/logs/), as listed above.
