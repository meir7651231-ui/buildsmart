// A8 (launch uid-migration) — focused coverage for the additive, display-neutral
// `fromUid` on [ChatMessage]. The field stamps a signed-in sender's `auth.uid`
// on the message they send (a later post-S1 phase will SCOPE chatMessages/thread
// `participants` on it); [fromRole] still drives the mine/theirs UI, so the field
// must be ZERO-regression:
//   • written ONLY when non-empty — the seed messages + every legacy/seed doc
//     (which carry no uid) round-trip byte-identical, in BOTH the local JSON
//     shape ([ChatMessage.toJson]/[ChatMessage.tryFromJson]) and the Firestore
//     doc shape ([FirebaseChatRepository] message `toDoc`/`fromDoc`);
//   • read back losslessly when present, defaulting to '' when absent;
//   • carried end-to-end: a message SENT while signed-in (engine `send` with a
//     uid, or the repo's port) stamps the uid on the recorded message doc; the
//     bot auto-reply carries NO uid (it is the system, not a user).
//
// No Firebase here: the repo's message toDoc/fromDoc are exercised by sending
// through a fake-driven [FirebaseChatRepository] and reading the captured `set`
// (the same hand-rolled fake the S4 base test uses) — no fake_cloud_firestore.

import 'dart:async';

