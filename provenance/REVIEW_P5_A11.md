# REVIEW_P5_A11: bb's review of P5 §A.11 (R-x, C1–C4, the two certifier changes (T) and R1b, the G1 sweep outputs, N-c)

2026-10-31. **AI review by bb, NOT an operator read-back.** No Lean or lake was run. The only things run were copies of P5's code in
bb's scratchpad (p5g1/, p5d/): a seeded sample of 184 G1 initial boxes, with 4 workers, 37 s wall, plus Arb and mpmath spot checks. No
P5 file was written.

**Object.**
- P5/memo.md **8ca72e41354a0694d7e5e2aa892da6dd** (1456 lines), against memo_pre_addendum6.md (0cebc99c). 189 lines differ: §A.11 and
  its pointers.
- Code read in full:
  - tl_arb_cert.py **4a001119** (floor_box), diffed against the copies preC1 = 250f6b11 (the R1 version I passed), preTail 1f0d2fae
    and preR1b b485f0bf;
  - tl_big.py 82333fd9 (flo);
  - tl_big2.py cc065977 (C1 diff only);
  - g1_sweep.py **5374c662** (initial grids, classify_rem, T_up, run_box, ledger);
  - lx_cover.py fa243994 (diff against 5e1e362b);
  - rhi_monotone.py 66a25bab.
- Outputs:
  - lx_cover_Rx.out 77cadb55, rhi_monotone.out 98c86374, r1b_validate.out 8af9c6f7;
  - g1_corner_a0/a1 fe0a8ab2/6fdca9d4;
  - g1_rem_a0_m3 40b0898c and g1_rem_a1_s1 cc7723f9.

## Verdict: PASS on items 1–7

**The G1 coverage is a reviewed certificate** (Arb trust class; same-session AI work; one AI reviewer). **C2 stays PARTIAL only on C6
(P2′ in Arb)**, as P5 says.

| # | Item | Verdict |
|---|---|---|
| 1 | **R-x** | **PASS.** τ* = √(T(4·10⁴)/2) is inserted as a breakpoint in lx_cover and in the rem grid. The re-run gives 3 069 boxes, 0 failed, worst −0.7689 ✓. **The endpoint rule is now proved:** rhi_monotone covers [L0d, 100] (b = 10⁻⁴) and [100, 4·10⁴] (b = L⁻²) with 2 × 4 000 geometric boxes, whose endpoints are the same float expressions, so they tile. It gives d(LT)/dL ≥ 1.54e−4 > 0 and dT/dL ≤ −1.13e−8 < 0 in Arb, and b is continuous at 100. So R_hi is increasing for τ ≤ τ* (the cap) and decreasing for τ ≥ τ* (t·Tinv(t) = L·T(L) at a decreasing L) ✓ |
| 2 | **C1, C2, C3** | **PASS.** flo(x) ≤ x.lower() exactly (nearest, then one nextafter step if above; non-finite gives −∞) ✓. floor_box and big2 return flo(S), and every other return is −∞ ✓. L0d = 17.275950858102963 and T0d = 9.999999999999999e−5 are asserted < the true values at 200 bits ✓. τ_lo = 0.999·√(5·10⁻⁵) ✓. The 1e−6 R-pad exceeds the float errors of R_lo and R_hi (the Tinv conditioning bound with \|T′\| ≥ 1.1e−8) ✓. The τ* split is in both grids ✓ |
| 3 | **C4, classifier and union argument** | **PASS.** L = 2(R − σ′)/τ² and t = 2τ² are Arb balls over the node, with σ′ in Arb. The four drop rules are checked below the table. Bisection children share float split points. complete ⇔ all initial boxes done, none capped, none failed ✓ |
| 4 | **(T) far-tail cut** | **PASS: tightness-only.** U_MIN = min(−6, …, R_lo − s_fe). The Riemann cells still tile [U_MIN, u₀] exactly, with width ≤ 0.04. The half-line majorant needs only U_MIN ≤ −6, i.e. y_m = (1 − U_MIN + a)/2 ≥ 3.5 for Stirling (as in REVIEW_P5 §6). s_fe in floats only moves the cut ✓ |
| 5 | **R1b, the Γ-ratio form** | **PASS, re-derived below the table.** This is the real soundness change, and it is correct |
| 6 | **Sweep outputs** | **PASS.** All four ledgers have complete = true, capped 0, failed 0, worst ≥ −1 (outward), with 3 021, 383, 224 903 and 212 686 leaves. **bb's sample re-run** (copied code, seeded): 72 remainder and 20 corner initial boxes per parity, including the τ*-adjacent boxes and x ≥ 4096. All 184 complete, 0 failures, 0 unfinished (bb_g1_sample.py ecc37e02 → sample.json 64cf8b59). It is a spot check, not a full replay |
| 7 | **N-c** | **PASS.** Z(2.6179) = 0.2509884 (mpmath). ½(−0.0795154 − 0.2509884) − 0.01 = **−0.17525** ✓ |

