# The auditor's checks at the other pin (records, not build targets)

Before the chain was compiled in OpenAI's environment, the auditor bb built and checked each stage separately at
a second pin, Lean v4.35.0-rc3 with Mathlib `0493595e`. These are the check and tamper files of that audit,
byte for byte, and their outputs are in `logs/rc3_audit/`. They are kept because they are the record of what was
checked at each stage, not because they build here: `scripts/materialize.sh` does not copy them into the
workspace, and `BbGenCheck.lean` imports two dbn island modules (`DBNM1Parametric`, `DBNHeatApprox`) that are not
part of this chain and are not vendored.

| File | Stage | What it checks |
|---|---|---|
| BbGenCheck.lean, BbGenAx.lean | D1, D2a | the generic library re-derives the island's de Bruijn theorem verbatim; axioms of 15 declarations |
| BbD2bCheck.lean, BbD2bTamper.lean | D2b | the Mellin bridge `DBN.Gen.bridge`; 1/8 replaced by 1/4 is rejected |
| BbD2bpCheck.lean, BbD2bpTamper.lean | D2b′ | theta functional equation ⇒ evenness; the χ₋₄ instance; rootNumber χ₋₄ = −1 rejected |
| BbD2cCheck.lean, BbD2cTamper.lean | D2c | the zero strip and the 9/32 statement in hypothesis form; heat time 1/4 control |
| BbGaussCheck.lean, BbGaussTamper.lean | S1, S2 | the quadratic Gauss sum and the prime-conductor sign; (1+i) → (1−i) and = −1 rejected |
| BbGauss3Check.lean, BbGauss3Tamper.lean | S3 | Gauss's sign theorem for every real primitive χ; = −1 rejected; hprim load-bearing |
| BbGaussBridgeCheck.lean, BbGaussBridgeTamper.lean | meaning link | `Hchi_bridge` for general χ; 1/8 → 1/4 and k → 1−k rejected |
