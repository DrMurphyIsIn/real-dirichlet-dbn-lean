"""bb (AI review, NOT an operator read-back), 2026-10-29: independent numeric check of S1/S2 (mpmath, 40 digits).
S1: G(N) = sum_{j<N} e^{2 pi i j^2/N} vs (1+i)(1+(-i)^N)/2 * sqrt(N), N = 1..200.
S2: Mathlib's rootNumber = tau(chi, stdAddChar)/I^a/sqrt(p) for the Legendre character mod every odd prime p < 500."""
import mpmath as mp
from sympy import primerange
from sympy.ntheory import legendre_symbol
mp.mp.dps = 40
I = mp.mpc(0, 1)
worst1 = 0
for N in range(1, 201):
    G = mp.fsum(mp.expjpi(2 * mp.mpf(j * j) / N) for j in range(N))
    F = (1 + I) * (1 + (-I) ** N) / 2 * mp.sqrt(N)
    worst1 = max(worst1, abs(G - F))
print('S1: max |G(N) - formula| over N = 1..200:', mp.nstr(worst1, 5))
worst2 = 0; bad = []
for p in primerange(3, 500):
    tau = mp.fsum(legendre_symbol(a, p) * mp.expjpi(2 * mp.mpf(a) / p) for a in range(1, p))
    a = 0 if p % 4 == 1 else 1              # chi(-1) = (-1/p)
    eps = tau / I ** a / mp.sqrt(p)
    worst2 = max(worst2, abs(eps - 1))
    if abs(eps - 1) > 1e-20: bad.append(p)
print('S2: max |rootNumber - 1| over odd primes < 500:', mp.nstr(worst2, 5), ' failures:', bad)
