// FIRESTORE CACHE-PATTERN (SERVER-SWAP Z) — unit coverage for the material-
// requests `_firebase` repo [FirebaseMaterialRequestsRepository] over the
// offline-first cache base, PLUS the engine delegation ([MaterialRequestsNotifier]
// bound to the repo) and the Firebase-free byte-identity of the provider.
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages
// (mirrors stock_firebase_repo_test / the orders pilot).
//
// Pins:
//   • the queue is BORN EMPTY (a material request only exists once filed);
//   • submit drops empty item lines, mints 'mat-…', status 'requested', writes;
//   • setStatus guards a known status + a non-terminal request (else no-op);
//   • a snapshot REPLACES the cache in createdTs order; a corrupt doc is SKIPPED;
//   • a write FAILURE corrupts neither cache nor throws;
//   • a BOUND notifier routes submit/setStatus THROUGH the repo (worker↔contractor
//     both see the live cache), not the in-memory fork;
//   • WITHOUT Firebase the provider's notifier is UNBOUND → the local engine is
//     byte-identical (submit persists to state, no repo).

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/material_requests_firebase.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [RemoteCollectionSource] — a manually-driven broadcast
/// stream + an in-memory record of writes (copy of the stock/orders test fake).
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];
  final List<String> deletes = [];
  bool failNextSet = false;

  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    if (failNextSet) {
      failNextSet = false;
      throw StateError('boom (simulated write failure)');
    }
    sets.add(MapEntry(id, data));
  }

  @override
  Future<void> delete(String id) async => deletes.add(id);

  @override
  bool get isScoped => false;

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseMaterialRequestsRepository — queue (empty · submit · status)',
      () {
    FirebaseMaterialRequestsRepository repo(_FakeSource src) =>
        FirebaseMaterialRequestsRepository(source: src);

    test('cache born EMPTY (no demo seed)', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);
      expect(r.all(), isEmpty);
      expect(r.seed, isEmpty);
    });

    test('submit drops empty lines, mints mat- id, status requested, writes',
        () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final id = r.submit(
        employerId: 'contractor-demo',
        workerUid: '',
        username: 'ran',
        workerName: 'רן',
        items: ['ברזל 12', '  ', 'צינור', ''], // 2 blanks dropped
      );
      expect(id, startsWith('mat-'));
      expect(r.all().length, 1);
      final req = r.all().single;
      expect(req.items, ['ברזל 12', 'צינור']); // whitespace/empty dropped
      expect(req.status, kMatReqRequested);
      expect(req.employerId, 'contractor-demo');

      await Future<void>.delayed(Duration.zero);
      expect(src.sets, isNotEmpty); // rode the repo's Firestore write
      expect(src.sets.single.key, id);
      expect(src.sets.single.value['status'], kMatReqRequested);
    });

    test('setStatus advances a non-terminal request; guards the rest', () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final id = r.submit(
        employerId: 'c',
        workerUid: '',
        username: 'ran',
        workerName: 'רן',
        items: ['x'],
      );
      // requested → ordered (a real advance).
      r.setStatus(id, kMatReqOrdered);
      expect(r.all().single.status, kMatReqOrdered);

      // an UNKNOWN status is rejected (no-op).
      r.setStatus(id, 'bogus');
      expect(r.all().single.status, kMatReqOrdered);

      // ordered → supplied (terminal), then a further advance is refused.
      r.setStatus(id, kMatReqSupplied);
      expect(r.all().single.status, kMatReqSupplied);
      r.setStatus(id, kMatReqOrdered); // terminal → no re-open
      expect(r.all().single.status, kMatReqSupplied);

      // an unknown id is a no-op (no crash).
      r.setStatus('mat-nope', kMatReqOrdered);
      expect(r.all().single.status, kMatReqSupplied);
    });

    test('a snapshot REPLACES the cache in createdTs order', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      // Two docs out of createdTs order — the base re-sorts ascending.
      src.emit([
        const RemoteDoc('mat-2', {
          'id': 'mat-2',
          'employerId': 'c',
          'workerUid': '',
          'username': 'ran',
          'workerName': 'רן',
          'items': ['b'],
          'note': '',
          'createdTs': 200,
          'status': kMatReqRequested,
        }),
        const RemoteDoc('mat-1', {
          'id': 'mat-1',
          'employerId': 'c',
          'workerUid': '',
          'username': 'omer',
          'workerName': 'עומר',
          'items': ['a'],
          'note': '',
          'createdTs': 100,
          'status': kMatReqOrdered,
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.all().map((e) => e.id).toList(), ['mat-1', 'mat-2']); // ts asc
      expect(r.all().first.status, kMatReqOrdered);
    });

    test('a corrupt doc is SKIPPED — never blanks the queue', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      src.emit([
        const RemoteDoc('mat-ok', {
          'id': 'mat-ok',
          'employerId': 'c',
          'workerUid': '',
          'username': 'ran',
          'workerName': 'רן',
          'items': ['a'],
          'createdTs': 100,
          'status': kMatReqRequested,
        }),
        // missing createdTs → tryFromJson returns null → fromDoc throws → skipped.
        const RemoteDoc('mat-bad', {
          'id': 'mat-bad',
          'employerId': 'c',
          'workerUid': '',
          'workerName': 'רן',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(r.all().map((e) => e.id).toList(), ['mat-ok']);
    });

    test('a write FAILURE corrupts neither cache nor throws', () async {
      final src = _FakeSource()..failNextSet = true;
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final id = r.submit(
        employerId: 'c',
        workerUid: '',
        username: 'ran',
        workerName: 'רן',
        items: ['x'],
      );
      expect(r.all().single.id, id); // optimistic cache intact
      await Future<void>.delayed(Duration.zero);
      expect(src.sets, isEmpty); // the failing set was NOT recorded, nothing threw
    });
  });

  group('MaterialRequestsNotifier — delegates THROUGH the bound repo', () {
    test('bound submit/setStatus route through the repo + mirror its cache',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final src = _FakeSource();
      final r = FirebaseMaterialRequestsRepository(source: src);
      final n = MaterialRequestsNotifier()..bindRemote(r);
      addTearDown(src.close);
      addTearDown(n.dispose);
      addTearDown(r.dispose);

      final id = n.submit(
        employerId: 'contractor-demo',
        workerUid: '',
        username: 'ran',
        workerName: 'רן',
        items: ['ברזל'],
      );
      // DELEGATED: the notifier state mirrors the repo cache synchronously.
      expect(n.state.single.id, id);
      expect(r.all().single.id, id);
      await Future<void>.delayed(Duration.zero);
      expect(src.sets.map((e) => e.key), contains(id)); // rode the repo write

      n.setStatus(id, kMatReqOrdered);
      expect(n.state.single.status, kMatReqOrdered); // via the repo, not the fork
      expect(r.all().single.status, kMatReqOrdered);
    });
  });

  group('materialRequestsProvider — Firebase-free path (byte-identity)', () {
    test('the notifier is UNBOUND without Firebase → the local engine runs',
        () async {
      // The whole suite runs without Firebase.initializeApp → useFirebaseBackend
      // is false → nothing is bound, so submit takes the verbatim LOCAL path.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final n = c.read(materialRequestsProvider.notifier);
      final id = n.submit(
        employerId: 'c',
        workerUid: '',
        username: 'ran',
        workerName: 'רן',
        items: ['x', ''],
      );
      // Local engine behaviour is intact (id minted, empty line dropped, stored).
      expect(id, startsWith('mat-'));
      expect(c.read(materialRequestsProvider).single.items, ['x']);
      expect(c.read(materialRequestsProvider).single.status, kMatReqRequested);
    });
  });
}
