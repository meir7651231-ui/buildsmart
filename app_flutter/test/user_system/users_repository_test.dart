// U0.2 — the users/{uid} repository: the in-memory impl + the Firestore impl
// (over a fake source) with its RULES-SAFE partial writes. Zero backend.

import 'dart:async';

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [RemoteCollectionSource] over `users`: records every write and
/// lets a test push snapshots. Scoped by default (the self-doc listen).
class _FakeUsersSource implements RemoteCollectionSource {
  final StreamController<List<RemoteDoc>> _controller =
      StreamController<List<RemoteDoc>>.broadcast();
  final List<MapEntry<String, Map<String, dynamic>>> writes =
      <MapEntry<String, Map<String, dynamic>>>[];
  final List<String> deletes = <String>[];

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    writes.add(MapEntry(id, data));
  }

  @override
  Future<void> delete(String id) async => deletes.add(id);

  @override
  bool get isScoped => true;

  void emit(List<RemoteDoc> docs) => _controller.add(docs);
}

void main() {
  group('LocalUsersRepository', () {
    test('ensureUser creates a pending record, byUid/currentUser read it back',
        () async {
      final repo = LocalUsersRepository(currentUid: 'u1');
      expect(repo.currentUser(), isNull);
      await repo.ensureUser(const BsUser(uid: 'u1', name: 'משה'));
      expect(repo.byUid('u1')!.name, 'משה');
      expect(repo.currentUser()!.status, UserStatus.pending);
    });

    test('ensureUser NEVER clobbers an existing record (no self-downgrade)',
        () async {
      final repo = LocalUsersRepository(currentUid: 'u1')
        ..upsertUser(
            const BsUser(uid: 'u1', role: 'store', status: UserStatus.active));
      await repo.ensureUser(const BsUser(uid: 'u1')); // a fresh pending seed
      // The server-assigned active/store survives the re-login.
      expect(repo.byUid('u1')!.status, UserStatus.active);
      expect(repo.byUid('u1')!.role, 'store');
    });

    test('touchLastSeen updates only lastSeen of a known record', () {
      final repo = LocalUsersRepository(currentUid: 'u1')
        ..upsertUser(const BsUser(uid: 'u1', name: 'a'));
      final t = DateTime.fromMillisecondsSinceEpoch(1710000000000);
      repo.touchLastSeen('u1', t);
      expect(repo.byUid('u1')!.lastSeen, t);
      expect(repo.byUid('u1')!.name, 'a');
    });

    test('touchLastSeen is a no-op for an unknown uid', () {
      final repo = LocalUsersRepository(currentUid: 'u1')
        ..touchLastSeen('ghost', DateTime.fromMillisecondsSinceEpoch(1));
      expect(repo.byUid('ghost'), isNull);
    });
  });

  group('FirestoreUsersRepository (fake source)', () {
    test('a snapshot flows into the cache; currentUser serves the self-doc',
        () async {
      final src = _FakeUsersSource();
      final repo = FirestoreUsersRepository(src, currentUid: 'u1')..attach();
      addTearDown(repo.dispose);

      src.emit([
        const RemoteDoc('u1', {'displayName': 'משה', 'status': 'active'}),
      ]);
      await pumpEventQueue();

      expect(repo.currentUser()!.name, 'משה');
      expect(repo.currentUser()!.status, UserStatus.active);
      expect(repo.byUid('u1')!.uid, 'u1');
    });

    test('ensureUser writes a rules-safe CREATE map: pending + no authority fields',
        () async {
      final src = _FakeUsersSource();
      final repo = FirestoreUsersRepository(src, currentUid: 'u1')..attach();
      addTearDown(repo.dispose);

      final now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
      await repo.ensureUser(BsUser(
        uid: 'u1',
        name: 'משה',
        phone: '0501234567',
        // Even if a caller passes these, the create map must DROP them:
        role: 'store',
        storeUid: 'store-x',
        orgId: 'org-1',
        status: UserStatus.active,
        createdAt: now,
        lastSeen: now,
      ));

      expect(src.writes, hasLength(1));
      final data = src.writes.single.value;
      expect(src.writes.single.key, 'u1');
      expect(data['status'], 'pending'); // pinned — never 'active' on self-create
      expect(data['displayName'], 'משה');
      expect(data['phone'], '0501234567');
      expect(data.containsKey('role'), isFalse);
      expect(data.containsKey('storeUid'), isFalse);
      expect(data.containsKey('orgId'), isFalse);
      expect(data['createdAt'], now.millisecondsSinceEpoch);
    });

    test('ensureUser does NOT write when the doc already exists in cache',
        () async {
      final src = _FakeUsersSource();
      final repo = FirestoreUsersRepository(src, currentUid: 'u1')..attach();
      addTearDown(repo.dispose);

      src.emit([const RemoteDoc('u1', {'status': 'active'})]);
      await pumpEventQueue();

      await repo.ensureUser(const BsUser(uid: 'u1'));
      expect(src.writes, isEmpty); // exists → no create, no clobber
    });

    test('touchLastSeen writes ONLY {lastSeen} (a rules-safe update)', () async {
      final src = _FakeUsersSource();
      final repo = FirestoreUsersRepository(src, currentUid: 'u1')..attach();
      addTearDown(repo.dispose);

      final t = DateTime.fromMillisecondsSinceEpoch(1710000000000);
      repo.touchLastSeen('u1', t);
      await pumpEventQueue();

      expect(src.writes, hasLength(1));
      expect(src.writes.single.value.keys, ['lastSeen']);
      expect(src.writes.single.value['lastSeen'], t.millisecondsSinceEpoch);
    });
  });
}
