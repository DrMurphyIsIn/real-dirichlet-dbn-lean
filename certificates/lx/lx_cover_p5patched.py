"""LX certification: S - L/4 >= -K0 for ALL x >= 1e4 (v >= 2500), over the C2 (R,tau) domain for L in [L0, 4e4]
(c2_domain.R_range), a in {0,1}; Arb boxes in (R, tau) with tl_big2.big2 mode 'xaware' (v-monotone, memo A.9.2)."""
import sys, time, math, json
sys.path.insert(0, '.')
from flint import arb
from y3_big2 import big2
from c2_domain_p5 import R_range, SIG, T
TSTAR = math.sqrt(T(4e4) / 2)
K0 = float(sys.argv[1]) if len(sys.argv) > 1 else 1.0
TLO = float(sys.argv[2]) if len(sys.argv) > 2 else math.sqrt(1e-4 / 2) * 0.999
THI = float(sys.argv[3]) if len(sys.argv) > 3 else 0.3718
T0 = time.time(); res = dict(boxes=0, failed=[], worst=math.inf)
tau = TLO
while tau < THI:
    tb = min(tau * 1.03, THI)
    if tau < TSTAR < tb: tb = TSTAR      # R-x / C3 (bb REVIEW_P5_DELTA): R_hi(tau) peaks at tau*; split there
    r1 = R_range(tau); r2 = R_range(tb)
    rr = [r for r in (r1, r2) if r]
    if not rr: tau = tb; continue
    Rlo = min(r[0] for r in rr) - 1e-6; Rhi = max(r[1] for r in rr) + 1e-6
    stack = [(Rlo + (Rhi - Rlo) * j / 8, Rlo + (Rhi - Rlo) * (j + 1) / 8, 0) for j in range(8)]
    while stack:
        a_, b_, d = stack.pop()
        for par in (0, 1):
            S, info = big2(arb(a_).union(arb(b_)), arb(tau).union(arb(tb)), 2500, a=par)
            res['boxes'] += 1
            if S < -K0:
                if d < 10:
                    m = (a_ + b_) / 2; stack += [(a_, m, d + 1), (m, b_, d + 1)]; break
                res['failed'].append((a_, b_, tau, tb, par, S, info.get('why'))); continue
            res['worst'] = min(res['worst'], S)
    print(json.dumps(dict(tau=[tau, tb], boxes=res['boxes'], worst=res['worst'], failed=len(res['failed']), sec=round(time.time()-T0,1))), flush=True)
    tau = tb
res['seconds'] = round(time.time() - T0, 1)
print(json.dumps(res))
