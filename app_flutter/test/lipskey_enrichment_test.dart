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
    test('spray-mode count from the name (Qondus photo-catalog had no table)', () {
      expect(bySku('77701117').dims?['מצבים'], '5'); // מערכת אמבטיה 5 מצבים
      expect(bySku('77701204').dims?['מצבים'], '3'); // מזלף 3 מצבים
    });
    test('structural material from the name (100%-certain, brand-agnostic)', () {
      expect(bySku('77777481').dims?['חומר'], 'נחושת'); // מצוף נחושת
    });
    test('attribute fleet — angle/config/application from the name', () {
      expect(bySku('116207').dims?['זווית'], '45°'); // ברך 45° (gate-117 SKU, new key safe)
      expect(bySku('77775256').dims?['ייעוד'], 'למדיח'); // ברז ניל יציאה למדיח
      expect(bySku('77775255').dims?['תצורה'], 'כפול'); // ברז ניל כפול
    });
    test('audit fix — unit error corrected, garbled dims removed', () {
      expect(bySku('7777707C').dims?['מידה'], '200 מ"מ'); // was ס"מ (contradicted name)
      expect(bySku('9106320031').dims?.containsKey('מידה'), false); // garbled "63*2 90" removed
    });
    test('audit fix v2 — typos corrected, wrong-product images nulled', () {
      expect(bySku('779096F').nameHe.contains('גרפיטי'), false); // typo → גרפיני
      expect(bySku('196587').imageFile, null); // floor-drain still has no real photo
      expect(bySku('186466').imageFile, null); // kit showed a stock drawing
    });
    test('Lipskey home-PDF extraction — cisterns/trap/cap pulled from catalog', () {
      expect(bySku('152785').imageFile, '152785.jpeg'); // Titan cistern, p50
      expect(bySku('178870').imageFile, '178870.jpeg'); // Bareket (shares model photo)
      expect(bySku('116167').imageFile, '116167.jpeg'); // gully trap, p27
      expect(bySku('610918').imageFile, '610918.jpeg'); // round drainage cap, p33
    });
    test('branch twins — same physical product reuses the twin live image', () {
      expect(bySku('118221').imageFile, '116223.jpeg'); // 45° DN40 == 116223 (40/40/40)
      expect(bySku('116589').imageFile, '116689.jpeg'); // 90° 32/32 == 116689
    });
    test('image relink — assets present on R2 but unlinked are now wired', () {
      expect(bySku('997091').imageFile, '997091.jpeg'); // ברך 90° — asset existed, was null
      expect(bySku('273226').imageFile, '273226.jpeg'); // צינור שחור DN40
    });
    test('PDF-extracted images — correct crops pulled from Qondus catalog', () {
      expect(bySku('777M1801').imageFile, '777M1801.jpg'); // bath faucet, was wrong photo
      expect(bySku('77773001').imageFile, '77773001.jpg'); // pressure gauge
      expect(bySku('78071545').imageFile, '78071545.jpg'); // brass float
      expect(bySku('77772412').imageFile, '77772412.jpeg'); // Dior wall spout, p18
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
