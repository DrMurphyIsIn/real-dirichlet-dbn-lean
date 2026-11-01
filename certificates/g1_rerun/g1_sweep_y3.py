"""G1 hybrid sweep driver (bb REVIEW_P5_DELTA C1-C5).  Certifies S - L/4 >= -K0 (K0 = 1) with tl_arb_cert.floor_box
(R1-patched, C1 outward return) over the compact C2 domain D_G1 = {L in [L0, 4e4], t in [1e-4, T(L)], x in [0, 1e4]}.

Hybrid (C4):
  corner    CORNER = [L0d, LC] x [T0d, TC] x [0, XC]  in (L, t, x) boxes  (mode 'corner');
  remainder (R, tau, x) boxes over c2_domain.R_range with the tau* breakpoint (C3), padded by 1e-6 in R (mode 'rem').
  A remainder node is dropped only if an Arb test shows
    (out)  hi(L) < L0d  or  hi(t) < T0d            -> the node meets no point of D (D has L >= L0, t >= 1e-4), or
    (stl)  lo(L) > 4e4                              -> covered by Lemma STL (memo A.9.3), not by G1, or
    (abv)  hi(L) <= 4e4 and lo(t) > hi(T(L-ball))  -> t > T(L) at every point (T enclosed in Arb), not in D, or
    (cor)  hi(L) <= LC and hi(t) <= TC and hi(x) <= XC -> every point of node & D lies in CORNER (D has L >= L0 >= L0d,
           t >= 1e-4 >= T0d), and CORNER is certified separately;
  with L = 2(R - sigma')/tau^2 and t = 2 tau^2 enclosed in Arb.  Otherwise it is certified or bisected (children tile it).
Edges (C2): L0d = float rounded DOWN from log(1e8/pi), T0d = float rounded DOWN from 1e-4 (both asserted in Arb).
Initial boxes are processed in a seeded random order, each to completion by one worker (per-box cap), so the per-box
cost sample is unbiased for the re-estimate (C5).  Ledger JSON every 60 s, DONE file at the end, unfinished boxes saved.
Usage: python3 g1_sweep.py MODE a budget_s workers prefix [cap_s] [index_file]"""
import sys, os, time, math, json, random
for v in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS'): os.environ[v] = '1'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from concurrent.futures import ProcessPoolExecutor, wait, FIRST_COMPLETED
from flint import arb
from c2_domain import R_range, T

K0 = 1.0
from flint import ctx
L0d = math.nextafter(math.log(1e8 / math.pi), -math.inf)
T0d = math.nextafter(1e-4, 0.0)
_p = ctx.prec; ctx.prec = 200
assert arb(L0d) < (arb(10) ** 8 / arb.pi()).log() and arb(T0d) < arb(1) / 10000   # C2: edges are outward
ctx.prec = _p
LC = math.log(10 ** 8.5 / math.pi); TC = 0.05; XC = 5.0          # CORNER upper edges (exact floats, used as-is)
TAU_LO = math.sqrt(1e-4 / 2) * 0.999; TAU_HI = 0.3718; TSTAR = math.sqrt(T(4e4) / 2)
SIGA = (1 + arb(5).sqrt()) / 2
XB = [0.0, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 256.0, 512.0, 1024.0, 2048.0, 4096.0, 8192.0, 1e4]

