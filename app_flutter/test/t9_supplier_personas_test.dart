import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T9 — supplier-side persona role-apps (🏪 חנות + 🛵 שליח). Guards the verbatim
/// SYS_ORDERS seed + supporting tables (proto 06 §1/§7), and the shared
/// store↔courier advance engine — now UNIFIED onto the manager's
/// `ordersEngineProvider`, so a store/courier advance is visible to the manager
/// live (one source of truth). Also checks both screens render real content. R8.

/// A container whose shared engine does NOT touch SharedPreferences, so unit
/// tests stay deterministic. The store/courier `sysOrdersProvider` is a live
/// view of this same engine.
ProviderContainer _container() => ProviderContainer(
  overrides: [
    ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
  ],
);

SysOrder _sys(ProviderContainer c, String id) =>
    c.read(sysOrdersProvider).firstWhere((o) => o.id == id);
String _eng(ProviderContainer c, String id) =>
    c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

void main() {
  group('SYS_ORDERS seed + tables (verbatim, R8)', () {
    test('4 demo orders, verbatim id/who/site/stage/lines', () {
      expect(kSysOrdersSeed.length, 4);
      expect(
        kSysOrdersSeed.map((o) => o.id),
        ['BS-1042', 'BS-1041', 'BS-1040', 'BS-1039'],
      );
      expect(kSysOrdersSeed[0].who, 'יוסי כהן');
      expect(kSysOrdersSeed[0].site, 'מגדל הרצליה');
      expect(kSysOrdersSeed[0].stage, OrderStage.newOrder);
      expect(kSysOrdersSeed[1].stage, OrderStage.preparing);
      expect(kSysOrdersSeed[2].stage, OrderStage.ready);
      expect(kSysOrdersSeed[3].stage, OrderStage.transit);
      expect(kSysOrdersSeed[0].lines.first.name, 'ברז לכיור');
      expect(kSysOrdersSeed[0].lines.first.qty, 2);
    });

    test('STORES / HAUL_TYPES / portal tables verbatim', () {
      expect(kStores.map((s) => s.name), [
        'מחסני אינסטלציה תל-אביב',
        'ספקי סניטריה השרון',
        'חומרי בניין הרצליה',
      ]);
      expect(kHaulTypes.map((h) => h.name), ['משלוח קטן', 'טנדר', 'משאית']);
      expect(kDistZones.length, 4);
      expect(kBulkTiers.map((b) => b.discount), [0, 5, 9, 14]);
      expect(kFleet.first.driver, 'אבי');
      expect(kOrderStageLabel[OrderStage.delivered], 'נמסר ✓');
    });
  });

  group('shared engine — store ↔ courier ↔ manager, ONE source of truth', () {
    test('store advances new→preparing→ready→pickup, then stops', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);
      n.storeAdvance('BS-1042');
      expect(_sys(c, 'BS-1042').stage, OrderStage.preparing);
      n.storeAdvance('BS-1042');
      expect(_sys(c, 'BS-1042').stage, OrderStage.ready);
      n.storeAdvance('BS-1042'); // hand off to courier (ready→pickup)
      expect(_sys(c, 'BS-1042').stage, OrderStage.pickup);
      n.storeAdvance('BS-1042'); // courier owns it from here — no-op
      expect(_sys(c, 'BS-1042').stage, OrderStage.pickup);
    });

    test('a store advance is visible to the MANAGER live (unified engine)', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(_eng(c, 'BS-1042'), 'new');
      c.read(sysOrdersProvider.notifier).storeAdvance('BS-1042');
      // The very same order the manager dashboard reads is now 'preparing'.
      expect(_eng(c, 'BS-1042'), 'preparing');
    });

    test('courier advances pickup→transit→delivered after the store hands off', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);
      // BS-1040 is seeded `ready`; the courier does NOT own ready→pickup now (the
      // store hands off), so courierAdvance on `ready` is a no-op.
      n.courierAdvance('BS-1040'); // no-op on ready
      expect(_sys(c, 'BS-1040').stage, OrderStage.ready);
      n.storeAdvance('BS-1040'); // store hands off: ready→pickup
      expect(_sys(c, 'BS-1040').stage, OrderStage.pickup);
      n.courierAdvance('BS-1040'); // pickup→transit (courier received it)
      expect(_sys(c, 'BS-1040').stage, OrderStage.transit);
      expect(_eng(c, 'BS-1040'), 'transit');
      n.courierAdvance('BS-1040'); // transit→delivered
      expect(_sys(c, 'BS-1040').stage, OrderStage.delivered);
      n.courierAdvance('BS-1040'); // no-op
      expect(_sys(c, 'BS-1040').stage, OrderStage.delivered);
    });

    test('a store-readied order becomes a courier job (cross-role)', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);
      expect(c.read(sysOrdersProvider).courierJobs('truck').any((o) => o.id == 'BS-1042'), isFalse);
      n.storeAdvance('BS-1042'); // preparing
      n.storeAdvance('BS-1042'); // ready
      expect(c.read(sysOrdersProvider).courierJobs('truck').any((o) => o.id == 'BS-1042'), isTrue);
    });

    test('vehicle gating: a small bike cannot carry a truck order', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(c.read(sysOrdersProvider).courierJobs('small').any((o) => o.id == 'BS-1040'), isFalse);
      expect(c.read(sysOrdersProvider).courierJobs('truck').any((o) => o.id == 'BS-1040'), isTrue);
    });

    test('simulate places a fresh new order through the shared engine', () {
      final c = _container();
      addTearDown(c.dispose);
      final before = c.read(sysOrdersProvider).length;
      final id = c.read(sysOrdersProvider.notifier).simulateIncomingOrder();
      final orders = c.read(sysOrdersProvider);
      expect(orders.length, before + 1);
      expect(orders.first.id, id);
      expect(orders.first.stage, OrderStage.newOrder);
      // It lands in the manager's engine too (contractor/store/manager share it).
      expect(c.read(ordersEngineProvider).any((o) => o.id == id), isTrue);
    });
  });

  testWidgets('store dashboard renders verbatim content + advances an order', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
        ],
        child: const MaterialApp(home: StoreDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('🏪 חנות ספק'), findsOneWidget);
    expect(find.text('שלום 👋'), findsOneWidget);
    expect(find.textContaining('מחסני אינסטלציה תל-אביב'), findsOneWidget);
    expect(find.textContaining('בבנייה'), findsNothing);

    // Orders tab → approve BS-1042 (new → preparing).
    await tester.tap(find.text('📥 הזמנות').first);
    await tester.pumpAndSettle();
    expect(find.text('📦 BS-1042'), findsOneWidget);
    expect(find.text('✓ אשר וקבל להכנה'), findsOneWidget);
    await tester.tap(find.text('✓ אשר וקבל להכנה'));
    await tester.pump();
    expect(find.text('📦 סמן כמוכן — העבר לשליח'), findsWidgets);
  });

  testWidgets('courier dashboard renders verbatim content', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
        ],
        child: const MaterialApp(home: CourierDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('🛵 שליח'), findsOneWidget);
    expect(find.text('שלום 🛵'), findsOneWidget);
    expect(find.text('הרכב שלי היום'), findsOneWidget);
    expect(find.text('משאית'), findsWidgets);
    // BS-1040 (ready, truck) is a truck job — but the store owns the hand-off,
    // so the courier sees it VIEW-ONLY (awaiting) until it is handed off (two-step).
    expect(find.text('📦 BS-1040'), findsOneWidget);
    expect(find.text('⏳ ממתין למסירה מהחנות'), findsWidgets);
    expect(find.textContaining('בבנייה'), findsNothing);
  });
}
