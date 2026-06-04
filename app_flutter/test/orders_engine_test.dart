// SHARED ORDERS ENGINE — unit coverage. Pins:
//   • SEED correctness — the engine starts as the SAME four seed orders, so
//     every existing manager number is reproduced (open=4, the 4 customers).
//   • placeOrder / advance / setStage behavior — verbatim against ORDER_FLOW.
//   • persistence round-trip — orders survive a reload from SharedPreferences.
//   • flow ordering — kManagerOrderFlow is the canonical 6-stage sequence.
//
// The notifier is exercised directly (persist:false) for the pure flow tests so
// no async storage is involved; a separate group uses the real persistence path
// with a mock SharedPreferences.

import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A fresh in-memory engine (no storage) for the flow assertions.
  OrdersEngineNotifier engine() => OrdersEngineNotifier(persist: false);

  group('seed correctness — preserves every existing number', () {
    test('starts as exactly the four seed orders (ids/sums/stages verbatim)',
        () {
      final n = engine();
      expect(n.state.length, 4);
      // Same ids in the same order as the seed source of truth.
      expect(
        n.state.map((o) => o.id).toList(),
        kManagerOrderSeed.map((o) => o.id).toList(),
      );
      for (var i = 0; i < n.state.length; i++) {
        final got = n.state[i];
        final want = kManagerOrderSeed[i];
        expect(got.who, want.who);
        expect(got.site, want.site);
        expect(got.items, want.items);
        expect(got.sum, want.sum);
        expect(got.stage, want.stage);
        expect(got.createdAt, isNull, reason: 'seed orders carry no timestamp');
      }
    });

    test('🚚 open orders = 4 (none delivered) — matches managerAnalytics', () {
      final n = engine();
      final open = n.state.where((o) => o.isOpen).length;
      expect(open, 4);
      expect(open, managerAnalytics.openOrders);
    });

    test('analytics derived from seed orders equal the static managerAnalytics',
        () {
      final n = engine();
      final live = ManagerAnalytics(
        orders: n.state.map((o) => o.toManagerOrder()).toList(),
        stores: kManagerStores,
        catalogCategories: kManagerCatalogCategories,
      );
      expect(live.openOrders, managerAnalytics.openOrders); // 4
      expect(live.catalogCount, managerAnalytics.catalogCount); // 54
      expect(live.accessoryCount, managerAnalytics.accessoryCount); // 148
      expect(live.availableCount, managerAnalytics.availableCount); // 202
      expect(live.storesLabel, managerAnalytics.storesLabel); // 3/3
    });

    test('customers derived from seed orders equal mgrCustomerList()', () {
      final n = engine();
      final live = mgrCustomerList(
        n.state.map((o) => o.toManagerOrder()).toList(),
      );
      final seed = mgrCustomerList();
      expect(live.length, seed.length); // 4 distinct buyers
      expect(live.map((c) => c.name).toList(), seed.map((c) => c.name).toList());
      expect(
        live.map((c) => c.totalSpend).toList(),
        seed.map((c) => c.totalSpend).toList(),
      );
      // Top spender unchanged.
      expect(live.first.name, 'משה אברהם');
      expect(live.first.totalSpend, 3150);
    });
  });

  group('flow ordering — kManagerOrderFlow', () {
    test('verbatim 6-stage sequence', () {
      expect(kManagerOrderFlow,
          ['new', 'preparing', 'ready', 'pickup', 'transit', 'delivered']);
    });
  });

  group('placeOrder — contractor creates an order at stage `new`', () {
    test('new order enters at the first flow stage and is prepended', () {
      final n = engine();
      final before = n.state.length;
      final o = n.placeOrder(
        who: 'בודק קבלן',
        site: 'אתר בדיקה',
        items: 5,
        sum: 900,
      );
      expect(o.stage, 'new');
      expect(o.stage, kManagerOrderFlow.first);
      expect(o.who, 'בודק קבלן');
      expect(o.items, 5);
      expect(o.sum, 900);
      expect(o.createdAt, isNotNull, reason: 'placed orders are timestamped');
      expect(n.state.length, before + 1);
      // Prepended (newest first), like the legacy unshift.
      expect(n.state.first.id, o.id);
    });

    test('auto-assigns the next BS-#### above the current max', () {
      final n = engine();
      // Seed max is BS-1042 → next is BS-1043.
      final o = n.placeOrder(who: 'x', site: 's', items: 1, sum: 1);
      expect(o.id, 'BS-1043');
      final o2 = n.placeOrder(who: 'y', site: 's', items: 1, sum: 1);
      expect(o2.id, 'BS-1044');
    });

    test('honours an explicit id', () {
      final n = engine();
      final o = n.placeOrder(
        who: 'x',
        site: 's',
        items: 1,
        sum: 1,
        id: 'BS-9000',
      );
      expect(o.id, 'BS-9000');
    });

    test('placing a new order raises the open count (drives 🚚 live)', () {
      final n = engine();
      final openBefore = n.state.where((o) => o.isOpen).length; // 4
      n.placeOrder(who: 'x', site: 's', items: 1, sum: 1);
      expect(n.state.where((o) => o.isOpen).length, openBefore + 1); // 5
    });
  });

  group('advance — next stage in the flow', () {
    test('moves an order one stage forward', () {
      final n = engine();
      // BS-1042 is `new` in the seed → advancing makes it `preparing`.
      n.advance('BS-1042');
      final o = n.state.firstWhere((o) => o.id == 'BS-1042');
      expect(o.stage, 'preparing');
    });

    test('walks the entire flow new→…→delivered then stops (no-op at end)', () {
      final n = engine();
      // Drive BS-1042 through every remaining stage.
      const rest = ['preparing', 'ready', 'pickup', 'transit', 'delivered'];
      for (final want in rest) {
        n.advance('BS-1042');
        expect(n.state.firstWhere((o) => o.id == 'BS-1042').stage, want);
      }
      // Already delivered → advance is a no-op (legacy "already completed").
      n.advance('BS-1042');
      expect(n.state.firstWhere((o) => o.id == 'BS-1042').stage, 'delivered');
    });

    test('unknown id is a no-op (state unchanged)', () {
      final n = engine();
      final before = n.state.map((o) => o.stage).toList();
      n.advance('NOPE-1');
      expect(n.state.map((o) => o.stage).toList(), before);
    });
  });

  group('setStage — manager god-step to any stage', () {
    test('jumps an order directly to any valid stage', () {
      final n = engine();
      n.setStage('BS-1042', 'delivered'); // new → delivered in one step
      expect(n.state.firstWhere((o) => o.id == 'BS-1042').stage, 'delivered');
      n.setStage('BS-1042', 'ready'); // and back down
      expect(n.state.firstWhere((o) => o.id == 'BS-1042').stage, 'ready');
    });

    test('ignores an unknown stage', () {
      final n = engine();
      n.setStage('BS-1042', 'banana');
      expect(n.state.firstWhere((o) => o.id == 'BS-1042').stage, 'new');
    });

    test('ignores an unknown id', () {
      final n = engine();
      final before = n.state.map((o) => o.stage).toList();
      n.setStage('NOPE-1', 'ready');
      expect(n.state.map((o) => o.stage).toList(), before);
    });

    test('setting an order to delivered drops it from the open count', () {
      final n = engine();
      expect(n.state.where((o) => o.isOpen).length, 4);
      n.setStage('BS-1042', 'delivered');
      expect(n.state.where((o) => o.isOpen).length, 3);
    });
  });

  group('resetToSeed', () {
    test('restores the four seed orders', () {
      final n = engine();
      n.placeOrder(who: 'x', site: 's', items: 1, sum: 1);
      n.advance('BS-1041');
      n.resetToSeed();
      expect(n.state.length, 4);
      expect(
        n.state.map((o) => o.id).toList(),
        kManagerOrderSeed.map((o) => o.id).toList(),
      );
      expect(n.state.firstWhere((o) => o.id == 'BS-1041').stage, 'preparing');
    });
  });

  group('persistence round-trip (bs.orders.v1)', () {
    test('a placed order survives a reload from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      // First engine — place an order through the persisting path.
      final a = OrdersEngineNotifier();
      a.placeOrder(
        who: 'נשמר',
        site: 'אתר',
        items: 2,
        sum: 300,
        id: 'BS-7777',
      );
      // Let the async _persist() flush.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kOrdersEngineKey), isNotNull);

      // Second engine — must load the persisted list (seed + the new order).
      final b = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(b.state.length, 5);
      final saved = b.state.firstWhere((o) => o.id == 'BS-7777');
      expect(saved.who, 'נשמר');
      expect(saved.sum, 300);
      expect(saved.stage, 'new');
      expect(saved.createdAt, isNotNull, reason: 'timestamp round-trips');
    });

    test('stage changes persist across a reload', () async {
      SharedPreferences.setMockInitialValues({});
      final a = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      a.setStage('BS-1042', 'delivered');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final b = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(b.state.firstWhere((o) => o.id == 'BS-1042').stage, 'delivered');
      // Open count dropped to 3 and survives the reload.
      expect(b.state.where((o) => o.isOpen).length, 3);
    });

    test('corrupt payload falls back to the seed', () async {
      SharedPreferences.setMockInitialValues({kOrdersEngineKey: 'not-json{'});
      final n = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(n.state.length, 4); // seed
      expect(
        n.state.map((o) => o.id).toList(),
        kManagerOrderSeed.map((o) => o.id).toList(),
      );
    });

    test('Order JSON round-trips losslessly', () {
      const o = Order(
        id: 'BS-1042',
        who: 'יוסי כהן',
        site: 'מגדל הרצליה',
        items: 7,
        sum: 1240,
        stage: 'new',
      );
      final back = Order.fromJson(o.toJson());
      expect(back.id, o.id);
      expect(back.who, o.who);
      expect(back.site, o.site);
      expect(back.items, o.items);
      expect(back.sum, o.sum);
      expect(back.stage, o.stage);
      expect(back.createdAt, isNull);
    });
  });
}
