// Nightly 2026-11-27 — עריכה של משימת-seed (שם · פירוט · ימים · שלבים ·
// עובד) על ידי הקבלן נשמרה בזיכרון בלבד: ה-overlay של bs.tasks-screen.v1 לא
// נשא את השדות האלה, ומשימות-seed מוחרגות מהמפתח של הרשומות-המלאות. אחרי F5
// המשימה חזרה לשמה המקורי ולעובד המקורי — חצי-שחזור (scheduledStart כן נשמר).

import 'dart:convert';

import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  test('editTask + assignTask on a SEED task survive a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final n = c1.read(tasksProvider.notifier);
    await _settle(); // let the initial async _load finish first
    final seed1 = c1.read(tasksProvider).firstWhere((t) => t.id == 1);
    final otherWorker = seed1.worker == 0 ? 1 : 0;

    n.editTask(1,
        name: 'קו מים חם — שם חדש',
        detail: 'פירוט חדש',
        days: 5,
        steps: const ['שלב א', 'שלב ב']);
    n.assignTask(1, worker: otherWorker);
    await _settle();
    c1.dispose();

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(tasksProvider.notifier); // kick the async _load
    await _settle();
    final t1 = c2.read(tasksProvider).firstWhere((t) => t.id == 1);
    expect(t1.name, 'קו מים חם — שם חדש');
    expect(t1.detail, 'פירוט חדש');
    expect(t1.days, 5);
    expect(t1.steps, ['שלב א', 'שלב ב']);
    expect(t1.worker, otherWorker);
  });

  test('an UNEDITED seed writes no authored keys (payload byte-identical)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(tasksProvider.notifier);
    await _settle();
    n.editTask(2, name: 'משימה 2 ערוכה'); // triggers a persist
    await _settle();

    final prefs = await SharedPreferences.getInstance();
    final m = jsonDecode(prefs.getString(kTasksScreenKey)!) as Map;
    final o1 = m['1'] as Map;
    for (final k in ['name', 'detail', 'days', 'steps', 'worker']) {
      expect(o1.containsKey(k), isFalse, reason: 'seed 1 untouched → no "$k"');
    }
    final o2 = m['2'] as Map;
    expect(o2['name'], 'משימה 2 ערוכה');
    expect(o2.containsKey('detail'), isFalse);
  });

  test('a pre-fix / garbage overlay keeps the seed values (no crash)',
      () async {
    final seed = buildTasksSeed().firstWhere((t) => t.id == 3);
    SharedPreferences.setMockInitialValues({
      kTasksScreenKey: jsonEncode({
        '3': {'status': seed.status, 'name': 42, 'days': 'x', 'steps': 'no'},
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(tasksProvider.notifier);
    await _settle();
    final t3 = c.read(tasksProvider).firstWhere((t) => t.id == 3);
    expect(t3.name, seed.name);
    expect(t3.days, seed.days);
    expect(t3.steps, seed.steps);
  });
}
