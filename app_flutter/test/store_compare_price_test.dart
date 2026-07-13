// C3.3 + C3.5 — real across-catalog comparison + real price-from-inventory (logic).
//
// The ready drop-ins that REPLACE the demo comparison (contractor_seeds) and the
// category price-GUESS (priceFor) — sourced from real `inventory`, proven here. The
// live swap into the product sheet / contractor screen happens at the cutover (when
// real inventory data exists); this pins that the real logic is correct now. Fake
// source — no Firebase.

import 'package:buildsmart/data/repositories/catalog_slice.dart'
    show kC1SliceSkus;
import 'package:buildsmart/data/repositories/store_inventory.dart';
import 'package:buildsmart/data/repositories/store_repo.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements StoreInventorySource {
  @override
  Future<List<Store>> allStores() async => kC1Stores;

  @override
  Future<List<InventoryItem>> inventoryForSku(String sku) async => [
        for (final it in c1Inventory())
          if (it.sku == sku) it,
      ];
}

void main() {
  test('C3.5 — cheapestPrice is the REAL cheapest in-stock price (not a guess)',
      () async {
    final repo = StoreInventoryRepository(_FakeSource());
    // 118220: אחים-כהן 38 (in stock 12) vs מרכז 42 → real cheapest 38.
    expect(await repo.cheapestPrice('118220'), 38);
    // A sku with no offers → no price (null), never a fabricated estimate.
    expect(await repo.cheapestPrice('no-such-sku'), isNull);
  });

  test('C3.5 — cheapestPrice matches the actual inventory row exactly', () async {
    final repo = StoreInventoryRepository(_FakeSource());
    for (final sku in kC1SliceSkus.take(6)) {
      final offers = [
        for (final it in c1Inventory())
          if (it.sku == sku && it.stock > 0) it.price,
      ]..sort();
      final expected = offers.isEmpty ? null : offers.first;
      expect(await repo.cheapestPrice(sku), expected, reason: 'sku $sku');
    }
  });

  test('C3.3 — compareMany gives one comparison per sku, from real inventory',
      () async {
    final repo = StoreInventoryRepository(_FakeSource());
    final skus = kC1SliceSkus.take(4).toList();
    final cmps = await repo.compareMany(skus);

    expect(cmps.map((c) => c.sku).toList(), skus);
    for (final c in cmps) {
      expect(c.availableCount, greaterThanOrEqualTo(1),
          reason: '${c.sku} should be stocked in the slice');
      expect(c.cheapest, isNotNull);
    }
    // The 118220 headline is the owner's demo string.
    final head = await repo.compareMany(['118220']);
    expect(head.single.headline, 'זמין ב-2 · הזול 38₪');
  });
}
