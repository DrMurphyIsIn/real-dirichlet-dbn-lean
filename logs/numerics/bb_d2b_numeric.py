"""bb (AI review, NOT an operator read-back), 2026-10-29: numeric sanity check of DBN.Gen.bridge's normalisation for
chi_{-4} (N = 4, odd, k = 1; classically real primitive with root number +1, so Phi_chi is even):
  Hd 0 z = int_0^inf PhiC(u) cos(z u) du,  PhiC(u) = e^{(1+2k)u} sum_n chi(n) n^k exp(-pi n^2 e^{4u} / N)
  RHS    = (1/8) N^{(s+k)/2} Gamma_R(s+k) L(s, chi),  s = 1/2 + i z/2,  Gamma_R(s) = pi^{-s/2} Gamma(s/2)."""
import mpmath as mp
mp.mp.dps = 30
N, k = 4, 1
chi = lambda n: [0, 1, 0, -1][n % 4]
def PhiC(u):
    x = mp.exp(4 * u)
    return mp.exp((1 + 2 * k) * u) * mp.nsum(lambda n: chi(int(n)) * n**k * mp.exp(-mp.pi * n**2 * x / N), [1, mp.inf])
print('evenness check PhiC(-0.3) vs PhiC(0.3):', mp.nstr(PhiC(-0.3), 20), mp.nstr(PhiC(0.3), 20))
for z in (mp.mpf(0), mp.mpf(1), mp.mpc(0.5, 0.25)):
    lhs = mp.quad(lambda u: PhiC(u) * mp.cos(z * u), [0, 0.5, 1, 2])
    s = mp.mpf(1) / 2 + 1j * z / 2
    GR = lambda w: mp.pi ** (-w / 2) * mp.gamma(w / 2)
    rhs = mp.mpf(1) / 8 * mp.power(N, (s + k) / 2) * GR(s + k) * mp.dirichlet(s, [0, 1, 0, -1])
    print('z =', mp.nstr(z, 6), ' LHS =', mp.nstr(lhs, 18), ' RHS =', mp.nstr(rhs, 18), ' |diff| =', mp.nstr(abs(lhs - rhs), 3))
