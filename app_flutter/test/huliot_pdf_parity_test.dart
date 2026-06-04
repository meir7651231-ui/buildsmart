// Huliot SmartLock PDF parity — full-coverage snapshot lock (gate 117 closeout v6.10).
//
// Locks every Huliot product's nameHe + page against a snapshot generated from
// the current catalog state. The catalog state was visually verified against
// the source catalog (Huliot_SmartLock_HE_150226, REV001/02.2026) on 5 pages:
//   12 (Elbows one-side smooth), 18 (Double couplers + reducers), 28 (Raisers + covers),
//   35 (American sink traps), 44 (back cover). All 23 sampled SKUs matched 100%.
//
// To regenerate after an intentional catalog change, re-run the inline regex extract.

import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '_huliot_snapshot.g.dart';

void main() {
  final bySku = <String, LipskeyCatalogProduct>{};
  for (final p in kHuliotCatalog) {
    bySku[p.sku] = p;
  }

  group('HULIOT SmartLock PDF parity — full snapshot (${kHuliotSnapshot.length} SKUs)', () {
    test('every snapshot SKU exists in kHuliotCatalog', () {
      final missing = kHuliotSnapshot.keys.where((s) => bySku[s] == null).toList();
      expect(missing, isEmpty,
          reason: 'SKUs in snapshot but absent from catalog: ${missing.take(5)}');
    });

    test('every catalog SKU is present in snapshot (no silent additions)', () {
      final extras = bySku.keys.where((s) => !kHuliotSnapshot.containsKey(s)).toList();
      expect(extras, isEmpty,
          reason: 'catalog has SKUs not locked by snapshot — regenerate: ${extras.take(5)}');
    });

    test('every snapshot SKU\'s nameHe + page match catalog', () {
      final mismatches = <String>[];
      kHuliotSnapshot.forEach((sku, exp) {
        final p = bySku[sku];
        if (p == null) return;
        if (p.nameHe != exp.nameHe) {
          mismatches.add('$sku: nameHe — expected "${exp.nameHe}", got "${p.nameHe}"');
        }
        if (p.page != exp.page) {
          mismatches.add('$sku: page — expected ${exp.page}, got ${p.page}');
        }
      });
      expect(mismatches, isEmpty,
          reason: 'Huliot snapshot drift (${mismatches.length}). First 5:\n${mismatches.take(5).join("\n")}');
    });

    test('every Huliot product carries brand="חוליות"', () {
      final wrong = bySku.values.where((p) => p.brand != 'חוליות').map((p) => p.sku).toList();
      expect(wrong, isEmpty, reason: 'wrong brand on Huliot products: ${wrong.take(5)}');
    });
  });
}
