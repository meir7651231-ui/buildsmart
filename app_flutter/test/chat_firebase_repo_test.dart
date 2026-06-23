// CHAT FIRESTORE REPO (S4.1–S4.3) — unit coverage for the composed
// [FirebaseChatRepository] (`chatThreads` + `chatMessages` caches over the S2.2
// base) WITHOUT Firebase: the seam ([RemoteCollectionSource]) is driven by the
// same hand-rolled fake the S2 base test uses — no fake_cloud_firestore, no new
// packages. The fake captures every `set` and lets a test push snapshot events,
// so the whole bridge (seed → snapshot → optimistic send → failure handling) is
// asserted deterministically. The LIVE cross-device check (S4.5) cannot run
// here (no network/Firebase) — it happens on real devices; these tests pin the
// loop the devices will ride.
//
// Pins:
//   • both caches BORN from the verbatim kChatThreads seed (assembly intact);
//   • first-empty snapshot pushes the seeds UP (threads + messages), pre-S1
//     identity mapped verbatim (participants = role names, fromUid omitted);
//   • a message/thread snapshot REPLACES its cache → threads() reflects, in
//     seed thread-order + ts message-order;
//   • a corrupt doc is SKIPPED, never blanks the chat;
//   • send(): optimistic + message write + thread lastMsg/ts write (S4.3),
//     trim/no-op guards, bot auto-reply — verbatim ChatEngineNotifier.send;
//   • a write FAILURE corrupts neither cache nor throws;
//   • resetToSeed restores + re-writes both collections.

import 'dart:async';

import 'package:buildsmart/data/chat_seeds.dart';
import 'package:buildsmart/data/repositories/chat_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource] (the S2 base-test fake, verbatim
/// shape): a broadcast stream we drive manually + an in-memory record of writes.
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  /// Captured `set` calls (id → last field-map written), in arrival order.
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];

  /// Captured `delete` calls (ids).
  final List<String> deletes = [];

  /// When true, the next [set] throws — to exercise the guarded write path.
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

/// A repo wired to two fakes, with tear-downs registered (engine-less here —
/// the engine wiring is `realtime_wiring_test.dart`).
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

ChatThread _thread(FirebaseChatRepository repo, String id) =>
    repo.threads().firstWhere((t) => t.id == id);

