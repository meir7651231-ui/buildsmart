// Regression guard for the lipskey taxonomy category-key fix.
//
// Two category keys were misnamed in the smart-data maps, so
// [lipskeyAccFor] / [lipskeyStagesFor] — which key off a product's real
// [LipskeyCatalogProduct.categoryHe] — fell through to `const []` for ~52
// products (no accessories, no install stages). The keys were:
//   'אטמים אומים ופקקים'        → should be 'אטמים ופקקים'
//   'מחסומים (סיפונים) גלויים'  → should be 'מחסומים גלויים'
//
// These tests pin the corrected keys (resolved through a REAL catalog product
// of each category, so the actual data path is exercised) and assert the old
// misnamed keys can never silently come back.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Fixed category keys + the old misnamed keys they replaced.
  const fixedCategories = ['אטמים ופקקים', 'מחסומים גלויים'];
  const oldMisnamedKeys = ['אטמים אומים ופקקים', 'מחסומים (סיפונים) גלויים'];

  group('lipskey category keys — fixed taxonomy resolves smart data', () {
    for (final categoryHe in fixedCategories) {
      test('"$categoryHe": real product resolves acc + stages (non-empty)', () {
        // Use a real catalog product of this category so we exercise the
        // exact categoryHe string that ships, not a hand-typed literal.
        final product = kLipskeyCatalog.firstWhere(
          (p) => p.categoryHe == categoryHe,
          orElse: () => throw StateError(
              'No catalog product with categoryHe "$categoryHe" — '
              'fixture/category renamed?'),
        );

        final acc = lipskeyAccFor(product.sku, product.categoryHe);
        final stages = lipskeyStagesFor(product.sku, product.categoryHe);

        expect(acc, isNotEmpty,
            reason: 'lipskeyAccFor returned [] for "$categoryHe" — '
                'category key misnamed again?');
        expect(stages, isNotEmpty,
            reason: 'lipskeyStagesFor returned [] for "$categoryHe" — '
                'category key misnamed again?');
      });

      // Also assert via the bare categoryHe string directly (the maps are keyed
      // on categoryHe; SKU '' has no override so it falls through to category).
      test('"$categoryHe": bare-string lookup hits the category maps', () {
        expect(lipskeyAccFor('', categoryHe), isNotEmpty);
        expect(lipskeyStagesFor('', categoryHe), isNotEmpty);
        expect(kLipskeyAccByCategory.containsKey(categoryHe), isTrue);
        expect(kLipskeyStagesByCategory.containsKey(categoryHe), isTrue);
      });
    }
  });

  group('lipskey category keys — old misnamed keys are gone', () {
    for (final stale in oldMisnamedKeys) {
      test('"$stale" is not a map key and resolves to empty', () {
        // Negative guard: the regression can't silently return.
        expect(kLipskeyAccByCategory.containsKey(stale), isFalse,
            reason: 'Old misnamed accessory key "$stale" is back');
        expect(kLipskeyStagesByCategory.containsKey(stale), isFalse,
            reason: 'Old misnamed stage key "$stale" is back');
        // And no product is filed under the stale category either.
        expect(kLipskeyCatalog.any((p) => p.categoryHe == stale), isFalse,
            reason: 'A product still uses the old category "$stale"');
        // The lookup helpers therefore fall through to empty for it.
        expect(lipskeyAccFor('', stale), isEmpty);
        expect(lipskeyStagesFor('', stale), isEmpty);
      });
    }
  });
}
