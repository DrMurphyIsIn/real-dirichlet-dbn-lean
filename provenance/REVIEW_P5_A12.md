# REVIEW_P5_A12: bb's review of P5 §A.12 (C6: P2′ via Lemma Z′, the p2z_arb check, the draft C2 statement of record), with FGMPS read at source

2026-10-31. **AI review by bb, NOT an operator read-back.** No Lean or lake was run, and no P5 script was run. I did Arb arithmetic in
the scratchpad. **FGMPS 2610.27343 v1 was read at source (alphaXiv)**: pp.1, 6–7, 19, 22, 24, 28–29, 34–35, 37–39, 41–48, 51, 57–59,
61–62 and 81–82. No P5 file was written.

**Object.**
- P5/memo.md **8c6b2b52a29114b02b4c1b2992a87c80**, the lead's latest version. It is the same as 9b7f82d9 except for my two §A.11 notes
  and the §A.11 PASS line, which I checked by diff. §A.12 (:1213–1332) is unchanged.
- Scripts: p2z_arb.py b732f0ef → p2z_arb.json 2b41dc9b and .DONE 69319cef; lemma_z.py 98f7fd0f.

## Verdict: PASS

**With §A.11 already PASSED (REVIEW_P5_A11), C2 is a complete result in the Arb trust class**, AI-reviewed by one reviewer. It is not
Lean and not an operator read-back. Its one external load-bearing source is the unrefereed FGMPS preprint (October 2026).