import 'package:buildsmart/data/repositories/chat_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hand-rolled fake [RemoteCollectionSource] (the S4 base-test fake shape):
/// a broadcast stream + an in-memory record of writes.
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

  @override
  bool get isScoped => false;

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

  const contractorStore = 'th-contractor-store';
  const botThread = 'th-bot';

  group('ChatMessage.toJson/tryFromJson — fromUid (local JSON shape)', () {
    test('a uid is WRITTEN and round-trips losslessly when non-empty', () {
      final m = ChatMessage(
        id: 'm-1',
        threadId: contractorStore,
        fromRole: BsRole.contractor,
        text: 'שלום',
        ts: DateTime.parse('2026-06-11T10:00:00.000'),
        fromUid: 'u-7',
      );
      final json = m.toJson();
      expect(json['fromUid'], 'u-7', reason: 'present when non-empty');

      final back = ChatMessage.tryFromJson(json)!;
      expect(back.fromUid, 'u-7');
      // The display fields are untouched (the field is additive).
      expect(back.fromRole, BsRole.contractor);
      expect(back.text, 'שלום');
      expect(back.id, 'm-1');
    });

    test('an EMPTY uid is OMITTED from the JSON (seed/legacy parity)', () {
      final m = ChatMessage(
        id: 'seed-x-0',
        threadId: contractorStore,
        fromRole: BsRole.store,
        text: 'מהזרע',
        ts: DateTime.parse('2026-06-07T08:00:00.000'),
      );
      expect(m.fromUid, '', reason: 'defaults to empty');
      expect(
        m.toJson().containsKey('fromUid'),
        isFalse,
        reason: 'omitted when empty → byte-identical to a pre-A8 payload',
      );
    });

    test("tryFromJson DEFAULTS to '' when the key is absent (legacy doc)", () {
      // A pre-A8 / seed JSON payload carries no fromUid at all.
      final back = ChatMessage.tryFromJson(const {
        'id': 'seed-th-contractor-store-0',
        'threadId': 'th-contractor-store',
        'fromRole': 'contractor',
        'text': 'בוקר טוב',
        'ts': '2026-06-07T08:00:00.000',
      })!;
      expect(back.fromUid, '', reason: 'zero-regression default');
    });

    test("a non-String fromUid coerces to '' (defensive)", () {
      final back = ChatMessage.tryFromJson(const {
        'id': 'm-2',
        'threadId': 'th-contractor-store',
        'fromRole': 'store',
        'text': 'x',
        'ts': '2026-06-07T08:00:00.000',
        'fromUid': 42, // not a string
      })!;
      expect(back.fromUid, '');
    });
  });

  group('FirebaseChatRepository message toDoc/fromDoc — fromUid (Firestore shape)',
      () {
    test('a uid SENT while signed-in is WRITTEN to the message doc', () async {
      final r = _mkRepo();

      // Send with a signed-in uid (the engine/UI passes currentUidProvider).
      r.repo.send(contractorStore, BsRole.contractor, 'נשלח-מחובר',
          fromUid: 'u-7');

      // Visible synchronously (optimistic) AND carries the uid in-memory.
      final sentMsg = r.repo
          .threads()
          .firstWhere((t) => t.id == contractorStore)
          .messages
          .last;
      expect(sentMsg.text, 'נשלח-מחובר');
      expect(sentMsg.fromUid, 'u-7');

      await Future<void>.delayed(Duration.zero);
      // The recorded message doc carries fromUid alongside fromRole.
      final msgDoc =
          r.messages.sets.firstWhere((e) => e.value['text'] == 'נשלח-מחובר').value;
      expect(msgDoc['fromUid'], 'u-7', reason: 'present when signed-in');
      expect(msgDoc['fromRole'], 'contractor', reason: 'fromRole kept');
    });

    test('a SIGNED-OUT send omits fromUid (seed/legacy parity, zero regression)',
        () async {
      final r = _mkRepo();

      // No fromUid → today's behavior, byte-identical to a pre-A8 send.
      r.repo.send(contractorStore, BsRole.store, 'נשלח-מנותק');

      await Future<void>.delayed(Duration.zero);
      final msgDoc =
          r.messages.sets.firstWhere((e) => e.value['text'] == 'נשלח-מנותק').value;
      expect(msgDoc.containsKey('fromUid'), isFalse,
          reason: 'omitted when empty → pre-A8 doc shape');
      // Exactly the four legacy schema fields, no more.
      expect(msgDoc.keys.toSet(), {'threadId', 'fromRole', 'text', 'ts'});
    });

    test('the bot auto-reply carries NO fromUid even when the user line does',
        () async {
      final r = _mkRepo();

      r.repo.send(botThread, BsRole.contractor, 'מה הסטטוס?', fromUid: 'u-7');

      final t = r.repo.threads().firstWhere((t) => t.id == botThread);
      final userLine = t.messages[t.messages.length - 2];
      final botLine = t.messages.last;
      expect(userLine.fromRole, BsRole.contractor);
      expect(userLine.fromUid, 'u-7', reason: 'user line stamped');
      expect(botLine.fromRole, BsRole.bot);
      expect(botLine.fromUid, '', reason: 'the bot is the system, not a user');

      await Future<void>.delayed(Duration.zero);
      final botDoc = r.messages.sets
          .firstWhere((e) => e.value['fromRole'] == 'bot')
          .value;
      expect(botDoc.containsKey('fromUid'), isFalse);
    });

    test("fromDoc round-trips a present fromUid and DEFAULTS to '' when absent",
        () {
      // A post-A8 message doc (carries fromUid) → decoded losslessly.
      const present = RemoteDoc('m-9', {
        'threadId': 'th-contractor-store',
        'fromRole': 'store',
        'text': 'מחובר',
        'ts': '2026-06-10T09:00:00.000',
        'fromUid': 'u-42',
      });
      // A legacy/seed doc (no fromUid) → '' (zero regression).
      const legacy = RemoteDoc('m-10', {
        'threadId': 'th-contractor-store',
        'fromRole': 'store',
        'text': 'מהזרע',
        'ts': '2026-06-10T09:00:00.000',
      });

      // Exercise fromDoc via a snapshot (the path the cache actually feeds).
      final r = _mkRepo();
      r.repo.attach();
      r.messages.emit(const [present, legacy]);

      return Future<void>.delayed(Duration.zero, () {
        final msgs = r.repo
            .threads()
            .firstWhere((t) => t.id == contractorStore)
            .messages;
        final got9 = msgs.firstWhere((m) => m.id == 'm-9');
        final got10 = msgs.firstWhere((m) => m.id == 'm-10');
        expect(got9.fromUid, 'u-42', reason: 'present round-trips');
        expect(got10.fromUid, '', reason: 'absent → zero-regression default');
      });
    });
  });
}
