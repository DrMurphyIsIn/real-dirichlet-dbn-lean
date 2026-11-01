"""Y3 TL-floor sweep at a general probe height p (env Y3_P).  Certifies  S_chi(x, p, t) - L/4 >= CF  for
   parity a, L = log(m/pi) in [L_lo, L_hi], t in [t_lo, t_hi] (t_lo <= 1e-4 asserted when requested), and EVERY x >= 0
(x < 0 by S(-x) = S(x)), for every real primitive chi with that (L, a):
   G1 part:  0 <= x <= 1e4, y3_cert.floor_box over (R, tau, x) boxes   (P5 tl_arb_cert 4a001119 + Y3 patch B1);
   LX part:  x >= 1e4,      y3_big2.big2 'xaware' v0 = 2500 over (R, tau) boxes  (P5 tl_big2 cc065977 + Y3 B1-B3).
(R, tau) parametrisation: R = sigma' + tau^2 L / 2, tau = sqrt(t/2), sigma' = (1+p)/2.  For a tau-slab [tau0, tau1] the
R-ball is the hull of the four corners (R is monotone in tau for fixed L and monotone in L: R-cover), computed in Arb and
padded outward.  Boxes failing CF are bisected (x first in G1, then tau, then R); depth-capped failures are recorded.
Usage: Y3_P=20 python3 y3_sweep.py a m_lo m_hi t_hi CF prefix [tau_ratio] [t_lo]
   L_lo = log(m_lo/pi) rounded DOWN, L_hi = log(m_hi/pi) rounded UP (both asserted in Arb)."""
import os, sys, json, math, time
for v in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS'): os.environ[v] = '1'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from flint import arb, ctx
from y3_cert import floor_box
from y3_big2 import big2
from y3_big import SIG, flo

def main():
    a = int(sys.argv[1]); m_lo = int(sys.argv[2]); m_hi = int(sys.argv[3]); t_hi = float(sys.argv[4])
    CF = float(sys.argv[5]); prefix = sys.argv[6]; ratio = float(sys.argv[7]) if len(sys.argv) > 7 else 1.02
    t_lo = float(sys.argv[8]) if len(sys.argv) > 8 else 1e-4
    _p = ctx.prec; ctx.prec = 200
    L_lo = flo((arb(m_lo) / arb.pi()).log())                       # rounded DOWN (outward)
    Lh = (arb(m_hi) / arb.pi()).log(); L_hi = float(Lh.upper())
    if arb(L_hi) < Lh: L_hi = math.nextafter(L_hi, math.inf)
    assert arb(L_lo) <= (arb(m_lo) / arb.pi()).log() and arb(L_hi) >= Lh
    TAU_LO = math.nextafter(math.sqrt(t_lo / 2), 0.0) * 0.9999; TAU_HI = math.sqrt(t_hi / 2) * 1.0001
    assert 2 * arb(TAU_LO) ** 2 <= arb(t_lo) and 2 * arb(TAU_HI) ** 2 >= arb(t_hi)
    ctx.prec = _p
    XB = [0.0, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 256.0, 512.0, 1024.0, 2048.0, 4096.0, 8192.0, 1e4]
    led = dict(p=os.environ['Y3_P'], a=a, m_lo=m_lo, m_hi=m_hi, L_lo=L_lo, L_hi=L_hi, t_lo=t_lo, t_hi=t_hi, tau=[TAU_LO, TAU_HI],
               CF=CF, ratio=ratio, g1_cert=0, lx_cert=0, evals=0, failed=[], worst_g1=math.inf, worst_lx=math.inf, slabs=0)
    T0 = time.time(); last = T0
    def R_ball(u0, u1):
        Ls = (arb(L_lo), arb(L_hi)); us = (arb(u0), arb(u1))
        vals = [SIG + u * u * L / 2 for u in us for L in Ls]
        lo_ = min(float(v.lower()) for v in vals); hi_ = max(float(v.upper()) for v in vals)
        return math.nextafter(lo_, -math.inf) - 1e-9, math.nextafter(hi_, math.inf) + 1e-9
    tau = TAU_LO
    while tau < TAU_HI:
        tb = min(tau * ratio, TAU_HI)
        R0, R1 = R_ball(tau, tb)
        # G1: stack of (R0, R1, u0, u1, x0, x1, depth)
        stack = [(R0, R1, tau, tb, XB[k], XB[k + 1], 0) for k in range(len(XB) - 1)]
        while stack:
            r0, r1, u0, u1, x0, x1, d = stack.pop()
            S, _ = floor_box(None, None, arb(x0).union(arb(x1)), a=a, Rb=arb(r0).union(arb(r1)), taub=arb(u0).union(arb(u1)))
            led['evals'] += 1
            if S >= CF:
                led['g1_cert'] += 1; led['worst_g1'] = min(led['worst_g1'], S); continue
            if d >= 24:
                led['failed'].append(('G1', r0, r1, u0, u1, x0, x1, S)); continue
            wx = (x1 - x0) / max(0.05, 0.02 * (x0 + 1)); wu = (u1 / u0 - 1) / 0.002; wr = (r1 - r0) / 0.01
            k = max((wx, 0), (wu, 1), (wr, 2))[1]
            if k == 0: m = (x0 + x1) / 2; stack += [(r0, r1, u0, u1, x0, m, d + 1), (r0, r1, u0, u1, m, x1, d + 1)]
            elif k == 1: m = math.sqrt(u0 * u1); stack += [(r0, r1, u0, m, x0, x1, d + 1), (r0, r1, m, u1, x0, x1, d + 1)]
            else: m = (r0 + r1) / 2; stack += [(r0, m, u0, u1, x0, x1, d + 1), (m, r1, u0, u1, x0, x1, d + 1)]
        # LX: x >= 1e4 (v0 = 2500), all x by the v-monotonicity of the big2 bound (P5 memo A.9.2)
        stack = [(R0, R1, tau, tb, 0)]
        while stack:
            r0, r1, u0, u1, d = stack.pop()
            S, info = big2(arb(r0).union(arb(r1)), arb(u0).union(arb(u1)), 2500, a=a)
            led['evals'] += 1
            if S >= CF:
                led['lx_cert'] += 1; led['worst_lx'] = min(led['worst_lx'], S); continue
            if d >= 16:
                led['failed'].append(('LX', r0, r1, u0, u1, S, info.get('why'))); continue
            if (r1 - r0) > 0.01: m = (r0 + r1) / 2; stack += [(r0, m, u0, u1, d + 1), (m, r1, u0, u1, d + 1)]
            else: m = math.sqrt(u0 * u1); stack += [(r0, r1, u0, m, d + 1), (r0, r1, m, u1, d + 1)]
        led['slabs'] += 1
        tau = tb
        if time.time() - last > 60:
            led['sec'] = round(time.time() - T0, 1); open(prefix + '.json', 'w').write(json.dumps(led)); last = time.time()
    led['sec'] = round(time.time() - T0, 1); led['n_failed'] = len(led['failed']); led['failed'] = led['failed'][:20]
    led['complete'] = True
    open(prefix + '.json', 'w').write(json.dumps(led))
    open(prefix + '.DONE', 'w').write(json.dumps({k: led[k] for k in led if k != 'failed'}))
    print(json.dumps({k: led[k] for k in led if k != 'failed'}))

if __name__ == '__main__':
    main()
