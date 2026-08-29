// ⏱️ Guard tests for the #85ו task clock — lib/state/tasks_engine.dart.
// 'התחל עבודה' ([TasksNotifier.startWork]) stamps [TaskItem.startedAt]
// (one-shot, worker-owned statuses only); the worker submit
// ([TasksNotifier.submitForReview]) stamps [TaskItem.completedAt] so the
// elapsed duration is positive; a manager reject clears completedAt but KEEPS
// startedAt (one honest elapsed number through a fix cycle); the stamps
// persist via the bs.tasks-screen.v1 overlay AND mirror into the
// bs.task-clock.v1 side-map that worker_reports_tab.dart reads read-only.
// Engine-only tests use TasksNotifier(persist: false) — the
// tasks_smart_project_projects_test.dart pattern; persistence tests go through
// the real lazy tasksProvider (read before settle).
import 'dart:convert';

import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startWork stamps startedAt · submit stamps completedAt · duration > 0',
      () async {
    final n = TasksNotifier(persist: false);
    TaskItem t1() => n.state.firstWhere((x) => x.id == 1);

    expect(t1().startedAt, isNull,
        reason: 'the verbatim seed carries NO clock (אין המצאות)');
    expect(t1().completedAt, isNull);

    n.startWork(1); // task 1 seeds 'active' — startable
    expect(t1().startedAt, isNotNull,
        reason: 'startWork must stamp the start instant');
    expect(t1().completedAt, isNull,
        reason: 'the clock is open until the worker submits');

    // Make the work measurably long so the elapsed duration is positive.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    n.submitForReview(1, note: 'בוצע');

    final done = t1();
    expect(done.status, 'review');
    expect(done.completedAt, isNotNull,
        reason: 'the submit must stamp the completion instant');
    expect(done.completedAt!.isAfter(done.startedAt!), true,
        reason: 'completedAt − startedAt must be a positive duration');
    expect(taskClockLabel(done), isNotNull,
        reason: 'a stamped task renders an elapsed label');
  });

  test('startWork guards — worker-owned statuses only, and one-shot', () {
    final n = TasksNotifier(persist: false);
    DateTime? startOf(int id) =>
        n.state.firstWhere((x) => x.id == id).startedAt;

    n.startWork(2); // pending — not startable
    expect(startOf(2), isNull, reason: 'a queued task has no clock yet');
    n.startWork(3); // review — not startable
    expect(startOf(3), isNull, reason: 'a submitted task cannot restart');
    n.startWork(999); // unknown id — must not throw
    expect(n.state.length, 5);

    n.startWork(1); // active — startable
    final first = startOf(1);
    expect(first, isNotNull);
    n.startWork(1); // second call must NOT restart the clock
    expect(startOf(1), first,
        reason: 'one-shot: the original stamp survives a re-tap');
  });

  test('reject clears completedAt but keeps startedAt (clock keeps counting)',
      () async {
    final n = TasksNotifier(persist: false);
    n.startWork(1);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    n.submitForReview(1);
    final started = n.state.firstWhere((x) => x.id == 1).startedAt;
    expect(n.state.firstWhere((x) => x.id == 1).completedAt, isNotNull);

    n.reject(1);
    final r = n.state.firstWhere((x) => x.id == 1);
    expect(r.status, 'rejected');
    expect(r.completedAt, isNull,
        reason: 'back in work — the completion stamp is cleared');
    expect(r.startedAt, started,
        reason: 'one honest elapsed number through the fix cycle');

    // 'rejected' is a startable status, but the one-shot guard holds.
    n.startWork(1);
    expect(n.state.firstWhere((x) => x.id == 1).startedAt, started);

    // The fix-resubmit stamps a NEW completion.
    n.submitForReview(1);
    final again = n.state.firstWhere((x) => x.id == 1);
    expect(again.completedAt, isNotNull);
    expect(again.completedAt!.isAfter(again.startedAt!), true);
  });

  test(
      'persist round-trip — stamps survive a restart AND mirror into the '
      'bs.task-clock.v1 side-map', () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    c1.read(tasksProvider.notifier).startWork(1);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    c1.read(tasksProvider.notifier).submitForReview(1, note: 'בוצע');
    await _settle(); // let _persist() finish before "shutting down"

    // ② the read-only side-map mirror for worker_reports_tab.dart.
    final prefs = await SharedPreferences.getInstance();
    final sideRaw = prefs.getString(kTaskClockSideMapKey);
    expect(sideRaw, isNotNull,
        reason: 'the engine must mirror clock stamps into the side-map');
    final side = jsonDecode(sideRaw!) as Map<String, dynamic>;
    final entry = side['1'] as Map<String, dynamic>?;
    expect(entry, isNotNull);
    expect(DateTime.tryParse('${entry!['startedAt']}'), isNotNull);
    expect(DateTime.tryParse('${entry['completedAt']}'), isNotNull);
    expect(side.containsKey('2'), false,
        reason: 'tasks with no stamp are omitted — honest "no measurement"');
    c1.dispose();

    // ① fresh container = fresh notifier → must reload the overlay (lazy —
    // touch the provider so _load() actually starts).
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(tasksProvider);
    await _settle();

    final t = c2.read(tasksProvider).firstWhere((x) => x.id == 1);
    expect(t.status, 'review',
        reason: 'the submitted status must survive a restart');
    expect(t.startedAt, isNotNull);
    expect(t.completedAt, isNotNull);
    expect(t.completedAt!.isAfter(t.startedAt!), true,
        reason: 'the restored duration stays positive');
  });

  test('taskClockLabel — null without a clock · natural Hebrew durations', () {
    final base = TasksNotifier(persist: false).state.first;
    expect(taskClockLabel(base), isNull,
        reason: 'no clock → no label (no invented timing)');

    final start = DateTime(2026, 6, 10, 8);
    TaskItem at(Duration d) =>
        base.copyWith(startedAt: start, completedAt: start.add(d));

    expect(taskClockLabel(at(const Duration(seconds: 30))), 'פחות מדקה');
    expect(taskClockLabel(at(const Duration(minutes: 45))), '45 דק׳');
    expect(taskClockLabel(at(const Duration(hours: 2))), '2 שע׳');
    expect(
        taskClockLabel(at(const Duration(hours: 2, minutes: 5))), '2 שע׳ 5 דק׳');
    expect(taskClockLabel(at(const Duration(days: 1, hours: 3))),
        '1 ימים 3 שע׳');
    // a clock that went backwards (clock skew) clamps to zero, never negative.
    expect(taskClockLabel(at(const Duration(minutes: -10))), 'פחות מדקה');
  });
}
