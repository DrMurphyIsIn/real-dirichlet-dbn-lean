"""Y3: the landing bound from a certified floor, in Arb (outward).  One-step H-B comparison (Thm 9, one step) at probe p:
   S(x, p, t) >= L/4 + CF  for t in [t_min, t_hi], all x   =>   k = 4(L/4 + CF)/p - 8/(p^2 - q0)  (needs p^2 >= 5 q0, k > 0),
   T(L) = t_min + log((2 + k (q0 - 2 t_min)) / (2 + k b)) / k   (needs T(L) <= t_hi),   Lambda_chi <= T(L) + b/2.
T is decreasing in k (T - t_min = int_b^{q0-2tmin} dq/(2+kq)) and k is increasing in L, so the bound over L >= L_lo is the
value at L_lo.  Usage: python3 y3_bounds.py p CF0 CF1 q0 [t_hi]   (p, CF*, q0 as exact decimal/rational strings)."""
import sys, json
from flint import arb, ctx
ctx.prec = 128
def bound(L, p, CF, q0, tmin=arb(1) / 10000, b=arb(1) / 10000):
    assert p * p >= 5 * q0
    k = 4 * (L / 4 + CF) / p - 8 / (p * p - q0)
    assert k > 0
    T = tmin + ((2 + k * (q0 - 2 * tmin)) / (2 + k * b)).log() / k
    return T, T + b / 2, k
def frac(s):
    if '/' in s: n, d = s.split('/'); return arb(n) / arb(d)
    return arb(s)
if __name__ == '__main__':
    p = frac(sys.argv[1]) if sys.argv[1] != 'sqrt5' else arb(5).sqrt()
    CF = {0: arb(float(sys.argv[2])), 1: arb(float(sys.argv[3]))};   # R-round: the float the sweep compared against
    q0 = frac(sys.argv[4]); t_hi = arb(float(sys.argv[5])) if len(sys.argv) > 5 else arb(0.5)
    mlo = {0: 5, 1: 3}
    out = dict(p=sys.argv[1], CF0=sys.argv[2], CF1=sys.argv[3], q0=sys.argv[4], rows=[])
    worst = None
    for a in (0, 1):
        for m in [mlo[a], 4, 7, 8, 11, 12, 100, 400, 1000, 10 ** 4, 10 ** 5, 10 ** 6, 10 ** 7, 10 ** 8]:
            if m < mlo[a]: continue
            L = (arb(m) / arb.pi()).log()
            T, Lam, k = bound(L, p, CF[a], q0)
            assert T <= t_hi
            out['rows'].append(dict(a=a, m=m, k=float(k.lower()), T_up=float(T.upper()), Lambda_up=float(Lam.upper()),
                                    gain_vs_9_32_lo=float((arb(9) / 32 - Lam).lower())))
            if m == mlo[a]:
                worst = Lam if worst is None else (Lam if Lam > worst else worst)
    out['uniform_Lambda_up'] = float(worst.upper()); out['uniform_lt_9_32'] = bool(worst < arb(9) / 32)
    out['uniform_lt_1_2'] = bool(worst < arb(1) / 2)
    print(json.dumps(out, indent=1))
