# REVIEW_P5_FINAL: bb's delta on P5's final memo (§A.13, the C2 statement of record)

2026-10-31. **AI review by bb, NOT an operator read-back.** No Lean or lake was run, and nothing was executed beyond md5s. No P5 file
was written.

**Object.**
- P5/memo.md **1994d13686720a988f340c86d1b4c073** (1774 lines), against memo_pre_final.md (8c6b2b52); 207 lines differ.
- §A.13 is at :1350–1530.

## Verdict: PASS (two attribution nits for the table; three notes for the Lean builder)

1. **§A.13.1 matches what I reviewed exactly.**
   - The definitions are the same: t_min = min(10⁻⁴, 4/L), b = min(10⁻⁴, L⁻²), k = (4/√5)(L/4 − 1) − 2, and
     T = t_min + k⁻¹log((2 + k(1 − 2t_min))/(2 + kb)). They are identical to c2_domain.py's kk, T and Lam_bound, which I checked in
     REVIEW_P5_DELTA and REVIEW_P5_A12.
   - "All zeros real for every t ≥ T + b/2" is the same statement as Λ_χ ≤ T + b/2.
   - The hypotheses are real primitive χ, m ≥ 10⁸, either parity; no GRH, no zero-free half-plane, no zero verification; Siegel zeros
     allowed. That is correct.
   - The values match my Arb values: 0.2764281989 at 10⁸; 10⁻⁴ + log(1 + k/2)/k = 6.0874e−4 ≤ 6.09e−4 for L ≥ 4·10⁴; 0.0122908 and
     0.00182589.
2. **LX at L/4 − 0.77 is correct.** The certificate of record is the R-x re-run (lx_cover_Rx.out 77cadb55), whose worst value is
   −0.7689. With flo rounding that is ≥ −0.77, and −0.77 ≥ −1 is all the argument needs. The old −0.50 belonged to the pre-R-x run.
3. **§A.13.3: all 9 rows cite the right reviews, and every md5 matches the files**: REVIEW_P5 e909a59c, REVIEW_P5_DELTA 206b88e7,
   REVIEW_P5_A11 e570fc33 and REVIEW_P5_A12 f6cade54. The 440 993 leaves = 3 021 + 383 + 224 903 + 212 686 ✓. Two attributions should
   carry my caveats:
   - **Row 3.** The bridge numerator is "Telperion-certified (§6 item 9)". REVIEW_P5 §8 lists the Telperion-emitted numerators as
     *not checked* by bb. I checked only that the memo's Planat numerator (c² − 1)(c² − 5) is Prop. 2.3's. Write "Telperion-certified;
     not re-checked by bb".
   - **Row 4b.** "Proved v-monotonicity (§A.9.2)": REVIEW_P5_DELTA item 4 says (a) was spot-checked and (b)–(g) were **read, not fully
     re-derived** by bb. Add that.

**Notes for the Lean builder (§A.13.4).**
- **STL needs L > 4·10⁴.** §A.9.3's proof (:858) uses "FE pieces ≤ exp(−(p/2)L − …) with L ≥ 4·10⁴". The Lean `STL` has no L
  hypothesis; τ ≤ 0.0175 and R ≥ 2.618 imply only L ≥ 6 531. Add `(hL : 40000 < Lc m)`, which matches its only use, via
  `STL_applies`. The alternative is a proof note that the FE bound already holds at L ≥ 6 531.
- **The notes on what each lemma needs are swapped.**
  - `STL_applies` needs T(L) ≤ 6.125e−4 for L > 4·10⁴. That comes from T ≤ 10⁻⁴ + log(1 + k/2)/k with k ≥ k(4·10⁴), not from T
    decreasing on [L₀, 4·10⁴]. Its second conjunct follows from t ≥ 4/L, which gives σ′ + 1 = 2.618034 ≥ 2.618.
  - `C2bound_lt_9_32` is the one that needs monotonicity on [L₀, 4·10⁴]. That is Arb-certified (rhi_monotone), so a Lean version needs
    either an interval replay or an analytic monotonicity proof.
- **TL_floor_C2 quantifies over all real x.** G1 covers 0 ≤ x ≤ 10⁴ and LX covers \|x\| ≥ 10⁴. Negative x needs S(−x) = S(x), which
  follows from H_t(−z̄) = conj H_t(z) (FGMPS p.19). State it as a lemma or a hypothesis.

## Status

With these attribution edits, the C2 statement of record is consistent with REVIEW_P5, REVIEW_P5_DELTA, REVIEW_P5_A11 and
REVIEW_P5_A12. Its trust class is:
- Arb certificates, plus sources read at source, plus AI-written proofs;
- one AI reviewer;
- not Lean, no operator read-back;
- FGMPS is an unrefereed preprint.

It is ready for the user's release decision. The Lean build is optional, and I will review its report when it lands.

conjecture1_proved = False. AI review by bb, NOT an operator read-back.
