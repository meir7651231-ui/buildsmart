// #hr — worker safety-training log local→server migration
// (workerTrainings/{workerUid}), mirrors worker_certs_repository_test. Pins:
// (1) DORMANT with kUserDataServer OFF (provider → null → SharedPreferences,
// byte-identical), and (2) the WorkerTrainingsRepository round-trips the worker's
// trainings through the neutral RemoteCollectionSource seam, stamping employerId;
// the employer roster flatten.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_trainings_repository.dart';
import 'package:buildsmart/state/worker_trainings.dart' show WorkerTraining;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(
        [for (final e in docs.entries) RemoteDoc(e.key, e.value)],
      );

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    docs[id] = {...?docs[id], ...data};
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true;
}

void main() {
  final t1 = WorkerTraining(
    id: 'train-1',
    username: 'w-uid-1',
    title: 'עבודה בגובה',
    by: 'ממונה בטיחות',
    date: DateTime.utc(2026, 3, 12),
    employerId: 'contractor-9',
  );

  group('#hr worker-trainings migration is DORMANT off', () {
    test(
        'workerTrainingsRepositoryProvider OFF (kUserDataServer const-false) ⇒ '
        'null — the log stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(workerTrainingsRepositoryProvider), isNull);
    });
  });

  group('#hr WorkerTrainingsRepository round-trip (workerTrainings/{uid})', () {
    test(
        'saveMine writes {trainings,employerId,updatedAt}; loadMine decodes back',
        () async {
      final src = _FakeSource();
      final repo = WorkerTrainingsRepository(
        src,
        currentUid: 'w-uid-1',
        employerId: 'contractor-9',
      );

      await repo.saveMine([t1]);
      final doc = src.docs['w-uid-1']!;
      expect((doc['trainings'] as List).length, 1);
      expect(doc['employerId'], 'contractor-9'); // the employer scope key
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.loadMine();
      expect(back.length, 1);
      expect(back.single.title, 'עבודה בגובה');
      expect(back.single.by, 'ממונה בטיחות');
      expect(back.single.employerId, 'contractor-9');
    });

    test('loadMine with no doc ⇒ empty list (never throws)', () async {
      final repo = WorkerTrainingsRepository(
        _FakeSource(),
        currentUid: 'w-uid-1',
        employerId: '',
      );
      expect(await repo.loadMine(), isEmpty);
    });
  });

  group('#hr flattenEmployerDocs (the employer roster flatten)', () {
    test("flattens MANY workers' logs into one training list", () {
      final flat = WorkerTrainingsRepository.flattenEmployerDocs(const [
        RemoteDoc('w-1', {
          'employerId': 'contractor-9',
          'trainings': [
            {'id': 'a', 'username': 'w-1', 'title': 'x', 'by': 'i',
             'date': '2026-03-12T00:00:00.000Z'},
          ],
        }),
        RemoteDoc('w-2', {
          'employerId': 'contractor-9',
          'trainings': [
            {'id': 'b', 'username': 'w-2', 'title': 'y', 'by': 'i',
             'date': '2026-03-12T00:00:00.000Z'},
          ],
        }),
      ]);
      expect(flat.length, 2);
      expect(flat.map((t) => t.username).toSet(), {'w-1', 'w-2'});
    });

    test('a doc with no/invalid trainings contributes nothing', () {
      final flat = WorkerTrainingsRepository.flattenEmployerDocs(const [
        RemoteDoc('w-1', {'employerId': 'c'}),
        RemoteDoc('w-2', {'trainings': 'not-a-list'}),
      ]);
      expect(flat, isEmpty);
    });
  });
}
