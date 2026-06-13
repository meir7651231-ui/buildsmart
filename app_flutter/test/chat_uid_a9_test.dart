// A9 (launch uid-migration) — focused coverage for the additive, display-neutral
// `participantUids` on a chat thread (the auth-truth the Firestore rules scope
// on; [ChatThread.participants] keeps the display ROLES + [threadsFor]
// isolation). Like A8's `fromUid`, the field must be ZERO-regression:
//   • written to the thread doc ONLY when non-empty — every seed/role-based/
//     legacy thread (no uids) round-trips byte-identical (the toDoc economy);
//   • read back losslessly when present, defaulting to [] when absent;
//   • the pure visibility predicate [chatThreadVisibleToUid] treats an EMPTY
//     list as "visible to all" (today's shared role threads) and a populated
//     list as "members only" — mirroring the rules `uid in participantUids`.
//
// No Firebase here: the repo's thread toDoc/fromDoc are exercised through a
// fake-driven [FirebaseChatRepository] (the same hand-rolled fake the A8/S4
// tests use). The rules themselves are pinned by rules_test/chat.test.js.

import 'dart:async';

import 'package:buildsmart/data/repositories/chat_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hand-rolled fake [RemoteCollectionSource] (the S4 base-test fake shape).
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];
  final List<String> deletes = [];

  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      sets.add(MapEntry(id, data));

  @override
  Future<void> delete(String id) async => deletes.add(id);

  Future<void> close() => _controller.close();
}

({FirebaseChatRepository repo, _FakeSource threads, _FakeSource messages})
    _mkRepo() {
  final threads = _FakeSource();
  final messages = _FakeSource();
  final repo = FirebaseChatRepository(
    threadsSource: threads,
    messagesSource: messages,
  );
  addTearDown(threads.close);
  addTearDown(messages.close);
  addTearDown(repo.dispose);
  return (repo: repo, threads: threads, messages: messages);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('chatThreadVisibleToUid — pure visibility predicate (A9)', () {
    test('an EMPTY participantUids is VISIBLE to anyone (legacy/un-migrated)', () {
      expect(chatThreadVisibleToUid(const [], 'uid-alice'), isTrue);
      expect(chatThreadVisibleToUid(const [], ''), isTrue);
    });

    test('a populated list is MEMBERS-only', () {
      const members = ['uid-alice', 'uid-bob'];
      expect(chatThreadVisibleToUid(members, 'uid-alice'), isTrue);
      expect(chatThreadVisibleToUid(members, 'uid-bob'), isTrue);
      expect(chatThreadVisibleToUid(members, 'uid-carol'), isFalse);
      expect(chatThreadVisibleToUid(members, ''), isFalse);
    });
  });

  group('ChatThread.participantUids — model (additive, default [])', () {
    test('defaults to [] and copyWith preserves it', () {
      const bare = ChatThread(
        id: 'th-x',
        participants: [BsRole.contractor, BsRole.store],
        name: 'ספק',
        avatar: '💬',
        messages: [],
      );
      expect(bare.participantUids, isEmpty, reason: 'zero-regression default');

      const withUids = ChatThread(
        id: 'th-y',
        participants: [BsRole.contractor, BsRole.store],
        name: 'ספק',
        avatar: '💬',
        messages: [],
        participantUids: ['uid-alice', 'uid-bob'],
      );
      // copyWith (messages-only signature) must NOT drop the uids.
      final copy = withUids.copyWith(messages: const []);
      expect(copy.participantUids, ['uid-alice', 'uid-bob']);
    });
  });

  group('FirebaseChatRepository thread toDoc/fromDoc — participantUids', () {
    test(
        'fromDoc round-trips a present participantUids and DEFAULTS to [] when absent',
        () {
      // A post-A9 thread doc (carries participantUids) + a legacy doc (none).
      const present = RemoteDoc('th-present', {
        'participants': ['contractor', 'store'],
        'participantUids': ['uid-alice', 'uid-bob'],
        'names': 'ספק',
        'lastMsg': 'שלום',
      });
      const legacy = RemoteDoc('th-legacy', {
        'participants': ['contractor', 'store'], // role-names only, pre-A9
        'names': 'ספק',
      });

      final r = _mkRepo();
      r.repo.attach();
      r.threads.emit(const [present, legacy]);

      return Future<void>.delayed(Duration.zero, () {
        final threads = r.repo.threads();
        final gotPresent = threads.firstWhere((t) => t.id == 'th-present');
        final gotLegacy = threads.firstWhere((t) => t.id == 'th-legacy');
        expect(
          gotPresent.participantUids,
          ['uid-alice', 'uid-bob'],
          reason: 'present round-trips',
        );
        expect(
          gotLegacy.participantUids,
          isEmpty,
          reason: 'absent → zero-regression default',
        );
        // The display roles are untouched (the field is additive).
        expect(gotPresent.participants, [BsRole.contractor, BsRole.store]);
      });
    });

    test('toDoc OMITS participantUids for a seed/empty thread (byte-identical to pre-A9)',
        () async {
      final r = _mkRepo();
      r.repo.attach();
      // Fresh backend → the seed heads (all with empty participantUids) are
      // pushed up; none of those docs may carry the key.
      r.threads.emit(const []);
      await Future<void>.delayed(Duration.zero);

      expect(r.threads.sets, isNotEmpty, reason: 'first-empty seeds the remote');
      for (final e in r.threads.sets) {
        expect(
          e.value.containsKey('participantUids'),
          isFalse,
          reason: 'empty uids omitted → pre-A9 doc shape (${e.key})',
        );
      }
    });

    test('toDoc WRITES participantUids when the thread carries them', () async {
      final r = _mkRepo();
      r.repo.attach();
      // A migrated thread arrives over the wire…
      r.threads.emit(const [
        RemoteDoc('th-present', {
          'participants': ['contractor', 'store'],
          'participantUids': ['uid-alice', 'uid-bob'],
          'names': 'ספק',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      // …a send re-writes its head (lastMsg/ts denorm) — toDoc must carry the
      // uids through the round-trip, not drop them.
      r.repo.send('th-present', BsRole.contractor, 'נשלח');
      await Future<void>.delayed(Duration.zero);

      final headDoc =
          r.threads.sets.lastWhere((e) => e.key == 'th-present').value;
      expect(headDoc['participantUids'], ['uid-alice', 'uid-bob']);
      expect(headDoc['lastMsg'], 'נשלח', reason: 'the denorm still updates');
    });
  });
}
