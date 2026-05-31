// Backfill direct tests for three card helpers caught by the regression gate
// (step 89): they were used in production but had no dedicated test reference.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('engineeringSpecFor', () {
    test('null when the product has no verified spec', () {
      final p = kLipskeyCatalog.firstWhere((x) => kVerifiedSpecs[x.sku] == null);
      expect(engineeringSpecFor(p), isNull);
    });

    test('material/maxTempC/waterSystem agree with the underlying spec', () {
      for (final p in kLipskeyCatalog.take(40)) {
        final spec = kVerifiedSpecs[p.sku];
        final r = engineeringSpecFor(p);
        if (spec == null) {
          expect(r, isNull);
          continue;
        }
        expect(r, isNotNull, reason: p.sku);
        expect(r!.material, spec.material);
        expect(r.maxTempC, spec.maxTempC);
        // waterSystem is "הזנה" for supply-only, "ניקוז" for drainage-only,
        // "משולב" otherwise.
        final sys = spec.endSystems;
        final expectedWs = sys.length == 1
            ? (sys.first == WaterSystem.supply ? 'הזנה' : 'ניקוז')
            : 'משולב';
        expect(r.waterSystem, expectedWs);
      }
    });
  });

  group('priceFor', () {
    test('returns a positive int for a mapped category; null otherwise', () {
      var withPrice = 0;
      var nullPrice = 0;
      for (final p in kLipskeyCatalog) {
        final v = priceFor(p);
        if (v == null) {
          nullPrice++;
        } else {
          expect(v, greaterThan(0), reason: p.sku);
          withPrice++;
        }
      }
      // Sanity — the price map covers a meaningful fraction of the catalog.
      expect(withPrice, greaterThan(100));
      expect(nullPrice, greaterThanOrEqualTo(0));
    });
  });

  group('catalogProductForSmart', () {
    test(
        'returns catalogProductForBrand(sp.recBrand), or null when the rec brand has no SKU',
        () {
      var checked = 0;
      for (final sp in kSmartProducts) {
        if (sp.brands.isEmpty) continue;
        final viaSmart = catalogProductForSmart(sp);
        final viaBrand = catalogProductForBrand(sp.recBrand);
        expect(viaSmart?.sku, viaBrand?.sku, reason: sp.key);
        checked++;
      }
      expect(checked, greaterThan(0));
    });
  });
}
