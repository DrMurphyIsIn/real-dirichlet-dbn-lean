"""C3 support (P5 A.11): R_hi(tau) = sigma' + (t/4) min(Tinv(t), 4e4) is non-increasing for tau >= tau*, because
L*T(L) is strictly increasing on [L0, 4e4] (then L = Tinv(t) decreases in t, and t*L = L*T(L) decreases).  Arb proof:
d/dL [L T(L)] > 0 on every box of a cover of [L0d, 4e4] (forward-mode derivative with arb_series; b(L) piecewise).
For tau <= tau*, R_hi = sigma' + 1e4 t is increasing.  T is strictly decreasing on [L0, 4e4] (checked the same way),
so Tinv is well defined."""
import math
from flint import arb, arb_series, ctx
ctx.prec = 80
P = arb(5).sqrt()
def f_and_T(Lb, piece):
    L = arb_series([Lb, 1], prec=2)
    tm = arb(1) / 10000
    b = arb_series([arb(1) / 10000], prec=2) if piece == 'lo' else 1 / (L * L)
    k = (L - 4) / P - 2
    T = tm + ((2 + k * (1 - 2 * tm)) / (2 + k * b)).log() / k
    return (L * T).coeffs()[1], T.coeffs()[1]
L0d = math.nextafter(math.log(1e8 / math.pi), -math.inf)
bad = 0; n = 0; minf = None; maxT = None
for (a, b_, piece) in ((L0d, 100.0, 'lo'), (100.0, 4e4, 'hi')):
    N = 4000; r = (b_ / a) ** (1 / N)
    for i in range(N):
        lo_, hi_ = a * r ** i, (a * r ** (i + 1) if i < N - 1 else b_)
        df, dT = f_and_T(arb(lo_).union(arb(hi_)), piece)
        n += 1
        if not (df > 0 and dT < 0): bad += 1
        minf = df.lower() if minf is None else min(minf, df.lower()); maxT = dT.upper() if maxT is None else max(maxT, dT.upper())
print(dict(boxes=n, failures=bad, min_dLT_lower=float(minf), max_dT_upper=float(maxT)))
