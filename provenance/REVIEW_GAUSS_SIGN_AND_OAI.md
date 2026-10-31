# bb: Gauss's sign theorem (S1–S3), and its OAI composition. Λ_χ ≤ 9/32 for every real primitive χ ≠ 1, in one environment

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

- **Authorisation.** The user approved the OAI-environment work directly in bb's session (AskUserQuestion: "Yes, run it all here").
- **Scope.** Part A is the audit of the Gauss sign bundles at our CT pin. Part B is the composition you asked for, in OpenAI's
  environment. Part C lists the files.

## Verdict

- **Gauss's sign theorem (bbgauss12 ff01f9ed + bbgauss3 09580c10): PASS** at Lean v4.35.0-rc3 / Mathlib 0493595e.
  - It uses only Mathlib, with axioms [propext, Classical.choice, Quot.sound].
  - It is now proved in Lean that `DirichletCharacter.rootNumber χ = 1` for every real primitive χ, in Mathlib's own
    normalisation.
- **OAI composition: PASS.** `bb_real_primitive_real_zeros_oai` has no hypotheses beyond "χ is real, primitive and ≠ 1".
  - It compiles in OpenAI's environment (v4.34.1 / d13f23b, openai/math @ adc7f124) with our chain UNCHANGED, and has the
    standard 3 axioms.
  - All five checkers accept it, and all five reject the skipKernelTC control (B.6).

## Part A: Gauss's sign theorem at the CT pin

### A.1 Inputs

| Stage | File | md5 | Lines |
|---|---|---|---|
| S1 quadratic Gauss sum | GaussQuad.lean | 51b4e494 | 422 |
| S2 prime conductor | GaussPrime.lean | 6fb94967 | 174 |
| S3a CRT | GaussCRT.lean | dce09dba | 205 |
| S3b odd prime powers | GaussPow.lean | 16bd30ef | 129 |
| S3b 2-part | GaussTwo.lean | 3800b2cc | 192 |
| S3c induction | GaussSign.lean | 03883647 | 297 |

- **Bundles.** bbgauss12.tar.xz is ff01f9ed (S1+S2). bbgauss3.tar.xz is 09580c10 (S3), the one you cite.
- **Totals.** The six files are 1,419 lines. Their md5s are identical in the decoded bundles, in the rc3 build tree (gen/out) and
  in the OAI port (B.1).

### A.2 Build and static scan

- **Build.** Plain `lean` through leanlock at rc3. All six files give rc 0, with warnings only:
  - GaussCRT: one unused `ring`;
  - GaussPrime: deprecations (`Set.toFinset_setOf`, `if_pos`, `if_neg`), one unused variable and one unused simp argument.
- **Static scan.** No hits in the six files for any of these: `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`,
  `extern`, `unsafe`, `opaque`, `set_option`, `macro`, `elab`, `run_cmd`, `#eval`, `debug.skipKernelTC`. The one textual hit,
  "admit", sits in a doc comment ("admit no real primitive character").
- **Imports.** Only Mathlib plus the audited chain: GenThetaFE → GaussQuad → GaussPrime → GaussCRT → GaussPow → GaussTwo
  (with GenChi4) → GaussSign.

### A.3 Headline statements

`#check`, from BbGauss3Check.out 94180a80 and BbGaussCheck.out e01ba12f:

```
DBN.Gen.gaussG_eq : ∀ (N : ℕ) [NeZero N],
  DBN.Gen.gaussG N = (1 + I) * (1 + (-I) ^ N) / 2 * ↑√↑N
    -- gaussG N = Σ_{j : Fin N} exp(2πi j²/N)
DBN.Gen.rootNumber_eq_one_of_prime : ∀ {p} [Fact p.Prime], p ≠ 2 → ∀ χ : DirichletCharacter ℂ p,
  χ ≠ 1 → (∀ n, (χ n).im = 0) → χ.rootNumber = 1
DBN.Gen.rootNumber_eq_one_of_real_primitive : ∀ {N} [NeZero N] (χ : DirichletCharacter ℂ N),
  χ.IsPrimitive → (∀ n, (χ n).im = 0) → χ.rootNumber = 1
DBN.Gen.real_primitive_real_zeros : ∀ {N} [NeZero N] (χ : DirichletCharacter ℂ N),
  χ.IsPrimitive → χ ≠ 1 → (∀ n, (χ n).im = 0) →
  (∀ s, 7/8 < s.re → DirichletCharacter.LFunction χ s ≠ 0) →
  ∀ t, 9/32 ≤ t → ∀ z, DBN.Gen.Hchi χ t z = 0 → z.im = 0
```

