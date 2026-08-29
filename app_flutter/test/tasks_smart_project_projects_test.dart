// Phase-B Track T3 (A/B/F) engines — pure state-machine proofs (no widgets,
// no SharedPreferences; the notifiers are constructed with persist:false).
//   T3.A tasks_engine        — 5-state machine + auto-advance + work-log.
//   T3.B smart_project_engine — 9 day-stages · done-marking · progress=done/9.
//   T3.F projects_engine      — list · switchProject · edit/add · cart-per-project.

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── T3.A · tasks engine ────────────────────────────────────────────────────
  group('T3.A tasks engine — 5-state machine + auto-advance', () {
    test('seed joins persona + steps + detail verbatim (5 tasks)', () {
      final n = TasksNotifier(persist: false);
      expect(n.state.length, 5);
      final t1 = n.state.firstWhere((t) => t.id == 1);
      expect(t1.name, 'התקנת קו מים חם — חדר רחצה');
      expect(t1.detail, kTaskDetail[1]);
      expect(t1.steps, kTaskSteps[1]);
      expect(t1.status, 'active'); // verbatim seed
      // review/done seeds carry a photo (proto), pending/active don't.
      expect(n.state.firstWhere((t) => t.id == 3).photo, 'demo'); // review
      expect(n.state.firstWhere((t) => t.id == 2).photo, isNull); // pending
    });

    test('worker submit: active → review AND auto-advances next pending task', () {
      final n = TasksNotifier(persist: false);
      String s(int id) => n.state.firstWhere((t) => t.id == id).status;
      // worker 0 owns task 1 (active) + tasks 2,5 (pending). Submit task 1.
      expect(s(1), 'active');
      expect(s(2), 'pending');
      n.submitForReview(1, note: 'בוצע');
      expect(s(1), 'review');
      expect(n.state.firstWhere((t) => t.id == 1).note, 'בוצע');
      // auto-advance: worker 0's next pending (task 2) became active.
      expect(s(2), 'active', reason: 'auto-advance promotes the next queued task');
      expect(s(5), 'pending', reason: 'only ONE task auto-advances');
    });

    test('manager approve review → done; reject review → rejected (clears photo)',
        () {
      final n = TasksNotifier(persist: false);
      // task 3 seeds `review` with a photo.
      expect(n.state.firstWhere((t) => t.id == 3).status, 'review');
      n.reject(3);
      final r = n.state.firstWhere((t) => t.id == 3);
      expect(r.status, 'rejected');
      expect(r.photo, isNull, reason: 'reject clears the photo for re-shoot');
      // a rejected task is submittable again → review → approve → done.
      n.submitForReview(3);
      expect(n.state.firstWhere((t) => t.id == 3).status, 'review');
      n.approve(3);
      expect(n.state.firstWhere((t) => t.id == 3).status, 'done');
    });

    test('invalid transitions are no-ops (approve a pending, submit a done)', () {
      final n = TasksNotifier(persist: false);
      n.approve(2); // pending — not review
      expect(n.state.firstWhere((t) => t.id == 2).status, 'pending');
      n.submitForReview(4); // done — not worker-owned
      expect(n.state.firstWhere((t) => t.id == 4).status, 'done');
    });

    test('work-log: today bucket = approved tasks, then kWorkLog history', () {
      final n = TasksNotifier(persist: false);
      // seed has task 4 done → today shows it.
      var today = todayWorkLog(n.state);
      expect(today.date, 'היום');
      expect(today.items.any((i) => i.task == 'התקנת נקזון רצפה'), isTrue);
      // approve task 3 too → it joins today.
      n.approve(3);
      today = todayWorkLog(n.state);
      expect(today.items.any((i) => i.task == 'איטום רצפת מקלחת'), isTrue);
      // history is appended verbatim after today.
      expect(kWorkLog.length, 2);
    });

    test('empty today bucket shows the placeholder row', () {
      // a state with no done tasks → placeholder.
      final none = [
        for (final t in kPersonaTasks)
          TaskItem(
            id: t.id,
            name: t.name,
            detail: '',
            worker: t.worker,
            status: 'pending',
            days: t.days,
            steps: const [],
          ),
      ];
      final today = todayWorkLog(none);
      expect(today.items.single.task, 'אין עדיין משימות שאושרו היום');
      expect(today.items.single.status, 'none');
    });
  });

  // ── T3.B · smart-project engine ────────────────────────────────────────────
  group('T3.B smart-project engine — 9 day-stages · progress=done/9', () {
    test('day-stages flatten each task into task.days days (Σ=9)', () {
      final stages = buildDayStages();
      // seed days: 2+1+3+1+2 = 9.
      expect(stages.length, 9);
      // task 3 (days:3) yields keys 3-1, 3-2, 3-3.
      final t3 = stages.where((s) => s.taskId == 3).toList();
      expect(t3.map((s) => s.key), ['3-1', '3-2', '3-3']);
      expect(t3.first.dayTag, 'יום 1 מתוך 3');
      // a 1-day task tags "יום עבודה".
      expect(stages.firstWhere((s) => s.taskId == 2).dayTag, 'יום עבודה');
    });

    test('progress = doneDays / total (round pct)', () {
      expect(smartProjectProgress(const {}), (done: 0, total: 9, pct: 0));
      // mark 3 day-stages done.
      final done = {'1-1', '1-2', '2-1'};
      final p = smartProjectProgress(done);
      expect(p.done, 3);
      expect(p.total, 9);
      expect(p.pct, (3 / 9 * 100).round()); // 33
      // step keys do NOT count toward day progress.
      final withStep = {...done, '1-step0'};
      expect(smartProjectProgress(withStep).done, 3);
    });

    test('toggle adds/removes a key; all-done → pct 100', () {
      final n = SmartProjectNotifier(persist: false);
      expect(n.isDone('1-1'), isFalse);
      n.toggle('1-1');
      expect(n.isDone('1-1'), isTrue);
      n.toggle('1-1');
      expect(n.isDone('1-1'), isFalse);
      // mark every day-stage done → progress 9/9 = 100%.
      for (final s in buildDayStages()) {
        n.toggle(s.key);
      }
      expect(smartProjectProgress(n.state), (done: 9, total: 9, pct: 100));
    });
  });

  // ── T3.F · projects engine ─────────────────────────────────────────────────
  group('T3.F projects engine — switch · edit/add · cart-per-project', () {
    test('seed = 3 verbatim projects, active = PRJ-1', () {
      final n = ProjectsNotifier(persist: false);
      expect(n.state.projects.length, 3);
      expect(n.state.projects.map((p) => p.id), ['PRJ-1', 'PRJ-2', 'PRJ-3']);
      expect(n.state.activeId, kActiveProjectId);
      expect(n.state.active.name, 'מגדל הרצליה — קומה 4');
      expect(n.state.seq, 4);
    });

    test('switchProject changes active + returns incoming cart; no-op if same/unknown',
        () {
      final n = ProjectsNotifier(persist: false);
      expect(n.switchProject('PRJ-1'), isNull, reason: 'already active');
      expect(n.switchProject('PRJ-9'), isNull, reason: 'unknown id');
      final incoming = n.switchProject('PRJ-2');
      expect(n.state.activeId, 'PRJ-2');
      expect(incoming, isA<List<SmartCartLine>>());
    });

    test('cart-per-project: outgoing cart is stashed, incoming restored on switch',
        () {
      final n = ProjectsNotifier(persist: false);
      const lineA = SmartCartLine(
        productKey: 'k-a',
        productName: 'ברז',
        productEmoji: '🚿',
        brandName: 'X',
        brandPrice: 100,
        productQty: 1,
        accessories: [],
      );
      // PRJ-1 active. Switch to PRJ-2 carrying PRJ-1's live cart [lineA].
      n.switchProject('PRJ-2', outgoingCart: const [lineA]);
      expect(n.state.projects.firstWhere((p) => p.id == 'PRJ-1').cart,
          [lineA], reason: 'outgoing cart stashed on PRJ-1');
      expect(n.state.active.cart, isEmpty, reason: 'PRJ-2 had no cart');
      // Switch back to PRJ-1 → its stashed cart [lineA] is returned.
      final restored = n.switchProject('PRJ-1', outgoingCart: const []);
      expect(restored, [lineA], reason: 'PRJ-1 cart restored on return');
    });

    test('editProject mutates name/addr/manager; empty name is a no-op', () {
      final n = ProjectsNotifier(persist: false);
      n.editProject('PRJ-1',
          name: 'מגדל חדש', addr: 'רחוב 1', manager: 'משה');
      final p = n.state.projects.firstWhere((x) => x.id == 'PRJ-1');
      expect(p.name, 'מגדל חדש');
      expect(p.addr, 'רחוב 1');
      expect(p.manager, 'משה');
      n.editProject('PRJ-1', name: '   ', addr: 'x', manager: 'y');
      expect(n.state.projects.firstWhere((x) => x.id == 'PRJ-1').name,
          'מגדל חדש', reason: 'empty name rejected');
    });

    test('addProject appends PRJ-<seq>, defaults addr/manager to "—", bumps seq',
        () {
      final n = ProjectsNotifier(persist: false);
      final id = n.addProject(name: 'אתר חדש');
      expect(id, 'PRJ-4');
      expect(n.state.seq, 5);
      final p = n.state.projects.last;
      expect(p.name, 'אתר חדש');
      expect(p.addr, '—');
      expect(p.manager, '—');
      expect(n.addProject(name: '  '), isNull, reason: 'empty name rejected');
    });
  });
}
