// Wave T3 (FOUNDATION) — the Firestore-backed §6 tasks repo. Pins the byte-
// fidelity contract the engine's bindRemote seam depends on: (1) toDoc/fromDoc
// round-trip every TaskItem field (a seed task AND a full runtime task with the
// whole lifecycle payload), (2) the int id ⇄ string doc-id mapping, (3) the cache
// is born seeded and served by all(), (4) optimistic upsert/removeById reflect
// into all(), and (5) fromDoc rejects a structurally-bad doc so the base skips it.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/tasks_firebase.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal in-memory source — never streams (the tests drive the cache through
/// the base's optimistic writes, not through snapshots).
class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};

  @override
  Stream<List<RemoteDoc>> snapshots() =>
      const Stream<List<RemoteDoc>>.empty();

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    docs[id] = {...?docs[id], ...data};
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => false;
}

void main() {
  group('#taskT3 toDoc/fromDoc byte-fidelity', () {
    test('a SEED task round-trips through toDoc→doc→fromDoc unchanged', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      final seed = buildTasksSeed();
      final t = seed.firstWhere((x) => x.status == 'done'); // has photo='demo'

      final doc = repo.toDoc(t);
      expect(doc.containsKey('id'), isFalse, reason: 'id is the doc-id');
      final back = repo.fromDoc(RemoteDoc(repo.idOf(t), doc));

      expect(back.id, t.id);
      expect(back.name, t.name);
      expect(back.detail, t.detail);
      expect(back.worker, t.worker);
      expect(back.status, t.status);
      expect(back.days, t.days);
      expect(back.steps, t.steps);
      expect(back.photo, t.photo);
      expect(back.orderId, t.orderId);
    });

    test('a FULL runtime task (every lifecycle field) round-trips unchanged', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      final t = TaskItem(
        id: 42,
        name: 'התקנת דוד',
        detail: 'פרטים',
        worker: 1,
        status: 'review',
        days: 3,
        steps: const ['שלב א', 'שלב ב'],
        photo: 'data:image/png;base64,AAAA',
        note: 'הערת עובד',
        startedAt: DateTime.parse('2026-08-01T08:00:00.000Z'),
        completedAt: DateTime.parse('2026-08-01T12:30:00.000Z'),
        doneSteps: const {0, 1},
        orderId: 'BS-1040',
        employerId: 'emp-uid-1',
        assignedWorkerUid: 'wrk-uid-9',
        createdBy: 'contractor',
        scheduledStart: DateTime.parse('2026-08-02T06:00:00.000Z'),
        kind: 'defect',
        location: 'אמבטיה ראשית',
        severity: 'חמור',
      );

      final back = repo.fromDoc(RemoteDoc(repo.idOf(t), repo.toDoc(t)));

      expect(repo.idOf(t), '42');
      expect(back.id, 42);
      expect(back.name, t.name);
      expect(back.status, 'review');
      expect(back.photo, t.photo);
      expect(back.note, t.note);
      expect(back.startedAt, t.startedAt);
      expect(back.completedAt, t.completedAt);
      expect(back.doneSteps, t.doneSteps);
      expect(back.orderId, 'BS-1040');
      expect(back.employerId, 'emp-uid-1');
      expect(back.assignedWorkerUid, 'wrk-uid-9');
      expect(back.createdBy, 'contractor');
      expect(back.scheduledStart, t.scheduledStart);
      expect(back.kind, 'defect');
      expect(back.location, 'אמבטיה ראשית');
      expect(back.severity, 'חמור');
    });
  });

  group('#taskT3 cache born seeded + optimistic writes', () {
    test('all() serves the born-seeded cache in ascending id order', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      final all = repo.all();
      expect(all, isNotEmpty);
      final ids = [for (final t in all) t.id];
      final sorted = [...ids]..sort();
      expect(ids, sorted, reason: 'sortBy keeps numeric id order');
    });

    test('upsert reflects a new task into all(); removeById drops it', () {
      final src = _FakeSource();
      final repo = FirebaseTasksRepository(source: src);
      final before = repo.all().length;

      final t = TaskItem(
        id: 99,
        name: 'משימת ריצה',
        detail: '',
        worker: 0,
        status: 'pending',
        days: 1,
        steps: const [],
      );
      repo.upsert(t);
      expect(repo.all().any((x) => x.id == 99), isTrue);
      expect(repo.all().length, before + 1);
      expect(src.docs.containsKey('99'), isTrue, reason: 'background set fired');

      repo.removeById('99');
      expect(repo.all().any((x) => x.id == 99), isFalse);
    });
  });

  group('#taskT3 fromDoc rejects a bad doc (base skips it)', () {
    test('a non-numeric doc-id throws', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      expect(
        () => repo.fromDoc(RemoteDoc('not-an-int', {'name': 'x'})),
        throwsFormatException,
      );
    });

    test('a structurally-bad doc (no name) throws', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      expect(
        () => repo.fromDoc(RemoteDoc('7', {'status': 'pending'})),
        throwsFormatException,
      );
    });
  });
}
