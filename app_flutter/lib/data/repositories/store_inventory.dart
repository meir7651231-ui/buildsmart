// STORES + INVENTORY (SPEC-catalog-to-server · C1.4 — the NEW store layer).
//
// The `stores/{id}` + `inventory/{storeId}_{sku}` collections that C1 introduces:
// per-store PRICE + STOCK, the data the multi-store comparison (C1.8 / C3) reads.
// Minimal models (C3 grows Store with logo/contact); reversible serializers; the 2
// demo stores + a deterministic 40-row inventory (2 stores × the 20 slice SKUs) with
// the owner's headline numbers pinned on 118220 (אחים-כהן 38₪/12 · מרכז 42₪/3).
//
// PRICE lives HERE, never in the catalog doc (R1-6) — the locked "no price in the
// finder/catalog" rule holds; price surfaces only in the store comparison.
//
// GATING: referenced only by the gated seed + tests → tree-shakes out of OFF.

import 'package:buildsmart/data/repositories/catalog_slice.dart'
    show kC1SliceSkus;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;

/// The server collections (C0.2).
const String kStoresCollection = 'stores';
const String kInventoryCollection = 'inventory';

/// A fixed seed timestamp so the seed is deterministic (a real re-sync / price change
/// writes a NEWER `updatedAt` to trigger the cache refresh — C1.6 / C1.9).
const String kC1SeedTimestamp = '2026-07-12T00:00:00Z';

/// The product whose two offers carry the owner's demo numbers (the C1.8 headline).
const String kC1HeadlineSku = '118220';

/// A store front. `logo`/`contact` (C3.1) are optional — a C1 store without them
/// round-trips unchanged (the guarded-field idiom).
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.area,
    this.logo,
    this.contact,
    this.ownerUid,
  });

  factory Store.fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return Store(
      id: (j['id'] as String?) ?? doc.id,
      name: (j['name'] as String?) ?? '',
      area: (j['area'] as String?) ?? '',
      logo: j['logo'] as String?,
      contact: j['contact'] as String?,
      ownerUid: j['ownerUid'] as String?,
    );
  }

  final String id;
  final String name;
  final String area;
  final String? logo;
  final String? contact;

  /// U3.1.2 — the single OWNER of this store (decision #3: one owner per store).
  /// The reverse link (store→owner) of the `storeId` auth claim; server/admin-set
  /// only. Null on every store today (dormant — the C1 seed carries none), so a
  /// store round-trips unchanged (the guarded-field idiom).
  final String? ownerUid;

  Map<String, dynamic> toDoc() => <String, dynamic>{
        'id': id,
        'name': name,
        'area': area,
        if (logo != null) 'logo': logo,
        if (contact != null) 'contact': contact,
        if (ownerUid != null) 'ownerUid': ownerUid,
      };
}

/// One store's price + stock for one SKU — the heart of multi-store comparison. Its
/// doc-id is `{storeId}_{sku}` (a natural composite key ⇒ idempotent upsert).
class InventoryItem {
  const InventoryItem({
    required this.storeId,
    required this.sku,
    required this.price,
    required this.stock,
    required this.updatedAt,
  });

  factory InventoryItem.fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return InventoryItem(
      storeId: (j['storeId'] as String?) ?? '',
      sku: (j['sku'] as String?) ?? '',
      price: (j['price'] as num?) ?? 0,
      stock: (j['stock'] as num?)?.toInt() ?? 0,
      updatedAt: (j['updatedAt'] as String?) ?? '',
    );
  }

  final String storeId;
  final String sku;
  final num price;
  final int stock;
  final String updatedAt;

  String get docId => '${storeId}_$sku';

  Map<String, dynamic> toDoc() => <String, dynamic>{
        'storeId': storeId,
        'sku': sku,
        'price': price,
        'stock': stock,
        'updatedAt': updatedAt,
      };
}

/// The 2 demo stores.
const Store kC1StoreAhimCohen =
    Store(id: 'ahim_cohen', name: 'אחים כהן', area: 'תל אביב');
const Store kC1StoreMerkaz =
    Store(id: 'merkaz', name: 'מרכז האינסטלציה', area: 'ראשון לציון');
const List<Store> kC1Stores = <Store>[kC1StoreAhimCohen, kC1StoreMerkaz];

/// Last [n] digits of a numeric SKU (for a deterministic, reproducible price/stock).
int _tail(String sku, int n) {
  final s = sku.length <= n ? sku : sku.substring(sku.length - n);
  return int.tryParse(s) ?? 0;
}

