# bb: Addendum 1 to REVIEW_COMPARATOR_LAMBDA_CHI (603fa0db): the logs are INSPECTED

*AI review by bb, NOT an operator read-back.* Fri 2026-10-30. Read-only: bb ran nothing on the runner's machine.

**Status: FINAL.** All seven logs were received and read, including main_INTERRUPTED_restart.out (§3).

## 1. What changed

REVIEW_COMPARATOR_LAMBDA_CHI recorded the run as **RELAYED**: bb had the runner's md5s and verdict lines, but not the logs.
The runner has now sent all six logs inline, and also the log of the interrupted attempt that compiled the solution (§3).
Each is xz-compressed and base64-encoded, and comes with its own md5s. bb decoded each one, matched both md5s and read it in
full.

**The record is upgraded to INSPECTED.** One qualification still applies: bb read the logs but did not repeat the run's kernel
executions. The run was made by another agent session.

| Log | Raw md5 | xz md5 | Lines | Verdict |
|---|---|---|---|---|
| main.out | fc80db0aad9b392d954354ca10a9c970 | 0989bc60236f7bc1f027a88560fa4912 | 2,620 | nanoda and Lean's kernel accept; "Your solution is okay!"; EXIT 0 |
| paranoid.out | fb16467579fd81ea4bbdbeb2de98578f | f1149a1adfe382ed8710a4eadae64f05 | 204 | con-leche and con-ron "accepted 124639"; leanchecker-paranoid, nanoda and Lean accept; okay; EXIT 0 |
| tamperA.out | 78a706f654a5f150347d74e945927731 | c0dca41bb0a2b883c7d80c8118b91e18 | 185 | "statement do not match: 'bb_real_primitive_meaning_oai'"; EXIT 1 |
| tamperB.out | d1f16445e6cfa2126163a00b8cb02cb3 | 3e11840fd62e715f9c09c82f4c59fe39 | 185 | the same; EXIT 1 |
| post.out | 27620fb974d7a7c73c46c6206d2f2356 | 358c708916e67b17ac25a1234142778d | 26 | sandboxed export: 1,730,282,328 B, md5 5ca44ad5 |
| fresh_check.out | b2cb533c8a499b8fa888e880021d8866 | 64657619f55c945062ae3ab165e9afab | 49 | CHALLENGE OLEANS IDENTICAL; MATHLIB OLEANS IDENTICAL (8,548) |
| main_INTERRUPTED_restart.out | 144a7c6b6680df543b94f1e2394cce41 | f52deb44f0c911176254243ad5997fcf | 707 | the sandboxed attempt that compiled the challenge and 27 of the 29 chain modules; killed by a restart (§3) |

The six raw md5s of the recorded runs are the ones REVIEW_COMPARATOR §3 recorded from the relay, so nothing in §§2–6 of that review changes.

## 2. What bb checked in the logs

- **Headers.** main, paranoid and both tampers carry the same md5s for:
  - the challenge files and the solution sources;
  - the lakefile, manifest and toolchain;
  - comparator 990f646b, shim 13a13e8b, lean4export ec897d54, nanoda 0d9bd7d1;
  - max_map_count.

  They differ only in the config (d563faf7, 4dc0b50c, 1c2534bb, f34c06af) and in the challenge module each one builds.
- **Sandbox lines.** Every build, export and kernel step runs through landrun-bwrap:
  - **Builds:** ro `/`, the workspace and the toolchain; rw `/dev` and `.lake`.
  - **Exports:** `.lake` read-only.
  - **Kernels:** ro on their own temp files, `env=[]`.
- **Exports.** Both main exports, Challenge and BbOaiMeaning, use the 34 targets REVIEW_COMPARATOR §4 lists.
- **Kernels.**
  - main: nanoda and Lean's kernel.
  - paranoid: con-leche, con-ron, leanchecker-paranoid and nanoda in alphabetical order, then the builtin kernel.
    leanchecker-paranoid's own stdout says "Lean default kernel accepts the solution", which is benign.
- **post.out against bb's own copy.** bb recounted its byte-identical export (meaning36.ndjson, 5ca44ad5):
  - kinds: inductive 1,452, quot 4, def 21,917, thm 101,212, axiom 3, opaque 55. Exactly post.out's.
  - Records excluding quot: 124,639. That is the con-* count.
  - post.out's "constants 127,675" = 123,191 non-inductive records + 1,452 types + 1,578 constructors + 1,454 recursors.
- **fresh_check.out.**
  - It pins the Mathlib-only manifest to the same 9 revs.
  - It decompresses Mathlib from the cache; the 8 olean and ilean md5s are equal to post.out's run values; all 8,548 Mathlib
    oleans are equal.
  - **Scope:** its Mathlib came from the local `~/.cache/mathlib` the run used. So it shows that the run's `.lake` was untouched,
    which is what assumption 2 needs. It does not re-check the cache against the server. The runner reports that the cache was
    deleted and re-downloaded from the server at 10:49:42, before the sandboxed attempt (§3).
