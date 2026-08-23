// A7 (launch uid-migration) — focused coverage for [UsersLookup], the
// counterparty → uid directory over the `users` collection. A4 (orders
// storeId/courierId = uid) and A8 (chat participants = uids) will later RESOLVE
// "who is the store/courier" through it; A7 only builds + exposes the lookup, so
// it must be ADDITIVE and Firebase-free-safe:
//   • uidByPhone returns the matching `users` doc-id (= auth.uid) on a HIT and
//     null on a MISS (no doc with that phone);
//   • the optional role filter narrows the phone match (the STORE at a phone,
//     not a same-phone courier) and EXCLUDES a doc with no/other role;
//   • uidsByRole returns every doc-id carrying a role (the "who are the stores"
//     query), in document order, [] when none;
//   • a backend hiccup (stream error) is swallowed to the not-found answer,
//     never thrown (HARD RULE #3);
//   • the PROVIDER resolves to null without the live backend — the same
//     `useFirebaseBackend` gate every repo provider uses (zero regression: the
//     Firebase-free suite never touches Firestore).
//
// No Firebase here: the lookup's [RemoteCollectionSource] seam is driven by the
// SAME hand-rolled fake the S2/A3/A8 tests use — a `users` dataset emitted as
// neutral [RemoteDoc]s — so the directory is fully unit-testable with no
// fake_cloud_firestore and no new packages.

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hand-rolled fake [RemoteCollectionSource] (the S2/A8 base-test fake
/// shape): a broadcast stream we seed with a `users` snapshot + a write record.
/// `set`/`delete` are unused by the read-only lookup but kept to satisfy the
/// port. [failSnapshots] exercises the swallow-to-empty path.
class _FakeUsersSource implements RemoteCollectionSource {
  _FakeUsersSource(this._docs);

  final List<RemoteDoc> _docs;

  /// When true, `snapshots()` errors — to prove a backend hiccup → not-found,
  /// never a throw (HARD RULE #3).
  bool failSnapshots = false;

  @override
  Stream<List<RemoteDoc>> snapshots() {
    if (failSnapshots) {
      return Stream<List<RemoteDoc>>.error(
        StateError('boom (simulated users read failure)'),
      );
    }
    return Stream<List<RemoteDoc>>.value(_docs);
  }

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;
}

/// A small `users` directory: doc-id = auth.uid, fields mirror the welcome flow
/// ({displayName, phone}) plus an admin-assigned `role` on some.
RemoteDoc _user(String uid, {String? phone, String? role, String? name}) =>
    RemoteDoc(uid, {
      if (name != null) 'displayName': name,
      if (phone != null) kUsersPhoneField: phone,
      if (role != null) kUsersRoleField: role,
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A representative directory: a store + a courier + a manager + a
  // mirror-only contractor (no role), plus a courier that SHARES the store's
  // phone (so the role filter has something to disambiguate).
  List<RemoteDoc> sampleUsers() => [
        _user('uid-store', phone: '050-1111111', role: 'store', name: 'חנות א'),
        _user('uid-courier', phone: '052-2222222', role: 'courier'),
        _user('uid-manager', phone: '053-3333333', role: 'admin'),
        _user('uid-contractor', phone: '054-4444444', name: 'יוסי'),
        _user('uid-courier-dup', phone: '050-1111111', role: 'courier'),
      ];

  group('UsersLookup.uidByPhone', () {
    test('HIT — returns the doc-id (auth.uid) of the matching phone', () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      expect(await lookup.uidByPhone('052-2222222'), 'uid-courier');
      expect(
        await lookup.uidByPhone('054-4444444'),
        'uid-contractor',
        reason: 'a mirror-only (roleless) user is still found by phone',
      );
    });

    test('MISS — null when no users doc carries that phone', () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      expect(await lookup.uidByPhone('099-0000000'), isNull);
    });

    test('an EMPTY phone is never matched (short-circuits to null)', () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      expect(await lookup.uidByPhone(''), isNull);
    });

    test('role filter NARROWS the phone match (store vs same-phone courier)',
        () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      // Two docs share 050-1111111; the role picks the right counterparty.
      expect(
        await lookup.uidByPhone('050-1111111', role: 'store'),
        'uid-store',
      );
      expect(
        await lookup.uidByPhone('050-1111111', role: 'courier'),
        'uid-courier-dup',
      );
    });

    test('role filter EXCLUDES a phone match that lacks/mismatches the role',
        () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      // The contractor has the phone but NO role → no store/courier match.
      expect(await lookup.uidByPhone('054-4444444', role: 'store'), isNull);
      expect(
        await lookup.uidByPhone('052-2222222', role: 'store'),
        isNull,
        reason: 'the courier phone is not a store',
      );
    });
  });

  group('UsersLookup.uidsByRole', () {
    test('returns every doc-id carrying the role, in document order', () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      expect(
        await lookup.uidsByRole('courier'),
        ['uid-courier', 'uid-courier-dup'],
      );
      expect(await lookup.uidsByRole('store'), ['uid-store']);
      expect(await lookup.uidsByRole('admin'), ['uid-manager']);
    });

    test('[] when no user carries the role', () async {
      final lookup = UsersLookup(_FakeUsersSource(sampleUsers()));
      expect(
        await lookup.uidsByRole('contractor'),
        isEmpty,
        reason: 'the roleless contractor doc carries no role field',
      );
    });
  });

  group('UsersLookup — failure & empty handling (HARD RULE #3)', () {
    test('a snapshot ERROR is swallowed to the not-found answer', () async {
      final src = _FakeUsersSource(sampleUsers())..failSnapshots = true;
      final lookup = UsersLookup(src);
      // A backend hiccup must read as "directory unavailable", never throw.
      expect(await lookup.uidByPhone('052-2222222'), isNull);
      expect(await lookup.uidsByRole('courier'), isEmpty);
    });

    test('an EMPTY users collection → null / []', () async {
      final lookup = UsersLookup(_FakeUsersSource(const []));
      expect(await lookup.uidByPhone('052-2222222'), isNull);
      expect(await lookup.uidsByRole('store'), isEmpty);
    });
  });

  group('usersLookupProvider — Firebase-free path', () {
    test('resolves to null when Firebase is not initialised', () {
      // The whole suite runs without Firebase.initializeApp → Firebase.apps is
      // empty → useFirebaseBackend is false → the provider must be null (never
      // touch Firestore). Same gate as ordersRepositoryProvider /
      // usersProfileWriterProvider.
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(usersLookupProvider), isNull);
    });
  });
}
