// Roadmap step 28 (lineFitFor) + step 73 (connectionNeedsHe).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lineFitFor', () {
    test('empty line → zero connects', () {
      final p = kLipskeyCatalog.firstWhere((x) => kVerifiedSpecs[x.sku] != null);
      final r = lineFitFor(p, const []);
      expect(r.connects, 0);
      expect(r.names, isEmpty);
    });

    test('counts a known compatible product in the line and ignores a foreign one',
        () {
      // Pick a product that has at least one compatible partner.
      LipskeyCatalogProduct? base;
      LipskeyCatalogProduct? partner;
      for (final p in kLipskeyCatalog) {
        final c = compatibleProductsFor(p);
        if (c.isNotEmpty) {
          base = p;
          partner = c.first;
          break;
        }
      }
      expect(base, isNotNull);
      // A product guaranteed NOT compatible: pick one not in the compat set.
      final compatSkus =
          compatibleProductsFor(base!).map((e) => e.sku).toSet();
      final foreign = kLipskeyCatalog.firstWhere(
          (x) => x.sku != base!.sku && !compatSkus.contains(x.sku));

      final r = lineFitFor(base, [partner!, foreign]);
      expect(r.connects, 1, reason: 'only the partner connects');
      expect(r.names, contains(partner.nameHe));
      expect(r.names, isNot(contains(foreign.nameHe)));
    });

    test('the product itself in the line is not counted', () {
      final p = kLipskeyCatalog.firstWhere((x) => compatibleProductsFor(x).isNotEmpty);
      final r = lineFitFor(p, [p]);
      expect(r.connects, 0);
    });
  });

  group('connectionNeedsHe', () {
    test('threaded products ask for the opposite gender thread', () {
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null && s.ends.any((e) => e.type == EndType.bspMale)) {
          expect(connectionNeedsHe(p).any((n) => n.contains('הברגה נקבה')),
              isTrue, reason: p.sku);
          break;
        }
      }
    });

    test('needs are de-duplicated; empty without a spec', () {
      for (final p in kLipskeyCatalog) {
        final needs = connectionNeedsHe(p);
        expect(needs.toSet().length, needs.length, reason: p.sku);
        if (kVerifiedSpecs[p.sku] == null) expect(needs, isEmpty);
      }
    });
  });
}