def initial_boxes(mode):
    out = []
    if mode == 'corner':
        tc = [T0d, 2e-4, 5e-4, 1e-3, 2e-3, 5e-3, 0.01, 0.02, 0.03, 0.04, TC]
        xc = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, XC]
        Lc = [L0d + (LC - L0d) * k / 4 for k in range(4)] + [LC]
        for i in range(4):
            for j in range(len(tc) - 1):
                for k in range(len(xc) - 1):
                    out.append((Lc[i], Lc[i + 1], tc[j], tc[j + 1], xc[k], xc[k + 1]))
        return out
    taus = [TAU_LO]
    while taus[-1] < TAU_HI:
        nb = min(taus[-1] * 1.1, TAU_HI)
        if taus[-1] < TSTAR < nb: nb = TSTAR
        taus.append(nb)
    for i in range(len(taus) - 1):
        t0, t1 = taus[i], taus[i + 1]
        rr = [r for r in (R_range(t0), R_range(t1)) if r]     # R_lo increasing; R_hi monotone on each side of tau*
        if not rr: continue
        Rlo = min(r[0] for r in rr) - 1e-6; Rhi = max(r[1] for r in rr) + 1e-6
        nR = max(1, math.ceil((Rhi - Rlo) / 0.5))
        for j in range(nR):
            for k in range(len(XB) - 1):
                out.append((Rlo + (Rhi - Rlo) * j / nR, Rlo + (Rhi - Rlo) * (j + 1) / nR, t0, t1, XB[k], XB[k + 1]))
    return out

P5A = arb(5).sqrt()
def T_up(Lb):
    """Arb enclosure of T(L) (memo A.9.0) over the ball Lb, for Lb <= 4e4 (t_min = 1e-4); b(L) = min(1e-4, L^-2)."""
    tm = arb(1) / 10000
    if Lb.upper() <= 100: b = arb(1) / 10000
    elif Lb.lower() >= 100: b = 1 / (Lb * Lb)
    else: b = (arb(1) / 10000).union(1 / (arb(Lb.upper()) ** 2))
    k = (Lb - 4) / P5A - 2
    return tm + ((2 + k * (1 - 2 * tm)) / (2 + k * b)).log() / k

def classify_rem(R0, R1, u0, u1, x1):
    Rb = arb(R0).union(arb(R1)); tau = arb(u0).union(arb(u1))
    Lb = 2 * (Rb - SIGA) / (tau * tau); tb = 2 * tau * tau
    if Lb.upper() < arb(L0d) or tb.upper() < arb(T0d): return 'out'      # D has L >= L0, t >= 1e-4 (L <= 4e4)
    if Lb.lower() > 40000: return 'stl'                                   # L > 4e4: Lemma STL (memo A.9.3)
    if Lb.upper() <= 40000 and tb.lower() > T_up(Lb): return 'above'      # t > T(L) on the whole node: not in D
    if Lb.upper() <= arb(LC) and tb.upper() <= arb(TC) and x1 <= XC: return 'corner'
    return None

def run_box(args):
    mode, a, idx, box, cap = args
    from y3_cert import floor_box, iv
    T0 = time.time(); q = [box + (0,)]; st = dict(idx=idx, ev=0, ok=0, out=0, stl=0, above=0, corner=0, worst=math.inf, fail=[], maxd=0)
    while q:
        if time.time() - T0 > cap:
            st['unfinished'] = [b for b in q]; break
        b0, b1, c0, c1, x0, x1, d = q.pop()
        if mode == 'rem':
            c = classify_rem(b0, b1, c0, c1, x1)
            if c: st[c] += 1; continue
            S, _ = floor_box(None, None, iv(x0, x1), a=a, Rb=iv(b0, b1), taub=iv(c0, c1))
        else:
            S, _ = floor_box(iv(b0, b1), iv(c0, c1), iv(x0, x1), a=a)
        st['ev'] += 1; st['maxd'] = max(st['maxd'], d)
        if S >= -K0:
            st['ok'] += 1; st['worst'] = min(st['worst'], S); continue
        if d >= 30:
            st['fail'].append((b0, b1, c0, c1, x0, x1, S)); continue
        if mode == 'rem':
            wb = (b1 - b0) / 0.05; wc = (c1 - c0) / (0.01 * c0); wx = (x1 - x0) / max(0.05, 0.02 * (x0 + 1))
        else:
            wb = (b1 - b0) / 0.02; wc = (c1 - c0) / (0.05 * c0); wx = (x1 - x0) / 0.1
        k = max((wb, 0), (wc, 1), (wx, 2))[1]
        if k == 0: m = (b0 + b1) / 2; q += [(b0, m, c0, c1, x0, x1, d + 1), (m, b1, c0, c1, x0, x1, d + 1)]
        elif k == 1: m = math.sqrt(c0 * c1); q += [(b0, b1, c0, m, x0, x1, d + 1), (b0, b1, m, c1, x0, x1, d + 1)]
        else: m = (x0 + x1) / 2; q += [(b0, b1, c0, c1, x0, m, d + 1), (b0, b1, c0, c1, m, x1, d + 1)]
    st['sec'] = time.time() - T0
    return st

