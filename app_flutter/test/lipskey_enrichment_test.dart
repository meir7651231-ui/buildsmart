// Pins the R8-verbatim enrichment extracted from the real Lipskey "בית" (home)
// catalog PDF (2026-06-23 swarm). Values read straight off the catalog pages —
// never invented. gate-117-pinned fields (e.g. color) are intentionally NOT
// touched here; this guards the dims/qty the enrichment actually added.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LipskeyCatalogProduct bySku(String sku) =>
      kLipskeyCatalog.firstWhere((p) => p.sku == sku);

  group('Lipskey PDF enrichment (R8 — verbatim from the home catalog)', () {
    test('bottle-trap dims (מידות) were extracted from the spec diagram', () {
      // verbatim from page 9's dimension diagram
      expect(bySku('217861').dims?['מידות'], '190-270 / 140 / 55 / 110-245 / Ø32.0');
      expect(bySku('218553').dims?['מידות'], '270-310 / 100 / 60 / 110-245 / 32');
    });

    test('pallet quantities were extracted (כמות במשטח)', () {
      expect(bySku('217861').qtyPallet, 2250);
      expect(bySku('218553').qtyPallet, 800);
      expect(bySku('116649').qtyPallet, 400);
    });

    test('every enriched quantity is a positive integer (no garbled reads)', () {
      for (final p in kLipskeyCatalog) {
        if (p.qtyPack != null) {
          expect(p.qtyPack! > 0, isTrue, reason: 'qtyPack ${p.sku}');
        }
        if (p.qtyPallet != null) {
          expect(p.qtyPallet! > 0, isTrue, reason: 'qtyPallet ${p.sku}');
        }
      }
    });
  });
}
