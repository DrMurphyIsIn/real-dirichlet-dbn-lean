# DQ-1 wave 6, W2B3 (agent w2mid): the derivative kernel on the uniform route — certified walls 1.65·10⁶ (odd) / 3.7·10⁶ (even)

w2mid, 2026-11-02. AI work by one agent. Not reviewed (for bb). No operator read-back. conjecture1_proved = False.
**Nothing here is progress on RH.** Every statement is a bound on Λ_χ for real primitive Dirichlet characters; none is GRH.
Follows W2M_memo.md 6aedc0f0 (the assessment) and the lead's GO (user-approved recommendation (ii)).

Inputs: Z3/memo.md 44cd5258 §4 (Theorem Z3-U and its transposition), REVIEW_Z3 e9cdbb52 §1, Y3/memo.md 3779ce49 §3–4, P5/memo.md
§A.13 (the assembly; lines 968–982, 1366–1392 read), the published v2 paper (main.tex 8135804d, eq. (tilt) lines 697–704 and §7),
WAVE5.md §2. **Hakimoglu-Brown 2610.12803 read at source (alphaXiv, PDF pages): p.14 Lemma 10 (Φ(D, r), (25)–(26) and its proof),
p.15 Prop 11 ((31)–(32): G* bounds ∂_pS, with ∂_yS = −Re(H′_t/H_t)′), p.17 Thm 12 ((33) and proof), p.18 Table 3, pp.22–23 the
Bernstein certificate (34)–(36) and the Arb scalar bounds.** Code read to EOF: scripts/y3_cert.py 5b375c5b, y3_big2.py aafeba32,
y3_big.py aa232458, y3_sweep.py 129799ab, z3_stepped_bound.py 71b639ae.

Labels as in W2M: CITED-READ, PROVED, COMPUTED, **CERTIFIED (Arb)** (0-failure cover, as-run code and md5 archived), MODEL, FROM MEMORY
(nothing load-bearing). Trust classes (WAVE5 Amendment 1 F5): everything here is **T3** (AI-written proofs reviewed by one AI reviewer,
once bb has reviewed) with Arb certificates (T2) and unrefereed preprints (T4; H-B 2610.12803 is a "working draft", unrefereed);
Lemma Z′ beyond 4·10⁵ carries both labels ("FGMPS Thm 4.3/Prop 4.18 for every m: our reading, auditor-checked only").

Files: `~/rh-team/dq1/Z3/w2b3_*` (md5s §9). One core per job, BLAS pinned, ≤ 4 workers, longest job 10.5 min, max RSS < 60 MB.
**Compute: ≈ 1.1 CPU-h** (W2B3) + 0.9 (W2M) = 2.0 of the 4 CPU-h budget. No Lean, no lake, no git, no external code, nothing published.

---

## 0. Result

> **Theorem W2B3-U (unconditional; Arb class; AI-written, UNREVIEWED; for bb).** For every real primitive Dirichlet character χ
> of conductor m: **odd χ with 1 650 000 ≤ m ≤ 10⁸: Λ_χ ≤ 0.2807226 < 9/32** (margin 5.27·10⁻⁴); **even χ with 3 700 000 ≤ m ≤ 10⁸:
> Λ_χ ≤ 0.2808812 < 9/32** (margin 3.69·10⁻⁴); and m ≥ 10⁸ (either parity): Λ_χ ≤ 0.2764282 by Theorem C2 (published v2).
> Hence **Λ_χ < 9/32 for odd m ≥ 1.65·10⁶ and even m ≥ 3.7·10⁶**, with no GRH, no zero-free half-plane and no zero verification
> (a Siegel zero is allowed).

Against the record: Theorem Z3-U (9.5·10⁶ / 2.1·10⁷, bb CONFIRMED, not yet folded in) by 0.76 / 0.75 decades; the PUBLISHED Remark U2
(15 848 932 / 36 307 806) by 0.98 / 0.99 decades. The uncovered set (W2M §1) shrinks from 9 270 900 characters to ≈ 1 700 000
(odd m < 1.65·10⁶: ≈ 500 000; even m < 3.7·10⁶: ≈ 1 100 000; exact counts in w2m_count.py's per-range table: odd 182 376 + 303 963·0.65 +
121 592, even 182 378 + 303 978 + 607 921·0.85 + 121 579, the fractions COMPUTED by interpolation, not by a new count).

**What is new, in one line:** H-B's Theorem 12 (the derivative kernel) transposed to the x-UNIFORM route (no barrier), with the first
certifier of **G_i = sup_x ∂_pS_χ(x, p, t)** over a slab, built as an extension of Y3's G1/LX certifiers (§2), exact-rational Bernstein
certificates of H-B's Φ_i ≥ 0 (§4), 39 slab covers per parity at p = 7/2 (§5), and the landing in Arb (§6). The plain kernel
((λ, μ) = (1, 0)) from the SAME ledgers does not land at all (q ≈ 0.037 / 0.032 at t = 0.29): every decade gained is the derivative
kernel's.

