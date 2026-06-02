import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Benzi #6 — as-you-type word completion (`searchSuggestions`): completes the
/// last typed word from the vocabulary of catalog PRODUCT-name words.
void main() {
  final allWords = <String>{
    for (final p in kLipskeyCatalog)
      for (final w in p.nameHe.split(RegExp(r'\s+')))
        if (w.isNotEmpty) w,
  };

  group('searchSuggestions (Benzi #6 — product word completion)', () {
    test('empty / too-short / post-space fragment → no suggestions', () {
      expect(searchSuggestions(''), isEmpty);
      expect(searchSuggestions('א'), isEmpty); // 1-char fragment
      expect(searchSuggestions('ברז '), isEmpty); // nothing after the space
    });

    test('completes the typed word from real product words', () {
      final s = searchSuggestions('מחס');
      expect(s, isNotEmpty);
      expect(s.length, lessThanOrEqualTo(6));
      expect(s.toSet().length, s.length, reason: 'distinct');
      for (final sug in s) {
        expect(allWords.contains(sug), isTrue,
            reason: '"$sug" is not a real product word');
        expect(sug.startsWith('מחס'), isTrue,
            reason: '"$sug" should extend the typed fragment');
      }
    });

    test('keeps the already-typed words, completes only the last', () {
      final s = searchSuggestions('ברז כד'); // last word ≥2 chars (כדורי…)
      expect(s, isNotEmpty);
      for (final sug in s) {
        expect(sug.startsWith('ברז '), isTrue,
            reason: '"$sug" should keep the committed prefix');
      }
    });

    test('respects an explicit limit', () {
      expect(searchSuggestions('מח', limit: 3).length, lessThanOrEqualTo(3));
    });

    test('system scope — each suggestion word is in an in-system product', () {
      for (final sys in WaterSystem.values) {
        for (final sug in searchSuggestions('צי', system: sys)) {
          final inSystem = filterBySystem(kLipskeyCatalog, sys)
              .any((p) => p.nameHe.split(RegExp(r'\s+')).contains(sug));
          expect(inSystem, isTrue,
              reason: '"$sug" not found in any $sys product');
        }
      }
    });
  });
}
