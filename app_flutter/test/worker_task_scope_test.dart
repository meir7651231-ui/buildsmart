// Guard tests for the worker board's task scoping (task #66 — כל עובד רואה רק
// את המשימות שלו בלבד). The scope seam IS unit-testable: the logged
// [BoardSession] maps to a seed worker index via [workerIndexForSession]
// (screens/worker_profile_screen.dart — ran→0 רן · omer→1 עומר · demo→0) and
// every board view filters the live [tasksProvider] with `t.worker == worker`
// (worker_app_screen.dart `_TasksTab._bucket` / the profile's honest stats).
// These tests reproduce exactly that path — log in, map, filter — and prove no
// task of the OTHER worker leaks into the scoped list.
import 'package:buildsmart/screens/worker_profile_screen.dart'
    show workerIndexForSession;
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 60));

/// The exact scope predicate the worker board applies over [tasksProvider]
/// (`_TasksTab` and the worker profile both filter `t.worker == worker`).
List<TaskItem> _scoped(List<TaskItem> all, int worker) =>
    all.where((t) => t.worker == worker).toList();

/// Login + map + read the scoped task list — the board's identity path.
Future<(int, List<TaskItem>)> _scopeFor(
    ProviderContainer c, String username, String code) async {
  final ok =
      c.read(boardAuthProvider.notifier).login(BoardRole.worker, username, code);
  expect(ok, true, reason: 'seeded worker $username must log in');
  final worker = workerIndexForSession(c.read(boardAuthProvider)!);
  c.read(tasksProvider); // lazy — touch it so its _load() starts
  await _settle();
  return (worker, _scoped(c.read(tasksProvider), worker));
}

void main() {
  test('ran (worker 0) sees only his tasks — seed ids 1·2·5', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final (worker, mine) = await _scopeFor(c, 'ran', '1111');

    expect(worker, 0, reason: 'ran maps to seed worker 0 (רן)');
    expect(mine.map((t) => t.id).toSet(), {1, 2, 5},
        reason: 'the seed assigns tasks 1/2/5 to רן and nothing else');
    expect(mine.every((t) => t.worker == 0), true,
        reason: 'no task of another worker may leak into the scope');
  });

  test('omer (worker 1) sees only their tasks — seed ids 3·4', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final (worker, mine) = await _scopeFor(c, 'omer', '2222');

    expect(worker, 1, reason: 'omer maps to seed worker 1 (עומר)');
    expect(mine.map((t) => t.id).toSet(), {3, 4},
        reason: 'the seed assigns tasks 3/4 to עומר and nothing else');
    expect(mine.every((t) => t.worker == 1), true,
        reason: 'no task of another worker may leak into the scope');
  });

  test('demo session scopes as רן (worker 0) — the documented demo identity',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(boardAuthProvider.notifier).enterDemo(BoardRole.worker);
    final session = c.read(boardAuthProvider)!;
    expect(session.demo, true);
    expect(workerIndexForSession(session), 0,
        reason: 'a demo session enters as רן (seed worker 0, honest דמו chip)');
  });

  test('scopes are disjoint and cover the whole seed — no shared/orphan task',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(tasksProvider); // lazy — touch it so its _load() starts
    await _settle();
    final all = c.read(tasksProvider);
    final ran = _scoped(all, 0).map((t) => t.id).toSet();
    final omer = _scoped(all, 1).map((t) => t.id).toSet();

    expect(ran.intersection(omer), isEmpty,
        reason: 'a task must never be visible to two workers');
    expect(ran.union(omer), all.map((t) => t.id).toSet(),
        reason: 'every seed task belongs to exactly one worker scope');
  });
}
