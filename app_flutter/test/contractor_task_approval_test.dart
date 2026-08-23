// CROSS-PERSONA WIRING T2 (CONTRACTOR approval) — proof that the 👷‍♂️ CONTRACTOR
// approving/rejecting a submitted worker task is LIVE on the SINGLE unified
// `tasksProvider`. Per [[manager-is-platform-admin-not-hr]] the approval is the
// EMPLOYER's decision: Wave T2 surfaces it on the contractor (the main app's
// 📋 משימות screen), reading the SAME `pendingApprovalTasksProvider` queue the
// manager's אישורי-עובדים block reads (relocation = PARALLEL — the contractor
// GAINS the surface; the manager's block is left untouched for now).
//
// Approval reuses the existing engine verbs (FROZEN, no new method): the worker
// `submitForReview`s → the task is `review` and shows in
// `pendingApprovalTasksProvider`; the contractor `approve(id)` flips it `done`
// (and the W3 order-advance fold still fires for an order-linked task — a
// completed install moves its bound order live); `reject(id, reason:)` carries
// the manager/contractor's reason.
//
// Through a `ProviderContainer` (not a bare notifier) so `tasksProvider.notifier`
// carries its `_ref` — the order-advance fold + the reject-note side-map writer
// both need the provider graph + persistence (the worker_approval_engine_test.dart
// PURE-container idiom). Firebase-free: SharedPreferences is mocked.
import 'dart:convert';

import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('contractor task approval (shared live state, T2)', () {
    test(
        'a submitted task shows in the contractor approval queue → approve flips '
        'it done live AND drops it from the queue', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      String statusOf(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id).status;

      // Task 1 (רן) seeds `active` — the worker's current job, NOT yet pending.
      expect(statusOf(1), 'active');
      expect(
        c.read(pendingApprovalTasksProvider).any((t) => t.id == 1),
        isFalse,
        reason: 'an active task is not yet awaiting the contractor',
      );

      // WORKER submits task 1 → `review`.
      tasks.submitForReview(1);
      expect(statusOf(1), 'review');

      // CONTRACTOR side: it is now in the approval queue (the SAME
      // pendingApprovalTasksProvider the contractor surface reads), live.
      expect(
        c.read(pendingApprovalTasksProvider).map((t) => t.id),
        contains(1),
        reason: 'the contractor approval section shows the submitted task',
      );

      // CONTRACTOR approves (the employer's decision) → `done` reflects live and
      // it leaves the pending queue.
      tasks.approve(1);
      expect(statusOf(1), 'done',
          reason: 'the contractor approval is live on the shared engine');
      expect(
        c.read(pendingApprovalTasksProvider).any((t) => t.id == 1),
        isFalse,
        reason: 'an approved task is no longer pending',
      );
    });

    test(
        'approving an ORDER-LINKED task still fires the W3 order-advance fold '
        '(the contractor surface inherits the unified engine\'s fold)', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final tasks = c.read(tasksProvider.notifier);

      // Task 3 (איטום רצפת מקלחת) seeds `review`, bound to order BS-1040 at
      // stage `ready` — so it is already in the contractor's approval queue.
      expect(
        c.read(tasksProvider).firstWhere((t) => t.id == 3).status,
        'review',
      );
      expect(c.read(pendingApprovalTasksProvider).map((t) => t.id), contains(3),
          reason: 'the seeded review task is pending the contractor');
      String orderStage() => c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == 'BS-1040')
          .stage;
      expect(orderStage(), 'ready');

      // CONTRACTOR approves the linked install → task `done` AND the bound order
      // advances ready → pickup on the shared engine (the fold still fires).
      tasks.approve(3);
      expect(
        c.read(tasksProvider).firstWhere((t) => t.id == 3).status,
        'done',
      );
      expect(orderStage(), 'pickup',
          reason: 'the contractor approval advanced the order-linked task\'s '
              'order one stage (the unified engine\'s W3 fold)');
      expect(c.read(pendingApprovalTasksProvider).any((t) => t.id == 3), isFalse);
    });

    test('reject carries the reason (review → rejected + the reason is recorded)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final tasks = c.read(tasksProvider.notifier);
      String statusOf(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id).status;

      // A worker submits task 1 → `review` (pending the contractor).
      tasks.submitForReview(1);
      expect(statusOf(1), 'review');
      expect(c.read(pendingApprovalTasksProvider).map((t) => t.id), contains(1));

      // CONTRACTOR rejects WITH a reason → back to `rejected` (the worker can
      // re-submit) and it leaves the pending queue.
      tasks.reject(1, reason: 'חסר חומר');
      expect(statusOf(1), 'rejected',
          reason: 'a rejected task bounces back to the worker');
      expect(c.read(pendingApprovalTasksProvider).any((t) => t.id == 1), isFalse,
          reason: 'a rejected task is no longer pending');

      // The reason CARRIES: reject(reason:) mirrors a non-empty reason into the
      // bs.task-reject-note.v1 side-map (the reports tab's "דחיות + סיבה"
      // reader) — the observable proof the reason was recorded, not dropped.
      await _settle();
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTaskRejectNoteSideMapKey);
      expect(raw, isNotNull,
          reason: 'reject with a reason writes the reject-note side-map');
      final m = jsonDecode(raw!) as Map<String, dynamic>;
      expect(m['1'], 'חסר חומר',
          reason: 'the contractor\'s rejection reason is recorded for task 1');
    });
  });
}