- `rootNumber` is Mathlib's `DirichletCharacter.rootNumber`, from Mathlib.NumberTheory.LSeries.DirichletContinuation. It is not
  a local definition.
- **The statement of the headline sign theorem uses only Mathlib and Init constants** (bb's walk lists each constant with its
  module).
- `real_primitive_real_zeros` adds exactly one constant from our chain, `DBN.Gen.Hchi` (from GenThetaFE: 32 Mathlib, 14 Init,
  1 GenThetaFE). Its meaning is covered in B.7.

### A.4 Proof route

This is read from the sources; the kernel checks the details.

- **S1.** The closed form of the quadratic Gauss sum, G(N) = (1+i)(1+(−i)^N)/2 · √N, for every N ≥ 1.
- **S2.** For an odd prime p, a real χ ≠ 1 is the Legendre character, and it is primitive. Its Mathlib Gauss sum equals G(p),
  which gives ε = 1.
- **S3c.** Strong induction on N. Each step peels one odd prime p ∥ N by CRT, χ = χ_p · χ′, and carries the Kronecker invariant
  K(χ): χ(ℓ) = (χ(−1)N / ℓ) for odd primes ℓ ∤ N.
  - The cross twist χ_p(N/p) χ′(p) then reduces to (χ′(−1)/p) without further reciprocity. Quadratic reciprocity enters only
    in proving K for the Legendre factor.
  - **Base cases.** Levels 1, 4 and 8 (1, χ₋₄, χ₈, χ₋₈). Levels 2, 2^e for e ≥ 4, and any level with p² ∣ N for odd p have no real
    primitive character.

### A.5 Axioms

bb's term-level closure walk agrees with `collectAxioms` for each walked theorem:

| Theorem | Axioms | Closure constants (bb walk) |
|---|---|---|
| gaussG_eq | standard 3 | 52,770 |
| real_char_eq_quadraticChar, gaussSum_eq_gaussG, isPrimitive_of_prime | standard 3 | (not walked; collectAxioms) |
| rootNumber_eq_one_of_prime | standard 3 | 55,001 |
| prime_real_zeros | standard 3 | (collectAxioms) |
| rootNumber_eq_one_of_real_primitive | standard 3 | 62,454 |
| real_primitive_real_zeros | standard 3 | 70,899 |

### A.6 Tampers

- **BbGaussTamper.out 3d9d6a15.** Replacing (1+i) with (1−i) in S1 is REJECTED by a type mismatch. So is
  `rootNumber_eq_one_of_prime` with = −1. Both are genuine rejections.
- **BbGauss3Tamper.out acb9a69f.**
  - T1: `rootNumber_eq_one_of_real_primitive` with = −1 is REJECTED by a type mismatch (genuine).
  - T2: dropping `hprim` fails at `assumption` with goal `χ.IsPrimitive`. This is a proof-reach control: the hypothesis is
    load-bearing.

### A.7 Independent numerics

bb wrote its own code (its own Kronecker symbol), in Mathlib's normalisation ε = gaussSum(χ, stdAddChar) / i^a / N^{1/2}, using
mpmath:

| Stage | Range | Max error | Failures |
|---|---|---|---|
| S1 | G(N) vs closed form, N = 1..200 | 6.6e-38 | none |
| S2 | ε = 1 for odd primes p < 500 | 4.2e-41 | none |
| S3 | ε = 1 for χ_D, every fundamental discriminant 0 < \|D\| ≤ 2000 (both signs, 1,218 discriminants) | 4.3e-31 | none |

Files: bb_gauss_numeric.py 87fdbf9a (out 5ef0d24b) covers S1 and S2; bb_gauss3_numeric.py 1de99c29 (out 41b89bc3) covers S3.

## Part B: the composition in OpenAI's environment

### B.1 Environment and port diff

- **Environment.** Lean v4.34.1 with Mathlib d13f23b. It holds OpenAI's built openai/math @ adc7f124 (~/oai-replay, from the
  10-07 replay), plus our chain built from source with plain `lean` through leanlock (build.sh b0edbe53).
- **The port diff is EMPTY for all 26 modules.**
  - The 7 island files are afd94c7 plus the 2 port lines already audited.
  - The 13 Gen files are at the audited md5s (REPORT_OAI_PORT.md 2010d4f8).
  - The **6 Gauss files are byte-identical to A.1**: `diff` of src/ against orig/ is empty, and the md5s match the bundle and the
    rc3 tree.
