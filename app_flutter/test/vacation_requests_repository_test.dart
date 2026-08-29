// #hr — vacation-requests CROSS-PARTY local→server migration
// (vacationRequests/{requestId}). The worker SUBMITS (create); the manager /
// employer DECIDES (update status). Pins: (1) DORMANT with kUserDataServer OFF
// (provider → null → SharedPreferences, byte-identical), (2) the repo round-trips
// a submit through the neutral seam and a decide MERGES the status flip without
// losing the owner/employer keys, and (3) decodeDocs flattens an employer slice.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/vacation_requests_repository.dart';
import 'package:buildsmart/state/vacation_requests.dart';
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
    docs[id] = {...?docs[id], ...data}; // merge — the RemoteCollectionSource.set contract
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true;
}

VacationRequest _req(String id, {String status = kVacationPending}) =>
    VacationRequest(
      id: id,
      username: 'w-uid-1',
      workerName: 'רן',
      from: DateTime.utc(2026, 8, 20),
      to: DateTime.utc(2026, 8, 22),
      reason: 'חופש',
      createdTs: DateTime.utc(2026, 8, 13),
      employerId: 'contractor-9',
      status: status,
    );

void main() {
  group('#hr vacation migration is DORMANT off', () {
    test('vacationRequestsRepositoryProvider OFF (kUserDataServer const-false) ⇒ '
        'null — the queue stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(vacationRequestsRepositoryProvider), isNull);
    });
  });

  group('#hr VacationRequestsRepository submit + decide (vacationRequests/{id})',
      () {
    test('submit creates the doc keyed by request-id; loadScoped decodes it back',
        () async {
      final src = _FakeSource();
      final repo = VacationRequestsRepository(src);

      await repo.submit(_req('vac-1'));
      expect(src.docs.containsKey('vac-1'), isTrue);
      expect(src.docs['vac-1']!['username'], 'w-uid-1');
      expect(src.docs['vac-1']!['employerId'], 'contractor-9');
      expect(src.docs['vac-1']!['status'], kVacationPending);

      final back = await repo.loadScoped();
      expect(back.single.id, 'vac-1');
      expect(back.single.status, kVacationPending);
    });

    test('decide MERGES the status flip, keeping username/employerId intact',
        () async {
      final src = _FakeSource();
      final repo = VacationRequestsRepository(src);
      await repo.submit(_req('vac-1'));

      await repo.decide('vac-1', kVacationApproved, DateTime.utc(2026, 8, 14));
      final doc = src.docs['vac-1']!;
      expect(doc['status'], kVacationApproved);
      expect(doc['decidedTs'], '2026-08-14T00:00:00.000Z');
      // The merge must NOT drop the owner/employer keys the rule reads.
      expect(doc['username'], 'w-uid-1');
      expect(doc['employerId'], 'contractor-9');

      final back = await repo.loadScoped();
      expect(back.single.status, kVacationApproved);
      expect(back.single.decidedTs, DateTime.utc(2026, 8, 14));
    });
  });

  group('#hr decodeDocs (the employer roster flatten)', () {
    test('flattens MANY request docs; a malformed one is dropped', () {
      final flat = VacationRequestsRepository.decodeDocs([
        RemoteDoc('vac-1', _req('vac-1').toJson()),
        RemoteDoc('vac-2', _req('vac-2').toJson()),
        const RemoteDoc('bad', {'garbage': true}), // no id/username/… → dropped
      ]);
      expect(flat.length, 2);
      expect(flat.map((r) => r.id).toSet(), {'vac-1', 'vac-2'});
    });
  });
}
