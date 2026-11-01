"""LX / LR: certified (Arb) lower bound for S_chi(x, sqrt5, t) - L/4, valid for ALL x >= 4*v0 (mode 'xaware') or for
x in [0, 4*v1] (mode 'xfree'), and for (R, tau) in a box, with L = 2(R - sigma')/tau^2 (the (R,tau) parametrisation).
Formulation: shifted-contour, doubly linearised (memo A.9):
   D(c) = int Phi(c + tau g) phi(g) dg,   beta = psi_a(c) + L'/L(c),   kappa = tau beta,   c* = c + tau^2 beta,
   D(c) = Phi(c) e^{kappa^2/2} [ int_bulk e^{r(g)} phi(g) dg + T0 ],  D'(c) = Phi(c) e^{kappa^2/2} [ int_bulk e^{r} (Phi'/Phi)(w) phi + T1 ]
   w = c* + tau g,  r = log Phi(w) - log Phi(c) - (w - c) beta.
   S - L/4 = (1/2) Re(D'/D) >= (1/2)(Re beta - K),  K = (Nb + |T1| + |beta||T0|)/(Pb - Ie - |T0|).
Monotonicity in v (x = 4v) for mode 'xaware' is proved in memo A.9 (each integrand piece is non-increasing in v for
v >= v0 >= 2500, except the far-FE piece, which is bounded by its supremum over v).  Evaluate at v = v0."""
import math, sys
from flint import arb, acb, acb_series, ctx
ctx.prec = 64
import os
_PS = os.environ['Y3_P']            # Y3: probe height p (exact decimal string, or 'sqrt5'); no default on purpose
P5 = arb(5).sqrt() if _PS == 'sqrt5' else arb(_PS); SIG = (1 + P5) / 2; SQ2PI = (2 * arb.pi()).sqrt(); GAM = arb.const_euler(); LOG2 = arb(2).log()
def lo(b): return arb(b.lower())
def flo(x):
    """C1 (bb REVIEW_P5_DELTA): a float f with f <= x.lower() exactly (outward rounding; float() rounds to nearest)."""
    l = arb(x).lower(); f = float(l)
    if not math.isfinite(f): return -math.inf
    if arb(f) > l: f = math.nextafter(f, -math.inf)
    return f
def hi(b): return arb(b.upper())
def zeta_pt(u):
    s = acb_series([acb(u), 1]).zeta(); c = s.coeffs(); return c[0].real, c[1].real
def zeta2_pt(u):   # zeta, zeta', zeta''
    s = acb_series([acb(u), 1, 0]).zeta(); c = s.coeffs(); return c[0].real, c[1].real, 2 * c[2].real
# Monotone tables: Z(u) = -zeta'/zeta, Z2(u) = (zeta'/zeta)', log zeta(u) are all DECREASING on u > 1 (Dirichlet series
# with non-negative coefficients; H-B 2610.12803 p.11).  So f(u) <= f(u_k) for the largest grid point u_k <= u: rigorous.
import bisect
_GRID_LO, _GRID_HI, _STEP = 1.05, 60.0, 0.005
_grid = [_GRID_LO + k * _STEP for k in range(int((_GRID_HI - _GRID_LO) / _STEP) + 1)]
_tabZ = {}; _tabZ2 = {}; _tabLZ = {}
def _tab(k):
    if k not in _tabZ:
        u = arb(_grid[k]); z, d, dd = zeta2_pt(u)
        _tabZ[k] = hi(-d / z); _tabZ2[k] = hi(dd / z - (d / z) ** 2); _tabLZ[k] = hi(z.log())
    return _tabZ[k], _tabZ2[k], _tabLZ[k]
def _lookup(u, which):
    x = float(u.lower())
    if x < _GRID_LO:
        z, d, dd = zeta2_pt(lo(u))
        return [hi(-d / z), hi(dd / z - (d / z) ** 2), hi(z.log())][which]
    k = min(int((x - _GRID_LO) / _STEP), len(_grid) - 1)
    while _grid[k] > x: k -= 1
    return _tab(k)[which]