- **Build** (log/progress.txt): all modules give rc 0.
  - GaussQuad 70 s, GaussPrime 4 s, GaussCRT 82 s, GaussPow 4 s, GaussTwo 4 s, GaussSign 4 s.

### B.2 The statement (BbOaiRealPrim.lean 4c569252)

```
import GaussSign
import OAI.NumberTheory.DirichletL.Nonvanishing

theorem bb_real_primitive_real_zeros_oai :
    ∀ {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N), χ.IsPrimitive → χ ≠ 1 → (∀ n : ℕ, (χ n).im = 0) →
    ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi χ t z = 0 → z.im = 0 :=
  fun χ hprim hχ1 hreal ↦ DBN.Gen.real_primitive_real_zeros χ hprim hχ1 hreal (fun _ hs ↦
    OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re χ hs (fun h ↦ hχ1 h.1))
```

- This is exactly the statement you asked for.
- The 7/8 hypothesis is discharged by OpenAI's theorem. Its side condition (χ is not the trivial character) comes from `hχ1`.

### B.3 Statement identity and constants

- **The `pp.all` text (4,017 characters) is byte-identical** with OpenAI in the environment (BbOaiRealPrimCheck.out df0f7fa4) and
  without it (BbOaiRealPrimRef.out 6ec3ef7a; Ref imports only the Gen chain + Gauss).
- **The statement has 43 constants:** 29 from Mathlib, 13 from Init, and 1 from GenThetaFE (`DBN.Gen.Hchi`). None comes from
  `OAI.*`.

### B.4 Axioms

- `bb_real_primitive_real_zeros_oai` and `DBN.Gen.rootNumber_eq_one_of_real_primitive` each have [propext, Classical.choice,
  Quot.sound].
- **bb's closure walk over 126,654 constants agrees with `collectAxioms`.**

### B.5 Tamper (BbOaiRealPrimTamper.lean dc3fa3e1, out 7804cd81): 2 errors

- **7/8 → 3/4:** "Application type mismatch … hs has type 3 / 4 < x✝.re but is expected to have type 7 / 8 < x✝.re in
  … LFunction_ne_zero_of_seven_eighths_lt_re χ hs". The rejection happens at OpenAI's theorem, so it is genuine.
- **Heat time 9/32 → 1/4:** the type mismatch is a proof-reach control.

### B.6 Five-checker replay (kernels_realprim.sh 8f7ce056)

- **Export.** Made with v4.34.1 `lean4export` 3.1.0 (~/e9-tools), with Quot / propext / Classical.choice added explicitly:
  - composition realprim.ndjson: 1,730,925,548 B, md5 ae0c51bd;
  - skipKernelTC control ctrl.ndjson (BbNeg.bogus : 4 = 5): 171,761,220 B, bf973608.
- **Checkers.** The ones bundled with Lean v4.35.0-rc3 (same export format, 3.1.0).
- **Guards.** An empty or failed export means ABORT. Any acceptance of the control means INVALID.

| Checker | composition (realprim.ndjson ae0c51bd) | control (BbNeg.bogus : 4 = 5) |
|---|---|---|
| leanchecker-paranoid | rc 0 (322 s) | rc 1, REJECT |
| nanoda | rc 0 (57 s) | rc 101, REJECT (panic: `assertion failed: self.def_eq(u, v)`) |
| con-leche | rc 0, "accepted 124633 declarations (--verified)" | rc 1, "invalid: type mismatch in theorem BbNeg.bogus" |
| con-ron | rc 0, "accepted 124633 declarations (--verified)" | rc 1, "rejected: type mismatch in declaration [at thm BbNeg.bogus …]" |
| leanchecker | rc 0 (270 s) | rc 1, REJECT |

- **Result: 5/5 accept the composition, and 5/5 genuinely reject the control.** The run is valid: no ABORT and no INVALID line
  (log/kernels_realprim_progress.txt ends DONE).
- The checkers accept 124,633 declarations. That is 238 more than the χ₋₄ composition (124,395) and 145 more than the
  prime-conductor one (124,488).

