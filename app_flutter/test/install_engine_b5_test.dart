// B5 engine fixes:
//  E1 — the galvanic dielectric requirement now fires between dissimilar metal
//       GROUPS (copper/brass ↔ steel/stainless), not "copper present + any 2
//       metals". The old predicate required copper specifically (so it missed
//       brass↔steel) and omitted stainless entirely. Tested through the public
//       lineComplianceChecklist 'רקורד דיאלקטרי' (critical) check.
//  E8 — shower spray OUTLETS (head, hand-sprayer) are terminal (endpoint-only);
//       the arm + mixer stay in-line so the real mixer→arm→head chain still builds.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((q) => q.sku == sku);

bool _dielectricRequired(List<LipskeyCatalogProduct> chain) =>
    lineComplianceChecklist(chain, 60, const {})
        .any((c) => c.label == 'רקורד דיאלקטרי');

void main() {
  group('E1 — galvanic dielectric: dissimilar metal GROUPS only', () {
    test('steel ↔ brass fires (old predicate missed it — no copper present)', () {
      expect(_dielectricRequired([_p('HW-BTANK-35'), _p('77777631')]), isTrue);
    });
    test('stainless ↔ brass fires (old predicate omitted stainless)', () {
      expect(_dielectricRequired([_p('HW-FLEX-32'), _p('77777314')]), isTrue);
    });
    test('copper ↔ steel fires', () {
      expect(_dielectricRequired([_p('HW-CU-15'), _p('HW-BTANK-35')]), isTrue);
    });
    test('copper ↔ brass does NOT fire (same group — benign, no over-flag)', () {
      expect(_dielectricRequired([_p('HW-CU-15'), _p('77777631')]), isFalse);
    });
    test('hot line auto-adds the dielectric for the steel expansion tank', () {
      // auto-compliance adds a STEEL expansion tank to the brass line → a
      // galvanic couple → the dielectric union must be auto-added too (the
      // predicate is recomputed over the FINAL items, not the pre-insertion set).
      final plan = buildInstallation([_p('779096G'), _p('77778071')],
          tempC: 60, autoCompliance: true);
      final skus = plan.items.map((p) => p.sku).toSet();
      expect(skus.any((s) => s.startsWith('HW-BTANK')), isTrue); // steel tank added
      expect(skus.any((s) => s.startsWith('HW-DIELECTRIC')), isTrue); // + its union
      expect(plan.criticalOpen(60), 0);
    });
  });

  group('E8 — shower: heads/sprayers terminal, arm/mixer in-line', () {
    test('shower head is a terminal (endpoint-only)', () {
      expect(flowRole(_p('7777708G')), FlowRole.fixture);
    });
    test('hand-sprayer is a terminal', () {
      expect(flowRole(_p('77701204')), FlowRole.fixture);
    });
    test('shower arm stays in-line (so mixer→arm→head still builds)', () {
      expect(flowRole(_p('77701189')), FlowRole.connector);
    });
    test('shower mixer stays in-line', () {
      expect(flowRole(_p('777M2208')), FlowRole.connector);
    });
  });
}
