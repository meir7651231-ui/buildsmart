// A13 (launch server-connect) — prove the CLIENT routes the order-stage advance
// + contractor-credit through their Cloud Functions CALLABLES (`advanceOrderStage`
// / `computeCredit`) when the `kServerCallables` flag is ON, and is BYTE-IDENTICAL
// to today (direct optimistic Firestore write / the client credit hash) when OFF.
//
// THE GAP A13 closes: the server functions EXIST (functions/src/orders.ts +
// credit.ts) and a `revertIllegalOrderStageWrite` trigger REVERTS direct stage
// writes — so the callable is the SANCTIONED stage-advance path. But the client
// only ever did direct optimistic Firestore writes, bypassing the server logic +
// S5 rules. A13 wires the gated callable path, forward-ready for when the owner
// deploys the functions + flips the flag.
//
// WHAT THIS FILE PROVES (the whole point — that it is NOT inert):
//   ORDERS:
//     1. flag ON  → `advance` INVOKES `advanceOrderStage({orderId})` with the
//        right arg, applies the SERVER'S returned `{to}` as an optimistic LOCAL
//        cache update, and fires NO direct persistent `set` (the trigger would
//        revert one — the callable is canonical);
//     2. flag OFF → the current direct-write path fires the `set` (the
//        zero-regression lock) and the callable is NEVER invoked;
//     3. a FunctionsException (not deployed / role denied) → no advance, no
//        crash, no faked success (the card keeps its stage).
//   CREDIT:
//     4. flag ON  → `computeCredit({name})` is INVOKED and the server figures
//        are returned;
//     5. flag OFF → the local derivation (byte-identical to the dashboard's sync
//        `creditLimit`/`pct`) is returned and the callable is NEVER invoked;
//     6. a FunctionsException → graceful fall back to the local derivation.
//   7. the compile-time default is OFF (`kServerCallables` false) → a default-
//      constructed notifier / repo gates exactly on that flag.
//
// The gate is the per-notifier/-repo `serverCallables` field, which DEFAULTS to
// the compile-time `kServerCallables` (production gates exactly on that flag,
// OFF today); a test injects `serverCallables: true` + a FAKE
// [OrderFunctionsGateway] to exercise the ON branch in the define-less suite (the
// `uidScoped` testability pattern). NO Firebase: the orders repo is driven by a
// hand-rolled fake [RemoteCollectionSource] (the cache-base test fake) that
// RECORDS every `set`, so "no direct persistent write when ON" is asserted on the
// bytes.

import 'dart:async';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/customers_local.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/order_functions.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource] (the cache-base test fake) —
/// RECORDS every `set`/`delete` and lets a test push snapshot events. The `sets`
/// list is the byte-level proof of whether a DIRECT persistent write happened.
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

/// A hand-rolled fake [OrderFunctionsGateway]: records every callable invocation
/// (args) and returns a configurable result, or throws a configurable
/// [OrderFunctionsException] to exercise the graceful-failure path.
class _FakeFunctions implements OrderFunctionsGateway {
  /// orderIds passed to `advanceOrderStage`, in call order.
  final List<String> advanceCalls = [];

  /// names passed to `computeCredit`, in call order.
  final List<String> creditCalls = [];

  /// When non-null, `advanceOrderStage` resolves with this; else it derives a
  /// trivial result from the orderId.
  AdvanceStageResult? advanceResult;

  /// When non-null, `computeCredit` resolves with this.
  CreditResult? creditResult;

  /// When non-null, the next matching call THROWS this (then clears).
  OrderFunctionsException? failAdvance;
  OrderFunctionsException? failCredit;

  @override
  Future<AdvanceStageResult> advanceOrderStage(String orderId) async {
    advanceCalls.add(orderId);
    final f = failAdvance;
    if (f != null) {
      failAdvance = null;
      throw f;
    }
    return advanceResult ??
        AdvanceStageResult(orderId: orderId, from: 'new', to: 'preparing');
  }

  @override
  Future<CreditResult> computeCredit(String name) async {
    creditCalls.add(name);
    final f = failCredit;
    if (f != null) {
      failCredit = null;
      throw f;
    }
    return creditResult ??
        CreditResult(
          name: name,
          creditLimit: 100,
          used: 25,
          balance: 75,
          pct: 25,
          orderCount: 1,
        );
  }
}

