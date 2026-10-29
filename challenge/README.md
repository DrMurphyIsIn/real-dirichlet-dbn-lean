# Comparator challenge (in preparation)

This directory will hold the statement-identity challenge for `bb_real_primitive_meaning_oai`, the file a
sandboxed [Comparator](https://github.com/leanprover/comparator) run checks the proof against:

- `Challenge.lean`: the statement of the conjunction, verbatim, with `:= sorry`;
- `ChallengeDefs.lean`: the minimal definitions the statement needs (`DBN.Gen.Hchi`, `DBN.Gen.parityK` and what
  they unfold to outside Mathlib), copied from the reviewed sources and pinned by md5. This file is part of the
  trusted base;
- `config.json`: challenge and solution modules, theorem names, permitted axioms
  `[propext, Quot.sound, Classical.choice]`, nanoda enabled;
- two tampered challenges (9/32 → 1/4 in the zero statement, 1/8 → 1/4 in the bridge), each of which must be
  rejected.

The challenge is being written by bb, the independent auditor who verified the chain, not by the authors of the
proof. It is deliberately empty here until bb has finished it and the sandboxed run has been checked; see
`logs/comparator_sandboxed/`.
