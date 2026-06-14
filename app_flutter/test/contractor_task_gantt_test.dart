// 📅 TASKS → GANTT (Wave G2a — STATE + PURE layout). The user's decision:
// "gantt integrated into the tasks engine" — the §6 tasks ARE the schedule. Two
// halves:
//   1. STATE: the additive OPTIONAL `TaskItem.scheduledStart` anchor — minted by
//      createTask/proposeTask, set by editTask, and round-tripped through the
//      SharedPreferences overlay EXACTLY like startedAt/completedAt (ISO-8601,
//      write-when-non-null). A pre-G2a persisted task (no key) decodes as null
//      (back-compat — אין המצאת תאריך).
//   2. PURE: `buildTasksGantt` (lib/logic/tasks_gantt.dart) maps a
//      `List<TaskItem>` onto a whole-day timeline — scheduled tasks → ordered
//      GanttBars (startDay offset, lenDays, donePercent), unscheduled tasks
//      listed off-timeline (NEVER given a synthetic date).
//
// The STATE half rides the ProviderContainer + mocked-SharedPreferences harness
// from contractor_task_proposal_test.dart (tasksProvider.notifier needs its
// _ref + persistence). The PURE half needs no container — it builds TaskItem
// instances directly and asserts on the layout.
import 'dart:convert';

import 'package:buildsmart/logic/tasks_gantt.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

