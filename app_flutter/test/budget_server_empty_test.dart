// Pins the budget server-persistence wiring (#wave2b-budget-persist).
// `BudgetNotifier` now seeds from + persists through a `FinanceRepository`:
//   1. EMPTY repo (the backend's honest genesis) → 0/0/[], pct 0, no crash;
//   2. the LOCAL const repo → the const demo budget, byte-identical (demo path
//      unchanged — setBudget is a no-op, no listenable, ephemeral as always);
//   3. an edit PERSISTS through `repo.setBudget` (the whole budget), and a
//      backend change (the repo's `budgetListenable` firing) RE-SEEDS the state.
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/data/repositories/finance_local.dart';
import 'package:buildsmart/data/repositories/finance_repository.dart';
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/state/finance_hub_state.dart' show FinanceApproval;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [FinanceRepository] that backs the budget reads with mutable
/// fields, records every [setBudget], and IS the `budgetListenable` (fires on a
/// write — mirroring the real optimistic-cache `notifyListeners`).
class _FakeFinanceRepo extends ChangeNotifier implements FinanceRepository {
  _FakeFinanceRepo({
    int total = 0,
    int spent = 0,
    List<BudgetCategory> cats = const [],
  })  : _total = total,
        _spent = spent,
        _cats = cats;

  int _total;
  int _spent;
  List<BudgetCategory> _cats;
  final List<({int total, int spent, int catCount})> setCalls = [];

  @override
  int budgetTotal() => _total;
  @override
  int budgetSpent() => _spent;
  @override
  List<BudgetCategory> budgetCategories() => _cats;
  @override
  int budgetPct() => _total > 0 ? (_spent / _total * 100).round() : 0;

  @override
  void setBudget(int total, int spent, List<BudgetCategory> categories) {
    _total = total;
    _spent = spent;
    _cats = categories;
    setCalls.add((total: total, spent: spent, catCount: categories.length));
    notifyListeners(); // mirror the real repo's optimistic-write notify
  }

  @override
  Listenable? get budgetListenable => this;

  // — unused by the budget editor —
  @override
  ({String label, String cls}) budgetLevel(int pct) => (label: '', cls: '');
  @override
  List<Section> financeHub() => const [];
  @override
  int activeRevenue() => 0;
  @override
  List<FinanceApproval> approvals() => const [];
  @override
  void decide(String id, bool ok) {}
  @override
  Listenable? get approvalsListenable => null;
}

void main() {
  test('empty repo (backend honest genesis): 0/0/[], pct 0, no crash', () {
    final n = BudgetNotifier(_FakeFinanceRepo());
    addTearDown(n.dispose);

    expect(n.state.total, 0);
    expect(n.state.spent, 0);
    expect(n.state.categories, isEmpty,
        reason: 'connected genesis → honest empty budget, not demo money');
    expect(n.state.pct, 0, reason: 'pct guards total==0 (no divide-by-zero)');
  });

  test('local const repo → the demo budget, byte-identical (demo path unchanged)',
      () {
    final n = BudgetNotifier(const LocalFinanceRepository.constData());
    addTearDown(n.dispose);

    expect(n.state.total, kBudgetTotal);
    expect(n.state.spent, kBudgetSpent);
    expect(n.state.categories.length, kBudgetCategories.length);
    expect(n.state.categories.first.name, kBudgetCategories.first.name);

    // A local edit updates in-memory state but persists NOTHING (no-op) — the
    // demo budget stays ephemeral exactly as before.
    n.setTotals(20000, 5000);
    expect(n.state.total, 20000);
    expect(n.state.spent, 5000);
  });

  test('connected: an edit PERSISTS via setBudget and the state round-trips', () {
    final repo = _FakeFinanceRepo();
    final n = BudgetNotifier(repo);
    addTearDown(n.dispose);

    n.setTotals(30000, 12000);
    expect(repo.setCalls, isNotEmpty,
        reason: 'an edit routes through repo.setBudget (persisted, not lost)');
    expect(repo.setCalls.last.total, 30000);
    expect(repo.setCalls.last.spent, 12000);
    // The re-seed (repo notified) keeps state consistent with the persisted value.
    expect(n.state.total, 30000);
    expect(n.state.spent, 12000);

    final i = n.addCategory();
    expect(i, n.state.categories.length - 1,
        reason: 'addCategory returns a valid index after the persist/re-seed');
    expect(repo.setCalls.last.catCount, n.state.categories.length);
  });

  test('connected: a backend change (listenable fires) re-seeds the budget', () {
    final repo = _FakeFinanceRepo();
    final n = BudgetNotifier(repo);
    addTearDown(n.dispose);
    expect(n.state.total, 0);

    // Simulate a snapshot landing with a persisted budget from the backend.
    repo.setBudget(
      50000,
      18000,
      const [BudgetCategory('חשמל', '⚡', 18000)],
    );
    expect(n.state.total, 50000,
        reason: 'the budget editor re-seeds when the repo notifies');
    expect(n.state.categories.single.name, 'חשמל');
  });
}
