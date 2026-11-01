# Y3: Arb values of the Lean statement-layer constants (rational CF <= the certified float CF; R-round).
from flint import arb, ctx
from y3_bounds import bound
ctx.prec = 128
q916 = arb(9) / 16
rows = [('odd uniform, m>=3, p=20', 1, 3, '20', arb(385) / 1000, 0.385, q916),
        ('even uniform, m>=5, p=20', 0, 5, '20', arb(3599) / 10000, 0.36, q916),
        ('odd unconditional, m>=3, p=20', 1, 3, '20', arb(385) / 1000, 0.385, arb(1)),
        ('even unconditional, m>=5, p=20', 0, 5, '20', arb(3599) / 10000, 0.36, arb(1)),
        ('odd unconditional ext, m>=15848932, p=5/2', 1, 15848932, '2.5', arb(-55) / 100 - arb(1) / 10 ** 6, -0.55, arb(1)),
        ('even unconditional ext, m>=36307806, p=5/2', 0, 36307806, '2.5', arb(-76) / 100 - arb(1) / 10 ** 6, -0.76, arb(1))]
for name, a, m, p, CFq, CFf, q0 in rows:
    assert CFq <= arb(CFf)                                   # rational is below the certified float
    L = (arb(m) / arb.pi()).log()
    T, Lam, k = bound(L, arb(p), CFq, q0)
    print(f"{name}: Lambda <= {float(Lam.upper()):.7f}  (k = {float(k.mid()):.5f}, T = {float(T.upper()):.7f}); < 9/32: {bool(Lam < arb(9)/32)}")
