"""W2B3 DESIGN (COMPUTED; NOT a certificate) from a w2b3_measure.py json: merged slabs with edges E, per-slab CF_i = min of the
measured floors (G1 and LX) over the fine slabs inside, CG_i = max of the measured G; H-B Thm 12 step by step with (lam_i, mu_i)
re-optimised on a rational grid (multiples of 1/50) under Phi >= 0 checked on a grid (the exact certificate is w2b3_phi.py);
reports the landing at a given m_lo and the threshold m; writes a PLAN json for the sweeps (CF_i - margin, CG_i + margin) and the
Phi certificate (A2_i = q_i rounded UP to 1/1000 + 1/1000).  Usage: python3 w2b3_design.py meas.json m_lo [margin_CF] [margin_CG]"""
import json, sys, math, os
from fractions import Fraction
d = json.load(open(sys.argv[1])); S = d['slabs']; p = float(d['p']); a = int(d['a'])
m_lo = int(sys.argv[2]); mCF = float(sys.argv[3]) if len(sys.argv) > 3 else 0.004; mCG = float(sys.argv[4]) if len(sys.argv) > 4 else 0.004
B = p * p
E = [1e-4, 0.01, 0.02, 0.03, 0.045, 0.06, 0.08, 0.10, 0.12, 0.14, 0.16, 0.18, 0.20, 0.22, 0.24, 0.26, 0.28, 0.30]   # 17 slabs (6 merged lost 0.1 decades)
if os.environ.get('W2B3_SLABS', '17') == 'fine': E = [S[0][0]] + [s[1] for s in S]     # the measurement's own 136 tau-slabs
elif os.environ.get('W2B3_SLABS', '17') == '34': E = [1e-4] + [0.005 * j for j in range(1, 21)] + [0.10 + 0.01 * j for j in range(1, 21)]
def phi_ok(A2, lam, mu, nD=50, nr=20):
    Ds = [0.0] + [10.0 ** (-2 + 5 * j / nD) for j in range(nD + 1)]
    for D in Ds:
        for i in range(nr + 1):
            r = A2 * i / nr; w = D + B - r; Dl = w * w + 4 * D * r
            N = 2 * lam * w * Dl - mu * (2 * w + 4 * B) * Dl + 8 * mu * B * w * w
            if 2 * Dl * Dl - (D + A2 + 3 * r) * N < 0: return False
    return 2 - 2 * lam + 2 * mu >= 0
_pc = {}
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from w2b3_phi import certify as phi_certify            # the EXACT Bernstein certificate (8 strips), as the landing will require
Bq = Fraction(d['p']) ** 2
def A2_of(q): return Fraction(math.ceil(q * 1000) + 1, 1000)   # the rational A2 >= q the certificate is issued for
def best_k(C, G, q):
    best = (4 * C / p - 8 / (B - q), 1.0, 0.0)
    A2 = A2_of(q)
    for li in range(50, 101):
        lam = li / 50
        for mi in range(0, 81):
            mu = mi / 50
            k = 4 * (lam * C / p - mu * G - 2 * lam / (B - q) - 2 * mu * (B + q) / (B - q) ** 2)
            if k > best[0]:
                key = (A2, li, mi)
                if key not in _pc:
                    _pc[key] = phi_ok(q, lam, mu) and (phi_certify(Bq, A2, Fraction(li, 50), Fraction(mi, 50))[0] > 0)
                if _pc[key]: best = (k, lam, mu)
    return best
merged = []
for i in range(len(E) - 1):
    inside = [s for s in S if s[1] > E[i] and s[0] < E[i + 1]]
    merged.append((E[i], E[i + 1], min(min(s[2], s[3]) for s in inside), max(max(s[4], s[5]) for s in inside)))
def stepped(L, plan=None, use_dk=True):
    b = 1e-4; tmin = 1e-4; q = 1 - 2 * tmin; t = tmin
    for i, (t0, t1, CF, CG) in enumerate(merged):
        C = L / 4 + (CF - mCF); G = CG + mCG
        k, lam, mu = best_k(C, G, q) if use_dk else (4 * C / p - 8 / (B - q), 1.0, 0.0)
        if plan is not None: plan.append(dict(t_lo=t0, t_hi=t1, CF=CF - mCF, CG=CG + mCG, q_i=q, lam=lam, mu=mu, k=k))
        if k <= 0: return None
        tb = t + math.log((2 + k * q) / (2 + k * b)) / k
        if tb <= t1: return tb + b / 2
        q = (q + 2 / k) * math.exp(-k * (t1 - t)) - 2 / k; t = t1
    return None
def thresh(f):
    lo, hi = 11.0, 18.0
    for _ in range(30):
        mid = (lo + hi) / 2; v = f(mid)
        if v is not None and v < 9 / 32: hi = mid
        else: lo = mid
    return hi
L = math.log(m_lo / math.pi)
print(f"file={sys.argv[1]} p={p} a={a} delta={d.get('delta')} measured band m_lo={d['m_lo']} (L_lo={d['L_lo']:.4f}); design at m_lo={m_lo} (L={L:.4f}); margins CF {mCF} CG {mCG}")
for (t0, t1, CF, CG) in merged: print(f"  slab [{t0}, {t1}]: measured min S-L/4 = {CF:.4f}, max G = {CG:.4f}")
plan = []; val = stepped(L, plan)
print(f"  at m_lo: stepped + deriv kernel = {val}; plain stepped = {stepped(L, None, False)}")
for r in plan: print(f"    t=[{r['t_lo']},{r['t_hi']}] q_i={r['q_i']:.4f} CF={r['CF']:.4f} CG={r['CG']:.4f} k={r['k']:.3f} (lam={r['lam']:.2f}, mu={r['mu']:.2f})")
hdk = thresh(lambda L_: stepped(L_)); hpl = thresh(lambda L_: stepped(L_, None, False))
print(f"  threshold: stepped + dk L={hdk:.4f} -> m={math.pi * math.exp(hdk):.4e};  plain stepped L={hpl:.4f} -> m={math.pi * math.exp(hpl):.4e}")
assert d['m_lo'] <= m_lo, "the measurement band must contain the design m_lo"
out = dict(p=str(Fraction(d['p'])), B=str(Fraction(d['p']) ** 2), a=a, delta=d.get('delta', 0.25), m_lo=m_lo, measured_m_lo=d['m_lo'], Lambda_design=val,
           slabs=[dict(t_lo=r['t_lo'], t_hi=r['t_hi'], CF=r['CF'], CG=r['CG'], lam=str(Fraction(r['lam']).limit_denominator(50)),
                       mu=str(Fraction(r['mu']).limit_denominator(50)), A2=str(A2_of(r['q_i']))) for r in plan])
json.dump(out, open(sys.argv[1].replace('.json', f'_plan_m{m_lo}.json'), 'w'), indent=1)
print("  plan written:", sys.argv[1].replace('.json', f'_plan_m{m_lo}.json'))
