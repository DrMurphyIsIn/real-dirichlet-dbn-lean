"""W2B3 LX certifier: y3_big2.py (aafeba32; P5 tl_big2 cc065977 + Y3 B1-B4) EXTENDED by an upper bound on
   G := d/dp S_chi(x, p, t) = (1/4) Re[(D'/D)'(c)]   for ALL x >= 4 v0 (xaware mode; v-monotone as in P5 A.9.2, see below).
The S computation is UNCHANGED line for line (bit-identical to y3_big2.big2: w2b3_check.py); G lines are marked "W2B3".
Derivation (W2B3 memo sec. 2.2, the variance form; notation of big2: f = Phi'/Phi, beta = beta1 + beta2, |beta| <= Pb_,
|f(w) - beta| <= num on the bulk, |f'(w)| = |psi_a'(w) + (L'/L)'(w)| <= M + z2; <h> the normalised average, <1> = 1):
   (D'/D)' = <f' + (f - beta)^2> - <f - beta>^2,
   |<f' + (f - beta)^2>| <= (Nb2 + T2 + 2 Pb_ T1 + Pb_^2 T0)/den,  Nb2 = int_bulk e^{eps}(M + z2 + num^2) phi (+ gap, + right tail),
   |<f - beta>| <= K (the existing bound),   G <= (1/4)(K3 + K^2).   (N3, auditor review REVIEW_W2B3: docstring aligned with the code.)
Tails, by parts twice on the tail (w = c2 + tau g): (1/tau^2) int_tail |Phi| (g^2+1) phi + boundary |Phi(w_s)| phi(g_s) (|g_s|/tau^2
+ |Phi'/Phi(w_s)|/tau), with |g| <= gpr(U) = (|R - U| + tau^2 Pb_)/tau in the U-measure (as for T1), |Phi'/Phi(w_s)| <= P_up((us+a)/2, vm)
+ Z(us).  Far tail U < U_MIN (region I slope >= rate/2 as in B3): int e^{-(rate/2) s} ((gm + s/tau)^2 + 1) ds <= 2.5 (gm^2+1)/(rate/2)
= 5 (gm^2 + 1)/rate, valid when gm tau (rate/2) >= 2 (asserted; else G = +inf).  Region IIa: int e^{-sIIa s'} ((g1 + s'/tau)^2 + 1)/tau^2
= ((g1^2+1)/sIIa + 2 g1/(tau sIIa^2) + 2/(tau^2 sIIa^3))/tau^2 with g1 = ((R - U1) + tau^2 Pb_)/tau.  Region IIb: eIIb (the quadratic
multiplier ((s1 + R + 1)/tau^2)^2 <= exp(s1^2/(16 tau^2)) for s1 >= 2500, tau <= 1/2: absorbed by the same slack as T0/T1).
Right Gaussian tail g > G_HI: num <= y := (tau^2 Pb_ + tau g)(M0 + z2c), 2 Pb_ num + num^2 + M0 + z2c <= (2 Pb_ + 1 + M0 + z2c) e^{2y}.
v-monotonicity (P5 A.9.2, inherited): every new piece is a product of pieces already shown non-increasing in v (num, M, z2, q) or
the boundary term q(us) * (|psi_a(w_s)| + Z + |g_s|/tau), where q(us) ~ v^{-(R-us)/2} (lg = -(R-U) gl_) and |psi_a| ~ (1/2) log v:
their product is non-increasing in v >= v0 >= 2500 when R - us >= 1/2 (checked: d/dv log|psi_a| <= 1/(v log v) < (R-us)/(2v) for
v >= 2500 iff R - us > 2/log 2500 = 0.256); asserted R - us >= 1/2."""
import math
from flint import arb, acb, acb_series, ctx
from y3_big import flo, lo, hi, zeta_pt, zeta2_pt, Z_up, Z2_up, lzeta_up, M_up, rho_lo_f, P_up, SIG, SQ2PI, GAM, LOG2, P5
ctx.prec = 64
def fhi(x):
    h = arb(x).upper(); f = float(h)
    if not math.isfinite(f): return math.inf
    if arb(f) < h: f = math.nextafter(f, math.inf)
    return f
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
    assert mode == 'xaware' and (Rb - us).lower() >= 0.5   # W2B3: v-monotonicity of the new boundary term (docstring)
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
        num2 = hi(M + z2 + num * num)                     # W2B3: |f' + (f - beta)^2| <= M + z2 + num^2 (eta = f - beta, |eta| <= num)
        return eps, num, num2
    # bulk main part [max(gs,G_LO), G_HI]
    G_HI = arb(40); glo = gs if gs > G_LO else arb(G_LO)
    width = (G_HI - glo) / ncell
    Ie = arb(0); Nb = arb(0)
    Nb2 = arb(0)                                          # W2B3
    for k in range(ncell):
        g = (glo + k * width).union(glo + (k + 1) * width)
        eps, num, num2 = integrand_bounds(g)
        w = (-(g * g) / 2).exp() / SQ2PI
        Ie += width * hi((eps.exp() - 1) * w); Nb += width * hi(eps.exp() * num * w)
        Nb2 += width * hi(eps.exp() * num2 * w)           # W2B3
    if gs < G_LO:   # piece [gs, G_LO]: cells with exact Gaussian masses, integrand sup per cell
        ncr = 200; wc = (arb(G_LO) - gs) / ncr
        cdf = lambda z: (-(z) / arb(2).sqrt()).erfc() / 2
        for k in range(ncr):
            a_ = gs + k * wc; b_ = a_ + wc
            eps, num, num2 = integrand_bounds(a_.union(b_))
            mass = hi(cdf(b_) - cdf(a_)) if True else 0
            Ie += hi(eps.exp() * mass); Nb += hi(eps.exp() * num * mass)
            Nb2 += hi(eps.exp() * num2 * mass)            # W2B3
    # Y3 B4 (auditor review REVIEW_Y3 sec. 4; re-derived by Y3, memo sec. 4.5): after the contour shift the
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
    if not (hi(tau * Z1) + gs < 0): return -math.inf, math.inf, dict(why='B4_guard')   # gap has Re w < Re c1
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
    numg2 = hi(Mg + Z2_up(us) + numg * numg)               # W2B3: on the gap, |f'| <= Mg + Z2(us), |f - beta| <= numg
    Nb2 += hi(Cg.exp() * numg2 * massg)                    # W2B3
    # right tail g > G_HI
    M0 = M_up((lo(Rb) + a) / 2, vm); z2c = Z2_up(Rc1)
    A2 = 1 - tau * tau * (M0 + z2c)
    if not (A2 > 0): return -math.inf, math.inf, dict(why='A2')
    B = tau ** 3 * Pb_ * (M0 + z2c) + tau * (M0 + z2c + 1); C = (tau * tau * Pb_) ** 2 * (M0 + z2c) / 2 + tau * tau * Pb_ - SQ2PI.log()
    right = hi((C + B * B / (2 * A2)).exp() * (arb.pi() / (2 * A2)).sqrt() * ((A2 / 2).sqrt() * (G_HI - B / A2)).erfc())
    Ie += right; Nb += right
    # W2B3: right tail of Nb2: eps <= (tau^2 Pb_ + tau g)^2 (M0+z2c)/2 (coefficients: const (tau^2 Pb_)^2 (M0+z2c)/2, linear
    # tau^3 Pb_ (M0+z2c), quadratic tau^2 (M0+z2c)/2 -> A2), times (2 Pb_ + 1 + M0 + z2c) exp(2 (tau^2 Pb_ + tau g)(M0 + z2c))
    Mz = M0 + z2c
    B2 = tau ** 3 * Pb_ * Mz + 2 * tau * Mz
    C2 = (tau * tau * Pb_) ** 2 * Mz / 2 + 2 * tau * tau * Pb_ * Mz - SQ2PI.log() + (1 + Mz).log()   # Mz + y^2 <= (1 + Mz) e^{2y}
    right2 = hi((C2 + B2 * B2 / (2 * A2)).exp() * (arb.pi() / (2 * A2)).sqrt() * ((A2 / 2).sqrt() * (G_HI - B2 / A2)).erfc())
    Nb2 += right2
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
    T2 = arb(0)                                           # W2B3
    for k in range(nt):
        U = (U_MIN + k * wu).union(U_MIN + (k + 1) * wu)
        q = (log_q(U) + common).exp()
        T0 += wu * hi(q)
        gpr = hi(((Rb - U).abs_upper() + tau * tau * Pb_) / tau)
        T1 += wu * hi(q * (gpr + tau * Pb_) / tau)
        T2 += wu * hi(q * (gpr * gpr + 1) / (tau * tau))   # W2B3
    # far tail U < U_MIN: d/dU log q >= rate (xaware: min(p/tau^2 - (c1+c2)/2, 1/tau^2) - 1; xfree: see memo), so int <= q(U_MIN)/rate
    if mode == 'xaware':
        rate = P5 / (tau * tau) - cc / 2 - 1
        r2 = 1 / (tau * tau) - 1
        rate = rate if rate < r2 else r2
    else:
        rate = (2 * SIG - Rb - U_MIN) / (tau * tau) - ((1 - U_MIN + a) / 2 + 1).log() / 2 - Lfac * 0 - 1
    qm = (log_q(U_MIN) + common).exp()
    gm = hi(((Rb - U_MIN).abs_upper() + tau * tau * Pb_) / tau)
    if not (rate > 1): return -math.inf, math.inf, dict(why='rate')
    T0 += hi(qm / rate * 2); T1 += hi(qm * (gm + tau * Pb_) / tau / rate * 4)
    G_ok = bool(gm * tau * (rate / 2) >= 2)               # W2B3: the quadratic far-tail integral bound needs gm tau (rate/2) >= 2
    T2 += hi(qm * (gm * gm + 1) / (tau * tau) / rate * 5)  # W2B3
    if mode == 'xaware':
        # Y3 B3 (far-far tail, memo Y3 sec. 3.3): the closed-form majorant log_q is NOT integrable as U -> -inf (its c1 term
        # sp/vM grows with s1 = 1-U), so the slope bound above holds only on region I = [1 - v0, U_MIN].  Check that slope,
        # then add region IIa (v >= s1 > v0: c1 <= c1base + 1) and region IIb (v < s1: Gaussian domination).
        c1b = 1 - GAM + 1 / (2 * vM); c2b = GAM + 1 / (2 * vM) + 2 * Z1
        sI = lo(min(arb((P5 - 2 / l0) / (tau * tau) - (c1b + arb('0.5002') + c2b) / 2 - arb('0.2501')).lower(),
                    arb((2 * SIG - Rb - U_MIN) / (tau * tau) - (l0 + c1b + arb('0.5002')) / 2 - arb('0.2501')).lower()))
        if not (sI >= rate / 2) or not (arb(2) / (tau * rate) <= gm + tau * Pb_):
            return -math.inf, math.inf, dict(why='B3_slopeI')
        if not (tau.upper() <= 0.5 and Rb.lower() >= 1 and (Rb - SIG).upper() <= 400 and v0.lower() >= 2500):
            return -math.inf, math.inf, dict(why='B3_domain')
        U1 = 1 - v0
        sIIa = lo((P5 - 2 / l0) / (tau * tau) - (c1b + 1 + c2b) / 2)
        if not (sIIa > 1): return -math.inf, math.inf, dict(why='B3_sIIa')
        lq1 = (log_q(U_MIN) + common) - sI * (U_MIN - U1) + (v0 - lo(Rb)) / 2 + 1 / l0   # log q_IIa(U1) upper
        q1 = hi(lq1.exp())
        T0 += hi(q1 / sIIa)
        T1 += hi(q1 * ((((Rb - U1) + tau * tau * Pb_) / tau + tau * Pb_) / tau / sIIa + 1 / (tau * tau * sIIa * sIIa)))
        g1 = hi(((Rb - U1) + tau * tau * Pb_) / tau)                                      # W2B3
        T2 += hi(q1 * ((g1 * g1 + 1) / sIIa + 2 * g1 / (tau * sIIa * sIIa) + 2 / (tau * tau * sIIa ** 3)) / (tau * tau))   # W2B3
        B0 = arb(max(0.0, -float(Lfac.lower())) * 1.0000001 + 1e-300) / 2 - lo(((Rb + a) / 2).lgamma()) + arb(2).zeta().log() + vert + common + 1
        eIIb = hi((B0 - v0 * v0 / (16 * tau * tau)).exp())
        T0 += eIIb; T1 += eIIb
        # W2B3 (N2, auditor review REVIEW_W2B3): eIIb = exp(B0 - v0^2/(16 tau^2)) comes from Y3 memo sec. 4.3 (B3, region IIb; P5 A.9.1): Lemma
        # Gamma-down (DLMF 5.7.6) gives log q <= B0 - s1^2/(8 tau^2) for s1 >= 2500, tau <= 1/2, R >= 1, R - sigma' <= 400 (checked
        # above); half of that exponent, e^{-s1^2/(16 tau^2)}, absorbs the multiplier: T1's linear one (Y3 B3-a) and here the quadratic
        # ((s1 + R + 1)/tau^2)^2 <= e^{s1^2/(16 tau^2)} (log LHS <= 2 log(2 s1) + 4 |log tau| < 40 << 1.56e6 at s1 = 2500), leaving eIIb.
        T2 += eIIb
    # by-parts boundary term at U = us
    qus = hi((log_q(us) + common).exp())
    T1 += qus
    # W2B3: D'' boundary terms at U = us: q(us) (|g_s|/tau + |psi_a(w_s)| + Z(us)), |g_s| <= gpr(us)
    gpr_s = hi(((Rb - us).abs_upper() + tau * tau * Pb_) / tau)
    T2 += hi(qus * (gpr_s / tau + P_up((us + a) / 2, vm) + Z_up(us)))
    den = Pb - Ie - T0
    if not (den > 0): return -math.inf, math.inf, dict(why='den', Pb=float(Pb), Ie=float(Ie.upper()), T0=float(T0.upper()))
    K = (Nb + T1 + Pb_ * T0) / den
    S = (rho_lo - Z1) / 2 - hi(K) / 2
    # W2B3: G upper bound.  (D'/D)' = <f' + (f - beta)^2> - <f - beta>^2; tails of f' + f^2 - 2 beta f + beta^2 are bounded by
    # T2 + 2 Pb_ T1 + Pb_^2 T0 (T1 >= |tail(f)|, T2 >= |tail(f' + f^2)|); |<f - beta>| <= K.  G <= (1/4)(K3 + K^2).
    K3 = hi((Nb2 + T2 + 2 * Pb_ * T1 + Pb_ * Pb_ * T0) / den)
    G = (K3 + hi(K) * hi(K)) / 4
    Gf = fhi(G) if G_ok else math.inf
    return flo(S), Gf, dict(L=float(Lfac.mid()), rho=float(rho_lo), Z1=float(Z1), Pb=float(Pb), Ie=float(Ie.upper()), Nb=float(Nb.upper()),
                            T0=float(T0.upper()), T1=float(T1.upper()), K=float(K.upper()), Nb2=float(Nb2.upper()), T2=float(T2.upper()),
                            K3=float(K3), G_ok=G_ok)
if __name__ == "__main__":
    for (R, tau) in [(2.26, 0.0071), (2.3, 0.1), (2.5, 0.2), (2.9, 0.3), (3.4, 0.39)]:
        S, G, info = big2(R, tau, 2500)
        print(f"xaware v>=2500: R={R} tau={tau}: S-L/4 >= {S:.4f}  G <= {G:.4f}  {info}", flush=True)
