# Sandboxed Comparator run (pending)

PLACEHOLDER. No sandboxed Comparator run of this theorem has been completed yet, and nothing in this
repository should be read as claiming one.

When it is done, this directory will hold the FULL logs (not tails) of:

- Comparator (the v4.34.0 tag built for toolchain v4.34.1) run with `--paranoid` inside a bwrap sandbox on Linux,
  against the challenge in `challenge/`, with every checker it supports: Lean's kernel, nanoda, lean4lean (or a
  recorded N/A if it cannot read v4.34.1 exports), con-leche, con-ron and leanchecker-paranoid;
- the two tampered challenges, each of which must be rejected;
- the non-empty-export guard and the exported declaration count;
- the auditor's verification of those logs against the md5s of the challenge and of `lean/MD5SUMS.txt`,

each with its md5 added to `logs/MD5SUMS.txt`. Until then, the evidence is the unsandboxed five-checker replay
on macOS in `logs/five_checker/`.