void main() {
  const contractorStore = 'th-contractor-store';
  const botThread = 'th-bot';

  group('seed & assembly', () {
    test('born seeded — threads() re-assembles kChatThreads verbatim', () {
      final r = _mkRepo();
      final assembled = r.repo.threads();

      // Seed order, head fields, participants, and per-thread message texts in
      // their seeded (chronological) order — byte-identical to the engine seed.
      expect(assembled.map((t) => t.id).toList(),
          kChatThreads.map((t) => t.id).toList(),);
      for (var i = 0; i < kChatThreads.length; i++) {
        final want = kChatThreads[i];
        final got = assembled[i];
        expect(got.name, want.name);
        expect(got.avatar, want.avatar);
        expect(got.isBot, want.isBot);
        expect(got.participants, want.participants);
        expect(got.messages.map((m) => m.text).toList(),
            want.messages.map((m) => m.text).toList(),);
      }
    });

    test('first-empty snapshots push BOTH seeds up (pre-S1 mapping verbatim)',
        () async {
      final r = _mkRepo();
      r.repo.attach();

      r.threads.emit(const []); // fresh chatThreads collection
      r.messages.emit(const []); // fresh chatMessages collection
      await Future<void>.delayed(Duration.zero);

      // Still seeded locally (not blanked) AND pushed server-side: 5 thread
      // heads + the 10 seed messages.
      expect(r.repo.threads().length, kChatThreads.length);
      expect(r.threads.sets.map((e) => e.key).toSet(),
          kChatThreads.map((t) => t.id).toSet(),);
      expect(r.messages.sets.length,
          kChatThreads.fold<int>(0, (n, t) => n + t.messages.length),);

      // Schema fields, pre-S1 identity: participants = ROLE NAMES (no uids
      // yet — the uid join lands with S1), names/lastMsg/ts denormalised.
      final head =
          r.threads.sets.firstWhere((e) => e.key == contractorStore).value;
      expect(head['participants'], ['contractor', 'store']);
      expect(head['names'], 'ספק חומרי בנייה');
      expect(head['lastMsg'], 'שלום, ההזמנה שלך תצא בעוד כ-20 דקות.');
      expect(head['ts'], isNotNull);

      // Message docs: threadId/fromRole/text/ts — and NO fromUid until S1.
      final msg = r.messages.sets.first.value;
      expect(msg.keys.toSet(), {'threadId', 'fromRole', 'text', 'ts'});
      expect(msg.containsKey('fromUid'), isFalse);
    });
  });

  group('snapshots flow IN (S4.1/S4.2)', () {
    test('a message snapshot REPLACES the cache → threads() reflects, ts-ordered',
        () async {
      final r = _mkRepo();
      r.repo.attach();

      // The remote now holds two messages for the contractor↔store thread —
      // emitted in the WRONG order (Firestore returns doc-id order); sortBy
      // must restore chronology.
      r.messages.emit(const [
        RemoteDoc('m-b', {
          'threadId': contractorStore,
          'fromRole': 'contractor',
          'text': 'תודה, בדרך אליכם',
          'ts': '2026-06-10T09:05:00.000',
        }),
        RemoteDoc('m-a', {
          'threadId': contractorStore,
          'fromRole': 'store',
          'text': 'ההזמנה מוכנה ✅',
          'ts': '2026-06-10T09:00:00.000',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      final t = _thread(r.repo, contractorStore);
      expect(t.messages.map((m) => m.text).toList(),
          ['ההזמנה מוכנה ✅', 'תודה, בדרך אליכם'],);
      expect(t.messages.first.fromRole, BsRole.store);
      // Thread heads were untouched (their own collection) — still 5, seeded.
      expect(r.repo.threads().length, kChatThreads.length);
    });

    test('a corrupt message doc is SKIPPED — never blanks the chat', () async {
      final r = _mkRepo();
      r.repo.attach();

      r.messages.emit(const [
        RemoteDoc('m-good', {
          'threadId': contractorStore,
          'fromRole': 'store',
          'text': 'תקין',
          'ts': '2026-06-10T09:00:00.000',
        }),
        RemoteDoc('m-bad', {'threadId': contractorStore, 'text': 'בלי role/ts'}),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(_thread(r.repo, contractorStore).messages.map((m) => m.text),
          ['תקין'],);
    });

    test(
        'a thread snapshot: role-name participants round-trip, doc-id order '
        're-sorted to seed order, unresolvable head skipped', () async {
      final r = _mkRepo();
      r.repo.attach();

      r.threads.emit(const [
        // Alphabetical/doc-id arrival order — NOT the seed order.
        RemoteDoc(botThread, {
          'participants': ['contractor', 'bot'],
          'names': 'צ׳אטבוט BuildSmart',
          'avatar': '🤖',
          'isBot': true,
        }),
        RemoteDoc(contractorStore, {
          // A future S1 uid sitting NEXT to role names is tolerated (skipped),
          // the role participants still resolve.
          'participants': ['contractor', 'uid-abc123', 'store'],
          'names': 'ספק חומרי בנייה',
          'avatar': '🏪',
        }),
        RemoteDoc('th-uids-only', {
          // Nothing resolvable pre-S1 → structurally bad → skipped per-doc.
          'participants': ['uid-1', 'uid-2'],
          'names': 'עתידי',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      final got = r.repo.threads();
      // Seed order restored (store-thread is seeded before the bot thread).
      expect(got.map((t) => t.id).toList(), [contractorStore, botThread]);
      expect(got.first.participants, [BsRole.contractor, BsRole.store]);
      expect(got.last.isBot, isTrue);
    });
  });

  group('send — S4.3 (verbatim ChatEngineNotifier.send via upsert)', () {
    test('optimistic message + thread lastMsg/ts write-through', () async {
      final r = _mkRepo();

      r.repo.send(contractorStore, BsRole.store, '  ההזמנה יצאה לדרך 🚚  ');

      // Visible SYNCHRONOUSLY (no await) — and trimmed.
      final t = _thread(r.repo, contractorStore);
      expect(t.messages.last.text, 'ההזמנה יצאה לדרך 🚚');
      expect(t.messages.last.fromRole, BsRole.store);

      await Future<void>.delayed(Duration.zero);
      // The message doc was written (schema fields, no fromUid pre-S1)…
      final msgWrite = r.messages.sets
          .firstWhere((e) => e.value['text'] == 'ההזמנה יצאה לדרך 🚚')
          .value;
      expect(msgWrite['threadId'], contractorStore);
      expect(msgWrite['fromRole'], 'store');
      expect(msgWrite.containsKey('fromUid'), isFalse);
      // …AND the thread head was denormalised (lastMsg/ts moved forward).
      final headWrite =
          r.threads.sets.firstWhere((e) => e.key == contractorStore).value;
      expect(headWrite['lastMsg'], 'ההזמנה יצאה לדרך 🚚');
      expect(headWrite['ts'], isNotNull);
    });

    test('empty text / unknown thread → no-op, nothing written', () async {
      final r = _mkRepo();
      final before = _thread(r.repo, contractorStore).messages.length;

      r.repo.send(contractorStore, BsRole.contractor, '   ');
      r.repo.send('no-such-thread', BsRole.contractor, 'x');

      expect(_thread(r.repo, contractorStore).messages.length, before);
      await Future<void>.delayed(Duration.zero);
      expect(r.threads.sets, isEmpty);
      expect(r.messages.sets, isEmpty);
    });

    test('bot thread keeps the rotating auto-reply; head lastMsg = the reply',
        () async {
      final r = _mkRepo();
      final before = _thread(r.repo, botThread).messages.length;

      r.repo.send(botThread, BsRole.contractor, 'מה הסטטוס?');

      final t = _thread(r.repo, botThread);
      // user line + one bot auto-reply (rotation index = 1 prior bot message).
      expect(t.messages.length, before + 2);
      expect(t.messages[t.messages.length - 2].fromRole, BsRole.contractor);
      expect(t.messages.last.fromRole, BsRole.bot);
      expect(t.messages.last.text, kBotAutoReplies[1 % kBotAutoReplies.length]);

      await Future<void>.delayed(Duration.zero);
      final headWrite =
          r.threads.sets.firstWhere((e) => e.key == botThread).value;
      expect(headWrite['lastMsg'], t.messages.last.text);
    });

    test('a write FAILURE corrupts neither cache nor throws', () async {
      final r = _mkRepo();
      r.messages.failNextSet = true;

      r.repo.send(contractorStore, BsRole.contractor, 'נשלח-אופטימית');
      expect(_thread(r.repo, contractorStore).messages.last.text,
          'נשלח-אופטימית',); // optimistic cache intact
      await Future<void>.delayed(Duration.zero);
      expect(r.messages.sets, isEmpty); // the failing set was swallowed
      expect(_thread(r.repo, contractorStore).messages.last.text,
          'נשלח-אופטימית',); // still intact, nothing threw
    });
  });

  group('#chat-delivery-status — the HONEST per-message status', () {
    test('a SERVER-sourced message (fromDoc) is delivered ✓✓', () async {
      final r = _mkRepo();
      r.repo.attach();

      // A doc coming back from the snapshot really reached the server → the
      // decode (fromDoc) stamps it delivered. This is the ONLY path to ✓✓.
      r.messages.emit(const [
        RemoteDoc('m-from-server', {
          'threadId': contractorStore,
          'fromRole': 'store',
          'text': 'מהשרת',
          'ts': '2026-06-10T09:00:00.000',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      final msg = _thread(r.repo, contractorStore)
          .messages
          .firstWhere((m) => m.id == 'm-from-server');
      expect(msg.status, MsgStatus.delivered);
    });

    test('toDoc OMITS status — it is sender-local, never written to the server',
        () async {
      final r = _mkRepo();

      // Send a message (its user line starts pending) and inspect the captured
      // write: the server doc must carry NO status field, whatever the local
      // status is — delivered-ness is implied by coming back through fromDoc.
      r.repo.send(contractorStore, BsRole.store, 'בלי status בשרת');
      await Future<void>.delayed(Duration.zero);

      final write = r.messages.sets
          .firstWhere((e) => e.value['text'] == 'בלי status בשרת')
          .value;
      expect(write.containsKey('status'), isFalse);
      expect(write.keys.toSet(), {'threadId', 'fromRole', 'text', 'ts'});
    });

    test('user line: pending → sent once the background write succeeds',
        () async {
      final r = _mkRepo();

      r.repo.send(contractorStore, BsRole.store, 'יוצא לדרך');
      // Optimistic + in flight → pending 🕐 (synchronous, before the write).
      var msg = _thread(r.repo, contractorStore).messages.last;
      expect(msg.status, MsgStatus.pending);

      await Future<void>.delayed(Duration.zero); // write settles ok
      msg = _thread(r.repo, contractorStore)
          .messages
          .firstWhere((m) => m.text == 'יוצא לדרך');
      // sent ✓ (in the outbox) — NOT delivered: ✓✓ only via a server snapshot.
      expect(msg.status, MsgStatus.sent);
    });

    test('user line: pending → failed when the background write throws',
        () async {
      final r = _mkRepo();
      r.messages.failNextSet = true;

      r.repo.send(contractorStore, BsRole.contractor, 'ייכשל');
      await Future<void>.delayed(Duration.zero); // failing write swallowed

      final msg = _thread(r.repo, contractorStore)
          .messages
          .firstWhere((m) => m.text == 'ייכשל');
      expect(msg.status, MsgStatus.failed);
    });

    test('retry re-fires a failed write → pending then sent', () async {
      final r = _mkRepo();
      r.messages.failNextSet = true;

      r.repo.send(contractorStore, BsRole.contractor, 'ניסיון');
      await Future<void>.delayed(Duration.zero);
      final failed = _thread(r.repo, contractorStore)
          .messages
          .firstWhere((m) => m.text == 'ניסיון');
      expect(failed.status, MsgStatus.failed);

      // Retry: re-mark pending, re-attempt — this time the write succeeds.
      r.repo.retry(contractorStore, failed.id);
      expect(
        _thread(r.repo, contractorStore)
            .messages
            .firstWhere((m) => m.id == failed.id)
            .status,
        MsgStatus.pending,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        _thread(r.repo, contractorStore)
            .messages
            .firstWhere((m) => m.id == failed.id)
            .status,
        MsgStatus.sent,
      );
    });

    test('the bot auto-reply stays sent (local, infallible — no server write)',
        () async {
      final r = _mkRepo();

      r.repo.send(botThread, BsRole.contractor, 'מה הסטטוס?');
      await Future<void>.delayed(Duration.zero);

      final t = _thread(r.repo, botThread);
      expect(t.messages.last.fromRole, BsRole.bot);
      expect(t.messages.last.status, MsgStatus.sent);
    });
  });

  group('resetToSeed', () {
    test('restores BOTH collections to the verbatim seed + re-writes them',
        () async {
      final r = _mkRepo();
      r.repo.send(contractorStore, BsRole.store, 'יימחק ב-reset');

      r.repo.resetToSeed();

      final t = _thread(r.repo, contractorStore);
      expect(t.messages.map((m) => m.text).toList(),
          kChatThreads.first.messages.map((m) => m.text).toList(),);

      await Future<void>.delayed(Duration.zero);
      // The seed was pushed to both remotes (heads + every seed message).
      expect(r.threads.sets.map((e) => e.key).toSet(),
          containsAll(kChatThreads.map((t) => t.id)),);
      expect(r.messages.sets.map((e) => e.key).toSet(),
          containsAll(kChatThreads.first.messages.map((m) => m.id)),);
    });
  });
}
