// Locks the O(1) `_skuIndex` optimization in `compatibleProductsCount` /
// `compatibleProductsFor` (#2): mates now resolve through the memoised
// unified-catalog SKU→product map instead of an O(catalog) rescan per spec.
// Catalog SKUs are unique (gate 86), so the result is byte-identical to the old
// `kCatalogProducts.where((x) => x.sku == key).first` — these invariants go red
// if the index returns the wrong/empty product.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(registerPolyrollSpecs);

  test('compatibleProductsFor resolves real mates via the unified SKU index', () {
    // PPR DN20 pipe — a well-connected product (also the card_score "rich" anchor).
    final ppr = [...kLipskeyCatalog, ...kPolyrollCatalog]
        .firstWhere((p) => p.sku == '95016002');
    final mates = compatibleProductsFor(ppr);

    expect(mates, isNotEmpty,
        reason: 'a connectable product resolves mates through _skuIndex');
    expect(compatibleProductsCount(ppr), mates.length,
        reason: 'count + list share the predicate → identical cardinality');
    expect(mates.map((p) => p.sku), isNot(contains(ppr.sku)),
        reason: 'a product never mates with itself');
    expect(mates.map((p) => p.sku).toSet(), hasLength(mates.length),
        reason: 'the SKU index yields distinct products (no duplicate sku)');
  });

  test('an endpoint with no verified spec resolves zero mates', () {
    final seat = kLipskeyCatalog.firstWhere((p) => p.sku == '220943');
    expect(compatibleProductsCount(seat), 0);
    expect(compatibleProductsFor(seat), isEmpty);
  });
}
