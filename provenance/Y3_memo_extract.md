# Y3 memo, EXTRACT for the version-2 release (sections 0–5, 8 and 9)

This file is an extract of the Y3 session's memo `dq1/Y3/memo.md`, whose full md5 is
**3779ce49220e4f1c934afcfa6722037a** (720 lines; dated 2026-11-01; title "DQ-1 wave 4, agent Y3: C2 for all conductors").
The full memo is held internally by the programme. Omitted here are its §6 (the obstruction/workaround ledger and a desk-only
plan, §6.1, that was NOT RUN) and §7 (the "new assets and new blockers" ledger), which are internal dive bookkeeping and are
cited by nothing in the paper. Everything else is reproduced VERBATIM (byte for byte) at the line ranges given; nothing inside
was edited. The review REVIEW_Y3.md cites an earlier revision of the memo (fda22d9f); REVIEW_Y3_G1.md cites this revision
(3779ce49). Section numbers are unchanged.

| extract part | full-memo lines | content |
|---|---|---|
| header, §0–§5 | 1–512 | labels and sources (§1); where C2 fails below 10⁸ (§2); the all-conductor results, bands, Theorems Y3 / U1 and U2 (§3); the certifier defects B1–B4, their repairs and the C2 G1 re-run (§4); calibration (§5) |
| §8–§9 | 602–720 | the Lean statement layer (statements only; NOT built) and the file/md5 table |

The memo's own header states: "AI work by Y3 alone. Not reviewed. No operator read-back. conjecture1_proved = False. Nothing
here is progress on RH." Its §0 outcome table and §4.6 were subsequently reviewed in REVIEW_Y3 and REVIEW_Y3_G1.

---

<!-- full memo lines 1-512: header, §0-§5 -->
# DQ-1 wave 4, agent Y3: C2 for all conductors

