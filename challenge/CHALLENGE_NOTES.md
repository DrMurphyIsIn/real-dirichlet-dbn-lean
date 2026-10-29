# Comparator challenge for Λ_χ ≤ 9/32 (all real primitive χ ≠ 1): notes by the challenge author

*AI review by bb, NOT an operator read-back.* Thu 2026-10-29.

This follows COMPARATOR_RUN_SPEC.md (3fc6b5d6), where bb is the independent challenge author and later the verifier. Nothing
here is public.

## Files (this folder)

| File | md5 | Role |
|---|---|---|
| ChallengeDefs.lean | 67e538bce62d039a63d0cabcffd2797b | trusted definitions (6 non-Mathlib constants), imports Mathlib only |
| Challenge.lean | 73c1bf9423bfc17c9f2b1ed1496a3f84 | the challenge: `bb_real_primitive_meaning_oai` verbatim, `:= sorry` |
| ChallengeTamperA.lean | d6ef5198ce5c64810477a0ffe8e26f6f | tamper A, 9/32 → 1/4: MUST be rejected |
| ChallengeTamperB.lean | 311631378a462aaa7199bce74ad42e6c | tamper B, bridge 1/8 → 1/4: MUST be rejected |
| config.json | d563faf75a71cdf711852a4515200bad | Challenge vs solution BbOaiMeaning; 3 axioms; enable_nanoda |
| config_tamperA.json | 1c2534bbdba4e1171b5183d6fdc30a2f | as config.json, challenge_module ChallengeTamperA |
| config_tamperB.json | f34c06afd0e32d588fda31c477406b33 | as config.json, challenge_module ChallengeTamperB |

## The trusted base

