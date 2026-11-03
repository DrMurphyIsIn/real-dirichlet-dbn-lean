"""W2B3: the stepped landing bound in Arb (outward) with Hakimoglu-Brown's derivative kernel (2610.12803 Thm 12, p.17, read at
source), from certified slab ledgers (w2b3_sweep.py DONE files, one per t-slab, each certifying S - L/4 >= CF_i and d/dp S <= CG_i
for all x, L >= L_lo, t in the slab) and a Phi certificate (w2b3_phi.py json: rows (A2_i, lam_i, mu_i) with B = p^2):
  C_i = L_lo/4 + CF_i,  G_i = CG_i,  k_i = 4 (lam_i C_i/p - mu_i G_i - 2 lam_i/(B - q_i) - 2 mu_i (B + q_i)/(B - q_i)^2)  (33),
  requires 0 < q_i <= A2_i < B (Lemma 10's domain and the Phi certificate's range) and k_i > 0;
  q_{i+1} = (q_i + 2/k_i) e^{-k_i d_i} - 2/k_i  (the barrier value; M(t_{i+1})^2 <= q_{i+1} by the gate),
  until the barrier reaches b inside a slab: T = t_i + log((2 + k_i q_i)/(2 + k_i b))/k_i,  Lambda <= T + b/2.
q_0 = 1 - 2 t_min at t_min = 1e-4 (classical contraction on [0, t_min]); b = 1e-4.  Every quantity is an arb ball; the reported
bound is the UPPER end.  R-round: CF_i, CG_i are the exact floats the sweep compared against; L_lo is the sweep's rounded-down
float; t-edges are checked from the ledgers (t_lo <= 1e-4 for the first slab; slab i's t_hi >= slab i+1's t_lo); A2_i, lam_i,
mu_i are the exact rationals of the Phi certificate (A2_i >= q_i upper end asserted).  The plain (lam, mu) = (1, 0) comparison
is also reported for the same ledgers (needs p^2 >= 5 q_i; H-B Lemma 10 remark / Planat Prop 2.3).
Usage: python3 w2b3_bound.py m_lo phi_cert.json ledger1.DONE ledger2.DONE ...   (ledgers in time order)"""
import sys, json
from fractions import Fraction
from flint import arb, ctx
ctx.prec = 128
def rat(s): f = Fraction(s); return arb(f.numerator) / arb(f.denominator)
def main():
    m_lo = int(sys.argv[1]); phi = json.load(open(sys.argv[2])); leds = [json.load(open(f)) for f in sys.argv[3:]]
    assert phi['all_certified'] and len(phi['rows']) == len(leds)
    L_lo = (arb(m_lo) / arb.pi()).log()
    p = None
    for d in leds:
        assert d['complete'] and d['n_failed'] == 0 and d['m_lo'] <= m_lo, d
        assert arb(d['L_lo']) <= L_lo
        assert p is None or d['p'] == p; p = d['p']
    p = rat(p); B = p * p
    assert rat(phi['B']) == B
    tr = [(2 * arb(float(d['tau'][0])) ** 2, 2 * arb(float(d['tau'][1])) ** 2) for d in leds]
    assert tr[0][0] <= arb(1) / 10000
    for i in range(len(leds) - 1): assert tr[i][1] >= tr[i + 1][0], (i, leds[i]['tau'], leds[i + 1]['tau'])
    tmin = arb(1) / 10000; b = arb(1) / 10000
    q = 1 - 2 * tmin; t = tmin; rows = []; out = None
    for i, d in enumerate(leds):
        CF = arb(float(d['CF'])); CG = arb(float(d['CG'])); t1 = tr[i][1]
        A2 = rat(phi['rows'][i]['A2']); lam = rat(phi['rows'][i]['lam']); mu = rat(phi['rows'][i]['mu'])
        assert phi['rows'][i]['certified']
        assert q > 0 and q <= A2 and A2 < B, (i, float(q.upper()), float(A2))      # Lemma 10 domain; Phi certified on 0 <= r <= A2
        C = L_lo / 4 + CF
        k = 4 * (lam * C / p - mu * CG - 2 * lam / (B - q) - 2 * mu * (B + q) / (B - q) ** 2)
        kplain = 4 * C / p - 8 / (B - q)
        assert k > 0
        Tland = t + ((2 + k * q) / (2 + k * b)).log() / k
        rows.append(dict(i=i, CF=d['CF'], CG=d['CG'], A2=phi['rows'][i]['A2'], lam=phi['rows'][i]['lam'], mu=phi['rows'][i]['mu'],
                         t_lo=float(t.lower()), t_hi=float(t1.upper()), q_i_up=float(q.upper()), k_lo=float(k.lower()),
                         k_plain_lo=float(kplain.lower()), Tland_if_last_up=float(Tland.upper())))
        if Tland <= t1:
            Lam = Tland + b / 2
            out = dict(m_lo=m_lo, p=str(Fraction(leds[0]['p'])), L_lo_lo=float(L_lo.lower()), slabs=rows, T_up=float(Tland.upper()),
                       Lambda_up=float(Lam.upper()), lt_9_32=bool(Lam < arb(9) / 32), margin_lo=float((arb(9) / 32 - Lam).lower()),
                       landed_in_slab=i)
            print(json.dumps(out, indent=1)); return out
        q = (q + 2 / k) * (-k * (t1 - t)).exp() - 2 / k; t = t1
    print(json.dumps(dict(m_lo=m_lo, slabs=rows, landed=False, q_end_up=float(q.upper())), indent=1))
if __name__ == '__main__':
    main()