/// Build a bare scheduled/unscheduled [TaskItem] for the PURE layout tests
/// (no engine, no container). Only the fields the layout reads are interesting.
TaskItem _task({
  required int id,
  String name = 'משימה',
  int days = 1,
  String status = 'pending',
  DateTime? scheduledStart,
  List<String> steps = const [],
  Set<int> doneSteps = const {},
}) =>
    TaskItem(
      id: id,
      name: name,
      detail: '',
      worker: 0,
      status: status,
      days: days,
      steps: steps,
      doneSteps: doneSteps,
      scheduledStart: scheduledStart,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────
  // STATE — the scheduledStart anchor on the engine.
  // ───────────────────────────────────────────────────────────────────────
  group('TaskItem.scheduledStart (Wave G2a — STATE)', () {
    test(
        'createTask(scheduledStart:) stamps the anchor; an unstamped createTask '
        'leaves it null (no invented date)', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final tasks = c.read(tasksProvider.notifier);
      TaskItem byId(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id);

      final scheduledId = tasks.createTask(
        name: 'התקנת כיור',
        scheduledStart: DateTime(2026, 6, 20),
      );
      expect(byId(scheduledId).scheduledStart, DateTime(2026, 6, 20),
          reason: 'createTask carries the planned start onto the task');

      // Additive default: an existing-style caller (no scheduledStart) → null.
      final plainId = tasks.createTask(name: 'משימה ללא תאריך');
      expect(byId(plainId).scheduledStart, isNull,
          reason: 'no date passed → unscheduled (אין המצאת תאריך)');
    });

    test('proposeTask(scheduledStart:) carries the anchor onto the proposal',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final tasks = c.read(tasksProvider.notifier);

      final id = tasks.proposeTask(
        name: 'הצעה מתוזמנת',
        worker: 1,
        scheduledStart: DateTime(2026, 7, 1),
      );
      final t = c.read(tasksProvider).firstWhere((x) => x.id == id);
      expect(t.scheduledStart, DateTime(2026, 7, 1));
      expect(t.status, 'proposed', reason: 'proposeTask behavior is unchanged');
    });

    test('editTask(scheduledStart:) sets / re-anchors the planned start',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final tasks = c.read(tasksProvider.notifier);
      TaskItem byId(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id);

      // Seed task 1 starts unscheduled.
      expect(byId(1).scheduledStart, isNull);
      tasks.editTask(1, scheduledStart: DateTime(2026, 6, 18));
      expect(byId(1).scheduledStart, DateTime(2026, 6, 18),
          reason: 'editTask anchors the task on the timeline');

      // A later editTask with a non-null date re-anchors it.
      tasks.editTask(1, scheduledStart: DateTime(2026, 6, 25));
      expect(byId(1).scheduledStart, DateTime(2026, 6, 25),
          reason: 'a non-null editTask date re-anchors');

      // A null editTask arg KEEPS the current value (editTask never clears).
      tasks.editTask(1, name: 'שם חדש');
      expect(byId(1).scheduledStart, DateTime(2026, 6, 25),
          reason: 'a null scheduledStart arg keeps the current anchor');

      // CLEARING back to unscheduled is via copyWith's sentinel path.
      expect(byId(1).copyWith(scheduledStart: null).scheduledStart, isNull,
          reason: 'copyWith(scheduledStart: null) clears the anchor (sentinel)');
    });

    test(
        'round-trip: a seed task anchored via editTask persists its ISO date '
        'and decodes it back on reload; an unanchored seed task decodes null '
        '(back-compat with a pre-G2a payload)', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      final tasks = c1.read(tasksProvider.notifier);

      // Anchor a SEED task (id 3) — the overlay restores onto re-seeded ids on
      // reload, so a seed id proves the persist→decode round-trip.
      tasks.editTask(3, scheduledStart: DateTime(2026, 6, 20));
      await _settle();

      // toJson: the overlay carries the ISO-8601 string (write-when-non-null).
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTasksScreenKey);
      expect(raw, isNotNull);
      final m = jsonDecode(raw!) as Map<String, dynamic>;
      expect((m['3'] as Map)['scheduledStart'],
          DateTime(2026, 6, 20).toIso8601String(),
          reason: 'scheduledStart serializes exactly like startedAt/completedAt');
      // An UNANCHORED seed task omits the key entirely (the seed stays
      // byte-identical — field-economy, write-when-non-null).
      expect((m['1'] as Map).containsKey('scheduledStart'), isFalse,
          reason: 'an unscheduled task writes no scheduledStart key');
      c1.dispose();

      // RELOAD: a fresh container over the SAME persisted prefs decodes the date.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(tasksProvider.notifier); // kick the async _load
      await _settle();
      final reloaded = c2.read(tasksProvider).firstWhere((t) => t.id == 3);
      expect(reloaded.scheduledStart, DateTime(2026, 6, 20),
          reason: 'the persisted anchor decodes back on reload');
      // An old persisted task that never had the key decodes as null.
      final t1 = c2.read(tasksProvider).firstWhere((t) => t.id == 1);
      expect(t1.scheduledStart, isNull,
          reason: 'a task with no scheduledStart key decodes null (back-compat)');
    });

    test(
        'back-compat: a pre-G2a overlay payload (no scheduledStart key) decodes '
        'cleanly with scheduledStart == null and never crashes', () async {
      // A hand-rolled pre-G2a payload for task 2 — the key did not exist then.
      SharedPreferences.setMockInitialValues({
        kTasksScreenKey: jsonEncode({
          '2': {'status': 'active', 'note': ''},
        }),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(tasksProvider.notifier);
      await _settle();

      final t2 = c.read(tasksProvider).firstWhere((t) => t.id == 2);
      expect(t2.scheduledStart, isNull,
          reason: 'a pre-G2a payload decodes scheduledStart as null');
      expect(t2.status, 'active', reason: 'the rest of the overlay still loads');
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // PURE — buildTasksGantt layout (no container needed).
  // ───────────────────────────────────────────────────────────────────────
  group('buildTasksGantt (Wave G2a — PURE layout)', () {
    test(
        'two scheduled tasks → earliest is day 0, the other offset by whole '
        'days; lenDays = days (floored at 1); spanDays = max(start+len)', () {
      // task A: 2026-06-20, 4 days · task B: 2026-06-23, 2 days.
      final layout = buildTasksGantt([
        _task(id: 1, days: 4, scheduledStart: DateTime(2026, 6, 20)),
        _task(id: 2, days: 2, scheduledStart: DateTime(2026, 6, 23)),
      ]);

      expect(layout.bars.length, 2);
      expect(layout.unscheduled, isEmpty);

      final a = layout.bars.firstWhere((b) => b.taskId == 1);
      final b = layout.bars.firstWhere((b) => b.taskId == 2);
      expect(a.startDay, 0, reason: 'the earliest scheduled task anchors day 0');
      expect(b.startDay, 3, reason: '2026-06-23 is 3 whole days after 06-20');
      expect(a.lenDays, 4, reason: 'lenDays = task.days');
      expect(b.lenDays, 2);
      // spanDays = max(startDay+lenDays) = max(0+4, 3+2) = 5.
      expect(layout.spanDays, 5, reason: 'spanDays = max(start + len) across bars');
    });

    test('a days==0 task still occupies one cell (lenDays floored at 1)', () {
      final layout = buildTasksGantt([
        _task(id: 1, days: 0, scheduledStart: DateTime(2026, 6, 20)),
      ]);
      expect(layout.bars.single.lenDays, 1,
          reason: 'lenDays = max(1, days) — a 0-day task still shows one cell');
      expect(layout.spanDays, 1);
    });

    test('the time-of-day on an anchor is dropped — offsets are whole days', () {
      // Same calendar dates as the headline test, but with non-midnight times:
      // the offset must still be a clean 3 whole days, not 2 or 4.
      final layout = buildTasksGantt([
        _task(id: 1, days: 4, scheduledStart: DateTime(2026, 6, 20, 23, 30)),
        _task(id: 2, days: 2, scheduledStart: DateTime(2026, 6, 23, 1, 15)),
      ]);
      expect(layout.bars.firstWhere((b) => b.taskId == 2).startDay, 3,
          reason: 'date-only differencing → a clean whole-day offset');
    });

    group('donePercent rule', () {
      test('steps present → ticked/total rounded (4 steps, 2 done → 50)', () {
        final layout = buildTasksGantt([
          _task(
            id: 1,
            status: 'active',
            scheduledStart: DateTime(2026, 6, 20),
            steps: const ['a', 'b', 'c', 'd'],
            doneSteps: const {0, 1},
          ),
        ]);
        expect(layout.bars.single.donePercent, 50,
            reason: '2 of 4 steps ticked = 50% (steps beat the status fallback)');
      });

      test('no steps → status fallback: done→100, active→50, pending→0', () {
        final layout = buildTasksGantt([
          _task(id: 1, status: 'done', scheduledStart: DateTime(2026, 6, 20)),
          _task(id: 2, status: 'active', scheduledStart: DateTime(2026, 6, 20)),
          _task(id: 3, status: 'pending', scheduledStart: DateTime(2026, 6, 20)),
          _task(id: 4, status: 'review', scheduledStart: DateTime(2026, 6, 20)),
        ]);
        int pct(int id) => layout.bars.firstWhere((b) => b.taskId == id).donePercent;
        expect(pct(1), 100, reason: 'done → 100');
        expect(pct(2), 50, reason: 'active → 50');
        expect(pct(3), 0, reason: 'pending → 0');
        expect(pct(4), 100, reason: 'review → 100 (submitted, awaiting approval)');
      });
    });

    test(
        'unscheduled tasks (scheduledStart == null) land in `unscheduled` in '
        'input order, NOT in bars (no fabricated date)', () {
      final layout = buildTasksGantt([
        _task(id: 1, scheduledStart: DateTime(2026, 6, 20)),
        _task(id: 2), // unscheduled
        _task(id: 3), // unscheduled
      ]);
      expect(layout.bars.map((b) => b.taskId), [1],
          reason: 'only the anchored task is placed');
      expect(layout.unscheduled.map((t) => t.id), [2, 3],
          reason: 'unscheduled tasks are listed off-timeline, input order kept');
    });

    test('all-unscheduled → empty bars + spanDays 0 + every task in unscheduled',
        () {
      final layout = buildTasksGantt([
        _task(id: 1),
        _task(id: 2),
      ]);
      expect(layout.bars, isEmpty);
      expect(layout.spanDays, 0);
      expect(layout.unscheduled.map((t) => t.id), [1, 2]);
    });

    test('empty input → empty layout', () {
      final layout = buildTasksGantt(const []);
      expect(layout.bars, isEmpty);
      expect(layout.spanDays, 0);
      expect(layout.unscheduled, isEmpty);
    });

    test(
        'deterministic order: two tasks with the SAME startDay sort by taskId '
        '(stable, no timestamp tie ambiguity)', () {
      // Feed them id-descending with the SAME anchor date; the layout must
      // re-order them ascending-by-id at the same startDay.
      final layout = buildTasksGantt([
        _task(id: 5, scheduledStart: DateTime(2026, 6, 20)),
        _task(id: 2, scheduledStart: DateTime(2026, 6, 20)),
        _task(id: 9, scheduledStart: DateTime(2026, 6, 20)),
      ]);
      expect(layout.bars.map((b) => b.startDay).toSet(), {0},
          reason: 'same anchor → all at day 0');
      expect(layout.bars.map((b) => b.taskId), [2, 5, 9],
          reason: 'ties broken by taskId ascending — deterministic');
    });

    test(
        'deterministic order across start days: sort is (startDay, then taskId)',
        () {
      final layout = buildTasksGantt([
        _task(id: 1, scheduledStart: DateTime(2026, 6, 25)), // day 5
        _task(id: 7, scheduledStart: DateTime(2026, 6, 20)), // day 0
        _task(id: 3, scheduledStart: DateTime(2026, 6, 20)), // day 0
      ]);
      // earliest = 06-20 → ids 7 & 3 at day 0 (sorted 3,7), then id 1 at day 5.
      expect(layout.bars.map((b) => b.taskId), [3, 7, 1]);
      expect(layout.bars.map((b) => b.startDay), [0, 0, 5]);
    });
  });
}
