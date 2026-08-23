// M0 — manager command-center derivations. Every expected number here is the
// VERBATIM value computed by the legacy `mgrAnalytics()` over the live
// index.html seed data (re-derived during the port; see manager_dashboard.dart
// for the @legacy line anchors). These tests pin that the Flutter derivation
// reproduces the legacy numbers exactly — if the seed data drifts, they fail.

import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ManagerAnalytics — the 5 mdMetric tiles (index.html:12160-12164)', () {
    const a = managerAnalytics;

    test('🚚 openOrders = orders not delivered = 4 (seed: new/preparing/ready/transit)',
        () {
      expect(a.openOrders, 4);
      // Every seed order is open (none delivered).
      expect(kManagerOrderSeed.every((o) => o.isOpen), isTrue);
    });

    test('📦 catalogCount = non-accessory products = 54', () {
      expect(a.catalogCount, 54);
    });

    test('🧰 accessoryCount = accessoryProduct:true products = 148', () {
      expect(a.accessoryCount, 148);
    });

    test('✅ availableCount = all in stock = total = 202 (STORE_STOCK all true)',
        () {
      expect(a.availableCount, 202);
      expect(a.totalProducts, 202);
      // The split is exhaustive: catalog + accessory == total.
      expect(a.catalogCount + a.accessoryCount, a.totalProducts);
    });

    test('🏪 stores = activeStores/totalStores = 3/3 (all on:true)', () {
      expect(a.activeStores, 3);
      expect(a.totalStores, 3);
      expect(a.storesLabel, '3/3');
    });

    test('catalog distribution sums to 202 across 14 categories', () {
      expect(a.categoryCount, 14);
      expect(
        kManagerCatalogCategories.values.fold(0, (s, n) => s + n),
        202,
      );
    });
  });

  group('ORDER_FLOW (index.html:16943)', () {
    test('verbatim 6-stage flow in order', () {
      expect(
        kManagerOrderFlow,
        ['new', 'preparing', 'ready', 'pickup', 'transit', 'delivered'],
      );
    });

    test('every seed order stage is a known flow stage', () {
      for (final o in kManagerOrderSeed) {
        expect(kManagerOrderFlow, contains(o.stage));
      }
    });
  });

  group('contractorCredit (M3 foundation) — deterministic 30k-120k band', () {
    test('within band and rounded to ₪100', () {
      for (final name in ['יוסי כהן', 'אבי מזרחי', 'משה אברהם', 'דוד לוי', '']) {
        final c = contractorCredit(name);
        expect(c, greaterThanOrEqualTo(30000));
        expect(c, lessThanOrEqualTo(120000));
        expect(c % 100, 0);
      }
    });

    test('deterministic — same name → same ceiling', () {
      expect(contractorCredit('יוסי כהן'), contractorCredit('יוסי כהן'));
    });
  });

  group('mgrCustomerList (M3 foundation) — group-by-buyer', () {
    test('seed has 4 distinct buyers, sorted by spend desc', () {
      final list = mgrCustomerList();
      expect(list.length, 4);
      // Each seed buyer is unique → 1 order each.
      expect(list.every((c) => c.orderCount == 1), isTrue);
      // Sorted by total spend descending: משה אברהם (3150) first.
      expect(list.first.name, 'משה אברהם');
      expect(list.first.totalSpend, 3150);
      for (var i = 0; i < list.length - 1; i++) {
        expect(list[i].totalSpend, greaterThanOrEqualTo(list[i + 1].totalSpend));
      }
    });

    test('aggregates spend across repeated buyers', () {
      const a = ManagerOrder(
        id: 'X-1',
        who: 'בודק',
        site: 's',
        items: 1,
        sum: 100,
        stage: 'new',
      );
      const b = ManagerOrder(
        id: 'X-2',
        who: 'בודק',
        site: 's',
        items: 2,
        sum: 250,
        stage: 'ready',
      );
      final list = mgrCustomerList([a, b]);
      expect(list.length, 1);
      expect(list.first.orderCount, 2);
      expect(list.first.totalSpend, 350);
    });
  });
}
