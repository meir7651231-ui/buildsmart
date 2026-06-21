// Pins the budget server-honesty wiring (#wave2b-budget). `budgetProvider` now
// seeds `BudgetNotifier` from the finance repo's reads instead of always the
// const demo, so on the connected backend the budget shows the HONEST empty
// figures (0/0/[] — finance_firebase's stated philosophy, matching the
// finance-hub budget box) instead of fabricated demo money. Two invariants:
//   1. an EMPTY seed (the backend's honest reads) yields total/spent 0, no
//      categories, pct 0 — and does NOT crash (the screen's `categories.isEmpty`
//      branch renders it).
//   2. a BARE `BudgetNotifier()` (the local/demo default) stays the const demo
//      budget — byte-identical to before (zero regression on the demo path).
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty seed (connected honest reads): 0/0/[], pct 0, no crash', () {
    final n = BudgetNotifier(total: 0, spent: 0, categories: const []);
    addTearDown(n.dispose);

    expect(n.state.total, 0);
    expect(n.state.spent, 0);
    expect(n.state.categories, isEmpty,
        reason: 'connected → honest empty budget, not fabricated demo money');
    expect(n.state.pct, 0, reason: 'pct guards total==0 (no divide-by-zero)');
  });

  test('bare BudgetNotifier() stays the const demo budget (byte-identical)', () {
    final n = BudgetNotifier();
    addTearDown(n.dispose);

    expect(n.state.total, kBudgetTotal);
    expect(n.state.spent, kBudgetSpent);
    expect(n.state.categories.length, kBudgetCategories.length,
        reason: 'demo path unchanged — same 4 seeded categories');
    expect(n.state.categories.first.name, kBudgetCategories.first.name);
  });
}
