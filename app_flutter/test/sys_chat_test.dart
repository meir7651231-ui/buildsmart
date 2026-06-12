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
//
// F-35: an EARLY send (before _load resolves) must not erase the persisted
// overlay of OTHER threads on the next write — the late load merges the disk
// overlay AROUND the pre-load mutation (_dirtyThreadIds + _loadSettled gate).
// F-56: _persist caps each thread at the newest kSysChatPersistCap messages on
// DISK while the in-memory list stays whole within the session.
// F-25: the courier↔store audience bridge lives in the PRIVATE
// `_visibleToAudience` of chats_screen.dart, so it is covered by a minimal
// widget test over `ChatsScreen` (keyed Dismissible rows) — see the last group.

import 'dart:convert';

import 'package:buildsmart/data/chat_seeds.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // …but NOT the contractor↔manager thread. (#83: the supplier chat now
      // INCLUDES the shared bot thread by design — the old not-contains
      // assertion was superseded by the approved supplier-chat spec.)
      expect(
        storeThreads,
        isNot(contains(contractorManager)),
        reason: 'the store must never see a contractor↔manager thread',
      );
      expect(storeThreads, contains(botThread),
          reason: '#83 — בוט is part of the supplier chat');

      // #83 seed-lock: the four supplier-chat threads must carry
      // audience 'store' — a wrong audience silently hides them from the
      // supplier's שיחות tab (mutation-survival hole closed 2026-06-11).
      const storeAudienceIds = [
        'th-store-contractors',
        'th-store-courier-pickups',
        'th-store-manager',
        'th-suppliers-group',
      ];
      for (final id in storeAudienceIds) {
        expect(
          kChatThreads.firstWhere((t) => t.id == id).audience,
          'store',
          reason: '#83 — $id חייב audience חנות',
        );
      }
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
      // And the engine state matches the FULL seed count (nothing was dropped)
      // — legacy cross-persona threads + the board-audience threads (#70/#75,
      // kWorkerChatThreads in sys_chat.dart).
      expect(n.state.length, kChatThreads.length + kWorkerChatThreads.length);
    });

    test('F-35 — an early send (before _load) does not erase another '
        "thread's persisted overlay", () async {
      // Disk already holds an overlay for the contractor↔manager thread (a
      // previous session). Note the overlay REPLACES the thread's message
      // list on load — so after a clean load the thread has exactly this one
      // message.
      final diskMsg = ChatMessage(
        id: 'm-disk-1',
        threadId: contractorManager,
        fromRole: BsRole.manager,
        text: 'הודעת דיסק ישנה — אסור שתימחק',
        ts: DateTime(2026, 6, 10, 9),
      );
      SharedPreferences.setMockInitialValues({
        kSysChatKey: jsonEncode({
          contractorManager: [diskMsg.toJson()],
        }),
      });

      final n = ChatEngineNotifier();
      final seedStoreLen = n.state
          .firstWhere((t) => t.id == contractorStore)
          .messages
          .length;
      // Mutate SYNCHRONOUSLY, before the async _load resolves — the old bug:
      // this send's _persist then serialized seed message-lists over every
      // other thread's persisted messages.
      n.send(contractorStore, BsRole.store, 'שליחה מוקדמת לפני load');
      await settle();

      // The pre-load mutation survived (the #24-style half of the race)…
      final store =
          n.state.firstWhere((t) => t.id == contractorStore).messages;
      expect(store.length, seedStoreLen + 1);
      expect(store.last.text, 'שליחה מוקדמת לפני load',
          reason: 'the late load must merge AROUND the early send');
      // …and the OTHER thread still hydrated from disk (the F-35 half).
      final manager =
          n.state.firstWhere((t) => t.id == contractorManager).messages;
      expect(manager.single.id, 'm-disk-1',
          reason: 'the disk overlay of an untouched thread must be applied');

      // The decisive proof: the NEXT write (triggered by the send) reached
      // disk AFTER the merge — both threads' messages are on disk now.
      final prefs = await SharedPreferences.getInstance();
      final onDisk =
          jsonDecode(prefs.getString(kSysChatKey)!) as Map<String, dynamic>;
      expect(
        ((onDisk[contractorManager] as List).single as Map)['id'],
        'm-disk-1',
        reason: "the early send must NOT overwrite the other thread's "
            'persisted messages on the next write',
      );
      expect(
        ((onDisk[contractorStore] as List).last as Map)['text'],
        'שליחה מוקדמת לפני load',
      );

      // And a full "restart" sees both — end-to-end.
      final second = ChatEngineNotifier();
      await settle();
      expect(
        second.state
            .firstWhere((t) => t.id == contractorManager)
            .messages
            .single
            .text,
        'הודעת דיסק ישנה — אסור שתימחק',
      );
      expect(
        second.state
            .firstWhere((t) => t.id == contractorStore)
            .messages
            .last
            .text,
        'שליחה מוקדמת לפני load',
      );
    });

    test('F-56 — disk keeps only the newest kSysChatPersistCap messages per '
        'thread; memory keeps them all', () async {
      final n = ChatEngineNotifier();
      await settle(); // initial _load resolves (empty store → seed)
      final seedLen = n.state
          .firstWhere((t) => t.id == contractorStore)
          .messages
          .length;

      const total = kSysChatPersistCap + 5;
      for (var i = 1; i <= total; i++) {
        n.send(contractorStore, BsRole.contractor, 'הודעה $i');
      }
      await settle(); // let the last _persist land

      // In-memory: WHOLE within the session (the cap is a disk budget only).
      expect(
        n.state.firstWhere((t) => t.id == contractorStore).messages.length,
        seedLen + total,
        reason: 'F-56 trims the persisted copy, never the live list',
      );

      // On disk: exactly the newest cap (seeds + oldest sends fell off).
      final prefs = await SharedPreferences.getInstance();
      final onDisk =
          jsonDecode(prefs.getString(kSysChatKey)!) as Map<String, dynamic>;
      final stored = onDisk[contractorStore] as List;
      expect(stored.length, kSysChatPersistCap,
          reason: 'prefs is a bounded budget — cap per thread');
      expect((stored.last as Map)['text'], 'הודעה $total',
          reason: 'the newest message is the last one persisted');
      expect(
        (stored.first as Map)['text'],
        'הודעה ${total - kSysChatPersistCap + 1}',
        reason: 'the persisted window is the NEWEST cap, oldest dropped',
      );

      // A restart honors the capped overlay (it replaces the seed list).
      final second = ChatEngineNotifier();
      await settle();
      final restored = second.state
          .firstWhere((t) => t.id == contractorStore)
          .messages;
      expect(restored.length, kSysChatPersistCap);
      expect(restored.last.text, 'הודעה $total');

      // Other threads were NOT trimmed — under the cap they persist whole.
      final managerStored = onDisk[contractorManager] as List?;
      if (managerStored != null) {
        expect(managerStored.length, lessThanOrEqualTo(kSysChatPersistCap));
      }
    });
  });

  // ── F-25 · the courier↔store audience bridge (widget) ────────────────────
  //
  // `_visibleToAudience` is PRIVATE to chats_screen.dart (no exposed seam), so
  // per the brief the bridge is covered by a light widget test: pump
  // `ChatsScreen` per board audience and assert which thread rows exist — each
  // row is a `Dismissible(key: ValueKey(thread.id))`, so presence is keyed and
  // unambiguous. The bridge (chats_screen.dart doc): the courier's attendance
  // report (#86.2) goes to 'th-store-courier-pickups' (audience 'store') and
  // the courier's daily report goes to 'th-courier-lipskey' (audience
  // 'courier') — without the symmetric bridge each side's send was write-only
  // for the other. The participants check keeps every OTHER audience-crossing
  // thread invisible.
  group('F-25 · courier↔store bridge (ChatsScreen widget)', () {
    Future<void> pumpChats(
      WidgetTester t, {
      required BsRole persona,
      required String audience,
    }) async {
      // Tall surface so the lazy ListView builds EVERY row (keyed presence
      // checks below depend on it).
      await t.binding.setSurfaceSize(const Size(600, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: ChatsScreen(
                  persona: persona,
                  audience: audience,
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      );
      // Bounded settle (the robustness_test idiom — AnimatedSize animates).
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(milliseconds: 120));
      }
    }

    testWidgets(
        'courier audience sees the bridged store-audience pickups thread',
        (t) async {
      await pumpChats(t, persona: BsRole.courier, audience: 'courier');

      // The bridge: audience-'store' store↔courier thread is visible here —
      // this is where the courier's attendance report (#86.2) lands.
      expect(find.byKey(const ValueKey('th-store-courier-pickups')),
          findsOneWidget,
          reason: "F-25 — without the bridge the courier's reports were "
              'write-only for the store');
      // The courier's own threads are intact.
      expect(
          find.byKey(const ValueKey('th-courier-lipskey')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('th-courier-customer')), findsOneWidget);
      // Isolation holds for every OTHER audience-crossing thread:
      expect(find.byKey(const ValueKey('th-store-manager')), findsNothing,
          reason: 'store-audience thread the courier does NOT take part in');
      expect(find.byKey(const ValueKey('th-contractor-store')), findsNothing,
          reason: 'contractor-audience threads are not bridged');
      expect(find.byKey(const ValueKey('th-worker-manager')), findsNothing,
          reason: 'worker-audience threads are not bridged');
    });

    testWidgets(
        'store audience sees the bridged courier-audience lipskey thread '
        '(symmetric)', (t) async {
      await pumpChats(t, persona: BsRole.store, audience: 'store');

      // The symmetric half: audience-'courier' store↔courier thread is
      // visible on the store board — the courier's daily report destination.
      expect(find.byKey(const ValueKey('th-courier-lipskey')), findsOneWidget,
          reason: 'F-25 — the store must read the courier-audience side of '
              'the pair');
      // The store's own #83 threads are intact.
      expect(find.byKey(const ValueKey('th-store-courier-pickups')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('th-store-manager')), findsOneWidget);
      // Isolation: courier-audience threads the store does NOT participate in
      // stay invisible even though their audience crosses the bridge.
      expect(find.byKey(const ValueKey('th-courier-customer')), findsNothing,
          reason: 'participants check still gates the bridged audience');
      expect(find.byKey(const ValueKey('th-couriers-group')), findsNothing,
          reason: "couriers-group is courier↔manager — not the store's");
    });
  });
}