/// Settle the fire-and-forget callable round-trip (the optimistic local update
/// lands after the awaited callable resolves).
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The first seed order — `BS-1042`, stage 'new' (kManagerOrderSeed[0]).
  final seedFirst = kOrdersEngineSeed.first;

  group('A13 · ORDERS — advanceOrderStage callable (flag ON)', () {
    test('flag ON: advance INVOKES advanceOrderStage with the orderId, applies '
        "the server's {to} LOCALLY, and fires NO direct persistent set", () async {
      final src = _FakeSource();
      addTearDown(src.close);
      final repo = FirebaseOrdersRepository(source: src);
      addTearDown(repo.dispose);
      final fns =
          _FakeFunctions()
            // The server reports the canonical step it performed.
            ..advanceResult = AdvanceStageResult(
              orderId: seedFirst.id,
              from: 'new',
              to: 'preparing',
            );

      final engine = OrdersEngineNotifier(
        persist: false,
        serverCallables:
            true, // ← flag ON (production gates on kServerCallables)
        functions: fns,
      )..bindRemote(repo);
      addTearDown(engine.dispose);

      // Pre-condition: the seed order is at 'new', the fake recorded the SEED
      // writes only (bindRemote does not write; we clear them to isolate advance).
      expect(engine.state.firstWhere((o) => o.id == seedFirst.id).stage, 'new');
      src.sets.clear();

      engine.advance(seedFirst.id);
      await _settle();

      // ── PROOF 1: the callable was invoked with the right arg ────────────────
      expect(
        fns.advanceCalls,
        [seedFirst.id],
        reason: 'A13: the stage advance routed through advanceOrderStage',
      );

      // ── PROOF 2: the server's canonical {to} is mirrored LOCALLY ────────────
      expect(
        engine.state.firstWhere((o) => o.id == seedFirst.id).stage,
        'preparing',
        reason: "the optimistic local update uses the server's returned stage",
      );

      // ── PROOF 3: NO direct persistent write (the trigger would revert it) ───
      expect(
        src.sets,
        isEmpty,
        reason:
            'A13 ON: the callable is the canonical write; the client must '
            'NOT also fire a direct set (revertIllegalOrderStageWrite)',
      );
    });

    test(
      'flag ON: a FunctionsException → NO advance, NO crash, NO faked success',
      () async {
        final src = _FakeSource();
        addTearDown(src.close);
        final repo = FirebaseOrdersRepository(source: src);
        addTearDown(repo.dispose);
        final fns =
            _FakeFunctions()
              // e.g. the function is not deployed yet, or the role is denied.
              ..failAdvance = const OrderFunctionsException(
                'unavailable',
                'not deployed',
              );

        final engine = OrdersEngineNotifier(
          persist: false,
          serverCallables: true,
          functions: fns,
        )..bindRemote(repo);
        addTearDown(engine.dispose);
        src.sets.clear();

        engine.advance(seedFirst.id); // must not throw
        await _settle();

        expect(fns.advanceCalls, [
          seedFirst.id,
        ], reason: 'it tried the callable');
        // Honest: the card keeps its stage; nothing faked, nothing written.
        expect(
          engine.state.firstWhere((o) => o.id == seedFirst.id).stage,
          'new',
          reason: 'a denied/undeployed advance does NOT move the order',
        );
        expect(src.sets, isEmpty, reason: 'no write on failure either');
      },
    );
  });

  group(
    'A13 · ORDERS — direct-write path (flag OFF = zero-regression lock)',
    () {
      test('flag OFF: advance fires the DIRECT set (byte-identical) and the '
          'callable is NEVER invoked', () async {
        final src = _FakeSource();
        addTearDown(src.close);
        final repo = FirebaseOrdersRepository(source: src);
        addTearDown(repo.dispose);
        final fns = _FakeFunctions(); // a gateway IS available…

        final engine = OrdersEngineNotifier(
          persist: false,
          serverCallables: false, // ← OFF = today, exactly
          functions: fns,
        )..bindRemote(repo);
        addTearDown(engine.dispose);
        src.sets.clear();

        engine.advance(seedFirst.id);
        await _settle();

        // The callable was NEVER touched — the direct optimistic write path ran.
        expect(
          fns.advanceCalls,
          isEmpty,
          reason:
              'OFF ⇒ no callable ⇒ the direct Firestore write is today, '
              'exactly (the A13 zero-regression invariant)',
        );
        // The optimistic cache advanced to the next flow stage…
        expect(
          engine.state.firstWhere((o) => o.id == seedFirst.id).stage,
          'preparing',
          reason: 'verbatim ORDER_FLOW advance (new→preparing)',
        );
        // …and fired a DIRECT background set carrying the new stage.
        expect(
          src.sets.where((e) => e.key == seedFirst.id),
          isNotEmpty,
          reason: 'OFF: the direct persistent write still happens (today)',
        );
        expect(
          src.sets.lastWhere((e) => e.key == seedFirst.id).value['stage'],
          'preparing',
        );
      });

      test(
        'default-constructed engine inherits the compile-time flag (OFF)',
        () {
          expect(
            kServerCallables,
            isFalse,
            reason: 'production gates EXACTLY on the compile-time flag',
          );
          final engine = OrdersEngineNotifier(persist: false);
          addTearDown(engine.dispose);
          expect(
            engine.serverCallables,
            isFalse,
            reason:
                'the provider passes nothing → inherits kServerCallables (OFF)',
          );
        },
      );
    },
  );

  // ── CREDIT ──────────────────────────────────────────────────────────────────

  /// Build a [LocalCustomersRepository] with the injected flag + fake gateway,
  /// wired through a real [ProviderContainer] so it has a live [Ref] (it reads
  /// `ordersEngineProvider` for the spend fold). The seed engine is Firebase-free
  /// (no gateway bound there) → the credit gateway is exercised only via the
  /// injected one, exactly as production would route it.
  LocalCustomersRepository creditRepo({
    required bool? serverCallables,
    required OrderFunctionsGateway functions,
  }) {
    late LocalCustomersRepository repo;
    final c = ProviderContainer(
      overrides: [
        customersRepositoryProvider.overrideWith((ref) {
          repo = LocalCustomersRepository(
            ref,
            serverCallables: serverCallables,
            functions: functions,
          );
          return repo;
        }),
      ],
    );
    addTearDown(c.dispose);
    // Resolve the provider so `repo` is assigned with a live Ref.
    c.read(customersRepositoryProvider);
    return repo;
  }

  /// The seed contractor name (kManagerOrderSeed[0].who) — present in the
  /// engine's seed aggregate, so the local derivation has real spend.
  final seedBuyer = seedFirst.who;

  group('A13 · CREDIT — computeCredit callable (flag ON)', () {
    test(
      'flag ON: computeCredit INVOKES the callable and returns server figures',
      () async {
        final fns =
            _FakeFunctions()
              ..creditResult = CreditResult(
                name: seedBuyer,
                creditLimit: 88000,
                used: 12000,
                balance: 76000,
                pct: 14,
                orderCount: 3,
              );
        final repo = creditRepo(serverCallables: true, functions: fns); // ← ON

        final r = await repo.computeCredit(seedBuyer);

        expect(
          fns.creditCalls,
          [seedBuyer],
          reason: 'A13: credit routed through the computeCredit callable',
        );
        // The SERVER figures are returned verbatim (server-canonical).
        expect(r.creditLimit, 88000);
        expect(r.used, 12000);
        expect(r.balance, 76000);
        expect(r.pct, 14);
        expect(r.orderCount, 3);
      },
    );

    test(
      'flag ON: a FunctionsException → graceful fall back to the local figures',
      () async {
        final fns =
            _FakeFunctions()
              ..failCredit = const OrderFunctionsException(
                'permission-denied',
                'not allowed',
              );
        final repo = creditRepo(serverCallables: true, functions: fns);

        final r = await repo.computeCredit(seedBuyer); // must not throw

        expect(fns.creditCalls, [seedBuyer], reason: 'it tried the callable');
        // Fell back to the SAME deterministic client ceiling — never faked.
        expect(
          r.creditLimit,
          contractorCredit(seedBuyer),
          reason: 'graceful fallback = the local derivation (honest)',
        );
        expect(
          r.used,
          greaterThan(0),
          reason: 'the live spend fold still drives `used`',
        );
      },
    );
  });

  group('A13 · CREDIT — local derivation (flag OFF = zero-regression)', () {
    test('flag OFF: computeCredit returns the LOCAL figures (byte-identical) and '
        'the callable is NEVER invoked', () async {
      final fns = _FakeFunctions(); // available but must stay untouched
      final repo = creditRepo(
        serverCallables: false,
        functions: fns,
      ); // ← OFF = today

      final r = await repo.computeCredit(seedBuyer);

      expect(
        fns.creditCalls,
        isEmpty,
        reason: 'OFF ⇒ no callable ⇒ the client credit derivation is today',
      );
      // creditLimit is byte-identical to the sync path the dashboard uses.
      expect(r.creditLimit, repo.creditLimit(seedBuyer));
      expect(r.creditLimit, contractorCredit(seedBuyer));
      // pct/balance match the manager_dashboard_screen formulas over real spend.
      final c = repo.byName(seedBuyer)!;
      final expectedPct =
          r.creditLimit == 0
              ? 0
              : ((c.totalSpend / r.creditLimit) * 100).round().clamp(0, 100);
      expect(r.pct, expectedPct);
      expect(r.used, c.totalSpend);
      expect(r.orderCount, c.orderCount);
    });

    test(
      'default-constructed repo inherits the compile-time flag (OFF)',
      () async {
        final fns = _FakeFunctions();
        // No serverCallables passed → defaults to kServerCallables (false).
        final repo = creditRepo(serverCallables: null, functions: fns);
        await repo.computeCredit(seedBuyer);
        expect(
          fns.creditCalls,
          isEmpty,
          reason:
              'the provider passes no flag → inherits kServerCallables (OFF)',
        );
      },
    );
  });
}