def Z_up(u): return _lookup(arb(u) if not isinstance(u, arb) else u, 0)
def Z2_up(u): return _lookup(arb(u) if not isinstance(u, arb) else u, 1)
def lzeta_up(u): return _lookup(arb(u) if not isinstance(u, arb) else u, 2)
def M_up(ut_lo, vm):   # sup |psi_a'| = (1/4) sup |psi'| over Re >= 2 ut_lo .. : DLMF 5.15.1 majorant
    tail = 1 / ut_lo
    if vm > 0:
        t2 = arb.pi() / (2 * vm)
        if t2 < tail: tail = t2
    return hi((1 / (ut_lo * ut_lo + vm * vm) + tail) / 4)
def rho_lo_f(ut, v):   # lower bound of Re psi_a(c) = (1/2) Re psi(ut - i v), valid for all v' >= v (DLMF 5.7.6, memo A.9)
    a1 = arb(ut.lower()).digamma() / 2
    if v > 0:
        a2 = ((v.log()) - GAM - 1 / (2 * v)) / 2
        return lo(a1) if a1 > a2 else lo(a2)
    return lo(a1)
def P_up(ut, v):      # |psi_a(c)| upper at height v (|Re psi| <= 1/2 log(u^2+v^2) + 1 - gamma + min(1/(2v),1/u); |Im psi| <= pi/2 + 1/(2u))
    m = 1 / ut if v == 0 else (1 / (2 * v) if 1 / (2 * v) < 1 / ut else 1 / ut)
    re = ((ut * ut + v * v).log() / 2 + 1 - GAM + m).abs_upper()
    re2 = (ut.digamma()).abs_upper()          # also |Re psi| could be near psi(u) if negative: take max with |psi(u)|
    re = arb(max(float(re), float(re2)))
    im = arb.pi() / 2 + 1 / (2 * lo(ut))
    return hi((re * re + im * im).sqrt() / 2)