| # | Item | Verdict |
|---|---|---|
| 1 | **FGMPS at source, including N2 (every m ≥ 3)** | **PASS, confirmed at source.** Details below the table |
| 2 | **Fidelity of the criterion** (lemma_z / p2z_arb's Q) | **PASS, term by term against FGMPS.** Details below the table |
| 3 | **x-monotonicity** | **PASS, re-derived independently.** All of the following are monotone for x ≥ 480: ℓ′ ↑ and ε₁ ↓, so r, r′ ↑ and ζ(r), ζ(r′) ↓; q^{−y/2} ↓ and log δ₊/(x − 2) ↓ (since log δ₊ > ½); d_m ↓, because ℓ²/(x − 2.5) ↓ once ℓ > 2(x − 2.5)/x, and ℓ ≥ 22 here; (mT′/2π)^{−(1+y)/4} ↓, e^{−tℓ²/16} ↓, K ↓ and E_RS ↓. So Q is non-decreasing in x, consistent with FGMPS pp.58–59 for their (6.4) and (6.5). P5's correction of the pointer (from "pp.59–60" to the per-term argument) is right |
| 4 | **Lemma Z′** | **PASS, every step re-derived.** Details below the table |
| 5 | **p2z_arb (independent check)** | **PASS as a check**, with nit N-x. 61 440 boxes, 0 failed: region A worst 0.92538, region B worst 0.90844. The t-boxes start at min t_min and the y-boxes at min y_b over each L-box ✓. Logs keep wide L-boxes finite ✓ |
| 6 | **First-contact use of the uniform form** | **PASS.** Details below the table |
| 7 | **"< 9/32 for every m ≥ 10⁸"** and the values | **PASS** (Arb). Details below the table |

**Item 1: FGMPS at source.**
- **Thm 4.3 (p.22)** is stated for 0 ≤ t ≤ ½, x ≥ 480, |y| ≤ 1, with **no m range**.
- **Its ingredients need only m ≥ 3 (or m > 1):**
  - Lemma 4.4 (p.24): σ ∈ ℝ, T > 2, 0 < t ≤ ½;
  - Props. 4.15–4.17;
  - Prop. 4.14 (p.37): T ≥ 240, with constants "use m ≥ 3";
  - (4.18) (p.29): "m ≥ 3 and h₀ > 4/5";
  - Thm 4.12: m > 1;
  - Thm 4.11 (4.31): m ≥ 3.
- **Prop 4.18 is stated for 3 ≤ m ≤ 4·10⁵, but its proof (pp.44–46) never uses the upper bound.**
  - (1): ℓ/(8(x − 2)) = log m/(8·478) + …, which is ≤ log m/3800, and the m-free part is 1.383e−3 ≤ 0.002.
  - (2) and (3) are m-free.
  - (4)–(5): (t²/4)(2\|L_n\| + π)/(x − 2) gives log m/3824 ≤ log m/2250, and the m-free part is 1.2899 ≤ 1.3.
  - (6): δb₁ = √(T′/7.49) is m-free, B*_m is kept, and c₁(0) = 2φ(m)/5.
  - The only range-specific statement is (4.32), B* < 3.33√m, which C2 does not use; it uses (4.31) with A₀ < 1.276873.
- **So Thm 4.3 + Prop 4.18 hold for every m ≥ 3.** N2 is now re-read at source.

**Item 2: the criterion, term by term.**
- \|f − 1\| ≤ Σ_{2≤n≤M} b_n n^{−Re s*(+)} + \|γ\|Σ_{n≤M} b_n n^{−Re s*(−)}, using (4.40).
- p.57 gives b_n n^{−Re s*(+)} ≤ n^{−1+θ_y}H_n, and log n ≤ log δ₊ gives ℓ − log n ≥ ℓ′. So the first sum is ≤ ζ(r) − 1.
- \|n^{−s*(−)}\| ≤ n^{y+\|κ\|}n^{−Re s*(+)} (Prop 4.18(4)'s proof) with M^{\|κ\|} ≤ δ₊^{ty/(2(x−2))}. Then (1) gives \|γ\| ≤ e^{a_m y}q^{−y/2}.
  So the second sum is ≤ g·ζ(r′) ✓.
- e_A + e_B ≤ η(ζ(r) + gζ(r′)) by (4)–(5), with \|L_n\| ≤ ℓ ✓.
- e_{C,0} is exactly (6) with (4.41) ✓.
- B*_m is (4.31), where the last term is < 1e−9 for m ≥ 3 ✓.
- "Non-vanishing iff \|f\| > E" is p.57, using B_t ≠ 0 ✓.
- Negative x or y are handled by the symmetries of H_t (p.19) ✓.

**Item 4: Lemma Z′.** Here q = e^{ℓ(L)} and X ≥ 4e^{7ℓ/8} ≥ 480.
- **r and r′.** tℓ ≥ 32 in both regimes (10⁻⁴·3.2·10⁵, and (4/L)·8L), so r ≥ 4.49 and r′ ≥ 3.99. ζ(4.49) − 1 = 0.055147 and ζ(3.99) = 1.083016 ✓.
- **g.** y_bℓ ≥ 8 in all three regimes, and a_m ≤ 0.0024 + ℓ/30400. So log g ≤ −0.4999·8, i.e. g ≤ 0.018331 ✓.
- **η and e_{C,0}.** Each majorant decreases in ℓ (exp(−7ℓ/8) and exp(−3ℓ/16) dominate). They are 10^{−121593} and 10^{−26053} at
  ℓ = 3.2·10⁵ ✓.
  - The constants check: mT′/2π ≥ q, √m ≤ √π·e^{ℓ/16}, c₁(0) ≤ (2π/5)e^{ℓ/8}, and √(T′/7.49) − 1.5 ≥ 0.25e^{7ℓ/16}.
- **Q ≥ 0.925001** ✓.

**Item 6: first contact.**
- The barrier argument (REVIEW_P5 §4) needs: every zero with \|y\| ≥ √b(L), at every t in the contraction phase [t_min(L), T(L)], lies in
  a bounded x-range.
- Lemma Z′ gives exactly that:
  - y_b = min(0.01, 1/L) = √(min(10⁻⁴, L⁻²)) = √b ✓;
  - t ∈ [t_min, ½] ⊃ [t_min, T(L)], since T ≤ 0.2764 ✓;
  - \|y\| ≤ 1 holds for every zero at t ≥ 0 (de Bruijn) ✓;
  - one radius X(L) for all such t and y is more than needed.
- Siegel zeros (on iℝ, \|y\| = \|1 − 2β\| ≤ 1) are untouched and allowed ✓.

**Item 7: the 9/32 claim and the values.**
- Λ-bound at L₀ = **0.2764281989 ± 5e−11** < 0.28125 ✓.
- On [L₀, 4·10⁴], T is decreasing (rhi_monotone: dT/dL ≤ −1.13e−8 in Arb, REVIEW_P5_A11), and b is non-increasing.
- For L ≥ 4·10⁴: (2 + k(1 − 2t_min))/(2 + kb) ≤ 1 + k/2, and log(1 + k/2)/k decreases (u/(1 + u) < log(1 + u)). At
  k(4·10⁴) = 17 884.755 that is **5.0874e−4**, so T ≤ 10⁻⁴ + 5.09e−4 ✓.
- Sample values: 6.087e−4 (4·10⁴), 2.640e−4 (10⁵), 3.154e−5 (10⁶), 4.70e−8 (10⁹).
- The asymptotic is √5·loglog m/log m ✓.

## Notes

- **N-x (p2z_arb).** Each box is evaluated at x = X_box = 4e^{ℓ₀ − L_lo}. That is the **largest** X(L) over the box:
  - in region A, X(L) = 4e^{3.2·10⁵ − L} decreases in L;
  - in region B, ℓ₀ = 8L_hi overshoots.
  
  So part 2 checks zero-freeness on x ≥ X_box ≥ X(L), a box-wise larger radius than Lemma Z′ states. It is still a valid independent
  check, since any finite radius suffices for C2. To check X(L) itself, use the box minimum (L_hi in A, and 8L_lo − L_lo with ℓ = 8L in
  B), or say "checks x ≥ X_box". Lemma Z′'s analytic proof covers X(L) exactly.
- **N-m.** Update §A.12.4 (i) and the component-4 line: N2 is now re-read at source by bb (this review), and Prop 4.18's proof is
  m-general. Keep the note that FGMPS's statement of Prop 4.18 is range-limited and that the extension is ours (read off its proof).
- **For the statement of record** (the user's release decision): "C2 is complete in the Arb trust class: AI-written proofs, reviewed
  by one AI reviewer (bb), with Arb certificates and sources read at source. It is not Lean, not an operator read-back, and FGMPS is an
  unrefereed Oct-2026 preprint." It is a large-conductor bound on Λ_χ for real primitive χ, not GRH. A Lean statement layer remains
  optional.

conjecture1_proved = False. AI review by bb, NOT an operator read-back.
