// GO-LIVE — the REAL Firestore [StoreInventorySource] (SPEC-catalog-to-server · 1-B).
//
// Reads the seeded `stores` + `inventory` collections so the product-sheet comparison
// (C3.4) shows live per-store price/stock. This is the seam-filler that replaces the
// throwing placeholder in storeInventoryRepositoryProvider — reached ONLY when
// useServerCatalog is on (the demo/live build tree-shakes it out).
//
// Reads are one-shot `.get()` (not listeners) — the repository caches per sku (C3.1),
// so a product sheet pays one query, then memory. `sku` is a plain equality filter.

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/store_inventory.dart'
    show InventoryItem, Store, kInventoryCollection, kStoresCollection;
import 'package:buildsmart/data/repositories/store_repo.dart'
    show StoreInventorySource;
import 'package:cloud_firestore/cloud_firestore.dart';

/// The live Firestore source: `stores` (all) + `inventory where sku == sku`.
class StoreInventoryFirestoreSource implements StoreInventorySource {
  StoreInventoryFirestoreSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<List<Store>> allStores() async {
    final snap = await _db.collection(kStoresCollection).get();
    return <Store>[
      for (final d in snap.docs) Store.fromDoc(RemoteDoc(d.id, d.data())),
    ];
  }

  @override
  Future<List<InventoryItem>> inventoryForSku(String sku) async {
    final snap = await _db
        .collection(kInventoryCollection)
        .where('sku', isEqualTo: sku)
        .get();
    return <InventoryItem>[
      for (final d in snap.docs)
        InventoryItem.fromDoc(RemoteDoc(d.id, d.data())),
    ];
  }
}
