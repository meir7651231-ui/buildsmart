// gapAdviceHe gives actionable advice when the engine can't bridge two anchors.
// The key correctness point: a supply↔drainage gap must NOT tell the user to
// hunt for an adapter (none exists — they meet only at a fixture), while a
// same-system mismatch should name the two unmet ends.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LipskeyCatalogProduct firstWhereSystem(WaterSystem only) {
    return kLipskeyCatalog.firstWhere((p) {
      final s = kVerifiedSpecs[p.sku];
      return s != null &&
          s.endSystems.length == 1 &&
          s.endSystems.contains(only);
    });
  }

  test('cross-system gap (supply↔drainage) advises a fixture, not an adapter',
      () {
    final supply = firstWhereSystem(WaterSystem.supply);
    final drain = firstWhereSystem(WaterSystem.drainage);
    final advice = gapAdviceHe(supply, drain);
    expect(advice, contains('קבוע'),
        reason: 'should send the user to a fixture, not an adapter');
    expect(advice.contains('מתאם'), isFalse,
        reason: 'must not suggest a (nonexistent) supply↔drainage adapter');
    // symmetric
    expect(gapAdviceHe(drain, supply), contains('קבוע'));
  });

  test('same-system mismatch names the two unmet ends', () {
    // Two supply products that do NOT directly connect.
    final supplyProducts = kLipskeyCatalog.where((p) {
      final s = kVerifiedSpecs[p.sku];
      return s != null &&
          s.endSystems.length == 1 &&
          s.endSystems.contains(WaterSystem.supply);
    }).toList();
    LipskeyCatalogProduct? a, b;
    outer:
    for (var i = 0; i < supplyProducts.length; i++) {
      for (var j = i + 1; j < supplyProducts.length && j < i + 60; j++) {
        if (connectionJoint(supplyProducts[i], supplyProducts[j]) == null) {
          a = supplyProducts[i];
          b = supplyProducts[j];
          break outer;
        }
      }
    }
    expect(a, isNotNull);
    final advice = gapAdviceHe(a!, b!);
    expect(advice, contains('מתאם'),
        reason: 'same-system mismatch should suggest a transition fitting');
    expect(advice, contains('צד 1'));
    expect(advice, contains('צד 2'));
  });

  test('missing spec falls back to a category-level hint', () {
    final noSpec =
        kLipskeyCatalog.firstWhere((p) => !kVerifiedSpecs.containsKey(p.sku));
    final withSpec =
        kLipskeyCatalog.firstWhere((p) => kVerifiedSpecs.containsKey(p.sku));
    expect(gapAdviceHe(noSpec, withSpec), contains('חפש מתאם'));
  });
}
