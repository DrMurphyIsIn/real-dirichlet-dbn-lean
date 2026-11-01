# Λ_χ ≤ 9/32 for every real primitive Dirichlet character, kernel-checked

> **Status: v2.0.0, released TODO_DATE.** Version 1's kernel-checked theorem (Λ_χ ≤ 9/32, below) is unchanged: five
> checkers from three implementation lineages replayed it locally, and a sandboxed Comparator run against a separately
> written challenge (`challenge/`) accepted it (`logs/comparator_sandboxed/`). Version 2 adds three further bounds on the
> same constant in weaker trust classes (see "Version 2" below and §7 of the paper). The paper is in `paper/`. DOI
> [10.5281/zenodo.TODO_V2](https://doi.org/10.5281/zenodo.TODO_V2) (v2.0.0); v1.0.0 is
> [10.5281/zenodo.23840082](https://doi.org/10.5281/zenodo.23840082); all versions:
> [10.5281/zenodo.23840081](https://doi.org/10.5281/zenodo.23840081).

## The question

The de Bruijn–Newman constant began life as a question about the Riemann ξ function, but the construction works
for any L-function with a functional equation. Take the completed L-function, here Λ(s, χ) for a Dirichlet
character χ, and restrict it to the critical line. That gives an entire function of one variable whose zeros are
real exactly when the generalized Riemann hypothesis holds for L(s, χ). Write the function as a Fourier integral
of a rapidly decaying kernel Φ_χ, and let the kernel evolve under the backward heat equation: multiply Φ_χ(u) by
e^{tu²}. For every real t you get an entire function H_t^χ, and H_0^χ is the completed L-function in disguise.

De Bruijn proved in 1950 that this flow only ever pulls zeros onto the real axis. If the zeros of H_t^χ lie in
a horizontal strip |Im z| ≤ Δ, then all the zeros of H_{t'}^χ are real once t' ≥ t + Δ²/2. So there is a
threshold, the de Bruijn–Newman constant Λ_χ: the zeros of H_t^χ are all real when t ≥ Λ_χ, and not all real
when t < Λ_χ. GRH for L(s, χ) is the statement Λ_χ ≤ 0. Upper bounds on Λ_χ are measures of how close a family
of L-functions comes to GRH, and they are much easier than GRH itself, because any zero-free region of fixed
width gives one.

This is exactly the bound we get. Freire, González-Riquelme, Muñoz, Poblete and Salinas (FGMPS, arXiv:2610.27343,
Remarks 3.1 and 3.4) observed that if Λ(s, χ) has no zeros off the strip 1/8 ≤ Re s ≤ 7/8, then de Bruijn's
theorem gives Λ_χ ≤ (3/4)²/2 = 9/32. In 2026 OpenAI released a Lean proof that every Dirichlet L-function is
zero-free on Re s > 7/8. For a real character, χ̄ = χ and the functional equation reflects that
half-plane onto Re s < 1/8, and that is the strip.

On paper the composition is a paragraph. This repository makes it a theorem of the Lean kernel, for every real
primitive character at once, with no hypotheses left over.

## The theorem

```lean
theorem bb_real_primitive_meaning_oai :
    (∀ {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N), χ.IsPrimitive → χ ≠ 1 → (∀ n : ℕ, (χ n).im = 0) →
      ∀ t : ℝ, 9 / 32 ≤ t → ∀ z : ℂ, DBN.Gen.Hchi χ t z = 0 → z.im = 0) ∧
    (∀ {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N), χ.IsPrimitive → χ ≠ 1 → (∀ n : ℕ, (χ n).im = 0) → ∀ z : ℂ,
      DBN.Gen.Hchi χ 0 z = (1 / 8) * (N : ℂ) ^ ((1 / 2 + I * z / 2 + DBN.Gen.parityK χ) / 2) *
        DirichletCharacter.completedLFunction χ (1 / 2 + I * z / 2))
-- 'bb_real_primitive_meaning_oai' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Reading the statement, if you don't read Lean

The theorem has two halves. The binders are the same in both: N is the modulus, and χ is a Dirichlet character
mod N with values in ℂ (Mathlib's `DirichletCharacter ℂ N`). It is primitive (Mathlib's `IsPrimitive`), it is
not the trivial character, and it is real-valued (every value has imaginary part 0).

The **first half** says: for every t ≥ 9/32, every zero z of `Hchi χ t` is real. That is Λ_χ ≤ 9/32.

The **second half** says what `Hchi` is. With s = ½ + iz/2 and k = 0 or 1 the parity of χ (`parityK`),

  `Hchi χ 0 z = (1/8) · N^{(s+k)/2} · completedLFunction χ s`.

Mathlib's `completedLFunction χ s` is Γ_ℝ(s + k)·L(s, χ). It has no conductor factor, which is why Mathlib's
functional equation carries N^{s−1/2}. So the right-hand side is (1/8)·Λ(s, χ), where
Λ(s, χ) = (N/π)^{(s+k)/2} Γ((s+k)/2) L(s, χ) is the classical completed L-function. The factor N^{…} never
vanishes, so the zeros of `Hchi χ 0` are exactly the zeros of Λ(·, χ) on the line s = ½ + iz/2. The first half
is therefore a statement about the de Bruijn–Newman flow of Λ(s, χ), and the second half is the proof of that,
in the same environment.

`Hchi` is defined explicitly (`lean/gen/GenThetaFE.lean`, `lean/gen/GenTheta.lean`):

  `Hchi χ t z = ∫₀^∞ e^{tu²} Φ_χ(u) cos(zu) du`, with `Φ_χ(u) = e^{(1+2k)u} θ_χ(e^{4u})` and
  `θ_χ(x) = Σ_{n≥1} χ(n) n^k e^{−πn²x/N}`.

This is the same normalisation as 2610.27343, up to a constant factor: their H^L_t is 8·`Hchi χ t` for every t.
So the zero sets, and the constant Λ_χ, are the same. "Real primitive χ ≠ 1" is, classically, the Kronecker
characters χ_D of fundamental discriminants D. The theorem quantifies over Mathlib's `IsPrimitive` directly and
does not rely on that correspondence.

The first half uses 43 constants, the whole conjunction 59. Every one comes from Mathlib or Lean's core library except
`DBN.Gen.Hchi` (both halves) and `DBN.Gen.parityK` (second half). **None comes from
OpenAI's library.** The auditor checked this by listing each constant with its module (`logs/oai_env/`).
OpenAI's theorem is used in the proof, not in the statement.

## How the proof goes

The chain is 29 modules and about 6,500 lines. It is built in layers, and each layer was reviewed and replayed
on its own before the next one went on top.

1. **de Bruijn's theorem for a generic kernel** (`lean/gen/GenDefs` … `GenM1Parametric`, on seven modules of
   the earlier dbn island in `lean/island/`). The dbn island already had de Bruijn's theorem for Riemann's Φ, with
   Hadamard factorisation and Hurwitz's theorem in zero-free form. Here it is restated for any even, continuous,
   rapidly decaying kernel that is not identically zero, as `DBN.Gen.Kernel`. As a regression, the island's own
   theorem was re-derived verbatim from the generic library. One genuine change was needed. The island knew H₀ is not identically
   zero because Riemann's Φ is positive, so H₀(0) = ∫Φ > 0. The Dirichlet analogue, H₀^χ(0) ≠ 0, would be
   L(½, χ) ≠ 0, which is Chowla's conjecture. The generic library gets nonvanishing from Fourier injectivity
   instead (`GenFourier`).
2. **The theta kernel** (`GenScale`, `GenTheta`). Φ_χ is shown to be continuous, rapidly decaying and not
   identically zero. A rescaling turns a strip for H₀ into de Bruijn's hypothesis, so a zero strip
   (Im z)² ≤ Y gives real zeros for t ≥ Y/2.
3. **The Mellin bridge** (`GenMellin`, `GenMellin2`, `GenBridge`). On Re s > 1, the Mellin transform of θ_χ produces
   the Dirichlet series of χ, and the t = 0 integral equals (1/8)·N^{(s+k)/2}·`completedLFunction χ s` there.
   Both sides are entire, so the identity theorem extends this to every z. Primitivity is not needed for this
   step. Evenness of Φ_χ is, because ∫₀^∞ is half the full-line integral only for an even kernel.
4. **The strip** (`GenStrip`). A zero of `Hchi χ 0` is a zero of Λ(s, χ) at s = ½ + iz/2. The 7/8 half-plane,
   with Γ_ℝ ≠ 0, rules out Re s > 7/8. Mathlib's functional equation for primitive χ, with χ⁻¹ = χ for real χ,
   reflects that to rule out Re s < 1/8. So |Im z| ≤ 3/4, and t ≥ (3/4)²/2 = 9/32. Primitivity is used here
   (the functional equation), in the theta functional equation, and in Gauss's theorem.
5. **Evenness from the root number** (`GenThetaFE`). Classically, θ(1/x) = ε·x^{(1+2k)/2}·θ(x), with ε
   the root number, so Φ_χ(−u) = ε·Φ_χ(u). The Lean theorem `theta_fe` proves this functional equation when
   ε = 1, where ε is Mathlib's literal `rootNumber`. It is built from Mathlib's even and odd Hurwitz-kernel
   functional equations and its Gauss-sum shift for primitive characters. `PhiC_even_of_rootNumber` then gives
   evenness of Φ_χ. `GenChi4` runs the whole thing on χ₋₄ as a non-vacuity instance.
6. **Gauss's sign theorem** (`lean/gauss/GaussQuad` … `GaussSign`). This was the last open hypothesis: for every
   real primitive χ, `DirichletCharacter.rootNumber χ = 1`, in Mathlib's own normalisation. It is classical, but
   it is not in Mathlib. The proof has three stages.
   - S1 is the closed form of the quadratic Gauss sum, G(N) = (1+i)(1+(−i)^N)/2·√N.
   - S2 handles prime conductors: a real χ ≠ 1 mod an odd prime p is the Legendre symbol, and its Gauss sum is
     G(p).
   - S3 is strong induction on the conductor. Each step peels off one odd prime by CRT and carries a Kronecker
     invariant, so quadratic reciprocity is needed only for the Legendre factor. The base cases are levels 1, 4
     and 8.

   This layer is about 1,400 lines and uses only Mathlib.
7. **The composition** (`lean/main/BbOaiRealPrim`, `BbOaiMeaning`). In OpenAI's environment, OpenAI's theorem
   `OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re` discharges the 7/8 hypothesis, and its side
   condition (χ is not trivial) comes from χ ≠ 1. `GaussBridge` assembles the general-χ meaning link: it derives
   evenness from Gauss's sign theorem and then applies the Mellin bridge. The conjunction of the two is the
   theorem above.

Every module of the chain compiled **unchanged** in OpenAI's environment. All 27 chain files are byte-identical to the
versions audited at Lean v4.35.0-rc3; the island files differ from the island's release afd94c7 by two one-line proof
repairs (`lean/patches/`).

## What was checked, and by what

These are the components of the trust base:

- **Lean's kernel**, at Lean v4.34.1. `#print axioms` gives `[propext, Classical.choice, Quot.sound]` for both
  halves. The auditor also wrote an independent closure walk, which agrees with `collectAxioms` over all 126,656
  constants (`logs/oai_env/BbOaiMeaningCheck.out`).
- **Five checkers, from three implementation lineages** (Lean's kernel, twice; nanoda; the con-leche/con-ron pair). The
  environment containing the theorem was exported with lean4export (1.73 GB,
  124,635 declarations). The export was replayed by leanchecker, leanchecker-paranoid, nanoda, con-leche and
  con-ron, and all five accepted it.
  - In the same run, each checker was given a negative control. The control is a false theorem `4 = 5`, injected
    with `debug.skipKernelTC` so that Lean's elaborator never checked it. All five rejected it, so the run is
    valid (`logs/five_checker/`).
  - lean4lean could not be used: the available build crashes on v4.34.1 exports before reaching any declaration.
- **Statement checks.** The `pp.all` text of each statement is byte-identical with OpenAI's library in the
  environment and without it.
  - Tampered statements are rejected. Changing 1/8 to 1/4, or the parity shift k to 1 − k, fails at the type
    level.
  - Weakening OpenAI's 7/8 to 3/4 fails at OpenAI's own theorem.
  - Dropping primitivity breaks the proof (`logs/oai_env/`).
- **A separate audit.** Every stage was rebuilt from source and reviewed by a separate AI session (bb).
  - bb did this first at a second pin, Lean v4.35.0-rc3 with Mathlib `0493595e` (`lean/checks/rc3_audit/`,
    `logs/rc3_audit/`), and then in OpenAI's environment.
  - bb also checked the analytic normalisations numerically, independently of the Lean code (`logs/numerics/`).
    The bridge identity at χ₋₄ holds to 30 digits, and ε(χ_D) = 1 holds for all 1,218 fundamental
    discriminants with |D| ≤ 2000.
  - bb confirmed that the OpenAI sources used are those of openai/math at `adc7f124`, file for file
    against a git clone.
- **OpenAI's Lean proof of the 7/8 half-plane.** It is kernel-checked: it was replayed through Comparator
  (unsandboxed) with Lean's kernel and nanoda on 7 October, and it is inside the export the five checkers
  accepted. The manuscript it
  formalises is unrefereed. OpenAI's tree builds with 23 compatibility patches to third-party dependencies,
  which their lakefile applies. Every exported constant still has its axioms checked, so no patch can add an
  axiom unseen, and the statement uses no constant from a patched package: only Mathlib, Lean's core library and our two
  definitions, `DBN.Gen.Hchi` and `DBN.Gen.parityK` (the challenge that states the theorem builds against Mathlib
  alone, `challenge/`).
- **Mathlib's definitions**, at `d13f23b`: `DirichletCharacter`, `IsPrimitive`, `LFunction`,
  `completedLFunction`, `Gammaℝ`, the Bochner integral, `Complex.cos`. They are trusted as code, as for any Lean
  proof.
- **Our definitions**, `DBN.Gen.Hchi` and `DBN.Gen.parityK` and what they unfold to (`PhiC`, `thetaC`). These are
  the only constants in the statement from outside Mathlib and Lean's core library. The second half, with Fourier uniqueness, is what lets a reader check that `Hchi` means
  what this README says: the reader need only check that `Hchi χ t z = ∫₀^∞ e^{tu²} F(u) cos(zu) du` for one function F
  independent of t and z. The Comparator challenge isolates them, verbatim, in one
  small `challenge/ChallengeDefs.lean`: six constants (`thetaC`, `PhiC` and its two auxiliary proof terms,
  `parityK`, `Hchi`) on top of Mathlib.

- **The local build environment.** bb's replays were built against a local tree, `$HOME/oai-replay`: openai/math
  `adc7f124`, Lean v4.34.1, Mathlib `d13f23b`. Its sources, lakefile, manifest and patches were checked against a
  clone of `adc7f124`. Its `.lake/packages` dependency checkouts were NOT hashed; they were touched on 2026-10-24
  (`provenance/OAI_ENV.md`).
- **The sandboxed Comparator run** (`logs/comparator_sandboxed/`) rebuilt OpenAI's
  environment from the public pins, with Mathlib from its official build cache at `d13f23b`. Its solution export is
  byte-identical to the one bb made from this local tree (md5 `5ca44ad5…`), which closes the unhashed-checkout gap for
  the theorem's closure, relative to that cache. That run:
  - was in a bwrap sandbox (uid 0, all capabilities dropped);
  - used Comparator v4.34.0 with Lean's kernel and nanoda, then the paranoid set (leanchecker-paranoid, nanoda,
    con-leche, con-ron, Lean's kernel; lean4lean N/A);
  - accepted the theorem, and rejected both tampered challenges.

  bb read all of its logs and checked their md5s (`provenance/REVIEW_COMPARATOR_LAMBDA_CHI.md` and its Addenda 1 and 2). The
  solution was compiled inside the sandbox, in an earlier attempt of the same command that a container restart interrupted;
  the recorded run replayed those outputs.

  The caveats the result carries:
  - It ran as uid 0, so Comparator's assumption that it is not run by a privileged user is met in spirit, not in
    letter.
  - lean4lean could not take part: its bundled build cannot read v4.34.1 exports.
  - The run was made by another agent session. bb read its logs and reproduced the solution export byte for byte, but did
    not repeat its kernel runs.
  - One unsandboxed `lake build Challenge`, run between the two attempts to test Lake's replay behaviour, compiled nothing;
    the challenge oleans match a fresh rebuild.

## What this does and does not advance

Λ_χ ≤ 9/32 is not a new analytic bound. The conditional statement is in 2610.27343, the half-plane is OpenAI's,
de Bruijn's theorem is from 1950, and the sign of the Gauss sum is Gauss's. For conductors up to 400, FGMPS's
unconditional bounds already beat 9/32 for 136 of the 242 characters (χ₋₄ ≤ 0.26). Granting OpenAI's half-plane, their own
D = 3/4 search improves on 9/32 for 149. It is not progress on GRH for these
L-functions either; that would be Λ_χ ≤ 0. What is new is that the whole argument is now one kernel-checked
proof term under the three standard axioms, for every real primitive character simultaneously. It is checked
end to end in one Lean environment, from Mathlib's definition of `completedLFunction` to the reality of the
zeros. Along the way, three pieces were formalised that are useful on their own:

- **de Bruijn's theorem for a generic kernel** (`DBN.Gen`). Any future zero-free strip for any L-function with
  an even theta-type kernel converts into a certified bound on its de Bruijn–Newman constant.
- **Gauss's sign theorem for real primitive characters**, `DBN.Gen.rootNumber_eq_one_of_real_primitive`, in
  Mathlib's normalisation. It has a closed form for the quadratic Gauss sum along the way.
- **The bridge from the theta kernel to Mathlib's `completedLFunction`** (`DBN.Gen.bridge`, `Hchi_bridge`). Our
  heat-flow object is provably the classical one.

## Version 2: beyond 9/32, and without OpenAI

Version 2 adds three bounds on the same constant Λ_χ. They come from a different method, and they are in weaker trust
classes than the theorem above, so it is worth being precise about what is and is not checked.

Write N for the conductor of χ and ℓ = log(N/π).

- **C2: large conductors, unconditionally.** For every real primitive χ with N ≥ 10⁸, Λ_χ ≤ T(ℓ) + b(ℓ)/2 < 9/32,
  with T and b explicit. The value is 0.27643 at N = 10⁸, and the bound decays like √5·log log N / log N. It uses no
  GRH, no zero-free half-plane and no zero verification, and Siegel zeros are allowed.
- **Y3: every conductor, strictly below 9/32.** Granting OpenAI's half-plane as in version 1, Λ_χ ≤ 0.27912 for every
  real primitive χ. This strictly improves version 1's 9/32.
- **U1: every conductor, unconditionally.** Λ_χ ≤ 0.49330 for every real primitive χ, with no hypothesis at all.

**The method.** It starts from an Arb-certified lower bound for −Im(H′/H) at a fixed height, a "floor". That floor is
fed into the vertical-contraction inequalities of Planat (arXiv:2609.37164) and Hakimoglu-Brown (arXiv:2610.12803),
using FGMPS's Gaussian form of the heat flow, their strip theorem and their effective approximation. Both contraction
papers are written for Riemann's ξ; carrying them over to Dirichlet L-functions is part of the work here, not a
citation.

**What is checked, and how.**

- **Not kernel-checked.** C2, Y3 and U1 are not kernel-checked theorems.
- **Arb certificates.** The numerical floors are ball-arithmetic certificates with outward rounding (`certificates/`).
  A separate AI auditor session re-ran every ledger the three bounds depend on, and got results identical in every
  field except wall time.
- **AI-written analysis.** The analytic steps that connect the certificates to the bounds were written by AI agent
  sessions and reviewed by one AI reviewer. Nobody has refereed them.
- **Four defects already found.** An earlier version of the certifiers had four defects: a second agent session found
  three and the auditor found one. They were fixed and every certificate was re-run. §7.3 of the paper says exactly
  what they were.
- **One Lean theorem.** A single step is a Lean theorem, `C2.C2bound_lt_9_32` in `lean/v2/`: the arithmetic fact that
  the explicit bound is below 9/32 for every N ≥ 10⁸. It was built once, at Lean v4.35.0, outside version 1's
  environment, and was not replayed. That this quantity bounds Λ_χ is the non-kernel-checked part.

All three are still not progress on GRH, which would be Λ_χ ≤ 0. The records behind version 2 are in `provenance/`,
listed in Appendix B of the paper. Paths of the form `~/rh-team/...` inside those records refer to the programme's
internal working tree at the time of writing; they are not part of the release. The copies are not redacted, so that
their md5s match the originals.

## Reproducing it

### The auditor's build, exactly

The auditor built the chain with plain `lean`, one module at a time and without Lake, against an already built
checkout of openai/math. The recipe, with `$HOME`-relative paths:

1. Clone <https://github.com/openai/math> and check out `adc7f1241b42e322a6451854ab7e4b4c146bf78a`. Its Lean
   project is the `lean/` subdirectory, with toolchain `leanprover/lean4:v4.34.1` and Mathlib
   `d13f23b723b8a846827a245b89c10fc7d3f11612`. Its `lakefile.lean` (md5 `c8078fb2…`) and `lake-manifest.json`
   (md5 `8c3ec864…`) pin every dependency, and `lean/patches/` holds OpenAI's 23 compatibility patches.
2. In `lean/`, run `lake update`, then check that `lake-manifest.json` still has md5
   `8c3ec864da5d9ce3cd9dcc22ad4bf601` (`lake update` can rewrite it; if it has changed, stop, because the
   dependencies are no longer the pinned ones). Then run `lake exe cache get` and
   `lake build OAI.NumberTheory.DirichletL.Nonvanishing`. That is OpenAI's documented procedure, and their
   lakefile applies the patches. The auditor used the tree built on 7 October for an earlier replay of OpenAI's
   own Comparator challenge. bb checked its sources, lakefile, manifest, toolchain and patches file for file
   against a git clone at `adc7f124`.
3. Put all the `.lean` files of `lean/island`, `lean/gen`, `lean/gauss`, `lean/main` and `lean/checks` into one
   flat directory. The module names are flat (`import GenDefs`).
4. Compile them in this order with `lean -R . -o <module>.olean <module>.lean`:

   ```
   DBNHadamardCount DBNHadamardLinear DBNHadamardMean DBNHadamardProduct DBNStep DBNHurwitz DBNHadamard
   GenFourier GenDefs GenHeatApprox GenM1Approx GenM1Parametric GenScale GenTheta GenMellin GenMellin2 GenBridge
   GenStrip GenThetaFE GenChi4 GaussQuad GaussPrime GaussCRT GaussPow GaussTwo GaussSign GaussBridge
   BbOaiRealPrim BbOaiMeaning
   ```

   Use `LEAN_PATH` set to the toolchain's `lib/lean`, your output directory, `lean/.lake/build/lib/lean` of the
   openai/math checkout, and every `lean/.lake/packages/*/.lake/build/lib/lean`.
5. Run `lean BbOaiMeaningCheck.lean`, `lean BbOaiMeaningRef.lean` and `lean BbOaiMeaningTamper.lean`, and
   compare with `logs/oai_env/`. The tamper file must fail with 3 errors.

The auditor's own scripts are kept as records in `logs/oai_env/build.sh` and `logs/five_checker/*/*.sh`. They
call a local job-slot wrapper; with that removed, they are the commands above. Every module's source md5 and
return code is in `logs/oai_env/progress.txt`.

### The same thing through Lake

`scripts/materialize.sh` does steps 1 and 3 for you. It also checks every pin and md5, and appends
`lean/lakefile-stanza.lean` to OpenAI's lakefile, which declares the chain as five `lean_lib` targets. OpenAI's
lakefile has to stay the workspace root, because its hooks patch dependencies before Lake resolves them.

```sh
scripts/verify_md5.sh                  # every manifest: lean/, logs/, challenge/, provenance/
scripts/materialize.sh --check-island  # openai/math at the pin, our modules inside; island re-derived from source
cd work/oai
lake update && ../../scripts/check_manifest.sh && lake exe cache get   # stops if lake update rewrote the manifest
lake build RDDBNIsland RDDBNGen RDDBNGauss RDDBNMain RDDBNNegativeControl
lake env lean BbOaiMeaningCheck.lean   # [propext, Classical.choice, Quot.sound] for both halves
lake env lean BbOaiMeaningRef.lean     # the bridge statement in pp.all, with no OpenAI module in scope
lake env lean BbOaiMeaningTamper.lean  # must fail, 3 errors
```

**autoImplicit.** OpenAI's package sets `autoImplicit := false`, but the auditor compiled the chain with plain
`lean`, where the default is `true`. The stanza sets `autoImplicit := true` again on each of our libraries. That a
library-level option overrides the package-level one here is untested. A read-only scan of the chain found no
file that relies on auto-bound implicits: no undeclared universe variables, and no unbound short identifiers in
any declaration header, beyond globals like `H` and `G` and names bound by `∀ᶠ`. Either way, a mismatch can only
fail loudly. With auto-binding off, an identifier that relied on it becomes an "unknown identifier" error, and a
name that resolves to a constant is never auto-bound, so no statement can change meaning silently. **This Lake route has not itself been run yet**; the
auditor's evidence is from the plain-`lean` build above. `.github/workflows/verify.yml` runs it cold on Linux,
with the axiom, statement-identity and tamper checks, but it has not been triggered either. Expect about 25 GB of
disk and a few CPU-hours the first time.

For the five-checker replay, export with lean4export (3.1.0; the copy that builds with Comparator v4.34.0 for
toolchain v4.34.1) and run each checker on the export, as in `logs/five_checker/meaning/meaning.sh`. The export
is 1.7 GB.

## Layout

```
lean/island/        seven dbn-island modules (Hadamard, Hurwitz, the de Bruijn step), from qrh-debruijn-newman afd94c7
lean/gen/           the generic de Bruijn library, theta kernel, Mellin bridge, strip, theta FE, the chi_{-4} instance
lean/gauss/         Gauss's sign theorem (S1-S3) and GaussBridge, the general-chi meaning link
lean/main/          BbOaiRealPrim (composition with OpenAI's 7/8) and BbOaiMeaning (the headline conjunction)
lean/checks/        axiom guards with closure walks, pp.all reference statements, tampers, the skipKernelTC control
lean/checks/rc3_audit/   the auditor's stage-by-stage checks at Lean v4.35.0-rc3 / Mathlib 0493595e (records)
lean/patches/       the two one-line island repairs for OpenAI's Mathlib pin (relative to afd94c7)
lean/OAI_PIN        openai/math repo, commit, toolchain, Mathlib, and md5s of the files we depend on
lean/lakefile-stanza.lean   the lean_lib targets appended to OpenAI's lakefile
lean/MD5SUMS.txt    md5 of every file under lean/, cross-checked against the auditor's records
logs/               five-checker replays, in-environment checks, the rc3 audit, numerics, md5 manifest
logs/comparator_sandboxed/   the sandboxed Comparator run's seven logs (scratch path normalized to $SCRATCH)
challenge/          the Comparator challenge by the auditor: ChallengeDefs, Challenge, two tampers, configs, pre-flight
provenance/         ISLAND_SOURCE (where lean/island/ comes from); OAI_ENV.md (what of the local build environment was checked);
                    REVIEW_COMPARATOR_LAMBDA_CHI.md and its ADDENDUM1, ADDENDUM2 (bb's verification of the sandboxed run)
                    REVIEW_CT_RERUNS.md (the capability-dropped Comparator re-runs of P2, Ingham and CT main, for the paper's
                    companion section)
                    the auditor's stage-by-stage records, byte-identical: REVIEW_GEN_D1_D2a.md (generic library, theta
                    kernel), REVIEW_D2b_BRIDGE.md (Mellin bridge), REVIEW_D2c_STRIP.md (zero strip), REVIEW_D2bp_CHI4.md
                    (theta FE and chi_{-4}), NOTE_D2_GAUSS_SIGN.md (the root-number hypothesis), REPORT_OAI_PORT.md (the port to
                    OpenAI's environment), REVIEW_GAUSS_SIGN_AND_OAI.md (Gauss's sign theorem and the composition),
                    REVIEW_GAUSS_BRIDGE_ADD1.md (the general-chi meaning link), REVIEW_P1P6_BUNDLE.md, REVIEW_CTQ.md,
                    REVIEW_INGHAM.md and REVIEW_CTFREE_KERNELS.md (the companion results), COMPARATOR_RUN_SPEC.md (the
                    specification of the sandboxed run)
                    MD5SUMS.txt: md5 of every file in provenance/, the 17 records included (scripts/verify_md5.sh checks it)
scripts/            verify_md5.sh, materialize.sh, check_manifest.sh
lean/v2/            version 2: DQ1_P5.lean (the arithmetic step C2.C2bound_lt_9_32, built once at Lean v4.35.0) and NOTE.md
certificates/       version 2: the Arb certifiers, drivers and ledgers behind C2, Y3 and U1 (MANIFEST.md, README.md, MD5SUMS.txt)
provenance/ (v2)    P5_memo_extract.md, Y3_memo_extract.md, P5_SUPERSEDED.md and the auditor's version-2 reviews REVIEW_P5*.md,
                    REVIEW_Y3.md, REVIEW_Y3_G1.md, REVIEW_LEAN_DQ1.md, REVIEW_PRERELEASE_v2.0.0.md
paper/              the paper: main.tex, refs.bib, main.pdf
```

## Credit

- **The mathematics.**
  - The engine is de Bruijn's: *The roots of trigonometric integrals*, Duke Math. J. 17 (1950), Theorem 13.
  - The conditional statement Λ_L ≤ D²/2 = 9/32 under the 3/4 strip is due to Freire, González-Riquelme, Muñoz,
    Poblete and Salinas, arXiv:2610.27343, Remarks 3.1 and 3.4.
  - The zero-free half-plane Re s > 7/8 for Dirichlet L-functions, and its Lean proof, are OpenAI's (*The
    Quasi-Riemann Hypothesis: A Zero-Free Half-Plane Re s > 7/8*, OpenAI Math Release preprint, 2026;
    <https://github.com/openai/math> at `adc7f124`).
  - The sign of the quadratic Gauss sum is Gauss's.
  - The L-function API this rests on is Mathlib's.
  - For the ζ background, see Polymath 15 and Rodgers–Tao.
  - Version 2: the contraction inequalities are Planat's (arXiv:2609.37164) and Hakimoglu-Brown's (arXiv:2610.12803);
    the Gaussian form, strip theorem and effective approximation are FGMPS's (arXiv:2610.27343); the Euler-product and
    convexity bounds (the latter Rademacher's) are read in Bennett, Martin, O'Bryant and Rechnitzer (arXiv:2005.02989);
    the Γ-function formulas are from the DLMF; the ball arithmetic is Arb, in FLINT, through python-flint.
- **The formalisation.**
  - All the Lean code and the audits were written by AI agent sessions (Claude, Anthropic), under the direction of
    the author. One session developed the generic library, the theta and Mellin modules, Gauss's sign theorem
    and the meaning link.
  - A second, separate session (bb) audited and rebuilt every stage, wrote the compositions with OpenAI's
    theorem and the check files, and ran the replays.
  - The author set the scope and the accuracy rules, approved the work in OpenAI's environment, and decides what
    is published.
  - Version 2's certifiers and analysis were written by further AI agent sessions, and audited by bb, who re-ran
    every certificate.

See `NOTICE.md`. Licensing is in `LICENSING.md`: the code is Apache-2.0 and the paper and prose are CC-BY-4.0.
Not yet refereed.
