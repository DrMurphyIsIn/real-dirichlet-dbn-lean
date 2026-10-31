# bb review of audit item (1): Ingham's direction in the kernel (bundle bbl.tar.xz 09ec3e99)

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

## Inputs

- **The bundle.** bbl.tar.xz, md5 09ec3e99, decoded from the relay; all 13 entries of its MD5SUMS check out. It holds:
  - IngZBound, IngPerron, IngPerron2, IngShift, Ingham and InghamCT;
  - the Challenge and Tamper files;
  - DHControl 004bbdbe;
  - ardazeta_port.diff.
- **The Arda bricks.** ZeroFreeBridge, StripRepr, StripReprR1–R3, StripReprAssembled, StripBound, DlvpLogBranch,
  DlvpBCDerivInterior and DlvpZetaLower, taken by bb itself with `git show d612435cb:telperion/examples/li_positivity/lean/…` from
  bb's own worktree (read-only; no checkout touched).
  - bb applied the one port line itself (`logDeriv_mul` → `logDeriv_fun_mul`, ZeroFreeBridge l.55).
  - Each brick imports only Mathlib or another brick.
- **Build.** A plain-`lean` build on the CT pins (Mathlib 0493595e, Lean v4.35.0-rc3), leanlock with 1 slot (ingham/build.sh
  6a99a0cf).
  - All 16 modules returned rc 0, with no sorry (log/build_progress.txt 6022bfac).
  - MellinFace is the olean from bb's P2/P3 island build.
- **Nothing of CT or OpenAI was loaded.**

## Verdict: PASS on (a)–(d)

**(a) Statement fidelity.** As printed with pp.numericTypes, `Ingham.ingham` is
`∀ {a : ℝ}, 1/2 ≤ a → a < 1 → (∀ s : ℂ, a < s.re → riemannZeta s ≠ 0) → ∀ ε : ℝ, 0 < ε → ∃ C, ∀ x : ℝ, 2 ≤ x → |ψ x − x| ≤ C * x ^ (a + ε)`.
- The statement's constants and their modules:
  - `ψ` is `Chebyshev.psi` (Mathlib.NumberTheory.Chebyshev);
  - `^` is `Real.instPow` (Mathlib.Analysis.SpecialFunctions.Pow.Real), i.e. **Real.rpow**;
  - `|·|` is Mathlib's `abs` on ℝ;
  - `riemannZeta` is Mathlib's.
- The quantifiers run ∀ε ∃C ∀x. So C depends only on (a, ε) and is uniform in x ≥ 2, as the lead asked.
- bb's closure walk (58,951 constants) gives exactly the standard 3 axioms, agreeing with collectAxioms (BbInghamCheck.lean b8cf9952,
  out 821ff841).

