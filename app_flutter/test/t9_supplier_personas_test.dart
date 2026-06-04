import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T9 — supplier-side persona role-apps (🏪 חנות + 🛵 שליח). Guards the verbatim
/// SYS_ORDERS seed + supporting tables (proto 06 §1/§7), the shared store↔courier
/// advance engine, and that both screens render real content (not "בבנייה"). R8.
OrderStage _stage(SysOrdersNotifier n, String id) =>
    n.state.firstWhere((o) => o.id == id).stage;

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

  group('shared order engine (store ↔ courier sync)', () {
    test('store advances new→preparing→ready, then stops', () {
      final n = SysOrdersNotifier();
      n.storeAdvance('BS-1042');
      expect(_stage(n, 'BS-1042'), OrderStage.preparing);
      n.storeAdvance('BS-1042');
      expect(_stage(n, 'BS-1042'), OrderStage.ready);
      n.storeAdvance('BS-1042'); // courier owns it from here — no-op
      expect(_stage(n, 'BS-1042'), OrderStage.ready);
    });

    test('courier advances ready→pickup→transit→delivered', () {
      final n = SysOrdersNotifier();
      n.courierAdvance('BS-1040'); // ready→pickup
      expect(_stage(n, 'BS-1040'), OrderStage.pickup);
      n.courierAdvance('BS-1040'); // pickup→transit
      expect(_stage(n, 'BS-1040'), OrderStage.transit);
      n.courierAdvance('BS-1040'); // transit→delivered
      expect(_stage(n, 'BS-1040'), OrderStage.delivered);
      n.courierAdvance('BS-1040'); // no-op
      expect(_stage(n, 'BS-1040'), OrderStage.delivered);
    });

    test('a store-readied order becomes a courier job (cross-role)', () {
      final n = SysOrdersNotifier();
      expect(n.state.courierJobs('truck').any((o) => o.id == 'BS-1042'), isFalse);
      n.storeAdvance('BS-1042'); // preparing
      n.storeAdvance('BS-1042'); // ready
      expect(n.state.courierJobs('truck').any((o) => o.id == 'BS-1042'), isTrue);
    });

    test('vehicle gating: a small bike cannot carry a truck order', () {
      final n = SysOrdersNotifier();
      expect(n.state.courierJobs('small').any((o) => o.id == 'BS-1040'), isFalse);
      expect(n.state.courierJobs('truck').any((o) => o.id == 'BS-1040'), isTrue);
    });

    test('simulate prepends a fresh new order', () {
      final n = SysOrdersNotifier();
      final before = n.state.length;
      final id = n.simulateIncomingOrder();
      expect(n.state.length, before + 1);
      expect(n.state.first.id, id);
      expect(n.state.first.stage, OrderStage.newOrder);
    });
  });

  testWidgets('store dashboard renders verbatim content + advances an order', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: StoreDashboardScreen())),
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
      const ProviderScope(child: MaterialApp(home: CourierDashboardScreen())),
    );
    await tester.pump();

    expect(find.text('🛵 שליח'), findsOneWidget);
    expect(find.text('שלום 🛵'), findsOneWidget);
    expect(find.text('הרכב שלי היום'), findsOneWidget);
    expect(find.text('משאית'), findsWidgets);
    // BS-1040 (ready, truck) is a job for the default truck vehicle.
    expect(find.text('📦 BS-1040'), findsOneWidget);
    expect(find.text('📦 אספתי מהחנות'), findsWidgets);
    expect(find.textContaining('בבנייה'), findsNothing);
  });
}
