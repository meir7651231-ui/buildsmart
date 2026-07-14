// C1.8 + C1.9 — multi-store comparison + a server price change (SPEC-catalog-to-server).
//
// C1.8: the product sheet for 118220 reads `inventory` and shows "זמין ב-2 · הזול 38₪"
//       (available in 2 stores, cheapest אחים-כהן at 38₪).
// C1.9: a store changing its price on the server flows straight to the comparison —
//       NO app version / rebuild. (Paired with the C1.6 re-sync-on-updatedAt, the app
//       picks up the new inventory doc and re-renders.)

import 'package:buildsmart/data/repositories/store_inventory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('C1.8 — 118220: זמין ב-2 · הזול 38₪ (cheapest = אחים-כהן)', () {
    final cmp = storeComparison('118220', c1Inventory());

    expect(cmp.availableCount, 2, reason: 'both stores have it in stock');
    expect(cmp.cheapest, isNotNull);
    expect(cmp.cheapest!.price, 38);
    expect(cmp.cheapest!.storeId, 'ahim_cohen');
    expect(cmp.headline, 'זמין ב-2 · הזול 38₪');
  });

  test('C1.9 — a store drops its price on the server → shown with NO app version', () {
    // Baseline: 118220 cheapest is 38₪ (אחים-כהן).
    expect(storeComparison('118220', c1Inventory()).cheapest!.price, 38);

    // אחים-כהן drops 118220 to 34₪ on the server (a fresh updatedAt) — same app build.
    final updated = <InventoryItem>[
      for (final it in c1Inventory())
        if (it.storeId == 'ahim_cohen' && it.sku == '118220')
          InventoryItem(
            storeId: it.storeId,
            sku: it.sku,
            price: 34,
            stock: it.stock,
            updatedAt: '2026-07-13T09:00:00Z',
          )
        else
          it,
    ];

    final cmp = storeComparison('118220', updated);
    expect(cmp.cheapest!.price, 34, reason: 'the new server price, no rebuild');
    expect(cmp.headline, 'זמין ב-2 · הזול 34₪');
  });

  test('out of stock in one store → available count drops, cheapest is the live one',
      () {
    // Zero מרכז's stock for 118220; only אחים-כהן remains available.
    final inv = <InventoryItem>[
      for (final it in c1Inventory())
        if (it.storeId == 'merkaz' && it.sku == '118220')
          InventoryItem(
            storeId: it.storeId,
            sku: it.sku,
            price: it.price,
            stock: 0,
            updatedAt: it.updatedAt,
          )
        else
          it,
    ];

    final cmp = storeComparison('118220', inv);
    expect(cmp.availableCount, 1);
    expect(cmp.cheapest!.storeId, 'ahim_cohen');
    expect(cmp.headline, 'זמין ב-1 · הזול 38₪');
  });

  test('C3.4 — the product-sheet line: stores · cheapest · in-stock', () {
    final cmp = storeComparison('118220', c1Inventory());
    expect(cmp.sheetLine, 'זמין ב-2 חנויות · הזול ב-38₪ · במלאי');

    // Nothing in stock → an explicit "sold out" line (no fake price).
    final out = <InventoryItem>[
      for (final it in c1Inventory())
        if (it.sku == '118220')
          InventoryItem(
            storeId: it.storeId,
            sku: it.sku,
            price: it.price,
            stock: 0,
            updatedAt: it.updatedAt,
          )
        else
          it,
    ];
    expect(storeComparison('118220', out).sheetLine, 'אזל מהמלאי בכל החנויות');
  });
}
