// C3.4 — the product-sheet STORE-COMPARISON line (SPEC-catalog-to-server).
//
// Renders [StoreComparison.sheetLine] — "זמין ב-N חנויות · הזול ב-X₪ · במלאי" — inside
// the Lipskey product sheet. OWNER-LOCKED: this is the ONLY sheet surface that shows a
// price; the finder/catalog never do (R1-6). The comparison itself is C1.8/C3.3's pure
// logic, sourced from the cached [StoreInventoryRepository] (C3.1/C3.2).
//
// GATING — the sheet includes this widget ONLY behind `if (kStoreComparisonUi)`, a
// top-level const (default false). A const-false `if` is dead code that dart2js
// tree-shakes, so with the flag OFF the sheet is byte-identical and this whole file
// (widget + providers) drops out of the build. The real Firestore source is wired at
// go-live (1-B) — until then [storeInventoryRepositoryProvider] throws, which is never
// reached live (the gate is off) and is overridden by a fake in tests.

import 'package:buildsmart/data/repositories/catalog_paged.dart'
    show useServerCatalog;
import 'package:buildsmart/data/repositories/store_inventory.dart'
    show StoreComparison;
import 'package:buildsmart/data/repositories/store_inventory_firestore.dart'
    show StoreInventoryFirestoreSource;
import 'package:buildsmart/data/repositories/store_repo.dart'
    show StoreInventoryRepository;
import 'package:buildsmart/state/app_profile.dart'
    show kProfileStoreComparisonUi;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// C3.4 UI gate — default OFF ⇒ byte-identical (a top-level const, tree-shaken out of
/// the sheet). The owner flips `SERVER_STORE_UI` at go-live, alongside
/// `useServerCatalog` (the data master) — the UI never shows a price with no data.
// stage-3.4: profile-aware default (explicit define still wins).
const bool kStoreComparisonUi = bool.fromEnvironment('STORE_COMPARISON_UI',
    defaultValue: kProfileStoreComparisonUi);

/// The store/inventory repository. With the server catalog live it reads the seeded
/// `stores` + `inventory` from Firestore ([StoreInventoryFirestoreSource]); gated on
/// [useServerCatalog] (folds false in the demo build ⇒ the Firestore branch tree-shakes,
/// byte-identical). Tests override this with a fake, so neither branch runs in tests.
final storeInventoryRepositoryProvider = Provider<StoreInventoryRepository>(
  (ref) {
    if (useServerCatalog) {
      return StoreInventoryRepository(StoreInventoryFirestoreSource());
    }
    // Unreachable in a live build (the widget is behind [kStoreComparisonUi]); tests
    // override the provider, so this throw guards only a misconfiguration.
    throw UnimplementedError(
      'storeInventoryRepositoryProvider needs useServerCatalog (or a test override)',
    );
  },
);

/// The multi-store comparison for one `sku`, from the cached repository.
final storeComparisonForSkuProvider =
    FutureProvider.family<StoreComparison, String>(
  (ref, sku) => ref.watch(storeInventoryRepositoryProvider).comparison(sku),
);

/// The single line the product sheet shows under the title:
/// "זמין ב-N חנויות · הזול ב-X₪ · במלאי". While the comparison loads (or on error) it
/// renders nothing — the sheet stays exactly as it was until real data arrives.
class StoreComparisonLine extends ConsumerWidget {
  const StoreComparisonLine({required this.sku, super.key});

  final String sku;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(storeComparisonForSkuProvider(sku)).maybeWhen(
          data: (cmp) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.storefront, size: 15, color: BsTokens.brand),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    cmp.sheetLine,
                    key: const Key('storeComparisonLine'),
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }
}