**The four drop rules (item 3).**
- **(out)** hi(L) < L0d or hi(t) < T0d. No point of D_G1 lies there. Points of the full C2 domain with L > 4·10⁴ and t ∈ [4/L, 10⁻⁴)
  are STL's: τ ≤ 0.00707 and R ≥ σ′ + 1 ✓.
- **(stl)** lo(L) > 4·10⁴. For D-points with L > 4·10⁴: t ≤ T(L) ≤ T(4·10⁴) gives τ ≤ τ* < 0.0175, and t ≥ 4/L gives R ≥ σ′ + 1. So STL's
  hypotheses hold ✓.
- **(above)** hi(L) ≤ 4·10⁴ and lo(t) > T_up(L-ball).
  - T_up is a valid Arb enclosure: k = (L − 4)/√5 − 2 ≥ 3.9 > 0, and b straddling 100 is the union [1/L_hi², 10⁻⁴] ✓.
  - The arb comparison is decided only if lo(t) > the ball's upper end ✓.
  - **It never fired in the final runs (dropped_above = 0 in both remainder ledgers), so no result depends on it.**
- **(corner)** hi(L) ≤ LC, hi(t) ≤ TC and x_hi ≤ XC. Then node ∩ D ⊂ CORNER, since L₀ ≥ L0d and 10⁻⁴ ≥ T0d. The same float LC is used
  by the corner sweep ✓.

**R1b, re-derived (item 5).** For a tail cell u and each x in the box, the tail term is normalised **at the same x**. That is what S's
ratio structure needs: D₀, D₁ and the tails share the normaliser pointwise in x.
- The x-dependence sits in Δ(u, x) = Re lgΓ_a(u − ix/2) − Re lgΓ_a(R − ix/2). With z = (· + a)/2 − ix/4:
  - ∂/∂x Re lgΓ(z) = Im ψ(z)/4;
  - so ∂Δ/∂x = ¼[Im ψ(z_u) − Im ψ(z_R)];
  - on the horizontal segment z_R → z_u, \|·\| ≤ (\|u − R\|/2)·sup\|ψ′\|.
  - So \|Δ(u, x) − Δ(u, x_mid)\| ≤ r_x·\|u − R\|/8·trig_up((min(u, R) + a)/2, \|x\|_lo/4). That is exactly `ex(u)` ✓.
- trig_up is valid because the real parts are > 0 (u ≥ ½, R ≥ σ′; FE us ≥ 0.46) and \|Im\| ≥ \|x\|_lo/4 ✓.
- Δ(u, x_mid) is bounded by hi(lgw at x_mid) − lo(lgc_m at x_mid), sup over the u- and R-balls ✓.
- The FE branch uses Re lgΓ(z̄) = Re lgΓ(z) with us = 1 − u ✓. The boundary term lP0 is handled the same way ✓.
- Every other tail ingredient (\|w + 1\|, Rademacher, the FE power, the ζ factors) is evaluated x-uniformly ✓.
- **Far half-line.** The numerator is x-free (\|Γ(y+iv)\| ≤ Γ(y)), so an x-box *lower* bound on the normaliser is needed. `lip` =
  lo(lgc_m) − r_x(π/2 + 1/(2ũ_lo))/4 gives it, from \|Im ψ(u+iv)\| ≤ π/2 + 1/(2u) (re-derived in REVIEW_P5 §5). Taking the max with the
  R1 centred form is valid ✓.
- **r1b_validate** (30/30) is consistency evidence: the box bound is ≤ the point certificates, which are ≤ the float floor. The proof is
  the derivation above.

## Notes

- **N-r1b.** In the memo, call r1b_validate "consistency", and point to this review for the proof of R1b.
- **N-old.** The pre-R1b m2 leaves (563 256) are valid under R1 + (T), as P5 says, but are not needed. Keep them labelled as such.
- **Status of C2.** The G1 sweep, LX (R-x fixed), STL (−0.17525) and the domain reduction are all reviewed. What remains:
  - **C6:** P2′ (Lemma Z) in Arb. That is (P2′-a), an Arb box version on [L0d, 4·10⁴], and (P2′-b), an analytic large-L lemma.
    P5's plan is reasonable. The first step it names, re-reading FGMPS's x ≥ 480 monotonicity term by term for the m-explicit forms, is
    the right one.
  - The FGMPS m-range items (N2) were CITED-READ by P5; bb has not re-read them at source.
  - Until C6 is done, C2 is a fully specified PARTIAL proof with its G1 grid certified.
  - It is a large-conductor bound on Λ_χ, not GRH.

## bb's files (scratchpad p5g1/; md5)

| file | md5 |
|---|---|
| bb_g1_sample.py (seeded sample of g1_sweep.run_box on copied code) | ecc37e02ef649a5dc17a969e86707e89 |
| sample.json (184 boxes: rem and corner × a ∈ {0, 1}; 0 failures) | 64cf8b59d18e0ffb98591e2a01ce23fd |

conjecture1_proved = False. AI review by bb, NOT an operator read-back.
