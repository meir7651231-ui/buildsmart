// A14 (launch uid-migration) — THE CHAT LAST-MILE: prove `participantUids` is
// actually POPULATED with REAL uids end-to-end, not another inert seam.
//
// THE GAP A14 closes (the product owner's exact critique): A9 added
// `ChatThread.participantUids` + round-trip + the rules that scope on it, but the
// field was NEVER populated → always empty → "empty = visible to all" → NO real
// per-user isolation. A14 wires the engine's [ChatEngineNotifier.ensureParticipantUids]
// to resolve, on send/open of a thread, the UNION of the real uids of ALL its
// participant ROLES (via the A7 [UsersLookup.uidsByRole]) + the sender's own uid,
// and STAMP them onto the thread head — so the rules' `uid in participantUids`
// becomes a real scope.
//
// WHAT THIS FILE PROVES (the whole point — that it is NOT inert):
//   1. flag ON + a fake directory (contractor→[uid-c], store→[uid-s1,uid-s2]) +
//      currentUid=uid-c → after a send on the [contractor,store] thread, its
//      `participantUids` is NON-EMPTY and equals the UNION {uid-c,uid-s1,uid-s2}
//      (multiple users per role all included — the ran/omer two-workers case);
//   2. flag OFF → participantUids stays EMPTY (the zero-regression lock);
//   3. the populated thread is then VISIBLE to a member and NOT to a non-member
//      via [chatThreadVisibleToUid] (the predicate the rules mirror).
//
// The gate is the engine's `uidScoped` field, which DEFAULTS to the compile-time
// `kUidScopedQueries` (so production is gated exactly by that flag, OFF today);
// a test injects `uidScoped: true` to exercise the ON branch in the standard
// define-less suite — the way every other compile-time switch here is made
// unit-testable. No Firebase: the [UsersLookup] reads through its injectable
// [RemoteCollectionSource] seam, driven by the same hand-rolled fake the A7/A8
// tests use.

