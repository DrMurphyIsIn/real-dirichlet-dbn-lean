# REVIEW_PRERELEASE_v2.0.0: bb's pre-release review of the Λ_χ v2.0.0 package

2026-11-01. **AI review by bb, NOT an operator read-back.** No Lean or lake was run. I re-ran copies of p2z_arb.py and
rhi_monotone.py in bb's scratchpad (p5comp/), with the outputs written there. I read the package, diffed and md5-checked it, and
used mpmath for constants. No team file other than this one was written. Nothing was committed, pushed or posted.

**Object.** ~/rh-team/pub_lambda_chi/v2/, 85 files.
- paper/main.tex 670c255a, main.pdf f642bea1, refs.bib d3afcab6, CHANGES_v2.md 5da9dd1c.
- certificates/MANIFEST.md 4fa02d6c and README.md 37679e29.
- lean/DQ1_P5.lean 01a24ec6 and NOTE.md da84f043.
- provenance/P5_memo_extract.md 4b3688f2 and Y3_memo_extract.md ebb8f66b.
- Against Y3/memo.md 3779ce49, P5/memo.md e3676c4c §A.13, and my reviews.

## Verdict: PASS WITH REQUIRED EDITS

There is no mathematical error. The required edits are seven wording or label corrections (R1–R7). With them applied, the
package is ready for the lead's release-repo assembly delta.

## Answers to the lead's five questions

**1. Theorem statements and trust classes.**
- **Thm 7.1 (C2)** is P5 §A.13's statement of record, symbol for symbol.
- **Thms 7.2 (Y3) and 7.3 (U1) and Rem 7.4 (U2)** match Y3 §3.4–3.5 and REVIEW_Y3 §6. Every value in the landing table equals my
  independent mpmath values.
- **T1–T4** describe the classes correctly (T1 is one build, one kernel, no replay; T4 lists the cited preprints), except for T2's
  two sentences (R1, R2).
- **Labels.** "0.2783189 (certificate)" is right. The Lean-rational displays are not upper bounds (R3).

**2. Credit and citations.**
- **Hakimoglu-Brown** (2610.12803), read by me at source this session:
  - the p. 9 inequality q′ ≤ −2 − (4q/p)S + 8q/(p² − q) for p² ≥ 5q;
  - Thm 9 (stepped comparison, k_i = 4C_i/p − 8/(p² − q_i), t_n ≤ 1/5, b = 1/25, Lemma 2 confinement);
  - p. 11 "These three functions are decreasing".

  All are quoted accurately. Presenting the Dirichlet transposition (FGMPS Prop 3.2 / Lemma 3.7 dynamics, Lemma Z′ in place of
  Lemma 2, our constants) as an AI-written T3 argument rather than a citation **is the right framing** ✓. The Heath-Brown →
  Hakimoglu-Brown correction is right.
- **FGMPS Lemma 4.2(5) and the one-liner.** The self-contained proof (y = n + θ; Γ(1+θ) ≤ 1 by log-convexity with Γ(1) = Γ(2) = 1;
  n − 1 factors each ≤ y) gives log Γ(y) ≤ (y − 1)log y ≤ y log y for y ≥ 1 ✓ PROVED. IIb needs y ≥ 1250 ✓.
- **FGMPS Thm 4.3 / Prop 4.18 for every N.** This is P5's reading, which I confirmed at source (REVIEW_P5_A12, N2). The paper labels
  it "our reading … checked at source by the auditor but by no one else" ✓.

**3. certificates/.**
- **All 65 files are byte-identical to their sources** (cmp, file by file): Y3/g1_rerun, Y3/scripts and P5/scripts. MANIFEST's md5s
  are right.
- Row 4a is Y3/g1_rerun ✓ (four ledgers as in REVIEW_Y3_G1). Row 4b is lx_cover_p5patched.out 5aa52aef ✓.
- The MANIFEST note that the u20/c25 ledgers came from y3_big2 a8f10bcd and reproduce bit-identically with aafeba32 is
  **accurate** (REVIEW_Y3 §4: all ten bands re-swept with B4).
- The additions are right to keep: y3_bands, p5_components, the STL illustration and U2.
- **New today: I re-ran p2z_arb.py and rhi_monotone.py from copies, and both outputs are byte-identical to the packaged ones**
  (p2z_arb.json 2b41dc9b, .DONE 69319cef, rhi_monotone.out 98c86374). Every ledger the v2 theorems rest on has now been reproduced
  by the auditor:
  - G1, LX, u20 ×2, c25 ×2 and p2z_small (earlier);
  - p2z_arb and rhi_monotone (now).

  STL has no ledger.

**4. Public hygiene.**
- No Claude-Session line, no /Users or /private path, no e-mail address, and no internal trading/Arda or socket names in any file
  that will ship. CHANGES_v2.md is an internal draft; its single "/Users" and "arda" hits are the scan description itself.
- All eight review copies and P5_SUPERSEDED.md are byte-identical to the originals.
- Both memo extracts contain their stated line ranges **verbatim** (P5 139–151 and 410–1530 of e3676c4c; Y3 1–512 and 602–720 of
  3779ce49). The omitted Y3 §6–§7 are the obstruction table and the ledger lists.
