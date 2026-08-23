// Hebrew morphology rescue — the pure singular-folding + its live effect on the
// dive. Pure cases run on every gate build; the integration self-skips flag-off.
//
//   flutter test --dart-define=GLOBAL_SEARCH=true test/features/global_search/hebrew_morph_test.dart

import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/features/global_search/hebrew_morph.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show diveResultsProvider, keyboardDiveQueryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('hebrewSearchVariants (pure)', () {
    test('folds the productive plural suffixes to the singular', () {
      expect(hebrewSearchVariants('ברזים'), ['ברז']);
      expect(hebrewSearchVariants('צינורות'), ['צינור']);
      expect(hebrewSearchVariants('ניפלים'), ['ניפל']);
      expect(hebrewSearchVariants('מצמדים'), ['מצמד']);
    });

    test('restores the word-final letter after stripping (מ→ם)', () {
      expect(hebrewSearchVariants('אטמים'), ['אטם']);
    });

    test('folds a plural noun anywhere in the phrase, size untouched', () {
      expect(hebrewSearchVariants('ברזים 16'), ['ברז 16']);
      expect(hebrewSearchVariants('16 ברזים'), ['16 ברז']);
    });

    test('nothing productive ⇒ empty (never returns the query itself)', () {
      expect(hebrewSearchVariants('ברז'), isEmpty); // already singular
      expect(hebrewSearchVariants('מים'), isEmpty); // too short to fold
      expect(hebrewSearchVariants(''), isEmpty);
      expect(hebrewSearchVariants('   '), isEmpty);
    });

    test('deterministic', () {
      expect(hebrewSearchVariants('ברזים'), hebrewSearchVariants('ברזים'));
    });
  });

  group('live dive rescue', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a plural query still finds the singular products (ON path)', () {
      if (!kGlobalSearch) return; // flag-off: rescue is compiled out

      final c = ProviderContainer();
      c.read(keyboardDiveQueryProvider.notifier).state = 'ברזים';
      final res = c.read(diveResultsProvider);
      c.dispose();

      expect(res, isNotEmpty,
          reason: 'the plural "ברזים" must be rescued to "ברז"');
      expect(res.any((p) => p.nameHe.contains('ברז')), isTrue,
          reason: 'the rescued results are the singular faucets');
    });
  });
}
