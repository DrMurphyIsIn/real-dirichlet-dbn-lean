# REVIEW_Y3: bb's adjudication of the C2 certifier defects B1–B3, a fourth gap B4, the G1 re-run gate, and Y3's own results

2026-11-01. **AI review by bb, NOT an operator read-back.** No Lean or lake was run. Every run used copies of P5's and Y3's
scripts in bb's scratchpad (y3c/) and wrote only there. P5/ and Y3/ were read, never written. No team file other than this
one was written. I read FGMPS 2610.27343 and H-B 2610.12803 at source (alphaXiv full text, this session).

**Object.**
- ~/rh-team/dq1/Y3/memo.md **fda22d9f02cf188f8befaf1915e4dbc0** (613 lines).
- Y3 scripts: y3_cert.py 5b375c5b, y3_big.py aa232458, y3_big2.py a8f10bcd, y3_sweep.py 129799ab, y3_bounds.py 628c43bd,
  y3_lean_consts.py 81112efe, p2z_small.py b3753b2f, lx_cover_p5patched.py 5ca71fdc (→ .out d0f05b64), c2_domain_p5.py
  f84d38a1 (identical to P5's c2_domain.py), and the ten band ledgers plus p2z_small.
- Against P5's tl_arb_cert.py 4a001119, tl_big.py 82333fd9, tl_big2.py cc065977, g1_sweep.py 5374c662, lx_cover.py fa243994,
  p2z_arb.py b732f0ef, and the G1 ledgers of record (corner a0/a1, rem_a0_m3, rem_a1_s1).

## Verdict

| # | Item | Verdict |
|---|---|---|
| B1 | Bulk majorant evaluated below u = 1 (R-box) | **CONFIRMED.** It **invalidates certificates formally** in floor_box (G1). In big2 it fails safe (NaN), so it invalidates no LX certificate. **Y3's patch is SOUND.** **Correction to Y3's "effect 0":** the patch is not value-neutral. It never lowered a floor in any measurement, but it raises some floors and certifies boxes P5 could not. The G1 re-run will therefore need *fewer* leaves (§1) |
| B2 | Bulk-mass lower bound has the wrong direction (big2) | **CONFIRMED.** It **invalidates the LX certificate as run** (box values may be too high). **Fix SOUND.** The corrected cover still passes: 3 069 / 0 / −0.7689010038 |
| B3 | Far-far tail majorant not integrable (big2) | **CONFIRMED; proof step only.** The three-region repair, including Lemma Γ↓, is **SOUND (re-derived)**, with two nits |
| **B4** | **NEW (bb): the bulk Riemann sum's lower limit uses a *lower* bound on Re c₂ where it needs an *upper* one (big2)** | **A coverage gap, proof step only.** Bulk points with g < lo(g_s) are in neither the bulk sum nor the U-tail. A v-uniform gap term (§4) gives C2's LX **3 069 / 0 / −0.7689010122** (it was −0.7689010031), and leaves all ten Y3 band ledgers' LX worst values unchanged. **Repair to be adopted into y3_big2, and re-derived by someone other than bb** |
| G | **C2 G1 re-run with the B1 patch** | **SOUND TO RUN** under conditions G-1 to G-6 (§5). Expect ≤ 3 CPU-h (the record took 2.9) and fewer leaves than 440 993. **Until it is done, C2 = PARTIAL (formal gap B1 in G1)** |
| Y3-a | Conditional bands at p = 20 (q₀ = 9/16): odd CF 0.385, even CF 0.36 | **PASS.** u20_a0 and u20_a1 **reproduced bit-identically** (every ledger field except `sec`), also with B4 included. The landing was recomputed independently |
| Y3-b | Λ_χ ≤ 0.27912 < 9/32 for every real primitive χ (given OAI's 7/8) | **PASS for 3 ≤ m < 10⁸.** For m ≥ 10⁸ it rests on C2, which is PARTIAL until the G1 re-run |
| Y3-c | Unconditional Λ_χ ≤ 0.49330 < ½ | **PASS** (T = 0.49324 ≤ t_hi = 0.499), with the same C2 caveat for m ≥ 10⁸. **Novelty checked at source: Y3's framing is right** (§6.3) |
| Y3-d | Unconditional < 9/32 for odd m ≥ 15 848 932 and even m ≥ 36 307 806 (p = 5/2) | **PASS.** c25_a0 and c25_a1 reproduced bit-identically, with and without B4. The margins are 1.36·10⁻⁴ (odd) and **9.67·10⁻⁶ (even)**. They are thin but decided, since the CF float is used exactly |
| Y3-e | Lemma Z′ for 3 ≤ m ≤ 10⁸ (76 800 boxes, worst Q ≥ 0.9455) | **PASS.** Only the region loop differs from P5's p2z_arb (Q_box is unchanged), and the run **reproduced exactly** |
| — | bb's own record | My REVIEW_P5 §6, REVIEW_P5_DELTA (206b88e7) and REVIEW_P5_A11 (e570fc33) passed both certifiers' bulk coverage and missed B1, B2, B3 and B4. §7 says what I failed to check |

## 1. B1: floor_box and big2 (CONFIRMED; patch SOUND; the patch is not value-neutral)

**Where the defect is.** In tl_arb_cert.py the Riemann sum starts at lo(g₀), with g₀ = (u₀ − R)/τ taken over the (R, τ)-ball
(:64). On a cell, u = R + τg can reach below 1, where `Z_up` returns −ζ′/ζ(σ) < 0. Then:
- `Zs` (:77) and `Z_up(u)` in D1 (:81) can be negative;
- (e^e − 1)·w < 0 can then enter I_a.

So the claim |∫_bulk (e^r − 1)φ| ≤ I_a is not established. **A leaf whose cells reach u < 1 is not a certificate.**

In big2 the same cells give `lzeta_up` = log of a negative number = NaN. Then rL2, eps and Ie are NaN, `den > 0` is False, and
the box returns −∞. So **B1 invalidates no LX certificate** (fail-safe), as Y3 says.

**Why the patch is valid.** In floor_box, w = c + τg lies on the original horizontal line, so Re w = R + τg exactly. The bulk at
each (R, τ) is exactly {Re w ≥ u₀}. On bulk points the clamp max(lo u, u₀) is therefore a valid lower bound for every real part
on the segment [c, w], because R ≥ σ′ + τ²L₀/2 > u₀ on the C2 domain. Points in a cell that are tail points at their own τ get
a majorant that is ≥ 0. They only over-count I_a and D1, which is conservative, and the tail integral already covers them.
Pcut uses hi(g₀), which is correct. The big2 clamp at u_s is valid on the same grounds, for the split of §4.

**Direction of the effect: the clamp is not value-neutral** (`bb_g1_dir.py`, 400 seeded C2 rem initial boxes × 2 parities):
- **max(P5 − Y3) = 0.0.** The patch never lowered a floor.
- **On 10 of 443 pairs where both are finite, the floor rose,** by up to +5.0·10⁻⁴. One example is box 3228 (P5-certified at
  the initial level): 1.1503696 → 1.1503793.
- **197 pairs went from P5's −∞ to finite.** Cells with lo u ∈ (1, u₀) gave P5 a near-pole Z_up, which the clamp removes.

Y3's "bit-identical on all 206" holds for Y3's sample but is not general. The accurate statement is "never lower in
800 + 287 measurements; sometimes higher".

**Leaf-level spot-check** (`bb_g1_spot.py`, 16 boxes × 2 parities, P5's run_box procedure verbatim): 20 of 32 pairs gave
identical leaves. In the other 12, Y3 needed fewer evaluations (box 4002: 255 → 1). There were no failures with either
certifier.

## 2. B2 (CONFIRMED; fix SOUND)

- In big2, Pb is a lower bound for the bulk mass. The bulk is {Re w ≥ u_s}, which is g ≥ g*(point) with g* ≤ (u_s − Uc₂)/τ (§4).
- P(g ≥ lo g_s) exceeds P(g ≥ g*) whenever g* > lo g_s. That happens when Re c₂ ≈ Uc₂ (R at R_lo, Re β₂ ≈ −Z₁) and τ > τ_lo,
  because lo g_s is taken at τ_lo.
- Y3's P(g ≥ hi g_s) ≤ P(g ≥ g*) is valid at every point.
- **B2 changes values** (−0.020 on Y3's example; −5.4·10⁻⁶ on a C2-domain box). **The LX certificate of record (lx_cover_Rx.out
  77cadb55) is therefore not a certificate.** The corrected cover passes with the same constant.

## 3. B3: the far-far tail (CONFIRMED as a proof gap; repair SOUND, re-derived)

**The defect.** Take the maximiser ℓ* = c₂ + 4A/τ². There the Gaussian U² terms cancel, so log q ~ s₁²/(4v₀) with s₁ = 1 − U.
The step "d log q/dU ≥ rate on (−∞, U_MIN)" is false for U ≲ −v₀p/τ². The numbers in the code are unaffected.

**Region I (1 − v₀ ≤ U < U_MIN).**
- For the coded majorant: d lg/dU = −(ℓ + c₁)/2 − A/(2v₀) by the envelope theorem. Here lg is a max over ℓ ≥ ℓ₀ of a function
  smooth in U (Danskin), and dA/dU = −½, dc₁/dU = −1/(2v₀).
- lL = log ζ(s₁) only steps down as U decreases. With (R − U)/τ² − 2(R − σ′)/τ² from the Gaussian and FE terms:
  - in the ℓ* regime the slope is ≥ (p − 2/ℓ₀)/τ² − (c₁ + c₂)/2 − A/(2v₀);
  - in the ℓ₀ regime it is ≥ (2σ′ − R − U_MIN)/τ² − (ℓ₀ + c₁)/2 − A/(2v₀).
- With s₁ ≤ v₀ and a ≤ 1: sp/v₀ ≤ 0.5002 and A/(2v₀) ≤ 0.25 + 1/(2v₀ℓ₀) ≤ 0.2501.
- This is Y3's s_I exactly ✓.
- Integrating e^{−s_I y} against [(g_m + τP_b)/τ + y/τ²], P5's 2q/rate and 4q(g_m + τP_b)/(τ·rate) suffice iff s_I ≥ rate/2 and
  2/(τ·rate) ≤ g_m + τP_b. These are exactly Y3's two Arb checks ✓.
- The omitted −2/(ℓ₀τ²) term in P5's rate is real, and is absorbed as Y3 says ✓.

**Region IIa (U < 1 − v₀, v ≥ s₁).**
- c₁(v) ≤ c₁ᵇ + (s₁ + a)/(2s₁) ≤ c₁ᵇ + 0.5002. Y3's "+1" is looser and valid.
- ℓ* ≥ 4A/τ² ≥ 2(2500 − 402)/0.25 ≫ ℓ₀, so only the ℓ* regime occurs. The constraint ℓ ≥ log s₁ only lowers the sup.
- The slope is (p − 2/ℓ₀)/τ² − (c₁ᵇ + 1 + c₂)/2 = s_IIa ✓, since dc₁/dU = 0 here.
- **The restart:** c₁ enters lg additively as A·c₁. So log q_IIa(U₁) − log q_I(U₁) = A(U₁)(c₁ᵇ + 1 − c₁,I) ≤ A(U₁) =
  (v₀ − R)/2 + 1/ℓ₀ ✓. Using lo R makes this conservative ✓.
- The T₁ closed form matches the integral ✓.

**Region IIb (v < s₁, s₁ > v₀).**
- **Lemma Γ↓ re-derived.**
  - d/dy log|Γ(x+iy)| = −Im ψ(x+iy) = −Σ_k y/((x+k)² + y²), so log|Γ(x+iy)| − log Γ(x) = −½Σ_k log(1 + y²/(x+k)²).
  - The summand is decreasing in x + k. So the sum is ≤ f(x) + ∫₀^∞ ½log(1 + y²/s²)ds = f(x) + π|y|/2, with f(x) ≤ ½log(1+4y²)
    for x ≥ ½ ✓.
  - This is applied at x = (R+a)/2 ≥ ½ (R ≥ 1 is guarded) and |y| = v < s₁.
- **The Gaussian domination.** The Gaussian and FE exponents combine to [−s² + 2s(R − p) − (R−1)² − 2(R − σ′)]/(2τ²).
  - With R − σ′ ≤ 400 (guarded) and s ≥ 2500, 2s(R − p) ≤ 0.32s², so the exponent is ≤ −0.34 s²/τ² + max(0, −L)/2.
  - The positive terms (s/2)log s, πs/2 and ½log(1+4s²) are ≪ 0.215 s²/τ² at τ ≤ ½.
  - So log q ≤ B₀ − s²/(8τ²) holds with room ✓, and ∫_{v₀}^∞ e^{−s²/(8τ²)}(1 + s/τ²)ds ≤ e^{−v₀²/(16τ²)} ✓.
- **Nit B3-a.** In IIb the multiplier |β(v)| ≤ P(s₁) (log growth) is absorbed by the same slack. Say so in §4.3, which
  currently states only log q.
- **Nit B3-b.** Region I uses sp/v₀ ≤ (v₀ + 1)/(2v₀) = 0.5002 at v₀ = 2500. Write the a ≤ 1 dependence into the constant's
  comment.

## 4. B4 (NEW): the bulk Riemann sum's lower limit in big2

**The geometry.** big2 shifts the contour to w = c₂ + τg (g real), so Re w = Re c₂ + τg.
- Re c₂ = R + τ²(Re β₁ + Re β₂) has only a lower bound Uc₂. Re β₂ = Re L′/L(c₁) ∈ [−Z₁, Z₁] is χ-dependent. Re β₁ grows like
  ½log v, and the x-aware box covers all v ≥ v₀.
- The U-tail is integrated in the true U = Re w up to u_s. The weight in U, exp(−(U−R)²/(2τ²) − τ²(Re β₁)²/2 + …), is exact
  (the Re β terms cancel).
- The by-parts boundary term is at U = u_s.
- So **the split is at Re w = u_s, i.e. g* = (u_s − Re c₂)/τ ≤ (u_s − Uc₂)/τ.**

**The gap.** The bulk sum starts at lo((u_s − Uc₂)/τ). That is an upper bound for g*, not a lower one.
- Points with g ∈ [g*, lo g_s) have Re w ≥ u_s, so they are not in the U-tail. They are also not in the sum.
- The gap is non-empty for generic χ, and unbounded in g as v → ∞.
- The other reading (split at g = (u_s − Uc₂)/τ) leaves the same set uncovered on the tail side instead, and puts the boundary
  term at the wrong place.

**A v-uniform bound for the gap.** On the gap:
- Re w ∈ [u_s, Re c₁ + τ²Z₁ + τ·lo g_s). That is < Re c₁ when τZ₁ + lo g_s < 0, which is guarded in Arb.
- |Re(w − c)| ≤ max(R − u_s, τ²(P₁ + Z₁)) and |Im(w − c)| ≤ τ²I.
- M is evaluated at real part u_s. The product P²M decreases in v by P5 A.9.2(d).
- |r_L| ≤ log ζ(u_s) + log ζ(Rc₁) + sup_{u≥Rc₁}(u − u_s + τ²Z₁)Z(u). The sup is taken on a 0.01-grid with monotone Z_up, and the
  tail beyond 60 uses Z(u) ≤ 2^{60−u}Z(60).
- The numerator majorant is |h_Γ|M + Z(u_s) + Z₁.
- The mass is ≤ Φ(lo g_s), evaluated at v₀. That suffices for every v, because the gap is relative to the v₀-sum start.
- Then Ie += e^C·Φ and Nb += e^C·num·Φ.

**Effect.**
- On the C2 domain, lo g_s ≤ −3.4 (minimum about −4.2 near τ ≈ 0.18), so Φ ≲ 10⁻⁵.
- C2's LX cover (`bb_lx_cover_b4`) gives 3 069 boxes, 0 failed, worst **−0.7689010122** (the guard never fired).
- All ten Y3 bands re-swept with the term (u20, c25, b6, b38, b28, both parities; G1 untouched) reproduce their ledgers
  bit-identically, including worst_lx.
- **B4 is a proof-step gap with no effect on any stated constant.**
- **Request:** Y3 (or the lead) re-derive the gap term and adopt it into y3_big2. Then re-run C2's LX and Y3's LX slabs with
  the final code for the record. I wrote the repair, so I am not an independent check of it.

**Not affected:**
- floor_box: there w = c + τg on the original line, Re w is exact, and the measure carries the shift.
- STL: its bulk covers all g, with nonnegative majorants.

## 5. The C2 G1 re-run gate: SOUND TO RUN under these conditions

- **G-1 code.**
  - y3_cert.py 5b375c5b + y3_big.py aa232458, with **`Y3_P=sqrt5` exported before the pool starts** (y3_big has no default, so a
    missing env aborts). With 'sqrt5', P and SIG = (1+P)/2 are the same Arb values as tl_arb_cert's.
  - Driver: a copy of g1_sweep.py 5374c662 whose only change is line 85, `from tl_arb_cert import floor_box, iv` →
    `from y3_cert import floor_box, iv`. Archive `diff` showing only that line.
  - c2_domain.py f84d38a1 unchanged.
- **G-2 runs:** the record's four jobs with the record's parameters:
  - corner a0 and a1 at cap 300 s;
  - rem a0 and a1 at cap 240 s;
  - W = 6, K0 = 1, depth cap 30, the same initial_boxes and classify_rem drops.
  - Run in a **new directory**, so P5's ledgers are kept as records.
- **G-3 pass criterion:** for each ledger:
  - DONE with complete: true;
  - attempted = completed = initial (320 / 320 / 4 576 / 4 576);
  - capped 0, failed 0.
  - Report evaluations, leaves, worst, dropped counts, and the md5s of the json, DONE, log and driver copy.
  - Fewer leaves than 3 021 / 383 / 224 903 / 212 686 is expected (§1) and is not a red flag. Any failure is.
- **G-4 hygiene:** one core per worker with BLAS pinned to 1 thread; no Lean or lake; writes only in the run directory.
  Expected ≤ 3 CPU-h, about 15 min wall per rem job at W = 6. Whether that is inside the user's C2 envelope is the lead's call; I
  cannot see the approval.
- **G-5 LX:** B1–B3 are already re-run (Y3, d0f05b64). Re-run once more with the adopted B4 term (§4) for the record. This is
  independent of G1 and takes 35 s.
- **G-6 status:**
  - Until G-3 passes: **C2 = PARTIAL (formal gap B1 in G1).**
  - After: the C2 statement of record (P5 §A.13 rows 4a and 4b) cites y3_cert and the new ledgers, and big2 with B2 + B3 + B4.
  - The constants (S ≥ L/4 − 1 in G1, S ≥ L/4 − 0.77 in LX, and 0.2764 at 10⁸) are expected unchanged.

## 6. Y3's own results

**6.1 The certificate machinery.**
- y3_sweep's R-ball is the outward hull of the four (L, τ) corners. This is correct even at m = 3, where L < 0.
- τ-slabs are contiguous; the x-grid is [0, 10⁴] plus LX for x ≥ 10⁴; L_lo is rounded down and L_hi up; t_lo ≤ 10⁻⁴ and t_hi
  are asserted in Arb.
- Bisected children keep the parent's R-range (over-cover) ✓.
- I found no √5-specific constant in y3_cert, y3_big or y3_big2. P enters only through σ′ = (1+p)/2.
- floor_box's far half-line uses hi(L) as the linear coefficient, so it stays valid for L < 0 ✓.
- B3's domain guards hold on every band (τ ≤ ½ is why u20 stops at t_hi = 0.499).
- **Reproduction:** u20_a0, u20_a1, c25_a0 and c25_a1 re-ran from copies and match Y3's DONE files in every field except `sec`.
  b6, b38 and b28 were re-swept only in the B4 variant (§4), which also matches.

**6.2 The landing** (`bb_landing.py`, mpmath at 50 digits; my own code, using the exact CF floats).

| case | m_lo | k | T | Λ ≤ | margin |
|---|---|---|---|---|---|
| OAI, odd, p = 20 | 3 | 0.054666 | 0.2790613 | 0.27911134 | 9/32 − Λ = 2.14·10⁻³ |
| OAI, even | 5 | 0.075207 | 0.2782689 | 0.27831886 | 2.93·10⁻³ |
| q₀ = 1, odd | 3 | 0.054644 | 0.4932441 | 0.49329408 | ½ − Λ = 6.71·10⁻³ |
| q₀ = 1, even | 5 | 0.075185 | 0.4907846 | 0.49083455 | 9.17·10⁻³ |
| q₀ = 1, odd, p = 5/2 | 15 848 932 | 3.769744 | 0.2810638 | 0.28111375 | 9/32 − Λ = 1.36·10⁻⁴ |
| q₀ = 1, even, p = 5/2 | 36 307 806 | 3.765316 | 0.2811903 | 0.28124033 | **9.67·10⁻⁶** |
| C2 at 10⁸ | 10⁸ | 3.937186 | 0.2763782 | 0.27642820 | 4.82·10⁻³ |

- All values agree with Y3's Arb (y3_bounds).
- Every case satisfies T ≤ t_hi and p² ≥ 5q₀.
- k increases in L and T decreases in k, so the band's lower end is the worst case ✓.
- **Nit Y3-1.** The memo's even constant 0.2783196 is the Lean-rational value (CF = 3599/10000). The certificate value is
  0.2783189. Label which one each place uses (§0, §3.4 and the Lean comment at :525).

**6.3 Novelty of (U1), checked at source.**
- FGMPS p.8: "On the upper-bound side, only the trivial bound Λ_L ≤ ½ from de Bruijn's argument was known. Theorem 1.1 gives
  the first non-trivial upper bounds for a Dirichlet L-function."
- Thm 1.1 (p.5) is stated for 3 ≤ m ≤ 400 only.
- Remark 3.1 (p.14): the 7/8 half-plane "would imply" D = 3/4. Remark 3.4: the strip alone gives D²/2, so with OAI they have
  9/32 for every m.
- H-B 2610.12803 is about ζ only (abstract, §1.1).
- So Y3's corrected framing is accurate: (U1) is the first all-m bound below ½ that uses no half-plane, no GRH and no zero
  verification. It rests on C2 for m ≥ 10⁸.
- Any external use of this is the user's call.
- **Optional (Y3-2).** FGMPS's unconditional D = 1 values for χ₋₃ (0.26967) and χ₋₄ (0.26) are below Y3's. Taking the min per
  character would lower the uniform conditional constant from 0.27912 to Y3's m = 5 even value, 0.27832. That would rest on
  FGMPS's tables, which are CITED and not reproduced by us.

**6.4 Lemma Z′ (p2z_small).**
- `diff` against p2z_arb b732f0ef shows only the region loop:
  - L ∈ [log(3/π)↓, log(10⁸/π)↑] in 200 uniform cells;
  - t_min = 10⁻⁴ and y_b = 0.01 fixed;
  - ℓ = 3.2·10⁵.
- Q_box (bb-reviewed with P5) is unchanged, and at L < 0, log m ≥ log 3 > 0 keeps every term finite.
- My copy reproduced p2z_small.json's part1 and regions exactly (76 800 boxes, 0 failed, worst Q 0.9455107877).
- **Nit Y3-3.** n_failed is computed after truncating `failed` to 10 entries. This is inherited from P5 and harmless at 0;
  compute it before truncating.

## 7. bb's miss

- In REVIEW_P5 §6, REVIEW_P5_DELTA and REVIEW_P5_A11, I checked each certifier's majorants cell by cell. I did not check that:
  - (i) every majorant is used inside its validity domain on every point of the ball (B1);
  - (ii) each bound feeding a denominator has the right direction over the whole R- and τ-ball (B2);
  - (iii) the closed-form far tail is integrable, rather than only having the right local slope (B3). For B3 I had marked P5
    A.9.2(f) "read, not re-derived";
  - (iv) the bulk/tail split is the same set on both sides when the contour shift has an unknown real part (B4).
- I now apply these four checks to any certifier I pass.
- The A11 184-box re-run could not catch B1–B4, because it ran the same code.

## bb's files (scratchpad y3c/)

| file | md5 |
|---|---|
| bb_big2_b4.py (y3_big2 + B4 gap term + guard) | a410901b35c039524cef27d63a4f4960 |
| bb_lx_cover_b4.py / .out (C2 LX: 3 069 / 0 / −0.7689010122) | e35dfc6188a3961af8331352d2ee0caa / 95551e4e83339de76fe1399f1f5eb3cb |
| bb_sweep_b4.py (y3_sweep with bb_big2_b4) | cb52b81e4c622d333ad0f2b5e71bda05 |
| bb_g1_dir.py / .out (B1 direction, 800 pairs) | e829bfa56bc174d3e58509e6aee94f1e / 51e6d1b40d1aba56198c1b526bba804b |
| bb_g1_spot.py / .out (leaf spot-check, 32 pairs) | 137ba858add930135ad7980087f19e7d / ecdb0450cef505b742c1a8a6beb0d44d |
| bb_landing.py (independent landing) | 4f02290ea9a33b5eab9c26786a12c1c2 |
| g1_sweep_copy.py (= P5 g1_sweep) | 5374c6626b0ae358975e1947a50437ad |
| rep/ re-runs: u20, c25 (plain + B4), b6/b38/b28 (B4), p2z_small | DONE files in rep/ (match Y3 except `sec`) |

No RH-facing claim. conjecture1_proved = False. AI review by bb, NOT an operator read-back.
