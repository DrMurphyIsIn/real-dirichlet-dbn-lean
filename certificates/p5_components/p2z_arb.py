"""P2' (Lemma Z') in Arb (memo A.12).  Zero-free region for H_t^chi:
   x >= X(L) := 4 exp(ell(L) - L),  y_b(L) <= |y| <= 1,  t_min(L) <= t <= 1/2,   for every L = log(m/pi) >= L0,
   ell(L) := 8 max(4e4, L),  y_b = sqrt(b) = min(0.01, 1/L),  t_min = min(1e-4, 4/L).
Criterion (FGMPS 2610.27343 Thm 4.3 + Prop 4.18, valid for every m >= 3 per memo A.8/A.10 N2; |H/B| >= |f| - E):
   Q := 1 - (zeta(r) - 1) - g zeta(r') - eta (zeta(r) + g zeta(r')) - eC0 > 0   (lemma_z.py, same notation).
Part 1: the analytic proof's constants (Arb).  Part 2: direct Arb evaluation of Q over (L, t, y) boxes at x = X(L)
(m = pi e^L, x = 4 e^{ell - L}, q = e^ell), as an independent check of Part 1; replaces lemma_z's 61-point y sample."""
import sys, time, math, json
from flint import arb, acb, ctx
ctx.prec = 80
PI = arb.pi(); A0 = arb('1.276873')

def zeta_up(r):           # zeta decreasing on (1, inf): sup over the ball is at its lower end
    return arb(r.lower()).zeta().upper() if r.lower() > 1 else None

def Q_box(Lb, tb, yb, ell0, Llo):
    """Arb lower bound of Q over the box (L, t, y) at the single point x = X_box := 4 e^{ell0 - Llo} (Llo = lower end of
    the L-box), so log q = log(m x / 4 pi) = L + ell0 - Llo >= ell0.  By x-monotonicity this gives every x >= X_box.
    Large quantities (m, q, B*, c1(0)) are carried as logarithms, so wide L-boxes stay finite."""
    logm = Lb + PI.log()
    x = 4 * (arb(ell0) - arb(Llo)).exp(); ell = Lb + arb(ell0) - arb(Llo)          # ell = log q, a ball
    lp = ell / 2 - (1 + PI * tb / (4 * x)).log() / 2
    eps1 = (3 + yb) * tb / (2 * x * x)
    r = (1 + yb) / 2 - eps1 + tb / 4 * lp; rp = (1 - yb) / 2 - eps1 + tb / 4 * lp
    if not (rp.lower() > 1): return -math.inf, dict(why='rp')
    logdplus = ell / 2 + (1 + PI * tb / (4 * x)).log() / 2
    am = arb('0.002') + logm / 3800
    g = (am * yb - yb / 2 * ell + tb * yb * logdplus / (2 * (x - 2))).exp()
    eta = ((tb * tb / 16 * ell ** 2 + logm / 2250 + arb('1.3')) / (x - arb(2.5))).exp() - 1
    Tp = x / 2 + PI * tb / 8
    logB = logm / 2 + PI / 4 * (-arb(logm.lower())).exp() + (logm / (2 * PI) + A0 + arb('1e-9')).log()     # B*_m (4.31), m >= 3
    logc10 = (arb(2) / 5).log() + logm                                                       # c1(0) <= 2m/5
    absl = (ell ** 2 + PI * PI / 4).sqrt()
    leC = -(1 + yb) / 4 * (logm + Tp.log() - (2 * PI).log()) - tb / 16 * ell ** 2 + (absl / 4 + arb('1.54')) / (x - arb(2.5))
    eC0 = 2 * (leC + logB).exp() * (arb(25) / (12 * (x - arb(2.5)))).exp() \
        + 2 * (leC + (arb(167) / 8).log() + logc10 - ((Tp / arb('7.49')).sqrt() - arb(1.5)).log()).exp() * (4 / (x - arb(2.5))).exp()
    z, zp = arb(zeta_up(r)), arb(zeta_up(rp))
    Q = 1 - (z - 1) - g * zp - eta * z - g * eta * zp - eC0
    return float(Q.lower()), dict(r=float(r.lower()), rp=float(rp.lower()), g=float(g.upper()), eta=float(eta.upper()), eC0=float(eC0.upper()))

