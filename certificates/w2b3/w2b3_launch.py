"""W2B3 launcher: runs the cover sweeps of a plan json (w2b3_design.py output) with at most W workers (subprocesses, BLAS pinned),
one sweep per slab: Y3_P=p w2b3_sweep.py a m_lo 1e8 t_hi CF_i CG_i prefix_s{i} 1.02 t_lo delta.  Skips slabs whose DONE file
exists.  Checks for live copies of the same prefix before starting (ps).  Foreground; prints a summary when all are done.
Usage: python3 w2b3_launch.py plan.json prefix [W] [m_hi]"""
import os, sys, json, time, subprocess
for v in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS'): os.environ[v] = '1'
def main():
    plan = json.load(open(sys.argv[1])); prefix = sys.argv[2]; W = int(sys.argv[3]) if len(sys.argv) > 3 else 4
    m_hi = int(sys.argv[4]) if len(sys.argv) > 4 else 100000000
    here = os.path.dirname(os.path.abspath(__file__))
    ps = subprocess.run(['ps', '-axo', 'pid,command'], capture_output=True, text=True).stdout
    # sweeps of this prefix: python3 processes running w2b3_sweep.py (not this launcher, not a shell whose command text mentions them)
    live = [l for l in ps.splitlines() if prefix in l and 'w2b3_sweep.py' in l and 'python3' in l and '/bin/zsh' not in l and 'eval' not in l]
    assert not live, 'live copy found: ' + '\n'.join(live)
    jobs = []
    for i, s in enumerate(plan['slabs']):
        pre = f"{prefix}_s{i}"
        if os.path.exists(pre + '.DONE'): continue
        args = ['python3', os.path.join(here, 'w2b3_sweep.py'), str(plan['a']), str(plan['m_lo']), str(m_hi), repr(s['t_hi']),
                repr(s['CF']), repr(s['CG']), pre, '1.02', repr(s['t_lo']), repr(plan['delta'])]
        jobs.append((pre, args))
    env = dict(os.environ, Y3_P=str(plan['p']))
    running = []; T0 = time.time()
    while jobs or running:
        while jobs and len(running) < W:
            pre, args = jobs.pop(0)
            log = open(pre + '.log', 'w')
            running.append((pre, subprocess.Popen(args, env=env, cwd=here, stdout=log, stderr=subprocess.STDOUT), log, time.time()))
            print(f"started {pre} [{time.time()-T0:.0f}s]", flush=True)
        time.sleep(5)
        still = []
        for pre, pr, log, t0 in running:
            if pr.poll() is None:
                if time.time() - t0 > 1800: pr.kill(); print(f"KILLED {pre} after 30 min", flush=True)
                else: still.append((pre, pr, log, t0)); continue
            log.close()
            d = json.load(open(pre + '.DONE')) if os.path.exists(pre + '.DONE') else None
            print(f"finished {pre}: rc={pr.returncode} " + (f"n_failed={d['n_failed']} worst_g1={d['worst_g1']:.4f} worst_lx={d['worst_lx']:.4f} maxG_g1={d['maxG_g1']:.4f} maxG_lx={d['maxG_lx']:.4f} evals={d['evals']} sec={d['sec']}" if d else 'NO DONE FILE'), flush=True)
        running = still
    print(f"all done [{time.time()-T0:.0f}s]")
if __name__ == '__main__':
    main()
