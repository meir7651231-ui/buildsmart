// Roadmap step 56 (frequentlyPairedTypesFor) + step 29 (connectionWarningHe).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('frequentlyPairedTypesFor', () {
    test('at most 4, de-duplicated, and every type is a real connectable type',
        () {
      var withResults = 0;
      for (final p in kLipskeyCatalog) {
        final types = frequentlyPairedTypesFor(p);
        expect(types.length, lessThanOrEqualTo(4), reason: p.sku);
        expect(types.toSet().length, types.length, reason: p.sku);
        if (types.isNotEmpty) {
          withResults++;
          final realTypes =
              compatibleProductsFor(p).map((c) => c.productType).toSet();
          for (final t in types) {
            expect(realTypes, contains(t), reason: '${p.sku} → $t');
          }
        }
      }
      expect(withResults, greaterThan(0));
    });

    test('ordered by frequency (non-increasing counts)', () {
      for (final p in kLipskeyCatalog) {
        final types = frequentlyPairedTypesFor(p);
        if (types.length < 2) continue;
        final counts = <String, int>{};
        for (final c in compatibleProductsFor(p)) {
          final t = c.productType;
          if (t != null && t.isNotEmpty) counts[t] = (counts[t] ?? 0) + 1;
        }
        for (var i = 1; i < types.length; i++) {
          expect(counts[types[i - 1]]!,
              greaterThanOrEqualTo(counts[types[i]]!), reason: p.sku);
        }
      }
    });
  });

  group('connectionWarningHe', () {
    test('null when there is no spec; null when the product has mates', () {
      for (final p in kLipskeyCatalog) {
        if (kVerifiedSpecs[p.sku] == null) {
          expect(connectionWarningHe(p), isNull, reason: p.sku);
        } else if (compatibleProductsCount(p) > 0) {
          expect(connectionWarningHe(p), isNull, reason: p.sku);
        } else {
          expect(connectionWarningHe(p), contains('מתאם'), reason: p.sku);
        }
      }
    });
  });

  // Roadmap step 29 — per-pair impossible-connection validation (closes 🟦).
  group('pairConnectionWarningHe', () {
    test('reflexive (a, a) returns null — same product is no warning', () {
      for (final p in kLipskeyCatalog.take(20)) {
        expect(pairConnectionWarningHe(p, p), isNull, reason: p.sku);
      }
    });

    test('null when either side lacks a spec (cannot judge)', () {
      final specked =
          kLipskeyCatalog.firstWhere((p) => kVerifiedSpecs[p.sku] != null);
      final unspecked = kLipskeyCatalog
          .firstWhere((p) => kVerifiedSpecs[p.sku] == null, orElse: () => specked);
      if (identical(specked, unspecked)) return; // no unspec'd product exists
      expect(pairConnectionWarningHe(specked, unspecked), isNull);
      expect(pairConnectionWarningHe(unspecked, specked), isNull);
    });

    test(
        'null when the pair really mates — sampled from compatibleProductsFor',
        () {
      var checked = 0;
      for (final a in kLipskeyCatalog.take(80)) {
        if (kVerifiedSpecs[a.sku] == null) continue;
        for (final b in compatibleProductsFor(a).take(2)) {
          expect(pairConnectionWarningHe(a, b), isNull,
              reason: '${a.sku} + ${b.sku} should mate');
          checked++;
        }
      }
      expect(checked, greaterThan(0));
    });

    test(
        'returns a Hebrew warning naming an adapter when two spec\'d products '
        'do NOT mate', () {
      // Build a pair that's intentionally bad: a brass thread fitting + a PVC
      // drainage fitting. They have specs but no joint.
      LipskeyCatalogProduct? brassThread;
      LipskeyCatalogProduct? pvcDrain;
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s == null) continue;
        if (s.material == 'פליז' && brassThread == null) brassThread = p;
        if (s.material == 'PVC' && pvcDrain == null) pvcDrain = p;
        if (brassThread != null && pvcDrain != null) break;
      }
      if (brassThread == null || pvcDrain == null) return; // data shape
      // Only assert when the pair really doesn't mate (data may have an
      // unexpected bridge). The point of the test is: when there's NO mate,
      // the helper returns a non-null warning mentioning "מתאם".
      final mates = compatibleProductsFor(brassThread)
          .map((p) => p.sku)
          .contains(pvcDrain.sku);
      if (!mates) {
        final w = pairConnectionWarningHe(brassThread, pvcDrain);
        expect(w, isNotNull);
        expect(w, contains('מתאם'));
      }
    });

    test('symmetric — pair(a,b) and pair(b,a) report consistently', () {
      for (final a in kLipskeyCatalog.take(30)) {
        if (kVerifiedSpecs[a.sku] == null) continue;
        for (final b in kLipskeyCatalog.skip(50).take(30)) {
          if (kVerifiedSpecs[b.sku] == null) continue;
          final ab = pairConnectionWarningHe(a, b);
          final ba = pairConnectionWarningHe(b, a);
          expect(ab == null, ba == null,
              reason: '${a.sku} vs ${b.sku} asymmetric');
        }
      }
    });
  });
}
