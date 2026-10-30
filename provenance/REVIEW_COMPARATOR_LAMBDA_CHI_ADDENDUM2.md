# bb: Addendum 2 to REVIEW_COMPARATOR_LAMBDA_CHI (603fa0db): two precision corrections to bb's own wording

*AI review by bb, NOT an operator read-back.* Fri 2026-10-30. Read-only. The verdicts of the review and of Addendum 1
(29c20743) are unchanged.

## C1. What "the environment the sandboxed kernels checked" was replayed by

**Old wording (bb's own):**
- **Summary, l. 22–23:** "So the environment the sandboxed kernels checked is exactly the one bb built and replayed locally
  with five checkers."
- **§4, l. 112–113:** "the environment the sandboxed kernels accepted is bit-for-bit the one bb built and replayed with five
  checkers".
- **§8, paper text, l. 175–176:** "so the environment the sandboxed kernels checked is exactly the one replayed in
  \cref{sec:verification}".

**Why it is imprecise** (pub_assembler noticed this): it runs together two exports of bb's local build.

| Export | md5 | Targets | Declaration records | Checked by |
|---|---|---|---|---|
| meaning36.ndjson | 5ca44ad5 | 34, Comparator's exportTargets | 124,639 | the sandboxed kernels (the runner's copy is byte-identical); bb's local con-leche ("accepted 124639 declarations", recount36_conleche.out) |
| meaning.ndjson | 6888b248 | 8: the theorem, Quot ×4 and the 3 axioms | 124,635 | bb's five local checkers (leanchecker, leanchecker-paranoid, nanoda, con-leche, con-ron) |

- **The theorem's closure.** The 8-target export has the theorem as a target, so its records contain the theorem's whole
  closure.
- **The name-level diff** (decl_names.py a3326c96) is +4 / −0: the 124,635 are a subset of the 124,639. The extra four are
  `Nat.lor`, `Nat.xor`, `String.mk` and `String.mk._proof_1`. They come from Comparator's primitive targets and lie
  outside the theorem's closure; if they were inside it, the 8-target export would contain them.
- **Both exports come from the same local environment** (`~/oai-replay`, the chain at the audited md5s), so a declaration
  with the same name has the same content in both.

**Precise statement:**
- The sandboxed kernels checked, byte for byte, the 34-target export of bb's local build.
- For every declaration in the theorem's closure, that is the same declaration bb's five local checkers replayed.
- The four extra primitive-target declarations were checked by the sandboxed kernels and by bb's con-leche only.

None of this changes a verdict: the extra four are core declarations outside the theorem's closure. The claim was right in
substance and imprecise in letter.

**Replacement text** for the paper, §5.6 Results (l. 594). Replace from "so the environment the sandboxed kernels checked
is exactly the one replayed in \cref{sec:verification}." through the end of the parenthetical "(… which Comparator exports as
kernel primitives.)" with:
> so the sandboxed kernels checked, byte for byte, the export of the auditor's own build. The five-checker replay of
> \cref{sec:verification} used an export of that build with fewer targets (md5 \lean{6888b248}): its $124{,}635$ declaration
> records contain the whole closure of the main theorem and are a subset of these $124{,}639$. The extra four,
> \lean{Nat.lor}, \lean{Nat.xor}, \lean{String.mk} and an auxiliary proof, lie outside that closure; Comparator exports them
> because it lists them as kernel primitives. The auditor also ran \lean{con-leche} on its own copy of the \lean{5ca44ad5}
> export, and it accepted all $124{,}639$ declarations.

**logs/comparator_sandboxed/README.md** (cdaaa97). Its caveat already says this precisely: "accepted an export of the same
build, made with 8 targets instead of 34 … differs only by four primitive declarations outside the theorem's closure".
One optional tightening: "four primitive declarations" → "four declarations that Comparator exports as kernel primitives".

## C2. "independently written challenge", everywhere in the review

Addendum 1 §4 corrected this only for the §7 label (l. 160). The same phrase is also in the summary, l. 17 ("bb's
independently written challenge").

**Read it as "separately written" in both places** (REVIEW_PAPER_v2_13_delta F1). The challenge was written by another
session of the same programme.

"Independently reproduced" and "independent export" (l. 21, 107, 174) are accurate as written. They mean a separate build
from the runner's.
