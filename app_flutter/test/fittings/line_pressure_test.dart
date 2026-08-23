// 🔑 Phase E-lite slice 1 — pressure-drop bridge golden + smoke. pressureDropForPlan
// delegates to the live estimatePressureDrop over the plan's products (advisory
// engineering estimate, not a binding safety value).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/features/fittings/intel/line_pressure.dart';
import 'package:buildsmart/features/fittings/intel/line_pressure_screen.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// productType is derived from nameHe (a getter over kLipskeyTypes), so the names
// carry the type ('ברך', 'מצמד', …) — no constructor param.
LipskeyCatalogProduct _p(String sku, String nameHe) => LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: '',
      categoryHe: 'אביזרי קצה HDPE',
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

FittingLinePlan _plan(List<LipskeyCatalogProduct> products) =>
    FittingLinePlan(products: products, route: const [], complete: true);

void main() {
  test('🔑 pressureDropForPlan delegates to estimatePressureDrop on the plan products', () {
    final products = [
      _p('A', 'ברך 90° 32'),
      _p('B', 'מצמד 32'),
    ];
    final plan = _plan(products);
    final viaBridge = pressureDropForPlan(plan);
    final direct = estimatePressureDrop(products);
    expect(viaBridge.dropBar, direct.dropBar);
    expect(viaBridge.totalK, direct.totalK);
  });

  test('flow/length params pass through to the estimator', () {
    final products = [_p('A', 'ברך 90° 32')];
    final plan = _plan(products);
    final a = pressureDropForPlan(plan, flowRateLPS: 0.15);
    final b = pressureDropForPlan(plan, flowRateLPS: 0.9); // higher flow ⇒ higher ΔP
    expect(b.dropBar, greaterThan(a.dropBar));
  });

  test('an empty plan estimates without crashing (finite ΔP)', () {
    final r = pressureDropForPlan(_plan(const []));
    expect(r.dropBar.isFinite, isTrue);
  });

  testWidgets('the pressure screen builds: ΔP + suggestions, no exception', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    final plan = _plan([_p('A', 'ברך 90° 32')]);
    await tester.pumpWidget(MaterialApp(home: LinePressureScreen(plan: plan)));
    expect(find.textContaining('bar'), findsOneWidget);
    expect(find.textContaining('הצעות'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
