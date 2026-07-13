// STORE + INVENTORY REPOSITORY (SPEC-catalog-to-server · C3.1 + C3.2).
//
// The read side of the store layer: loads the stores once (cached) and answers
// inventory-BY-SKU queries (cached per sku), then builds the multi-store
// [StoreComparison] (C1.8's pure helper) on top. A source seam ([StoreInventorySource])
// lets a test drive it with a fake; the real lazy-Firestore source is wired at 1-B.
//
// The cache is the same "download-once, re-sync-on-change" spirit as the catalog: a
// repeated query is served from memory (0 source hits) until [invalidate] (a price/
// stock change bumps it — the C1.9 loop).
//
// GATING: referenced only by the gated store surface + tests → tree-shakes out of OFF.

import 'package:buildsmart/data/repositories/store_inventory.dart'
    show InventoryItem, Store, StoreComparison, storeComparison;

/// The backend seam — a fake in tests, a lazy-Firestore adapter in prod (1-B).
abstract class StoreInventorySource {
  /// Every store (`stores` collection).
  Future<List<Store>> allStores();

  /// The offers for one SKU (`inventory where sku == sku`).
  Future<List<InventoryItem>> inventoryForSku(String sku);
}

/// Caches stores + per-sku inventory and serves the comparison. One repeated read
/// pays no source round-trip (the egress saving) until [invalidate].
class StoreInventoryRepository {
  StoreInventoryRepository(this._source);

  final StoreInventorySource _source;

  List<Store>? _stores;
  final Map<String, List<InventoryItem>> _invBySku = {};

  /// All stores — fetched ONCE, then from cache.
  Future<List<Store>> stores() async => _stores ??= await _source.allStores();

  /// The offers for [sku] — fetched once per sku, then from cache.
  Future<List<InventoryItem>> inventoryForSku(String sku) async =>
      _invBySku[sku] ??= await _source.inventoryForSku(sku);

  /// The multi-store comparison for [sku] ("זמין ב-N · הזול X₪") from live inventory.
  Future<StoreComparison> comparison(String sku) async =>
      storeComparison(sku, await inventoryForSku(sku));

  /// C3.5 — the REAL price: the cheapest IN-STOCK offer for [sku] (null when nothing
  /// is in stock). This is the ready drop-in for the category-GUESS `priceFor` — a
  /// real number from a real store, never an estimate. The live swap happens at the
  /// cutover (when real inventory exists); until then `priceFor` stays.
  Future<num?> cheapestPrice(String sku) async =>
      (await comparison(sku)).cheapest?.price;

  /// C3.3 — the across-catalog comparison: one [StoreComparison] per requested sku.
  /// The ready drop-in for the demo `storePriceComparisonAcrossCatalog`
  /// (`contractor_seeds` ScanItem/StoreOffer) — sourced from real `inventory`, not
  /// hardcoded offers. Swapped in at the cutover.
  Future<List<StoreComparison>> compareMany(Iterable<String> skus) async =>
      <StoreComparison>[for (final sku in skus) await comparison(sku)];

  /// Drop the caches (a store/price/stock change → the next read re-syncs). Pass a
  /// [sku] to invalidate just that product's offers; null clears everything.
  void invalidate([String? sku]) {
    if (sku == null) {
      _stores = null;
      _invBySku.clear();
    } else {
      _invBySku.remove(sku);
    }
  }
}
