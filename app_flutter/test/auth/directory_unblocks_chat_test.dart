// The directory — why chat threads were invisible to the person they were for.
//
// THE BUG, EXACTLY. A chat thread is isolated by `participantUids`, and the app
// fills that list by resolving the other side's uids from their role. It did so
// by reading the whole `users` collection — a read the security rules correctly
// deny to everyone but an admin, because `users` holds phone numbers, e-mail
// addresses and approval status.
//
// The client caught that denial and carried on with just the sender's own uid.
// The effect was an exact inversion of the feature: every thread became private
// to whoever wrote in it first. Two contractors could type into the same
// conversation and neither would ever see the other. It looked like it worked —
// but only for the owner, who is an admin and whose read succeeds. That is the
// worst shape a bug can take: correct for the one person checking it.
//
// The fix is a second, deliberately thin collection — {role, displayName,
// status} and nothing else — readable by any signed-in person. These tests pin
// the split that makes it safe: roles resolve from the DIRECTORY, phone numbers
// still only from `users`.

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

/// A source that answers with a fixed set of docs — or refuses, the way the
/// rules refuse a non-admin reading `users`.
class _FakeSource implements RemoteCollectionSource {
  _FakeSource(this.docs, {this.denied = false});

  final List<RemoteDoc> docs;
  final bool denied;
  int reads = 0;

  @override
  Stream<List<RemoteDoc>> snapshots() {
    reads++;
    if (denied) {
      return Stream<List<RemoteDoc>>.error(
        StateError('permission-denied: users is admin-only'),
      );
    }
    return Stream<List<RemoteDoc>>.value(docs);
  }

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;
}

RemoteDoc _doc(String id, Map<String, dynamic> data) => RemoteDoc(id, data);

void main() {
  group('roles resolve from the directory, not from users', () {
    test('THE BUG: with users denied and no directory, nobody is found', () {
      // This is the state that shipped: the peer list comes back empty, the
      // thread is stamped with only its sender, and the other side never sees it.
      final lookup = UsersLookup(_FakeSource(const [], denied: true));
      return expectLater(lookup.uidsByRole('contractor'), completion(isEmpty));
    });

    test('THE FIX: the directory answers even while users is denied',
        () async {
      final users = _FakeSource(const [], denied: true);
      final directory = _FakeSource([
        _doc('uid-a', {'role': 'contractor', 'displayName': 'אבי'}),
        _doc('uid-b', {'role': 'contractor', 'displayName': 'בני'}),
        _doc('uid-c', {'role': 'store', 'displayName': 'חנות'}),
      ]);
      final lookup = UsersLookup(users, directorySource: directory);

      final found = await lookup.uidsByRole('contractor');
      expect(found, ['uid-a', 'uid-b'],
          reason: 'both contractors — this is what makes the thread shared');
      expect(users.reads, 0, reason: 'the denied collection is not touched');
    });

    test('a role with nobody in it returns empty, not an error', () async {
      final lookup = UsersLookup(
        _FakeSource(const []),
        directorySource: _FakeSource([
          _doc('uid-a', {'role': 'contractor'}),
        ]),
      );
      expect(await lookup.uidsByRole('courier'), isEmpty);
    });

    test('a directory that is itself unreachable degrades to empty, not a throw',
        () async {
      // HARD RULE #3 of this seam: a lookup never throws into the UI.
      final lookup = UsersLookup(
        _FakeSource(const []),
        directorySource: _FakeSource(const [], denied: true),
      );
      expect(await lookup.uidsByRole('contractor'), isEmpty);
    });
  });

  group('the phone stays out of the directory', () {
    test('phone lookup reads users, NOT the directory', () async {
      // A phone number is exactly what a readable list must not carry. The
      // manager assigning a role is an admin, so their `users` read succeeds.
      final users = _FakeSource([
        _doc('uid-a', {'phone': '0501234567', 'role': 'contractor'}),
      ]);
      final directory = _FakeSource([
        _doc('uid-a', {'role': 'contractor'}), // no phone here, by design
      ]);
      final lookup = UsersLookup(users, directorySource: directory);

      expect(await lookup.uidByPhone('0501234567'), 'uid-a');
      expect(users.reads, 1, reason: 'the phone can only come from users');
    });

    test('a phone absent from users is not found via the directory', () async {
      final lookup = UsersLookup(
        _FakeSource(const []),
        directorySource: _FakeSource([
          _doc('uid-a', {'role': 'contractor', 'phone': '0501234567'}),
        ]),
      );
      expect(await lookup.uidByPhone('0501234567'), isNull,
          reason: 'phone lookup must never fall back to the readable list');
    });
  });

  group('no directory supplied — the Firebase-free path is unchanged', () {
    test('roles still resolve from the single source', () async {
      final lookup = UsersLookup(
        _FakeSource([
          _doc('uid-a', {'role': 'worker'}),
        ]),
      );
      expect(await lookup.uidsByRole('worker'), ['uid-a']);
    });
  });
}
