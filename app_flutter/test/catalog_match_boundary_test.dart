// Regression: catalogProductMatchesQuery matches whole WORDS (with an optional
// single Hebrew clitic prefix), not arbitrary substrings. This is what stops the
// dive/search from dragging "בידוד" (insulation) into a "דוד" (water-heater)
// query — the substring false-positive the old `hay.contains` produced — while
// keeping the forgiving prefix/plural hits a non-technical search needs.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, {String? color}) => LipskeyCatalogProduct(
      sku: '00000',
      nameHe: nameHe,
      nameEn: 'x',
      color: color,
      categoryHe: 'בדיקה',
      categoryEn: 'test',
      categoryEmoji: '🔧',
      page: 1,
    );

void main() {
  group('boundary-aware token match', () {
    test('"דוד" matches a דוד word but NOT the substring inside "בידוד"', () {
      expect(catalogProductMatchesQuery(_p('דוד שמש 150 ליטר'), 'דוד'), isTrue);
      expect(catalogProductMatchesQuery(_p('בידוד צנרת תרמי'), 'דוד'), isFalse,
          reason: 'דוד is mid-word in בידוד — must not match');
    });

    test('a single Hebrew clitic prefix still lets the word through', () {
      expect(catalogProductMatchesQuery(_p('הדוד החשמלי'), 'דוד'), isTrue,
          reason: 'ה prefix');
      expect(catalogProductMatchesQuery(_p('מברגה חשמלית'), 'ברג'), isTrue,
          reason: 'מ prefix + ברג');
    });

    test('prefix/plural hits are kept ("ברז" → "ברזים")', () {
      expect(catalogProductMatchesQuery(_p('ברזים כדוריים'), 'ברז'), isTrue);
      expect(catalogProductMatchesQuery(_p('ברז כדורי 1/2"'), 'ברז'), isTrue);
    });

    test('numeric / size tokens (1/2") are whole words and still match', () {
      expect(catalogProductMatchesQuery(_p('צינור 1/2" כחול'), '1/2"'), isTrue);
      expect(catalogProductMatchesQuery(_p('מחבר 20 מ"מ'), '20'), isTrue);
    });

    test('multi-word query is order-independent, each word boundary-matched', () {
      expect(
          catalogProductMatchesQuery(_p('ברז כדורי שחור'), 'שחור ברז'), isTrue);
      expect(catalogProductMatchesQuery(_p('ברז כדורי שחור'), 'ברז בידוד'),
          isFalse,
          reason: 'בידוד is not present as a word');
    });

    test('colour field participates in the boundary match', () {
      expect(catalogProductMatchesQuery(_p('ברז כדורי', color: 'כרום'), 'כרום'),
          isTrue);
    });
  });
}
