// ─────────────────────────────────────────────────────────────────────────────
// CustomersRepository — the read surface for the manager's 👥 לקוחות view.
//
// SERVER-READY FOUNDATION (Track T6.1). ABSTRACT interface only; local impl
// (T6.2) + provider refactor (T6.3) come later.
//
// CURRENT BACKING (what T6.2's local impl will wrap): the buyer aggregates
// derived from the shared orders engine — `managerCustomersProvider`
// (`state/orders_engine.dart`) which folds the live orders through
// `mgrCustomerList` (`logic/manager_dashboard.dart`), plus the per-contractor
// `contractorCredit` ceiling. A future CRM backend swaps in behind this
// contract (swap-implementation-only).
//
// Method surface mirrors what the manager dashboard reads today:
//   • all()        — the group-by-buyer aggregates (sorted by spend).
//   • byName()     — a single buyer's aggregate.
//   • creditLimit()— the contractor's deterministic credit ceiling.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerCustomer;

/// Server-ready contract over the manager's customer aggregates. The current
/// backing is `managerCustomersProvider` (`state/orders_engine.dart`) +
/// `mgrCustomerList`/`contractorCredit` (`logic/manager_dashboard.dart`).
abstract class CustomersRepository {
  /// Every buyer aggregate (name · orderCount · totalSpend · creditLimit),
  /// grouped from the live orders and sorted by spend (desc). Mirrors
  /// `ref.watch(managerCustomersProvider)`.
  List<ManagerCustomer> all();

  /// The aggregate for the buyer named [name], or null if they have no orders.
  ManagerCustomer? byName(String name);

  /// The contractor's credit ceiling in ₪ — a deterministic per-name value in
  /// the 30,000–120,000 band. Mirrors `contractorCredit(name)`.
  int creditLimit(String name);
}
