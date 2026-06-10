// REAL-TIME ENGINE⇄CACHE WIRING (S4.1–S4.4) — unit coverage for the loop that
// makes real-time flow INTO the existing engines through the caches, WITHOUT
// Firebase: fake [RemoteCollectionSource]s drive the real `_firebase` repos,
// the real engines bind to them (`bindRemote`), and we assert BOTH directions:
//   • DOWN — a fake-source snapshot lands → the repo cache replaces → notify →
//     the engine state rebuilds → `threadsFor`/orders getters reflect it from
//     a SYNCHRONOUS read (S4.1/S4.2/S4.4);
//   • UP — an engine mutation (`send`/`advance`/`placeOrder`) delegates to the
//     repo's verbatim port → optimistic cache (mirrored back into the engine in
//     the SAME synchronous call) + the Firestore write recorded on the fake.
// Plus the LOCAL FALLBACK pin: unbound engines (the whole Firebase-free suite,
// and `chatRepositoryProvider` → null) behave byte-identically to today.
//
// S4.5 (the two-device A→B check) is NOT runnable here — no network/Firebase in
// this environment — so these fakes pin the exact loop the devices will ride;
// the live cross-device verification happens on real devices after deploy.

import 'dart:async';

import 'package:buildsmart/data/chat_seeds.dart';
import 'package:buildsmart/data/repositories/chat_firebase.dart';
import 'package:buildsmart/data/repositories/chat_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/supplier_data.dart' show OrderStage;
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The hand-rolled fake source (the S2 base-test fake, verbatim shape).
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const contractorStore = 'th-contractor-store';

  // ── chat: a bound engine over fake-driven chatThreads+chatMessages caches ──
  ({
    ChatEngineNotifier engine,
    FirebaseChatRepository repo,
    _FakeSource threads,
    _FakeSource messages,
  }) boundChat() {
    final threads = _FakeSource();
    final messages = _FakeSource();
    final repo = FirebaseChatRepository(
      threadsSource: threads,
      messagesSource: messages,
    )..attach();
    final engine = ChatEngineNotifier(persist: false)..bindRemote(repo);
    addTearDown(threads.close);
    addTearDown(messages.close);
    addTearDown(repo.dispose);
    addTearDown(engine.dispose); // LIFO: engine unbinds before the repo dies
    return (engine: engine, repo: repo, threads: threads, messages: messages);
  }

  // ── orders: a bound engine over a fake-driven orders cache ─────────────────
  ({
    OrdersEngineNotifier engine,
    FirebaseOrdersRepository repo,
    _FakeSource src,
  }) boundOrders() {
    final src = _FakeSource();
    final repo = FirebaseOrdersRepository(source: src)..attach();
    final engine = OrdersEngineNotifier(persist: false)..bindRemote(repo);
    addTearDown(src.close);
    addTearDown(repo.dispose);
    addTearDown(engine.dispose);
    return (engine: engine, repo: repo, src: src);
  }

  group('chat engine ⇄ cache (S4.1/S4.2 — snapshots flow IN)', () {
    test(
        'a remote message snapshot rebuilds the engine — threadsFor reflects '
        'it synchronously, isolation intact', () async {
      final c = boundChat();

      // The other device's store message lands as a chatMessages snapshot.
      c.messages.emit(const [
        RemoteDoc('m-remote-1', {
          'threadId': contractorStore,
          'fromRole': 'store',
          'text': 'הגיע ממכשיר אחר 📡',
          'ts': '2026-06-10T10:00:00.000',
        }),
      ]);
      await Future<void>.delayed(Duration.zero); // stream delivery only

      // SYNC reads off the engine: both participants see it…
      for (final role in [BsRole.contractor, BsRole.store]) {
        final t = c.engine
            .threadsFor(role)
            .firstWhere((t) => t.id == contractorStore);
        expect(t.messages.last.text, 'הגיע ממכשיר אחר 📡');
        expect(t.messages.last.fromRole, BsRole.store);
      }
      // …and 🔒 isolation still holds on remote-fed state (SPEC §2.5).
      expect(
        c.engine.threadsFor(BsRole.store).any(
              (t) => t.id == 'th-contractor-manager',
            ),
        isFalse,
      );
    });

    test('engine.send is one SYNCHRONOUS loop: state + cache + recorded write',
        () async {
      final c = boundChat();

      c.engine.send(contractorStore, BsRole.contractor, 'יוצא מהמנוע 👷');

      // NO await: the optimistic upsert notified back inside the same call —
      // the engine state and the repo cache already agree.
      final viaEngine = c.engine
          .threadsFor(BsRole.store)
          .firstWhere((t) => t.id == contractorStore);
      expect(viaEngine.messages.last.text, 'יוצא מהמנוע 👷');
      final viaRepo =
          c.repo.threads().firstWhere((t) => t.id == contractorStore);
      expect(viaRepo.messages.last.text, 'יוצא מהמנוע 👷');

      // The background writes were recorded: the message + the head's
      // lastMsg/ts denormalisation (S4.3).
      await Future<void>.delayed(Duration.zero);
      expect(c.messages.sets.any((e) => e.value['text'] == 'יוצא מהמנוע 👷'),
          isTrue,);
      expect(
        c.threads.sets
            .firstWhere((e) => e.key == contractorStore)
            .value['lastMsg'],
        'יוצא מהמנוע 👷',
      );
    });

    test('the bot auto-reply rides the same loop (engine sees both lines)', () {
      final c = boundChat();
      final before = c.engine.state
          .firstWhere((t) => t.id == 'th-bot')
          .messages
          .length;

      c.engine.send('th-bot', BsRole.contractor, 'מה הסטטוס?');

      final bot = c.engine.state.firstWhere((t) => t.id == 'th-bot');
      expect(bot.messages.length, before + 2); // user line + auto-reply
      expect(bot.messages.last.fromRole, BsRole.bot);
      expect(kBotAutoReplies, contains(bot.messages.last.text));
    });
  });

  group('orders engine ⇄ cache (S4.4 — live stage status)', () {
    test(
        'a remote stage-change snapshot rebuilds the engine AND the '
        'sysOrdersProvider projection (store advance → courier/contractor see it)',
        () async {
      // Built inline (not via [boundOrders]): the override makes the CONTAINER
      // own + dispose the engine, so the helper's engine tear-down would
      // double-dispose. LIFO: container (→engine) → repo → source.
      final src = _FakeSource();
      final repo = FirebaseOrdersRepository(source: src)..attach();
      final engine = OrdersEngineNotifier(persist: false)..bindRemote(repo);
      final o = (engine: engine, repo: repo, src: src);
      // Project the bound engine through the real store/courier view.
      final container = ProviderContainer(
        overrides: [ordersEngineProvider.overrideWith((ref) => o.engine)],
      );
      addTearDown(src.close);
      addTearDown(repo.dispose);
      addTearDown(container.dispose);
      expect(container.read(sysOrdersProvider).length, 4); // seeded projection

      // The store device advanced BS-1042 → the snapshot lands here.
      o.src.emit(const [
        RemoteDoc('BS-1042', {
          'contractorId': 'קבלן א',
          'siteAddress': 'אתר מרכזי',
          'items': 5,
          'sum': 1200,
          'stage': 'ready',
        }),
      ]);
      await Future<void>.delayed(Duration.zero); // stream delivery only

      // SYNC reads: engine getters + the derived SysOrder projection moved.
      expect(o.engine.state.single.stage, 'ready');
      expect(o.repo.open().single.id, 'BS-1042');
      final sys = container.read(sysOrdersProvider).single;
      expect(sys.id, 'BS-1042');
      expect(sys.stage, OrderStage.ready);
    });

    test(
        'engine.advance / placeOrder delegate UP: optimistic cache mirrored '
        'synchronously + Firestore write recorded', () async {
      final o = boundOrders();

      // advance: BS-1042 is `new` → `preparing` (the verbatim flow walk).
      o.engine.advance('BS-1042');
      expect(o.engine.state.first.stage, 'preparing'); // no await — same frame
      expect(o.repo.byId('BS-1042')!.stage, 'preparing');

      // placeOrder: next BS-#### above the seed max, prepended, stage `new`.
      final placed = o.engine.placeOrder(
        who: 'קבלן',
        site: 'אתר',
        items: 3,
        sum: 540,
      );
      expect(placed.id, 'BS-1043');
      expect(o.engine.state.first.id, 'BS-1043');
      expect(o.repo.byId('BS-1043')!.stage, 'new');

      await Future<void>.delayed(Duration.zero);
      final byId = {for (final e in o.src.sets) e.key: e.value};
      expect(byId['BS-1042']!['stage'], 'preparing');
      expect(byId['BS-1043']!['contractorId'], 'קבלן');
    });

    test('resetToSeed (bound) restores the seed through the cache', () async {
      final o = boundOrders();
      o.engine
        ..placeOrder(who: 'x', site: 's', items: 1, sum: 1)
        ..resetToSeed();
      expect(o.engine.state.map((x) => x.id).toList(),
          kOrdersEngineSeed.map((x) => x.id).toList(),);
      await Future<void>.delayed(Duration.zero);
      expect(o.src.sets.map((e) => e.key).toSet(),
          containsAll(kOrdersEngineSeed.map((x) => x.id)),);
    });
  });

  group("local fallback (no Firebase — the whole suite's path)", () {
    test('chatRepositoryProvider resolves NULL → the engine stays the store',
        () async {
      // No Firebase.initializeApp anywhere in tests → Firebase.apps is empty.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(chatRepositoryProvider), isNull);

      // The engine the provider builds is UNBOUND: seed verbatim, send works
      // purely locally — byte-identical to the pre-S4 behavior. The local
      // seed is the FULL one: legacy cross-persona threads + the
      // board-audience threads (#70/#75, kWorkerChatThreads in sys_chat).
      final engine = container.read(chatEngineProvider.notifier);
      expect(container.read(chatEngineProvider).map((t) => t.id).toList(), [
        ...kChatThreads.map((t) => t.id),
        ...kWorkerChatThreads.map((t) => t.id),
      ]);
      engine.send(contractorStore, BsRole.store, 'מקומי בלבד');
      expect(
        engine
            .threadsFor(BsRole.contractor)
            .firstWhere((t) => t.id == contractorStore)
            .messages
            .last
            .text,
        'מקומי בלבד',
      );
    });

    test('an UNBOUND orders engine never touches the remote', () async {
      final src = _FakeSource();
      addTearDown(src.close);
      // A repo exists in the world (constructed, even attached)…
      final repo = FirebaseOrdersRepository(source: src)..attach();
      addTearDown(repo.dispose);
      // …but the engine was never bound (the Firebase-free provider path).
      final engine = OrdersEngineNotifier(persist: false);
      addTearDown(engine.dispose);

      engine.advance('BS-1042');
      expect(engine.state.first.stage, 'preparing'); // local flow, verbatim
      expect(repo.byId('BS-1042')!.stage, 'new'); // the cache never moved

      await Future<void>.delayed(Duration.zero);
      expect(src.sets, isEmpty); // and nothing was ever written remotely
    });
  });
}
