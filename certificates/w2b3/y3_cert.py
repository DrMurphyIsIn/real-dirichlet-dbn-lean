"""G1: CERTIFIED lower bound for the TL floor (version 1, memo A.7) over a parameter box
   L in [L0,L1], t in [t0,t1] (t0 > 0), x in [x0,x1], parity a, p = sqrt5, delta fixed.
Rigour: python-flint (Arb) balls throughout; special functions over boxes via
  - monotonicity: Z(u) = -zeta'/zeta(u) and zeta(u) are decreasing on u > 1 (Euler product / Dirichlet series);
    trig majorant 1/(u^2+v^2) + 1/u is decreasing in u, |v|;
  - centred forms (mean value theorem) for psi_a and Re log Gamma_a, with |psi'| <= trig majorant (DLMF 5.15.1);
  - integrals as interval Riemann sums of non-negative integrands + closed-form Gaussian tail majorants.
Returns a rigorous lower bound for S_chi(x, sqrt5, t) valid for every (L,t,x) in the box and every real primitive chi
with log(m/pi) = L, parity a."""
import sys, time, math
from flint import arb, acb, acb_series, ctx
ctx.prec = 64
from y3_big import P5 as P; SIG = (1 + P) / 2; SQ2PI = (2 * arb.pi()).sqrt(); LOG2 = arb(2).log()
def lo(b): return arb(b.lower())
def hi(b): return arb(b.upper())
def iv(a, b): a, b = arb(a), arb(b); return a.union(b)
_zcache = {}
def zeta_pt(u):            # exact-point zeta(u), zeta'(u)
    key = float(u.mid())
    s = acb_series([acb(u), 1]).zeta(); c = s.coeffs(); return c[0].real, c[1].real
from y3_big import Z_up as _Zc, lzeta_up as _lzc, flo
def Z_up(u): return _Zc(u)                      # sup of -zeta'/zeta over ball u (monotone table, tl_big)
def zeta_up(u):
    if float(u.lower()) >= 1.05: return hi(_lzc(u).exp())
    return hi(zeta_pt(lo(u))[0])
def zeta_lo(u): return lo(zeta_pt(hi(u))[0])
def trig_up(ut_lo, v_lo):
    """sup |psi'(ut+iv)| over ut >= ut_lo, |v| >= v_lo:  1/(u^2+v^2) + min(1/u, pi/(2v))   (DLMF 5.15.1 series,
    sum_{k>=1} 1/((u+k)^2+v^2) <= int_0^inf ds/((u+s)^2+v^2) <= min(1/u, pi/(2v)))"""
    tail = 1 / ut_lo
    if v_lo > 0:
        tail2 = arb.pi() / (2 * v_lo)
        if tail2 < tail: tail = tail2
    return hi(1 / (ut_lo * ut_lo + v_lo * v_lo) + tail)
def psi_a_box(Rb, xb, a):
    """centred enclosure of psi_a(c) = (1/2) psi((c+a)/2), c = R - i x/2, over the box; also |psi_a'| sup."""
    cm = acb(Rb.mid(), -xb.mid() / 2)
    r = ((Rb.rad() ** 2) + (xb.rad() / 2) ** 2).sqrt()
    dsup = trig_up((lo(Rb) + a) / 2, lo(xb.abs_lower() if False else arb(xb.lower()).abs_lower()) / 4) / 4
    val = ((cm + a) / 2).digamma() / 2
    e = hi(r * dsup)
    return acb(val.real + arb(0, e), val.imag + arb(0, e)), dsup
def lgre_box(wre, wim_abs_lo, wim_mid, a, wim_rad=0):
    """enclosure of Re log Gamma((w+a)/2) over the complex box w = wre (ball) + i*(wim_mid +/- wim_rad): centred form.
    R1 patch (bb REVIEW_P5 6): the imaginary radius wim_rad (= x-radius/2) is now part of the centred-form radius."""
    cm = acb(wre.mid(), wim_mid)
    val = ((cm + a) / 2).lgamma().real
    # |d/dw lgamma((w+a)/2)| = |psi_a(w)| <= |psi_a(cm)| + r sup|psi_a'|,  r = |w - cm| <= sqrt(rad_re^2 + rad_im^2)
    r = (wre.rad() ** 2 + arb(wim_rad) ** 2).sqrt()
    dps = trig_up((lo(wre) + a) / 2, wim_abs_lo / 2) / 4
    psm = (((cm + a) / 2).digamma() / 2).abs_upper()
    e = hi(r * (psm + r * dps))
    return val + arb(0, e)
