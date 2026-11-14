// Courier delivery detail sheet — double-tap race on "📦 אספתי מהחנות".
//
// The button's closure captures the order SNAPSHOT it was built from. Its
// advance awaits the courier-clock stamp before mutating, so a fast second tap
// (before the rebuild) used to run with the stale `pickup` snapshot and advance
// AGAIN: pickup → transit → delivered, skipping the "אישור מסירה?" confirmation
// entirely. The fix: a live-stage guard + in-flight lock in the sheet and a
// compare-and-set `courierAdvance(id, from:)` in the shared notifier.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_delivery_detail_sheet.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = 'BS-1042';

Order _order(String stage) => Order(
  id: _id,
  who: 'יוסי כהן',
  site: 'מגדל הרצליה',
  items: 7,
  sum: 1240,
  stage: stage,
);

Future<ProviderContainer> _pump(WidgetTester tester, String stage) async {
  final container = ProviderContainer(
    overrides: [
      ordersEngineProvider.overrideWith(
        (ref) => OrdersEngineNotifier(persist: false, seed: [_order(stage)]),
      ),
    ],
  );
  addTearDown(container.dispose);
  // Tall viewport so the action button is on-screen (hit-testable).
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CourierDeliveryDetailSheet(orderId: _id),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

String _stage(ProviderContainer c) =>
    c.read(ordersEngineProvider).firstWhere((o) => o.id == _id).stage;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'double-tap on "אספתי מהחנות" advances ONE step (pickup→transit), '
    'never skipping to delivered',
    (tester) async {
      final c = await _pump(tester, 'pickup');
      final btn = find.text('📦 אספתי מהחנות');
      expect(btn, findsOneWidget);

      // Two taps with no frame in between — the second lands on the SAME
      // (not yet rebuilt) button holding the stale `pickup` snapshot.
      await tester.tap(btn);
      await tester.tap(btn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        _stage(c),
        'transit',
        reason: 'the stale second tap must not deliver without confirmation',
      );
      // The delivery confirmation is still ahead — nothing was skipped.
      expect(find.text('✅ נמסר ללקוח'), findsOneWidget);
    },
  );

  testWidgets('a single tap still advances pickup → transit', (tester) async {
    final c = await _pump(tester, 'pickup');
    await tester.tap(find.text('📦 אספתי מהחנות'));
    await tester.pumpAndSettle();
    expect(_stage(c), 'transit');
  });

  group('courierAdvance(id, from:) — compare-and-set', () {
    test('no-op when the live stage moved on; advances when it matches', () {
      final c = ProviderContainer(
        overrides: [
          ordersEngineProvider.overrideWith(
            (ref) =>
                OrdersEngineNotifier(persist: false, seed: [_order('pickup')]),
          ),
        ],
      );
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);

      n.courierAdvance(_id, from: OrderStage.pickup);
      expect(_stage(c), 'transit');
      // Stale caller still believes `pickup` → must not deliver.
      n.courierAdvance(_id, from: OrderStage.pickup);
      expect(_stage(c), 'transit');
      n.courierAdvance(_id, from: OrderStage.transit);
      expect(_stage(c), 'delivered');
      // Legacy call without `from` keeps its old behaviour (terminal no-op).
      n.courierAdvance(_id);
      expect(_stage(c), 'delivered');
    });
  });
}
