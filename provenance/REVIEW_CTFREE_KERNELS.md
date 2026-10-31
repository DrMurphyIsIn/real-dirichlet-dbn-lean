# bb: six-checker kernel replay of the CT-free P2 and Ingham compositions, with a must-reject control

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

**Scope.** These are bb's CT-free conditional forms. CTRat's audited conclusion `∀ {s}, 31/32 < s.re → s ≠ 1 → riemannZeta s ≠ 0`
is a hypothesis, and the s = 1 bridge and the compositions are copied verbatim from the bundle files:
- `BbP2.dbn_real_zeros_of_ct`: P2, Λ ≤ 225/512 form; BbP2CondSolution.lean 02be0f7e, on the dBN island.
- `BbIng.psi_sub_le_thirtyone_div_thirtytwo`: Ingham, 31/32 + ε; BbIngCondSolution.lean 93778ad5, on the Arda bricks + Ingham
  chain.

No Cureton–Thorner or OpenAI code is in either closure.

**Method** (cmp/kernels.sh 2be82444):
- Both modules are built with plain `lean` on Mathlib 0493595e and Lean v4.35.0-rc3.
- Each is exported with the toolchain's bundled `leanexport <module> -- <theorem> Quot Quot.mk Quot.lift Quot.ind propext Quot.sound
  Classical.choice`.
- Each export is fed to the six checkers bundled with the toolchain, with exit codes captured directly: `leanchecker-paranoid`,
  `lean4lean`, `nanoda_bin` (axioms restricted to the standard 3, hard error), `con-leche`, `con-ron` and `leanchecker`.
- This is the `--paranoid` set plus Lean's default kernel. bb did NOT use `lake comparator --inadvisably-no-sandbox`, because the
  safety classifier blocked that flag. So there is no Comparator statement compare in this run. Statement identity rests on bb's
  in-environment Expr.eqv checks (REVIEW_P1P6_BUNDLE §1 and REVIEW_INGHAM (b)).

**Run 1 was VACUOUS and is discarded** (kept in log/run1_vacuous/).
- The rc3 `leanexport` resolved the default v4.35.0 toolchain's Init.olean, hit "incompatible header", and wrote 0 bytes.
- All six checkers then exited 0 on the empty files, **the negative control included**.
- Fix: the toolchain bin goes first on PATH and `<toolchain>/lib/lean` first in LEAN_PATH.
- New guards: an export failure or near-empty export means ABORT, and any checker accepting the control means INVALID RUN.

**Run 2 is VALID** (log/kernels_progress.txt 8087a458).

| Export | Bytes | md5 |
|---|---|---|
| control | 348,664,364 | bc49dc4f |
| P2 | 469,748,049 | 05d1319a |
| Ingham | 431,402,808 | 9de6e91c |

| Checker | control (BbNeg.bogus : 4 = 5 via skipKernelTC) | P2 | Ingham |
|---|---|---|---|
| leanchecker-paranoid | rc 1, REJECT | rc 0 | rc 0 |
| lean4lean | rc 134, REJECT (panics in its error printer after the type error) | rc 0, "checked 62691 declarations" | rc 0, "checked 59120 declarations" |
| nanoda | rc 101, REJECT (panic at tc.rs:955, `def_eq(u, v)`) | rc 0 | rc 0 |
| con-leche | rc 1, "invalid: type mismatch in theorem BbNeg.bogus" | rc 0, "accepted 62690 declarations (--verified)" | rc 0, "accepted 59119 declarations (--verified)" |
| con-ron | rc 1, "rejected: type mismatch … BbNeg.bogus" | rc 0, "accepted 62690" | rc 0, "accepted 59119" |
| leanchecker (Lean default) | rc 1, REJECT | rc 0 | rc 0 |

- **The control was rejected 6 of 6, so the acceptances are not vacuous.**
- **The off-by-one between lean4lean and con-\* is explained.** con-\* model the Lean.Syntax inductive block in-process and do not
  count it as a record of the file, as their own banner says. That accounts for the 62691/62690 and 59120/59119 gaps here, and for
  the 206507/206506 gap in your CT run (REVIEW_CTQ Add.1 "minor").

**Chain status, with no CT code run by bb:**
1. CT `main`, accepted by 6 checkers in your Linux run (RELAYED, plus bb's reading of Check.lean).
2. bb's Mathlib-only CT@Q reduction to the ζ half-plane (REVIEW_CTQ, kernel).
3. These CT-free compositions, accepted by 6 checkers here.

Only the CT-dependent full-config Comparator runs remain with your queue.
