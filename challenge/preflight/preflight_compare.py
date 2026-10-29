"""bb, 2026-10-29: pre-flight comparison of exact ConstantInfo dumps (challenge env vs solution env).
Raw = byte-identical repr (binder names included: STRICTER than Comparator). Norm = hygienic binder names
`inst.«_@».<Module> ... _hyg N` mapped to `inst.«_@».<M>` (Comparator's Expr BEq = Expr.eqv ignores binder names)."""
import os, re, hashlib, difflib
W = os.path.expanduser('~/e9-research/review_cn1/p1p6/chal/log')
def blocks(f):
    t = open(f'{W}/{f}').read()
    return {m.group(1): m.group(2) for m in re.finditer(r'DUMP-BEGIN (\S+)\n(.*?)\nDUMP-END \1', t, re.S)}
norm = lambda s: re.sub(r'`inst\.«_@»\.(BbOaiMeaning|Challenge|ChallengeTamperA|ChallengeTamperB) ', '`inst.«_@».<M> ', s)
h = lambda s: hashlib.md5(s.encode()).hexdigest()[:8]
sol = blocks('BbPreflightSol.out')
for side in ['Chal', 'TamperA', 'TamperB']:
    b = blocks(f'BbPreflight{side}.out')
    print(f'--- {side} vs Sol')
    for n in sol:
        s, c = sol[n], b[n]
        raw = 'IDENTICAL' if c == s else 'differs'
        nm = 'IDENTICAL' if norm(c) == norm(s) else 'DIFFERENT'
        print(f'  {n:32s} raw={raw:9s} norm={nm:9s} md5(norm) sol={h(norm(s))} chal={h(norm(c))}')
        if norm(c) != norm(s):
            d = [l for l in difflib.unified_diff(norm(s).split('\n'), norm(c).split('\n'), 'sol', side, n=0, lineterm='') if l[:1] in '+-' and l[:3] not in ('---', '+++')]
            print('    first differing lines (norm):'); [print('     ', l.strip()[:150]) for l in d[:6]]
