// CROSS-PERSONA WIRING G3a (DEFECTS AS A TASK KIND — STATE) — proof that a
// ליקוי (defect) is just a `TaskItem` with `kind == 'defect'` (+ optional
// `location`/`severity`) that reuses the ENTIRE tasks engine: authoring
// (`createTask`), proposal (`proposeTask` → `pendingProposalsProvider` →
// `approveProposal`), and the field-economy persist/decode. The user's
// decision: "ליקויים same as משימות". The defects UI itself is Wave G3b — here
// we only exercise the additive engine API on `TasksNotifier`:
//   createTask({…, kind, location, severity}) → int
//   proposeTask({…, kind, location, severity}) → int
//   editTask(int, {…, location?, severity?})
// and the new live `defectsProvider` (the kind filter off `tasksProvider`).
//
// Through a `ProviderContainer` (not a bare notifier) so `tasksProvider.notifier`
// carries its `_ref` — the worker-bell + the proposal queue both need the
// provider graph + persistence (mirrors contractor_task_proposal_test.dart).
// Firebase-free: SharedPreferences mocked.
import 'dart:convert';

import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('defects as a task kind (ליקוי == משימה, shared engine, G3a)', () {
    test(
        'createTask(kind:defect, location, severity) → a pending defect that '
        'shows in defectsProvider; a regular createTask is NOT a defect '
        '(HEADLINE: contractor opens a defect via the SAME authoring path)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      TaskItem byId(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id);

      // Clean verbatim seed: ids 1..5, none a defect.
      expect(c.read(tasksProvider).map((t) => t.id), [1, 2, 3, 4, 5],
          reason: 'the verbatim §6 seed is 5 tasks (אין המצאות)');
      expect(c.read(defectsProvider), isEmpty,
          reason: 'the verbatim seed carries no defects');

      // The CONTRACTOR "opens a defect" via the SAME createTask authoring path.
      final defectId = tasks.createTask(
        name: 'סדק',
        kind: 'defect',
        location: 'אמבטיה',
        severity: 'חמור',
        employerId: 'c1',
      );

      final d = byId(defectId);
      expect(d.kind, 'defect',
          reason: 'createTask stamps the defect kind');
      expect(d.location, 'אמבטיה');
      expect(d.severity, 'חמור');
      expect(d.status, 'pending',
          reason: 'a defect reuses createTask\'s pending start (unchanged)');
      expect(d.createdBy, 'contractor',
          reason: 'a contractor-opened defect is authored by the contractor');
      expect(d.employerId, 'c1');

      // It surfaces in the live defectsProvider.
      expect(c.read(defectsProvider).map((t) => t.id), contains(defectId),
          reason: 'the defect surfaces in the live defectsProvider');

      // A REGULAR task (kind default) is NOT a defect.
      final taskId = tasks.createTask(name: 'התקנת כיור', employerId: 'c1');
      expect(byId(taskId).kind, 'task',
          reason: 'createTask defaults kind to task');
      expect(c.read(defectsProvider).any((t) => t.id == taskId), isFalse,
          reason: 'a regular task does not leak into defectsProvider');
    });

    test(
        'proposeTask(kind:defect) → a worker-reported defect awaits the '
        'contractor through the SAME G1 proposal flow; approveProposal flips it '
        'active and it STAYS a defect (kind preserved through copyWith)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      TaskItem byId(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id);

      // The WORKER REPORTS a defect via the SAME proposeTask path.
      final id = tasks.proposeTask(
        name: 'נזילה',
        worker: 1,
        kind: 'defect',
        location: 'מטבח',
        severity: 'בינוני',
        employerId: 'c1',
      );

      final d = byId(id);
      expect(d.kind, 'defect', reason: 'proposeTask stamps the defect kind');
      expect(d.location, 'מטבח');
      expect(d.severity, 'בינוני');
      expect(d.status, 'proposed',
          reason: 'a reported defect enters the proposed bucket (unchanged)');
      expect(d.createdBy, 'worker',
          reason: 'a worker-reported defect is authored by the worker');

      // It is BOTH a defect AND in the contractor's proposal-approval queue —
      // a worker-reported defect runs the SAME G1 approval flow.
      expect(c.read(defectsProvider).any((t) => t.id == id), isTrue,
          reason: 'the reported defect surfaces in defectsProvider');
      expect(c.read(pendingProposalsProvider).map((t) => t.id), contains(id),
          reason: 'the reported defect awaits the contractor (same G1 queue)');

      // CONTRACTOR approves via the SAME approveProposal → active, STILL a
      // defect (kind preserved through copyWith).
      tasks.approveProposal(id);
      final after = byId(id);
      expect(after.status, 'active',
          reason: 'approveProposal flips the proposed defect active');
      expect(after.kind, 'defect',
          reason: 'the kind is PRESERVED through approveProposal (copyWith)');
      expect(after.location, 'מטבח',
          reason: 'location survives the copyWith too');
      expect(after.severity, 'בינוני');
      expect(c.read(defectsProvider).any((t) => t.id == id), isTrue,
          reason: 'an approved defect is still a defect');
      expect(c.read(pendingProposalsProvider).any((t) => t.id == id), isFalse,
          reason: 'an approved proposal leaves the queue');
    });

    test(
        'editTask patches a defect\'s location/severity; editing a non-defect '
        'task\'s location is harmless', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final tasks = c.read(tasksProvider.notifier);
      TaskItem byId(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id);

      final defectId = tasks.createTask(
        name: 'סדק',
        kind: 'defect',
        location: 'אמבטיה',
        severity: 'בינוני',
      );

      // Re-locate + escalate the defect.
      tasks.editTask(defectId, location: 'אמבטיה ראשית', severity: 'חמור');
      final d = byId(defectId);
      expect(d.location, 'אמבטיה ראשית', reason: 'editTask patches location');
      expect(d.severity, 'חמור', reason: 'editTask patches severity');
      expect(d.kind, 'defect',
          reason: 'editTask must NOT flip the kind (fixed at creation)');
      // A null arg keeps the current value (the existing editTask contract).
      tasks.editTask(defectId, name: 'סדק עמוק');
      expect(byId(defectId).location, 'אמבטיה ראשית',
          reason: 'a null location leaves the value untouched');
      expect(byId(defectId).name, 'סדק עמוק');

      // Editing a REGULAR task's location is harmless (it just stops being '').
      final taskId = tasks.createTask(name: 'התקנת כיור');
      expect(byId(taskId).kind, 'task');
      tasks.editTask(taskId, location: 'מטבח');
      expect(byId(taskId).location, 'מטבח',
          reason: 'editing a regular task\'s location is harmless');
      expect(byId(taskId).kind, 'task',
          reason: 'a regular task stays a task');
      expect(c.read(defectsProvider).any((t) => t.id == taskId), isFalse,
          reason: 'giving a task a location does NOT make it a defect');
    });

    test(
        'kind/location/severity round-trip through persist+reload; an OLD '
        'persisted task with none decodes as task/\'\'/\'\' (back-compat, NOT a '
        'defect)', () async {
      // The overlay is keyed by SEED id, so the round-trip is proven on a seed
      // task: this OLD overlay marks seed task 1 a defect (the keys _persist
      // would write), while seed task 2 stays pre-G3a (no kind/location/
      // severity keys — the back-compat decode).
      SharedPreferences.setMockInitialValues({
        kTasksScreenKey: jsonEncode({
          '1': {
            'status': 'pending',
            'note': '',
            'createdBy': 'contractor',
            'kind': 'defect',
            'location': 'אמבטיה',
            'severity': 'חמור',
          },
          '2': {'status': 'active', 'note': ''},
        }),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Touch the notifier so the async _load runs, then settle.
      c.read(tasksProvider.notifier);
      await _settle();

      // ROUND-TRIP: the persisted defect (task 1) decodes back as a defect with
      // its location/severity intact, and surfaces in defectsProvider.
      final t1 = c.read(tasksProvider).firstWhere((t) => t.id == 1);
      expect(t1.kind, 'defect',
          reason: 'kind round-trips through persist+reload');
      expect(t1.location, 'אמבטיה',
          reason: 'location round-trips through persist+reload');
      expect(t1.severity, 'חמור',
          reason: 'severity round-trips through persist+reload');
      expect(c.read(defectsProvider).any((t) => t.id == 1), isTrue,
          reason: 'a persisted defect surfaces in defectsProvider on reload');

      // BACK-COMPAT: the pre-G3a task 2 decodes as a plain task — NOT a defect.
      final t2 = c.read(tasksProvider).firstWhere((t) => t.id == 2);
      expect(t2.kind, 'task',
          reason: 'a pre-G3a payload decodes kind as the task default');
      expect(t2.location, '');
      expect(t2.severity, '');
      expect(t2.status, 'active', reason: 'the rest of the overlay still loads');
      expect(c.read(defectsProvider).any((t) => t.id == 2), isFalse,
          reason: 'a pre-G3a task is never a defect (back-compat)');
    });

    test(
        'field-economy: a regular task\'s toJson omits kind/location/severity '
        '(the verbatim seed + regular tasks stay byte-identical)', () async {
      // The persisted overlay is the ground truth for the wire economy: a
      // DEFAULT (regular) task must not write any of the three keys.
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Mutate a seed task so its overlay entry is written (status flip), then
      // read the raw persisted payload back.
      c.read(tasksProvider.notifier).startWork(1);
      await _settle();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTasksScreenKey);
      expect(raw, isNotNull, reason: 'a mutation persists the overlay');
      final m = jsonDecode(raw!) as Map<String, dynamic>;
      final entry1 = m['1'] as Map<String, dynamic>;

      // A regular (default-kind) task omits all three keys — byte-economy.
      expect(entry1.containsKey('kind'), isFalse,
          reason: 'a regular task omits kind (write-when-non-default)');
      expect(entry1.containsKey('location'), isFalse,
          reason: 'a regular task omits location (write-when-non-empty)');
      expect(entry1.containsKey('severity'), isFalse,
          reason: 'a regular task omits severity (write-when-non-empty)');

      // …but once a seed task carries a location, the key DOES appear (proving
      // the omission above is the economy, not a dropped field).
      c.read(tasksProvider.notifier).editTask(1, location: 'אמבטיה');
      await _settle();
      final m2 =
          jsonDecode(prefs.getString(kTasksScreenKey)!) as Map<String, dynamic>;
      expect((m2['1'] as Map<String, dynamic>)['location'], 'אמבטיה',
          reason: 'a non-empty location IS written (write-when-non-empty)');
    });
  });
}
