# Licensing

- **Lean sources, scripts and data** (`lean/`, `scripts/`, `.github/`, `challenge/`, `provenance/`, `certificates/`): [Apache License
  2.0](LICENSE). The seven `lean/island/*.lean` modules come from
  [qrh-debruijn-newman](https://github.com/DrMurphyIsIn/qrh-debruijn-newman), which is Apache-2.0
  (`provenance/ISLAND_SOURCE`); two of them carry the one-line repairs in `lean/patches/`. The version-2 layer
  `lean/v2/` (`DQ1_P5.lean`) is Apache-2.0 like the rest of the Lean sources. `certificates/` (the Python certifiers and
  drivers of version 2, and their ledgers, logs and outputs) is Apache-2.0 like `scripts/`; the ledgers are data, reproduced
  as run. The version-2 additions to `provenance/` (the two memo extracts, `P5_SUPERSEDED.md` and the auditor's reviews) are
  records, reproduced as records, under the same licence as the rest of `provenance/`.
- **The paper and the prose documents** (`paper/`, `README.md`, `NOTICE.md`, `LICENSING.md` and the README files in
  subdirectories): [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
- **`logs/`:** verification records, reproduced as records. The scripts among them (`*.sh`, `*.py`) are Apache-2.0
  like the rest of the code.
- **OpenAI's theorem.** The proof that every Dirichlet L-function is nonzero on Re s > 7/8 is OpenAI's, from
  <https://github.com/openai/math> at commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`, licensed under Apache-2.0.
  No OpenAI file is vendored here; `scripts/materialize.sh` checks out their `lean/` directory unmodified and builds
  this repository's files inside it.
- **Lean 4 and Mathlib** are Apache-2.0 and are fetched at build time; nothing of them is vendored.
