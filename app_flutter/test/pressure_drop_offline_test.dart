// Regression: off-line side-branch safety parts (a ¼" Legionella sampling tap,
// an air vent, an expansion tank) must NOT be counted as the line's flow
// bottleneck. Before the fix, a hot recirculation line auto-inserted a ¼"
// sampling port whose 8 mm bore hijacked the calc, reporting a bogus ΔP≈4.8 bar.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Legionella sampling tap is not the flow bottleneck', () {
    final manifold = kLipskeyCatalog.firstWhere(
        (p) =>
            (p.productType == 'מחלק' || p.categoryHe == 'מחלקים') &&
            kVerifiedSpecs.containsKey(p.sku),
        orElse: () =>
            kLipskeyCatalog.firstWhere((p) => kVerifiedSpecs.containsKey(p.sku)));
    final nipple = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');

    final plan = buildInstallation([manifold, nipple],
        tempC: 60,
        loop: true,
        autoCompliance: true,
        accessories: const {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'});

    // Sanity: the recirc line really did insert the off-line sampling tap.
    expect(plan.items.any((p) => p.sku == 'HW-SAMPLE'), isTrue,
        reason: 'expected the recirc line to include a Legionella sampling tap');

    final pd = estimatePressureDrop(plan.items,
        pipeLengthMeters: 8, flowRateLPS: 0.4, verticalRiseMeters: 3);

    // The bottleneck must be a real in-line product, never the side tap / vent.
    expect(pd.bottleneck?.sku, isNot('HW-SAMPLE'));
    expect(pd.bottleneck?.sku, isNot('HW-AIRVENT'));
    // 8 mm sampling bore must not define the line; min in-line bore ≥ 15 mm.
    expect(pd.minBoreMm, greaterThanOrEqualTo(15));
    // ΔP must be in a sane band — the bogus value was ~4.8 bar.
    expect(pd.dropBar, lessThan(2.0));
  });
}