import 'dart:async';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hand-rolled fake [RemoteCollectionSource] over a `users` dataset (the
/// A7 test fake shape): doc-id = auth.uid, fields mirror the welcome flow + an
/// admin-assigned `role`. `uidsByRole` scans these for the role's members.
class _FakeUsersSource implements RemoteCollectionSource {
  _FakeUsersSource(this._docs);

  final List<RemoteDoc> _docs;

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(_docs);

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;
}

RemoteDoc _user(String uid, {required String role}) =>
    RemoteDoc(uid, {kUsersRoleField: role});

/// A directory with ONE contractor + TWO stores (the "multiple users per role"
/// case the union must handle — e.g. the two workers ran/omer).
UsersLookup _directory() => UsersLookup(_FakeUsersSource([
      _user('uid-c', role: 'contractor'),
      _user('uid-s1', role: 'store'),
      _user('uid-s2', role: 'store'),
    ]));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `th-contractor-store` is the seeded [contractor, store] thread — exactly the
  // pair whose union the proof targets.
  const contractorStore = 'th-contractor-store';

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 30));

  group('A14 · participantUids POPULATION end-to-end (the proof it is real)',
      () {
    test(
        'flag ON: a send STAMPS the union of the roles\' real uids + the sender '
        '(NON-EMPTY)', () async {
      final engine = ChatEngineNotifier(
        persist: false,
        uidScoped: true, // ← flag ON (production gates on kUidScopedQueries)
        lookup: _directory(), // contractor→[uid-c], store→[uid-s1,uid-s2]
        currentUid: () => 'uid-c', // the signed-in sender
      );
      addTearDown(engine.dispose);

      // Pre-condition: the seeded thread starts with EMPTY participantUids (A9
      // shipped it inert — that is the gap A14 closes).
      final before =
          engine.state.firstWhere((t) => t.id == contractorStore);
      expect(before.participantUids, isEmpty,
          reason: 'the seed thread is born un-populated');

      // Send → kicks the async resolve-and-stamp (non-blocking).
      engine.send(contractorStore, BsRole.contractor, 'שלום, מה הסטטוס?');
      await settle(); // let uidsByRole resolve + the upsert stamp the head

      final after = engine.state.firstWhere((t) => t.id == contractorStore);

      // ── THE PROOF: participantUids became NON-EMPTY = the UNION ─────────────
      expect(after.participantUids, isNotEmpty,
          reason: 'A14: the field is now POPULATED, not inert');
      expect(
        after.participantUids.toSet(),
        {'uid-c', 'uid-s1', 'uid-s2'},
        reason: '⋃ over [contractor,store] = every contractor uid + every '
            'store uid, plus the sender — multiple users per role all included',
      );
      // The display roles + the sent message are untouched (population is
      // additive — it never disturbs visibility-by-role or the message flow).
      expect(after.participants, [BsRole.contractor, BsRole.store]);
      expect(after.messages.last.text, 'שלום, מה הסטטוס?');
    });

    test('flag ON: ensureParticipantUids on thread OPEN populates too (no send)',
        () async {
      final engine = ChatEngineNotifier(
        persist: false,
        uidScoped: true,
        lookup: _directory(),
        currentUid: () => 'uid-c',
      );
      addTearDown(engine.dispose);

      // The "open the thread" seam — stamp without sending anything.
      await engine.ensureParticipantUids(contractorStore);

      final t = engine.state.firstWhere((x) => x.id == contractorStore);
      expect(t.participantUids.toSet(), {'uid-c', 'uid-s1', 'uid-s2'});
      // No message was added (open != send).
      expect(t.messages.last.text, isNot('שלום, מה הסטטוס?'));
    });

    test('flag ON + NULL lookup (the on-device failure mode): the SENDER\'s own '
        'uid is STILL stamped — mirrors orders contractorUid==auth.uid', () async {
      // THE BUG this locks: in production a null/failing UsersLookup made
      // ensureParticipantUids bail BEFORE folding the sender ⇒ participantUids
      // stayed EMPTY ⇒ thread/message writes silently denied. The fix ALWAYS
      // folds currentUid, so the sender is a member even with no directory.
      final engine = ChatEngineNotifier(
        persist: false,
        uidScoped: true,
        lookup: null, // ← no users directory (the device's resolve path)
        currentUid: () => 'uid-c',
      );
      addTearDown(engine.dispose);

      await engine.ensureParticipantUids(contractorStore);

      final t = engine.state.firstWhere((x) => x.id == contractorStore);
      expect(t.participantUids, ['uid-c'],
          reason: 'no directory ⇒ peer roles unresolved, but the sender is '
              'ALWAYS a member so they can read/write the thread they stamped');
      expect(chatThreadVisibleToUid(t.participantUids, 'uid-c'), isTrue);
      expect(chatThreadVisibleToUid(t.participantUids, 'uid-x'), isFalse);
    });

    test('flag OFF (default): participantUids stays EMPTY — zero-regression lock',
        () async {
      final engine = ChatEngineNotifier(
        persist: false,
        uidScoped: false, // ← OFF = today, exactly
        lookup: _directory(), // a directory IS available…
        currentUid: () => 'uid-c',
      );
      addTearDown(engine.dispose);

      engine.send(contractorStore, BsRole.contractor, 'שלום');
      await engine.ensureParticipantUids(contractorStore); // even explicit open
      await settle();

      final t = engine.state.firstWhere((x) => x.id == contractorStore);
      expect(t.participantUids, isEmpty,
          reason: 'OFF ⇒ no resolve ⇒ threads stay shared (byte-identical to '
              'today, the A14 zero-regression invariant)');
      // The send still worked exactly as before (population is the only change).
      expect(t.messages.last.text, 'שלום');
    });

    test('the populated thread is VISIBLE to a member, NOT to a non-member '
        '(ties to the rules)', () async {
      final engine = ChatEngineNotifier(
        persist: false,
        uidScoped: true,
        lookup: _directory(),
        currentUid: () => 'uid-c',
      );
      addTearDown(engine.dispose);

      await engine.ensureParticipantUids(contractorStore);
      final uids = engine.state
          .firstWhere((t) => t.id == contractorStore)
          .participantUids;
      expect(uids, isNotEmpty);

      // [chatThreadVisibleToUid] is the pure twin of the firestore rules'
      // `uid in participantUids`. With a POPULATED list it is members-only:
      expect(chatThreadVisibleToUid(uids, 'uid-s1'), isTrue,
          reason: 'a store member (in the union) sees the thread');
      expect(chatThreadVisibleToUid(uids, 'uid-c'), isTrue,
          reason: 'the contractor/sender sees the thread');
      expect(chatThreadVisibleToUid(uids, 'uid-x'), isFalse,
          reason: 'a NON-member (not in the union) is isolated out — REAL '
              'per-user scoping, no longer "empty = visible to all"');
    });

    test('a second send does NOT re-resolve (resolve-once, then it is cached)',
        () async {
      // A directory whose uidsByRole COUNTS its calls — to prove the in-flight
      // + already-populated guards stop a duplicate resolve.
      var calls = 0;
      final counting = UsersLookup(_CountingSource(() => calls++));
      final engine = ChatEngineNotifier(
        persist: false,
        uidScoped: true,
        lookup: counting,
        currentUid: () => 'uid-c',
      );
      addTearDown(engine.dispose);

      engine.send(contractorStore, BsRole.contractor, 'ראשון');
      await settle();
      final callsAfterFirst = calls;
      engine.send(contractorStore, BsRole.contractor, 'שני');
      await settle();

      expect(callsAfterFirst, greaterThan(0),
          reason: 'the first send DID resolve');
      expect(calls, callsAfterFirst,
          reason: 'the second send saw a populated thread → no re-resolve');
    });
  });

  group('A14 · the compile-time default is OFF (production zero-regression)', () {
    test('kUidScopedQueries is FALSE in tests → the engine default gate is OFF',
        () {
      expect(kUidScopedQueries, isFalse);
      // A default-constructed engine (the provider path) inherits that → OFF.
      final engine = ChatEngineNotifier(persist: false);
      addTearDown(engine.dispose);
      expect(engine.uidScoped, isFalse,
          reason: 'production gates EXACTLY on the compile-time flag');
    });
  });
}

/// A `users` source that increments a counter every time it is read — lets a
/// test prove the resolve is kicked at most once per (still-empty) thread.
class _CountingSource implements RemoteCollectionSource {
  _CountingSource(this._onRead);

  final void Function() _onRead;

  @override
  Stream<List<RemoteDoc>> snapshots() {
    _onRead();
    return Stream<List<RemoteDoc>>.value([
      _user('uid-c', role: 'contractor'),
      _user('uid-s1', role: 'store'),
    ]);
  }

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;
}
