// Pins the #twin pure helpers extracted from budget_screen:
//   - budgetSpendBySite: the connected per-site fold (Σ orders by o.site).
//   - illustrativeSiteSpend: the demo weighting, pinned VERBATIM so a refactor
//     can't silently drift the OFF/byte-identical path.
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Order _ord(String site, int sum) =>
    Order(id: 'X', who: 'w', site: site, items: 1, sum: sum, stage: 'new');

void main() {
  test('budgetSpendBySite folds orders by site (sum per site)', () {
    final m = budgetSpendBySite(
        [_ord('אתר א', 100), _ord('אתר א', 50), _ord('אתר ב', 30)]);
    expect(m['אתר א'], 150, reason: 'two orders on the same site sum together');
    expect(m['אתר ב'], 30);
    expect(m['לא קיים'] ?? 0, 0, reason: 'an unlisted site → 0 (matches `?? 0`)');
    expect(budgetSpendBySite(const []), isEmpty);
  });

  test('illustrativeSiteSpend pins the demo weighting verbatim', () {
    // n=3 → decreasing weights 3/6, 2/6, 1/6 of spent (the shipped formula).
    expect(illustrativeSiteSpend(600, 3, 0), 600 * 3 / 6);
    expect(illustrativeSiteSpend(600, 3, 1), 600 * 2 / 6);
    expect(illustrativeSiteSpend(600, 3, 2), 600 * 1 / 6);
    expect(illustrativeSiteSpend(600, 0, 0), 0,
        reason: 'no projects → 0 (guards divide-by-zero)');
  });

  test('budgetResidualSpend = orders on non-project sites (the "אחר" row)', () {
    // Orphan surfaces: rows(100) + residual(40) == real total(140).
    final m1 = budgetSpendBySite([_ord('אתר א', 100), _ord('ללא פרויקט', 40)]);
    expect(budgetResidualSpend(m1, ['אתר א']), 40);
    // No orphans → 0 → the row is hidden (pins the `> 0` render gate).
    final m2 = budgetSpendBySite([_ord('אתר א', 100), _ord('אתר ב', 30)]);
    expect(budgetResidualSpend(m2, ['אתר א', 'אתר ב']), 0);
    // Multiple orphans aggregate into ONE residual row.
    final m3 =
        budgetSpendBySite([_ord('אתר א', 100), _ord('X', 10), _ord('Y', 5)]);
    expect(budgetResidualSpend(m3, ['אתר א']), 15);
  });
}
