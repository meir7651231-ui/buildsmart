// ─────────────────────────────────────────────────────────────────────────────
// LocalStockRepository — the T6.2 local implementation of [StockRepository].
//
// SERVER-READY FOUNDATION (Track T6.2 + T6.3). This wraps the EXISTING const
// stock/availability + store-network seeds — it adds NO new data and changes NO
// value. Every read returns exactly the const it mirrors today, so the manager
// dashboard's stock tiles, the supplier-store rows, the haulage types AND the
// 📦 "המלאי שלי" inventory screen stay byte-for-byte identical. When stock moves
// to a real inventory backend, only THIS class swaps (the providers + UI are
// unchanged).
//
// Backing consts (the single sources of truth, NOT re-declared here):
//   • the manager catalog distribution + store list folded by `ManagerAnalytics`
//     (`logic/manager_dashboard.dart`: `kManagerCatalogCategories`,
//     `kManagerStores`, and the `managerAnalytics` const-folded snapshot for the
//     counts) — identical numbers to what the dashboard reads.
//   • the supplier store + haulage seeds in `data/supplier_data.dart`
//     (`kStores`, `kHaulTypes`).
//   • the 📦 inventory seed `kStockDemo` (`data/phaseb_seeds.dart`).
//
// The inventory SEED (`kStockDemo`, name → 'warehouse'|'site') is exposed via
// the extra concrete [stockDemo] method (NOT on the abstract contract) so the
// `stockProvider`'s StateNotifier can obtain its genesis map THROUGH this
// repository (T6.3) — a const-only accessor that does NOT read any provider,
// keeping the notifier↔repository wiring acyclic. Mirrors `orders_local.dart`'s
// `seed()` idiom exactly.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/phaseb_seeds.dart' show kStockDemo;
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/stock_firebase.dart';
import 'package:buildsmart/data/repositories/stock_repository.dart';
import 'package:buildsmart/data/supplier_data.dart'
    show HaulType, StoreInfo, kHaulTypes, kStores;
import 'package:buildsmart/logic/manager_dashboard.dart'
    show
        ManagerStore,
        kManagerCatalogCategories,
        kManagerStores,
        managerAnalytics;
import 'package:buildsmart/state/auth_state.dart' show currentOrgIdProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local (const-backed) implementation of [StockRepository]. Every read
/// returns the exact const the dashboard / store portal reads today; a future
/// inventory backend swaps in behind this same contract.
class LocalStockRepository implements StockRepository {
  const LocalStockRepository();

  /// The 11-row inventory seed (name → 'warehouse' | 'site') the 📦 "המלאי שלי"
  /// screen starts from. Lifted from [kStockDemo] (the single seed source of
  /// truth); const-only, so reading it never touches a provider (T6.3-safe).
  /// NOT on the abstract [StockRepository] — the screen's notifier reads it
  /// directly, mirroring `LocalOrdersRepository.seed()`.
  Map<String, String> stockDemo() => kStockDemo;

  @override
  int totalProducts() => managerAnalytics.totalProducts;

  @override
  int catalogCount() => managerAnalytics.catalogCount;

  @override
  int accessoryCount() => managerAnalytics.accessoryCount;

  @override
  int availableCount() => managerAnalytics.availableCount;

  @override
  Map<String, int> categoryCounts() => kManagerCatalogCategories;

  @override
  List<ManagerStore> stores() => kManagerStores;

  @override
  int activeStores() => managerAnalytics.activeStores;

  @override
  List<StoreInfo> supplierStores() => kStores;

  @override
  List<HaulType> haulTypes() => kHaulTypes;
}

/// The stock repository provider — the server-ready seam the inventory notifier
/// reads its seed through (T6.3) and the remote impl swaps in behind (S3.T). When
/// Firebase is initialised (the real app, `main()` calls `Firebase.initializeApp`)
/// the Firestore-backed [FirebaseStockRepository] is used — it `attach()`es its
/// `snapshots()` listener (for the mutable inventory; the analytics reads stay
/// const) and is disposed with the provider. When Firebase is NOT initialised
/// (the entire Firebase-free test suite) the const-backed [LocalStockRepository]
/// is used, so tests never touch Firestore. Both satisfy the same sync
/// [StockRepository] contract → providers + UI are unchanged.
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  if (useFirebaseBackend) {
    final repo = FirebaseStockRepository(
      // stage-3.3 St3 — the session org claim `toDoc` stamps as `orgId`
      // (guarded: only when a claim is known; '' → nothing stamped).
      orgId: ref.read(currentOrgIdProvider) ?? '',
    )..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return const LocalStockRepository();
});
