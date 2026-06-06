// ─────────────────────────────────────────────────────────────────────────────
// StockRepository — the read surface for stock / availability + the supplier
// store network (the manager 📦/✅/🏪 tiles + the 🏪 store persona).
//
// SERVER-READY FOUNDATION (Track T6.1). ABSTRACT interface only; local impl
// (T6.2) + provider refactor (T6.3) come later.
//
// CURRENT BACKING (what T6.2's local impl will wrap): the manager catalog
// distribution + store list folded by `ManagerAnalytics`
// (`managerAnalyticsProvider`, `state/orders_engine.dart` /
// `logic/manager_dashboard.dart`: `kManagerCatalogCategories`,
// `kManagerStores`), plus the supplier store + haulage seeds in
// `data/supplier_data.dart` (`kStores`, `kHaulTypes`). `STORE_STOCK` is seeded
// all-`true` today, so `availableCount == totalProducts`; a real inventory
// backend drops in behind this contract (swap-implementation-only).
//
// Method surface mirrors the stock/store numbers the dashboard + store portal
// read today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/supplier_data.dart' show HaulType, StoreInfo;
import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerStore;

/// Server-ready contract over stock/availability + the store network. The
/// current backing is the manager analytics (`managerAnalyticsProvider`) +
/// `data/supplier_data.dart`; a future inventory backend swaps in behind it.
abstract class StockRepository {
  /// Every product in the catalog (sum of all category buckets). Mirrors
  /// `ManagerAnalytics.totalProducts`.
  int totalProducts();

  /// Non-accessory products (📦 מוצרים בקטלוג). Mirrors `ManagerAnalytics.catalogCount`.
  int catalogCount();

  /// Accessory products flagged `accessoryProduct:true` (🧰 אביזרים נלווים).
  /// Mirrors `ManagerAnalytics.accessoryCount`.
  int accessoryCount();

  /// Products currently in stock (✅ זמינים כעת). `STORE_STOCK` is seeded
  /// all-`true`, so this equals [totalProducts] today. Mirrors
  /// `ManagerAnalytics.availableCount`.
  int availableCount();

  /// Per-category product counts (the catalog distribution the dashboard splits
  /// on). Mirrors `kManagerCatalogCategories`.
  Map<String, int> categoryCounts();

  /// The manager's store network (name · area · eta · on). Mirrors `kManagerStores`.
  List<ManagerStore> stores();

  /// Count of active stores (🏪 חנויות פעילות — `on:true`). Mirrors
  /// `ManagerAnalytics.activeStores`.
  int activeStores();

  /// The supplier store rows for the 🏪 store persona (name · area · eta).
  /// Mirrors `kStores` (`data/supplier_data.dart`).
  List<StoreInfo> supplierStores();

  /// The haulage types (small | van | truck) the store/courier flow uses.
  /// Mirrors `kHaulTypes`.
  List<HaulType> haulTypes();
}