Y3, 2026-11-01. AI work by Y3 alone. Not reviewed. No operator read-back. conjecture1_proved = False.
**Nothing here is progress on RH.** Every bound below is a bound on Λ_χ (the generalised de Bruijn–Newman constant of a real
primitive Dirichlet character). None is GRH. The method is ζ-blind by design (it is P5's C2 machinery).

Requirements: ~/rh-team/dq1/WAVE4.md (md5 1a847b4f), §4 Y3. Inputs read:
- P5/memo.md (e3676c4c): §A.1–A.13, §6, §8;
- P5 scripts tl_arb_cert.py 4a001119, tl_big.py 82333fd9, tl_big2.py cc065977, g1_sweep.py 5374c662, lx_cover.py fa243994,
  p2z_arb.py b732f0ef, c2_domain.py f84d38a1, rhi_monotone.py 66a25bab (all read to EOF; P5/ was never edited);
- the published paper's README (~/real-dirichlet-dbn-lean, v1.0.0), for the exact form of the OAI input.

Labels: **CITED-READ** (read at source this session, page given); **CITED-READ (P5)** (read at source by P5, bb-reviewed,
re-used unchanged); **PROVED** (argument written here, unreviewed); **COMPUTED** (float/mpmath); **CERTIFIED (Arb)**
(python-flint balls, outward rounding, as-run code and md5 archived); **FROM MEMORY** (never load-bearing).

Scripts and outputs: `~/rh-team/dq1/Y3/scripts/` (md5 prefixes in §9). Superseded runs are in `scripts/superseded/`.
Every job ran on one core, BLAS pinned to 1 thread. **Total compute ≈ 1.55 CPU-h**: the §4.0 defect probes added ≈ 3 CPU-min, and the C2 G1 re-run (§4.6) added 0.43 CPU-h at W = 6, the record setting the lead released (sweeps ≈ 0.67 CPU-h, of which 0.37 was
two runs killed and re-targeted; calibration ≈ 0.3 CPU-h; probes ≈ 0.08 CPU-h). Largest single job 11.5 min.

---

## 0. Outcome

| # | Target (WAVE4 §4 Y3) | Outcome |
|---|---|---|
| 1 | Locate where C2 fails, and why | **LOCATED.** The certified C2 formula crosses 9/32 at m ≈ 10^{7.83}. The binding obstruction is the q₀ = 1 initial strip: from q₀ = 1, beating 9/32 needs k ≥ 3.765. With p optimised and the *exact* t = 0 floor F, the one-step route stops at m ≈ 10^{7.03} (odd χ) / 10^{7.34} (even χ). Below that, the unconditional route cannot reach 9/32 (§2). |
| 2a | Strict improvement on 9/32 for EVERY real primitive χ | **WORKS (Arb class; uses OAI's kernel-checked 7/8, exactly as the published paper does).** For every real primitive χ of conductor 3 ≤ m < 10⁸: **Λ_χ ≤ 0.2791114** (odd; worst case m = 3), **≤ 0.2783189** (even; worst case m = 5). Both are certificate values, from the exact CF floats; the Lean-rational values in §8 are 0.2791113 and 0.2783196. Together with C2 (m ≥ 10⁸, unconditional, ≤ 0.2764282): **Λ_χ ≤ 0.27912 < 9/32 = 0.28125 for every real primitive χ.** That is a uniform constant c = 0.27912 < 9/32 (§3). |
| 2b | Ladder (better constants in the middle range) | **WORKS, conditional on OAI.** Five certified bands. Values: 0.2724 at m = 60, 0.2616 / 0.2598 at m = 400 (even / odd), 0.2424 at 10⁴, 0.2139 at 10⁶, 0.1846 just below 10⁸ (§3.4). |
| 2c | Unconditional (no OAI, no GRH) | **TWO new results.** (i) **Λ_χ ≤ 0.49330 < 1/2 for every real primitive χ.** This is uniform in m and does not use the 7/8 half-plane. It is new only in that class: with OAI's kernel-checked 7/8, the published paper's 9/32 already gives < 1/2 for every m. Without OAI, FGMPS improve ½ only for m ≤ 400 (§3.5, re-read at source). (ii) **C2's threshold lowered:** Λ_χ < 9/32 unconditionally for odd m ≥ 15 848 932 (10^{7.2}) and even m ≥ 36 307 806 (10^{7.56}). That is within 0.17 / 0.22 decades of the one-step limit in item 1 (§3.5). |
| 3 | Calibration | Siegel rule: PASS (every bound is a constant ≥ 0.18, and no rate is o(1/log m)). FGMPS: consistent; we are better on χ₅, χ₋₇, χ₋₁₁ and worse on χ₋₃, χ₋₄, χ_{±8}; for 93 characters with m ≤ 400 FGMPS keep 9/32, and we improve all of them. Published 9/32: strictly below it everywhere. Direct (mpmath) S for six actual characters sits 0.030 above the certified floor everywhere sampled (§5). |
| 4 | Soundness | **Four defects in P5's C2 certifiers: B1–B3 found by Y3, B4 found by bb (REVIEW_Y3 799a8fa8, which confirms all four).** Y3's patches are SOUND per bb. B4 was re-derived by Y3 and adopted (§4.5). **C2's LX re-run with B1–B4:** 3 069 boxes, 0 failed, worst −0.7689010122 (reproduces bb). **C2's G1 re-run with the B1 patch (§4.6): all four ledgers complete, 0 capped, 0 failed,** 67 679 leaves (the record had 440 993), worst ≥ −0.99999909, 0.43 CPU-h. So C2 is complete again (the lead's call). The B1 patch is not value-neutral: it never lowers a floor, but it raises some and certifies boxes P5 rejected (§4.0, corrected). Per-defect records are in §4.0. |

**The best all-m statement (Arb trust class; AI-written; unreviewed):**

> **Theorem Y3.** Let χ be a real primitive Dirichlet character of conductor m ≥ 3, and assume OAI's zero-free half-plane
> Re s > 7/8 for L(s, χ). This is a kernel-checked Lean theorem, used exactly as in ~/real-dirichlet-dbn-lean. Then
> **Λ_χ ≤ 0.27912 < 9/32.** More precisely, Λ_χ ≤ T_band(log(m/π)) + b/2 (§3.3–3.4), which is decreasing in m inside each band.
>
> **Without OAI:** Λ_χ ≤ 0.49330 for every m ≥ 3. Moreover Λ_χ < 9/32 for odd m ≥ 15 848 932 and even m ≥ 36 307 806.

The m ≥ 10⁸ part of each statement rests on C2. C2 is unconditional there, and after the B1–B4 re-runs (§4.5–4.6) it is
certified with the repaired code. bb's REVIEW_Y3 passes Y3's own results and reproduces them bit-identically.

---

## 1. Attack: the target and the sources

**Target (exact).** For every real primitive χ ≠ 1, the goal is Λ_χ < 9/32 strictly, or Λ_χ ≤ c < 9/32 uniformly. If neither is
possible, the goal is the best all-m statement plus the exact obstruction.

**Sources (read at source this session; page numbers are the PDF's):**
- **FGMPS 2610.27343**, CITED-READ:
  - abstract and p.6: Λ ≤ 953/3200 = 0.2978125 for 3 ≤ m ≤ 400, *unconditional*, from Platt's GRH verification;
  - p.10: Thm 2.6 (de Bruijn's strip theorem, in time-shifted form) and Thm 2.7 (for 3 ≤ m ≤ 4·10⁵ and t > 0, all but finitely
    many zeros are real and simple);
  - p.13: Prop 3.2 (zero velocity with the r₀/z term; Hermite splitting of a multiple zero);
  - pp.14–17: Remark 3.1 (the 7/8 half-plane gives D = 3/4) and Remark 3.4;
  - p.17: Lemma 3.7 (multiple zeros on iℝ split into simple imaginary zeros);
  - p.78 and Table 10 (p.89): the per-character pairs. Λ_{−3} ≤ 0.26967, Λ_{−4} ≤ 0.26, Λ₅ ≤ 0.27912, Λ_{−7} ≤ 0.28097,
    Λ_{−8} ≤ 0.26007, Λ₈ ≤ 0.26343, Λ_{−11} ≤ 0.28605. At D = 3/4, "93 characters for which the search keeps the strip bound"
    (p.78, §7.7).
- **Hakimoglu-Brown 2610.12803**, CITED-READ:
  - p.9: q′ ≤ −2 − (4q/p)S + 8q/(p² − q) for p² ≥ 5q, with its numerator factorisation;
  - pp.12–13: Thm 9 (stepped comparison; strict barriers; Hermite splitting; compact attainment), stated for an arbitrary
    initial strip q₀ and any fixed p > 0;
  - p.2: the 7/8 → q₀ = 9/16 conversion;
  - pp.13–17: Lemma 10 and Thm 12 (the derivative kernel; not used here, see §6).
- **Planat 2609.37164**, CITED-READ: pp.3–5, Thm 2.1 ((y²)′ ≤ −2 − 4y²G) and Prop 2.3 (η ≥ √5·y ⇒ G ≥ L_η/η − 2/(η² − y²)). The
  proofs use only the paired zero dynamics and the Poisson-sum identity. Nothing in them depends on p = √5 beyond η ≥ √5·y.
- **The published paper** (README of ~/real-dirichlet-dbn-lean v1.0.0), CITED-READ. OAI's
  `LFunction_ne_zero_of_seven_eighths_lt_re` covers every non-trivial Dirichlet character. With the FE this gives
  |Im z| ≤ 3/4 for the zeros of H₀^χ, i.e. q₀ = 9/16, for every real primitive χ ≠ 1.
- **Inherited, CITED-READ (P5) and bb-reviewed:** BMOR Lemma 2.1 and Lemma 5.6 (Rademacher's convexity bound), DLMF 5.15.1 / 5.7.6
  / 5.6.6, FGMPS Lemma 4.2(5), Thm 4.3 and Prop 4.18 (m-general, P5 §A.8 / A.12.1), and H-B p.11 (monotonicity of ζ, −ζ′ and −ζ′/ζ).

**Nothing FROM MEMORY is load-bearing.** One place where I first reached for DLMF 5.6.7 (FROM MEMORY) is replaced by a PROVED
lemma (Lemma Γ↓, §4.3).

---

## 2. Where C2 fails, and why (target 1)

**C2's certified formula** (P5 §A.13) is k = (4/√5)(L/4 − 1) − 2 with q₀ = 1. It crosses 9/32 at m ≈ 10^{7.833} (P5 A.8.5,
RECORD). The question is which ingredient binds.

**Exact requirement (COMPUTED, `f0_threshold.py`).** From q₀ = 1, with t_min = b = 10⁻⁴, the bound
t_min + k⁻¹log((2 + k(1 − 2t_min))/(2 + kb)) + b/2 equals 9/32 at **k = 3.76498**. Any route through the one-step comparison
from the trivial strip needs k ≥ 3.765, i.e. 4C/p − 8/(p² − 1) ≥ 3.765.

**Each candidate obstruction:**

| Candidate | Verdict | Evidence |
|---|---|---|
| the t = 0 floor F | **binding, but only through q₀ = 1** | With the exact PROVED floor F (no certifier slack) and p optimised, the threshold is m ≈ **10^{7.033} (odd) / 10^{7.336} (even)** (`f0_threshold.py`; agrees with P5 §A.5's 7.03 / 7.33). No certified floor can do better, because the floor is S ≥ F at t = 0 and P5/Y3 measure inf_x S non-decreasing in t. |
| p = √5 | **not binding** | p = √5 is forced only by p² ≥ 5q₀ with q₀ = 1. The optimum is p ≈ 2.4–2.6 near 10^{7.5}. Re-tuning to p = 5/2 alone moves the certified threshold from 10^{7.83} to 10^{7.2} / 10^{7.56} (§3.5). |
| certifier slack (CF = −1 in C2) | **costs about 0.5 decade** | C2 certified S − L/4 ≥ −1. The truth near the corner is about −0.6 to −0.85 at √5. At p = 5/2 Y3 certifies −0.55 (odd) and −0.76 (even), with measured worst values −0.538 / −0.756. |
| the contact argument (P2′ / FIN) | **not binding** | Lemma Z′ holds for all 3 ≤ m ≤ 10⁸ (§3.2), and FGMPS Thm 2.7 covers m ≤ 4·10⁵ directly. |
| the G1 domain | **not binding** | Re-parametrised and re-run for every band in under 2.5 min (§3). |

**Why q₀ = 1 is the wall (PROVED, elementary).** The one-step gain over de Bruijn is ∫_b^{q₁}[1/2 − 1/(2 + kq)]dq ≈ kq₀²/8 for
small k. From q₀ = 1 the baseline is ½, and closing the gap to 9/32 needs a gain of 0.219, i.e. k ≈ 3.8. Since
k ≤ 4F/p ≈ (L + ψ − 2Z)/p, this needs L ≳ 15–16. Below that, nothing in the one-step S-floor route reaches 9/32 from q₀ = 1.
The two exits are:
- (a) **a better strip**: q₀ = 9/16 from OAI, which turns the needed gain from 0.219 into "any k > 0" (§3);
- (b) **a better t = 0 input** than the strip, as FGMPS do with Platt's verification for m ≤ 400. That gives 0.2978, which is not
  below 9/32.

**Siegel zeros.** With q₀ = 1 a Siegel zero sits at height ≤ 1 on iℝ. That is exactly what keeps q₀ = 1 unconditionally
(P5 §F1). The obstruction is therefore Siegel-shaped, as it should be.

---

## 3. The middle range: attempts and results (target 2)

### 3.1 The idea: with q₀ = 9/16, ANY positive contraction is a strict improvement

The strip bound alone is sharp. For z² + D², Λ = D²/2 (P5 §F, PROVED), so any gain must come from extra input, and the S-floor
supplies it. From q₀ = 9/16 the one-step bound is t_min + ∫_b^{q₁} dq/(2 + kq) + b/2 < q₀/2 for every k > 0. So **the target
"strict improvement" reduces to "k > 0", i.e. S(x, p, t) > 2p/(p² − q₀) for all x and t ∈ [t_min, T].**

**Pilot (COMPUTED, `f0_landing.py`, `f0_popt.py`).** With F as the floor proxy and q₀ = 9/16, k > 0 holds for EVERY m ≥ 3 once
p is large: for m = 3 the optimum is p ≈ 20–22, k ≈ 0.06 and T ≈ 0.2789. This works because at height p the Γ-factor alone gives
S − L/4 ≈ ¼ψ((1+p)/4 + a/2) ≈ ¼log(p/4), which beats 2p/(p² − q₀) ≈ 2/p. The arithmetic enters only through the tiny
½ζ′/ζ((1+p)/2). The worst conductor is the smallest one: m = 3 (odd) and m = 5 (even).

**Obstruction met.** The gain is small, of order k·q₀²/8 ≈ 0.002 at m = 3, because k ≈ 4S/p − 8/p² ≈ log(p/4)/p is at most ≈ 0.06.
This is structural for the one-step bridge at small conductor. See §6 for the next attempt around it.

### 3.2 Components and their status

| # | Component | For Y3 | Status |
|---|---|---|---|
| 1 | Initial strip | q₀ = 9/16 (OAI 7/8 + FE), or q₀ = 1 (trivial) | CITED-READ (published paper; FGMPS Remark 3.1) |
| 2 | [0, t_min] | de Bruijn: q(t_min) ≤ q₀ − 2t_min, t_min = 10⁻⁴ | FGMPS Thm 2.6, CITED-READ |
| 3 | Transfer | Planat Thm 2.1 + Prop 2.3 with η = p ≥ √5·y (needs p² ≥ 5q₀: p ≥ 1.677 at q₀ = 9/16); H-B Thm 9, one step | CITED-READ. The generic-p form is verbatim in both sources |
| 4 | TL floor | S_χ(x, p, t) − L/4 ≥ CF on the band, for all x ∈ ℝ and t ∈ [10⁻⁴, t_hi] | **CERTIFIED (Arb)**, §3.3 |
| 5 | Confinement P2′ | H_t ≠ 0 for \|x\| ≥ 4e^{3.2·10⁵ − L}, 0.01 ≤ \|y\| ≤ 1, 10⁻⁴ ≤ t ≤ ½ | **CERTIFIED (Arb)** for 3 ≤ m ≤ 10⁸: `p2z_small.py`, 76 800 boxes, 0 failed, worst Q ≥ 0.9455. This is P5's Lemma Z′ check with the L-range moved down and Q_box unchanged (A.12.2's constants are m-general for L ≤ 100). For m ≤ 4·10⁵ FGMPS Thm 2.7 also gives it (CITED-READ) |
| 6 | Imaginary-axis / multiple contacts | velocity formula with the r₀/z term; Hermite splitting; Lemma 3.7 on iℝ | FGMPS Prop 3.2, Lemma 3.7, CITED-READ; as in C2 (P5 A.13 assembly; bb PASS) |
| 7 | Landing | T(L) = t_min + log((2 + k(q₀ − 2t_min))/(2 + kb))/k, k = 4(L/4 + CF)/p − 8/(p² − q₀), Λ ≤ T + b/2, b = 10⁻⁴ | Arb (`y3_bounds.py`, `y3_table.py`). T decreasing in k, and k increasing in L (PROVED), so each band's worst case is its lower end. Asserted T ≤ t_hi |

**Assembly.** This is C2's assembly (P5 §A.13.3) with (q₀, p, CF) per band. The one structural change is that on [t_min, T] the
barrier starts at q₁ = q₀ − 2t_min. H-B's comparison then gives q′ ≤ −2 − kq at every highest simple zero of height ≥ √b. The
height cap 8q/(p² − q) ≤ 8q/(p² − q₀) is used because q ≤ q₀ by the strip theorem.

### 3.3 The certificate: S − L/4 ≥ CF over a band, all x, all t

**Code.** These are Y3 copies of P5's certifiers, with p parametrised (env `Y3_P`, no default) and patches B1–B3 (§4):
- `y3_cert.py` (from tl_arb_cert 4a001119): G1 boxes, 0 ≤ x ≤ 10⁴;
- `y3_big2.py` / `y3_big.py` (from tl_big2 cc065977 / tl_big 82333fd9): LX, x ≥ 10⁴, v-monotone (P5 A.9.2);
- the driver `y3_sweep.py`.

**Domain handling.**
- **(R, τ)-boxes:** R = σ′ + τ²L/2, σ′ = (1+p)/2.
- **R-cover:** for each τ-slab, the R-ball is the hull of the four corners (L_lo, L_hi) × (τ₀, τ₁). R is monotone in τ for fixed L
  and monotone in L, so the corners are the extremes. This matters because L < 0 at m = 3 (L = −0.046), where R *decreases* in τ.
- **R-round:**
  - L_lo is rounded DOWN and L_hi UP; τ_lo² ≤ 10⁻⁴/2 and 2τ_hi² ≥ t_hi; all asserted in Arb.
  - S is returned through `flo` (rounded down).
  - The landing calculation uses the exact binary value of the CF float that the sweep compared against, and the Lean constants
    use rationals ≤ that float (`y3_lean_consts.py` asserts this).
- **x < 0:** by S(−x) = S(x) (PROVED: H real on ℝ and even ⇒ H(−x + ip) = conj H(x + ip) and H′(−x + ip) = −conj H′(x + ip)).

**Runs (all CERTIFIED (Arb), 0 failures, complete):**

| ledger | p | parity | conductors | t ∈ | CF certified | worst G1 / LX | certified leaves | sec |
|---|---|---|---|---|---|---|---|---|
| u20_a1 | 20 | odd | [3, 10⁸] | [10⁻⁴, 0.499] | **0.385** | 0.3903 / 1.811 | 3 672 | 40 |
| u20_a0 | 20 | even | [5, 10⁸] | [10⁻⁴, 0.499] | **0.36** | 0.3640 / 1.811 | 3 672 | 39 |
| b6_a1 | 6 | odd | [60, 2000] | [10⁻⁴, 0.3] | 0.03 | 0.0495 / 1.759 | 3 576 | 40 |
| b6_a0 | 6 | even | [60, 2000] | [10⁻⁴, 0.3] | −0.05 | −0.0334 / 1.759 | 3 779 | 44 |
| b38_a1 | 3.8 | odd | [2000, 10⁵] | [10⁻⁴, 0.3] | −0.2 | −0.1819 / 1.639 | 3 827 | 46 |
| b38_a0 | 3.8 | even | [2000, 10⁵] | [10⁻⁴, 0.26] | −0.33 | −0.3291 / 1.639 | 3 784 | 45 |
| b28_a1 | 2.8 | odd | [10⁵, 10⁸] | [10⁻⁴, 0.23] | −0.5 | −0.4998 / 1.457 | 3 795 | 46 |
| b28_a0 | 2.8 | even | [10⁵, 10⁸] | [10⁻⁴, 0.235] | −0.68 | −0.6800 / 1.457 | 7 360 | 125 |
| c25_a1 | 2.5 | odd | [15 848 932, 10⁸] | [10⁻⁴, 0.282] | −0.55 | −0.5382 / 1.351 | 3 665 | 42 |
| c25_a0 | 2.5 | even | [36 307 806, 10⁸] | [10⁻⁴, 0.282] | −0.76 | −0.7563 / 1.352 | 4 891 | 70 |

**Superseded (in `scripts/superseded/`, kept as records):**
- u20 at t_hi = 0.5: LX failed only on the last slab, τ > 0.5, outside B3's domain guard. G1 was clean;
- b38_a0 and b28_a0 at the first CF: killed after 11 min. b38_a0 failed only at τ > √(T/2), outside the needed domain;
  b28_a0 failed at true-floor values ≈ −0.62. Both were re-targeted with t_hi = the needed T and a lower CF;
- c25 at m_lo = 2.5·10⁷ / 4·10⁷: valid but weaker. Superseded by the c25 rows above.

**Pilot cost against the estimate.** The measured cost is ≈ 0.011 s per box, 40–125 s per band and parity. This is far below
P5's G1, which needed 440 993 leaves. At p ≥ 2.5 the corner where P5's margin was 0.136 does not occur, because CF is chosen
from the measured worst value.

### 3.4 The resulting bounds (Arb, `y3_table.json`; q₀ = 9/16, i.e. using OAI)

Each band gives Λ_χ ≤ (value at its lower end) on the whole band. The table shows sample conductors (the best band covering m).

| m | 3 | 4 | 5 | 7 | 8 | 11 | 12 | 59 | 60 | 400 | 2000 | 10⁴ | 10⁵ | 10⁶ | 10⁷ | 10⁸ − 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| odd χ | **0.27911** | 0.27856 | — | 0.27748 | 0.27723 | 0.27663 | 0.27646 | 0.27350 | 0.27052 | 0.25984 | 0.25038 | 0.23881 | 0.22445 | 0.20907 | 0.19533 | 0.18023 |
| even χ | — | — | **0.27832** | 0.27767 | 0.27742 | 0.27681 | 0.27665 | 0.27368 | 0.27244 | 0.26156 | 0.25319 | 0.24240 | 0.22750 | 0.21390 | 0.19937 | 0.18457 |

(No even χ has conductor 3 or 4, and no odd χ has conductor 5; the cells for other conductors with no character are kept for
the shape of the curve.)

**Uniform constant.** max(0.2791114, 0.2783189) = **0.2791114** at m = 3. These are certificate values (exact CF floats; bb's
independent mpmath landing gives 0.27911134 and 0.27831886). The Lean-rational CF = 3599/10000 gives 0.2783196 for even χ (§8).
- **Optional (bb Y3-2).** Taking min(FGMPS, Y3) per character lowers the uniform conditional constant to Y3's even m = 5 value,
  0.27832, because FGMPS's unconditional D = 1 values for χ₋₃ (0.26967) and χ₋₄ (0.26) are below Y3's. That statement would rest
  on FGMPS's Table 10, which is CITED and not reproduced here. With C2 for m ≥ 10⁸ (≤ 0.2764282), **Λ_χ ≤ 0.27912
for every real primitive χ.**

### 3.5 Unconditional results (q₀ = 1; no OAI, no GRH, no zero verification)

- **(U1) Λ_χ ≤ 0.4932941 for every real primitive χ with 3 ≤ m < 10⁸** (odd worst m = 3; even 0.4908369 at m = 5). This comes
  from the same u20 certificate (t_hi = 0.499 ≥ T = 0.4932; p = 20 ≥ √5). With C2: **Λ_χ < 1/2 − 0.0067 for every real
  primitive χ.**
  - **Novelty, checked at source (lead's item 3, 2026-11-01).**
    - FGMPS p.7–8 (CITED-READ, introduction and "previous and related contributions"): "On the upper-bound side, only the
      trivial bound Λ_L ≤ ½ from de Bruijn's argument was known. Theorem 1.1 gives the first non-trivial upper bounds for a
      Dirichlet L-function."
    - Their theorems are stated only for 3 ≤ m ≤ 400 (Thm 1.1, p.5), and for D = 1 they give 0.2978 there (p.6, §7.7).
    - Their large-x machinery (Thm 4.3, Thm 8.1, Thm 2.7) is stated for m ≤ 4·10⁵ and gives zero localisation, not a Λ bound.
      Nothing in the paper says anything about Λ_L for m > 400.
    - So **FGMPS do not imply Λ < ½ for every m.** FGMPS (m ≤ 400) together with C2 (m ≥ 10⁸, this team, unpublished) leave
      400 < m < 10⁸ at the trivial ½.
    - **Qualification.** If OAI's kernel-checked 7/8 is accepted as a theorem, then the published paper (Zenodo
      10.5281/zenodo.23840082) already gives Λ_χ ≤ 9/32 < ½ for every m, as do FGMPS's Remark 3.4 and H-B p.2 for any 7/8 input.
      So the correct claim is: **(U1) is the first all-m bound below ½ that uses no zero-free half-plane, no GRH and no zero
      verification.**
    - alphaXiv search (this session, "de Bruijn–Newman constant" × "Dirichlet L-functions", recency-weighted): the only Λ_L
      upper-bound paper is FGMPS. The other hits are about ζ (2610.12803, 2610.18214, 2609.37164), lower bounds and Newman's
      conjecture (1301.3158), or real zeros (2610.29018). This is a search result, not proof of absence.
- **(U2) C2 extended below 10⁸:** Λ_χ ≤ 0.2811138 < 9/32 for odd 15 848 932 ≤ m < 10⁸, and Λ_χ ≤ 0.2812404 < 9/32 for even
  36 307 806 ≤ m < 10⁸ (c25 bands, p = 5/2). The bound decreases in m: odd 0.2618 and even 0.2702 just below 10⁸. The one-step
  limit is 10^{7.03} / 10^{7.34} (§2), and the remaining 0.17 / 0.22 decades are certifier slack (0.09 and 0.12 below F).

---

## 4. Soundness (WAVE4 §2): three defects in P5's certifiers, found and repaired

All three are in code inherited from C2. I report them because C2 is the m ≥ 10⁸ leg of Theorem Y3.

### 4.0 Defect records (for bb's adjudication and for P5's record)

Probes: `defect_records.py` → `defect_records.out`, `b2_only_probe.py` → `b2_only_probe.out`, `lx_cover_b2only.py` →
`lx_cover_b2only.out`, `lx_fartail_probe.py`, `rbox_probe2.py`, `rbox_probe3.py`. All import P5's files read-only, or build a
patched copy in memory.

**B1. Bulk majorant uses a negative Z (R-box).**
- **File:line (P5/scripts):** tl_arb_cert.py:64 (g_lo = lo(g₀)), :77 (Zs = Z_up(umin)), :81 (Z_up(u) in D1); tl_big2.py:28
  (gs = lo(…)), :32 (Ulo).
- **Failing inputs:**
  - floor_box(Rb = [5.2424, 5.2434], τ = [0.0926, 0.1019], x = [0, 0.5], a = 0). 11 bulk cells have lo(u) < 1; cell 0 has
    lo(u) = 0.848 and Z_up = −7.18.
  - **P5's own C2 G1 initial remainder boxes** (g1_sweep.initial_boxes('rem'), 4 576 boxes): of 300 sampled (seeded), 299 reach
    u < 1 in the bulk, and 206 (box, parity) pairs are certified at K0 = 1 by P5's code. Example: box 755,
    R = [2.0822, 2.5445], τ = [0.015142, 0.016657], x = [2, 4], u_min = 0.658, floor −0.4090 (a = 0).
- **Why the old enclosure is invalid:**
  - At a fixed (R, τ) in the box the bulk is g ≥ (u₀ − R)/τ, i.e. Re w ≥ u₀. But one cell ball spans every τ in the box, so a
    bulk point at τ_lo shares a cell with points where Re w < 1 at τ_hi, and its majorant uses Zs = Z_up(lo u).
  - For σ ∈ (0, 1), ζ(σ) < 0 and ζ′(σ) < 0, so Z_up = −ζ′/ζ(lo u) < 0.
  - Then e(g) = (τ|g|)²M/2 + τ|g|·Zs can be negative, and (e^e − 1)w < 0 is ADDED to I_a (and Z_up(u) < 0 to D1). The claim
    |∫(e^r − 1)φ| ≤ I_a is therefore not established.
  - In big2 the same cells give lzeta_up(Ulo) = NaN, so rL = NaN, Ie = NaN and the box is rejected. So B1 is **fail-safe in
    big2, but not in floor_box.**
- **Does it affect a certificate value? It affects validity, and the patch is NOT value-neutral.** (Correction after bb
  REVIEW_Y3 §1; this replaces "effect 0".)
  - The patch never LOWERED a floor in any measurement: Y3's 1 + 206 + 287 boxes and bb's 800 pairs.
  - It RAISES some floors: on 10 of bb's 443 pairs where both are finite, by up to +5.0·10⁻⁴ (box 3228: 1.1503696 → 1.1503793).
  - It also certifies boxes that P5's code rejected: 197 of bb's pairs went from −∞ to finite. Cells with lo u ∈ (1, u₀) gave P5
    a near-pole Z_up, and the clamp at u₀ removes it.
  - My "bit-identical on all 206" holds for my sample and is not general.
  - Consequence: a B1-patched G1 needs far fewer leaves. That is what the re-run shows (§4.6).

**B2. Bulk-mass lower bound has the wrong direction (R-box).**
- **File:line:** tl_big2.py:72, Pb = lo(1 − erfc(−gs/√2)/2) with gs = lo(…) from :28.
- **Failing input:** big2(Rb = [1.70, 1.80], τ = [0.300, 0.309], v₀ = 2500). Here gs ∈ [−2.4220, −2.3515], so the mass gap is
  ≤ 1.63·10⁻³.
- **Why the old enclosure is invalid:**
  - At a fixed τ the bulk is g ≥ g_s(τ) = (u_s − Uc₂)/τ, and lo(gs) ≤ g_s(τ).
  - Pb enters den = Pb − Ie − T0 as a LOWER bound for the bulk mass P(g ≥ g_s(τ)). But P(g ≥ lo(gs)) ≥ P(g ≥ g_s(τ)), so it
    is an upper bound.
  - So den is overestimated, K is underestimated, and the floor comes out too high.
- **Does it affect a certificate value? Yes, but negligibly for C2.**
  - B2 alone (P5 code with only the Pb fix, `b2_only_probe`) changes:
    - the example by −0.0200;
    - R = [1.62, 1.70], τ = [0.100, 0.103] by −5.4·10⁻⁶;
    - R = [1.618, 1.620], τ = [0.300, 0.309] by −0.149. That box lies outside C2's domain (there L ≈ 0.04).
  - **C2's whole LX cover with B2 only:** 3 069 boxes, 0 failed, worst −0.7689010038, against P5's −0.7689010032
    (`lx_cover_b2only.out`). C2's stated LX constant, −0.77, is unaffected.

**B3. LX far-tail majorant is not integrable.**
- **File:line:** tl_big2.py:96 (c₁ ∋ sp/vM), :128 (rate), :136 (T0 += 2q(U_MIN)/rate); memo A.9.2(f) and memo line 841.
- **Failing input:** the big2 majorant at R = 2.4, τ = 0.3, v₀ = 2500 (`lx_fartail_probe.py`):

  | U | −10⁴ | −10⁵ | −10⁶ | −10⁷ |
  |---|---|---|---|---|
  | log q(U) | −2.03·10⁵ | −1.13·10⁶ | **+7.87·10⁷** | +9.79·10⁹ |

- **Why the old proof step is invalid:**
  - The far tail ∫_{−∞}^{U_MIN} q is bounded by 2q(U_MIN)/rate, on the claim that d log q/dU ≥ rate for all U < U_MIN.
  - But the majorant's c₁ contains sp/vM = (1 − U + a)/(2v₀), which is unbounded as U → −∞.
  - After the sup over ℓ = log v the Gaussian U² terms cancel exactly, so log q ~ +(1 − U)²/(4v₀) and the majorant is not
    integrable. The slope claim is false for U ≲ −v₀p/τ².
  - Separately, the rate omits a −2/(ℓ₀τ²) term. The factor 2 covers it for p ≥ 0.51.
- **Does it affect a certificate value? No, only the proof text.**
  - The repaired region-II terms are ≤ q(U_MIN)·e^{−s_I(U_MIN − 1 + v₀) + v₀/2} ≲ q(U_MIN)·e^{−15 000} (IIa), and
    ≤ e^{B₀ − v₀²/(16τ²)} ≤ e^{B₀ − 2.8·10⁶} (IIb).
  - With all three patches, the LX values match P5's to the printed digits (worst −0.7689010031).

**Repairs (§4.1–4.3):**
- B1: clamp the real-part lower bound at u₀ (u_s in big2), PROVED valid; marked "Y3 B1" in y3_cert.py and y3_big2.py.
- B2: compute Pb from hi(gs); "Y3 B2" in y3_big2.py.
- B3: a three-region tail argument using Lemma Γ↓; "Y3 B3" in y3_big2.py.

### 4.1 B1 (R-box): bulk majorants used outside their domain

- **Where:** P5 tl_arb_cert.py:64,77,81; tl_big2.py:28,32.
- **The defect:**
  - The bulk Riemann sum starts at g₀ = lo((u₀ − R)/τ) over the (R, τ)-ball.
  - Inside one box, u = R + τg can then fall below u₀ = 1 + δ, and even below 1. Those points are tail points at their own τ.
  - There `Z_up(u)` (the −ζ′/ζ table) returns a NEGATIVE number, so the "majorant" e(g) is invalid and can make (e^e − 1) < 0.
- **Probe (`rbox_probe2.py`):** of 191 random P5-domain boxes whose bulk reaches u < 1, P5's floor_box returned a finite floor on
  26.
- **Repair (Y3 B1, PROVED):**
  - At each τ the bulk is exactly {Re w ≥ u₀}. Clamping the real-part lower bound at u₀ is valid on bulk points and harmless
    elsewhere, because the majorant stays ≥ 0 and the bulk is over-covered.
  - In big2, the clamp is at u_s. In floor_box, D₀ already uses hi(g₀) for the cut mass, so it is correct.
- **Effect (`rbox_probe3.py`):** on 287 random boxes (24 of them reaching u < 1), max(P5 floor − Y3 floor) = 0.0, so the patch
  never lowered a floor. It does raise floors elsewhere: see the corrected statement in §4.0 (bb REVIEW_Y3 §1).
- **C2's G1 has now been re-run with B1 (§4.6): every box passes.**

### 4.2 B2 (R-box): the bulk mass bound has the wrong direction (LX)

- **Where:** P5 tl_big2.py:72.
- **The defect:** Pb = P(g ≥ lo(g_s)) is used as a LOWER bound for P(g ≥ g_s(τ)). But g_s(τ) ≥ lo(g_s), so this is an upper
  bound.
- **Size:** about φ(g_s)·Δg_s. Measured ≤ 1.6·10⁻³ in Pb at τ ≈ 0.3, R ≈ 1.75 (§4.0).
- **Repair:** use hi(g_s).
- **Re-run of C2's LX with B1 + B2 + B3** (`lx_cover_p5patched.py`; the B1–B3 output d0f05b64 is now in scripts/superseded/, and the B1–B4 output is 5aa52aef, §4.5): **3 069 boxes, 0 failed, worst
  −0.7689010031**, against P5's −0.7689010032. With B2 alone: worst −0.7689010038. B2 lowers values and the valid B1 clamp
  raises them. C2's LX statement (S ≥ L/4 − 0.77) stands.

### 4.3 B3: the far-far tail majorant of LX is not integrable

- **Where:** P5 tl_big2.py:96,128,136; memo A.9.2(f) and line 841.
- **The defect:**
  - The closed-form sup-over-v majorant contains c₁ ∋ s₁/(2v₀) with s₁ = 1 − U.
  - After the sup over ℓ = log v, the quadratic Gaussian term cancels exactly, so log q(U) ~ +s₁²/(4v₀) as U → −∞.
  - The claimed slope bound "d log q/dU ≥ rate" therefore fails for U ≲ −10⁴.
- **Probe (`lx_fartail_probe.py`):** log q(−10⁶) = +7.9·10⁷ at R = 2.4, τ = 0.3. The majorant diverges, so the step
  "∫_{−∞}^{U_MIN} ≤ 2q(U_MIN)/rate" has no proof as written. The true integrand is tiny. This is a proof gap, not a wrong
  number.
- **Repair (PROVED; coded in y3_big2 as B3). Split U < U_MIN into three regions:**
  - **Region I, s₁ ≤ v₀.** Here sp/v₀ = (s₁ + a)/(2v₀) ≤ (v₀ + a)/(2v₀) ≤ 0.5002 (this uses a ≤ 1 and v₀ = 2500; bb nit B3-b) and
    A/(2v₀) ≤ 0.25 + 1/(2v₀ℓ₀) ≤ 0.2501, so the true slope is ≥ (p − 2/ℓ₀)/τ² − (c₁ᵇ + 0.5002 + c₂)/2
    − 0.2501. The code checks in Arb that this is ≥ rate/2, and that 2/(τ·rate) ≤ g_m + τP_b. Then P5's factors 2 and 4 cover
    region I. (P5's rate also omitted a −2/(ℓ₀τ²) term; the factor 2 absorbs it whenever p ≥ 4/ℓ₀ ≈ 0.51.)
  - **Region IIa, v ≥ s₁ > v₀.** Here c₁ ≤ c₁ᵇ + 1. The majorant restarted at U = 1 − v₀ costs at most e^{(v₀ − R)/2 + 1/ℓ₀}. It
    is multiplied by e^{−s_I(U_MIN − 1 + v₀)}, which is about e^{−16000} or smaller. The decay slope s_IIa > 1 is checked in
    Arb.
  - **Region IIb, v < s₁.** Gaussian domination. Writing −log|Γ_a(c)| needs a lower bound for |Γ| at height v, which is
    **Lemma Γ↓ (PROVED from DLMF 5.7.6):** for x ≥ ½, log|Γ(x+iy)| ≥ log Γ(x) − π|y|/2 − ½log(1 + 4y²).
    - Proof: d/dy log|Γ(x+iy)| = −Im ψ(x+iy) = −Σ_k y/((x+k)² + y²) (5.7.6). Integrating gives
      log|Γ(x+iy)| − log Γ(x) = −½Σ_k log(1 + y²/(x+k)²).
    - For x ≥ ½ the sum is ≤ ½log(1+4y²) + ∫_0^∞ ½log(1 + y²/s²)ds = ½log(1+4y²) + π|y|/2. ∎
    - With |Γ(σ+iy)| ≤ Γ(σ) (5.6.6), log Γ(y) ≤ y log y (FGMPS 4.2(5)) and |L(1−w)| ≤ ζ(2), this gives
      log q ≤ B₀ − s₁²/(8τ²) for s₁ ≥ 2500, when τ ≤ ½, R ≥ 1 and R − σ′ ≤ 400 (all checked in code).
    - Contribution: ≤ e^{B₀ − v₀²/(16τ²)}.
    - **The T₁ multiplier (bb nit B3-a).** T₁'s integrand carries (|g′| + τ|β|)/τ, where |β(v)| ≤ P(v) + Z₁ grows like ½log v,
      and v < s₁ in IIb. So the multiplier is ≤ (s₁ + R + 1)/τ² + (½log(2s₁) + 3)/τ, which grows only polynomially in s₁. It is
      absorbed by the same slack (e^{−s₁²/(16τ²)} × multiplier ≤ 1 for s₁ ≥ 2500, τ ≤ ½), which is why the code adds the same e^{…}
      to T0 and T1.
- **Effect:** none measurable (LX re-run above). The C2 LX lemma now has a complete tail argument.

### 4.5 B4 (found by bb, REVIEW_Y3 §4): the bulk sum's lower limit in big2. Re-derived by Y3 and adopted

**Re-derivation (PROVED; independent of bb's text, then compared with bb_big2_b4.py a410901b line by line).**
- **The exact weight after the shift.** Shift g → g + κ with κ = τ(β₁ + β₂) in D = ∫Φ(c + τg)φ(g)dg. This gives
  D = ∫Φ(c₂ + τg)φ(g)e^{−κg − κ²/2}dg.
  - Write Φ(w) = Γ_a(c)L(c₁)·exp((w − c)β₁ + r_Γ + (w − c₁)β₂ + r_L).
  - Then (w − c)β₁ + (w − c₁)β₂ = τg(β₁ + β₂) + τ²(β₁² + β₁β₂ + β₂²). The τg term cancels e^{−κg}, and the constant becomes
    τ²(β₁² + β₂²)/2.
  - So **the weight on w = c₂ + τg is exactly the real φ(g)**, and Re w = Re c₂ + τg.
- **The split.** The U-tail and the by-parts boundary term are at Re w = u_s, so the bulk is g ≥ g* = (u_s − Re c₂)/τ.
  - Re c₂ = R + τ²(Re β₁ + Re β₂) ≥ Uc₂, but it has no upper bound in xaware mode: Re β₁ ≥ ½(log v − γ − 1/(2v)) → ∞.
  - Hence g* ≤ (u_s − Uc₂)/τ, and g* < lo g_s is possible. The set [g*, lo g_s) is in neither the Riemann sum (which starts at
    lo g_s) nor the U-tail (Re w ≥ u_s there). **bb's B4 is confirmed.**
- **The majorants on the gap, uniform in v ≥ v₀:**
  - **Real part:** u_s ≤ Re w < Re c₂ + τ·lo g_s ≤ Re c₁ + τ²Z₁ + τ·lo g_s. This is < Re c₁ iff τZ₁ + lo g_s < 0; the code guards
    this and returns −∞ otherwise.
  - **h_Γ = w − c:**
    - Re(w − c) ∈ [u_s − R, τ²(Re β₁ + Re β₂) + τg) and g < 0, so |Re| ≤ max(R − u_s, τ²(P₁ + Z₁)).
    - |Im| = τ²|Im(β₁ + β₂)| ≤ τ²I.
    - P₁ is |β₁| at v₀. For v > v₀ the combinations |h_Γ|²M and |h_Γ|M are non-increasing by P5 A.9.2(d): P²M and PM decrease,
      and (a + b)²M expands into such terms.
  - **r_Γ:** |r_Γ| ≤ |h_Γ|²M/2, with M = sup|ψ_a′| on the segment [c, w]. Its real parts are ≥ min(Re w, R) ≥ u_s, so
    M ≤ M_up((u_s + a)/2, v_m).
  - **r_L = log L(w) − log L(c₁) − (w − c₁)β₂:**
    - |log L(σ + it)| ≤ log ζ(σ) for σ > 1 (P5 A.8 item 3), and |β₂| ≤ Z(Re c₁).
    - |w − c₁| ≤ (Re c₁ − Re w) + τ²|Im β₂| ≤ (u − u_s) + τ²Z₁, with u = Re c₁ ≥ Rc₁.
    - So |r_L| ≤ log ζ(u_s) + log ζ(Rc₁) + sup_{u≥Rc₁}(u − u_s + τ²Z₁)Z(u).
    - The sup is taken on a 0.01-grid, where each cell uses Z at its left end (Z decreasing) and the linear factor at its right
      end.
    - For u ≥ 60: Z′(u) = −Σ Λ(n)log n·n^{−u} ≤ −log 2·Z(u), so d/du[(u − c)Z(u)] ≤ Z(u)(1 − (u − c)log 2) < 0 once
      u − c ≥ 1/log 2. Here c = u_s − τ²Z₁ < 1.3, so (u − c)Z(u) is decreasing on [60, ∞) and its value at 60 bounds the tail.
      (bb states this as Z(u) ≤ 2^{60−u}Z(60); my monotonicity argument is what the code's single evaluation at 60 needs.)
  - **Numerator:** |(Φ′/Φ)(w) − β| ≤ |h_Γ|M + |L′/L(w)| + |L′/L(c₁)| ≤ |h_Γ|M + Z(u_s) + Z₁.
  - **Mass:** the gap at height v is [g*(v), lo g_s(v₀)) ⊂ (−∞, lo g_s), so its φ-mass is ≤ Φ(lo g_s) for every v.
  - So the gap contributes ≤ e^{C_g}·Φ(lo g_s) to the bulk modulus and ≤ e^{C_g}·num_g·Φ(lo g_s) to the numerator. Adding these to
    Ie and Nb is exactly bb's term.
- **Adoption.** The adopted code is in y3_big2.py ("Y3 B4"). It is identical to bb_big2_b4.py except for bb's diagnostic `GAP`
  dict and comments (diff archived: scripts/y3_big2_vs_bb_b4.diff).
- **Re-run for the record.** C2's LX (`lx_cover_p5patched.py` → `.out` 5aa52aef) gives **3 069 boxes, 0 failed, worst
  −0.7689010122**, which reproduces bb. The pre-B4 output d0f05b64 is kept in scripts/superseded/.
- Y3's band ledgers: bb re-swept all ten bands with B4 and they are bit-identical, including worst_lx (REVIEW_Y3 §4). I did not
  re-run them.
- **Effect:** proof step only; no stated constant changes.

### 4.6 The C2 G1 re-run with the B1-patched certifier (released by the lead after REVIEW_Y3; bb conditions G-1 to G-4)

**Setup** (`~/rh-team/dq1/Y3/g1_rerun/`, a new directory; P5/ untouched; md5s below):
- **Code:** y3_cert.py 5b375c5b + y3_big.py aa232458 (copies with identical md5), with `Y3_P=sqrt5` exported by `run_all.sh`
  before the pool starts. c2_domain.py f84d38a1 is unchanged.
- **Driver:** g1_sweep_y3.py a591107d, a copy of P5's g1_sweep.py 5374c662 changed only at line 85:
  `from tl_arb_cert import floor_box, iv` → `from y3_cert import floor_box, iv`. The archived `g1_sweep_y3.diff` (0bd7810a)
  shows exactly that one line.
- **Jobs:** the record's four, with the record's parameters: corner a0 and a1 at cap 300 s, rem a0 and a1 at cap 240 s, W = 6,
  K0 = 1, depth cap 30, budget 1 750 s per job; the same initial_boxes, seeded order and classify_rem drops. They ran
  sequentially (run_all.sh e186b662), with BLAS pinned to 1 thread per worker.
- **Timestamps:** the run straddled the US DST fall-back (01:59 EDT → 01:00 EST on 2026-11-01). Files show 01:56–01:59 and then
  01:00; the order is corner a0, corner a1, rem a0, rem a1.

**Result: PASS (G-3).** Every ledger is complete, attempted = completed = initial, capped 0, failed 0.

| ledger | initial | attempted / completed | capped | failed | evaluations | certified leaves (record) | dropped out / stl / above / corner | worst | max depth | wall s |
|---|---|---|---|---|---|---|---|---|---|---|
| y3g1_corner_a0 | 320 | 320 / 320 | 0 | 0 | 5 538 | 2 929 (3 021) | 0 / 0 / 0 / 0 | −0.9999656033 | 10 | 12.6 |
| y3g1_corner_a1 | 320 | 320 / 320 | 0 | 0 | 378 | 349 (383) | 0 / 0 / 0 / 0 | −0.9988738033 | 3 | 1.0 |
| y3g1_rem_a0 | 4 576 | 4 576 / 4 576 | 0 | 0 | 74 495 | 37 065 (224 903) | 4 384 / 69 / 0 / 488 | −0.9999990867 | 17 | 152.9 |
| y3g1_rem_a1 | 4 576 | 4 576 / 4 576 | 0 | 0 | 50 165 | 27 336 (212 686) | 0 / 69 / 0 / 0 | −0.9999363845 | 8 | 93.1 |

- **Total ≈ 0.43 CPU-h** (wall × 6 workers), against 2.9 CPU-h for the record and a 3 CPU-h cap.
- **Leaves:** 67 679 in total, against the record's 440 993. bb predicted fewer leaves (REVIEW_Y3 §1, G-3), and the cause is
  the B1 clamp: P5's near-pole Z_up on cells with lo u ∈ (1, u₀) forced deep bisection that the patched certifier does not need.
  bb's leaf spot-check saw the same, e.g. box 4002 went from 255 evaluations to 1.
- **All worst values are ≥ −1 = −K0,** so the G1 floor S − L/4 ≥ −1 of C2's statement of record (P5 §A.13 row 4a) is now
  certified with a B1-valid certifier.

**md5s** (g1_rerun/):

| ledger | DONE | json | log |
|---|---|---|---|
| y3g1_corner_a0 | 79194715 | 01a9cf7a | a35795d6 |
| y3g1_corner_a1 | 0c5a24e4 | de50ff39 | 719fc681 |
| y3g1_rem_a0 | 43e1f9bc | f1a620e6 | 43d86eb0 |
| y3g1_rem_a1 | f630953b | 37d25be4 | ca8c9341 |

The four .unfinished.json files are all the empty list (d7517139).

**C2 status (G-6).** G1 (B1-patched, this re-run), LX (B1 + B2 + B3 + B4, `lx_cover_p5patched.out` 5aa52aef, worst −0.7689010122)
and STL together meet the constants of the C2 statement of record (S ≥ L/4 − 1, S ≥ L/4 − 0.77, and 0.2764282 at 10⁸). On
this evidence **C2 is complete again** in the Arb trust class. Re-closing it is the lead's call. P5's record should cite
y3_cert and these ledgers for row 4a, and y3_big2 (aafeba32) for row 4b.

### 4.4 The other checklist items

| Item | Status |
|---|---|
| R-round | Every bound is outward. CF floats are used exactly. Lean rationals are ≤ the floats (asserted). m-edges are rounded outward (asserted). |
| R-cover | Four-corner R-hull. τ-slabs are contiguous from τ_lo to τ_hi (the loop sets tau = tb). The x-grid is contiguous. LX covers x ≥ 10⁴ by v-monotonicity (P5 A.9.2, inherited; its parts (b)–(g) are bb-read, not re-derived; (e) needs R ≥ σ′ > 1 + δ, true for every band). |
| R-vac | No Telperion `prove` was run. The Lean layer in §8 has no universal binder over a failing range: every L is bounded below by the band's conductor, and T ≤ t_hi is a hypothesis of the transfer. |
| R-prec | No integrals in §8 except through C2's H. |
| R-asrun | All as-run scripts and outputs have md5s (§9). y3_big2 was edited (τ cap 0.4 → 0.5) after the first LX re-run, so that re-run was repeated with the final code: same numbers, `.out` d0f05b64. After B4 was adopted (y3_big2 aafeba32) it was re-run again: `.out` 5aa52aef. |
| R-label | Float pilots (f0_*, s_direct) are labelled COMPUTED. Only ledgers with 0 failures are called CERTIFIED. |

---

## 5. Calibration (target 3)

- **Siegel sanity rule: PASS.** The conditional bounds are constants in [0.18, 0.2791] on m < 10⁸, and the unconditional ones
  lie in [0.26, 0.4933]. They decrease no faster than k ∝ L/p allows (≥ loglog m/log m shape, via C2). Nothing is o(1/log m).
  Under q₀ = 1 a Siegel zero is admitted at height ≤ 1, and the bound stays ≥ 0.26.
- **FGMPS (m ≤ 400): consistent.** Both are upper bounds, so no contradiction can arise. The comparison per character
  (FGMPS D = 1, unconditional, against Y3, conditional on OAI):

  | χ | FGMPS | Y3 |
  |---|---|---|
  | χ₋₃ | 0.26967 | 0.27911 |
  | χ₋₄ | 0.26 | 0.27856 |
  | χ₅ | 0.27912 | **0.27832** |
  | χ₋₇ | 0.28097 | **0.27748** |
  | χ₋₈ | 0.26007 | 0.27723 |
  | χ₈ | 0.26343 | 0.27742 |
  | χ₋₁₁ | 0.28605 (> 9/32; at D = 3/4 FGMPS keep 9/32) | **0.27663** |

  The two methods are complementary. Taking the minimum per character improves both.
- **Published 9/32:** strictly below it for every χ.
- **Direct computation (COMPUTED, `s_direct.py` → `s_direct.out`).**
  - Method: S_χ(x, 20, t) for χ₋₃, χ₋₄, χ₅, χ₋₇, χ₈ and χ₋₁₁, from the exact Gaussian-tilt identity (mpmath, 24-node
    Gauss–Hermite), on t ∈ {10⁻⁴, .15, .3, .49} × x ∈ {0, 2, 4, 6, 10, 30}.
  - Result: min(S − L/4) = 0.41470–0.41517 (odd) and 0.39000–0.39024 (even). That is **0.030 above the certified CF**
    everywhere, and equal to F − L/4 to 10⁻³.
  - So the certificate is tight (worst certified 0.3903 / 0.3640 against the truth ≈ 0.415 / 0.390), and the p = 20 route is
    at its structural limit (§3.1).
- **Zoo fakes.**
  - z² + D² and FGMPS's Remark 3.4 quartic have inf_x S(x, p, t) = 0 (S ~ 2p/x²), so k = −8/(p² − q₀) < 0 and the method gives
    nothing. That matches the sharp Λ = D²/2: the strip-only fake is not "improved".
  - DH violates the inputs used: the Euler product in |L′/L| ≤ −ζ′/ζ and |L| ≥ ζ(2σ)/ζ(σ), and the strip, since DH has zeros
    in σ > 1. So DH is outside the theorem's class, as for C2.
  - The other zoo items (EP5, the 2/5 function, Leech, Z1, Z2, F₃[T], Knopp) are not degree-1 Dirichlet-type FE objects with
    |Λ(n)χ(n)| ≤ Λ(n) and a q₀ ≤ 9/16 strip, so they are not in scope. Not run.
  - The method is ζ-blind and twist-blind by construction (F5/F6 FAIL as an RH input, by design, exactly as C2).

---


<!-- full memo lines 602-720: §8-§9 -->
## 8. Lean statement layer (statements only; nothing built; for the lead via leanlock + Comparator)

These reuse the C2 namespace definitions of P5 §A.13.4 (H, S, Lc, parity, IsRealChar). Cited inputs enter as hypotheses or
axioms, as in C2. The two pure-real-analysis items are the natural first targets.

```lean
import Mathlib

open Complex

noncomputable section

namespace Y3

/-- the one-step landing time of H-B Thm 9 from squared height q1 at time tmin down to b, rate k -/
def landing (tmin q1 b k : ℝ) : ℝ := tmin + Real.log ((2 + k * q1) / (2 + k * b)) / k

def kY3 (p CF q0 L : ℝ) : ℝ := 4 * (L / 4 + CF) / p - 8 / (p ^ 2 - q0)

def boundY3 (p CF q0 L : ℝ) : ℝ :=
  landing (1 / 10000) (q0 - 2 / 10000) (1 / 10000) (kY3 p CF q0 L) + 1 / 20000

/-- pure real analysis: the landing time is antitone in the rate (it is ∫_b^{q1} dq/(2+kq)) -/
theorem landing_antitone (tmin q1 b k₁ k₂ : ℝ) (hb : 0 < b) (hbq : b ≤ q1) (hk : 0 < k₁) (hk12 : k₁ ≤ k₂) :
    landing tmin q1 b k₂ ≤ landing tmin q1 b k₁ := by
  sorry

/-- pure real analysis: the uniform constants. These are the Lean-rational values 0.2791113 / 0.2783196 (`y3_lean_consts.py`,
    CF = 385/1000 and 3599/10000); the certificate values with the exact CF floats are 0.2791114 / 0.2783189 -/
theorem boundY3_odd_le (L : ℝ) (hL : Real.log (3 / Real.pi) ≤ L) :
    boundY3 20 (385 / 1000) (9 / 16) L ≤ 27912 / 100000 := by
  sorry

theorem boundY3_even_le (L : ℝ) (hL : Real.log (5 / Real.pi) ≤ L) :
    boundY3 20 (3599 / 10000) (9 / 16) L ≤ 27833 / 100000 := by
  sorry

/-- pure real analysis: the unconditional constants (0.4932941 / 0.4908369) -/
theorem boundY3_uncond_odd_le (L : ℝ) (hL : Real.log (3 / Real.pi) ≤ L) :
    boundY3 20 (385 / 1000) 1 L ≤ 4934 / 10000 := by
  sorry

theorem boundY3_uncond_even_le (L : ℝ) (hL : Real.log (5 / Real.pi) ≤ L) :
    boundY3 20 (3599 / 10000) 1 L ≤ 4909 / 10000 := by
  sorry

/-- Lemma Γ↓ (memo §4.3), PROVED from DLMF 5.7.6 -/
theorem gamma_norm_lower (x y : ℝ) (hx : 1 / 2 ≤ x) :
    Real.log (Real.Gamma x) - Real.pi * |y| / 2 - Real.log (1 + 4 * y ^ 2) / 2 ≤
      Real.log ‖Complex.Gamma (x + y * I)‖ := by
  sorry

/-- the TL floor at p = 20 (Arb certificate u20_a1 / u20_a0: G1 ∪ LX) -/
theorem TL_floor_p20 {m : ℕ} [NeZero m] (χ : DirichletCharacter ℂ m)
    (hm3 : if C2.parity χ = 1 then 3 ≤ m else 5 ≤ m) (hm : m < 10 ^ 8)
    (hprim : χ.IsPrimitive) (hreal : C2.IsRealChar χ) (t x : ℝ) (ht : 1 / 10000 ≤ t ∧ t ≤ 499 / 1000) :
    C2.Lc m / 4 + (if C2.parity χ = 1 then 385 / 1000 else 3599 / 10000) ≤ C2.S χ x 20 t := by
  sorry

/-- Theorem Y3 (memo §0), conditional on the 7/8 half-plane exactly as in the published paper -/
theorem Y3_all_conductors {m : ℕ} [NeZero m] (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive) (hne : χ ≠ 1)
    (hreal : C2.IsRealChar χ)
    (hOAI : ∀ s : ℂ, 7 / 8 < s.re → DirichletCharacter.LFunction χ s ≠ 0) :
    ∀ t : ℝ, 27912 / 100000 ≤ t → ∀ z : ℂ, C2.H χ t z = 0 → z.im = 0 := by
  sorry

/-- (U1), unconditional -/
theorem Y3_uncond_half {m : ℕ} [NeZero m] (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive) (hne : χ ≠ 1)
    (hreal : C2.IsRealChar χ) :
    ∀ t : ℝ, 4934 / 10000 ≤ t → ∀ z : ℂ, C2.H χ t z = 0 → z.im = 0 := by
  sorry

/-- (U2), unconditional, below 10^8 (c25 bands); the bound is < 9/32 -/
theorem Y3_uncond_below_9_32 {m : ℕ} [NeZero m] (χ : DirichletCharacter ℂ m) (hprim : χ.IsPrimitive)
    (hreal : C2.IsRealChar χ)
    (hm : (C2.parity χ = 1 ∧ 15848932 ≤ m) ∨ (C2.parity χ = 0 ∧ 36307806 ≤ m)) :
    ∀ t : ℝ, 28125 / 100000 - 1 / 10 ^ 6 ≤ t → ∀ z : ℂ, C2.H χ t z = 0 → z.im = 0 := by
  sorry

end Y3
```

Notes for the build:
- **The two constants under (U2):** 0.2811138 (odd) and 0.2812404 (even).
  - 9/32 − 10⁻⁶ = 0.281249, which is above the even value 0.2812404, so the stated t-threshold is valid for both parities.
  - For m ≥ 10⁸, `Y3_uncond_below_9_32` follows from C2 (≤ 0.2765).
- **`hne`:** χ ≠ 1 is redundant given m ≥ 3, but it mirrors the published theorem.
- **TL_floor_p20 is stated for t ≤ 0.499 and for the certified conductor floor per parity (odd m ≥ 3, even m ≥ 5), so no
  binder ranges over an uncertified point** (R-vac). The parity convention is P5's (`parity = 1` ⇔ odd).
- **Unconditional constants per parity:** 0.4932941 (odd, CF 385/1000) and 0.4908369 (even, CF 3599/10000). Using the even CF at
  m = 3 would give 0.4939 > 0.4934, so the two lemmas are kept separate.
- **`hOAI`:** discharged by OAI's `LFunction_ne_zero_of_seven_eighths_lt_re` (published paper, step 7).
- **Cited ingredients (FGMPS Thm 2.6 / 2.7 / Prop 3.2 / Thm 4.3 / Prop 4.18, Planat Thm 2.1 / Prop 2.3, H-B Thm 9) enter as
  axioms or hypotheses, as for C2.** The lead decides which.

---

## 9. Files (Y3/scripts; md5 prefixes)

| script | output | content |
|---|---|---|
| y3_big.py aa232458, y3_big2.py aafeba32 (B1–B4; the band sweeps ran with a8f10bcd = B1–B3, and bb re-swept every band with B4: bit-identical), y3_cert.py 5b375c5b | — | P5 certifiers, p-parametrised, with patches B1–B4 (diffs: §4; `diff` against P5/scripts reproduces them) |
| y3_big2_vs_bb_b4.diff 5dd60367 | — | adopted B4 against bb_big2_b4.py a410901b: only bb's diagnostic dict differs |
| g1_rerun/: g1_sweep_y3.py a591107d (+ .diff 0bd7810a), run_all.sh e186b662, c2_domain.py f84d38a1, y3_cert.py 5b375c5b, y3_big.py aa232458 | y3g1_corner_a0/a1, y3g1_rem_a0/a1 .DONE 79194715 / 0c5a24e4 / 43e1f9bc / f630953b | C2 G1 re-run (§4.6) |
| y3_sweep.py 129799ab | u20_a0/a1.DONE 953e869c / 4a1c199c (.json 9886ba5f / 32e89db4); b6_a0/a1 c2968d17 / 395e9b98; b38_a0/a1 610ab542 / 46986511; b28_a0/a1 5e114552 / b666c2a1; c25_a0/a1 7166fa3b / 9a2aa6dd | band sweeps (§3.3) |
| y3_bounds.py 628c43bd | bounds_u20_q916.json a4dafb2e, bounds_u20_q1.json f6a00ed3 | the landing bound in Arb |
| y3_table.py fcbc63ed | y3_table.json a50f2af4 | the table of §3.4 / §3.5 |
| y3_lean_consts.py 81112efe | (console, §8) | Lean constants, rational CF ≤ float CF |
| p2z_small.py b3753b2f | p2z_small.json 002d6e66, .DONE 5cacd90e | P2′ for 3 ≤ m ≤ 10⁸ |
| lx_cover_p5patched.py 5ca71fdc, c2_domain_p5.py f84d38a1 | lx_cover_p5patched.out 5aa52aef (B1–B4; the B1–B3 output d0f05b64 is in superseded/) | C2's LX re-run |
| lx_fartail_probe.py 2d7e98e8 | (console, §4.3) | B3 probe |
| rbox_probe.py fabeabe0, rbox_probe2.py 648386bb, rbox_probe3.py 5acf395f | (console, §4.1) | B1 probes |
| s_direct.py 4ef28c3d | s_direct.out 44ce3d24 | direct S for six characters (COMPUTED) |
| f0_landing.py a447d419, f0_popt.py dc835d93, f0_threshold.py 418fe562 | (console) | float pilots (COMPUTED) |
| pilot2.py 92274d9a, pilot3.py 682eb42f | (console) | certifier pilots |
| defect_records.py 1f7f2a42 | defect_records.out 7336ca75 | §4.0: B1 example and C2 initial boxes; B2/B3 on LX boxes |
| b2_only_probe.py 6a1e6aa2 | b2_only_probe.out afab95a0 | §4.0: B2 isolated (P5 + Pb fix only, built in memory) |
| lx_cover_b2only.py 996f2c77 | lx_cover_b2only.out cf26aa8f | §4.0: C2's LX cover with B2 only |
| superseded/ | u20 at t_hi = 0.5; b38_a0 / b28_a0 killed; c25 weaker | records only |
