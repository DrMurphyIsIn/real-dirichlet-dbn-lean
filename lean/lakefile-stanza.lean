
-- ===== real-dirichlet-dbn-lean (appended to OpenAI's lakefile by scripts/materialize.sh) =====
-- Every module below was built by the auditor with plain `lean` against OpenAI's built tree, so with Lean's
-- default options (autoImplicit := true). OpenAI's package sets autoImplicit := false, so each library
-- restores the default. This stanza records that build as a Lake target; it has not itself been run yet
-- (see README, "Reproducing it").
--
-- The seven de Bruijn modules the generic library needs, from the dbn island (provenance/ISLAND_SOURCE),
-- with the two one-line proof repairs of lean/patches/ already applied.
lean_lib RDDBNIsland where
  roots := #[`DBNHadamardCount, `DBNHadamardLinear, `DBNHadamardMean, `DBNHadamardProduct, `DBNStep,
    `DBNHurwitz, `DBNHadamard]
  leanOptions := #[⟨`autoImplicit, true⟩]
-- The generic de Bruijn theorem, the theta kernel, the Mellin bridge, the zero strip, the theta functional
-- equation and the chi_{-4} instance (13 modules).
lean_lib RDDBNGen where
  roots := #[`GenFourier, `GenDefs, `GenHeatApprox, `GenM1Approx, `GenM1Parametric, `GenScale, `GenTheta,
    `GenMellin, `GenMellin2, `GenBridge, `GenStrip, `GenThetaFE, `GenChi4]
  leanOptions := #[⟨`autoImplicit, true⟩]
-- Gauss's sign theorem for real primitive characters (6 modules) and the general-chi meaning link.
lean_lib RDDBNGauss where
  roots := #[`GaussQuad, `GaussPrime, `GaussCRT, `GaussPow, `GaussTwo, `GaussSign, `GaussBridge]
  leanOptions := #[⟨`autoImplicit, true⟩]
-- The composition with OpenAI's Dirichlet 7/8 theorem and the headline conjunction.
lean_lib RDDBNMain where
  roots := #[`BbOaiRealPrim, `BbOaiMeaning]
  leanOptions := #[⟨`autoImplicit, true⟩]
-- Negative control for the independent checkers: a FALSE theorem `BbNeg.bogus : 4 = 5` added with
-- debug.skipKernelTC. Every checker run on its export must reject it. Nothing imports it.
lean_lib RDDBNNegativeControl where
  roots := #[`BbOaiSkip]
  leanOptions := #[⟨`autoImplicit, true⟩]
