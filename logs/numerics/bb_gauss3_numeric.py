"""bb (AI review, NOT an operator read-back), 2026-10-29: independent numeric check of Gauss's sign theorem in MATHLIB's normalisation
rootNumber = gaussSum(chi, stdAddChar) / I^a / N^(1/2), a = 0 (even) / 1 (odd), for the Kronecker character chi_D of every
fundamental discriminant D with |D| <= 2000 (both signs), N = |D|. Own Kronecker-symbol code; mpmath 30 digits."""
import mpmath as mp
mp.mp.dps = 30
I = mp.mpc(0, 1)
def kron(D, n):
    if n == 0: return 0
    if n == 1: return 1
    r = 1
    while n % 2 == 0:
        n //= 2
        if D % 2 == 0: return 0
        r *= 1 if D % 8 in (1, 7) else -1
    # Jacobi (D/n), n odd
    a, m, j = D % n, n, 1
    while a:
        while a % 2 == 0:
            a //= 2
            if m % 8 in (3, 5): j = -j
        a, m = m, a
        if a % 4 == 3 and m % 4 == 3: j = -j
        a %= m
    return r * (j if m == 1 else 0)
def squarefree(m): return all(m % (p * p) for p in range(2, int(m ** 0.5) + 1))
def fundamental(D):
    if D == 1: return False
    if D % 4 == 1: return squarefree(abs(D))
    if D % 4 == 0:
        m = D // 4
        return m % 4 in (2, 3) and squarefree(abs(m))
    return False
worst, count, bad = 0, 0, []
for D in list(range(-2000, 0)) + list(range(2, 2001)):
    if not fundamental(D): continue
    N = abs(D); a = 0 if D > 0 else 1
    assert kron(D, N - 1) == (1 if a == 0 else -1)          # parity consistent with chi(-1)
    tau = mp.fsum(kron(D, x) * mp.expjpi(2 * mp.mpf(x) / N) for x in range(N))
    eps = tau / I ** a / mp.sqrt(N)
    count += 1; worst = max(worst, abs(eps - 1))
    if abs(eps - 1) > 1e-15: bad.append(D)
print('fundamental discriminants checked:', count, ' max |rootNumber - 1| =', mp.nstr(worst, 5), ' failures:', bad[:10])
