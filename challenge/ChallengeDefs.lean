import Mathlib

/-! # ChallengeDefs: the trusted definitions for the Λ_χ ≤ 9/32 Comparator challenge (bb, 2026-10-29)

AI-authored (bb), NOT an operator read-back.  Every non-Mathlib constant the challenge statement uses is defined here, copied
VERBATIM (same text, same `open`s and `variable`s) from the audited sources:

* `GenTheta.lean` md5 3dbf6decea4cdb0c5b59c3bde29cd7ce, lines 16-28: `DBN.Gen.thetaC`, `DBN.Gen.PhiC`
  (Lean also generates `DBN.Gen.PhiC._proof_1`, `DBN.Gen.PhiC._proof_2`, auxiliary proof terms of `PhiC`'s body);
* `GenThetaFE.lean` md5 8aeec9b012db751af3f30f43b8468f8b, lines 19-23, 29, 264-273: `DBN.Gen.parityK`, `DBN.Gen.Hchi`.

Non-Mathlib constants introduced (complete list): `DBN.Gen.thetaC`, `DBN.Gen.PhiC`, `DBN.Gen.PhiC._proof_1`,
`DBN.Gen.PhiC._proof_2`, `DBN.Gen.parityK`, `DBN.Gen.Hchi`.

In formulas: `θ_c(x) = Σ_{n≥0} c(n) n^k e^{−πn²x/q}`, `Φ_c(u) = e^{(1+2k)u} θ_c(e^{4u})`, `k(χ) = 0` (χ even) / `1` (odd), and
`Hchi χ t z = ∫_0^∞ e^{tu²} Φ_χ(u) cos(zu) du` with `Φ_χ = Φ_c` for `c n = Re χ(n)`, `k = k(χ)`, `q = N`.

The solution environment must NOT import this file: Comparator checks that each of these constants is identical
(`ConstantInfo` equality: type, value, hints, safety) to the one in the solution's own chain (GenTheta / GenThetaFE). -/

open Real MeasureTheory Set Filter Topology

namespace DBN.Gen

variable (c : ℕ → ℝ) (k : ℕ) (q : ℝ)

/-- `θ_c(x) = Σ_n c(n) n^k exp(−π n² x / q)`. -/
noncomputable def thetaC (x : ℝ) : ℝ :=
  ∑' n : ℕ, c n * (n : ℝ) ^ k * Real.exp (-π * (n : ℝ) ^ 2 * x / q)

/-- `Φ_c(u) = e^{(1+2k)u} θ_c(e^{4u})`. -/
noncomputable def PhiC (u : ℝ) : ℝ :=
  Real.exp ((1 + 2 * k) * u) * thetaC c k q (Real.exp (4 * u))

end DBN.Gen

open Real MeasureTheory Set Filter Topology Complex HurwitzZeta ZMod

namespace DBN.Gen

variable {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)

variable {χ} {c : ℕ → ℝ} {k : ℕ}

open scoped Classical in
/-- The parity weight `k(χ) = 0` (even) / `1` (odd). -/
noncomputable def parityK (χ : DirichletCharacter ℂ N) : ℕ := if χ.Even then 0 else 1

open scoped Classical in
/-- **The Dirichlet heat-flow family**, written out explicitly:
`H_t^χ(z) = ∫_0^∞ e^{tu²} Φ_χ(u) cos(zu) du`, `Φ_χ(u) = e^{(1+2k)u} θ_χ(e^{4u})`. -/
noncomputable def Hchi (χ : DirichletCharacter ℂ N) (t : ℝ) (z : ℂ) : ℂ :=
  ∫ u in Ioi (0 : ℝ), ((Real.exp (t * u ^ 2) : ℝ) : ℂ) *
    ((PhiC (fun n ↦ (χ n).re) (parityK χ) N u : ℝ) : ℂ) * Complex.cos (z * u)

end DBN.Gen
