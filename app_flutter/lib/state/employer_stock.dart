import 'package:buildsmart/screens/stock_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One row of the employer's (contractor's) stock as the WORKER reads it —
/// a name + its location ('warehouse' / 'site'). A read-only projection:
/// there is no mutator here, because the worker NEVER edits the employer's
/// stock (only the contractor owns and moves [stockProvider]). Mirrors
/// `employer_link.dart`'s `EmployerProfile` read-only-projection pattern.
class EmployerStockItem {
  const EmployerStockItem(this.name, this.location);

  /// Item name (e.g. 'סרט טפלון') — the key of the contractor's live stock map.
  final String name;

  /// Where the item is: `'warehouse'` (🏬 מחסן) or `'site'` (🏗️ אתר) — the
  /// value of the contractor's live stock map, surfaced verbatim.
  final String location;
}

/// Resolves a worker's `employerId` (the Wave-0 link minted in
/// `board_auth.dart`) to the employing contractor's stock, READ-ONLY.
///
/// SERVER-SWAP SEAM (mirrors `employer_link.dart` / the `stock_repository`
/// server-ready seam). When the backend lands this body becomes an
/// employer-scoped `stock` query (`where employerId == …`) via
/// `stockRepositoryProvider` — only THIS provider swaps, and every consumer
/// that reads `employerStockProvider(session.employerId)` is unchanged. TODAY
/// the single-device demo holds exactly ONE contractor (the device's own
/// [stockProvider], the live `Map<String,String>` name→location), so ANY
/// non-empty `employerId` resolves to that one device contractor's stock —
/// honest, because there is one contractor per device and we fabricate no
/// second identity. An empty `employerId` (no link — e.g. the
/// contractor/manager/store themselves, or a worker with no resolvable
/// employer yet) yields `const []`, so the consumer shows the honest "to be
/// connected with the server" empty state instead of a fabricated list.
///
/// READ-ONLY: no mutators, no exposure of [StockNotifier.move]. The worker
/// only SEES the employer's stock; moving items between warehouse and site
/// stays the contractor's own action in `stock_screen.dart`.
final employerStockProvider =
    Provider.family<List<EmployerStockItem>, String>((ref, employerId) {
  if (employerId.isEmpty) return const [];
  // SERVER-SWAP: → an employer-scoped `stock` query via stockRepositoryProvider
  // (cache-bridged). Until then, the one device contractor IS the employer
  // (one contractor per device), so read their live stock map.
  final stock = ref.watch(stockProvider);
  final items = [
    for (final e in stock.entries) EmployerStockItem(e.key, e.value),
  ];
  // Warehouse-first, then name — a stable, deterministic order for the
  // read-only list (and for E1b's test).
  items.sort((a, b) {
    if (a.location != b.location) {
      // 'site' sorts after 'warehouse' (s > w is false, so compare explicitly).
      return a.location == 'warehouse' ? -1 : 1;
    }
    return a.name.compareTo(b.name);
  });
  return items;
});
