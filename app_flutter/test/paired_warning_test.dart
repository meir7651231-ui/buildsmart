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
}