- **The challenge builds against Mathlib alone.** fresh_check builds ChallengeDefs and Challenge with a Mathlib-only lakefile.
  This backs the README sentence that the statement uses no constant from a patched package.

## 3. Where the solution was compiled: INSPECTED

main.out *replays* Challenge and the chain modules that do not import OpenAI. It builds only:
- 2,428 OAI.NumberTheory.DirichletL.* modules;
- BbOaiRealPrim and BbOaiMeaning.

Lake prints a replay only when the module has stored messages, so 16 replay lines appear, not one per module. bb asked the
runner where those outputs came from. The runner's answer is taken from its logs and command history, and is relayed:

**Before the recorded run (UTC):**
1. **Before 10:47:46** (all discarded):
   - an unsandboxed `lake build Challenge` at 10:34 and a lean4export of it at 10:35;
   - an attempt with the old shim without `--cap-drop` (f1d904c2) at 10:41, which was aborted (main_ABORTED_capleak.out
     3c1e9722).
2. **10:47:46, wipe:** `rm -rf .lake/build .lake/packages/*/.lake`.
3. **10:49:42:** `rm -rf ~/.cache/mathlib …; lake exe cache get`, a fresh download from the server.
4. **10:51:23 → ~11:38, an interrupted sandboxed attempt** of the same command, `lake env $CMP config.json`:
   - comparator 990f646b, shim **13a13e8b** (with cap-drop), every input md5 equal to main.out's;
   - it built ChallengeDefs and Challenge inside the shim, and exported the challenge;
   - it then built the solution side inside the shim, including the whole non-OAI chain, up to job 9467/11897 (the runner
     counted 544 modules; see below);
   - a container restart killed it (log main_INTERRUPTED_restart.out, **144a7c6b**, 707 lines).
5. **11:42:38, unsandboxed, as uid 0:** `: > .lake/build/ir/Challenge.c; lake build Challenge`. This tested that Lake replays
   rather than rebuilds. Its output was "Replayed Challenge" and compiled nothing; it touched only the challenge side.
6. **11:46:00:** main.out, the recorded run.

**What 144a7c6b shows** (bb read all 707 lines):
- **Header.** Lines 2–19 are identical to main.out's: config d563faf7, every source md5, lakefile, manifest, toolchain,
  comparator 990f646b, shim **13a13e8b**, lean4export, nanoda and max_map_count. It starts at 10:51:23.
- **The challenge is built inside the shim.** The landrun-bwrap line is rw only `/dev` and `.lake`. Then come
  "✔ [8924/8926] Built ChallengeDefs" and "⚠ [8925/8926] Built Challenge". The challenge export follows, with the same 34 targets.
- **The solution build is inside the shim.** It uses the same landrun-bwrap line and has 542 Built lines:
  - **27 of the 29 MANIFEST modules.** That is every chain module except BbOaiRealPrim and BbOaiMeaning, which import OpenAI
    and are built in main.out.
  - **15 RellichKondrachov and 4 PrimeNumberTheoremAnd modules,** the patched packages. That is exactly the 15 + 4
    non-standard non-OAI modules of BbNvRoots (24ab19a8).
  - **496 OAI modules.** With main.out's 2,428 they are disjoint and total **2,924**, exactly the OAI module count of
    Nonvanishing's import closure (BbNvRoots).
- **It ends mid-build** at [9467/11897], with no kernel step and no verdict. That is consistent with a kill.
- **The runner's count of "544 solution-side modules"** is the 542 solution-side builds plus the 2 challenge modules.

**So every module of the solution was compiled inside the cap-drop sandbox exactly once, across the two attempts.** The
patched packages and all of OpenAI's modules were too. The recorded run replayed the first attempt's outputs.

**bb's assessment:**
- **Every solution module was compiled inside the cap-drop sandbox.** This differs from CT-main, whose pre-build was
  unsandboxed.
- **Step 5 is outside the sandbox but harmless to the result.** The fresh check shows the challenge oleans and ilean equal
  a fresh build.
- **The wipe's scope.** It covers the build outputs and the Mathlib cache. It does not cover the tool binaries (comparator,
  lean4export, nanoda, the rc3 checkers) or the toolchain. An escape during the aborted no-cap-drop attempt could in principle
  have reached those. That matters only for an adversarial solution. This solution is our own audited, md5-pinned chain, and
  bb's local five-checker replay accepts the byte-identical export independently of the runner's binaries. So the result does
  not rest on the sandbox's integrity.
- **Lake's trace rule.** Traces are written only after a job succeeds. So the outputs replayed from the interrupted attempt
  are complete builds.

## 4. Corrections to REVIEW_COMPARATOR_LAMBDA_CHI

