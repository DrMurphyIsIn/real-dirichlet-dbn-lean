"""W2B3 Phi >= 0 certificates, EXACT rational arithmetic (Python fractions), H-B 2610.12803 pp.22-23 (read at source):
   Lemma 10 (p.14): B = p^2, 0 < A^2 < B, lam, mu >= 0; w = D + B - r, Delta = w^2 + 4 D r,
   N = 2 lam w Delta - mu (2w + 4B) Delta + 8 mu B w^2,   Phi(D, r) = 2 Delta^2 - (D + A^2 + 3r) N.
   Certificate (their (34)-(36)): Psi(U, V) = ((1-U)^4 / B^4) Phi(B U/(1-U), A^2 V) is a polynomial of degree <= 4 in each
   variable on [0,1]^2; on each strip U in [l/8, (l+1)/8] expand Psi((l+u)/8, v) = sum a_km u^k v^m and form the Bernstein
   coefficients beta_ab = sum_{k<=a, m<=b} a_km C(a,k) C(b,m) / (C(4,k) C(4,m)); if every beta_ab > 0 then Psi > 0 on [0,1]^2
   (Bernstein basis polynomials are >= 0 and sum to 1), hence Phi(D, r) > 0 for every finite D >= 0 and 0 <= r <= A^2
   (U = D/(D + B) in [0, 1), V = r/A^2), with no separate large-D argument (U -> 1 is the corner coefficient).
   NEGATIVE CONTROL: a (lam, mu) outside the admissible region (e.g. lam = 2.5, mu = 0) must be REFUSED.
Usage: python3 w2b3_phi.py plan.json out.json    (plan: {"B": "49/4", "rows": [{"A2": "9999/10000", "lam": "8/5", "mu": "16/25"}, ...]})
   or: python3 w2b3_phi.py --selftest"""
import sys, json
from fractions import Fraction as F
from math import comb

# bivariate polynomials in (D, r) or (u, v) as dict {(i, j): coeff}
def padd(P, Q):
    R = dict(P)
    for k, c in Q.items(): R[k] = R.get(k, 0) + c
    return {k: c for k, c in R.items() if c != 0}
def pmul(P, Q):
    R = {}
    for (i, j), c in P.items():
        for (k, l), d in Q.items(): R[(i + k, j + l)] = R.get((i + k, j + l), 0) + c * d
    return {k: c for k, c in R.items() if c != 0}
def pscale(P, s): return {k: c * s for k, c in P.items() if c * s != 0}
def const(c): return {(0, 0): F(c)} if c != 0 else {}
X = {(1, 0): F(1)}; Y = {(0, 1): F(1)}
def phi_poly(B, A2, lam, mu):
    """Phi(D, r) as a polynomial in (D, r) with exact coefficients."""
    w = padd(padd(X, const(B)), pscale(Y, -1))                     # D + B - r
    Dl = padd(pmul(w, w), pscale(pmul(X, Y), 4))                   # w^2 + 4 D r
    N = padd(padd(pscale(pmul(w, Dl), 2 * lam), pscale(pmul(padd(pscale(w, 2), const(4 * B)), Dl), -mu)),
             pscale(pmul(w, w), 8 * mu * B))
    return padd(pscale(pmul(Dl, Dl), 2), pscale(pmul(padd(padd(X, const(A2)), pscale(Y, 3)), N), -1))
def psi_poly(B, A2, lam, mu):
    """Psi(U, V) = (1-U)^4/B^4 Phi(B U/(1-U), A2 V): substitute D^k -> B^k U^k (1-U)^{4-k}, r -> A2 V."""
    Ph = phi_poly(B, A2, lam, mu)
    U = {(1, 0): F(1)}; V = {(0, 1): F(1)}; oneU = padd(const(1), pscale(U, -1))
    pw = {0: const(1)}
    for k in range(1, 5): pw[k] = pmul(pw[k - 1], oneU)
    Upow = {0: const(1)}
    for k in range(1, 5): Upow[k] = pmul(Upow[k - 1], U)
    Vpow = {0: const(1)}
    for m in range(1, 5): Vpow[m] = pmul(Vpow[m - 1], V)
    out = {}
    for (k, m), c in Ph.items():
        assert k <= 4 and m <= 4
        term = pscale(pmul(pmul(Upow[k], pw[4 - k]), Vpow[m]), c * B ** k * A2 ** m / B ** 4)
        out = padd(out, term)
    return out
