"""LX / LR certified bound, double contour shift (memo A.9.1).
beta1 = psi_a(c), c1 = c + tau^2 beta1, beta2 = L'/L(c1), c2 = c1 + tau^2 beta2, kappa = tau (beta1 + beta2):
  D = Gamma_a(c) L(c1) e^{tau^2 (beta1^2 + beta2^2)/2} [ int_bulk e^{rG + rL} phi + T0 ],  w = c2 + tau g,
  |rG| <= |hG|^2 M / 2,  hG = w - c = tau^2 (beta1+beta2) + tau g;   |rL| <= min(|hL|^2 Z2 / 2, log zeta(U) + log zeta(Re c1) + |hL| Z(Re c1)),
  hL = w - c1 = tau^2 beta2 + tau g;   numerator integrand |hG| M + min(|hL| Z2, Z(U) + Z(Re c1)).
  S - L/4 >= (rho_lo - Z(Re c1))/2 - K/2,   K = (Nb + T1 + |beta| T0)/(Pb - Ie - T0).
Tail weight (U-measure): exp(-(U-R)^2/(2tau^2) - tau^2 rho_lo^2/2 + tau^2 (iota^2 + I^2 + Zc1^2)/2)/(tau sqrt(2pi)),
normalised by |Gamma_a(c)| zeta(2 Re c1)/zeta(Re c1).  Modes: 'xaware' (valid for all x >= 4 v0; v-monotone, memo A.9.2),
'xfree' (valid for 0 <= x <= 4 v1)."""
import math
from flint import arb, acb, acb_series, ctx
from y3_big import flo, lo, hi, zeta_pt, zeta2_pt, Z_up, Z2_up, lzeta_up, M_up, rho_lo_f, P_up, SIG, SQ2PI, GAM, LOG2, P5
ctx.prec = 64
def big2(Rb, taub, v0, a=0, delta=0.25, mode='xaware', v1=None, ncell=400, G_LO=-40):
    Rb = arb(Rb); tau = arb(taub); v0 = arb(v0)
    ut = (Rb + a) / 2
    vP = v0 if mode == 'xaware' else arb(v1)
    vM = v0 if mode == 'xaware' else arb(0)
    rho_lo = rho_lo_f(ut, vM)
    P1 = P_up(ut, vP)                                     # |beta1|
    iota = hi(arb.pi() / 4 + 1 / (4 * lo(ut)))           # |Im beta1|
    Rc1 = lo(Rb + tau * tau * rho_lo)                     # Re c1 >= R + tau^2 rho_lo
    Z1 = Z_up(Rc1)                                        # |beta2| <= Z(Re c1)
    Pb_ = P1 + Z1                                         # |beta1 + beta2|
    I_ = iota + Z1                                        # |Im(beta1+beta2)|
    Uc2 = lo(Rb + tau * tau * (rho_lo - Z1))              # Re c2 lower
    us = 1 + arb(delta)
    gs = lo((us - Uc2) / tau)
    vm = (vM - tau * tau * I_ / 2) if vM > 0 else arb(0)
    lzc1 = lzeta_up(Rc1)
    gs_hi = hi((us - Uc2) / tau)                          # Y3 B2: upper end of the split ball (for the bulk MASS lower bound)
    def integrand_bounds(g):
        # Y3 R-box patch (B1): bulk points have Re w >= us at their own tau; clamp the lower bound (Z_up < 0 below u = 1).
        Ulo = arb(max(lo(Uc2 + tau * g), us))
        gl, gh = g.lower(), g.upper()
        uminG = lo(Ulo) if gh <= 0 else (lo(Rb) if gl >= 0 else lo(Ulo.union(Rb)))
        uminL = lo(Ulo) if gh <= 0 else (Rc1 if gl >= 0 else lo(Ulo.union(Rc1)))
        uminG = uminG if uminG < lo(Rb) else lo(Rb)
        M = M_up((uminG + a) / 2, vm)
        z2 = Z2_up(uminL)
        ag = hi(g.abs_upper())
        hG = tau * tau * Pb_ + tau * ag
        hL = tau * tau * Z1 + tau * ag
        rG = hG * hG * M / 2
        rL1 = hL * hL * z2 / 2; rL2 = lzeta_up(Ulo) + lzc1 + hL * Z1
        eps = hi(rG + (rL1 if rL1 < rL2 else rL2))
        d1 = hL * z2; d2 = Z_up(Ulo) + Z1
        num = hi(hG * M + (d1 if d1 < d2 else d2))
        return eps, num
    # bulk main part [max(gs,G_LO), G_HI]
    G_HI = arb(40); glo = gs if gs > G_LO else arb(G_LO)
    width = (G_HI - glo) / ncell
    Ie = arb(0); Nb = arb(0)
    for k in range(ncell):
        g = (glo + k * width).union(glo + (k + 1) * width)
        eps, num = integrand_bounds(g)
        w = (-(g * g) / 2).exp() / SQ2PI
        Ie += width * hi((eps.exp() - 1) * w); Nb += width * hi(eps.exp() * num * w)
    if gs < G_LO:   # piece [gs, G_LO]: cells with exact Gaussian masses, integrand sup per cell
        ncr = 200; wc = (arb(G_LO) - gs) / ncr
        cdf = lambda z: (-(z) / arb(2).sqrt()).erfc() / 2
        for k in range(ncr):
            a_ = gs + k * wc; b_ = a_ + wc
            eps, num = integrand_bounds(a_.union(b_))
            mass = hi(cdf(b_) - cdf(a_)) if True else 0
            Ie += hi(eps.exp() * mass); Nb += hi(eps.exp() * num * mass)
    # Y3 B4 (bb REVIEW_Y3 sec. 4, code = bb_big2_b4.py a410901b; re-derived by Y3, memo sec. 4.5): after the contour shift the
    # weight is exactly phi(g) on w = c2 + tau g, and the bulk/tail split is Re w = us, i.e. g* = (us - Re c2)/tau.  Re c2 has
    # only the LOWER bound Uc2 (Re beta1 grows like log v / 2 in xaware mode), so g* <= gs and the bulk points with
    # g in [g*, lo gs) are in neither the Riemann sum nor the U-tail.  On that gap, uniformly in v >= v0:
    #   us <= Re w < Re c1 (guard: tau Z1 + lo gs < 0);  |Re(w-c)| <= max(R - us, tau^2 (P1+Z1)), |Im(w-c)| <= tau^2 I_;
    #   |rG| <= |hG|^2 M/2 with M at real part us (P^2 M decreasing in v, P5 A.9.2(d));
    #   |rL| <= log z(us) + log z(Re c1) + |w - c1| |beta2| <= log z(us) + log z(Rc1) + sup_{u >= Rc1} (u - us + tau^2 Z1) Z(u)
    #   (grid sup with monotone Z_up; for u >= 60, (u - c) Z(u) is decreasing because Z' <= -log2 Z, so its value at 60 bounds it);
    #   numerator |hG| M + Z(us) + Z1;  gap mass <= P(g < lo gs) = Phi(lo gs).
    hGg = arb(max(float(hi(Rb - us).upper()), float(hi(tau * tau * (P1 + Z1)).upper()))) + hi(tau * tau * I_)
    Mg = M_up((us + a) / 2, vm)
    cZ = hi(tau * tau * Z1)
    if not (hi(tau * Z1) + gs < 0): return -math.inf, dict(why='B4_guard')   # gap has Re w < Re c1
    supL = arb(0); uu = flo(Rc1); stp = 0.01
    while uu < 60.0:
        val = hi((arb(uu + stp) - us + cZ) * Z_up(arb(uu)))
        if val > supL: supL = val
        uu += stp
    val = hi((arb(60.0) - us + cZ) * Z_up(arb(60.0)))
    if val > supL: supL = val
    Cg = hi(hGg * hGg * Mg / 2 + lzeta_up(us) + lzc1 + supL)
    numg = hi(hGg * Mg + Z_up(us) + Z1)
    massg = hi((-(gs) / arb(2).sqrt()).erfc() / 2)        # Phi(lo gs) >= P(g < lo gs) >= gap mass
    Ie += hi(Cg.exp() * massg); Nb += hi(Cg.exp() * numg * massg)
    # right tail g > G_HI
    M0 = M_up((lo(Rb) + a) / 2, vm); z2c = Z2_up(Rc1)
    A2 = 1 - tau * tau * (M0 + z2c)
    if not (A2 > 0): return -math.inf, dict(why='A2')
    B = tau ** 3 * Pb_ * (M0 + z2c) + tau * (M0 + z2c + 1); C = (tau * tau * Pb_) ** 2 * (M0 + z2c) / 2 + tau * tau * Pb_ - SQ2PI.log()
    right = hi((C + B * B / (2 * A2)).exp() * (arb.pi() / (2 * A2)).sqrt() * ((A2 / 2).sqrt() * (G_HI - B / A2)).erfc())
    Ie += right; Nb += right
    Pb = lo(1 - (-(gs_hi) / arb(2).sqrt()).erfc() / 2)   # Y3 B2: P(g >= g_s(tau)) >= P(g >= hi(gs)) (was lo: too large)
    # tails
    lz1 = lzeta_up(us)
    lnormL = lo((zeta_pt(hi(2 * Rc1))[0] / zeta_pt(Rc1)[0]).log())
    rpos = rho_lo if rho_lo > 0 else arb(0)
    common = -(tau * tau) * rpos * rpos / 2 + tau * tau * (iota * iota + I_ * I_ + Z1 * Z1) / 2 - (tau * SQ2PI).log() - lnormL
    vert = tau * tau * I_ * (arb.pi() / 4 + 1)
    Lfac = 2 * (Rb - SIG) / (tau * tau)
    xs = 4 * vP
    if mode == 'xaware':
        gl_ = ((vM.log()) - GAM - 1 / (2 * vM)) / 2
        l0 = vM.log()
    def log_q(U):
        gauss = -((Rb - U) ** 2) / (2 * tau * tau)
        if U.lower() >= 0.5:
            lg = -(Rb - U) * gl_ if mode == 'xaware' else ((U + a) / 2).lgamma() - ((lo(Rb) + a) / 2).lgamma()
            absw1 = hi(U + 1) + xs / 2 + tau * tau * I_
            return gauss + (1 + delta - U) / 2 * (Lfac - LOG2 + absw1.log()) + lg + lz1 + vert
        s1 = 1 - U
        if mode == 'xaware':
            if s1.upper() <= Rb.lower():
                lg = -(Rb - s1) * gl_
            else:
                sp = (hi(s1) + a) / 2
                c1 = 1 - GAM + 1 / (2 * vM) + sp / vM
                c2 = GAM + 1 / (2 * vM) + 2 * Z1
                Aco = (s1 - Rb) / 2 + 1 / l0     # +1/l0 absorbs the log-growth of the multipliers P(v)/P(v0) (memo A.9.2(f))
                lstar = c2 + 4 * Aco / (tau * tau)
                ell = lstar if lstar > l0 else l0
                lg = Aco * (ell + c1) - (tau * tau / 8) * (ell - c2) ** 2 + tau * tau * rpos * rpos / 2
        else:
            lg = ((s1 + a) / 2).lgamma() - ((lo(Rb) + a) / 2).lgamma()
        if s1.lower() >= 1 + delta:
            lL = lzeta_up(s1); Lp = arb(0)
        else:
            abs2w = hi(2 - U) + xs / 2 + tau * tau * I_
            lL = lz1; Lp = (1 + delta - s1) / 2 * (Lfac - LOG2 + abs2w.log())
        return gauss + (1 - 2 * U) / 2 * Lfac + lg + lL + Lp + vert
    # U_MIN beyond which log q has derivative >= rate > 0 (memo A.9.1)
    if mode == 'xaware':
        cc = 1 - GAM + 1 / (2 * vM) + GAM + 1 / (2 * vM) + 2 * Z1 + 1
        Umin_f = min(-8.0, float((1 - Rb).lower()) - 1, float((2 * SIG - Rb - tau * tau * (l0 + cc + 2)).lower()) - 1)
    else:
        Umin_f = min(-8.0, float((2 * SIG - Rb).lower()) - 6)
    U_MIN = arb(Umin_f)
    nt = max(ncell, int(float(hi(us - U_MIN).upper()) / 0.05) + 1)
    wu = (us - U_MIN) / nt
    T0 = arb(0); T1 = arb(0)
    for k in range(nt):
        U = (U_MIN + k * wu).union(U_MIN + (k + 1) * wu)
        q = (log_q(U) + common).exp()
        T0 += wu * hi(q)
        gpr = hi(((Rb - U).abs_upper() + tau * tau * Pb_) / tau)
        T1 += wu * hi(q * (gpr + tau * Pb_) / tau)
    # far tail U < U_MIN: d/dU log q >= rate (xaware: min(p/tau^2 - (c1+c2)/2, 1/tau^2) - 1; xfree: see memo), so int <= q(U_MIN)/rate
    if mode == 'xaware':
        rate = P5 / (tau * tau) - cc / 2 - 1
        r2 = 1 / (tau * tau) - 1
        rate = rate if rate < r2 else r2
    else:
        rate = (2 * SIG - Rb - U_MIN) / (tau * tau) - ((1 - U_MIN + a) / 2 + 1).log() / 2 - Lfac * 0 - 1
    qm = (log_q(U_MIN) + common).exp()
    gm = hi(((Rb - U_MIN).abs_upper() + tau * tau * Pb_) / tau)
    if not (rate > 1): return -math.inf, dict(why='rate')
    T0 += hi(qm / rate * 2); T1 += hi(qm * (gm + tau * Pb_) / tau / rate * 4)
    if mode == 'xaware':
        # Y3 B3 (far-far tail, memo Y3 sec. 3.3): the closed-form majorant log_q is NOT integrable as U -> -inf (its c1 term
        # sp/vM grows with s1 = 1-U), so the slope bound above holds only on region I = [1 - v0, U_MIN].  Check that slope,
        # then add region IIa (v >= s1 > v0: c1 <= c1base + 1) and region IIb (v < s1: Gaussian domination).
        c1b = 1 - GAM + 1 / (2 * vM); c2b = GAM + 1 / (2 * vM) + 2 * Z1
        sI = lo(min(arb((P5 - 2 / l0) / (tau * tau) - (c1b + arb('0.5002') + c2b) / 2 - arb('0.2501')).lower(),
                    arb((2 * SIG - Rb - U_MIN) / (tau * tau) - (l0 + c1b + arb('0.5002')) / 2 - arb('0.2501')).lower()))
        if not (sI >= rate / 2) or not (arb(2) / (tau * rate) <= gm + tau * Pb_):
            return -math.inf, dict(why='B3_slopeI')
        if not (tau.upper() <= 0.5 and Rb.lower() >= 1 and (Rb - SIG).upper() <= 400 and v0.lower() >= 2500):
            return -math.inf, dict(why='B3_domain')
        U1 = 1 - v0
        sIIa = lo((P5 - 2 / l0) / (tau * tau) - (c1b + 1 + c2b) / 2)
        if not (sIIa > 1): return -math.inf, dict(why='B3_sIIa')
        lq1 = (log_q(U_MIN) + common) - sI * (U_MIN - U1) + (v0 - lo(Rb)) / 2 + 1 / l0   # log q_IIa(U1) upper
        q1 = hi(lq1.exp())
        T0 += hi(q1 / sIIa)
        T1 += hi(q1 * ((((Rb - U1) + tau * tau * Pb_) / tau + tau * Pb_) / tau / sIIa + 1 / (tau * tau * sIIa * sIIa)))
        B0 = arb(max(0.0, -float(Lfac.lower())) * 1.0000001 + 1e-300) / 2 - lo(((Rb + a) / 2).lgamma()) + arb(2).zeta().log() + vert + common + 1
        eIIb = hi((B0 - v0 * v0 / (16 * tau * tau)).exp())
        T0 += eIIb; T1 += eIIb
    # by-parts boundary term at U = us
    T1 += hi((log_q(us) + common).exp())
    den = Pb - Ie - T0
    if not (den > 0): return -math.inf, dict(why='den', Pb=float(Pb), Ie=float(Ie.upper()), T0=float(T0.upper()))
    K = (Nb + T1 + Pb_ * T0) / den
    S = (rho_lo - Z1) / 2 - hi(K) / 2
    return flo(S), dict(L=float(Lfac.mid()), rho=float(rho_lo), Z1=float(Z1), Pb=float(Pb), Ie=float(Ie.upper()), Nb=float(Nb.upper()), T0=float(T0.upper()), T1=float(T1.upper()), K=float(K.upper()))
if __name__ == "__main__":
    for (R, tau) in [(1.704, 0.1), (1.964, 0.2), (2.4, 0.3), (3.778, 0.5), (10.0, 0.3), (40.0, 0.5), (40.0, 0.007), (1.6203, 0.007)]:
        S, info = big2(R, tau, 2500)
        print(f"xaware v>=2500: R={R} tau={tau}: S-L/4 >= {S:.4f}  {info}", flush=True)
    for (R, tau) in [(40.0, 0.5), (40.0, 0.1), (40.0, 0.01), (40.0, 0.007)]:
        S, info = big2(R, tau, 0, mode='xfree', v1=2500)
        print(f"xfree 0<=v<=2500: R={R} tau={tau}: S-L/4 >= {S:.4f}  {info}", flush=True)
