"""Y3: assemble the certified bands (ledgers *.DONE with n_failed = 0) into the Lambda_chi bound per conductor, in Arb.
For each (a, m) every complete band with m_lo <= m <= m_hi and T <= t_hi gives Lambda_chi <= T(L) + b/2 at q0 (9/16 needs
OAI's 7/8; 1 is unconditional); the table reports the best.  Usage: python3 y3_table.py ledger1.DONE ledger2.DONE ..."""
import sys, json
from flint import arb, ctx
from y3_bounds import bound
ctx.prec = 128
bands = []
for f in sys.argv[1:]:
    d = json.load(open(f))
    assert d['n_failed'] == 0 and d['complete'] and d['t_lo'] <= 1e-4
    bands.append(d)
def best(a, m, q0):
    L = (arb(m) / arb.pi()).log(); out = None
    for d in bands:
        if d['a'] != a or not (d['m_lo'] <= m <= d['m_hi']): continue
        p = arb(5).sqrt() if d['p'] == 'sqrt5' else arb(d['p'])
        if p * p < 5 * q0: continue
        try: T, Lam, k = bound(L, p, arb(d['CF']), q0)   # R-round: the exact binary float the sweep compared S against
        except AssertionError: continue
        if not (T <= arb(d['t_hi'])): continue
        if out is None or Lam.upper() < out[0].upper(): out = (Lam, d['p'], d['CF'], d['m_lo'], d['m_hi'])
    return out
res = dict(ledgers=sys.argv[1:], rows=[])
for q0s, q0 in (('9/16', arb(9) / 16), ('1', arb(1))):
    for a in (0, 1):
        ms = ([5] if a == 0 else [3, 4]) + [7, 8, 11, 12, 13, 59, 60, 100, 400, 1999, 2000, 10 ** 4, 99999, 10 ** 5, 10 ** 6, 10 ** 7, 25118864, 39810717, 5 * 10 ** 7, 10 ** 8 - 1]
        for m in ms:
            b = best(a, m, q0)
            res['rows'].append(dict(q0=q0s, a=a, m=m, Lambda_up=(float(b[0].upper()) if b else None), p=(b[1] if b else None),
                                    CF=(b[2] if b else None), band=([b[3], b[4]] if b else None),
                                    lt_9_32=(bool(b[0] < arb(9) / 32) if b else None)))
print(json.dumps(res, indent=0))
