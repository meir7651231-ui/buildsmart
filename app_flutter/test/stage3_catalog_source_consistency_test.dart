// STAGE-3.1 — list ↔ bridge ↔ search read the SAME catalog source.
//
// The latent bug this pins against: the SKU bridge (related_info._skuIndex)
// and the fuzzy-search default were hardcoded to kCatalogProducts (the v1
// list) while list surfaces read resolvedCatalogProducts (the CATALOG_SOURCE-
// aware getter) — so under CATALOG_SOURCE=v2 the 789 new Huliot products
// appeared in lists but never resolved by SKU (barcode / cart-line reopen /
// BOM) and never surfaced in search. After the stage-3.1 un-pinning all three
// read resolvedCatalogProducts.
//
// Under the define-less test build v1 == kCatalogProducts, so these pass
// today AND become load-bearing the day v2 (or any swapped catalog profile)
// is active: every listed product must resolve through the bridge.

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every product in the ACTIVE catalog resolves through the SKU bridge',
      () {
    final missing = <String>[];
    for (final p in resolvedCatalogProducts) {
      if (catalogProductForSku(p.sku) == null) missing.add(p.sku);
    }
    expect(missing, isEmpty,
        reason: 'listed-but-unresolvable products = the v2 latent bug: '
            'barcode/cart-reopen/BOM die on them');
  });

  test('the bridge resolves to the SAME object the list shows', () {
    // Sample the head/middle/tail — identity, not just equality, since both
    // sides must share one source (no forked copies drifting).
    final list = resolvedCatalogProducts;
    for (final p in [list.first, list[list.length ~/ 2], list.last]) {
      expect(identical(catalogProductForSku(p.sku), p), isTrue,
          reason: 'bridge and list must share one source object');
    }
  });
}
