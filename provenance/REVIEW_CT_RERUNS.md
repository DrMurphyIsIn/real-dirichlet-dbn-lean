# bb: the cap-drop Comparator re-runs of P2, Ingham and CT main

*AI review by bb, NOT an operator read-back.* 2026-10-31. Read-only: bb ran nothing on the runner's machine.

**Status: FINAL.**

## 1. Why the re-runs were made

The first P2, Ingham and CT-main Comparator runs (10-29) used the rc3 toolchain's `lake comparator` sandbox, bwrap as uid 0
*without* a capability drop. That keeps root capabilities inside the sandbox. bb ruled that the verdicts stood but the
"sandboxed" label did not. The user approved re-runs with `--cap-drop ALL`:
- P2 and Ingham, each paranoid plus tamper;
- CT main, paranoid.

All five were made on 10-30/31 by another agent session (the contrarian). Their verdict lines and md5s are **RELAYED**: bb did not see
the logs. bb checked every relayed field against its own records.

## 2. The runs

All five share the same setup:
- wrapper bwrap-capdrop.sh **b33d92b1** (`exec bwrap --cap-drop ALL "$@"`, every call logged), accepted on 10-30;
- probe.sh cb6643fd;
- CT at 09afbb4, with lakefile d772eda6, the only tracked change, and manifest 4738ea1a;
- the lakefile diff (778f387f, 1,629 B) was relayed inline and checked by bb:
  - bb rebuilt it byte-exact (md5 match). Its base blob 523531e is CT's lakefile at 09afbb4 (4a898695), and applying it gives
    d772eda6 exactly.
  - It appends six `[[lean_lib]]` stanzas (ArdaDBN, CTRatLib, ArdaDBNChallenge, ArdaZeta, ArdaIngham, ArdaDBNGen), each with
    name, srcDir and roots only.
  - It has no require, leanOptions, moreLeanArgs, weakLeanArgs, precompileModules or defaultTargets change. CT's own stanzas
    and its package options (`autoImplicit = false`, `relaxedAutoImplicit = false`) are untouched.
  - ArdaDBNGen is declared but not imported by these runs.
- rc3 toolchain 8359154e, Mathlib 0493595e from its official cache;
- vm.max_map_count 1048576.

The challenge sources equal bb's audited copies:

| File | md5 | Source of bb's copy |
|---|---|---|
| DedekindZetaChallenge | 1b4c9117 | REVIEW_CTQ |
| CTRatDBNChallenge | 411693af | bb_bundle_1029 |
| CTRatDBNChallengeTamper | 3649c005 | bb_bundle_1029 |
| InghamChallenge | ccf8dddc | ingham/bbl |
| InghamChallengeTamper | b03623b3 | ingham/bbl |
| DBNDefs | acfa852d | |