def main():
    mode, a, budget, W, prefix = sys.argv[1], int(sys.argv[2]), float(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
    cap = float(sys.argv[6]) if len(sys.argv) > 6 else 240.0
    boxes = initial_boxes(mode); N = len(boxes)
    order = list(range(N)); random.Random(20261031 + a).shuffle(order)
    if len(sys.argv) > 7:
        order = json.load(open(sys.argv[7]))
    T0 = time.time(); res = []; last = [T0]
    def ledger(final=False):
        done = [r for r in res if 'unfinished' not in r]
        secs = [r['sec'] for r in done]
        n = len(secs); mean = sum(secs) / n if n else float('nan')
        sd = math.sqrt(sum((s - mean) ** 2 for s in secs) / (n - 1)) if n > 1 else float('nan')
        d = dict(mode=mode, a=a, K0=K0, L0d=L0d, T0d=T0d, corner=dict(L=[L0d, LC], t=[T0d, TC], x=[0, XC]),
                 tau_star=TSTAR, initial_boxes=N, attempted=len(res), completed=n,
                 capped=len(res) - n, evaluations=sum(r['ev'] for r in res), certified=sum(r['ok'] for r in res),
                 dropped_out=sum(r['out'] for r in res), dropped_stl=sum(r['stl'] for r in res), dropped_above=sum(r['above'] for r in res), dropped_corner=sum(r['corner'] for r in res),
                 failed=sum(len(r['fail']) for r in res), worst=min([r['worst'] for r in res] + [math.inf]),
                 max_depth=max([r['maxd'] for r in res] + [0]),
                 cpu_s_per_initial_box=dict(mean=mean, sd=sd, max=max(secs) if secs else None),
                 est_total_cpu_h=(N * mean / 3600 if n else None),
                 est_total_cpu_h_95hi=(N * (mean + 1.96 * sd / math.sqrt(n)) / 3600 if n > 1 else None),
                 sec_per_eval=(sum(secs) / max(1, sum(r['ev'] for r in done))), wall_s=round(time.time() - T0, 1),
                 workers=W, cap_s=cap, complete=(final and len(res) == N and n == N and not any(r['fail'] for r in res)),
                 done_idx=sorted(r['idx'] for r in done), fail_examples=[f for r in res for f in r['fail']][:5],
                 capped_idx=[r['idx'] for r in res if 'unfinished' in r])
        open(prefix + '.json', 'w').write(json.dumps(d))
        return d
    nxt = 0; fut = set()
    with ProcessPoolExecutor(max_workers=W) as ex:
        while nxt < len(order) or fut:
            while nxt < len(order) and len(fut) < W and time.time() - T0 < budget - cap - 15:
                i = order[nxt]; nxt += 1
                fut.add(ex.submit(run_box, (mode, a, i, boxes[i], cap)))
            if not fut: break
            dn, fut = wait(fut, timeout=30, return_when=FIRST_COMPLETED)
            for f in dn: res.append(f.result())
            if time.time() - last[0] > 60: ledger(); last[0] = time.time()
    d = ledger(final=True)
    json.dump([r for r in res if 'unfinished' in r], open(prefix + '.unfinished.json', 'w'))
    open(prefix + '.DONE', 'w').write(json.dumps({k: d[k] for k in d if k not in ('done_idx',)}))
    print(json.dumps({k: d[k] for k in d if k not in ('done_idx', 'capped_idx')}))

if __name__ == '__main__':
    main()
