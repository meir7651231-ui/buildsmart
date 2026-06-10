// CROSS-PERSONA WIRING W3 (WORKER) — proof that "worker → manager" is LIVE.
// The 🦺 worker submits a task for approval, and the 👔 manager sees it pending
// and approves/rejects it — ALL on the SHARED `workerTasksProvider`. The approval
// bridge is the task status: `active`/`rejected` → (worker "שלח לאישור") `review`
// → (manager ✅ אשר) `done` / (manager ↩️ דחה) `rejected`.
//
// Three layers of proof:
//   1) PURE one-container: a worker submit makes the task pending in the manager's
//      `pendingApprovalTasksProvider`; the manager approves → `done` reflects live
//      on the worker's reading. Plus a linked task's approval `advance`s the bound
//      order on the SHARED orders engine (manager open-orders 4 → 3).
//   2) WIDGET worker side: the worker screen's "📸 שלח לאישור" button moves the
//      task to `review` on the engine (live).
//   3) WIDGET manager side: the manager's 🛠️ ניהול → 👷 אישורי עובדים section shows
//      the pending task and its ✅ אשר button approves it on the shared engine,
//      reflecting live (the count badge drops).

import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  group('worker tasks → manager approval (shared live state, W3)', () {
    test(
        'PURE — worker submit → manager sees it pending → manager approve → done '
        'reflects live (ONE container, no widgets)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(workerTasksProvider.notifier);

      // Seed: task 1 (worker רן) is `active` — the worker's current job. It is
      // NOT yet pending the manager's approval.
      String statusOf(int id) =>
          c.read(workerTasksProvider).firstWhere((t) => t.id == id).status;
      expect(statusOf(1), 'active');
      expect(
        c.read(pendingApprovalTasksProvider).any((t) => t.id == 1),
        isFalse,
        reason: 'an active task is not yet awaiting approval',
      );

      // WORKER submits task 1 for approval → `review` (📸 ממתין לאישור).
      tasks.submitForReview(1);
      expect(statusOf(1), 'review');

      // MANAGER side: the task is now in the approvals queue (a derivation over
      // the SAME provider) — the manager sees it pending, live.
      expect(
        c.read(pendingApprovalTasksProvider).map((t) => t.id),
        contains(1),
        reason: 'manager approvals view shows the worker-submitted task',
      );

      // MANAGER approves it → `done` (✅ אושר). The worker's own reading reflects
      // it live, and it leaves the pending queue.
      tasks.approve(1);
      expect(statusOf(1), 'done', reason: 'manager approval is live on worker');
      expect(
        c.read(pendingApprovalTasksProvider).any((t) => t.id == 1),
        isFalse,
        reason: 'an approved task is no longer pending',
      );
    });

    test('PURE — manager REJECT bounces a submitted task back to the worker '
        '(review → rejected), so the worker can re-submit', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      String statusOf(int id) =>
          c.read(workerTasksProvider).firstWhere((t) => t.id == id).status;

      c.read(workerTasksProvider.notifier).submitForReview(1); // active → review
      expect(statusOf(1), 'review');

      c.read(workerTasksProvider.notifier).reject(1); // manager rejects → back
      expect(statusOf(1), 'rejected');

      // The worker can submit it again (rejected is a submittable status).
      c.read(workerTasksProvider.notifier).submitForReview(1);
      expect(statusOf(1), 'review');
    });

    test('PURE — approving an ORDER-LINKED task also advances that order on the '
        'shared engine (manager open-orders 4 → 3 chain reflects live)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final tasks = c.read(workerTasksProvider.notifier);
      final orders = c.read(ordersEngineProvider.notifier);

      // Task 3 (איטום רצפת מקלחת) is seeded `review` and bound to BS-1040, which
      // starts at stage `ready`. 4 orders open.
      final linked =
          c.read(workerTasksProvider).firstWhere((t) => t.id == 3);
      expect(linked.status, 'review');
      expect(linked.orderId, 'BS-1040');
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      String orderStage() => c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == 'BS-1040')
          .stage;
      expect(orderStage(), 'ready');

      // Manager approves the linked install → task `done` AND the bound order
      // advances ready → pickup on the SHARED engine, live.
      tasks.approve(3);
      expect(
        c.read(workerTasksProvider).firstWhere((t) => t.id == 3).status,
        'done',
      );
      expect(orderStage(), 'pickup', reason: 'approval advanced the linked order');

      // Drive that order to delivered (the rest of the flow) and the manager's
      // live open-orders count falls 4 → 3 — the cross-engine link is live.
      orders
        ..advance('BS-1040') // pickup → transit
        ..advance('BS-1040'); // transit → delivered
      expect(orderStage(), 'delivered');
      expect(c.read(managerAnalyticsProvider).openOrders, 3);
    });

    testWidgets(
        'WIDGET worker — the "📸 שלח לאישור" button submits the task to review '
        'on the shared engine', (t) async {
      SharedPreferences.setMockInitialValues({
      // #65 gate: seed a board session so the board (not the gate) renders.
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
      await t.binding.setSurfaceSize(const Size(440, 1000));
      addTearDown(() => t.binding.setSurfaceSize(null));

      late ProviderContainer c;
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: Builder(
              builder: (context) {
                c = ProviderScope.containerOf(context);
                return const WorkerAppScreen();
              },
            ),
          ),
        ),
      );
      await settle(t);

      // רן (worker 0) is selected by default; his task 1 is `active` → its card
      // carries the keyed submit button.
      expect(find.text('התקנת קו מים חם — חדר רחצה'), findsOneWidget);
      final submit = find.byKey(const ValueKey('submit-1'));
      expect(submit, findsOneWidget);

      await t.tap(submit);
      await settle(t);

      // The shared engine moved task 1 active → review.
      expect(
        c.read(workerTasksProvider).firstWhere((x) => x.id == 1).status,
        'review',
      );
      // It is now in the manager's approvals queue (same provider).
      expect(c.read(pendingApprovalTasksProvider).map((x) => x.id), contains(1));
    });

    testWidgets(
        'WIDGET manager — the 👷 אישורי עובדים section shows a submitted task and '
        'its ✅ אשר approves it live (badge drops)', (t) async {
      // #65 gate: seed a manager session so the board (not the gate) renders.
      SharedPreferences.setMockInitialValues({
        'bs.board-auth.v1':
            '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
      });
      await t.binding.setSurfaceSize(const Size(440, 1000));
      addTearDown(() => t.binding.setSurfaceSize(null));

      late ProviderContainer c;
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: Builder(
              builder: (context) {
                c = ProviderScope.containerOf(context);
                return const ManagerDashboardScreen();
              },
            ),
          ),
        ),
      );
      await settle(t);

      // A worker submits task 1 (off the SAME shared engine, as if from the
      // worker screen) → it becomes pending for the manager.
      c.read(workerTasksProvider.notifier).submitForReview(1);
      await settle(t);

      // Open the 🛠️ ניהול tab, then the 👷 אישורי עובדים section.
      await t.tap(find.text('ניהול').first);
      await settle(t);
      // The section header is present (with a count badge — task 3 seed + task 1
      // submitted = 2 pending).
      expect(find.text('אישורי עובדים'), findsOneWidget);
      expect(c.read(pendingApprovalTasksProvider).length, 2);

      await t.tap(find.text('אישורי עובדים'));
      await settle(t);

      // The submitted task renders in the queue with an approve button.
      expect(find.text('התקנת קו מים חם — חדר רחצה'), findsOneWidget);
      final approve = find.byKey(const ValueKey('approve-1'));
      expect(approve, findsOneWidget);
      await t.ensureVisible(approve);
      await settle(t);
      await t.tap(approve);
      await settle(t);

      // The manager's approval is LIVE: task 1 is `done` on the shared engine,
      // and the pending queue dropped to just the remaining seed task (3).
      expect(
        c.read(workerTasksProvider).firstWhere((x) => x.id == 1).status,
        'done',
      );
      expect(c.read(pendingApprovalTasksProvider).map((x) => x.id), [3]);
    });
  });
}