**Soundness checklist (§7):** R-ball, R-dir, R-tail, R-split, R-cover carried; negative controls: tampered ledger, uncertified Φ row,
m_lo below the ledgers, and a (λ, μ) outside Lemma 10's region are all REFUSED (§8).

**ERRATUM F1 (2026-11-03, after bb REVIEW_W2B3 63c7497a: PASS after one required fix).** bb found a bound-direction bug in the
new G1 accumulator (w2b3_cert.py, the `dL` term): the mean value theorem on the segment [c, w] needs sup|(L′/L)′| over the SEGMENT,
i.e. Z2 at the segment's minimum real part `umin` (= R for g ≥ 0), but the pre-fix code used Z2 at the cell's own real part `uZ`,
which for g > 0 UNDER-estimates (Z2 is decreasing). Fixed: `dL = tau*absg*Z2_up(umin)` (`Z2u = Z2_up(uZ)` stays for the pointwise
|f′(w)| term, which is correct). The S path is untouched (w2b3_check: bit-identical on all 26 boxes). **The certificate of record was
re-issued with the fixed code:** all 78 slab sweeps re-run (w2b3_cov2_*, 0 failures, 6 078 / 8 076 evaluations — exactly bb's
numbers), max rise of a slab's certified G +2.6·10⁻³ (odd) / +3.1·10⁻³ (even), min CG slack 1.9·10⁻⁵ / 3.3·10⁻⁵ (tight, but a
certificate), landing inputs unchanged, **Theorem W2B3-U's numbers stand** (w2b3_bound2_a{1,0}.json, byte-identical to the pre-fix
landings since CF_i, CG_i, A²_i, λ_i, μ_i are the same). Pre-fix code, ledgers, landings and memo are archived in
`superseded_w2b3/prefix_F1/` (cert adaf2ee3, big2 e7f43d44, sweep 9c5babc3, ledgers w2b3_cov_*, memo ec5e2fdd); §5, §9 below are the
re-issued record. Nits: N1 (the §5 "boxes certified" column now gives certified boxes, not evaluations), N2 (the IIb slack
e^{−s₁²/(16τ²)} is now cited to Y3 §4.3 B3 / P5 A.9.1 in w2b3_big2.py), N3 (w2b3_big2's docstring aligned with the variance form),
N4 (every ledger of record carries `certifier_md5` = {w2b3_cert f2e56a85, w2b3_big2 4b780036, w2b3_sweep 9efa5464, y3_big aa232458}).

**The points bb should check first (§7.6):** (i) the variance identity (D′/D)′ = ⟨f′ + (f − m)²⟩ − ⟨f − m⟩² and the tail bookkeeping of
D″ by parts (§2.2–2.3); (ii) the v-monotonicity of the new LX boundary term (§2.4); (iii) δ = 1/2 (§2.5); (iv) the transposition of
Thm 12 at a highest zero on iℝ (the r₀/z term of FGMPS Prop 3.2), §3.

---

## 1. The theorem's shape (PROVED by transposition, unreviewed)

Everything is Theorem Z3-U's proof (Z3 §4.4, Y3 §3.2 assembly = P5 A.13.3, bb PASS) with H-B's Theorem 12 in place of Theorem 9:

- **Initial strip** q₀ = 1 − 2t_min at t_min = 10⁻⁴ (de Bruijn / FGMPS Thm 2.6; a Siegel zero sits on iℝ at height ≤ 1).
- **Compact attainment** of a first contact: Lemma Z′ (Y3 p2z_small, 3 ≤ m ≤ 10⁸; FGMPS Thm 4.3 + Prop 4.18 beyond 4·10⁵: both labels),
  exactly as Z3-U; this is why the ledgers stop at m_hi = 10⁸ and C2 takes over.
- **Multiple zeros and the imaginary axis**: FGMPS Prop 3.2 (Hermite splitting; the r₀/z term), Lemma 3.7; as in C2/Y3/Z3-U.
- **The kernel comparison at the highest simple zero x + ih (q = h² ≤ q_i):** H-B Lemma 10 (p.14, CITED-READ): for B = p², 0 < A² < B,
  λ, μ ≥ 0 with Φ(D, r) ≥ 0 on D ≥ 0, 0 ≤ r ≤ A², and 0 < h² ≤ A², 0 ≤ v ≤ h, (d, v) ≠ (0, h):
  K_h(d, v) ≥ h(λK_p(d, v)/p − μ∂_pK_p(d, v)), where K_p(d, v) = (p − v)/(d² + (p−v)²) + (p + v)/(d² + (p+v)²) is the conjugate-pair
  kernel (its derivation from the zero ODE is FGMPS Prop 3.2 = Polymath's, as in Z3-U; K_p = 2pw/Δ in H-B's notation). Summing over all
  other pairs (every v_j ≤ h since h is the global maximum; the own pair removed contributes K_p(0, h) = 2p/(B − q) and ∂_pK_p(0, h) =
  −2(B + q)/(B − q)²; S = Σ_pairs K_p = −Im(H′/H)(x + ip) and ∂_pS = Σ ∂_pK_p, absolutely convergent), with S ≥ C_i and ∂_pS ≤ G_i on
  the slab for ALL x (the uniform route: no "Lemma 2 permits x > X" is needed):
  h′ = −1/h − 2Σ′K_h ≤ −1/h − 2h[λ_i(C_i − 2p/(B − q))/p − μ_i(G_i + 2(B + q)/(B − q)²)] and, since the bracket decreases in q < B
  (H-B p.17), q′ = 2hh′ ≤ −2 − k_i q with **k_i = 4(λ_iC_i/p − μ_iG_i − 2λ_i/(B − q_i) − 2μ_i(B + q_i)/(B − q_i)²)** (H-B (33)).
- **The stepped comparison** (barrier Q_i, first-contact argument, the gate, the final strip theorem): H-B Thm 9/12 verbatim; per-slab
  (λ_i, μ_i) is admissible exactly as per-slab p was in Z3 §4.1 (the proof is per step). Here p = 7/2 throughout. The time restriction
  t ≤ 1/5 of H-B (Polymath's barrier window) is replaced by t ≤ t_hi of the ledgers and Lemma Z′'s t ≤ ½, as in Y3/Z3.
- **∂_pS in the certifiers' variables (PROVED, elementary; W2M §3.2):** from the published identity (tilt), H_t(x + ip) = pref·D(c) with
  pref = (N/π)^{(1−iz)/4}e^{ℓ²t/16} (so (log pref)″ = 0) and c = (1 − iz)/2 + tℓ/4, dc/dz = −i/2: S = ℓ/4 + ½Re(D′/D)(c) and
  ∂_pS = ∂_yS = −Re(H′/H)′ = ¼Re[(D′/D)′](c).

So the theorem needs, per slab i: **(F_i)** S − ℓ/4 ≥ CF_i for all x, all m ∈ [m_lo, 10⁸], t ∈ slab; **(G_i)** ∂_pS ≤ CG_i likewise;
**(Φ_i)** Φ ≥ 0 at (A²_i, λ_i, μ_i), A²_i ≥ q_i; and the Arb landing. §2–6 supply them.

---

## 2. The G certifier (the new piece): w2b3_cert.floor_box and w2b3_big2.big2

### 2.1 Design rule
Y3's certifiers are extended by ACCUMULATORS ONLY: the S floor's code path is unchanged line for line, and `w2b3_check.py` confirms
**bit-identical S on 16 G1 boxes and 10 LX boxes** (w2b3_cert_vs_y3_cert.diff d1d4f5eb, w2b3_big2_vs_y3_big2.diff e2b01685: the
changed lines are docstrings, 3-tuple returns, the refactors `uZ`, `bd`, `qus` (same values) and one new assert). Both return
(S_lo, G_hi, info) with G_hi rounded UP (`fhi`), S_lo rounded down (`flo`, the C1 fix).

### 2.2 The identity used (PROVED, elementary)
Write f = Φ′/Φ (Φ = Γ_a·L) and ⟨h⟩ := [∫_bulk e^{r}hφ + tail(h)]/[∫_bulk e^{r}φ + T0] for the normalised average that the certifiers
already use (so D′/D = ⟨f⟩, D″/D = ⟨f′ + f²⟩, ⟨1⟩ = 1, with the bulk on the shifted contour and the tails raw). For ANY constant m,
   **(D′/D)′ = D″/D − (D′/D)² = ⟨f′ + f²⟩ − ⟨f⟩² = ⟨f′ + (f − m)²⟩ − ⟨f − m⟩².**
Take m = the χ-dependent constant at the centre (G1: ψ_a(c) + L′/L(c); LX: β = β₁ + β₂ of the double shift). Only |m| ≤ |pc| + Z(R)
(G1) / |β| ≤ Pb_ (LX) is used. On the bulk (Re w ≥ u0 by the B1 clamp), the mean value theorem on the segment [c, w] gives
   |f(w) − m| ≤ τ|g|·M_G + min(τ|g|·Z2(Re w), Z(Re w) + Z(R)) =: numc,   |f′(w)| ≤ M_G + Z2(Re w),
with M_G = ¼ψ′((u_min + a)/2) (§2.6) and Z2 = (ζ′/ζ)′ (decreasing on (1, ∞); the monotone table `Z2_up` of y3_big). Hence
   |⟨f′ + (f−m)²⟩| ≤ [D2 + DT2 + 2|m|DT1 + |m|²DT0]/den,  D2 = ∫_bulk e^{e}(M_G + Z2 + numc²)w (+ right tail),
   |⟨f − m⟩| ≤ [D2b + DT1 + |m|DT0]/den,                  D2b = ∫_bulk e^{e}numc·w (+ right tail),
   **G = ¼Re(D′/D)′ ≤ ¼(E1 + E2²).**
The tails: tail(f′ + f² − 2mf + m²) = tail(Φ″/Φ(c)) − 2m·tail(Φ′/Φ(c)) + m²·tail(1); |tail(Φ′/Φ(c))| ≤ DT1 (Y3's, by parts once)
and |tail(Φ″/Φ(c))| ≤ DT2 (§2.3); |tail(f − m)| ≤ DT1 + |m|DT0. (Why not D″/D − (D′/D)² term by term: that costs 2|m|K + K² + (the
whole |L′/L| in num² for G1), measured 0.38 against 0.23 for the same box.)

### 2.3 DT2: the tail of Φ″ by parts twice (PROVED)
On the tail region in the variable g (w = c + τg, dw = τdg): ∫_tail Φ″φ = τ⁻²{[τΦ′φ] + [Φgφ] + ∫_tail Φ(g² − 1)φ} at the inner edge
U = u0 (g = g0; φ′ = −gφ, φ″ = (g² − 1)φ). So
   DT2 = ∫_tail |Φ(w)/Φ(c)|(g² + 1)φ/τ² + |Φ(w0)/Φ(c)|φ(g0)·(|g0|/τ² + |Φ′/Φ(w0)|/τ),
   |Φ′/Φ(w0)| ≤ |ψ_a(w0)| + Z(u0), |ψ_a(w0)| ≤ P_up((u0 + a)/2, v) with the x-box as a BALL in v (y3_big.P_up's bound is monotone-safe
   on a ball: its `min` falls back to 1/u when undecided).
Riemann-sum tail cells: the existing q(U) with multiplier (gg² + 1)/τ². Far half-line U < U_MIN (v = U_MIN − U ≥ 0):
(g² + 1)/τ² = ((R − U)²/τ² + 1)/τ² ≤ ((R − U_MIN)²/τ² + 1)/τ²·e^{2v/(R − U_MIN)} (from (A + v)² ≤ A²e^{2v/A}): Q0c = Q0 +
log((...)), Q1c = Q1 + 2/(R − U_MIN), the same closed form `halfline` (Q2 > 0 now asserted). Right Gaussian tail g > G_HI > 0 (Zs = Zc,
M ≤ Mmax there): numc ≤ τg·MZ with MZ = Mmax + Z2(u0); M + Z2 + numc² ≤ (MZ + 1)e^{2τgMZ} and numc ≤ e^{τgMZ} (y ≤ e^{y} ≤ e^{2y},
y² ≤ e^{2y}, 1 ≤ e^{2y} for y ≥ 0): the same erfc closed form with B2 = τρ + τZc + 2τMZ (resp. τMZ), A2 = 1 − τ²Mmax > 0 asserted.
In LX (big2): T2 = Σ wu·q·(gpr² + 1)/τ² with gpr the existing bound on |g| in the U-measure; far tail ∫e^{−(rate/2)s}((gm + s/τ)² + 1)ds
≤ 2.5(gm² + 1)/(rate/2) = 5(gm² + 1)/rate when gm·τ·(rate/2) ≥ 2 (checked; else G = +∞, the box fails); region IIa:
∫e^{−σs}((g₁ + s/τ)² + 1)/τ² ds = [(g₁² + 1)/σ + 2g₁/(τσ²) + 2/(τ²σ³)]/τ² with σ = sIIa, g₁ = ((R − U1) + τ²Pb_)/τ; region IIb: eIIb
added to T2 as to T0/T1 (the quadratic multiplier ((s₁ + R + 1)/τ²)² ≤ e^{s₁²/(16τ²)} for s₁ ≥ 2500, τ ≤ ½: log LHS ≤ 2log(2s₁) + 4|log τ|
< 40 ≪ 1.56·10⁶); by-parts boundary at U = u_s: q(u_s)·(gpr(u_s)/τ + P_up((u_s + a)/2, v_m) + Z(u_s)).

### 2.4 v-monotonicity of the LX extension (R-cover for all x ≥ 10⁴; inherited P5 A.9.2 + one new check)
Every new bulk piece is a product of pieces already shown non-increasing in v (num, M, z2, the weights). The new boundary term
q(u_s)·(|ψ_a(w_s)| + Z + |g_s|/τ) has |ψ_a| ~ ½log v growing: q(u_s) carries lg = −(R − U)·gl_, i.e. ~ v^{−(R − u_s)/2}, so the product
is non-increasing for v ≥ v₀ = 2500 iff (R − u_s)/(2v) ≥ d/dv log|ψ_a| ≈ 1/(v log v), i.e. R − u_s ≥ 2/log 2500 = 0.256.
**Asserted: (R − u_s) ≥ ½** (true for p = 7/2: R ≥ 2.25, u_s = 1.5). **bb: this is the one new monotonicity claim.**

### 2.5 δ = 1/2 (the bulk/tail split u0 = 1 + δ)
y3_cert/y3_big2 take δ = 1/4. The tails use Rademacher's convexity bound (BMOR Lemma 5.6, (5.3), CITED-READ by P5) for −δ ≤ σ ≤ 1 + δ,
0 < δ ≤ ½, and log ζ(1 + δ); nothing else depends on δ. At δ = ½ the cells with Re w ∈ [1.25, 1.5] (where Z(u) ≈ 3.9, Z2(u) ≈ 16 and
e^{e} ≈ e^{τ|g|Z}) move from the bulk to the tail, which is what made G blow up at large τ before (0.83 at t = 0.29, even; §W2B3
development log in w2b3_check runs). Measured effect (w2b3_check at p = 7/2, L = 13.08, x ∈ [0, ¼]): odd t ≈ 0: S −0.1986 vs −0.2068,
G 0.224 vs 0.232; even t = 0.29: G 0.182 vs 0.211. Both S and G improve; the sweeps run at δ = ½ (asserted ≤ ½ in w2b3_sweep).

### 2.6 M_G: the sharper Γ-majorant for the G terms only
y3_cert's M is the trig majorant ¼(1/u² + 1/u) ≥ ¼sup|ψ′|. For the G terms: |ψ′(u + iv)| = |Σ_k (u + k + iv)⁻²| ≤ Σ_k (u + k)⁻² = ψ′(u),
and ψ′ decreases on (0, ∞) (DLMF 5.15.1), so sup over Re ≥ u_min is ψ′(u_min), evaluated rigorously by acb.polygamma (python-flint →
FLINT acb_polygamma): M_G = min(M, ¼ψ′((lo(u_min) + a)/2)). At u = 1.125 (even, t ≈ 0): 1.388 against the trig 1.679, worth 0.018
in G for even χ. The S path keeps M.

### 2.7 Calibration (COMPUTED): certified G against the x = 0 model ¼ψ₂(R) + (1/16)ψ′((R + a)/2)
At p = 7/2, L = 13.08, x ∈ [0, ¼], δ = ½ (w2b3_check.py a198a5ee, run output in the development log):

| parity | t ≈ 0 | t = 0.15 | t = 0.29 | x ∈ [500, 512], t = 0.29 |
|---|---|---|---|---|
| odd: certified / model | 0.2207 / 0.1865 | 0.173 / 0.105 | 0.119 / 0.072 | 0.035 / — |
| even: certified / model | 0.2611 / 0.2207 | 0.235 / 0.127 | 0.188 / 0.087 | 0.035 / — |
| LX (x ≥ 10⁴), R = 2.26 / 2.9 / 3.4 | 0.145 / 0.046 / 0.021 (both parities; the double shift moves the L-centre to R + τ²ρ_lo) | | | |

The certified G is above the model everywhere (R-dir sanity: the model is the true value at x = 0, t = 0 up to the tilt), by 0.03 at
t ≈ 0 and 0.05–0.11 at larger t (the tilt average's second moment E2² and the Z2 majorant at the cells' lowest Re). The certified
corner floor S at δ = ½ is −0.1986 (odd) / −0.3384 (even) against the exact −0.18 / −0.32 (W2M §2).

---

## 3. What remains from Z3-U unchanged, and the one place bb should look (the imaginary axis)
P5 A.13 (lines 975, 1374): "the imaginary axis is handled by the P2′ / contact argument with y ≥ √b"; "Siegel zeros lie on iℝ with
|y| ≤ 1 and are untouched by the argument." The contact argument applies the kernel inequality at the highest simple zero wherever it
is (including x = 0, where FGMPS Prop 3.2's r₀/z term appears when zeros lie on iℝ). Thm 12 changes only the per-pair inequality
(Lemma 10 in place of Lemma 10 at (1, 0)); the r₀/z term, the Hermite splitting and Lemma 3.7 are untouched. **I did not re-derive
P5's handling of the r₀/z term; I state that it is the same step as in C2/Y3/Z3-U (bb PASS) and ask bb to confirm that Lemma 10's
pairwise form does not interact with it.**

---

## 4. Φ_i ≥ 0: exact-rational Bernstein certificates (w2b3_phi.py 797ff1d8; CERTIFIED, exact)
H-B's (34)–(36): Ψ_i(U, V) = ((1 − U)⁴/B⁴)Φ_i(BU/(1 − U), A²_iV), a polynomial of degree ≤ 4 in each variable (Φ has degree 4 in D
and in r: checked by assertion), 8 strips in U, 25 Bernstein coefficients β_ab = Σ_{k≤a, m≤b} a_km C(a,k)C(b,m)/(C(4,k)C(4,m)) per
strip, all > 0 ⇒ Ψ > 0 on [0, 1]² ⇒ Φ_i > 0 for every finite D ≥ 0, 0 ≤ r ≤ A²_i (U = D/(D + B) < 1; the corner U = 1 is the leading
coefficient 2 − 2λ + 2μ). Python `fractions` throughout; no float. Self-test: H-B's Table 3 row 0 (p = 61/20, q₀ = 9/16, λ = 1.718,
μ = 0.868) certifies with min coefficient 7.1·10⁻³ > 13/10000 (their (36) bound holds for it); (λ, μ) = (1, 0) at B = 49/4, A² = 1 gives
min coefficient exactly 0 (the boundary case of Lemma 10's remark); **negative control (λ, μ) = (5/2, 0) is REFUSED** (min −3).
Certificates of record: w2b3_phi_a1_m1650000.json 4e72c655 and w2b3_phi_a0_m3700000.json c3213386 — 39 rows each, `all_certified`
true, A²_i = ⌈1000q_i⌉/1000 + 1/1000 with q_i the design's float barrier value (the landing asserts the Arb q_i ≤ A²_i), λ_i, μ_i
multiples of 1/50 in [1, 2] × [0, 1.6]. The first design (float grid test only) produced two rows that the exact certificate refused
(A² = 23/1000, 3/1000: min coefficients −1.5·10⁻³, −4.0·10⁻³); the design now optimises (λ_i, μ_i) UNDER the exact certificate
(w2b3_design.py 7ad66fa0, `best_k`), so every row of the plans is certified by construction.

---

## 5. The covers (CERTIFIED (Arb); w2b3_sweep.py 9c5babc3 = y3_sweep.py's structure with the two certifiers; w2b3_launch.py 49f7fd30)
p = 7/2 (exact decimal '3.5' → σ′ = 9/4), δ = ½, τ-ratio 1.02, G1 on 0 ≤ x ≤ 10⁴ with bisection (x, τ, R; depth cap 24), LX at
v₀ = 2500 for x ≥ 10⁴ (depth cap 16); a box passes iff S ≥ CF_i AND G ≤ CG_i; bands [m_lo, 10⁸]; 39 contiguous slabs with edges
10⁻⁴, 0.005, 0.010, …, 0.100, 0.11, …, 0.29 (t_hi of the last slab 0.29; TAU_LO/TAU_HI padded outward as in y3_sweep, so the certified
t-ranges overlap at every seam: asserted by w2b3_bound). Targets: CF_i = (measured slab minimum, w2b3_measure.py f3b36538 on x ≤ 16 at
0.25 steps + LX, 136 fine τ-slabs, R-cells ≤ 0.02) − 0.004, CG_i = (measured slab maximum) + 0.004.

| parity | band | slabs | boxes certified (evaluations) | failed | wall | ledgers OF RECORD (F1 code; md5 of the 39 DONE files concatenated in slab order) |
|---|---|---|---|---|---|---|
| odd | [1 650 000, 10⁸] | 39 | 4 926 (6 078) | **0** | 126 s | w2b3_cov2_a1_m1650000_s{0..38}.DONE → 696148f1 |
| even | [3 700 000, 10⁸] | 39 | 5 925 (8 076) | **0** | 166 s | w2b3_cov2_a0_m3700000_s{0..38}.DONE → 0be5d4cf |

(Pre-F1, superseded: w2b3_cov_* with 4 868 (5 962) / 5 888 (8 002), d496a4f8 / feb27a07, in superseded_w2b3/prefix_F1/ledgers/.)
Every ledger: `complete` true, `n_failed` 0, CF/CG the exact floats the boxes were compared against, m-edges rounded outward (L_lo
down, L_hi up, asserted in Arb at 200 bits), t-edges from the ledgers, `certifier_md5` stamped (N4). The sweeps' own worst/max
values sit inside the targets; after F1 the smallest CG − max G is 1.9·10⁻⁵ (odd, slab 8) / 3.3·10⁻⁵ (even, slab 7).

---

## 6. The landing (Arb, outward; w2b3_bound.py 4b4ca675; outputs OF RECORD w2b3_bound2_a1.json 87e26183, w2b3_bound2_a0.json 55c37c93, from the F1 ledgers; byte-identical to the pre-F1 w2b3_bound_a{1,0}.json, archived)
q₀ = 1 − 2·10⁻⁴, b = 10⁻⁴; per slab: C_i = L_lo/4 + CF_i, G_i = CG_i, k_i by (33) with the certificate's rationals, asserted
0 < q_i ≤ A²_i < B and k_i > 0; q_{i+1} = (q_i + 2/k_i)e^{−k_id_i} − 2/k_i; landing when t_i + log((2 + k_iq_i)/(2 + k_ib))/k_i ≤ t_{i+1}.
L_lo is monotone: k_i increases with L, so the value at m_lo bounds the band (as in Z3-U, bb REVIEW_Z3_R1).

| parity | m_lo | L_lo (lo) | landed in slab | T (up) | **Λ_χ ≤ (up)** | margin to 9/32 (lo) | k_0 … k_38 (lo) | plain k_0 … k_38 |
|---|---|---|---|---|---|---|---|---|
| odd | 1 650 000 | 13.1716 | 38 ([0.2801, 0.2901]) | 0.2806725 | **0.2807226** | 5.27·10⁻⁴ | 3.421 … 4.438 | 2.821 … 3.074 |
| even | 3 700 000 | 13.9791 | 38 | 0.2808311 | **0.2808812** | 3.69·10⁻⁴ | 3.435 … 4.454 | 2.892 … 3.171 |

Condensed rows (every fourth slab; the full 39-row tables are in the JSONs):

odd: | i | t_i | CF_i | CG_i | A²_i | λ_i | μ_i | q_i (up) | k_i (lo) |
|---|---|---|---|---|---|---|---|---|
| 0 | 0.0001 | −0.20265 | 0.21709 | 1001/1000 | 8/5 | 16/25 | 0.99980 | 3.4212 |
| 8 | 0.0400 | −0.17840 | 0.19966 | 199/250 | 81/50 | 33/50 | 0.79463 | 3.5829 |
| 16 | 0.0800 | −0.15345 | 0.18947 | 307/500 | 83/50 | 18/25 | 0.61246 | 3.7221 |
| 24 | 0.1400 | −0.11652 | 0.17538 | 191/500 | 44/25 | 9/10 | 0.38018 | 3.9260 |
| 32 | 0.2200 | −0.06485 | 0.14887 | 7/50 | 9/5 | 24/25 | 0.13855 | 4.2313 |
| 38 | 0.2801 | −0.03162 | 0.12956 | 3/1000 | 46/25 | 26/25 | 0.00133 | 4.4378 |

even: | 0 | 0.0001 | −0.34252 | 0.25610 | 1001/1000 | 8/5 | 16/25 | 0.99980 | 3.4348 |
|---|---|---|---|---|---|---|---|---|
| 8 | 0.0400 | −0.32132 | 0.24103 | 199/250 | 81/50 | 33/50 | 0.79449 | 3.5830 |
| 16 | 0.0800 | −0.29351 | 0.23314 | 307/500 | 83/50 | 18/25 | 0.61246 | 3.7137 |
| 24 | 0.1400 | −0.25109 | 0.22046 | 191/500 | 42/25 | 37/50 | 0.38043 | 3.9123 |
| 32 | 0.2200 | −0.18923 | 0.19170 | 141/1000 | 9/5 | 24/25 | 0.13896 | 4.2262 |
| 38 | 0.2801 | −0.14840 | 0.16875 | 3/1000 | 46/25 | 26/25 | 0.00165 | 4.4537 |

**The plain comparison from the same ledgers does not land** (float replay of the k_plain column: q = 0.037 / 0.032 at t = 0.29).
Design thresholds (COMPUTED, w2b3_design_a{1,0}_final.out): 1.587·10⁶ / 3.599·10⁶; the certified m_lo were chosen above them for
margin. The ledgers could be re-swept at lower m_lo (2–3 min per parity) if a thinner margin is wanted; not done.

---

## 7. Soundness checklist (WAVE5 §2)

| check | status |
|---|---|
| R-ball | all new enclosures use arguments already inside domain (u_min ≥ u0 ≥ 1.25 for Z, Z2, ψ′; A2 > 0 and Q2 > 0 now ASSERTED where y3 left them implicit); acb.polygamma on real u ≥ 0.56 |
| R-dir | G is an UPPER bound built from upper bounds of every piece (hi() throughout, fhi at the end); M_G ≤ M and the min for numc are both valid upper bounds of the respective suprema; S unchanged; the landing uses CF_i as lower, CG_i as upper, q ≤ q_i ≤ A²_i, k_i's bracket decreasing in q (H-B p.17); §2.7 shows certified G ≥ model everywhere |
| R-tail | DT2 / T2 majorants integrable: far half-line via the same Gaussian-exponential closed form (Q2 > 0), LX far tail with the explicit factor 5 under gm·τ·rate/2 ≥ 2 (checked per box, else +∞), regions IIa/IIb written out (§2.3) |
| R-split | slab seams overlap (asserted); first slab starts ≤ 10⁻⁴; bulk/tail split at u0 = 1 + δ with δ = ½ inside Rademacher's range; G1 ∪ LX at x = 10⁴ with LX valid for all x ≥ 4v₀ (§2.4) |
| R-cover | 39 ledgers per parity, each a 0-failure cover of its slab × [m_lo, 10⁸] × all x ≥ 0 (x < 0 by the reflection, which holds for G as for S) |
| R-round | CF_i, CG_i exact floats; L_lo rounded down; A²_i, λ_i, μ_i exact rationals; the bound is the upper end of an Arb ball at 128 bits |
| R-asrun | every script and output has an md5 (§9); the certifiers were edited only before the measurement runs of record (the superseded first-measurement outputs are in superseded_w2b3/) |
| R-label | CERTIFIED only for 0-failure covers + exact certificates + Arb landing; the measurement and design files are COMPUTED |
| process | live-copy check (ps, not pgrep loops) before every launch; ≤ 4 workers (2 + 2 for the sweeps); DONE files; foreground bounded waits; no /tmp |

**7.6 For bb, in order:** (i) §2.2 identity and the tail expansion of (f − m)²; (ii) §2.3 the by-parts boundary terms (signs, the
factor 5, IIb's absorption); (iii) §2.4 the LX boundary term's v-monotonicity (R − u_s ≥ ½); (iv) §2.5 δ = ½; (v) §3 the r₀/z term;
(vi) that Thm 12's statement is as transcribed (I read pp.14–17 at source this session; the transcription in §1 is mine).

---

## 8. Negative controls (all REFUSED)
w2b3_bound.py on: a copy of the odd ledgers with `n_failed = 1` in slab 5 (AssertionError); the odd Φ certificate with row 38 marked
uncertified (AssertionError); m_lo = 1 600 000 below the ledgers' m_lo (AssertionError). w2b3_phi.py on (λ, μ) = (5/2, 0) (min
coefficient −3). The first design's two rows at A² = 23/1000 and 3/1000 were REFUSED by the exact certificate although the float grid
test had passed them (§4): the grid test is not a certificate, and the plans of record never used it alone.

---

## 9. Files (~/rh-team/dq1/Z3/; md5 prefixes; all as-run)

| file (md5) | content |
|---|---|
| **w2b3_cert.py f2e56a85** (F1 applied; diff vs scripts/y3_cert.py: w2b3_cert_vs_y3_cert.diff 9d9aea74; pre-F1 adaf2ee3 archived) | G1 certifier with G (§2) |
| **w2b3_big2.py 4b780036** (N2, N3 docstring/comment only; diff: w2b3_big2_vs_y3_big2.diff 7f1ba8e6; pre e7f43d44 archived) | LX certifier with G (§2) |
| w2b3_check.py a198a5ee | bit-identity of S vs y3 (26 boxes: True) and G calibration (§2.7) |
| w2b3_measure.py f3b36538 → w2b3_meas_p35_d05_a1_m1.5e6.json 9620a633, _a0_m2.5e6.json b98ae3a5 (+ .DONE, .log) | per-slab (min S, max G) on the fixed grid, 136 slabs, 27 885 / 25 805 boxes, 632 / 590 s (COMPUTED); superseded first runs in superseded_w2b3/ |
| w2b3_design.py 7ad66fa0 → w2b3_design_a1_final.out 9f47f42d, _a0_final.out 64001424; plans w2b3_meas_…_plan_m1650000.json a2111bb6, _plan_m3700000.json ecc27b99 | the 39-slab plans with (λ_i, μ_i) optimised under the exact Φ certificate (COMPUTED); other _plan_*.json are earlier designs (not used) |
| w2b3_phi.py 797ff1d8 → w2b3_phi_a1_m1650000.json 4e72c655, w2b3_phi_a0_m3700000.json c3213386 | exact Bernstein certificates, 39 rows each, all certified (§4) |
| **w2b3_sweep.py 9efa5464** (N4: certifier md5 stamp; pre 9c5babc3 archived), w2b3_launch.py 49f7fd30 → **w2b3_cov2_a1_m1650000_s{0..38}.DONE/.json/.log (concat md5 696148f1), w2b3_cov2_a0_m3700000_s{0..38}.* (0be5d4cf)**; w2b3_launch2_a1.log 57e6af13, _a0.log 67f399fb | the covers of record (§5), F1 code |
| superseded_w2b3/prefix_F1/ (ledgers/ w2b3_cov_* d496a4f8 / feb27a07; w2b3_cert_adaf2ee3.py, w2b3_big2_e7f43d44.py, w2b3_sweep_9c5babc3.py, W2B3_memo_ec5e2fdd.md, w2b3_bound_a{1,0}_*.json, launch logs) | the pre-F1 record, SUPERSEDED |
| w2b3_bound.py 4b4ca675 → **w2b3_bound2_a1.json 87e26183, w2b3_bound2_a0.json 55c37c93** (F1 ledgers; byte-identical to the archived pre-F1 landings) | the Arb landing (§6) |
| w2b3_negctl/ | the tampered copies of §8 |

Compute: measurements of record 1 222 s + superseded measurements 1 729 s + sweeps 286 s (pre-F1) + 292 s (F1 re-issue) + designs
≈ 1 500 s + checks ≈ 200 s ≈ 5 200 s ≈ **1.45 CPU-h** (W2B3); with W2M's 0.90, 2.35 CPU-h of the 4 CPU-h budget. Peak 4 workers;
longest job 632 s; max RSS < 60 MB.
