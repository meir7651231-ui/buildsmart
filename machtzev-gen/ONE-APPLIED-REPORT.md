# מנוע-האחד שודרג — מה המחולל חיווט לכל מנוע

29/29 מנועים פלטו `<id>-max` · 27/29 ברירת-מחדל ביט-זהה (אפס-אובדן).

| מנוע | מה המחולל שידרג (חיווט) | אפס-אובדן |
|---|---|---|
| screen-decomp.mjs | fix→carve/screen-lift.mjs · verify→police.mjs | ✅ |
| screen-lift.mjs | 🔨 forge-on-miss (ds-forge — אין עוזר במדף) | ✅ |
| widget-dedup.mjs | fix→assemble/shelf-lift.mjs · verify→police.mjs | ✅ |
| dedup-atoms.mjs | fix→assemble/shelf-lift.mjs · verify→deep-purity-scan.mjs | ✅ |
| dedup-cross-dart.mjs | fix→purify-dart-native.mjs · verify→verify-independent.mjs | ✅ |
| shelf-lift.mjs | 🔨 forge-on-miss (ds-forge — אין עוזר במדף) | ✅ |
| data-lift.mjs | fix→assemble/shelf-lift.mjs · verify→deep-purity-scan.mjs | ✅ |
| chisel-all.mjs | fix→box-purify.mjs · verify→verify-independent.mjs | ✅ |
| gen-manifest.mjs | fix→assemble/shelf-lift.mjs · verify→police-selftest.mjs | ✅ |
| gen-screen.mjs | fix→audit/gen-forge-dart.mjs · verify→police.mjs | ✅ |
| synth.mjs | fix→box-purify.mjs · verify→police.mjs | ✅ |
| ds-forge.mjs | 🔨 forge-on-miss (ds-forge — אין עוזר במדף) | ✅ |
| genesis-gen.mjs | fix→audit/gen-forge-dart.mjs · verify→verify-dart-arg0.mjs | ⚠️ |
| board-gen.mjs | fix→assemble/shelf-lift.mjs · verify→deep-purity-scan.mjs | ✅ |
| ds-critic.mjs | fix→ds-forge.mjs · verify→deep-purity-scan.mjs | ✅ |
| pure-lint.mjs | fix→ds-forge.mjs · verify→pure/pure-e2e-proof.gen.mjs | ✅ |
| pure-decompose.mjs | fix→ds-forge.mjs · verify→verify-dart-tests.mjs | ✅ |
| box-audit.mjs | fix→box-purify.mjs · verify→pretool-selftest.mjs | ✅ |
| purity-data.mjs | fix→purity/purify.mjs · verify→deep-purity-scan.mjs | ✅ |
| purify-engine.mjs | 🔨 forge-on-miss (ds-forge — אין עוזר במדף) | ✅ |
| purify-hard.mjs | fix→purity/purify-engine.mjs · verify→police.mjs | ✅ |
| deep-purity-scan.mjs | fix→box-magic-lift.mjs · verify→police-selftest.mjs | ✅ |
| box-coverage.mjs | fix→box-magic-lift.mjs · verify→deep-purity-scan.mjs | ✅ |
| gen-wiring-doc.mjs | fix→audit/gen-forge-dart.mjs · verify→verify-dart-tests.mjs | ✅ |
| reconvert-data.mjs | fix→purify-dart.mjs · verify→deep-purity-scan.mjs | ✅ |
| verify-dart-tests.mjs | fix→purify-dart.mjs · verify→deep-purity-scan.mjs | ✅ |
| verify-dart-arg0.mjs | fix→purify-dart.mjs · verify→deep-purity-scan.mjs | ✅ |
| run.mjs | fix→audit/gen-forge-dart.mjs · verify→generator/skin-golden.mjs | ✅ |
| police.mjs | fix→purify-dart-native.mjs · verify→deep-purity-scan.mjs | ⚠️ |
