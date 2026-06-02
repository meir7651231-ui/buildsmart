import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Benzi #6 — as-you-type autocomplete (`searchSuggestions`). Pure over the
/// catalog, so it's unit-tested here; the chip UI is wired in `_SearchPanel`.
void main() {
  final allCats = kLipskeyCatalog.map((p) => p.categoryHe).toSet();

  group('searchSuggestions (Benzi #6 autocomplete)', () {
    test('empty / whitespace query → no suggestions', () {
      expect(searchSuggestions(''), isEmpty);
      expect(searchSuggestions('   '), isEmpty);
    });

    test('a common term yields real, distinct, capped category labels', () {
      final s = searchSuggestions('אסלה');
      expect(s, isNotEmpty);
      expect(s.length, lessThanOrEqualTo(6));
      expect(s.toSet().length, s.length, reason: 'no duplicate suggestions');
      for (final c in s) {
        expect(allCats, contains(c),
            reason: '"$c" is not a real catalog category');
      }
    });

    test('respects an explicit limit', () {
      expect(searchSuggestions('א', limit: 3).length, lessThanOrEqualTo(3));
    });

    test('never echoes a category the user already typed in full', () {
      // A real, populous category typed verbatim must not suggest itself back.
      const exact = 'מושבי אסלה';
      expect(allCats, contains(exact)); // precondition guard
      expect(searchSuggestions(exact), isNot(contains(exact)));
    });

    test('system scope — every suggestion has an in-system matching product',
        () {
      expect(searchSuggestions('צינור'), isNotEmpty); // anchor (no scope)
      for (final sys in WaterSystem.values) {
        for (final cat in searchSuggestions('צינור', system: sys)) {
          final inSystem = filterBySystem(
              kLipskeyCatalog.where((p) => p.categoryHe == cat).toList(), sys);
          expect(inSystem, isNotEmpty,
              reason: 'suggestion "$cat" has no $sys product');
        }
      }
    });
  });
}
