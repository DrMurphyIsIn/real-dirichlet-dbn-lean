# Sandboxed Comparator run

These are the logs of the sandboxed [Comparator](https://github.com/leanprover/comparator) run of
`bb_real_primitive_meaning_oai`, against the challenge in `challenge/`. Another agent session (the runner) made the
run on 30 October 2026 in its Linux container. bb, the auditor who wrote the challenge, received all seven logs inline,
matched their md5s, and read them in full. bb's verification is `provenance/REVIEW_COMPARATOR_LAMBDA_CHI.md`; its
Addendum 1 upgrades that record from RELAYED to INSPECTED. bb read the logs but did not repeat the run's kernel
executions.

## The setup

- **Comparator** v4.34.0, built for toolchain v4.34.1.
- **Sandbox:** a bwrap shim in place of landrun (`landrun-bwrap.sh`, md5 `13a13e8b…`). The run was uid 0 with all
  capabilities dropped and no network.
- **OpenAI's environment,** rebuilt from the public pins (`provenance/OAI_ENV.md`):
  - Mathlib from its official build cache at `d13f23b`;
  - PrimeNumberTheoremAnd and rellich-kondrachov cloned at their pins and patched with OpenAI's patches;
  - OpenAI's sources unmodified.
- **The solution:** the chain at the md5s in `lean/MD5SUMS.txt`.

## The logs

| Log | What it shows |
|---|---|
| `main.out` | Comparator with nanoda and Lean's kernel. "Your solution is okay!"; exit 0 |
| `paranoid.out` | The paranoid kernel set: con-leche and con-ron ("accepted 124639"), leanchecker-paranoid, nanoda, Lean's kernel. "Your solution is okay!"; exit 0 |
| `tamperA.out` | The challenge with 9/32 → 1/4. "Challenge and solution theorem statement do not match"; exit 1 |
| `tamperB.out` | The challenge with 1/8 → 1/4. The same rejection; exit 1 |
| `post.out` | The sandboxed solution export: 1,730,282,328 bytes, md5 `5ca44ad5…`. It is byte-identical to the export bb made from its own local build |
| `fresh_check.out` | After the run, the challenge oleans were compared with a fresh build against Mathlib alone, and all 8,548 Mathlib oleans with a fresh decompression of the cache the run used: identical |
| `main_INTERRUPTED_restart.out` | The earlier sandboxed attempt of the same command, killed by a container restart. It compiled the challenge and 27 of the 29 chain modules inside the sandbox. `main.out` replayed those outputs and built the rest |

`main.out` prints "Your solution is okay!" only after the statement comparison, the axiom check
(`[propext, Quot.sound, Classical.choice]`) and every kernel have passed. lean4lean was not run, because its bundled
build cannot read v4.34.1 exports.

Addendum 1 §3 gives the full timeline. One unsandboxed `lake build Challenge` was run between the two attempts to test
Lake's replay behaviour. It compiled nothing, and the challenge oleans match a fresh rebuild.

## The normalisation, and both md5s

The runner's logs embed the path of its scratch directory, which contains an agent session identifier:
`/tmp/claude-0/-home-user-Arda/<session UUID>/scratchpad`. The copies here have that prefix replaced by the literal
string `$SCRATCH`:

```
sed 's|/tmp/claude-0/-home-user-Arda/<session UUID>/scratchpad|$SCRATCH|g'
```

No other byte differs. The paper and REVIEW_COMPARATOR cite the raw md5s, so both are listed. The normalized md5s
are also in `logs/MD5SUMS.txt`.

| Log | Raw md5 (as run) | Normalized md5 (this copy) |
|---|---|---|
| main.out | fc80db0aad9b392d954354ca10a9c970 | 27549b58ecb5ffd6936702dea01802fe |
| paranoid.out | fb16467579fd81ea4bbdbeb2de98578f | 0c511e13101f9340ed0266c959e4e241 |
| tamperA.out | 78a706f654a5f150347d74e945927731 | ebe6a1050ccc3e1edc71791d994bc08e |
| tamperB.out | d1f16445e6cfa2126163a00b8cb02cb3 | 43d6f357498db7d5e6b9c0190035f760 |
| post.out | 27620fb974d7a7c73c46c6206d2f2356 | 6ecd62eb836213a4992a9b19462248ba |
| fresh_check.out | b2cb533c8a499b8fa888e880021d8866 | (no path; unchanged) |
| main_INTERRUPTED_restart.out | 144a7c6b6680df543b94f1e2394cce41 | 6a445130462472cecb7f145889dfbce7 |

## The caveats the result carries

- **uid 0.** The run was made as uid 0. Comparator's assumption that it is not run by a privileged user is met in
  spirit, not in letter.
- **lean4lean** could not take part.
- **Kernel runs not repeated.** The run was made by another agent session. bb read its logs and reproduced the
  solution export byte for byte, but did not repeat its kernel runs. con-leche accepted bb's byte-identical copy. bb's
  local five-checker replay (`logs/five_checker/`) accepted an export of the same build, made with 8 targets instead of
  34 (`6888b248…`). That export differs only by four primitive declarations outside the theorem's closure, and was
  checked with bb's own binaries, not the runner's.
