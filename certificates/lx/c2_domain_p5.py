"""C2 record domain in (R, tau): t in [t_min(L), T(L)], t_min = min(1e-4, 4/L), b = min(1e-4, 1/L^2), L >= L0 = log(1e8/pi);
TL is needed only there (memo A.9.0).  R = sigma' + t L/4, tau = sqrt(t/2)."""
import math
SIG = (1 + math.sqrt(5)) / 2; P = math.sqrt(5); K0 = 1.0
L0 = math.log(1e8 / math.pi)
def tmin(L): return min(1e-4, 4 / L)
def bb(L): return min(1e-4, 1 / L ** 2)
def kk(L): return 4 * (L / 4 - K0) / P - 8 / (P * P - 1)
def T(L):
    k = kk(L); tm = tmin(L); b = bb(L)
    return tm + math.log((2 + k * (1 - 2 * tm)) / (2 + k * b)) / k
def Lam_bound(L): return T(L) + bb(L) / 2
def Tinv(t, Lmax=1e12):   # largest L with T(L) >= t  (T decreasing)
    lo_, hi_ = L0, Lmax
    if T(lo_) < t: return None
    for _ in range(200):
        mid = math.sqrt(lo_ * hi_)
        if T(mid) >= t: lo_ = mid
        else: hi_ = mid
    return lo_
def R_range(tau, L4=4e4):
    t = 2 * tau * tau
    Lhi = Tinv(t)
    if Lhi is None: return None
    Lhi = min(Lhi, L4)
    if Lhi < L0: return None
    return SIG + t * L0 / 4, SIG + t * Lhi / 4
if __name__ == "__main__":
    for L in (L0, 25, 50, 100, 1e3, 1e4, 4e4, 1e5, 1e6):
        print(f"L={L:.4g}: T={T(L):.6g}  Lambda_bound={Lam_bound(L):.6g}  R_max={SIG + T(L)*L/4:.4f}  tau_max={math.sqrt(T(L)/2):.4f}")
    print("tau range:", math.sqrt(1e-4 / 2), math.sqrt(T(L0) / 2))
    for tau in (0.00708, 0.01, 0.02, 0.05, 0.1, 0.2, 0.3, 0.37):
        print(tau, R_range(tau))
