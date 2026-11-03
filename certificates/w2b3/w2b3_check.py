"""W2B3 check: (1) the S floor of w2b3_cert.floor_box is BIT-IDENTICAL to y3_cert.floor_box on a set of boxes (the extension adds
accumulators only); (2) the certified G upper bound at t ~ 0, x ~ 0 is compared with the exact model (1/16) psi'((sigma'+a)/2) +
(1/4) psi_2(sigma') (it must be >= the model, since the model is the true value at x = 0, t = 0 up to the tilt); (3) the same for
w2b3_big2.big2 vs y3_big2.big2 (S identical; G printed).  Usage: Y3_P=3.5 python3 w2b3_check.py"""
import os, sys, math, time
for v in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS'): os.environ[v] = '1'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from flint import arb, ctx
import mpmath as mp
from y3_big import SIG, P5
import y3_cert, w2b3_cert
p = float(P5.mid()); sp = (1 + p) / 2
def model_G(R, a):
    psi2 = mp.zeta(R, derivative=2) / mp.zeta(R) - (mp.zeta(R, derivative=1) / mp.zeta(R)) ** 2
    return float(psi2 / 4 + mp.polygamma(1, (R + a) / 2) / 16)
def model_S(R, a):
    return float(mp.digamma((R + a) / 2) / 4 + (mp.zeta(R, derivative=1) / mp.zeta(R)) / 2)
print(f"p = {p}, sigma' = {sp}")
ok = True
for a in (1, 0):
    for (L, t0, t1, x0, x1) in [(13.08, 1e-4, 1.02e-4, 0.0, 0.25), (13.08, 1e-4, 1.02e-4, 0.25, 0.5), (13.08, 0.05, 0.051, 0.0, 0.25),
                                (13.08, 0.15, 0.153, 0.0, 0.25), (13.08, 0.29, 0.296, 0.0, 0.25), (13.08, 0.1, 0.102, 4.0, 4.5),
                                (13.08, 0.1, 0.102, 500.0, 512.0), (17.3, 0.2, 0.204, 0.0, 0.25)]:
        Lb = arb(L).union(arb(L + 0.02)); tb = arb(t0).union(arb(t1)); xb = arb(x0).union(arb(x1))
        T0 = time.time(); S1, _ = y3_cert.floor_box(Lb, tb, xb, a=a); T1 = time.time()
        S2, G2, info = w2b3_cert.floor_box(Lb, tb, xb, a=a); T2 = time.time()
        R = sp + t0 * L / 4
        same = (S1 == S2)
        ok = ok and same
        print(f"a={a} L={L} t=[{t0},{t1}] x=[{x0},{x1}]: S y3={S1:.6f} w2b3={S2:.6f} identical={same} | G<={G2:.4f} (model {model_G(R, a):.4f}, S model {model_S(R, a):.4f}) "
              f"K2={info.get('K2', float('nan')):.4f} K3={info.get('K3', float('nan')):.4f} [{T1-T0:.2f}s / {T2-T1:.2f}s]", flush=True)
print("G1 S bit-identical on all boxes:", ok)
try:
    import y3_big2, w2b3_big2
    for a in (1, 0):
        for (R, tau) in [(2.26, 0.0071), (2.3, 0.1), (2.5, 0.2), (2.9, 0.3), (3.4, 0.39)]:
            Rb = arb(R).union(arb(R + 0.01)); taub = arb(tau).union(arb(tau * 1.02))
            S1, _ = y3_big2.big2(Rb, taub, 2500, a=a); S2, G2, info = w2b3_big2.big2(Rb, taub, 2500, a=a)
            print(f"LX a={a} R={R} tau={tau}: S y3={S1:.6f} w2b3={S2:.6f} identical={S1 == S2} | G<={G2:.4f} (model {model_G(R, a):.4f}) why={info.get('why')}", flush=True)
except ImportError as e:
    print("big2 check skipped:", e)
