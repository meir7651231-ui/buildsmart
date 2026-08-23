// C3.1 + C3.2 — store + inventory repository (SPEC-catalog-to-server).
//
// Proves the read side: stores load once (cached), inventory-by-sku queries (cached),
// the comparison is built from live inventory, and invalidate re-syncs. Plus the
// C3.1 Store `logo`/`contact` round-trip. Fake source — no Firebase.

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/store_inventory.dart';
import 'package:buildsmart/data/repositories/store_repo.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements StoreInventorySource {
  int storeCalls = 0;
  int invCalls = 0;

  @override
  Future<List<Store>> allStores() async {
    storeCalls++;
    return kC1Stores;
  }

  @override
  Future<List<InventoryItem>> inventoryForSku(String sku) async {
    invCalls++;
    return [
      for (final it in c1Inventory())
        if (it.sku == sku) it,
    ];
  }
}

void main() {
  test('C3.1 — stores load once, then from cache (0 extra source hits)', () async {
    final src = _FakeSource();
    final repo = StoreInventoryRepository(src);

    final a = await repo.stores();
    final b = await repo.stores();
    expect(a.map((s) => s.id).toSet(), {'ahim_cohen', 'merkaz'});
    expect(identical(a, b), isTrue, reason: 'same cached list');
    expect(src.storeCalls, 1, reason: 'fetched once, then cached');
  });

  test('C3.2 — comparison(118220) from inventory-by-sku: זמין ב-2 · הזול 38₪',
      () async {
    final repo = StoreInventoryRepository(_FakeSource());
    final cmp = await repo.comparison('118220');
    expect(cmp.availableCount, 2);
    expect(cmp.cheapest!.price, 38);
    expect(cmp.cheapest!.storeId, 'ahim_cohen');
    expect(cmp.headline, 'זמין ב-2 · הזול 38₪');
  });

  test('C3.2 — inventory-by-sku is cached; invalidate re-syncs', () async {
    final src = _FakeSource();
    final repo = StoreInventoryRepository(src);

    await repo.comparison('118220');
    await repo.comparison('118220'); // cache hit
    expect(src.invCalls, 1, reason: 'one fetch for the sku, then cache');

    repo.invalidate('118220'); // a price/stock change on the server
    await repo.comparison('118220');
    expect(src.invCalls, 2, reason: 'invalidate forces one re-sync');
  });

  test('C3.1 — Store logo/contact round-trip (optional fields)', () {
    const s = Store(
      id: 's1',
      name: 'חנות',
      area: 'חיפה',
      logo: 'logo.png',
      contact: '050-1234567',
    );
    final back = Store.fromDoc(RemoteDoc('s1', s.toDoc()));
    expect(back.logo, 'logo.png');
    expect(back.contact, '050-1234567');
    // A store WITHOUT them still round-trips (guarded fields absent).
    const bare = Store(id: 's2', name: 'x', area: 'y');
    final bareBack = Store.fromDoc(RemoteDoc('s2', bare.toDoc()));
    expect(bareBack.logo, isNull);
    expect(bareBack.contact, isNull);
  });
}
