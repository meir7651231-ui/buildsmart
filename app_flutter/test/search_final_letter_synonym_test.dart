// Two search misses in catalogProductMatchesQuery (live: GLOBAL_SEARCH is on in
// the hosting build, and the matcher runs for every product search):
//
// 1. A singular ending in a word-FINAL letter never found its plural:
//    "סיפון" is not a prefix of "סיפונים" (ן vs נ). Same for אטם→אטמים,
//    מסעף→מסעפים, מחסום→מחסומים, ברך→ברכיים.
// 2. Multi-word synonym phrases ("אסלות וכיורים", "אביזרי אסלה") were compared
//    against ONE word at a time, so they could never match. "שירותים" only
//    reached toilet seats, never the toilets themselves.
import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, {String categoryHe = 'בדיקה'}) =>
    LipskeyCatalogProduct(
      sku: '00000',
      nameHe: nameHe,
      nameEn: 'x',
      categoryHe: categoryHe,
      categoryEn: 'test',
      categoryEmoji: '🔧',
      page: 1,
    );

void main() {
  group('final-letter singular finds the plural', () {
    test('ן / ם / ף / ך all open to the regular form inside the word', () {
      expect(catalogProductMatchesQuery(_p('סיפונים לכיור'), 'סיפון'), isTrue);
      expect(catalogProductMatchesQuery(_p('אטמים גומי'), 'אטם'), isTrue);
      expect(catalogProductMatchesQuery(_p('מסעפים 45'), 'מסעף'), isTrue);
      expect(catalogProductMatchesQuery(_p('ברכיים 90'), 'ברך'), isTrue);
    });

    test('works past a clitic prefix too ("האטמים")', () {
      expect(catalogProductMatchesQuery(_p('ערכת האטמים'), 'אטם'), isTrue);
    });

    test('the literal singular still matches exactly as before', () {
      expect(catalogProductMatchesQuery(_p('סיפון בקבוק'), 'סיפון'), isTrue);
    });

    test('the open stem never stands in for a bare word', () {
      // "סיפונ" is not a word; a product whose word IS the stem must not hit.
      expect(catalogProductMatchesQuery(_p('סיפונ'), 'סיפון'), isFalse);
    });

    test('2-letter tokens are left alone ("גן" does not reach "גנרטור")', () {
      expect(catalogProductMatchesQuery(_p('גנרטור חשמלי'), 'גן'), isFalse);
    });

    test('boundary rule is kept: no mid-word hit through the stem', () {
      expect(catalogProductMatchesQuery(_p('מאטמים'), 'אטם'), isTrue,
          reason: 'מ is a clitic prefix');
      expect(catalogProductMatchesQuery(_p('קאטמים'), 'אטם'), isFalse,
          reason: 'ק is not a clitic — mid-word');
    });
  });

  group('multi-word synonym phrases', () {
    test('"שירותים" reaches a product in "אסלות וכיורים"', () {
      expect(
        catalogProductMatchesQuery(
          _p('אסלה תלויה', categoryHe: 'אסלות וכיורים'),
          'שירותים',
        ),
        isTrue,
      );
    });

    test('"שירותים" reaches "אביזרי אסלה"', () {
      expect(
        catalogProductMatchesQuery(
          _p('ניאגרה סמויה', categoryHe: 'אביזרי אסלה'),
          'שירותים',
        ),
        isTrue,
      );
    });

    test('the phrase must be consecutive words — scattered words do not count',
        () {
      expect(
        catalogProductMatchesQuery(
          _p('אסלות ומשהו וכיורים', categoryHe: 'אחר'),
          'שירותים',
        ),
        isFalse,
      );
    });

    test('the phrase starts on a word boundary', () {
      expect(
        catalogProductMatchesQuery(
          _p('x', categoryHe: 'זאסלות וכיורים'),
          'שירותים',
        ),
        isFalse,
      );
    });

    test('toilet connectors stay OUT of "שירותים" (the reason bare אסלה was '
        'never a synonym)', () {
      expect(
        catalogProductMatchesQuery(
          _p('מחבר אסלה 110', categoryHe: 'מסעפים וחיבורי אסלה'),
          'שירותים',
        ),
        isFalse,
      );
    });
  });

  group('against the real catalog', () {
    test('"סיפון" now also returns the plural-named siphons', () {
      final hits = resolvedCatalogProducts
          .where((p) => catalogProductMatchesQuery(p, 'סיפון'))
          .toList();
      expect(hits.any((p) => p.nameHe.contains('סיפונים') ||
          p.categoryHe.contains('סיפונים')), isTrue);
    });

    test('"שירותים" returns real toilets, and no toilet connectors', () {
      final hits = resolvedCatalogProducts
          .where((p) => catalogProductMatchesQuery(p, 'שירותים'))
          .toList();
      expect(hits.any((p) => p.nameHe.contains('אסלה')), isTrue,
          reason: 'a toilet, not only a seat');
      expect(
        hits.where((p) => p.categoryHe == 'מסעפים וחיבורי אסלה'),
        isEmpty,
      );
    });
  });
}
