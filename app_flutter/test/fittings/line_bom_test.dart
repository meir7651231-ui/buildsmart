// 🔑 Phase D slice 4 — BOM (bill-of-materials) golden + screen smoke. bomRows maps
// an InstallationPlan to product×qty rows (qtyOf per SKU); the gated screen shows
// the shopping list + status. Grounded in buildInstallation's InstallationPlan.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/fittings/intel/line_bom.dart';
import 'package:buildsmart/features/fittings/intel/line_bom_screen.dart';
import 'package:buildsmart/logic/install_engine.dart' show InstallationPlan;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku, String nameHe) => LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: '',
      categoryHe: 'מצמדים PPR',
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

void main() {
  group('bomRows — InstallationPlan → shopping list', () {
    test('🔑 each item becomes a row carrying its per-SKU quantity', () {
      final plan = InstallationPlan(
        [_p('A', 'מצמד PPR 50'), _p('B', 'ברך PPR 90° 50')],
        const [],
        const {'A': 2, 'B': 1},
      );
      final rows = bomRows(plan);
      expect(rows.map((r) => r.sku).toList(), ['A', 'B']);
      expect(rows[0].qty, 2); // reused connector counted twice
      expect(rows[1].qty, 1);
      expect(rows[0].nameHe, 'מצמד PPR 50');
    });

    test('a SKU with no explicit quantity defaults to 1 (qtyOf contract)', () {
      final plan = InstallationPlan([_p('X', 'פקק PPR 32')], const [], const {});
      expect(bomRows(plan).single.qty, 1);
    });

    test('empty plan → empty BOM (no crash)', () {
      const plan = InstallationPlan([], [], {});
      expect(bomRows(plan), isEmpty);
    });
  });

  group('LineBomScreen — the gated capability', () {
    testWidgets('demo screen builds; a row tile per item; status shows total', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LineBomScreen()));
      expect(find.textContaining('סה״כ'), findsOneWidget);
      expect(find.textContaining('×'), findsWidgets); // qty chips
      expect(tester.takeException(), isNull);
    });

    testWidgets('a supplied BOM with gaps/critical shows the warning state', (tester) async {
      const bom = LineBom(
        rows: [BomRow('S1', 'מצמד PPR 50', 1)],
        totalPieces: 1,
        complete: false,
        criticalOpen: 2,
      );
      await tester.pumpWidget(const MaterialApp(home: LineBomScreen(bom: bom)));
      expect(find.textContaining('פערים'), findsOneWidget);
      expect(find.textContaining('בטיחות חסרים'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty BOM shows the empty label, no crash', (tester) async {
      const bom = LineBom(rows: [], totalPieces: 0, complete: true, criticalOpen: 0);
      await tester.pumpWidget(const MaterialApp(home: LineBomScreen(bom: bom)));
      expect(find.text('אין פריטים'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