def big_bound(Rb, taub, v0, a=0, delta=0.25, mode='xaware', v1=None, ncell=400, verbose=False):
    Rb = arb(Rb) if not isinstance(Rb, arb) else Rb; taub = arb(taub) if not isinstance(taub, arb) else taub
    v0 = arb(v0)
    tau = taub; t = 2 * tau * tau
    Lb = 2 * (Rb - SIG) / (tau * tau)
    ut = (Rb + a) / 2
    vP = v0 if mode == 'xaware' else arb(v1)               # height at which increasing quantities are taken
    vM = v0 if mode == 'xaware' else arb(0)                # height at which decreasing quantities are taken
    ZR = Z_up(Rb)
    rho_lo = rho_lo_f(ut, vM)
    rb_lo = rho_lo - ZR                                    # Re beta lower
    Pbeta = P_up(ut, vP) + ZR                              # |beta| upper
    ib = hi(arb.pi() / 4 + 1 / (4 * lo(ut))) + ZR          # |Im beta| <= |Im psi_a| + Z(R)
    if not (rb_lo > 0):
        return -math.inf, dict(why='rb_lo<=0')
    us = 1 + arb(delta)
    Uc_lo = lo(Rb + tau * tau * rb_lo)
    gs = lo((us - Uc_lo) / tau)
    # ---------------- bulk: g in [gs, G_HI] standard Gaussian, interval Riemann sum
    G_HI = arb(40)
    width = (G_HI - gs) / ncell
    Ie = arb(0); Nb = arb(0)
    vm = (vM - tau * tau * ib / 2) if vM > 0 else arb(0)
    lzR = lzeta_up(Rb)
    for k in range(ncell):
        gl = gs + k * width; gh = gl + width; g = gl.union(gh)
        Ulo = Uc_lo + tau * g                              # lower bound of Re w
        umin = Ulo if gh <= 0 else (lo(Rb) if gl >= 0 else Ulo.union(Rb))
        umin = lo(umin)
        M = M_up((umin + a) / 2, vm)
        z2 = Z2_up(umin)
        absg = hi(g.abs_upper())
        h = tau * tau * Pbeta + tau * absg
        rG = h * h * M / 2
        rL1 = h * h * z2 / 2
        rL2 = lzeta_up(Ulo) + lzR + h * ZR
        rL = rL1 if rL1 < rL2 else rL2
        eps = hi(rG + rL)
        d1 = h * z2; d2 = Z_up(Ulo) + ZR
        dl = d1 if d1 < d2 else d2
        w = (-(g * g) / 2).exp() / SQ2PI
        Ie += width * hi((eps.exp() - 1) * w)
        Nb += width * hi(eps.exp() * (h * M + dl) * w)
    # right tail g > G_HI: crude: eps <= (tau^2 P + tau g)^2 (M0 + Z2(R))/2 + ...; Gaussian dominates (tau^2 (M0+Z2) <= 1/2)
    M0 = M_up((lo(Rb) + a) / 2, vm); z2R = Z2_up(Rb)
    A2 = 1 - tau * tau * (M0 + z2R)
    if not (A2 > 0):
        return -math.inf, dict(why='A2')
    # int_{G}^inf exp(-A2 g^2/2 + B g + C) with B = tau^3 P (M0+Z2) + tau(...)  (crude linear bound absorbs h-factor via h <= e^h)
    B = tau ** 3 * Pbeta * (M0 + z2R) + tau * (M0 + z2R + 1)
    C = (tau * tau * Pbeta) ** 2 * (M0 + z2R) / 2 + tau * tau * Pbeta - SQ2PI.log()
    right = hi((C + B * B / (2 * A2)).exp() * (arb.pi() / (2 * A2)).sqrt() * ((A2 / 2).sqrt() * (G_HI - B / A2)).erfc())
    Ie += right; Nb += right
    Pb = lo(1 - (-(gs) / arb(2).sqrt()).erfc() / 2)
    # ---------------- tails: U < us, U-measure.  weight exp(-(U-R)^2/(2 tau^2) - tau^2 rb_lo^2/2 + tau^2 ib^2)/(tau sqrt(2pi)),
    # normalised by |Gamma_a(c)| zeta(2R)/zeta(R) [ |L(c)| >= zeta(2R)/zeta(R) ].
    lz1 = lzeta_up(us)
    lnormL = lo((zeta_pt(hi(2 * Rb))[0] / zeta_pt(lo(Rb))[0]).log())
    common = -(tau * tau) * rb_lo * rb_lo / 2 + tau * tau * ib * ib - (tau * SQ2PI).log() - lnormL
    # Gamma-ratio slopes on the horizontal line at height v (x-aware) or x-free:
    if mode == 'xaware':
        gl_ = ((vM.log()) - GAM - 1 / (2 * vM)) / 2               # Re psi_a >= gl_ on any horizontal segment, height >= v0
    vert = tau * tau * ib * (arb.pi() / 4 + 1)                     # vertical shift tau^2 |Im beta| times sup |Im psi_a| (Re >= 1/2)
    U_MIN = arb(min(-8.0, float(lo(Rb).lower()) - 10 - float(hi(tau * 12).upper())))
    nt = max(ncell, int(float(hi(us - U_MIN).upper()) / 0.05) + 1)
    wu = (us - U_MIN) / nt
    T0 = arb(0); T1 = arb(0)
    xs_hi = 2 * vP * 2        # x upper used in Rademacher |w+1| (xfree: x <= 4 v1); xaware: evaluated at v0 (monotone)
    for k in range(nt):
        ul = U_MIN + k * wu; uh = ul + wu; U = ul.union(uh)
        gauss = -((Rb - U) ** 2) / (2 * tau * tau)
        if ul >= 0.5:
            # mid: |Gamma_a(w)|/|Gamma_a(c)| <= exp(-(R-U) gl_) (xaware) or Gamma((U+a)/2)/Gamma((R+a)/2) (xfree)
            if mode == 'xaware':
                lg = -(Rb - U) * gl_
            else:
                lg = ((U + a) / 2).lgamma() - ((lo(Rb) + a) / 2).lgamma()
            absw1 = hi(U + 1) + xs_hi / 2 + tau * tau * ib
            # Rademacher with L combined exactly: (1+delta-U)/2 * (L - log2 + log|w+1|), L = 2(R - sig)/tau^2
            expo = gauss + (1 + delta - U) / 2 * (2 * (Rb - SIG) / (tau * tau) - LOG2 + absw1.log()) + lg + lz1 + vert
        else:
            s1 = 1 - U
            # Gamma_a(1-w) vs Gamma_a(c): horizontal from R to s1
            if mode == 'xaware':
                if s1 <= lo(Rb):
                    lg = -(Rb - s1) * gl_
                else:
                    # far-FE: sup over v >= v0 of (s1-R) gu(v) - tau^2 rb_lo(v)^2/2 (memo A.9, closed form);
                    sp = (hi(s1) + a) / 2
                    c1 = 1 - GAM + 1 / (2 * vM) + sp / vM
                    Aco = (s1 - Rb) / 2
                    c2 = GAM + 1 / (2 * vM) + 2 * ZR
                    lstar = c2 + 4 * Aco / (tau * tau)
                    l0 = vM.log()
                    ell = lstar if lstar > l0 else l0
                    val = Aco * (ell + c1) - (tau * tau / 8) * (ell - c2) ** 2 + tau * tau * rb_lo * rb_lo / 2   # add back (common subtracts it)
                    lg = val
            else:
                lg = ((s1 + a) / 2).lgamma() - ((lo(Rb) + a) / 2).lgamma() if s1 >= 0.5 else arb(0)
            if s1 >= 1 + delta:
                lL = lzeta_up(s1)
                Lpart = arb(0)
            else:
                abs2w = hi(2 - U) + xs_hi / 2 + tau * tau * ib
                lL = lz1
                Lpart = (1 + delta - s1) / 2 * (2 * (Rb - SIG) / (tau * tau) - LOG2 + abs2w.log())
            expo = gauss + (1 - 2 * U) / 2 * (2 * (Rb - SIG) / (tau * tau)) + lg + lL + Lpart + vert
        q = (expo + common).exp()
        T0 += wu * hi(q)
        gpr = hi(((Rb - U).abs_upper() + tau * tau * Pbeta) / tau)          # |g'| <= (|U-R| + tau^2 |Re beta|)/tau
        T1 += wu * hi(q * (gpr + tau * Pbeta) / tau)
    # far tail U < U_MIN: Gaussian dominates every growth (closed form, memo A.9): bounded by the last-cell value times 1/slope
    T0 += hi(q / ((Rb - U_MIN) / (tau * tau)) * 2); T1 += hi(q * (gpr + tau * Pbeta) / tau / ((Rb - U_MIN) / (tau * tau)) * 2)
    # boundary term of the by-parts formula at U = us: |Phi(w_s)| |E(g_s)| / tau  (same normalisation)
    Ub = us
    if mode == 'xaware':
        lgb = -(Rb - Ub) * gl_
    else:
        lgb = ((Ub + a) / 2).lgamma() - ((lo(Rb) + a) / 2).lgamma()
    expob = -((Rb - Ub) ** 2) / (2 * tau * tau) + lgb + lzeta_up(Ub) + vert
    T1 += hi((expob + common).exp() * tau / tau * SQ2PI * 0 + (expob + common).exp() / 1)    # boundary (|E| at g_s; tau factors cancel)
    den = Pb - Ie - T0
    if not (den > 0):
        return -math.inf, dict(why='den', Pb=float(Pb), Ie=float(Ie.upper()), T0=float(T0.upper()))
    K = (Nb + T1 + Pbeta * T0) / den
    S = rb_lo / 2 - hi(K) / 2
    info = dict(L=float(Lb.mid()), rb_lo=float(rb_lo), Pb=float(Pb), Ie=float(Ie.upper()), Nb=float(Nb.upper()), T0=float(T0.upper()), T1=float(T1.upper()), K=float(K.upper()))
    return float(S.lower()), info
if __name__ == "__main__":
    for (R, tau) in [(1.704, 0.1), (1.964, 0.2), (3.778, 0.5), (10.0, 0.3), (40.0, 0.5), (40.0, 0.007)]:
        S, info = big_bound(arb(R), arb(tau), 2500)
        print(f"xaware v0=2500: R={R} tau={tau}: S-L/4 >= {S:.4f}  {info}")
    for (R, tau) in [(40.0, 0.5), (40.0, 0.1), (40.0, 0.01)]:
        S, info = big_bound(arb(R), arb(tau), 0, mode='xfree', v1=2500)
        print(f"xfree v<=2500: R={R} tau={tau}: S-L/4 >= {S:.4f}  {info}")
