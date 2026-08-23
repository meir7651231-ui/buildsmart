// 🔑 Phase D slice 3 — "show in 3D" capability smoke test: a single catalog
// product renders in 3D + its engine spec; a non-fitting shows a fallback and
// never crashes; a hot line surfaces safety in the spec panel.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/fittings/intel/product_3d_screen.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, String categoryHe) => LipskeyCatalogProduct(
      sku: 'V-$nameHe',
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

void main() {
  // A tall surface so the whole (lazy ListView) spec panel lays out & builds.
  Future<void> _tall(WidgetTester t) => t.binding.setSurfaceSize(const Size(900, 1600));

  testWidgets('a fitting product shows the 3D + its engine spec', (tester) async {
    await _tall(tester);
    await tester.pumpWidget(
      MaterialApp(home: Product3dScreen(product: _p('ברך PPR 90° 32', kPprElbows))),
    );
    expect(find.byType(FittingPreview3d), findsOneWidget);
    expect(find.textContaining('שיטות-חיבור'), findsOneWidget);
    expect(find.textContaining('תקנים'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a hot line surfaces cold-line vs hot safety honestly', (tester) async {
    await _tall(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Product3dScreen(product: _p('מצמד PPR 32', kPprCouplers), tempC: 70),
      ),
    );
    expect(find.textContaining('בטיחות קו-חם'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a non-fitting product → fallback, no 3D, no crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Product3dScreen(product: _p('צינור PPR', 'צינורות PPR'))),
    );
    expect(find.byType(FittingPreview3d), findsNothing);
    expect(find.textContaining('אינו פריס-במנוע'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