- **lean4lean is N/A across versions.** It crashes on v4.34.1 exports before reaching any target ("unknown constant
  'Decidable.intro'"), as reported in REPORT_OAI_PORT.

### B.7 What `Hchi χ` means, for general χ

- `Hchi χ t z = ∫₀^∞ e^{tu²} Φ_χ(u) cos(zu) du`, with Φ_χ(u) = e^{(1+2k)u} θ_χ(e^{4u}) and k = parity (GenThetaFE).
- **The link to the L-function is `DBN.Gen.bridge`** (GenBridge, audited PASS in REVIEW_D2b_BRIDGE).
  - At t = 0, the heat-flow kernel equals (1/8) · N^{(s+k)/2} · `completedLFunction χ s`, with s = ½ + iz/2, for every z.
  - It needs evenness of Φ, which `PhiC_even_of_rootNumber` derives from ε = 1. That ε = 1 is what Part A now supplies.
- This bridge is inside the proof of `real_primitive_real_zeros`, so it is in the environment of B.2.
- **In-environment re-check.** An instance in `Hchi` form was compiled in the OAI environment only for χ₋₄
  (BbOaiBridge.lean 9be8fdf9). bb did not write a separate `Hchi`-form bridge statement for general χ here.

### B.8 Provenance

This is unchanged from REPORT_OAI_PORT (b).
- `diff -rq ~/oai-replay/OAI ~/oai-math/lean/OAI` is empty. That covers 121,734 files against bb's clone, whose HEAD is
  adc7f1241b42….
- The lakefile, manifest, toolchain and patches/ are identical in both.
- Nonvanishing.lean is ea8efdb1. It was re-checked just now, and it re-elaborates from source with rc 0.
- **Nothing under ~/oai-replay has an mtime newer than REPORT_OAI_PORT.md (15:04).** So the environment used here is the one
  whose provenance was checked.

## Label

**"Λ_χ ≤ 9/32 for every real primitive Dirichlet character χ ≠ 1: PROVED in one environment (OpenAI's Dirichlet 7/8 @ adc7f124 +
our unchanged chain incl. Gauss's sign theorem, v4.34.1/d13f23b), axioms standard 3, replayed by five independent checkers
(leanchecker, leanchecker-paranoid, nanoda, con-leche, con-ron; lean4lean N/A across versions); NOT a sandboxed Comparator run."**

**Caveats.**
- OpenAI's manuscript is unrefereed. The kernel-level trust in their part rests on the 10-07 replay plus these checkers.
- The run was unsandboxed on macOS. It is not Comparator.
- The rc3 audit (Part A) and the v4.34.1 build (Part B) are separate builds of byte-identical sources, and both pass.
- "Real primitive χ ≠ 1" is, classically, the Kronecker characters χ_D of fundamental discriminants. The theorem quantifies over
  Mathlib's `IsPrimitive` directly, so it does not rely on that correspondence.
- conjecture1_proved = False. RH is not claimed.

## Part C: files

- **Part A** (~/e9-research/review_cn1/p1p6/gen):
  - out/BbGaussCheck.lean 655f0d76 → log/BbGaussCheck.out e01ba12f
  - out/BbGaussTamper.lean 71f455cd → log/BbGaussTamper.out 3d9d6a15
  - out/BbGauss3Check.lean 7465025b → log/BbGauss3Check.out 94180a80
  - out/BbGauss3Tamper.lean 25d18562 → log/BbGauss3Tamper.out acb9a69f
- **Numerics:**
  - gauss12/bb_gauss_numeric.py 87fdbf9a → out 5ef0d24b
  - gauss3/bb_gauss3_numeric.py 1de99c29 → out 41b89bc3
- **Part B** (~/e9-research/review_cn1/p1p6/oaiport):
  - src/BbOaiRealPrim.lean 4c569252
  - src/BbOaiRealPrimCheck.lean a4a6d612 → log/BbOaiRealPrimCheck.out df0f7fa4
  - src/BbOaiRealPrimRef.lean 38ade31b → log/BbOaiRealPrimRef.out 6ec3ef7a
  - src/BbOaiRealPrimTamper.lean dc3fa3e1 → log/BbOaiRealPrimTamper.out 7804cd81
  - kernels_realprim.sh 8f7ce056 → log/kernels_realprim_progress.txt cf9b447e
  - build.sh b0edbe53; log/progress.txt 3978e272
- **Also in this round** (5 checkers PASS, control 5/5 reject): bb_prime_real_zeros_oai, BbOaiPrime.lean f7efdf7e.
  - Its export prime.ndjson is 4c9ae783.
  - log/kernels_prime_progress.txt is ffc00e93.
- Copies of the Part A and Part B check, ref and tamper files and their outputs are in ~/rh-team/contrarian/synthesis_1029/bb/gauss_oai/.
