# Verification logs

Everything here is a byte-for-byte copy of the auditor bb's own records from 29 October 2026, except one file
noted below, and every file's md5 is in `MD5SUMS.txt` (`scripts/verify_md5.sh logs` checks them). The runs were
local and unsandboxed, on macOS. They are not a Comparator run; that one is still to come
(`comparator_sandboxed/`).

## `five_checker/`: the kernel replays

The chain was exported from OpenAI's environment (Lean v4.34.1, Mathlib `d13f23b`, openai/math `adc7f124`) with
`lean4export` 3.1.0, and the export was fed to five independent checkers: Lean's `leanchecker`, the same in
paranoid mode, nanoda, con-leche and con-ron. Each run also checked a negative control,
`BbNeg.bogus : 4 = 5`, a false theorem slipped into the environment with `debug.skipKernelTC`
(`lean/checks/BbOaiSkip.lean`). A checker that accepted the control would have made the run invalid; all five
rejected it.

- `meaning/` is the run on the headline conjunction `bb_real_primitive_meaning_oai`. The export, `meaning.ndjson`,
  was 1,730,561,283 bytes with md5 `6888b248e37c70f2f5ddcf76b1009be3`. It is too large to keep here, and it is
  reproducible from the sources. con-leche and con-ron each report "accepted 124635 declarations (--verified)".
  leanchecker, leanchecker-paranoid and nanoda print nothing on success, so their `km_meaning_*.out` files are
  empty and their verdict is the exit code (rc 0), recorded in `meaning_progress.txt`. That file ends `DONE`, with
  no ABORT or INVALID line. `meaning.sh` is the script that ran it.
- `realprim/` is the earlier run on the first conjunct alone, `bb_real_primitive_real_zeros_oai`. Its export was
  `realprim.ndjson` (md5 `ae0c51bd91939cfa1a4236da5c379b6b`), and con-leche and con-ron report 124,633
  declarations. It has the same structure as `meaning/`.

Both runs used the checkers bundled with Lean v4.35.0-rc3, which read the same export format (3.1.0). lean4lean
is N/A: the available build crashes on v4.34.1 exports before it reaches any declaration ("unknown constant
'Decidable.intro'"), so it was not counted.

## `oai_env/`: the build and the statement checks in OpenAI's environment

- `progress.txt` holds the return code and source md5 of every module the auditor built (rc 0 throughout).
  `build.sh` is the build script: plain `lean`, one module at a time, against OpenAI's built tree.
- `BbOaiMeaningCheck.out` prints both conjuncts' axioms, `[propext, Classical.choice, Quot.sound]`. It also
  shows the auditor's independent closure walk agreeing with `collectAxioms`, and lists every constant in the
  statements with its module: none is from `OAI.*`.
- `BbOaiMeaningRef.out` is the bridge statement in `pp.all` form, elaborated with only the chain and Gauss in
  scope (no OpenAI module). It is byte-identical with the same text printed inside OpenAI's environment.
- `BbOaiMeaningTamper.out` has the three expected errors: 1/8 → 1/4 and k → 1−k are rejected outright, and
  dropping primitivity breaks the proof.
- `BbOaiRealPrimCheck.out`, `BbOaiRealPrimRef.out` and `BbOaiRealPrimTamper.out` are the same checks for the
  first conjunct. In its tamper file, 7/8 → 3/4 is rejected at OpenAI's own theorem.
- `BbOaiMeaning.out` is empty: the module compiled without a message.

## `rc3_audit/`: the stage-by-stage audit at the other pin

These are the outputs of the check and tamper files in `lean/checks/rc3_audit/`, run at Lean v4.35.0-rc3 with
Mathlib `0493595e`. This is where each stage was first reviewed: the generic library, the Mellin bridge, the
theta functional equation and χ₋₄, the strip, the Gauss sign theorem, and the meaning link. `gen_build_progress.txt`
is the build log of the generic library at that pin. `GaussBridge.out` holds the two deprecation warnings from
compiling `GaussBridge.lean` there.

## `numerics/`: the auditor's independent numerics

These are mpmath scripts written by the auditor, independent of the Lean sources.
- `bb_d2b_numeric.py` checks the bridge identity Hd₀(z) = (1/8)·4^{(s+1)/2}·Γℝ(s+1)·L(s, χ₋₄) at three points, with
  agreement to 5e-31 or better.
- `bb_gauss_numeric.py` checks the quadratic Gauss sum for N ≤ 200, and ε = 1 for the odd primes below 500.
- `bb_gauss3_numeric.py` checks ε(χ_D) = 1 for all 1,218 fundamental discriminants with 0 < |D| ≤ 2000.

They are records. Nothing in the Lean proof depends on them.

**The one modified file.** In `bb_gauss_numeric.out`, the first line is a SymPy deprecation warning that carried
the auditor's absolute home path; it has been replaced by `$HOME`. The original md5 is
`5ef0d24b0537de416b2ae95a45e9c25c`, and this copy's md5 is in `MD5SUMS.txt`. No other byte differs.
