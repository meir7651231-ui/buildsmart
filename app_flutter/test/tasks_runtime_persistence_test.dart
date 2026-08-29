// Wave A1 — a RUNTIME-created task (contractor createTask / worker proposeTask,
// a non-seed id) must survive an app restart. Before the fix, _load rebuilt
// state only from the const seeds + an id-keyed mutation overlay, so any task
// with a non-seed id (createTask/proposeTask mint max+1) was silently dropped on
// relaunch — every contractor-created task / worker proposal vanished. Now the
// full record is persisted under kTasksRuntimeKey and restored on load.

import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Poll until [cond] holds (lets the fire-and-forget _load/_persist settle).
  Future<void> waitFor(bool Function() cond) async {
    for (var i = 0; i < 200; i++) {
      if (cond()) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  group('runtime task persistence (Wave A1)', () {
    test('a contractor-created task (non-seed id) survives a restart with its '
        'full record', () async {
      SharedPreferences.setMockInitialValues({});

      // Session 1: contractor mints a brand-new task (id beyond the 5 seeds).
      final c1 = ProviderContainer();
      final id = c1.read(tasksProvider.notifier).createTask(
            name: 'התקנת ברז גן',
            steps: const ['פתיחת מים', 'חיבור הברז'],
            worker: 1,
            employerId: 'contractor-demo',
          );
      expect(id, greaterThan(5), reason: 'a runtime task gets a non-seed id');

      // Wait for the full runtime record to land in prefs.
      final prefs = await SharedPreferences.getInstance();
      await waitFor(() {
        final raw = prefs.getString('bs.tasks-runtime.v1');
        return raw != null && raw.contains('התקנת ברז גן');
      });
      c1.dispose();

      // Session 2: a fresh container on the SAME prefs restores the task.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(tasksProvider.notifier); // fires _load
      await waitFor(() => c2.read(tasksProvider).any((t) => t.id == id));

      final restored =
          c2.read(tasksProvider).firstWhere((t) => t.id == id);
      expect(restored.name, 'התקנת ברז גן');
      expect(restored.status, 'pending');
      expect(restored.createdBy, 'contractor');
      expect(restored.steps, const ['פתיחת מים', 'חיבור הברז']);
      expect(restored.employerId, 'contractor-demo');
    });

    test('the const seeds still load unchanged alongside runtime tasks',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      c1.read(tasksProvider.notifier).createTask(name: 'משימת-ריצה');
      final prefs = await SharedPreferences.getInstance();
      await waitFor(() =>
          (prefs.getString('bs.tasks-runtime.v1') ?? '').contains('משימת-ריצה'));
      c1.dispose();

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(tasksProvider.notifier);
      // seed task 1 still present + a single copy of the runtime task (no dup).
      await waitFor(() => c2.read(tasksProvider).any((t) => t.name == 'משימת-ריצה'));
      final all = c2.read(tasksProvider);
      expect(all.where((t) => t.id == 1), hasLength(1), reason: 'seed intact');
      expect(all.where((t) => t.name == 'משימת-ריצה'), hasLength(1),
          reason: 'runtime task restored exactly once (no seed/runtime dup)');
    });
  });
}
