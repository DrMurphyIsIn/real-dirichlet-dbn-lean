# Provenance of the build environment

The auditor built and replayed the chain against a local, already built checkout of openai/math's `lean/`
directory at commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`, made on 7 October 2026 for an earlier replay of
OpenAI's own Comparator challenge. Before using it, the auditor compared that checkout with a git clone of
openai/math at the same commit:

- the `OAI/` sources, 121,734 files: identical;
- `lakefile.lean` (`c8078fb2…`), `lake-manifest.json` (`8c3ec864…`), `lean-toolchain` (v4.34.1) and OpenAI's 23
  dependency patches: identical;
- `OAI/NumberTheory/DirichletL/Nonvanishing.lean` (`ea8efdb1…`): identical, and it re-elaborated from source with
  return code 0.

**What was not checked.** The dependency checkouts inside that tree (`.lake/packages/*`: Mathlib and the other
packages OpenAI's lakefile pins and patches) were not hashed. Their Mathlib checkout is at `d13f23b`, as the
manifest requires, but their file contents were not compared with the pinned commits plus patches. The kernel
replays check every proof in the export, whatever its source. But the definitions the statement rests on, for
example Mathlib's `completedLFunction`, are trusted as they stood in that tree. So this is a gap in the local
record, and we state it as one.

**How it will be closed.** The sandboxed Comparator run does not reuse that local tree. It rebuilds OpenAI's
environment independently, on Linux, from the public pins: openai/math `adc7f124`, Lean v4.34.1, Mathlib
`d13f23b`, and OpenAI's lakefile, which fetches and patches the dependencies. It then builds this repository's
chain, at the md5s in `lean/MD5SUMS.txt`, on top. `scripts/materialize.sh` and `.github/workflows/verify.yml`
follow the same route from the public pins.

`ISLAND_SOURCE` records where `lean/island/` comes from. `scripts/materialize.sh --check-island` re-derives it from
that commit and `lean/patches/`.
