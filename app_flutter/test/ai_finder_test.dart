// Pins the AI finder closed-set design (#ai-finder) + a printed DEMO of the flow.
// matchCategory accepts only a REAL category and drops NONE/invented; the products
// shown are always real catalog rows. Pure — no gateway, no widget pump.
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/screens/ai_finder_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cats = finderCategories();
  final realCat = cats.first;

  test('matchCategory accepts a real category, rejects NONE/invented', () {
    expect(matchCategory(realCat), realCat, reason: 'exact category → matched');
    expect(matchCategory('הקטגוריה: $realCat'), realCat,
        reason: 'a category wrapped in prose is still matched (contained)');
    expect(matchCategory('NONE'), isNull);
    expect(matchCategory('קטגוריה-מומצאת-12345'), isNull,
        reason: 'an invented category is dropped (closed-set guard)');
    expect(matchCategory(''), isNull);
  });

  test('aiFinderPrompt grounds the model in the closed category set', () {
    final p = aiFinderPrompt('ברז למטבח');
    expect(p, contains('ברז למטבח'), reason: 'the request is in the prompt');
    expect(p, contains(realCat), reason: 'every real category is offered');
    expect(p, contains('NONE'), reason: 'the model may decline');
    expect(p, contains('החזר אך ורק'), reason: 'constrained to ONLY a category');
  });

  test('productsInCategory returns only REAL catalog products', () {
    expect(productsInCategory(realCat), isNotEmpty);
    for (final p in productsInCategory(realCat)) {
      expect(p.categoryHe, realCat);
      expect(p.sku, isNotEmpty);
    }
    expect(productsInCategory('קטגוריה-שלא-קיימת'), isEmpty);
  });

  // ── DEMO — simulate "describe → find": a keyword stands in for Claude's
  //    category pick, then we surface the REAL products. Prints the flow when
  //    this test file is run.
  test('DEMO · תאר → מצא (simulated Claude pick → real products)', () {
    const samples = {
      'ברז למטבח חם': 'ברז',
      'חיבור לצינור HDPE': 'HDPE',
      'מחסום רצפה לאמבטיה': 'מחסום',
      'אביזר נחושת להלחמה': 'נחושת',
    };
    // ignore: avoid_print
    print('\n================  DEMO: תאר → מצא  ================');
    for (final e in samples.entries) {
      final cat = cats.firstWhere((c) => c.contains(e.value), orElse: () => '');
      final prods =
          cat.isEmpty ? const <LipskeyCatalogProduct>[] : productsInCategory(cat);
      // ignore: avoid_print
      print('🗣️ "${e.key}"');
      // ignore: avoid_print
      print('   → 📂 ${cat.isEmpty ? '(לא נמצאה קטגוריה)' : cat}  ·  '
          '${prods.length} מוצרים');
      for (final p in prods.take(4)) {
        // ignore: avoid_print
        print('       • ${p.nameHe}');
      }
    }
    // ignore: avoid_print
    print('===================================================\n');
    expect(cats, isNotEmpty);
  });
}
