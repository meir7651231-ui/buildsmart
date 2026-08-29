// #hr — worker-cert wallet local→server migration (workerCerts/{workerUid}),
// mirrors worker_attendance_repository_test. Pins: (1) DORMANT with
// kUserDataServer OFF (provider → null → SharedPreferences, byte-identical), and
// (2) the WorkerCertsRepository round-trips the worker's certs through the neutral
// RemoteCollectionSource seam, stamping employerId; the employer roster flatten.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_certs_repository.dart';
import 'package:buildsmart/state/worker_certs.dart' show WorkerCert;
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
  final c1 = WorkerCert(
    id: 'cert-1',
    username: 'w-uid-1',
    name: 'עבודה בגובה',
    issuer: 'מכון התקנים',
    expiry: DateTime.utc(2027, 1, 1),
    addedTs: DateTime.utc(2026, 8, 13),
    employerId: 'contractor-9',
  );

  group('#hr worker-certs migration is DORMANT off', () {
    test(
        'workerCertsRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— the wallet stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(workerCertsRepositoryProvider), isNull);
    });
  });

  group('#hr WorkerCertsRepository round-trip (workerCerts/{uid})', () {
    test('saveMine writes {certs,employerId,updatedAt}; loadMine decodes back',
        () async {
      final src = _FakeSource();
      final repo = WorkerCertsRepository(
        src,
        currentUid: 'w-uid-1',
        employerId: 'contractor-9',
      );

      await repo.saveMine([c1]);
      final doc = src.docs['w-uid-1']!;
      expect((doc['certs'] as List).length, 1);
      expect(doc['employerId'], 'contractor-9'); // the employer scope key
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.loadMine();
      expect(back.length, 1);
      expect(back.single.name, 'עבודה בגובה');
      expect(back.single.issuer, 'מכון התקנים');
      expect(back.single.employerId, 'contractor-9');
    });

    test('loadMine with no doc ⇒ empty list (never throws)', () async {
      final repo = WorkerCertsRepository(
        _FakeSource(),
        currentUid: 'w-uid-1',
        employerId: '',
      );
      expect(await repo.loadMine(), isEmpty);
    });
  });

  group('#hr flattenEmployerDocs (the employer roster flatten)', () {
    test("flattens MANY workers' wallets into one cert list", () {
      final flat = WorkerCertsRepository.flattenEmployerDocs(const [
        RemoteDoc('w-1', {
          'employerId': 'contractor-9',
          'certs': [
            {'id': 'a', 'username': 'w-1', 'name': 'x', 'issuer': 'i',
             'expiry': '2027-01-01T00:00:00.000Z', 'addedTs': '2026-08-13T00:00:00.000Z'},
          ],
        }),
        RemoteDoc('w-2', {
          'employerId': 'contractor-9',
          'certs': [
            {'id': 'b', 'username': 'w-2', 'name': 'y', 'issuer': 'i',
             'expiry': '2027-01-01T00:00:00.000Z', 'addedTs': '2026-08-13T00:00:00.000Z'},
          ],
        }),
      ]);
      expect(flat.length, 2);
      expect(flat.map((c) => c.username).toSet(), {'w-1', 'w-2'});
    });

    test('a doc with no/invalid certs contributes nothing', () {
      final flat = WorkerCertsRepository.flattenEmployerDocs(const [
        RemoteDoc('w-1', {'employerId': 'c'}),
        RemoteDoc('w-2', {'certs': 'not-a-list'}),
      ]);
      expect(flat, isEmpty);
    });
  });
}
