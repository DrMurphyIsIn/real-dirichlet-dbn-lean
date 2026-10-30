# Notice and provenance

- **The result.** For every real primitive Dirichlet character χ ≠ 1 and every t ≥ 9/32, every zero of the
  de Bruijn–Newman heat flow `DBN.Gen.Hchi χ t` of Λ(s, χ) is real; classically, Λ_χ ≤ 9/32. In the same
  environment, `Hchi χ 0 z = (1/8)·N^((s+k)/2)·completedLFunction χ s` with s = ½ + iz/2, which says that
  `Hchi χ` is the heat flow of the classical completed L-function. The Lean theorem is
  `bb_real_primitive_meaning_oai`, the conjunction of the two. It is not the generalized Riemann hypothesis
  for these L-functions, which would be Λ_χ ≤ 0, and it is not a new analytic bound. The contribution is
  the end-to-end kernel proof and the formal components it is built from.
- **Mathematics credited.**
  - The engine is de Bruijn's theorem: a zero strip |Im z| ≤ Δ for H₀ gives real zeros for t ≥ Δ²/2
    (N. G. de Bruijn, *The roots of trigonometric integrals*, Duke Math. J. 17 (1950), 197–226, Theorem 13).
  - The conditional statement Λ_L ≤ D²/2 = 9/32 under a zero-free strip of half-width D = 3/4 is in
    Freire, González-Riquelme, Muñoz, Poblete and Salinas, arXiv:2610.27343, Remarks 3.1 and 3.4.
  - The sign of the Gauss sum of a real primitive character, ε(χ) = 1, is Gauss's theorem.
  - For the ζ context, see Polymath 15 (Res. Math. Sci. 6 (2019), paper 31) and Rodgers–Tao
    (Forum Math. Pi 8 (2020), e6).
- **OpenAI.** The zero-free half-plane `OAI.DirichletCharacter.LFunction_ne_zero_of_seven_eighths_lt_re`
  (every Dirichlet L-function is nonzero on Re s > 7/8, except at s = 1 for the trivial character) is OpenAI's. It comes from
  *The Quasi-Riemann Hypothesis: A Zero-Free Half-Plane Re s > 7/8*, OpenAI Math Release preprint, 2026, and
  its Lean proof, <https://github.com/openai/math> at commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`
  (Apache-2.0). The manuscript is unrefereed; the Lean proof is kernel-checked. No OpenAI file is vendored here.
  `scripts/materialize.sh` checks out their `lean/` directory unmodified and builds this repository's files
  inside it. That checkout carries OpenAI's own 23 compatibility patches to third-party dependencies, applied
  by their lakefile, as at the pin.
- **The dbn island.** The seven modules in `lean/island/` come from the author's earlier release
  <https://github.com/DrMurphyIsIn/qrh-debruijn-newman> at commit `afd94c7` (Apache-2.0; `provenance/ISLAND_SOURCE`).
  Five are byte-identical. Two carry a one-line proof repair each for OpenAI's Mathlib pin, recorded in
  `lean/patches/`; neither changes a statement or a definition.
- **Lean and Mathlib.** Lean 4 v4.34.1 and Mathlib `d13f23b723b8a846827a245b89c10fc7d3f11612` are OpenAI's
  pins. The L-function API (`DirichletCharacter.LFunction`, `completedLFunction`, `gammaFactor`, `rootNumber`,
  `IsPrimitive`, the Hurwitz-kernel functional equations) is Mathlib's.
- **Verification.**
  - Lean's kernel: `#print axioms` gives `[propext, Classical.choice, Quot.sound]` for both conjuncts.
  - A replay of the exported environment by five checkers from three implementation lineages (leanchecker,
    leanchecker-paranoid, nanoda, con-leche, con-ron), each of which also rejected a `debug.skipKernelTC`
    negative control.
  - Tampered statements were rejected.
  - Everything was rebuilt and audited by a separate AI session (bb); its records are in `logs/`.
  - Those replays were local and unsandboxed. A sandboxed Comparator run against a separately written challenge
    also accepted it, and rejected both tampered challenges (`challenge/`, `logs/comparator_sandboxed/`). It ran as
    uid 0 with all capabilities dropped; bb read its logs in full and reproduced the solution export byte for byte.
- **Checkers.** nanoda (<https://github.com/ammkrn/nanoda_lib>), con-leche, con-ron, and Lean's leanchecker,
  as bundled with Lean v4.35.0-rc3. The export tool is lean4export 3.1.0, and Comparator is
  <https://github.com/leanprover/comparator>.
- **Machine assistance.** All the Lean code here, the audits and the tooling were written by AI agent sessions
  (Claude, Anthropic), working under the direction of the author.
  - One session developed the generic library, the theta and Mellin modules, the Gauss sign theorem and the
    meaning link.
  - A second, separate session (bb) audited every stage. bb also wrote the compositions with OpenAI's
    theorem and the check, reference and tamper files, and ran the replays.
  - The author set the scope and the accuracy rules, approved the steps that ran in OpenAI's environment, and
    decides what is published.

  The Lean kernel is the trusted component: every claim here is either a kernel-checked theorem or labelled
  otherwise.
