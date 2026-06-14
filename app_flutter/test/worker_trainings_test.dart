// Guard tests for cluster #85ח · תיק בטיחות → הדרכות (#108) —
// lib/state/worker_trainings.dart. The safety-training log the worker board
// reads: record a training (status recorded), attach a certificate document,
// send it for the safety officer's approval (recorded → pending), and remove
// it. Covered here (the worker_certs/courier_profile_store idioms):
//   • model round-trip — toJson → tryFromJson incl. a null doc + defaults,
//   • add / remove / sendForApproval / forUser (newest-first) on an in-memory
//     (persist:false) notifier,
//   • attachDoc — success path AND the FAILED-persist rollback (the F-8 idiom,
//     via the debugPersistOverride hook); an unknown id → false, state intact,
//   • persist round-trip — an add survives a simulated restart under
//     'bs.worker-trainings.v1',
//   • DEMO-SEED — a FRESH (empty) persisted store seeds 3 removable demo rows.
import 'dart:convert';

import 'package:buildsmart/state/worker_trainings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── model ─────────────────────────────────────────────────────────────────
  group('WorkerTraining model', () {
    test('round-trip — fields survive toJson → tryFromJson', () {
      final t = WorkerTraining(
        id: 'train-1',
        username: 'ran',
        title: 'עבודה בגובה',
        by: 'ממונה בטיחות',
        date: DateTime(2026, 3, 12),
        doc: 'data:image/png;base64,DOC=',
        status: kTrainingPending,
      );
      final back = WorkerTraining.tryFromJson(t.toJson());
      expect(back, isNotNull);
      expect(back!.id, 'train-1');
      expect(back.username, 'ran');
      expect(back.title, 'עבודה בגובה');
      expect(back.by, 'ממונה בטיחות');
      expect(back.date, DateTime(2026, 3, 12));
      expect(back.doc, 'data:image/png;base64,DOC=');
      expect(back.status, kTrainingPending);
    });

    test('defensive decode — null doc + missing/bad fields → defaults/drop', () {
      // A minimal valid record with no doc/by/status keys.
      final back = WorkerTraining.tryFromJson({
        'id': 'train-min',
        'username': 'omer',
        'title': 'כללי',
        'date': DateTime(2026, 1, 5).toIso8601String(),
      });
      expect(back, isNotNull);
      expect(back!.doc, isNull, reason: 'missing doc → null');
      expect(back.by, '', reason: 'missing by → empty');
      expect(back.status, kTrainingRecorded, reason: 'missing status → recorded');

      // A malformed entry is dropped, never crashes the load.
      expect(WorkerTraining.tryFromJson({'id': 1}), isNull);
      expect(WorkerTraining.tryFromJson('not a map'), isNull);
      expect(WorkerTraining.tryFromJson({'id': 'x', 'username': 'u'}), isNull,
          reason: 'no title/date → dropped');
    });
  });

  // ── add / remove / sendForApproval / forUser (in-memory) ───────────────────
  group('add / remove / sendForApproval', () {
    test('add — records a training with status recorded, returns it', () async {
      final n = WorkerTrainingsNotifier(persist: false);
      final t = await n.add(
        username: 'ran',
        title: '  עבודה בגובה  ',
        by: '  ממונה בטיחות  ',
        date: DateTime(2026, 3, 12),
      );
      expect(t, isNotNull);
      expect(t!.status, kTrainingRecorded, reason: 'a fresh training is recorded');
      expect(t.title, 'עבודה בגובה', reason: 'title is trimmed');
      expect(t.by, 'ממונה בטיחות', reason: 'by is trimmed');
      expect(t.doc, isNull);
      expect(n.state.single.id, t.id, reason: 'it landed in the log');
    });

    test('remove — drops the given training only', () async {
      final n = WorkerTrainingsNotifier(persist: false);
      final a = await n.add(
          username: 'ran', title: 'א', by: 'x', date: DateTime(2026, 1, 1));
      final b = await n.add(
          username: 'ran', title: 'ב', by: 'x', date: DateTime(2026, 2, 1));
      expect(n.state.length, 2);

      n.remove(a!.id);
      expect(n.state.map((t) => t.id), [b!.id],
          reason: 'only the targeted row is removed');
    });

    test('sendForApproval — recorded → pending; idempotent (no-op once sent)',
        () async {
      final n = WorkerTrainingsNotifier(persist: false);
      final t = await n.add(
          username: 'ran', title: 'א', by: 'x', date: DateTime(2026, 1, 1));
      expect(n.state.single.status, kTrainingRecorded);

      n.sendForApproval(t!.id);
      expect(n.state.single.status, kTrainingPending,
          reason: 'recorded flips to pending for the safety officer');

      // A second send must NOT regress/re-flip an already-pending row — the
      // guard is `status == recorded`, so this is a no-op.
      n.sendForApproval(t.id);
      expect(n.state.single.status, kTrainingPending,
          reason: 'sendForApproval only acts on a recorded row (idempotent)');
    });

    test('forUser — filters by username, newest first', () async {
      final n = WorkerTrainingsNotifier(persist: false);
      await n.add(
          username: 'ran', title: 'ישן', by: 'x', date: DateTime(2026, 1, 1));
      await n.add(
          username: 'ran', title: 'חדש', by: 'x', date: DateTime(2026, 6, 1));
      await n.add(
          username: 'omer', title: 'אחר', by: 'x', date: DateTime(2026, 3, 1));

      final mine = n.forUser('ran');
      expect(mine.map((t) => t.title), ['חדש', 'ישן'],
          reason: 'only ran, newest date first');
      expect(n.forUser('omer').map((t) => t.title), ['אחר']);
      expect(n.forUser('nobody'), isEmpty);
    });
  });

  // ── attachDoc ──────────────────────────────────────────────────────────────
  group('attachDoc', () {
    test('success — sets the doc data-URL on the training', () async {
      final n = WorkerTrainingsNotifier(persist: false);
      final t = await n.add(
          username: 'ran', title: 'א', by: 'x', date: DateTime(2026, 1, 1));
      final ok = await n.attachDoc(t!.id, 'data:image/png;base64,ATTACH=');
      expect(ok, true);
      expect(n.state.single.doc, 'data:image/png;base64,ATTACH=');
    });

    test('unknown id — returns false, leaves state untouched', () async {
      final n = WorkerTrainingsNotifier(persist: false);
      await n.add(
          username: 'ran', title: 'א', by: 'x', date: DateTime(2026, 1, 1));
      final before = n.state;
      final ok = await n.attachDoc('no-such-id', 'data:image/png;base64,Z=');
      expect(ok, false, reason: 'nothing to attach to → honest false');
      expect(identical(n.state, before), isTrue,
          reason: 'state object is untouched when the id is unknown');
    });

    test('FAILED persist → rollback (F-8) — doc not retained, false returned',
        () async {
      final n = WorkerTrainingsNotifier(persist: false);
      final t = await n.add(
          username: 'ran', title: 'א', by: 'x', date: DateTime(2026, 1, 1));
      expect(n.state.single.doc, isNull);

      final before = n.state;
      n.debugPersistOverride = () async => false; // simulated quota failure
      final ok = await n.attachDoc(t!.id, 'data:image/png;base64,HUGE=');
      expect(ok, false, reason: 'a failed persist must be reported honestly');
      expect(identical(n.state, before), isTrue,
          reason: 'the rollback restores the exact pre-attach state object');
      expect(n.state.single.doc, isNull,
          reason: 'the document that would not survive a reload is dropped');
    });

    test('add — FAILED persist rolls the new row back', () async {
      final n = WorkerTrainingsNotifier(persist: false);
      n.debugPersistOverride = () async => false;
      final t = await n.add(
          username: 'ran',
          title: 'א',
          by: 'x',
          date: DateTime(2026, 1, 1),
          doc: 'data:image/png;base64,HUGE=');
      expect(t, isNull, reason: 'a failed persist returns null');
      expect(n.state, isEmpty, reason: 'the unsaved row never lingers');
    });
  });

  // ── persistence ────────────────────────────────────────────────────────────
  group('persistence', () {
    test('round-trip — an add survives a simulated restart', () async {
      // Seed a non-empty store so the demo seed does NOT run (we assert our own
      // added row, plus the seed, survive a restart).
      SharedPreferences.setMockInitialValues({kWorkerTrainingsKey: '[]'});
      final c1 = ProviderContainer();
      final n1 = c1.read(workerTrainingsProvider.notifier);
      final t = await n1.add(
        username: 'ran',
        title: 'עבודה בגובה',
        by: 'ממונה בטיחות',
        date: DateTime(2026, 3, 12),
      );
      expect(t, isNotNull);
      await _settle(); // let _persist() finish before "shutting down"
      c1.dispose();

      // Byte-verify the persisted payload carries the row.
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString(kWorkerTrainingsKey)!) as List;
      expect(stored.length, 1);
      expect((stored.single as Map)['title'], 'עבודה בגובה');

      // Fresh container = fresh notifier → must reload from prefs (lazy —
      // touch the provider so _load() actually starts).
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(workerTrainingsProvider);
      await _settle();

      final restored = c2.read(workerTrainingsProvider).single;
      expect(restored.id, t!.id);
      expect(restored.title, 'עבודה בגובה');
      expect(restored.by, 'ממונה בטיחות');
      expect(restored.status, kTrainingRecorded);
    });

    test('DEMO-SEED — a FRESH (empty) store seeds 3 removable demo rows',
        () async {
      SharedPreferences.setMockInitialValues({}); // no persisted key at all
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(workerTrainingsProvider); // lazy — start its _load()
      await _settle();

      final rows = c.read(workerTrainingsProvider);
      expect(rows.length, 3, reason: 'an empty store is seeded with 3 demo rows');
      expect(rows.every((t) => t.username == kTrainingDemoUser), isTrue);
      expect(rows.every((t) => t.by == 'ממונה בטיחות'), isTrue);
      expect(rows.every((t) => t.status == kTrainingRecorded), isTrue);
      expect(
        rows.map((t) => t.title),
        containsAll(<String>['הדרכת בטיחות כללית באתר', 'עבודה בגובה', 'ציוד מגן אישי']),
      );

      // The seed is persisted (survives a reload) AND removable.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kWorkerTrainingsKey), isNotNull,
          reason: 'the seed is written so it survives a reload');
      c.read(workerTrainingsProvider.notifier).remove(rows.first.id);
      expect(c.read(workerTrainingsProvider).length, 2,
          reason: 'demo rows are removable like real ones');
    });

    test('corrupt persisted payload — load keeps an empty log, no crash',
        () async {
      SharedPreferences.setMockInitialValues({kWorkerTrainingsKey: '[broken'});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(workerTrainingsProvider); // lazy — start its _load()
      await _settle();
      expect(c.read(workerTrainingsProvider), isEmpty,
          reason: 'a corrupt payload is dropped, never thrown');
    });

    test('debugSeedDemo — hermetic in-memory variant seeds the demo rows', () {
      final n = WorkerTrainingsNotifier(persist: false);
      expect(n.state, isEmpty, reason: 'persist:false starts empty (no _load)');
      n.debugSeedDemo();
      expect(n.state.length, 3);
      expect(n.forUser(kTrainingDemoUser).length, 3);
    });
  });
}
