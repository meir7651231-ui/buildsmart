// #hr — the FIRST worker-HR local→server migration (a worker's own attendance
// ledger → workerAttendance/{workerUid}). Two things pinned: (1) the migration is
// DORMANT with kUserDataServer OFF (the provider yields null → the ledger keeps
// its SharedPreferences path, byte-identical), and (2) the
// WorkerAttendanceRepository round-trips the worker's days through the neutral
// RemoteCollectionSource seam, STAMPING the employerId every write (so the
// employer roster query — next slice — can scope to it). Firebase-free.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_attendance_repository.dart';
import 'package:buildsmart/state/worker_attendance.dart' show AttendanceDay;
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
    docs[id] = {...?docs[id], ...data}; // merge:true contract
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true;
}

void main() {
  final d1 = AttendanceDay(
    username: 'w-uid-1',
    date: '2026-08-13',
    inTs: DateTime.utc(2026, 8, 13, 6),
    outTs: DateTime.utc(2026, 8, 13, 15),
    inLat: 32.1,
    inLng: 34.8,
    employerId: 'contractor-9',
  );

  group('#hr worker-attendance migration is DORMANT off', () {
    test(
        'workerAttendanceRepositoryProvider OFF (kUserDataServer const-false) ⇒ '
        'null — the ledger stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(workerAttendanceRepositoryProvider), isNull);
    });
  });

  group('#hr WorkerAttendanceRepository round-trip (workerAttendance/{uid})', () {
    test('saveMine writes {days,employerId,updatedAt}; loadMine decodes back',
        () async {
      final src = _FakeSource();
      final repo = WorkerAttendanceRepository(
        src,
        currentUid: 'w-uid-1',
        employerId: 'contractor-9',
      );

      await repo.saveMine([d1]);
      final doc = src.docs['w-uid-1']!;
      expect((doc['days'] as List).length, 1);
      // THE EMPLOYER SCOPE: the roster query keys on this field.
      expect(doc['employerId'], 'contractor-9');
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.loadMine();
      expect(back.length, 1);
      expect(back.single.date, '2026-08-13');
      expect(back.single.employerId, 'contractor-9');
      expect(back.single.inLat, 32.1);
      expect(back.single.worked, const Duration(hours: 9));
    });

    test('loadMine with no doc ⇒ empty list (never throws)', () async {
      final repo = WorkerAttendanceRepository(
        _FakeSource(),
        currentUid: 'w-uid-1',
        employerId: '',
      );
      expect(await repo.loadMine(), isEmpty);
    });

    test('a malformed day row is skipped (per-entry tolerant)', () async {
      final src = _FakeSource();
      await src.set('w-uid-1', {
        'employerId': 'contractor-9',
        'days': [
          {'username': 'ok', 'date': '2026-08-13'},
          {'username': 42}, // structural-invalid → dropped
          'not-a-map', // wrong type → dropped
        ],
      });
      final repo = WorkerAttendanceRepository(
        src,
        currentUid: 'w-uid-1',
        employerId: 'contractor-9',
      );
      final back = await repo.loadMine();
      expect(back.length, 1);
      expect(back.single.username, 'ok');
    });
  });

  group('#hr slice B — flattenEmployerDocs (the employer roster flatten)', () {
    test('flattens MANY workers\' docs into one day list', () {
      final docs = [
        const RemoteDoc('w-1', {
          'employerId': 'contractor-9',
          'days': [
            {'username': 'w-1', 'date': '2026-08-13'},
            {'username': 'w-1', 'date': '2026-08-12'},
          ],
        }),
        const RemoteDoc('w-2', {
          'employerId': 'contractor-9',
          'days': [
            {'username': 'w-2', 'date': '2026-08-13'},
          ],
        }),
      ];
      final flat = WorkerAttendanceRepository.flattenEmployerDocs(docs);
      expect(flat.length, 3); // 2 + 1 workers' days merged
      expect(flat.map((d) => d.username).toSet(), {'w-1', 'w-2'});
    });

    test('a doc with no/invalid days contributes nothing (never throws)', () {
      final flat = WorkerAttendanceRepository.flattenEmployerDocs(const [
        RemoteDoc('w-1', {'employerId': 'c-9'}), // no days key
        RemoteDoc('w-2', {'days': 'not-a-list'}), // wrong type
      ]);
      expect(flat, isEmpty);
    });
  });
}
