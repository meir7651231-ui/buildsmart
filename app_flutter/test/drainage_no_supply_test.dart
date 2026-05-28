// Regression: a gravity DRAINAGE line must never receive supply-side
// compliance (an isolation ball valve, PRV, expansion vessel …). A supply ball
// valve cannot physically connect to a drain trap — the old auto-compliance
// inserted "ברז כדורי 1\"" between two drainage מחסומים, an impossible joint.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

bool _supply(LipskeyCatalogProduct p) =>
    kVerifiedSpecs[p.sku]?.endSystems.contains(WaterSystem.supply) ?? false;

bool _drainOnly(LipskeyCatalogProduct p) {
  final s = kVerifiedSpecs[p.sku];
  return s != null &&
      s.endSystems.length == 1 &&
      s.endSystems.contains(WaterSystem.drainage);
}

void main() {
  test('drainage line gets no supply compliance, no open critical', () {
    final traps = kLipskeyCatalog
        .where((p) =>
            _drainOnly(p) &&
            (p.categoryHe.contains('מחסום') || p.productType == 'סיפון'))
        .toList();
    if (traps.length < 2) return; // no pair to exercise — skip cleanly

    final plan = buildInstallation([traps.first, traps[1]],
        tempC: 20, autoCompliance: true, accessories: {});

    expect(plan.items.where(_supply), isEmpty,
        reason: 'a supply valve must not appear on a drainage line');
    expect(plan.items.any((p) => p.sku == 'HW-BALL-1'), isFalse);
    expect(plan.criticalOpen(20, const {}), 0);
  });

  test('lineIsSupply distinguishes the two systems', () {
    final drain = kLipskeyCatalog.firstWhere(_drainOnly);
    final supply = kLipskeyCatalog.firstWhere(_supply);
    expect(lineIsSupply([drain]), isFalse);
    expect(lineIsSupply([supply]), isTrue);
    expect(lineIsSupply([drain, supply]), isTrue); // a fixture seam is supply-side
  });
}
