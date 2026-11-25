// #103 — a courier's «נמסר» confirmation must not be lost when the sheet is
// dismissed while the delivery-clock write is still in flight.
//
// Before the fix the sheet did: stampCourier → await stampCourierClock →
// `if (!context.mounted) return;` → courierAdvance. Dismissing the sheet during
// the await (drag-down, back, rotate) skipped the advance: the delivered stamp
// was on disk but the order stayed «בדרך», with no reward and no bell.
//
// We pump the courier delivery-detail sheet over a test engine seeded with one
// `transit` order and a clock repository whose load() blocks on a Completer.
// Tap «✅ נמסר ללקוח», confirm «נמסר», REMOVE the sheet from the tree while the
// clock write is pending, release the write, and assert the order reached
// `delivered` on the shared engine.

import 'dart:async';

import 'package:buildsmart/data/repositories/courier_clock_repository.dart';
import 'package:buildsmart/screens/courier_delivery_detail_sheet.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clock repository whose load() parks until the test releases it — the
/// window in which a real Firestore/disk write is still in flight.
class _BlockingClockRepo implements CourierClockRepository {
  final gate = Completer<void>();
  Map<String, dynamic>? saved;

  @override
  String get uid => 'courier-test';

  @override
  Future<Map<String, dynamic>> load() async {
    await gate.future;
    return <String, dynamic>{};
  }

  @override
  Future<void> save(Map<String, dynamic> entries) async {
    saved = entries;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _order = Order(
  id: 'BS-2103',
  who: 'דנה לוי',
  site: 'פרויקט רמת גן',
  items: 3,
  sum: 480,
  stage: 'transit',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    '#103 · dismissing the sheet mid clock-write still delivers the order',
    (tester) async {
      final repo = _BlockingClockRepo();
      final container = ProviderContainer(
        overrides: [
          ordersEngineProvider.overrideWith(
            (ref) => OrdersEngineNotifier(persist: false, seed: [_order]),
          ),
          courierClockRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final showSheet = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: ValueListenableBuilder<bool>(
                  valueListenable: showSheet,
                  builder: (_, show, __) => show
                      ? SingleChildScrollView(
                          child: CourierDeliveryDetailSheet(orderId: _order.id),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // «✅ נמסר ללקוח» → confirm dialog → «נמסר».
      final deliver = find.text('✅ נמסר ללקוח');
      expect(deliver, findsOneWidget);
      await tester.ensureVisible(deliver);
      await tester.tap(deliver);
      await tester.pumpAndSettle();
      await tester.tap(find.text('נמסר'));
      await tester.pump(); // dialog pops → _advance resumes → parks on load()

      String stage() => container
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == _order.id)
          .stage;
      expect(stage(), 'transit', reason: 'clock write still in flight');

      // The sheet goes away while the write is pending (drag-down / back).
      showSheet.value = false;
      await tester.pumpAndSettle();
      expect(find.byType(CourierDeliveryDetailSheet), findsNothing);

      // Release the write — the advance must still land.
      repo.gate.complete();
      await tester.pumpAndSettle();

      expect(repo.saved, isNotNull, reason: 'the delivered stamp was written');
      expect(
        stage(),
        'delivered',
        reason: 'a stamped delivery must not stay «בדרך» (#103)',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