def part1():
    """Constants of the analytic proof (memo A.12.2)."""
    z45 = arb('4.49').zeta(); z399 = arb('3.99').zeta(); gb = arb('-3.9992').exp()
    tiny = arb(10) ** -100
    Qlo = 1 - (z45 - 1) - gb * z399 - tiny * (z45 + z399) - tiny
    # tiny-term majorants as functions of ell >= 3.2e5 (each decreasing in ell for ell >= 100): evaluate at 3.2e5
    l = arb(320000)
    eta_maj = 2 * (l * l / 64 + l / 18000 + arb('1.31')) / (4 * (7 * l / 8).exp() - arb(2.5))          # eta <= 2d (d << 1)
    eC_maj = (-l / 4).exp() * arb('1.001') * (2 * arb('1.7726') * (l / 16).exp() * (l / 50 + 3) * arb('1.001')
                                                + (arb(167) * arb('1.2567') / 4) / (arb('0.25') * (7 * l / 16).exp()) * (l / 8).exp())
    return dict(zeta_449_minus_1=float((z45 - 1).upper()), zeta_399=float(z399.upper()), g_bound=float(gb.upper()),
                Q_lower_with_tiny_1e_100=float(Qlo.lower()), eta_majorant_at_3_2e5_log10=float((eta_maj.log() / arb(10).log()).upper()),
                eC0_majorant_at_3_2e5_log10=float((eC_maj.log() / arb(10).log()).upper()))

def part2(budget, out):
    T0 = time.time(); led = dict(boxes=0, failed=[], worstQ=math.inf, regions={})
    L0d = math.nextafter(math.log(1e8 / math.pi), -math.inf)
    # region A: L in [L0d, 4e4]; region B: L in [4e4, 1e12] (sampled cover of B is a check only; B is proved analytically)
    for name, La, Lb_, nL in (('A', L0d, 4e4, 120), ('B', 4e4, 1e12, 40)):
        rL = (Lb_ / La) ** (1 / nL); cnt = 0; worst = math.inf
        for i in range(nL):
            l0, l1 = La * rL ** i, (La * rL ** (i + 1) if i < nL - 1 else Lb_)
            Lb = arb(l0).union(arb(l1))
            ell = 8 * max(4e4, l1)
            tlo = min(1e-4, 4 / l1); ylo = min(0.01, 1 / l1)       # smallest t_min, y_b over the L-box
            nt, ny = 24, 16
            rt = (0.5 / tlo) ** (1 / nt); ry = (1 / ylo) ** (1 / ny)
            for j in range(nt):
                tb = arb(tlo * rt ** j).union(arb(min(0.5, tlo * rt ** (j + 1))))
                for k in range(ny):
                    yb = arb(ylo * ry ** k).union(arb(min(1.0, ylo * ry ** (k + 1))))
                    Q, parts = Q_box(Lb, tb, yb, ell, l0)
                    led['boxes'] += 1; cnt += 1; worst = min(worst, Q)
                    if not (Q > 0): led['failed'].append((l0, l1, float(tb.lower()), float(tb.upper()), float(yb.lower()), float(yb.upper()), Q, parts))
            if time.time() - T0 > budget: break
        led['regions'][name] = dict(L=[La, Lb_], L_boxes=nL, boxes=cnt, worstQ=worst)
        led['worstQ'] = min(led['worstQ'], worst)
    led['seconds'] = round(time.time() - T0, 1); led['complete'] = time.time() - T0 <= budget
    led['failed'] = led['failed'][:10]; led['n_failed'] = len(led['failed'])
    return led

if __name__ == '__main__':
    budget = float(sys.argv[1]) if len(sys.argv) > 1 else 1500; out = sys.argv[2] if len(sys.argv) > 2 else 'p2z_arb'
    p1 = part1(); print(json.dumps(dict(part1=p1)), flush=True)
    p2 = part2(budget, out)
    d = dict(part1=p1, part2=p2)
    open(out + '.json', 'w').write(json.dumps(d)); open(out + '.DONE', 'w').write(json.dumps(dict(n_failed=p2['n_failed'], boxes=p2['boxes'], worstQ=p2['worstQ'], seconds=p2['seconds'], complete=p2['complete'])))
    print(json.dumps(d))
