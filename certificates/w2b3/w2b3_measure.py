"""W2B3 slab MEASUREMENT (COMPUTED lower/upper bounds on a fixed grid; NOT a cover certificate): for a band [m_lo, m_hi], parity a,
probe p (env Y3_P), bulk/tail split delta, records per tau-slab the minimum certified floor S - L/4 and the MAXIMUM certified
G = d/dp S over a fixed grid of boxes (G1: w2b3_cert.floor_box on x-boxes of width 0.25 for 0 <= x <= 16 and the y3_sweep x-grid
16..1e4; LX: w2b3_big2.big2 at v0 = 2500), R-cells of width <= 0.02.  Each box value is valid on its box, so the slab extremes
are valid bounds at that grid resolution (a certifying sweep bisects and typically improves them).
Output per slab: [t_lo, t_hi, minS_g1, minS_lx, maxG_g1, maxG_lx, argmin_S, argmax_G].
Usage: Y3_P=3.5 python3 w2b3_measure.py a m_lo m_hi t_hi prefix [ratio] [delta]"""
import os, sys, json, math, time
for v in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS'): os.environ[v] = '1'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from flint import arb, ctx
from w2b3_cert import floor_box
from w2b3_big2 import big2
from y3_big import SIG, flo
def main():
    a = int(sys.argv[1]); m_lo = int(sys.argv[2]); m_hi = int(sys.argv[3]); t_hi = float(sys.argv[4]); prefix = sys.argv[5]
    ratio = float(sys.argv[6]) if len(sys.argv) > 6 else 1.03
    delta = float(sys.argv[7]) if len(sys.argv) > 7 else 0.25
    _p = ctx.prec; ctx.prec = 200
    L_lo = flo((arb(m_lo) / arb.pi()).log()); Lh = (arb(m_hi) / arb.pi()).log(); L_hi = float(Lh.upper())
    if arb(L_hi) < Lh: L_hi = math.nextafter(L_hi, math.inf)
    ctx.prec = _p
    TAU_LO = math.nextafter(math.sqrt(1e-4 / 2), 0.0) * 0.9999; TAU_HI = math.sqrt(t_hi / 2) * 1.0001
    XB = [k * 0.25 for k in range(65)]   # x <= 16 only (the binding corner); 16 <= x <= 1e4 is left to the certifying sweep, which bisects
    # (the y3_sweep coarse cells 16..1e4 return -inf/+inf at this resolution on some slabs: a grid artefact, not a floor value)
    out = dict(p=os.environ['Y3_P'], a=a, m_lo=m_lo, m_hi=m_hi, L_lo=L_lo, L_hi=L_hi, t_hi=t_hi, ratio=ratio, delta=delta, slabs=[])
    T0 = time.time(); tau = TAU_LO; nev = 0
    def R_ball(u0, u1):
        Ls = (arb(L_lo), arb(L_hi)); us = (arb(u0), arb(u1))
        vals = [SIG + u * u * L / 2 for u in us for L in Ls]
        return min(float(v.lower()) for v in vals), max(float(v.upper()) for v in vals)
    while tau < TAU_HI:
        tb = min(tau * ratio, TAU_HI)
        R0, R1 = R_ball(tau, tb)
        nR = max(1, int(math.ceil((R1 - R0) / 0.02))); Rs = [R0 + (R1 - R0) * j / nR for j in range(nR + 1)]
        wS = math.inf; wSx = math.inf; wG = -math.inf; wGx = -math.inf; argS = None; argG = None
        for j in range(nR):
            Rb = arb(Rs[j]).union(arb(Rs[j + 1])); taub = arb(tau).union(arb(tb))
            for k in range(len(XB) - 1):
                S, G, _ = floor_box(None, None, arb(XB[k]).union(arb(XB[k + 1])), a=a, delta=delta, Rb=Rb, taub=taub); nev += 1
                if S < wS: wS = S; argS = (XB[k], XB[k + 1], Rs[j])
                if G > wG: wG = G; argG = (XB[k], XB[k + 1], Rs[j])
            S, G, info = big2(Rb, taub, 2500, a=a, delta=delta); nev += 1
            if S < wSx: wSx = S
            if G > wGx: wGx = G
        out['slabs'].append([2 * tau * tau, 2 * tb * tb, wS, wSx, wG, wGx, argS, argG])
        tau = tb
        if len(out['slabs']) % 20 == 0:
            s = out['slabs'][-1]; print(f"t=[{s[0]:.4f},{s[1]:.4f}] minS g1={s[2]:.4f} lx={s[3]:.4f} maxG g1={s[4]:.4f} lx={s[5]:.4f} argG={s[7]} [{time.time()-T0:.0f}s]", flush=True)
    out['evals'] = nev; out['sec'] = round(time.time() - T0, 1)
    json.dump(out, open(prefix + '.json', 'w'))
    open(prefix + '.DONE', 'w').write(json.dumps(dict(evals=nev, sec=out['sec'], nslabs=len(out['slabs']))))
    print(json.dumps(dict(evals=nev, sec=out['sec'], nslabs=len(out['slabs']))))
if __name__ == '__main__':
    main()