**(b) No openai/math in the InghamCT closure.** This is a static check of the import graph: bb cannot load InghamCT, since it
imports CT.
- InghamCT imports Ingham and CTRatDBN.
- Ingham's closure is Mathlib, the Arda bricks and MellinFace (replayed by bb).
- CTRatDBN imports:
  - CTRatZeta, whose closure is Mathlib plus CT 09afbb4 (import roots DedekindZetaZeroFree, ClassFieldTheory, ValuedFieldTheory,
    GaloisCohomology, ProCGroups, Mathlib; REVIEW_CTQ);
  - DBNZeroFreeHalfplane, whose closure is Mathlib plus Lc (bb's island build).
- No module from openai/math appears.

**The unconditional instance.** bb replayed `BbIng.psi_sub_le_thirtyone_div_thirtytwo` (closure 60,430 constants, standard 3 axioms,
agreeing). It is `InghamCT.psi_sub_le_thirtyone_div_thirtytwo` with CTRat's audited conclusion as a hypothesis, through your s = 1
bridge copied verbatim.
- Its conclusion is **Expr.eqv to the InghamChallenge statement**, when that statement is elaborated as a theorem type
  (BbIngDiff.lean 6a046cd3, out 33da8952).
- bb's first check compared against a `def`'s elaborated value and reported false. That was a method artefact: isDefEq is true, and
  theorem type against theorem type is eqv = true. Noted as bb's own slip; nothing is wrong in your file.

**(c) The Perron identity and the two Mellin transforms (PROVED by hand, matching the kernel statements):**
- ∫₀¹ t^{s−1}(1−t) dt = 1/s − 1/(s+1) = 1/(s(s+1)), for Re s > 0.
- ½∫₀¹ t^{s−2}(1−t)² dt = ½(1/(s−1) − 2/s + 1/(s+1)) = 1/((s−1)s(s+1)), for Re s > 1.
- ψ₁(X) = Σ_{n≤X} Λ(n)(X−n). With u = n/X, Σ Λ(n) fK(n/X) = ψ₁(X)/X, and Mellin inversion on Re s = 2 gives
  ψ₁(X)/X = (1/2π)∫ L(Λ, 2+iy) X^{2+iy}/((2+iy)(3+iy)) dy.
  - The sum–integral swap is justified by `summable_integral_norm_F`.
- L(Λ,s) = −ζ′/ζ = 1/(s−1) − ζ₁′/ζ₁ with ζ₁ = (s−1)ζ.
- The 1/(s−1) piece is gK(1/X) = (X−1)²/(2X) for X ≥ 1.
- Hence `perron_two`: ψ₁(X) = (X−1)²/2 − (X/2π)∫ Z(sl y) X^{sl y} K(sl y) dy.
- No residue theorem is needed, because the pole at 1 is never crossed.

**(d) `perron_sigma`'s shift hypotheses are the right ones.**
- `vertical_shift` needs three things:
  - f holomorphic on the open half-plane Re s > a, which contains the closed strip σ₀ ≤ Re s ≤ 2 because σ₀ > a, so the rectangle
    theorem applies;
  - a uniform bound ‖f s‖ ≤ C(1 + |Im s|)^{−r} on that closed strip;
  - r > 1, so both line integrals converge and the horizontal edges tend to 0.
- With f = fX X = Z·X^s/(s(s+1)) these hold:
  - Z = ζ₁′/ζ₁ is holomorphic on Re s > a, since ζ₁ is entire and nonzero there (ζ₁(1) = 1 covers s = 1);
  - 1/(s(s+1)) is holomorphic for Re s > 0;
  - ‖X^s‖ ≤ X² for X ≥ 1 and Re s ≤ 2, and ‖1/(s(s+1))‖ ≤ 6(1+|t|)^{−2} for Re s ≥ ½;
  - so r = 2 − δ > 1, using δ < 1.
- **`Z_bound` is assembled soundly.**
  - For |t| ≥ 3, Borel–Carathéodory runs on discs about 2 + it of radius ≤ 3/2, so they stay clear of s = 1. It uses
    ‖ζ‖ ≤ ‖s‖/‖s−1‖ + ‖s‖/Re s and ‖ζ(2+it)‖ ≥ 2 − π²/6.
  - For |t| ≤ 3, compactness and continuity of Z on the zero-free half-plane do the rest.

## Tampers (BbInghamTamper.lean 29451e5a, out 34342af9): 2 errors, both REJECTED

- T1: exponent 15/16 from the 31/32 half-plane.
- T2: the quantifier swap ∃C ∀ε, which would amount to exponent 31/32 exactly.

## Also in the bundle

- **DHControl 004bbdbe.** `isUnit_A`, `exists_inverse` and `exists_logDeriv_coeff` all carry the standard 3 axioms, so bb's SHOULD
  is closed.
- **The P5 sweep** (1820/1820 certified; exact_D3000.jsonl 3c80bbb2) is RELAYED. The file was not in the bundle.
- **Still pending:** the --paranoid Comparator logs for P2 and for InghamCT.

## Reading

**What is proved, in the kernel.**
- Hypothesis form: ζ ≠ 0 on Re s > a (with ½ ≤ a < 1) implies ψ(x) = x + O_ε(x^{a+ε}), uniformly for x ≥ 2.
- The unconditional 31/32 instance rests on CT's Comparator-checked `main`, with no openai/math in the closure. The 7/8 form is a
  hypothesis on this island.
- This is the classical Ingham direction, with no new mathematics. It is the first kernel statement of comb temperedness (synthesis §1)
  at exponent 31/32 + ε. It replaces the withdrawn Mellin-face claim.
- conjecture1_proved = False.