def floor_box(Lb, tb, xb, a=0, delta=0.25, ncell=500, Rb=None, taub=None):
    if Rb is None:
        tau = (tb / 2).sqrt(); Rb = SIG + tb * Lb / 4
    else:
        tau = taub; tb = 2 * tau * tau; Lb = 2 * (Rb - SIG) / (tau * tau)
    pc, dpsi = psi_a_box(Rb, xb, a); rho, iota = pc.real, pc.imag
    u0 = 1 + arb(delta); g0 = (u0 - Rb) / tau
    Zc = Z_up(Rb)
    vlo = arb(xb.lower()).abs_lower() / 4 if xb.lower() > 0 else arb(0)
    # ---- bulk
    g_lo = lo(g0); G_HI = hi(tau * rho) + 30
    width = (G_HI - g_lo) / ncell
    I_a = arb(0); D1 = arb(0)
    for k in range(ncell):
        gl = g_lo + k * width; gh = gl + width; g = gl.union(gh)
        u = Rb + tau * g
        if gh <= 0:
            umin = u; absg = -g
        elif gl >= 0:
            umin = Rb; absg = g
        else:
            umin = u.union(Rb); absg = arb(0).union(hi(g.abs_upper()))
        # Y3 R-box patch (B1): at a given tau the bulk is g >= g_s(tau) = (u0-R)/tau, i.e. Re w >= u0; the cell ball can reach
        # below u0 (even below 1, where Z_up is NOT a majorant) only through the (R, tau)-ball, at points that are tail
        # points for that tau.  Clamp the real-part lower bound at u0: valid on bulk points, harmless elsewhere.
        umin = arb(max(lo(umin), u0))
        M = trig_up((lo(umin) + a) / 2, vlo) / 4
        Zs = Z_up(umin)
        e = (tau * absg) ** 2 / 2 * M + tau * absg * Zs
        w = (-((g - tau * rho) ** 2) / 2).exp() / SQ2PI
        I_a += width * hi((e.exp() - 1) * w)
        D1 += width * hi(e.exp() * (tau * absg * M + Z_up(arb(max(lo(u), u0)))) * w)   # Y3 B1 clamp
    Mmax = trig_up((lo(Rb) + a) / 2, arb(0)) / 4
    A2 = 1 - tau * tau * Mmax
    B = tau * rho + tau * Zc + tau * Mmax
    C = -(lo(tau * rho.abs_lower()) ** 2) / 2 + (1 + Zc).log() - SQ2PI.log()
    right = hi((C + B * B / (2 * A2)).exp() * (arb.pi() / (2 * A2)).sqrt() * ((A2 / 2).sqrt() * (G_HI - B / A2)).erfc())
    I_a += right; D1 += right
    Pcut = hi((-(hi(g0) - tau * rho) / arb(2).sqrt()).erfc() / 2)
    D0 = lo((-(tau * hi(iota.abs_upper())) ** 2 / 2).exp()) - Pcut - hi(I_a)
    # ---- tails (u variable), normalised; lognorm LOWER bound
    lgc = lgre_box(Rb, vlo * 2, -xb.mid() / 2, a, wim_rad=xb.rad() / 2)   # Re lgamma_a(c), whole x-box (far half-line)
    lzr = lo((zeta_lo(2 * Rb) / zeta_up(Rb)).log())
    lognorm = lo(lgc) + lzr
    # R1b (P5 A.11): Riemann-sum tails use the Gamma RATIO at the same x.  Delta(u,x) = Re lgG_a(u - ix/2) - Re lgG_a(R - ix/2)
    # is evaluated at x = x_mid and extended over the x-box by |dDelta/dx| = |Im psi(z_u) - Im psi(z_R)|/4
    # <= (|u - R|/2) sup|psi'| / 4 (mean value theorem on the horizontal segment z_u z_R, Im = -x/4; DLMF 5.15.1 majorant).
    lgc_m = lgre_box(Rb, vlo * 2, -xb.mid() / 2, a)
    lognorm_m = lo(lgc_m) + lzr
    # far half-line: lognorm over the x-box, the better of the centred form (lgc) and the x-Lipschitz bound
    # |d/dx Re lgG((R+a)/2 - ix/4)| = |Im psi|/4 <= (pi/2 + 1/(2 u~))/4, u~ = (R+a)/2 (DLMF 5.7.6, memo A.8 item 3)
    lip = lo(lgc_m) - hi(arb(xb.rad()) * (arb.pi() / 2 + 1 / (2 * lo((Rb + a) / 2))) / 4)
    if lip > lo(lgc): lognorm = lip + lzr
    xr = arb(xb.rad())
    def ex(ub):
        umin = lo(ub) if lo(ub) < lo(Rb) else lo(Rb)
        return hi(xr * hi((ub - Rb).abs_upper()) / 8 * trig_up((umin + a) / 2, vlo))
    # far tail must also beat the archimedean decay e^{-pi x/8} absorbed in lognorm (|Gamma(y+iv)| <= Gamma(y) loses it)
    xm = float(xb.upper()); tl_ = float(tb.lower()); Rl = float(Rb.lower())
    # tail-cut tightness (P5 A.11, not a rigour change: the half-line majorant below is valid for every U_MIN <= -6):
    # also let the Gaussian beat the FE growth (1-2U)L/2 on top of pi x/8, i.e. (R-U)^2/t >= pi x/8 + (1-2U)L/2 + 60
    Lh = float(Lb.upper()); th = float(tb.upper())
    s_fe = (th * Lh + math.sqrt((th * Lh) ** 2 + 4 * th * max(0.0, math.pi * xm / 8 + (1 - 2 * Rl) * Lh / 2 + 60))) / 2
    U_MIN = arb(min(-6.0, float((SIG - tb * Lb / 4).lower()) - 12, Rl - math.sqrt(max(tl_, 1e-12) * (math.pi * xm / 8 + 60)),
                    Rl - s_fe))
    ncell_t = max(ncell, int(float((u0 - U_MIN).upper()) / 0.04) + 1)
    wu = (u0 - U_MIN) / ncell_t
    DT0 = arb(0); DT1 = arb(0)
    lz1 = zeta_pt(u0)[0].log()
    for k in range(ncell_t):
        ul = U_MIN + k * wu; uh = ul + wu; u = ul.union(uh)
        absw1 = ((hi(u + 1).abs_upper()) ** 2 + (hi(xb.abs_upper()) / 2) ** 2).sqrt()
        if ul >= 0.5:
            lgw = lgre_box(u, vlo * 2, -xb.mid() / 2, a)
            lP = hi(lgw) + ex(u) + lz1 + hi((1 + arb(delta) - u) / 2 * (Lb - LOG2 + absw1.log()))
        else:
            us = 1 - u
            lgs = lgre_box(us, vlo * 2, xb.mid() / 2, a)      # Re lgG(conj z) = Re lgG(z): same Delta form with us
            if us >= 1 + delta:
                Lb_ = zeta_up(us).log()
            else:
                abss1 = ((hi((2 - u).abs_upper())) ** 2 + (hi(xb.abs_upper()) / 2) ** 2).sqrt()
                Lb_ = lz1 + hi((1 + arb(delta) - us) / 2 * (Lb - LOG2 + abss1.log()))
            lP = hi((1 - 2 * u) / 2 * Lb) + hi(lgs) + ex(us) + hi(Lb_)
        gg = (u - Rb) / tau
        dens = (-(gg ** 2) / 2).exp() / (SQ2PI * tau)
        q = (lP - lognorm_m).exp() * dens
        DT0 += wu * hi(q); DT1 += wu * hi(q * gg.abs_upper() / tau)
    lgw0 = lgre_box(u0, vlo * 2, -xb.mid() / 2, a)
    absw01 = ((hi(u0 + 1)) ** 2 + (hi(xb.abs_upper()) / 2) ** 2).sqrt()
    lP0 = hi(lgw0) + ex(u0) + lz1 + hi((1 + arb(delta) - u0) / 2 * (Lb - LOG2 + absw01.log()))
    DT1 += hi((lP0 - lognorm_m).exp() * (-(g0 ** 2) / 2).exp() / (SQ2PI * tau))
    ym = (1 - U_MIN + a) / 2; lym = ym.log()
    Q2 = lo(1 / tb) - 1 / (4 * ym)
    Q1 = hi(Lb) + lym / 2 - 2 * lo(Rb - U_MIN) / hi(tb)
    Q0 = hi((1 - 2 * U_MIN) * Lb / 2) + ym * lym - ym + 1 + zeta_pt(arb(2))[0].log() - lo((Rb - U_MIN) ** 2 / tb) - lo(tau).log() - SQ2PI.log() - lognorm
    def halfline(Q0_, Q1_):   # int_0^inf exp(Q0 + Q1 v - Q2 v^2) dv
        if Q1_ < 0: return hi(Q0_.exp() / (-Q1_))
        return hi((Q0_ + Q1_ * Q1_ / (4 * Q2)).exp() * (arb.pi() / Q2).sqrt())
    DT0 += halfline(Q0, Q1)
    Q0b = Q0 + hi((Rb - U_MIN) / (tau * tau)).log(); Q1b = Q1 + 1 / lo(Rb - U_MIN)
    DT1 += halfline(Q0b, Q1b)
    den = D0 - DT0
    if not (den > 0):
        return -math.inf, dict(D0=float(D0.lower()), DT0=float(DT0.upper()))
    K2 = (D1 + DT1 + hi(pc.abs_upper()) * DT0) / den
    S = lo(rho) / 2 - hi(K2) / 2           # rigorous lower bound for S - L/4 over the box
    return flo(S), dict(D0=float(D0.lower()), D1=float(D1.upper()), DT0=float(DT0.upper()), DT1=float(DT1.upper()))
if __name__ == "__main__":
    L0 = math.log(1e8 / math.pi)
    for (L1, t0, t1, x0, x1) in [(L0, 0.01, 0.01, 0.0, 0.0), (L0 + 0.01, 0.01, 0.0105, 0.0, 0.05), (L0 + 0.05, 0.01, 0.012, 0.0, 0.2),
                                 (L0 + 0.01, 0.1, 0.105, 0.0, 0.25), (L0 + 0.01, 0.3, 0.31, 2.0, 2.25)]:
        T0 = time.time()
        S, info = floor_box(iv(L0, L1), iv(t0, t1), iv(x0, x1), a=0)
        print(f"L=[{L0:.3f},{L1:.3f}] t=[{t0},{t1}] x=[{x0},{x1}]: certified S >= {S:.4f}  {info}  [{time.time()-T0:.1f}s]", flush=True)