- **Home-relative paths: keep them.** The copies are md5-pinned records. Redacting would break byte identity, and the paths carry no
  personal data. Add one sentence to provenance/README (or NOTICE): "paths of the form ~/rh-team/… in these records refer to the
  programme's internal working tree; they are not part of the release."
- **The "conjecture1_proved = False" / dive framing:** acceptable as verbatim records. The extract headers already explain the
  context.

**5. The "not verified at source" list: acceptable as labelled.**
- de Bruijn Thm 13 via FGMPS Thm 2.6 (T4, as in v1).
- Rademacher via BMOR Lemma 5.6 (T4, cited as quoted there).
- The tilt identity, LX, STL, Lemma Z′, B3 and B4 as T3, with their reviews.
- The Telperion bridge numerator is disclosed in Limitations item 14 and in the component-3 row.

## Required edits

- **R1 "bit for bit".** My reproductions matched every certified field, but wall-clock/`sec` fields differ. Only p2z_arb,
  rhi_monotone and the LX rows-minus-sec are byte-identical. Replace "reproduced bit for bit" / "bit-identical ledgers" with
  **"reproduced, identical in every field except wall time"** in these places:
  - the abstract;
  - §1.5 T2;
  - table row 4a;
  - §7.5 (the second paragraph);
  - Use of AI ("reproduced every certificate of record bit for bit");
  - Appendix B (the REVIEW_Y3_G1 line).

  §7.2's text under the G1 table, §7.8 and certificates/README already say it correctly. T2's "every ledger that §7 depends on" is
  now literally true; cite this review for p2z_arb and rhi_monotone, and add it to provenance/.
- **R2 (T2, §1.5).** "reviewed by one AI reviewer, who found four defects" is wrong. B1–B3 were found by the Y3 session and B4 by the
  auditor, as §7.3 itself says. Suggested wording: "…reviewed by one AI reviewer; four defects in an earlier version were found, three
  by a second agent session and one by the reviewer (§7.3)."
- **R3 (the Lean-rational constants).** "0.2791113 (Lean-rational)" and "0.2783196" are y3_lean_consts.py's `:.7f` displays, rounded
  to nearest. They lie **below** the exact rational-floor values:
  - 0.27911134136… (CF = 385/1000);
  - 0.27831962506… (CF = 3599/10000).

  So they are not bounds. Either drop them, or quote the rounded-up values 0.2791114 and 0.2783197. (The Lean statements use
  27912/100000 and 27833/100000, which are safe.) Fix this in §7.5, CHANGES §2 and the Zenodo text if it is quoted.

  Related: **Thm 7.3 (U1) even, "0.4908369"**, is a valid bound, since the certificate value is 0.49083455. But it is the
  Lean-rational display, while Thm 7.2 uses certificate values. For consistency use **0.4908346** (certificate, rounded up), or keep
  0.4908369 with a note. The odd 0.4932941 is the certificate value rounded up ✓.
- **R4 (§7.6).** "A search of the literature (alphaXiv, by the Y3 session and the auditor)". The search was Y3's. The auditor read
  FGMPS and Hakimoglu-Brown at source but ran no literature search. Say "by the Y3 session".
- **R5 (§7.2 Values).** "…much larger than 1/log N, as any bound that admits Siegel zeros must be" states as fact what §7.7 rightly
  calls a sanity heuristic. Drop the clause, or write "consistent with the Siegel sanity check of §7.7".
- **R6 (§1.5 and §7.1).** "The conductor enters through the single term ℓ/4" / "the whole conductor dependence of S_χ is the term ℓ/4".
  ℓ also enters D through the centre R = (1+p)/2 + tℓ/4, which only moves it to the right. Say "explicitly only through ℓ/4, and
  through the centre R, which ℓ only moves to the right."
- **R7 (§7.4, last sentence).** "the kernel-checked content … is exactly this: *if* Theorem C2 holds, then its bound is below 9/32".
  The Lean theorem is unconditional arithmetic. Write: "the kernel-checked content of version 2 is the arithmetic fact
  C2bound(N) < 9/32 for N ≥ 10⁸; that C2bound bounds Λ_χ is classes T2–T4."

## Nits

- N1. §7.1 "every certifier … run on one core": G1 ran with six workers, one core each.
- N2. §7.6 "Platt's verification of GRH to height 10⁸/N": FGMPS p. 5 has h_m = max(10⁸/m, 200 + A(m)10⁷/m). Say "to height h_N ≥ 10⁸/N".
- N3. §7.7 "The method is also blind to ζ": unclear. Say instead "it gives nothing for the zoo fakes, which violate its Euler-product
  inputs".
- N4. certificates/README §4 "Both were run by P5": add "and reproduced byte-identically by the auditor (REVIEW_PRERELEASE_v2.0.0)".
- N5. The TODOs (release date, v2 DOI, the author's confirmation in Use of AI) must be filled at release. The lead's assembly delta
  is the place to check them.
- N6. "an independent AI auditor" (abstract): "a separate AI auditor session" is more exact, since the auditor is the same model in
  the same programme.

## bb's files (scratchpad p5comp/)

p2z_arb.py / rhi_monotone.py copies; outputs p2z_arb.json 2b41dc9b, p2z_arb.DONE 69319cef and rhi_monotone.out 98c86374, all
byte-identical to certificates/p5_components/. Constants: mpmath at 40 digits (inline).

No RH-facing claim. AI review by bb, NOT an operator read-back.
