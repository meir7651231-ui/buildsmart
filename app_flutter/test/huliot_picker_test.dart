// §21 picker regression — the chip picker (בורר) must work for Huliot, not
// just Polyroll. Two bugs (both lesson T4 — kPolyrollCatalog instead of
// kCatalogProducts):
//   1. lipskey_products_screen.dart fed the sibling pool from kPolyrollCatalog
//      (Huliot products absent) → empty siblings.
//   2. findHierarchySiblings gated strictly on the Polyroll brand
//      (brandOf(product) != polyrollBrand → []) → returns [] for any Huliot
//      product before even scanning.
// Result: tapping any chip on a Huliot card opened nothing.
//
// Fix: findHierarchySiblings gates on the PRODUCT'S OWN brand (same-brand
// siblings) and the call-site draws from kCatalogProducts.
import 'package:buildsmart/data/chip_hierarchy.dart';
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper mirroring the screen's _cycleHierarchy sibling query.
  List<LipskeyCatalogProduct> sibsAt(LipskeyCatalogProduct p, int chipIndex) =>
      findHierarchySiblings<LipskeyCatalogProduct>(
        p, chipIndex,
        all: kCatalogProducts,
        nameOf: (q) => q.nameHe,
        brandOf: (q) => q.brand,
      );

  // distinct chip-values offered at chipIndex (what the picker would list)
  Set<String> distinctValues(
      List<LipskeyCatalogProduct> sibs, int chipIndex) {
    final out = <String>{};
    for (final q in sibs) {
      final path = parseChips(q.nameHe).path;
      if (chipIndex < path.length) out.add(path[chipIndex]);
    }
    return out;
  }

  group('§21 Huliot picker (בורר) — same-brand hierarchy siblings', () {
    test('elbow shape chip offers ≥2 angles (45° + 90°)', () {
      final p = kHuliotCatalog.firstWhere((q) => q.sku == '70033460'); // ברך 45° 32
      final sibs = sibsAt(p, 0); // chip[0] = angle (צורה)
      final vals = distinctValues(sibs, 0);
      expect(vals.length, greaterThanOrEqualTo(2),
          reason: 'picker must offer multiple angles, got $vals');
      expect(vals.contains('45°') && vals.contains('90°'), isTrue,
          reason: 'both 45° and 90° elbows exist, got $vals');
    });

    test('elbow size chip offers ≥2 sizes (32/40/50/63)', () {
      final p = kHuliotCatalog.firstWhere((q) => q.sku == '70033460');
      final sibs = sibsAt(p, 1); // chip[1] = size (מידה)
      final vals = distinctValues(sibs, 1);
      expect(vals.length, greaterThanOrEqualTo(2),
          reason: 'picker must offer multiple sizes, got $vals');
    });

    test('siblings are Huliot-only (no cross-brand leak)', () {
      final p = kHuliotCatalog.firstWhere((q) => q.sku == '70033460');
      final sibs = sibsAt(p, 1);
      final brands = sibs.map((q) => q.brand).toSet();
      expect(brands, {'חוליות'},
          reason: 'a Huliot product must list only Huliot siblings, got $brands');
    });

    test('Polyroll picker still works (no regression)', () {
      // pick any Polyroll product with a multi-level path
      final pol = kCatalogProducts.where((q) => q.brand == kPolyrollBrand);
      LipskeyCatalogProduct? target;
      for (final q in pol) {
        if (parseChips(q.nameHe).path.length >= 2) {
          final s = sibsAt(q, parseChips(q.nameHe).path.length - 1);
          if (s.length >= 2) {
            target = q;
            break;
          }
        }
      }
      expect(target, isNotNull,
          reason: 'at least one Polyroll product must still find siblings');
      final brands = sibsAt(target!, 0).map((q) => q.brand).toSet();
      expect(brands, {kPolyrollBrand},
          reason: 'Polyroll product → Polyroll siblings only, got $brands');
    });
  });
}