- **§7 label:** read "independently written challenge" as "separately written challenge" (REVIEW_PAPER_v2_13_delta F1). The
  challenge was written by another session of the same programme.
- §§2–6 are unchanged.

## 5. Replacement text (X6 of REVIEW_RELEASE_REPO_v2_delta), ready to apply

**Paper, l. 495 (trust base).** Old: "…ran as uid 0 with all capabilities dropped, and its logs were relayed to the auditor,
not inspected by it." New:
> …ran as uid 0 with all capabilities dropped; it was made by another agent session, and the auditor read all of its logs but
> did not repeat its kernel runs.

**Paper, l. 588.** Old: "the auditor then verified the relayed results". New:
> the auditor then read the run's logs in full and verified them

**Paper, l. 594 (§5.6 Results).**
- Replace "The auditor did not see these logs, but reproduced the solution export independently, from its own build:" with:
  > The auditor read all of the run's logs (\cite[REVIEW\_COMPARATOR\_LAMBDA\_CHI, Addendum~1]{bbrecords}) and reproduced the
  > solution export independently, from its own build:
- Insert before "Because the queued runs share one build directory, …":
  > The solution was compiled inside the sandbox, in an earlier attempt of the same Comparator command that a container
  > restart interrupted (log md5 \lean{144a7c6b}); the recorded run replayed those build outputs. Before that attempt the
  > build directory was wiped and Mathlib's cache downloaded afresh, discarding an earlier attempt that had been made without
  > the capability drop. Between the two attempts one unsandboxed \lean{lake build Challenge} was run to test Lake's replay
  > behaviour; it compiled nothing.

**Paper, l. 625 (limitation 2).** Old: "…and its logs were relayed to the auditor, who reproduced the solution export byte for
byte but not the kernel verdicts." New:
> …and it was made by another agent session: the auditor read its logs and reproduced the solution export byte for byte, but
> did not repeat its kernel runs.

**README, l. 188.** Old: "Its logs were relayed to bb (REVIEW_COMPARATOR_LAMBDA_CHI.md)." New:
> bb read all of its logs and checked their md5s (`provenance/REVIEW_COMPARATOR_LAMBDA_CHI.md` and its Addendum 1). The
> solution was compiled inside the sandbox, in an earlier attempt of the same command that a container restart interrupted;
> the recorded run replayed those outputs.

**README, caveat 3 (l. 194–195).** Old: "bb did not see the logs. …" New:
> - The run was made by another agent session. bb read its logs and reproduced the solution export byte for byte, but did
>   not repeat its kernel runs.
> - One unsandboxed `lake build Challenge`, run between the two attempts to test Lake's replay behaviour, compiled nothing;
>   the challenge oleans match a fresh rebuild.

**NOTICE.md, l. 42–44.** Old: "…and its logs were relayed to bb, who reproduced the solution export byte for byte." New:
> …; bb read its logs in full and reproduced the solution export byte for byte.

**challenge/README.md, l. 91–93.** Old: "bb did not see the logs, whose verdict lines are relayed, but it reproduced the
solution export byte for byte. The full logs will go in `logs/comparator_sandboxed/`." New:
> bb read all of the run's logs and reproduced the solution export byte for byte. The logs are in
> `logs/comparator_sandboxed/`, with the runner's scratch path replaced by `$SCRATCH`.

## 6. For logs/comparator_sandboxed/

Archive the normalized copies (`$SCRATCH` for `/tmp/claude-0/-home-user-Arda/<session UUID>/scratchpad`). bb made them at
~/e9-research/review_cn1/p1p6/lcc_logs/normalized/ (MD5SUMS.txt). List both md5s, since the paper cites the raw ones.

| Log | Raw md5 | Normalized md5 |
|---|---|---|
| main.out | fc80db0aad9b392d954354ca10a9c970 | 27549b58ecb5ffd6936702dea01802fe |
| paranoid.out | fb16467579fd81ea4bbdbeb2de98578f | 0c511e13101f9340ed0266c959e4e241 |
| tamperA.out | 78a706f654a5f150347d74e945927731 | ebe6a1050ccc3e1edc71791d994bc08e |
| tamperB.out | d1f16445e6cfa2126163a00b8cb02cb3 | 43d6f357498db7d5e6b9c0190035f760 |
| post.out | 27620fb974d7a7c73c46c6206d2f2356 | 6ecd62eb836213a4992a9b19462248ba |
| fresh_check.out | b2cb533c8a499b8fa888e880021d8866 | (no path; unchanged) |
| main_INTERRUPTED_restart.out | 144a7c6b6680df543b94f1e2394cce41 | 6a445130462472cecb7f145889dfbce7 |

Archive REVIEW_COMPARATOR_LAMBDA_CHI.md (603fa0db), unchanged, at `provenance/`, with this addendum beside it.