| Run | Config (= bb's copy) | Log md5 | Verdict | bwrap calls / with cap-drop / `--cap-add` |
|---|---|---|---|---|
| p2_paranoid | comparator_dbn.json 82a5a830 | fed70f9a | 6/6 kernels accept; "Your solution is okay!"; EXIT 0 | 12 / 12 / 0 |
| p2_tamper | comparator_dbnTamper.json d82dd3b0 | 90424a05 | statement mismatch; EXIT 1 | 6 / 6 / 0 |
| ingham_paranoid | comparator_ingham.json 1d203b88 | dd6fa95b | 6/6 accept; okay; EXIT 0 | 12 / 12 / 0 |
| ingham_tamper | comparator_inghamTamper.json fbce2885 | 33d0ea1c | statement mismatch, before any kernel ran; EXIT 1 | 6 / 6 / 0 |
| ct_main | comparator.json 984d2e11 (main + heckeCorollary, CT's own challenge) | a33d06b0 | 6/6 accept; okay; EXIT 0 | 12 / 12 / 0 |

- **The six paranoid kernels:** Lean paranoid, lean4lean, nanoda, con-leche, con-ron and Lean's default kernel.
- **Every probe:** CapEff 0; mount-bind and remount-rw denied; EROFS outside the rw set; no escape.
- **ct_main's solution,** DedekindZetaSolution.lean 87c46452, was hashed before, at start and at exit. It equals bb's clone.

**Counts.** These equal the original runs' and REVIEW_CTQ's:

| Run | lean4lean | con-* |
|---|---|---|
| P2 | 208,773 | 208,772 |
| Ingham | 207,691 | 207,690 |
| CT main | 206,507 | 206,506 |

The +1 also holds on bb's own two local exports (62,691 / 62,690 and 59,120 / 59,119). So it is constant across every export
seen, which bb reads as a counting convention between the checkers. bb has not traced its mechanism; it is not load-bearing,
since every checker accepted. This replaces the "unexplained" note in REVIEW_CTQ.

**Interrupted attempts, not counted:**
- p2_paranoid: ENOSPC ebceab1a, restart d590474f, restart 4fd378fe;
- ingham_paranoid: restart 31790024.

**The container restarts** (17:48, ~21:17 and 05:27) remain unexplained. The runner's "no tracked task" explanation was
falsified at 05:27. The memory logs show con-ron peaking at 9.3 GB against a 13.4 GiB cgroup, with oom_kill 0.

## 3. Toolchain integrity

The installed rc3 toolchain was compared with the official lean-4.35.0-rc3-linux.zip:
- 17,931 of 17,931 files identical, 0 missing, 0 extra (toolchain_check.out a0664d2a);
- that covers every checker binary;
- bb independently fetched the GitHub release API: digest sha256 fb73ada4…1d05, 927,944,558 B, uploaded 2026-09-24. It equals
  the runner's download.

/usr/bin/bwrap and the system libraries are not covered.

## 4. Compile provenance: every solution artifact traces to a cap-drop build

**The method.** For each run's attempt sequence:
- R = modules with a "Replayed" line;
- B = modules with an earlier "Built" line.

Lake prints a Built line for every built job, but a Replayed line only for modules with stored messages.

**P2.** After the 10-30 10:26 wipe, every Built line is in a cap-drop attempt. The wrapper call log has 40 entries, all
with cap-drop and `--cap-add` 0.

**The gap, found by this check.** CT requires FiniteAbelianGlobalReciprocityv2 as a *path* package
(vendor/class-field-theory, 1,658 modules):
- the wipe missed its `.lake`;
- its oleans were built on 10-29 by an unsandboxed root `lake build`;
- 90 of them appear in R \ B, and the rest replay silently.

**Closed by (a′), the user's decision.**
- **Static scan.** bb scanned the package on its own clone at 09afbb4. It has no elaboration-time code, no IO and no IO
  tactics, and a TOML lakefile.
- **Fresh-directory rebuild.** The package was rebuilt from `git archive 09afbb4` inside the cap-drop sandbox (cft_fresh
  2230938b): all 1,658 .olean, .ilean, .ir, .c and .sig files are byte-identical. 130 .olean.server/.private parts differed
  because stored linter messages embed the build path.
- **Path-identical rebuild.** A rebuild bind-mounted at the run's path (cft_fresh2 9f41320e) matches on all 11,606 artifacts
  (list md5 89b3fd2d, equal to the run tree's before and after; 0 files newer than the marker).
- **Result:** the vendored inputs equal those of a cap-drop build.

**Ingham** (attempts 31790024, then dd6fa95b, then 33d0ea1c):
- its 18 own modules were built under cap-drop in 31790024;
- 2,248 replays trace to P2 cap-drop builds;
- 90 are CFT.

**CT main:** only the challenge was built; 2,237 replays trace to P2 and Ingham cap-drop builds; 90 are CFT.

**Unsandboxed but trusted:**
- `lake exe cache get` at 14:28 compiled 18 Mathlib Cache.* oleans plus bin/cache, and 1 Batteries olean
  (Tactic/OpenPrivate). This is trusted tooling built from trusted source.
- The ct_fresh_check below covers Mathlib but not that Batteries olean.

## 5. The challenge side: ct_fresh_check

The script ct_fresh_check.sh (2e5bfdf9) produced log e8689126 (97 lines), running 14:48 → 15:02 UTC with no restart. All
values are relayed.

**Challenge side:** "CT CHALLENGE ARTIFACTS IDENTICAL (20)".
- The 8-module challenge closure was rebuilt in a fresh directory: DedekindZetaChallenge, CTRatDBNChallenge and its Tamper,
  InghamChallenge and its Tamper, DBNDefs, Lc.LiCriterion.Basic and Lc.XiZeros.
- Every .olean and .ilean is byte-identical to the run's. So are DedekindZetaChallenge's .ir, .ir.sig, .olean.private and
  .olean.server.
- **The fresh sources equal bb's copies,** including Lc/LiCriterion/Basic.lean ae26979b and Lc/XiZeros.lean ad41e3e9, which
  are bb's island sources (p1p6/island/src).
- The fresh lakefile (6487f3e5) and manifest (8b66b41b) carry CT's package name, options and challenge stanzas, with Mathlib
  0493595 only. Its dependency pins equal CT's.

**Mathlib:** "CT MATHLIB OLEANS IDENTICAL (8567)". The run-tree manifest (5c6469e8) was written before the script freed
the run's Mathlib build.

**Comparator assumption 2 holds for the CT runs.**

**Scope:**
- The check itself ran outside the sandbox, by design. It is reproducibility evidence for the challenge side, not a sandbox
  check.
- Its Mathlib oleans were decompressed from the same local cache the run used ("No files to download"). So the comparison
  shows the run's Mathlib is unmodified since `lake exe cache get`. Its trust root stays the official cache.
- Batteries OpenPrivate and the vendored package are outside its coverage. The vendored package is covered by §4.

## 6. Verdict

**P2, Ingham and CT main pass Comparator --paranoid under cap-drop. Both tampers are rejected.**

The runs used:
- solution artifacts that are cap-drop-built, directly or by the (a′) byte-identity;
- a toolchain that is the published release.

The challenge side matches a fresh rebuild (§5). **The labels:** "sandboxed (bwrap, uid 0, all capabilities dropped); verdicts relayed".

## 7. Replacement text for the paper, §6 "Status of the checks"

From "A Comparator run of \lean{main} at \lean{09afbb4} …" to the end of the paragraph, replace with:

> All three Comparator runs below were made on 30--31 October 2026 by another agent session. Each used the toolchain-provided
> \lean{lake comparator} of Lean \lean{v4.35.0-rc3} with \lean{-{}-paranoid} (\lean{leanchecker-paranoid}, \lean{lean4lean},
> \lean{nanoda}, \lean{con-leche}, \lean{con-ron} and Lean's kernel), in a \lean{bwrap} sandbox as uid 0 with all capabilities
> dropped, on Cureton--Thorner's repository at \lean{09afbb4} (its lakefile extended by 30 additive lines that only declare
> the libraries of our compositions and challenges) with Mathlib from its official build cache. The installed
> toolchain, checkers included, is file-for-file the published \lean{v4.35.0-rc3} release. The auditor checked each run's
> relayed configuration, challenge and solution md5s, sandbox probe, verdicts and exit code against its own records, but did
> not see the logs \cite[REVIEW\_CT\_RERUNS]{bbrecords}. Cureton--Thorner's own challenge (\lean{main} and
> \lean{heckeCorollary}): ``Your solution is okay!'', all six kernels accepting (log md5 \lean{a33d06b0}). The P2 and Ingham
> statements are kernel-checked from the type of \lean{main} itself, whose reduction to Mathlib's \lean{riemannZeta} was
> audited separately \cite[REVIEW\_CTQ, Addendum~1]{bbrecords}. P2: PASS, six
> kernels (log \lean{fed70f9a}); tamper ($224/512$) rejected, exit 1 (log \lean{90424a05}); the trusted definitions of the P2
> challenge match the audited \lean{DBNDefs} (md5 \lean{acfa852d}). Ingham: PASS, six kernels (log \lean{dd6fa95b}); tamper
> ($15/16$) rejected (log \lean{33d0ea1c}). Every solution module these runs used was compiled inside the sandbox, except
> Cureton--Thorner's vendored class-field-theory package, which had been compiled earlier without it; rebuilt inside the
> sandbox at the same path, it gave byte-identical build outputs. These runs replace earlier ones whose sandbox did not drop
> capabilities. The challenge-side build outputs were rebuilt afterwards in a fresh directory and found
> byte-identical (Comparator's assumption that the solution was not compiled before the challenge). The result rests on
> Cureton--Thorner \lean{main} at \lean{09afbb4}.

**What is dropped.** The clause "Our results do not rely on this run:" defended the earlier no-cap-drop CT-main run and is
no longer needed. Its content, the REVIEW_CTQ reduction of `main` to Mathlib's `riemannZeta`, is kept in the new text.
