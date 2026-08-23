// Regression guard: searching the catalog by a Huliot SKU (e.g. 64032300)
// returned NO results because the catalog RESULTS search (matchProducts)
// iterated kLipskeyCatalog (Lipskey-only) instead of the unified
// kCatalogProducts. catalogProductMatchesQuery already matches the SKU field
// (for queries >=5 chars) — the bug was purely the source list. matchProducts
// now runs over kCatalogProducts. (Autocomplete searchSuggestions stays
// Lipskey-scoped by design — see CONVENTIONS "Catalog reads".)
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(registerPolyrollSpecs);

  test('a Huliot SKU is matchable in the unified catalog (not Lipskey-only)', () {
    const sku = '64032300'; // צינור חלק 32 אורך 3000 (Huliot SmartLock)
    expect(kHuliotCatalog.any((p) => p.sku == sku), isTrue,
        reason: 'precondition: the SKU exists in the Huliot catalog');

    // The unified catalog (the results-search source) matches it by SKU...
    final unified =
        kCatalogProducts.where((p) => catalogProductMatchesQuery(p, sku)).toList();
    expect(unified.any((p) => p.sku == sku), isTrue,
        reason: 'unified-catalog search must find the Huliot SKU');

    // ...while Lipskey-only (the old, buggy source) does NOT — exactly why search
    // came up empty before the fix. If matchProducts is reverted to
    // kLipskeyCatalog, the Huliot SKU stops resolving.
    final lipskeyOnly =
        kLipskeyCatalog.where((p) => catalogProductMatchesQuery(p, sku)).toList();
    expect(lipskeyOnly, isEmpty,
        reason: 'Huliot SKU absent from kLipskeyCatalog; results search MUST use kCatalogProducts');
  });

  test('a Huliot cart line resolves via the unified catalog (not fallback)', () {
    // Huliot/PPR products get 'lip:<sku>' cart keys too, so cartLineDisplay must
    // resolve them via kCatalogProducts. On a miss it falls back to
    // line.productName — so a sentinel name proves resolution.
    const line = SmartCartLine(
      productKey: 'lip:64032300',
      productName: 'FALLBACK_SENTINEL',
      productEmoji: '🔧',
      brandName: '',
      brandPrice: 0,
      productQty: 1,
      accessories: [],
    );
    expect(cartLineDisplay(line).name, isNot('FALLBACK_SENTINEL'),
        reason: 'a Huliot cart line must resolve via kCatalogProducts');
  });
}
