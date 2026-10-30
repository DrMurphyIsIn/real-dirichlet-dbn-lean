# Provenance of the build environment

bb's local five-checker replays (`logs/five_checker/`) were built against a local tree, `$HOME/oai-replay`. That
tree is a checkout of openai/math's `lean/` directory at commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`, with
Lean v4.34.1 and Mathlib `d13f23b`. It was made on 7 October 2026 for an earlier replay of OpenAI's own Comparator
challenge. Before using it, the auditor compared that checkout with a git clone of
openai/math at the same commit:

- the `OAI/` sources, 121,734 files: identical;
- `lakefile.lean` (`c8078fb2…`), `lake-manifest.json` (`8c3ec864…`), `lean-toolchain` (v4.34.1) and OpenAI's 23
  dependency patches: identical;
- `OAI/NumberTheory/DirichletL/Nonvanishing.lean` (`ea8efdb1…`): identical, and it re-elaborated from source with
  return code 0.

**What was not checked.** The dependency checkouts inside that tree, `$HOME/oai-replay/.lake/packages/*` (Mathlib
and the other packages OpenAI's lakefile pins and patches), were NOT hashed. That directory was touched on
2026-10-24, after the 7 October build, and a sibling `packages_reclone_2026-10-24` exists next to it. Their Mathlib checkout is at `d13f23b`, as the
manifest requires, but their file contents were not compared with the pinned commits plus patches. The kernel
replays check every proof in the export, whatever its source. But the definitions the statement rests on, for
example Mathlib's `completedLFunction`, are trusted as they stood in that tree. So this is a gap in the local
record, and we state it as one.

**How it was closed.** The sandboxed Comparator run did not reuse that local tree. It re-created OpenAI's
environment independently, on Linux, from the public pins: Lean v4.34.1; Mathlib taken from its official build
cache at `d13f23b` (`lake exe cache get`), not rebuilt; PrimeNumberTheoremAnd and rellich-kondrachov cloned at
their pins and patched with OpenAI's patches, per OpenAI's lakefile; and OpenAI's sources read unmodified at
openai/math `adc7f124`. It then built this repository's
chain, at the md5s in `lean/MD5SUMS.txt`, on top. Its solution export is byte-identical to the one bb made from the local tree (md5 `5ca44ad5…`). That closes this gap
for the closure of the main theorem, relative to Mathlib's official cache. **That run, not the local replays, is the
reference result.** `scripts/materialize.sh` and `.github/workflows/verify.yml`
follow the same route from the public pins.

`ISLAND_SOURCE` records where `lean/island/` comes from. `scripts/materialize.sh --check-island` re-derives it from
that commit and `lean/patches/`.
