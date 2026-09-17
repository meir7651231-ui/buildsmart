# מנוע-האחד משפר את מנועי-עצמו — דוח שדרוג מנוע-מנוע

29/29 מנועי-`one.mjs` קיבלו תכנית-שדרוג (עוזרים נמצאו באימפריה, 1188 מנועים).

| מנוע ב-one.mjs | תפקיד | #עוזרים | פער | fix→ | verify→ |
|---|---|---|---|---|---|
| screen-decomp.mjs | transform | 74 | detect,fix,verify,aggregate,act | screen-lift | police |
| screen-lift.mjs | fix | 91 | detect,verify,aggregate,act | — | supporterAggregates |
| widget-dedup.mjs | transform | 65 | detect,fix,verify,aggregate,act | shelf-lift | police |
| dedup-atoms.mjs | transform | 60 | detect,fix,aggregate,act | shelf-lift | — |
| dedup-cross-dart.mjs | transform | 117 | guard,detect,fix,verify,aggregate,act | purify-dart-native | verify-independent |
| shelf-lift.mjs | fix | 62 | detect,verify,aggregate,act | — | skinGolden |
| data-lift.mjs | detect | 107 | fix,aggregate,act | shelf-lift | — |
| chisel-all.mjs | transform | 90 | detect,fix,verify,aggregate,act | box-purify | verify-independent |
| gen-manifest.mjs | transform | 78 | detect,fix,verify,aggregate,act | shelf-lift | police-selftest |
| gen-screen.mjs | transform | 66 | detect,fix,verify,act | gen-forge-dart | police |
| synth.mjs | transform | 126 | guard,detect,fix,verify,aggregate,act | box-purify | police |
| ds-forge.mjs | fix | 114 | detect,verify,aggregate,act | — | skinGolden |
| genesis-gen.mjs | transform | 87 | detect,fix,verify,aggregate,act | gen-forge-dart | verify-dart-arg0 |
| board-gen.mjs | transform | 68 | detect,fix,aggregate,act | shelf-lift | — |
| ds-critic.mjs | detect | 49 | fix,aggregate,act | ds-forge | — |
| pure-lint.mjs | detect | 43 | fix,verify,act | ds-forge | pure-e2e-proof.gen |
| pure-decompose.mjs | transform | 121 | guard,detect,fix,verify,aggregate,act | ds-forge | verify-dart-tests |
| box-audit.mjs | detect | 78 | fix,verify,aggregate,act | box-purify | pretool-selftest |
| purity-data.mjs | detect | 54 | guard,fix,aggregate,act | purify | — |
| purify-engine.mjs | fix | 100 | guard,detect,verify,aggregate,act | — | verify-dart-tests |
| purify-hard.mjs | transform | 127 | guard,detect,fix,socket,verify,aggregate,act | purify-engine | police |
| deep-purity-scan.mjs | detect | 196 | guard,fix,verify,aggregate,act | box-magic-lift | police-selftest |
| box-coverage.mjs | transform | 74 | detect,fix,aggregate,act | box-magic-lift | — |
| gen-wiring-doc.mjs | transform | 102 | detect,fix,verify,aggregate,act | gen-forge-dart | verify-dart-tests |
| reconvert-data.mjs | detect | 66 | guard,fix,act | purify-dart | — |
| verify-dart-tests.mjs | verify | 74 | guard,detect,fix,aggregate,act | purify-dart | — |
| verify-dart-arg0.mjs | verify | 39 | detect,fix,act | purify-dart | — |
| run.mjs | transform | 72 | detect,fix,verify,aggregate,act | gen-forge-dart | skinGolden |
| police.mjs | verify | 100 | detect,fix,aggregate,act | purify-dart-native | — |

**מדד-מקסימום (בריאים): 29/29** — מנוע בריא = עוזר-fix/verify בדומיין-אמת.
