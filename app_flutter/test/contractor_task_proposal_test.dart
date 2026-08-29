// CROSS-PERSONA WIRING G1a (WORKER PROPOSAL — STATE) — the REVERSE of T2: here
// the 🦺 WORKER authors their own next job, which enters a NEW `'proposed'`
// status awaiting the 👷‍♂️ CONTRACTOR's approval (`proposed` → `active`), the
// mirror of contractor→worker authoring. Proof the proposal lifecycle is LIVE
// on the SINGLE unified `tasksProvider`, isolated from the `'review'`→`'done'`
// COMPLETION lifecycle (the two must never collide).
//
// Exercises the additive G1a engine API on `TasksNotifier`:
//   proposeTask({name, detail, days, steps, worker, assignedWorkerUid, employerId}) → int
//   approveProposal(int)   — proposed → active (+ worker bell)
//   rejectProposal(int, {reason}) — proposed → rejected (+ reason side-map + bell)
// and the contractor's proposal-approval queue `pendingProposalsProvider`
// (sibling of `pendingApprovalTasksProvider`, projecting the `'proposed'` bucket).
//
// Through a `ProviderContainer` (not a bare notifier) so `tasksProvider.notifier`
// carries its `_ref` — the worker-bell (`workerNotifsProvider`) + the reject-note
// side-map writer both need the provider graph + persistence (mirrors the harness
// in contractor_task_approval_test.dart). Firebase-free: SharedPreferences mocked.
import 'dart:convert';