def shift_u(P, l, n=8):
    """P((l + u)/n, v) as a polynomial in (u, v)."""
    u = {(1, 0): F(1)}; lin = padd(const(F(l, n)), pscale(u, F(1, n)))
    lp = {0: const(1)}
    for k in range(1, 5): lp[k] = pmul(lp[k - 1], lin)
    out = {}
    for (k, m), c in P.items(): out = padd(out, pscale(pmul(lp[k], {(0, m): F(1)}), c))
    return out
def bernstein_min(P):
    """Min over the 25 Bernstein coefficients (degree 4 x 4) of P(u, v) on [0,1]^2."""
    a = {}
    for (k, m), c in P.items(): a[(k, m)] = c
    best = None
    for A in range(5):
        for Bb in range(5):
            s = F(0)
            for k in range(A + 1):
                for m in range(Bb + 1):
                    c = a.get((k, m), F(0))
                    if c: s += c * comb(A, k) * comb(Bb, m) / F(comb(4, k) * comb(4, m))
            best = s if best is None or s < best else best
    return best
def certify(B, A2, lam, mu, nstrip=8):
    B, A2, lam, mu = F(B), F(A2), F(lam), F(mu)
    assert 0 < A2 < B and lam >= 0 and mu >= 0
    Ps = psi_poly(B, A2, lam, mu)
    assert all(k <= 4 and m <= 4 for (k, m) in Ps)
    mins = [bernstein_min(shift_u(Ps, l, nstrip)) for l in range(nstrip)]
    return min(mins), mins
def main():
    if sys.argv[1] == '--selftest':
        # H-B Table 3 row 0 (p = 61/20, q_0 = 9/16, lam = 1.718, mu = 0.868): positive, min coefficient > 13/10000 (their (36))
        m, _ = certify(F(61, 20) ** 2, F(562500, 10 ** 6), F(1718, 1000), F(868, 1000))
        print("H-B row 0: min Bernstein coeff =", float(m), "> 13/10000:", m > F(13, 10000))
        # lam = 1, mu = 0 with B >= 5 A^2: Phi = 2 Delta {w (B - A^2 - 4r) + 4 D r} >= 0 (Lemma 10 remark) -> coefficients >= 0
        m, _ = certify(F(49, 4), F(1), F(1), F(0)); print("(1,0), B = 12.25, A2 = 1: min coeff =", float(m), ">= 0:", m >= 0)
        # NEGATIVE CONTROL: lam = 2.5, mu = 0 violates 2 - 2 lam + 2 mu >= 0 (leading coefficient) -> must be refused
        m, _ = certify(F(49, 4), F(1), F(5, 2), F(0)); print("negative control (2.5, 0): min coeff =", float(m), "REFUSED:", not (m > 0))
        return
    plan = json.load(open(sys.argv[1])); B = F(plan['B']); out = dict(B=str(B), rows=[])
    allok = True
    for r in (plan.get('rows') or plan['slabs']):     # a w2b3_design plan json has the rows under 'slabs'
        m, mins = certify(B, F(r['A2']), F(r['lam']), F(r['mu']))
        ok = m > 0; allok = allok and ok
        out['rows'].append(dict(A2=r['A2'], lam=r['lam'], mu=r['mu'], min_coeff=str(m), min_coeff_float=float(m), certified=ok))
        print(f"A2={r['A2']} lam={r['lam']} mu={r['mu']}: min Bernstein coefficient {float(m):.3e} -> {'CERTIFIED' if ok else 'REFUSED'}", flush=True)
    out['all_certified'] = allok
    json.dump(out, open(sys.argv[2], 'w'), indent=1)
    print("all certified:", allok)
if __name__ == '__main__':
    main()
