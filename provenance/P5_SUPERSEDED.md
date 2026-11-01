# P5 certificate outputs: SUPERSEDED (lead, 2026-11-01; R-asrun)

The G1 ledgers in P5 (`g1_corner_a0/a1`, `g1_rem_a0_m*`, `g1_rem_a1_s1`) and `lx_cover_Rx.out` (77cadb55) are **SUPERSEDED**. They
were produced by certifiers with defects B1–B4, found by Y3 and bb (Y3 memo 3779ce49 §4; REVIEW_Y3 799a8fa8). They are kept as
history only.

The certificates of record for C2 are now:
- **Row 4a (G1):** y3_cert 5b375c5b, y3_big aa232458 and c2_domain f84d38a1, driver g1_sweep_y3 a591107d. The ledgers are in
  Y3/g1_rerun:

  | job | DONE md5 |
  |---|---|
  | corner_a0 | 79194715 |
  | corner_a1 | 0c5a24e4 |
  | rem_a0 | 43e1f9bc |
  | rem_a1 | f630953b |

  There are 67,679 leaves, 0 capped, 0 failed, and the worst value is −0.9999990867. bb reproduced the run bit-for-bit
  (REVIEW_Y3_G1 4b4d8aab).
- **Row 4b (LX):** y3_big2 aafeba32 and lx_cover_p5patched.out 5aa52aef: 3,069 boxes, 0 failed, worst −0.7689010122. bb
  reproduced it.

The STL output and the Lean "< 9/32" theorem are unaffected.