// אחים-כהן is the cheaper store (so the headline's "הזול" is 38₪); מרכז = +4₪.
num _priceAhim(String sku) => sku == kC1HeadlineSku ? 38 : 4 + (_tail(sku, 3) % 60);
num _priceMerkaz(String sku) => _priceAhim(sku) + 4;
int _stockAhim(String sku) => sku == kC1HeadlineSku ? 12 : 2 + (_tail(sku, 2) % 18);
int _stockMerkaz(String sku) => sku == kC1HeadlineSku ? 3 : 1 + (_tail(sku, 2) % 7);

/// 40 inventory rows — both stores × the 20 slice SKUs. Deterministic; 118220 carries
/// the owner's demo numbers (אחים-כהן 38₪/12 · מרכז 42₪/3).
List<InventoryItem> c1Inventory() => <InventoryItem>[
      for (final sku in kC1SliceSkus) ...<InventoryItem>[
        InventoryItem(
          storeId: kC1StoreAhimCohen.id,
          sku: sku,
          price: _priceAhim(sku),
          stock: _stockAhim(sku),
          updatedAt: kC1SeedTimestamp,
        ),
        InventoryItem(
          storeId: kC1StoreMerkaz.id,
          sku: sku,
          price: _priceMerkaz(sku),
          stock: _stockMerkaz(sku),
          updatedAt: kC1SeedTimestamp,
        ),
      ],
    ];

/// A generic id→doc write seam (a fake closure in tests, a lazy-Firestore writer in
/// prod, added at 1-B). doc-id supplied by the caller ⇒ an idempotent upsert.
typedef FirestoreDocSink = Future<void> Function(
  String id,
  Map<String, dynamic> data,
);

/// Seed the 2 demo stores → `stores/{id}`. Returns the count.
Future<int> seedC1Stores(FirestoreDocSink sink) async {
  for (final s in kC1Stores) {
    await sink(s.id, s.toDoc());
  }
  return kC1Stores.length;
}

/// Seed the 40 inventory rows → `inventory/{storeId}_{sku}`. Returns the count.
Future<int> seedC1Inventory(FirestoreDocSink sink) async {
  final inv = c1Inventory();
  for (final it in inv) {
    await sink(it.docId, it.toDoc());
  }
  return inv.length;
}

/// The multi-store comparison for one SKU (C1.8) — the minimal read the product sheet
/// shows. C3.3 grows this into the full comparison engine (replacing the
/// `contractor_seeds` demo); here it is a pure function over the inventory rows.
class StoreComparison {
  const StoreComparison({required this.sku, required this.offers});

  final String sku;

  /// This SKU's offers across stores (any stock level).
  final List<InventoryItem> offers;

  /// Offers actually in stock, cheapest first.
  List<InventoryItem> get inStock {
    final live = offers.where((o) => o.stock > 0).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    return live;
  }

  /// How many stores have it in stock.
  int get availableCount => inStock.length;

  /// The cheapest in-stock offer (null when nothing is in stock).
  InventoryItem? get cheapest => inStock.isEmpty ? null : inStock.first;

  /// The product-sheet headline — e.g. "זמין ב-2 · הזול 38₪".
  String get headline {
    final c = cheapest;
    if (c == null) return 'אזל מהמלאי';
    return 'זמין ב-$availableCount · הזול ${_fmtPrice(c.price)}₪';
  }

  /// C3.4 — the fuller line the product sheet shows: stores · cheapest · in-stock.
  /// e.g. "זמין ב-3 חנויות · הזול ב-38₪ · במלאי". OWNER-LOCKED: price appears ONLY in
  /// this store-comparison line — never in the finder/catalog surfaces.
  String get sheetLine {
    final c = cheapest;
    if (c == null) return 'אזל מהמלאי בכל החנויות';
    return 'זמין ב-$availableCount חנויות · הזול ב-${_fmtPrice(c.price)}₪ · במלאי';
  }

  static String _fmtPrice(num p) =>
      p == p.roundToDouble() ? p.toStringAsFixed(0) : p.toString();
}

/// Build the [StoreComparison] for [sku] from a flat list of inventory rows (the query
/// `inventory where sku == sku`, evaluated in-memory here).
StoreComparison storeComparison(String sku, List<InventoryItem> inventory) =>
    StoreComparison(
      sku: sku,
      offers: <InventoryItem>[
        for (final it in inventory)
          if (it.sku == sku) it,
      ],
    );
