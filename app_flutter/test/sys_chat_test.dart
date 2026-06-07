// CROSS-PERSONA CHAT ENGINE — unit coverage for the shared message store
// (SPEC `SPEC-cross-persona-chat.md` CH-1). The engine is the single source of
// truth that makes "אותו מסך-שיחות אצל כולם" real, so the three things that MUST
// hold are: cross-persona visibility (a message one side sends is seen by the
// other), persistence across a restart (the `worker_tasks_engine` H2 pattern),
// and 🔒 isolation (a persona only sees the threads it participates in — the
// store never sees a contractor↔manager thread).
//
// No UI: we drive `ChatEngineNotifier` directly. `persist:false` exercises the
// in-memory seed/flow in isolation (the worker-tasks test idiom); a second group
// flips persistence on with a mock SharedPreferences store to prove a write +
// fresh-notifier read survives a "restart".

import 'package:buildsmart/data/chat_seeds.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Let the notifier's async _load/_persist microtasks settle (the prefs store
  // resolves on a microtask — same helper the persistence_roundtrip test uses).
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() => SharedPreferences.setMockInitialValues({}));

  // The seeded contractor↔store thread used across the visibility tests.
  const contractorStore = 'th-contractor-store';
  const contractorManager = 'th-contractor-manager';
  const botThread = 'th-bot';

  group('cross-persona visibility (CH-1 DoD)', () {
    test(
        'a store message on a contractor↔store thread is visible to the '
        'contractor', () {
      final n = ChatEngineNotifier(persist: false);

      // 🏪 store sends into the SHARED thread.
      n.send(contractorStore, BsRole.store, 'ההזמנה יצאה לדרך 🚚');

      // 👷 contractor reads the SAME thread (via threadsFor) and sees it.
      final contractorThreads = n.threadsFor(BsRole.contractor);
      final shared = contractorThreads.firstWhere(
        (t) => t.id == contractorStore,
      );
      expect(
        shared.messages.last.text,
        'ההזמנה יצאה לדרך 🚚',
        reason: 'the store-sent message must surface on the contractor side',
      );
      expect(
        shared.messages.last.fromRole,
        BsRole.store,
        reason: 'fromRole drives mine/theirs in the UI',
      );

      // Symmetric: the store sees its own message on the same shared thread.
      final storeShared = n
          .threadsFor(BsRole.store)
          .firstWhere((t) => t.id == contractorStore);
      expect(storeShared.messages.last.text, 'ההזמנה יצאה לדרך 🚚');
    });

    test('send appends (does not replace) and trims/ignores empty', () {
      final n = ChatEngineNotifier(persist: false);
      final before = n
          .threadsFor(BsRole.contractor)
          .firstWhere((t) => t.id == contractorStore)
          .messages
          .length;

      n.send(contractorStore, BsRole.contractor, '  ננפגש ב-14:00  ');
      n.send(contractorStore, BsRole.contractor, '   '); // whitespace → no-op
      n.send('no-such-thread', BsRole.contractor, 'x'); // unknown → no-op

      final after = n
          .threadsFor(BsRole.contractor)
          .firstWhere((t) => t.id == contractorStore);
      expect(after.messages.length, before + 1);
      expect(after.messages.last.text, 'ננפגש ב-14:00'); // trimmed
    });

    test('bot thread keeps an auto-reply after a user message', () {
      final n = ChatEngineNotifier(persist: false);
      final bot = n.state.firstWhere((t) => t.id == botThread);
      final before = bot.messages.length;

      n.send(botThread, BsRole.contractor, 'מה הסטטוס?');

      final after = n.state.firstWhere((t) => t.id == botThread);
      // user line + one bot auto-reply.
      expect(after.messages.length, before + 2);
      expect(after.messages[after.messages.length - 2].fromRole,
          BsRole.contractor);
      expect(after.messages.last.fromRole, BsRole.bot);
      expect(kBotAutoReplies, contains(after.messages.last.text));
    });
  });

  group('🔒 isolation (SPEC §2.5)', () {
    test('threadsFor returns only threads the persona participates in', () {
      final n = ChatEngineNotifier(persist: false);

      final storeThreads = n.threadsFor(BsRole.store).map((t) => t.id).toSet();
      // The store sees its own pairs…
      expect(storeThreads, contains('th-contractor-store'));
      expect(storeThreads, contains('th-store-courier'));
      // …but NOT the contractor↔manager thread, and NOT the bot thread.
      expect(
        storeThreads,
        isNot(contains(contractorManager)),
        reason: 'the store must never see a contractor↔manager thread',
      );
      expect(storeThreads, isNot(contains(botThread)));
    });

    test('a manager message stays invisible to the store (isolation holds '
        'after a send)', () {
      final n = ChatEngineNotifier(persist: false);
      n.send(contractorManager, BsRole.manager, 'אנא אשר את החריגה');

      // The contractor (a participant) sees it…
      expect(
        n.threadsFor(BsRole.contractor).any((t) => t.id == contractorManager),
        isTrue,
      );
      // …the store (not a participant) still has no such thread at all.
      expect(
        n.threadsFor(BsRole.store).any((t) => t.id == contractorManager),
        isFalse,
      );
    });

    test('every seeded thread is seen from BOTH its participants (CH-2 DoD)',
        () {
      final n = ChatEngineNotifier(persist: false);
      for (final t in n.state) {
        for (final role in t.participants) {
          expect(
            n.threadsFor(role).any((x) => x.id == t.id),
            isTrue,
            reason: 'thread ${t.id} must be visible to participant $role',
          );
        }
      }
    });
  });

  group('persistence across restart (worker_tasks H2 pattern)', () {
    test('a sent message survives a fresh notifier reading from prefs',
        () async {
      // First "session": persist on, send a cross-persona message.
      final first = ChatEngineNotifier();
      await settle(); // initial _load resolves (empty store → seed)
      first.send(contractorStore, BsRole.store, 'נשמר גם אחרי restart ✅');
      await settle(); // _persist resolves

      // Second "session": a brand-new notifier reads the SAME mock prefs.
      final second = ChatEngineNotifier();
      await settle(); // _load re-applies the persisted overlay onto the seed

      final restored = second
          .threadsFor(BsRole.contractor)
          .firstWhere((t) => t.id == contractorStore);
      expect(restored.messages.last.text, 'נשמר גם אחרי restart ✅');
      expect(restored.messages.last.fromRole, BsRole.store);
    });

    test('persist:false writes nothing to SharedPreferences', () async {
      final n = ChatEngineNotifier(persist: false);
      n.send(contractorStore, BsRole.contractor, 'in-memory only');
      await settle();

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(kSysChatKey),
        isNull,
        reason: 'tests must be able to assert the seed/flow in isolation',
      );
    });

    test('a corrupt payload falls back to the verbatim seed', () async {
      SharedPreferences.setMockInitialValues({kSysChatKey: '{not json'});
      final n = ChatEngineNotifier();
      await settle();
      // Seed intact: the contractor still sees the seeded pairs.
      final ids = n.threadsFor(BsRole.contractor).map((t) => t.id).toSet();
      expect(ids, contains(contractorStore));
      expect(ids, contains(contractorManager));
      // And the engine state matches the seed count (nothing was dropped).
      expect(n.state.length, kChatThreads.length);
    });
  });
}
