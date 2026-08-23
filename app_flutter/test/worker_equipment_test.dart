// #112 — the DAY-level equipment checklist. Two guarantees:
//   1) PURE `equipmentForTasks` dedups a shared kit line ACROSS tasks (merging
//      the contributing task ids) AND omits a task with NO SKU mapping.
//   2) the sheet renders the visible DEMO-SEED hint (honesty: the mapping is
//      demo wiring, to be server-connected).
//
// Real seed (task_skus_local.dart `kTaskSkus`): task 1 maps to two AQUATEC NTM
// press fittings, task 2 maps to brass nipple/valve products, task 3 (איטום
// רצפת מקלחת) has NO entry. Tasks 1 and 2 BOTH yield the BSP sealant line
// 'סרט טפלון (PTFE)' (task 1 via the 16×½" coupler's female-BSP end, task 2 via
// its male-BSP nipple) — so it must appear exactly once with taskIds [1, 2].

import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/screens/worker_equipment_checklist_sheet.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal real-id TaskItem — only id matters for `equipmentForTasks`
/// (it keys off `productsForTask(t.id)`); name is asserted for the unmapped
/// note.
TaskItem _task(int id, String name) => TaskItem(
      id: id,
      name: name,
      detail: '',
      worker: 0,
      status: 'active',
      days: 1,
      steps: const [],
    );

void main() {
  group('equipmentForTasks (pure)', () {
    test('the real seed has task 1 mapped and task 3 unmapped', () {
      // Pin the contract's seed facts so the assertions below stay honest.
      expect(kTaskSkus.containsKey(1), isTrue);
      expect(kTaskSkus.containsKey(3), isFalse);
      expect(productsForTask(1), isNotEmpty);
      expect(productsForTask(3), isEmpty);
    });

    test('dedups a shared line across tasks AND omits an unmapped task', () {
      final items = equipmentForTasks([
        _task(1, 'התקנת קו מים חם — חדר רחצה'),
        _task(2, 'הרכבת מיכל הדחה סמוי'),
        _task(3, 'איטום רצפת מקלחת'), // unmapped — must contribute nothing
      ]);

      // Task 3 contributes nothing → no line carries id 3.
      expect(
        items.every((it) => !it.taskIds.contains(3)),
        isTrue,
        reason: 'an unmapped task must not appear on any equipment line',
      );

      // The BSP sealant is shared by tasks 1 and 2 → exactly ONE deduped line
      // whose merged taskIds are [1, 2] (sorted).
      final ptfe =
          items.where((it) => it.label == 'סרט טפלון (PTFE)').toList();
      expect(ptfe.length, 1,
          reason: 'a kit line shared across tasks must dedup to one row');
      expect(ptfe.single.taskIds, [1, 2],
          reason: 'dedup must MERGE the contributing task ids');

      // Every label is unique (the dedup invariant) and every retained line
      // traces to a mapped task (1 or 2 only).
      final labels = items.map((it) => it.label).toList();
      expect(labels.length, labels.toSet().length,
          reason: 'no duplicate labels survive aggregation');
      for (final it in items) {
        expect(it.taskIds.every((id) => id == 1 || id == 2), isTrue);
        expect(it.severity, isNotEmpty);
      }
    });

    test('empty input → empty list (honest)', () {
      expect(equipmentForTasks(const []), isEmpty);
    });
  });

  testWidgets('sheet shows the DEMO-SEED hint', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showEquipmentChecklistSheet(
                    context,
                    ref,
                    tasks: [_task(1, 'התקנת קו מים חם — חדר רחצה')],
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('🧰 ציוד נדרש להיום'), findsOneWidget);
    // The hint + send action sit at the bottom of the lazy sheet list — scroll
    // each into view before asserting (the Wave-2 lazy-ListView lesson:
    // scrollUntilVisible builds the off-screen tail).
    final sheetScroll = find.byType(Scrollable).last;
    final hint = find.text(
        'רשימת הציוד נגזרת ממיפוי דמו של מוצרים למשימה — תחובר עם השרת');
    await tester.scrollUntilVisible(hint, 120, scrollable: sheetScroll);
    expect(hint, findsOneWidget,
        reason: 'the DEMO-SEED honesty hint must be visible');
    // The send-to-contractor action is present.
    final send = find.text('שלח רשימה לקבלן');
    await tester.scrollUntilVisible(send, 120, scrollable: sheetScroll);
    expect(send, findsOneWidget);
  });
}
