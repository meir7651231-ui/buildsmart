// T0 DoD guard (PLAN-contractor-completion §T0): the contractor seeds are
// present, verbatim-shaped, and the pure helpers compute correctly. Locks the
// counts/sums so a future edit that drops or mangles a seed fails here.
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contractor seeds (T0)', () {
    test('SAFETY_TIPS — 5 verbatim tips', () {
      expect(kSafetyTips, hasLength(5));
      expect(kSafetyTips.first,
          '🦺 לוודא קסדות ואפודים זוהרים לכל הנוכחים באתר.');
    });

    test('budget thresholds (80/90/100) + level logic', () {
      expect(kBudgetThresholds.map((t) => t.pct).toList(), [80, 90, 100]);
      expect(budgetLevel(66).cls, 'ok'); // projectBudget pct
      expect(budgetLevel(85).cls, 'h');
      expect(budgetLevel(95).cls, 'x');
      expect(budgetLevel(90).label, 'חריגה קריטית');
    });

    test('budget categories (4) sum to spent (9840); total 15000', () {
      expect(kBudgetCategories, hasLength(4));
      final sum = kBudgetCategories.fold<int>(0, (a, c) => a + c.amount);
      expect(sum, kBudgetSpent);
      expect(kBudgetSpent, 9840);
      expect(kBudgetTotal, 15000);
    });

    test('DEPT — 8 home tiles, last is הכל', () {
      expect(kDeptTiles, hasLength(8));
      expect(kDeptTiles.last.name, 'הכל');
    });

    test('PLAN_TYPES — 4 types · 13 zones · every item has 3 store offers', () {
      expect(kPlanTypes, hasLength(4));
      expect(kPlanTypes.map((p) => p.key).toList(),
          ['plumbing', 'electrical', 'architectural', 'finishing']);
      final zoneCount = kPlanTypes.fold<int>(0, (a, p) => a + p.zones.length);
      expect(zoneCount, 13);
      for (final p in kPlanTypes) {
        expect(p.steps, hasLength(4));
        expect(p.steps.first, 'סורק את התוכנית...');
        expect(p.steps.last, 'משווה מחירים בחנויות...');
        for (final z in p.zones) {
          expect(z.items, isNotEmpty);
          for (final it in z.items) {
            expect(it.stores, hasLength(3));
          }
        }
      }
    });

    test('bestStore picks the lowest-price offer index', () {
      // אסלה תלויה: בנייני העיר 789 · אבן קיסר 740 · טמבור הום 765 → index 1
      final stores = kPlanTypes.first.zones.first.items.first.stores;
      expect(bestStore(stores), 1);
      expect(stores[bestStore(stores)].price, 740);
      expect(bestStore(const []), 0); // defensive
    });

    test('fMoney — ₪ + thousands separator', () {
      expect(fMoney(9840), '₪9,840');
      expect(fMoney(15000), '₪15,000');
      expect(fMoney(789), '₪789');
    });

    test('caToday — DD/MM/YYYY', () {
      expect(caToday(DateTime(2026, 6, 3)), '03/06/2026');
    });
  });
}
