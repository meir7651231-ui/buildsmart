// ─────────────────────────────────────────────────────────────────────────────
// LocalFinanceRepository — the T6.2 local implementation of [FinanceRepository].
//
// SERVER-READY FOUNDATION (Track T6.2 + T6.3). This wraps the EXISTING const
// budget seeds + finance-hub section list — it adds NO new data and changes NO
// value. Every const-backed read returns EXACTLY the same const / const-derived
// value the finance-hub sheets read today, so the 📊 מרכז פיננסים hub stays
// byte-for-byte identical (index, payment-terms, subs, approvals, gauge, ROI,
// invoice-split, penalty, FX). When the budget/finance data moves to a real
// accounting backend, only THIS class swaps (the accessor + UI stay unchanged).
//
// ── THE ACCESSOR PATTERN (why this file exposes TWO entry points) ─────────────
// The const budget data is read by TOP-LEVEL `_open*` functions in
// `screens/finance_hub_sheets.dart` — plain functions with NO [WidgetRef] in
// scope. Threading a [Ref] into them would change their signatures (and the
// menu's call-sites) — the riskier path that the prior R8 ceiling avoided. So
// the const-only reads route through a GLOBAL, Ref-free accessor instead:
//
//   • [financeRepo] → a top-level function returning the shared `const`
//     [LocalFinanceRepository] instance. Non-ref code calls
//     `financeRepo().budgetTotal()` etc. — no [Ref], no signature change.
//   • [financeRepositoryProvider] → the Riverpod seam for code that DOES have a
//     [Ref]; it hands out a Ref-bearing instance so the ONE method that needs
//     live state ([activeRevenue], Σ sum of open orders) can reach the engine.
//
// The const path and the provider path return the SAME const budget values; the
// only difference is whether [activeRevenue] can resolve (const accessor: no, it
// has no engine — and no finance-hub sheet reads it; provider: yes). A future
// remote impl swaps in behind BOTH entry points.
//
// Like [LocalCatalogRepository] (and unlike the always-Ref orders repo) the
// const data here is PURE — it forwards to top-level consts / const-derived
// helpers, so the const instance needs no [Ref]. The backing:
//   • kBudgetTotal / kBudgetSpent / kBudgetCategories / budgetLevel
//                                          (data/contractor_seeds.dart)
//   • budgetPct                            (data/phaseb_seeds.dart)
//   • kFinanceHub                          (data/menu_trees.dart)
//   • Σ sum of open orders (activeRevenue) (state/orders_engine.dart, Ref-only)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/contractor_seeds.dart'
    show
        BudgetCategory,
        budgetLevel,
        kBudgetCategories,
        kBudgetSpent,
        kBudgetTotal;
import 'package:buildsmart/data/menu_trees.dart' show kFinanceHub;
import 'package:buildsmart/data/phaseb_seeds.dart' show budgetPct;
import 'package:buildsmart/data/repositories/finance_firebase.dart'
    show FirebaseFinanceRepository;
import 'package:buildsmart/data/repositories/finance_repository.dart';
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/state/orders_engine.dart' show ordersEngineProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Module-level pass-throughs to the const helpers whose names this class's
// methods shadow. Inside an instance method, an unprefixed `budgetLevel(pct)` /
// `budgetPct()` would resolve to the (overriding) instance method and recurse
// forever — exactly the trap `catalog_local.dart` avoids with its `st.` prefix
// and `site_local.dart` avoids with `budgetLevelFor`. These thin aliases reach
// the top-level helpers with NO value change.
({String label, String cls}) _budgetLevelFor(int pct) => budgetLevel(pct);
int _budgetPctValue() => budgetPct();

/// The local (const-backed) implementation of [FinanceRepository]. The budget +
/// finance-hub reads are PURE (forward to a top-level const / const-derived
/// helper, returning the SAME object the sheets read today — no value is
/// recomputed and no [Ref] is needed). The single live read ([activeRevenue],
/// Σ sum of open orders) needs the orders engine, so the instance can OPTIONALLY
/// hold a [Ref]: the `const` accessor instance has none (and no sheet reads
/// revenue), while [financeRepositoryProvider] supplies one. A future remote
/// impl swaps in behind the same accessor + provider.
class LocalFinanceRepository implements FinanceRepository {
  /// Ref-bearing constructor — used by [financeRepositoryProvider] so
  /// [activeRevenue] can reach the live orders engine.
  const LocalFinanceRepository(this._ref);

