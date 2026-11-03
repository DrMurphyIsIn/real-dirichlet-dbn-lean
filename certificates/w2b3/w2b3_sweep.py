"""W2B3 cover sweep at probe p (env Y3_P), bulk/tail split delta: certifies BOTH
   S_chi(x, p, t) - L/4 >= CF   and   G := d/dp S_chi(x, p, t) <= CG
for parity a, L = log(m/pi) in [L_lo, L_hi], t in [t_lo, t_hi] (t_lo <= 1e-4 asserted when requested), and EVERY x >= 0
(x < 0 by S(-x) = S(x) and G(-x) = G(x): H_t(-conj z) = conj H_t(z)), for every real primitive chi with that (L, a):
   G1 part: 0 <= x <= 1e4, w2b3_cert.floor_box over (R, tau, x) boxes (y3_cert 5b375c5b + the W2B3 G accumulators);
   LX part: x >= 1e4, w2b3_big2.big2 'xaware' v0 = 2500 over (R, tau) boxes (y3_big2 aafeba32 + the W2B3 G accumulators).
Structure, (R, tau) parametrisation, R-cover (four-corner hull, padded outward), contiguous tau-slabs and the bisection order
(x, then tau, then R; depth caps 24 / 16) are those of y3_sweep.py 129799ab; a box passes iff S >= CF and G <= CG.
Usage: Y3_P=3.5 python3 w2b3_sweep.py a m_lo m_hi t_hi CF CG prefix [tau_ratio] [t_lo] [delta]
   L_lo = log(m_lo/pi) rounded DOWN, L_hi = log(m_hi/pi) rounded UP (both asserted in Arb)."""
import os, sys, json, math, time
for v in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS'): os.environ[v] = '1'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from flint import arb, ctx
from w2b3_cert import floor_box
from w2b3_big2 import big2
from y3_big import SIG, flo

def main():
    a = int(sys.argv[1]); m_lo = int(sys.argv[2]); m_hi = int(sys.argv[3]); t_hi = float(sys.argv[4])
    CF = float(sys.argv[5]); CG = float(sys.argv[6]); prefix = sys.argv[7]
    ratio = float(sys.argv[8]) if len(sys.argv) > 8 else 1.02
    t_lo = float(sys.argv[9]) if len(sys.argv) > 9 else 1e-4
    delta = float(sys.argv[10]) if len(sys.argv) > 10 else 0.5
    assert 0 < delta <= 0.5          # Rademacher's convexity bound (BMOR Lemma 5.6) is used for -delta <= sigma <= 1 + delta, delta <= 1/2
    _p = ctx.prec; ctx.prec = 200
    L_lo = flo((arb(m_lo) / arb.pi()).log())                       # rounded DOWN (outward)
    Lh = (arb(m_hi) / arb.pi()).log(); L_hi = float(Lh.upper())
    if arb(L_hi) < Lh: L_hi = math.nextafter(L_hi, math.inf)
    assert arb(L_lo) <= (arb(m_lo) / arb.pi()).log() and arb(L_hi) >= Lh
    TAU_LO = math.nextafter(math.sqrt(t_lo / 2), 0.0) * 0.9999; TAU_HI = math.sqrt(t_hi / 2) * 1.0001
    assert 2 * arb(TAU_LO) ** 2 <= arb(t_lo) and 2 * arb(TAU_HI) ** 2 >= arb(t_hi)
    ctx.prec = _p
    XB = [0.0, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 256.0, 512.0, 1024.0, 2048.0, 4096.0, 8192.0, 1e4]
    # N4 (auditor review REVIEW_W2B3): the ledger records the md5 of the certifier code it ran (R-asrun)
    import hashlib
    here = os.path.dirname(os.path.abspath(__file__))
    cert_md5 = {f: hashlib.md5(open(os.path.join(here, f), 'rb').read()).hexdigest()[:8]
                for f in ('w2b3_cert.py', 'w2b3_big2.py', 'w2b3_sweep.py')}
    cert_md5['y3_big.py'] = hashlib.md5(open(os.path.join(here, 'y3_big.py'), 'rb').read()).hexdigest()[:8]
    led = dict(p=os.environ['Y3_P'], a=a, m_lo=m_lo, m_hi=m_hi, L_lo=L_lo, L_hi=L_hi, t_lo=t_lo, t_hi=t_hi, tau=[TAU_LO, TAU_HI],
               CF=CF, CG=CG, delta=delta, ratio=ratio, g1_cert=0, lx_cert=0, evals=0, failed=[], worst_g1=math.inf, worst_lx=math.inf,
               maxG_g1=-math.inf, maxG_lx=-math.inf, slabs=0, certifier_md5=cert_md5)
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
        stack = [(R0, R1, tau, tb, XB[k], XB[k + 1], 0) for k in range(len(XB) - 1)]
        while stack:
            r0, r1, u0, u1, x0, x1, d = stack.pop()
            S, G, _ = floor_box(None, None, arb(x0).union(arb(x1)), a=a, delta=delta, Rb=arb(r0).union(arb(r1)), taub=arb(u0).union(arb(u1)))
            led['evals'] += 1
            if S >= CF and G <= CG:
                led['g1_cert'] += 1; led['worst_g1'] = min(led['worst_g1'], S); led['maxG_g1'] = max(led['maxG_g1'], G); continue
            if d >= 24:
                led['failed'].append(('G1', r0, r1, u0, u1, x0, x1, S, G)); continue
            wx = (x1 - x0) / max(0.05, 0.02 * (x0 + 1)); wu = (u1 / u0 - 1) / 0.002; wr = (r1 - r0) / 0.01
            k = max((wx, 0), (wu, 1), (wr, 2))[1]
            if k == 0: m = (x0 + x1) / 2; stack += [(r0, r1, u0, u1, x0, m, d + 1), (r0, r1, u0, u1, m, x1, d + 1)]
            elif k == 1: m = math.sqrt(u0 * u1); stack += [(r0, r1, u0, m, x0, x1, d + 1), (r0, r1, m, u1, x0, x1, d + 1)]
            else: m = (r0 + r1) / 2; stack += [(r0, m, u0, u1, x0, x1, d + 1), (m, r1, u0, u1, x0, x1, d + 1)]
        stack = [(R0, R1, tau, tb, 0)]
        while stack:
            r0, r1, u0, u1, d = stack.pop()
            S, G, info = big2(arb(r0).union(arb(r1)), arb(u0).union(arb(u1)), 2500, a=a, delta=delta)
            led['evals'] += 1
            if S >= CF and G <= CG:
                led['lx_cert'] += 1; led['worst_lx'] = min(led['worst_lx'], S); led['maxG_lx'] = max(led['maxG_lx'], G); continue
            if d >= 16:
                led['failed'].append(('LX', r0, r1, u0, u1, S, G, info.get('why'))); continue
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