- **Mathlib** at d13f23b (OpenAI's pin), plus **ChallengeDefs.lean**.
- **ChallengeDefs introduces exactly six non-Mathlib constants:**
  - `DBN.Gen.thetaC`: θ_c(x) = Σ_{n≥0} c(n)·n^k·e^{−πn²x/q}
  - `DBN.Gen.PhiC`: Φ_c(u) = e^{(1+2k)u}·θ_c(e^{4u})
  - `DBN.Gen.PhiC._proof_1`, `DBN.Gen.PhiC._proof_2`: auxiliary proof terms that Lean generates from `PhiC`'s body
  - `DBN.Gen.parityK`: k(χ) = 0 if χ is even, 1 if odd
  - `DBN.Gen.Hchi`: Hchi χ t z = ∫_0^∞ e^{tu²}·Φ_χ(u)·cos(zu) du, with Φ_χ = Φ_c for c(n) = Re χ(n), k = k(χ), q = N
- **Completeness.** That list was produced mechanically, not by hand. bb walked the non-Mathlib closure of
  `Hchi` and `parityK` in the solution environment (oaiport/src/BbDefsClosure.lean 177ad2a3, out 059ff867), and of the
  challenge theorem in the challenge environment (pre-flight, below).
- **Provenance.** The text is copied verbatim, with the same `open`s and `variable`s, from the audited sources:
  - GenTheta.lean 3dbf6dec, lines 16–28;
  - GenThetaFE.lean 8aeec9b0, lines 19–23, 29 and 264–273.

## How Comparator matches the definitions (read from its source, comparator v4.34.0)

- **The comparison.** `Comparator/Compare.lean` (lines 37–59, 67–108) starts from the constants used in the challenge
  theorem's type. For every constant reached through types and values, it requires the challenge and solution `ConstantInfo`
  to be EQUAL (derived BEq: name, universe parameters, type, value, reducibility hints, safety, `all`).
  - The theorem target itself is compared on name, universe parameters and type only.
- **Consequences:**
  - **The solution must NOT import ChallengeDefs.** Its own GenTheta / GenThetaFE define the same six constants. Importing both
    would be a duplicate-declaration error, and it is unnecessary: Comparator checks identity across the two environments,
    and the module a constant lives in does not matter.
  - The solution module is the unchanged BbOaiMeaning (23ea25e9), over the audited chain.
  - The challenge environment is only Mathlib + ChallengeDefs + Challenge, with no chain and no OpenAI code.

## Design question: could the trusted base be smaller?

**Decision: keep the spec's verbatim conjunction, with ChallengeDefs as above.** The reasons follow.

1. **It is already small.** It is four short explicit formulas, about ten lines: the textbook theta series, the textbook Φ, the
   parity, and the textbook heat integral. The two `_proof_n` terms are Lean bookkeeping, and Comparator compares them too.

2. **The bridge conjunct (b) cross-validates most of it.** A reader needs to check only two things in ChallengeDefs:
   - (i) `Hchi χ t z` has the shape ∫_0^∞ e^{tu²}·F(u)·cos(zu) du, for a single F that depends on neither t nor z;
   - (ii) what `parityK` means.

   Conjunct (b) states ∫_0^∞ F(u) cos(zu) du = Λ(½ + iz/2, χ)/8 for all z ∈ ℂ, and that pins F down:
   - At z = iy with y below −1, s = ½ − y/2 > 1, where Λ ≠ 0. The identity therefore forces F·cosh(yu) to be integrable (a
     non-integrable integrand would make the Bochner integral 0).
   - So F has every exponential moment, and the cosine transform on real z then determines F almost everywhere (Fourier
     uniqueness).
   - Hence Hchi χ t is the de Bruijn–Newman flow of Λ(·, χ) whatever θ_c and Φ_c say internally.
   - This argument is outside Lean, but it is standard. It is also only needed as a sanity check, because the explicit
     formulas are there to read anyway.

3. **Defining Hchi through an inverse Fourier transform of `completedLFunction` (the lead's suggestion) is declined.**
   - It would need new Lean proofs:
     - Fourier inversion for Φ_χ;
     - integrability of Λ(½ + ix/2, χ) along the line, which needs growth bounds for L(s, χ) on vertical lines that Mathlib
       does not have.
   - The new definition would itself be trusted. It is an integral of `completedLFunction` with Bochner junk-value semantics,
     which makes it less transparent than four explicit formulas.
   - It would also break the "unchanged audited chain" property.

4. **A Mathlib-only existential variant was considered and declined as the primary target.**
   - The variant: ∀ real primitive χ ≠ 1, ∃ Φ : ℝ → ℝ, (∀ z, ∫_0^∞ Φ(u) cos(zu) du = (1/8)·N^{(s+k)/2}·completedLFunction χ s)
     ∧ (∀ t ≥ 9/32, every zero of ∫_0^∞ e^{tu²} Φ(u) cos(zu) du is real).
   - It has ZERO trusted definitions, and its solution is a few lines.
   - But its meaning depends entirely on the out-of-Lean uniqueness argument in 2. An "∃" statement is a known vacuity hazard
     for outside readers, so it should not be the headline.
   - It could be added later as a supplementary challenge if the user wants a Mathlib-only statement.

## Tampers (each MUST be rejected)

| Challenge | Change | Expected Comparator outcome |
|---|---|---|
| ChallengeTamperA | conjunct (a): 9 / 32 ≤ t → 1 / 4 ≤ t (one line) | "Challenge and solution theorem statement do not match: 'bb_real_primitive_meaning_oai'" |
| ChallengeTamperB | conjunct (b): (1 / 8) → (1 / 4) (one line) | same |

The configs point at the same solution and theorem name. Only `challenge_module` differs.

## Local pre-flight (unsandboxed, macOS, plain `lean`, no lake; NOT a Comparator run)

Run as chal/preflight.sh 491b44ab, with progress in log/preflight_progress.txt. The challenge side was built into its own build
directory against OpenAI's Mathlib oleans. The solution side is the existing OAI-env build.

- **Builds.** ChallengeDefs, Challenge, ChallengeTamperA and ChallengeTamperB all give rc 0. The only warnings are the expected
  `declaration uses 'sorry'`.
- **Challenge-side closure.** It is exactly the six ChallengeDefs constants plus the theorem (log/BbPreflightChalClosure.out
  5afa6922).
- **Exact `ConstantInfo` dumps.** These compare type, value, hints, safety and `all`, via `repr`, which includes binder names
  (log/BbPreflight{Chal,TamperA,TamperB,Sol}.out; compared by preflight_compare.py 0b0a1e82, out 7a0c5286).
  - **All six trusted constants are BYTE-IDENTICAL** between the challenge and solution environments: Hchi f6e23216,
    PhiC dc3be88c, PhiC._proof_1 d3da97ce, PhiC._proof_2 f3cd0ce3, thetaC 12256bff, parityK 721da9ed (md5 of each dump).
  - **Challenge theorem type.** It differs from the solution's only in the hygienic names of the two anonymous `[NeZero N]`
    binders, which embed the module name (`inst.«_@».Challenge…` vs `inst.«_@».BbOaiMeaning…`). After normalising those,
    the two are identical (be924279).
  - This does not affect Comparator. Its derived `ConstantInfo` BEq uses `BEq Expr := Expr.eqv`, which is
    alpha-equivalence: binder names and annotations are ignored (Lean v4.34.1 src/lean/Lean/Expr.lean lines 805–812).
  - bb confirmed this with a direct test (chal/src/BbBeqTest.lean): renamed binder → `true`, changed binder info → `true`,
    changed type → `false`.
- **Tampers differ in substance**, after normalisation:
  - A changes the literal 9 (in 9/32) and its numeral instance;
  - B changes 8 → 4 and the `instOfNatAtLeastTwo` witness 7 → 3.
- **What this pre-flight does not do.** It is not Comparator. There is no sandbox, no lake, no export comparison and no kernel
  replay. It shows that the challenge SHOULD match, and that the tampers SHOULD be rejected at the statement check.

## Notes for the runner (contrarian)

- **Pins.** Lean v4.34.1, Mathlib d13f23b, openai/math @ adc7f124. Use comparator v4.34.0 with `lean-toolchain` bumped to
  v4.34.1, as for SiegelZeros.
- **Lake.** The project needs `lean_lib` entries for Challenge, ChallengeDefs, ChallengeTamperA, ChallengeTamperB, the solution
  BbOaiMeaning and the chain modules (island, Gen, Gauss, GaussBridge, BbOaiRealPrim).
  - Build the Challenge side from these exact files, checking the md5s first.
  - Don't let anything in the solution import ChallengeDefs.
- **Solution md5s** (from bb's records):
  - BbOaiMeaning 23ea25e9, BbOaiRealPrim 4c569252, GaussBridge 4f746054;
  - the six Gauss files and the 13 Gen + 7 island files as listed in REVIEW_GAUSS_SIGN_AND_OAI §B.1 / REPORT_OAI_PORT.
- **Logs.** Please keep the FULL Comparator logs, including the statement-match line, the axiom check and every kernel's
  verdict. Also assert that the export is non-empty and report its declaration count. bb's five-checker replay of
  `bb_real_primitive_meaning_oai` accepted 124,635 declarations.