  /// Const, Ref-free constructor — backs the global [financeRepo] accessor that
  /// the non-ref top-level finance-hub functions call. Every const-budget method
  /// works; only [activeRevenue] (which has no engine here) is unavailable.
  const LocalFinanceRepository.constData() : _ref = null;

  final Ref? _ref;

  // ── const project budget (byte-identical to the seeds) ──────────────────────

  @override
  int budgetTotal() => kBudgetTotal;

  @override
  int budgetSpent() => kBudgetSpent;

  @override
  List<BudgetCategory> budgetCategories() => kBudgetCategories;

  @override
  int budgetPct() => _budgetPctValue();

  @override
  ({String label, String cls}) budgetLevel(int pct) => _budgetLevelFor(pct);

  // ── finance-hub section list ────────────────────────────────────────────────

  @override
  List<Section> financeHub() => kFinanceHub;

  // ── live revenue (Ref-only) ─────────────────────────────────────────────────

  /// Σ sum of OPEN orders — the manager's 💰 figure, derived from the shared
  /// orders engine (same fold the dashboard's `revenue`/`מחזור` strip uses, over
  /// the open subset per the [FinanceRepository.activeRevenue] contract). Needs a
  /// live [Ref]; the const accessor instance has none, so it throws there (and no
  /// finance-hub sheet reads revenue, so the const path never calls this).
  @override
  int activeRevenue() {
    final ref = _ref;
    if (ref == null) {
      throw StateError(
        'activeRevenue() needs the live orders engine — read it through '
        'financeRepositoryProvider, not the const financeRepo() accessor.',
      );
    }
    return ref
        .read(ordersEngineProvider)
        .where((o) => o.isOpen)
        .fold<int>(0, (s, o) => s + o.sum);
  }
}

/// The shared `const` instance backing the global [financeRepo] accessor on the
/// Firebase-free path — the const-budget read surface for non-ref code (the
/// finance-hub top-level functions). Constructing it is free, so it's a
/// top-level `const`.
const LocalFinanceRepository _kFinanceConst =
    LocalFinanceRepository.constData();

/// The app-lifetime Firebase finance singleton backing the global [financeRepo]
/// accessor when Firebase is initialised. Built+attached ONCE on first access
/// and kept for the whole app run (the global accessor has no provider lifecycle
/// to dispose it against — it lives as long as the process, exactly like the
/// const instance it replaces). The Ref is `null` here: the accessor path is
/// Ref-free, so the delegated [FinanceRepository.activeRevenue] is unavailable
/// through it (it throws — same contract as the const accessor today; no
/// finance-hub sheet reads revenue through the accessor).
FirebaseFinanceRepository? _firebaseFinanceSingleton;

/// GLOBAL, Ref-free accessor over the finance read surface (const project budget
/// + finance-hub data + — when Firebase is up — the persisted approval/penalty/
/// payment-term lists). The finance-hub's top-level `_open*` functions read
/// budget data THROUGH this (`financeRepo().budgetTotal()` …) WITHOUT a
/// [WidgetRef] — so no signature changes and no value changes.
///
/// Swap (mirrors `ordersRepositoryProvider`, adapted to a Ref-free app-lifetime
/// singleton): when Firebase is initialised (the real app) a single
/// [FirebaseFinanceRepository] is built+`attach()`ed once and reused for the app
/// lifetime; when Firebase is NOT initialised (the entire Firebase-free test
/// suite) the const [LocalFinanceRepository] is returned, so tests never touch
/// Firestore. Both satisfy the same sync [FinanceRepository] contract.
FinanceRepository financeRepo() {
  if (Firebase.apps.isNotEmpty) {
    return _firebaseFinanceSingleton ??=
        (FirebaseFinanceRepository(null)..attach());
  }
  return _kFinanceConst;
}

/// The finance repository provider — the server-ready seam for code that holds a
/// [Ref] (so [FinanceRepository.activeRevenue] can resolve against the live
/// orders engine). Swap (mirrors `ordersRepositoryProvider`): when Firebase is
/// initialised it returns a Ref-bearing [FirebaseFinanceRepository] that
/// `attach()`es its three `snapshots()` listeners and is disposed with the
/// provider (`ref.onDispose`); when Firebase is NOT initialised it returns the
/// Ref-bearing [LocalFinanceRepository] (so the suite stays Firebase-free). Both
/// return the same const budget values + a live `activeRevenue`.
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  if (Firebase.apps.isNotEmpty) {
    final repo = FirebaseFinanceRepository(ref)..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalFinanceRepository(ref);
});
