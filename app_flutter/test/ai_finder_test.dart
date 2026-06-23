// Pins the AI finder closed-set design (#ai-finder) + a printed DEMO of the flow.
// matchCategory accepts only a REAL category and drops NONE/invented; the products
// shown are always real catalog rows. Pure — no gateway, no widget pump.
import 'dart:io';

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
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

  // ── HYBRID search (literal-first) — the fix for "ברז→1" and "שחור→נחושת".
  //    `_search` now runs `fuzzySearchProducts(query)` FIRST (a deterministic
  //    name-search that carries color/size/material/type), only falling back to
  //    the AI category-map when it's empty. These pin that the literal engine
  //    resolves the exact queries the single-category map mis-handled.
  group('hybrid literal search (recall + attribute fix)', () {
    test('a COLOR query → on-topic products, NOT a wrong category (שחור≠נחושת)',
        () {
      final black = fuzzySearchProducts('שחור');
      expect(black, isNotEmpty,
          reason: 'black products exist by name (e.g. "צינור שחור")');
      for (final p in black) {
        expect(p.nameHe.contains('שחור'), isTrue,
            reason: 'every hit literally matches the query — grounded');
      }
      // none is a copper accessory — the OLD wrong mapping was שחור→"אביזרי נחושת"
      expect(black.every((p) => p.categoryHe != 'אביזרי נחושת'), isTrue);
    });

    test('a GENERIC word → MANY products, not the lone "ברזים" category', () {
      expect(fuzzySearchProducts('ברז').length, greaterThan(1));
    });

    test('a SIZE query resolves (sizes live in names, not categories)', () {
      expect(fuzzySearchProducts('1"'), isNotEmpty);
    });

    test('the finder screen wires literal-first (references fuzzySearchProducts)',
        () {
      final src =
          File('lib/screens/ai_finder_screen.dart').readAsStringSync();
      expect(src.contains('fuzzySearchProducts'), isTrue,
          reason: 'literal search must run before the AI category-map');
    });
  });
}
