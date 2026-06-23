// Pins the R8-verbatim enrichment extracted from official supplier catalog PDFs
// (Lipskey home 2026-06-23 + Qondus/Aquatec 2026-06-23 swarms). Values read
// straight off the catalog pages — never invented. gate-117-pinned fields (e.g.
// color on accessories) are intentionally NOT touched; this guards the dims/
// color the enrichment actually added.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LipskeyCatalogProduct bySku(String sku) =>
      kLipskeyCatalog.firstWhere((p) => p.sku == sku);

  group('Lipskey home-catalog PDF enrichment (R8)', () {
    test('bottle-trap dims (מידות) from the spec diagram', () {
      expect(bySku('217861').dims?['מידות'], '190-270 / 140 / 55 / 110-245 / Ø32.0');
      expect(bySku('218553').dims?['מידות'], '270-310 / 100 / 60 / 110-245 / 32');
    });
    test('pallet quantities (כמות במשטח)', () {
      expect(bySku('217861').qtyPallet, 2250);
      expect(bySku('116649').qtyPallet, 400);
    });
  });

  group('Qondus/Aquatec PDF enrichment (R8)', () {
    test('shower-head finish + size were extracted', () {
      // verbatim from the Qondus catalog (page 30)
      expect(bySku('7777708G').color, 'זהב מוברש');
      expect(bySku('7777708G').dims?['מידה'], '250 מ"מ');
    });
    test('bath-accessory set finish was extracted', () {
      expect(bySku('778580').color, 'ניקל');
    });
    test('connector dims/finish from the dense table pages (pass 2)', () {
      // single-line AQUATEC rows — מכסים/ברזי מעבר
      expect(bySku('77003023').dims?['מידה'], '6"');
      expect(bySku('77003023').color, 'ניקל');
      expect(bySku('77777311').dims?['מידה'], '1/2"');
    });
    test('HDPE coupler dims from the page-75 tables (pass 3)', () {
      expect(bySku('9101601610').dims?['מידה'], '16*16');
      expect(bySku('9101601211').dims?['מידה'], '16*1/2"');
    });
  });

  group('Name-parse enrichment (R8 — size/finish printed in the name)', () {
    test('toilet-connector DN from its own name', () {
      expect(bySku('196206').dims?['מידה'], 'DN32');
    });
    test('decorative finish from its own name (category-aware)', () {
      expect(bySku('77701205').color, 'זהב מוברש');
    });
    test('residual inch size in the name (only-תיאור gap)', () {
      expect(bySku('273089').dims?['מידה'], '2"'); // משפך אמריקאי
    });
    test('pure-colour word in the name (never a material)', () {
      expect(bySku('116180').color, 'אפור'); // צינור הכנסה אפור
    });
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
}
