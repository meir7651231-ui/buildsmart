// Plumber-slang rescue — the pure expansion + its live effect on the dive. Pure
// cases run on every gate build; the integration self-skips flag-off.
//
//   flutter test --dart-define=GLOBAL_SEARCH=true test/features/global_search/plumber_slang_test.dart

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/features/global_search/plumber_slang.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, diveResultsProvider, keyboardDiveQueryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('slangVariants (pure)', () {
    test('a slang word expands to its real catalog word(s)', () {
      expect(slangVariants('אלבו'), ['ברך', 'זווית']);
      expect(slangVariants('בול'), ['ברז כדורי']);
      expect(slangVariants('פטמה'), ['ניפל']);
    });

    test('owner field-slang folds to the real catalog word', () {
      expect(slangVariants('תוכי'), ['חותך']); // parrot = pipe cutter
      expect(slangVariants('חנוכייה'), ['מחלק', 'מסעף']); // menorah = manifold
      expect(slangVariants('פרלטור'), ['פיה', 'מעדן']); // aerator
      expect(slangVariants('אוכף'), ['רוכב']); // saddle
      expect(slangVariants('מנומטר'), ['שעון']); // manometer
      expect(slangVariants('דריין'), ['ניקוז']); // drain
      expect(slangVariants('שיבר'), ['ברז']); // Schieber
      expect(slangVariants('קלנבו'), ['זווית', 'ברך']); // old elbow distortion
      expect(slangVariants('אורינג'), ['אטם', 'טבעת']); // O-ring
      expect(slangVariants('מנהול'), ['תא']); // manhole
      expect(slangVariants('לוחץ'), ['ונטיל']); // sink drain outlet
      expect(slangVariants('ווסת'), ['מקטין']); // pressure regulator
      expect(slangVariants('פטרייה'), ['כובע']); // roof vent cap
      expect(slangVariants('קולקטור'), ['מסעף', 'מחלק', 'סעפת']); // manifold
    });

    test('Latin loan-words match case-insensitively, size preserved', () {
      expect(slangVariants('valve'), ['ברז', 'שסתום']);
      expect(slangVariants('VALVE'), ['ברז', 'שסתום']);
      expect(slangVariants('אלבו 1/2'), ['ברך 1/2', 'זווית 1/2']);
    });

    test('owner glossary aliases (slang + English) fold to the catalog word', () {
      expect(slangVariants('toilet'), ['אסלה']);
      expect(slangVariants('trap'), ['סיפון', 'מחסום']);
      expect(slangVariants('pipe'), ['צינור']);
      expect(slangVariants('טאפה'), ['פקק']);
      expect(slangVariants('פולירול'), ['PPR']);
    });

    test('inch-size phrases swap to the catalog notation', () {
      expect(slangVariants('חצי צול'), contains('1/2'));
      expect(slangVariants('ברז חצי צול'), contains('ברז 1/2'));
      expect(slangVariants('צול וחצי'), containsAll(['1 1/2', 'DN40']));
      expect(slangVariants('4 צול'), contains('DN110'));
    });

    test('a real catalog word is not slang ⇒ empty', () {
      expect(slangVariants('ברז'), isEmpty);
      expect(slangVariants(''), isEmpty);
    });

    test('every canonical target really exists in the catalog (אין המצאות)', () {
      void checkTargets(Map<String, List<String>> m) {
        m.forEach((slang, canons) {
          for (final c in canons) {
            final hits =
                kCatalogProducts.where((p) => catalogProductMatchesQuery(p, c));
            expect(hits, isNotEmpty,
                reason: 'slang "$slang" → "$c" must match real products');
          }
        });
      }

      checkTargets(kPlumberSlang);
      checkTargets(kPlumberSlangPhrases);
    });
  });

  group('live dive rescue', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a slang query finds the real products (ON path)', () {
      if (!kGlobalSearch) return; // flag-off: rescue is compiled out

      List res(String q) {
        final c = ProviderContainer();
        c.read(keyboardDiveQueryProvider.notifier).state = q;
        final r = c.read(diveResultsProvider);
        c.dispose();
        return r;
      }

      final elbow = res('אלבו');
      expect(elbow, isNotEmpty, reason: '"אלבו" must be rescued to elbows');
      expect(
          elbow.any((p) =>
              '${p.nameHe}'.contains('ברך') || '${p.nameHe}'.contains('זווית')),
          isTrue);

      final valve = res('valve');
      expect(valve, isNotEmpty, reason: 'the loan-word "valve" must find taps');
      expect(valve.any((p) => '${p.nameHe}'.contains('ברז')), isTrue);
    });
  });
}