import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('contractor task proposal (worker → contractor, shared live state, G1a)',
      () {
    test(
        'proposeTask mints a `proposed` task authored by the worker → it shows '
        'in the contractor proposal queue (HEADLINE: worker-proposed → '
        'contractor-sees-live)', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      TaskItem byId(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id);

      // Clean verbatim seed: ids 1..5. No worker-proposed task exists yet.
      expect(c.read(tasksProvider).map((t) => t.id), [1, 2, 3, 4, 5],
          reason: 'the verbatim §6 seed is 5 tasks (אין המצאות)');
      expect(c.read(pendingProposalsProvider), isEmpty,
          reason: 'no proposal exists on a clean seed');

      // The WORKER proposes their OWN next job (worker 1 = עומר, uid-omer),
      // stamping the employer they propose it to (server-ready identity).
      final id = tasks.proposeTask(
        name: 'התקנת מדף כלים',
        worker: 1,
        assignedWorkerUid: 'u-omer',
        employerId: 'c1',
      );

      // A FRESH id past the seed max (max(1..5)+1 = 6).
      expect(id, 6, reason: 'proposeTask mints max(existing ids)+1');

      // The task is on the single unified tasksProvider, in the NEW `proposed`
      // bucket, authored by the worker.
      final t = byId(id);
      expect(t.status, 'proposed',
          reason: 'a worker proposal enters the new proposed status');
      expect(t.createdBy, 'worker',
          reason: 'proposeTask stamps the worker as the author');
      expect(t.worker, 1, reason: 'auto-addressed to the proposing worker');
      expect(t.assignedWorkerUid, 'u-omer');
      expect(t.employerId, 'c1',
          reason: 'the worker stamps the employer they propose the job to');

      // CONTRACTOR side: it is now in the proposal-approval queue (the SAME
      // pendingProposalsProvider the contractor surface will read), live.
      expect(c.read(pendingProposalsProvider).map((t) => t.id), contains(id),
          reason: 'the contractor proposal queue shows the worker proposal');
      // …and it carries the employerId so the G1c contractor UI can scope it.
      expect(
        c.read(pendingProposalsProvider).firstWhere((t) => t.id == id).employerId,
        'c1',
      );

      // A worker proposal must NOT leak into the manager/contractor COMPLETION
      // queue (pendingApprovalTasksProvider projects `review`, not `proposed`).
      expect(c.read(pendingApprovalTasksProvider).any((t) => t.id == id), isFalse,
          reason: 'a proposal is not a completion awaiting approval');
    });

    test(
        'approveProposal flips proposed → active live, drops it from the proposal '
        'queue, the worker view shows it active (bidirectional), and a worker '
        'bell fires', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      String statusOf(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id).status;

      final id = tasks.proposeTask(
        name: 'התקנת מדף כלים',
        worker: 1,
        assignedWorkerUid: 'u-omer',
        employerId: 'c1',
      );
      expect(statusOf(id), 'proposed');
      expect(c.read(pendingProposalsProvider).map((t) => t.id), contains(id));

      // CONTRACTOR approves the proposal → it enters the worker's ACTIVE queue.
      tasks.approveProposal(id);
      expect(statusOf(id), 'active',
          reason: 'an approved proposal becomes the worker\'s active task');

      // It LEAVES the proposal queue (no longer proposed).
      expect(c.read(pendingProposalsProvider).any((t) => t.id == id), isFalse,
          reason: 'an approved proposal is no longer pending the contractor');

      // BIDIRECTIONAL: the worker's OWN view (the same tasksProvider, scoped by
      // the int worker the worker board filters on) shows it active.
      final omerView =
          c.read(tasksProvider).where((t) => t.worker == 1).toList();
      expect(omerView.firstWhere((t) => t.id == id).status, 'active',
          reason: 'the worker who proposed it now sees it as active work');

      // A worker bell fired — the same mechanism approve() uses
      // (workerNotifsProvider.addForWorker, keyed by the int worker → fanned
      // out to kWorkerUsernames[1] = ['omer']). body == the task name.
      await _settle();
      final feed = c.read(workerNotifsProvider)['omer'] ?? const [];
      expect(feed, isNotEmpty,
          reason: 'approving the proposal notifies the proposing worker');
      expect(feed.first.body, 'התקנת מדף כלים',
          reason: 'the bell body carries the task name (mirrors approve)');
    });

    test(
        'rejectProposal flips proposed → rejected + records the reason in the '
        'reject-note side-map (mirrors reject)', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      String statusOf(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id).status;

      final id = tasks.proposeTask(
        name: 'התקנת מדף כלים',
        worker: 1,
        assignedWorkerUid: 'u-omer',
        employerId: 'c1',
      );
      expect(statusOf(id), 'proposed');

      // CONTRACTOR rejects the proposal WITH a reason.
      tasks.rejectProposal(id, reason: 'לא נדרש כרגע');
      expect(statusOf(id), 'rejected',
          reason: 'a rejected proposal bounces to the rejected bucket');
      expect(c.read(pendingProposalsProvider).any((t) => t.id == id), isFalse,
          reason: 'a rejected proposal is no longer pending');

      // The reason CARRIES — mirrored into the bs.task-reject-note.v1 side-map
      // (the reports tab's "דחיות + סיבה" reader), exactly like reject().
      await _settle();
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTaskRejectNoteSideMapKey);
      expect(raw, isNotNull,
          reason: 'rejectProposal with a reason writes the reject-note side-map');
      final m = jsonDecode(raw!) as Map<String, dynamic>;
      expect(m['$id'], 'לא נדרש כרגע',
          reason: 'the contractor\'s rejection reason is recorded');
    });

    test(
        'GUARD: the proposal lifecycle and the completion lifecycle do NOT '
        'collide (approveProposal only flips `proposed`; approve only flips '
        '`review`)', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      String statusOf(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id).status;

      // Seed truth: task 1 = active, task 3 = review (a COMPLETION awaiting the
      // contractor). A fresh proposal (id 6) = proposed.
      expect(statusOf(1), 'active');
      expect(statusOf(3), 'review');
      final pid = tasks.proposeTask(name: 'הצעה', worker: 1);
      expect(statusOf(pid), 'proposed');

      // approveProposal on a `review` task → NO-OP (it guards `proposed`).
      tasks.approveProposal(3);
      expect(statusOf(3), 'review',
          reason: 'approveProposal must not touch a completion-review task');

      // approveProposal on a `pending` task → NO-OP. (Promote task 1's queued
      // sibling to pending via the seed; task 2 seeds pending for רן.)
      expect(statusOf(2), 'pending');
      tasks.approveProposal(2);
      expect(statusOf(2), 'pending',
          reason: 'approveProposal must not touch a pending task');

      // approve (COMPLETION) on a `proposed` task → NO-OP (it guards `review`).
      tasks.approve(pid);
      expect(statusOf(pid), 'proposed',
          reason: 'the completion approve must not flip a proposal');

      // reject (COMPLETION) on a `proposed` task → NO-OP (it guards `review`).
      tasks.reject(pid, reason: 'x');
      expect(statusOf(pid), 'proposed',
          reason: 'the completion reject must not flip a proposal');

      // The proposal still flips correctly with its OWN verb.
      tasks.approveProposal(pid);
      expect(statusOf(pid), 'active',
          reason: 'approveProposal flips the proposal it owns');
    });

    test(
        'back-compat: an old persisted task with NO createdBy decodes as \'\' '
        'and does not crash; existing seed/createTask tasks are unaffected',
        () async {
      // A pre-G1a overlay payload for task 1 — no `createdBy` key (the field
      // did not exist). It must decode cleanly with createdBy == ''.
      SharedPreferences.setMockInitialValues({
        kTasksScreenKey: jsonEncode({
          '1': {'status': 'active', 'note': ''},
        }),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Touch the notifier so the async _load runs, then settle.
      c.read(tasksProvider.notifier);
      await _settle();

      final t1 = c.read(tasksProvider).firstWhere((t) => t.id == 1);
      expect(t1.createdBy, '',
          reason: 'a pre-G1a payload decodes createdBy as the empty default');
      expect(t1.status, 'active', reason: 'the rest of the overlay still loads');

      // A contractor-created task is stamped 'contractor' (createTask unchanged).
      final newId = c.read(tasksProvider.notifier).createTask(
            name: 'התקנת כיור',
            worker: 0,
            employerId: 'c1',
          );
      expect(
        c.read(tasksProvider).firstWhere((t) => t.id == newId).createdBy,
        'contractor',
        reason: 'createTask now stamps the contractor as the author',
      );
      expect(
        c.read(tasksProvider).firstWhere((t) => t.id == newId).status,
        'pending',
        reason: 'createTask behavior is unchanged (still mints pending)',
      );
    });
  });
}
