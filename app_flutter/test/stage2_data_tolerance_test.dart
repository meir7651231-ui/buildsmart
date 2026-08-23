// STAGE-2 · iron-rule #1 — "לא קורס לעולם": every engine tolerates EMPTY /
// MISSING-FIELDS / MALFORMED / HUGE data (DIRECTIVE-buildsmart-clean.md §2.1).
//
// Firebase-free. Two idioms reused verbatim from the suite:
//   • corrupt prefs via SharedPreferences.setMockInitialValues
//     (offline_order_queue_test.dart);
//   • a hand-rolled fake RemoteCollectionSource driving the REAL mappers
//     (firestore_cached_repo_test.dart — no fake_cloud_firestore).
//
// Covers ONLY the gaps the stage-2 audit found (T1-T5); the already-pinned
// cells (base per-doc skip, customers/stock/chat corrupt docs, worker/courier
// prefs stores, honest empty-states) live in their own suites and are not
// re-tested here. The site mapper's tolerance follows from the same base
// per-doc skip (pinned generically in firestore_cached_repo_test) — the real-
// mapper proof here runs through orders + finance.

import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/repositories/finance_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hand-rolled fake [RemoteCollectionSource] (the firestore_cached_repo_test
/// idiom) — lets a test push snapshots through the REAL fromDoc mappers.
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;

  Future<void> close() => _controller.close();
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T1 · orders prefs — per-entry tolerance (stage-2 F1)', () {
    test('one corrupt persisted entry is SKIPPED — the rest survive', () async {
      // Place a real order so the persisted payload is authentic (seed + new).
      SharedPreferences.setMockInitialValues({});
      final n1 = OrdersEngineNotifier();
      await _settle();
      n1.placeOrder(
        who: 'בודק סבילות',
        site: 'אתר בדיקה',
        items: 2,
        sum: 750,
        id: 'BS-T1',
      );
      await _settle();
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kOrdersEngineKey);
      expect(raw, isNotNull, reason: 'placeOrder persisted the engine');

      // Corrupt exactly ONE entry (missing every required field).
      final entries = jsonDecode(raw!) as List<dynamic>;
      final goodCount = entries.length;
      entries.add(<String, dynamic>{'id': 'BAD'});
      SharedPreferences.setMockInitialValues(
        {kOrdersEngineKey: jsonEncode(entries)},
      );

      final n2 = OrdersEngineNotifier();
      await _settle();
      // The good entries all survive; the corrupt one is skipped — the engine
      // is NOT reset to the seed (the pre-fix behavior).
      expect(n2.state.length, goodCount);
      expect(n2.state.any((o) => o.id == 'BS-T1'), isTrue);
      expect(n2.state.any((o) => o.id == 'BAD'), isFalse);
    });

    test('an ALL-corrupt non-empty payload keeps the seed (never empty)',
        () async {
      SharedPreferences.setMockInitialValues({
        kOrdersEngineKey: jsonEncode([
          {'id': 'X'},
          {'nonsense': true},
        ]),
      });
      final n = OrdersEngineNotifier();
      await _settle();
      expect(n.state.length, 4); // the seed — never an empty engine
    });

    test('HUGE: 5,000 persisted orders load without a throw and stay live',
        () async {
      const template = Order(
        id: 'BS-H',
        who: 'קבלן עומס',
        site: 'אתר עומס',
        items: 1,
        sum: 10,
        stage: 'new',
      );
      final blob = jsonEncode([
        for (var i = 0; i < 5000; i++)
          (template.toJson()..['id'] = 'BS-H$i'),
      ]);
      SharedPreferences.setMockInitialValues({kOrdersEngineKey: blob});

      final n = OrdersEngineNotifier();
      await _settle();
      expect(n.state.length, 5000);
      // The engine still functions on top of the huge list.
      n.setStage('BS-H4999', 'delivered');
      expect(
        n.state.firstWhere((o) => o.id == 'BS-H4999').stage,
        'delivered',
      );
    });
  });

  group('T2 · orders REAL mapper — malformed docs skipped, list never blanks',
      () {
    test('missing-fields + wrong-type docs are skipped; the good doc renders',
        () async {
      final src = _FakeSource();
      final repo = FirebaseOrdersRepository(source: src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      const good = Order(
        id: 'BS-T2',
        who: 'קבלן אמת',
        site: 'אתר אמת',
        items: 3,
        sum: 900,
        stage: 'new',
      );
      src.emit([
        RemoteDoc('BS-T2', repo.toDoc(good)), // real toDoc → real fromDoc
        const RemoteDoc('BS-9', <String, dynamic>{}), // missing everything
        const RemoteDoc('BS-8', {'items': 'seven'}), // wrong type
      ]);
      await Future<void>.delayed(Duration.zero);

      final cached = repo.cached();
      expect(cached.length, 1, reason: 'both corrupt docs skipped');
      expect(cached.single.id, 'BS-T2');
    });
  });

  group('T3 · finance REAL mapper — a corrupt approval doc never blanks the '
      'queue', () {
    test('good approval kept, corrupt one skipped', () async {
      final approvals = _FakeSource();
      final penalties = _FakeSource();
      final term = _FakeSource();
      final budget = _FakeSource();
      final repo = FirebaseFinanceRepository(
        null,
        approvalsSource: approvals,
        penaltiesSource: penalties,
        paymentTermSource: term,
        budgetSource: budget,
      )..attach();
      addTearDown(approvals.close);
      addTearDown(penalties.close);
      addTearDown(term.close);
      addTearDown(budget.close);
      addTearDown(repo.dispose);

      approvals.emit([
        const RemoteDoc('AP-OK', {
          'what': 'הזמנת בדיקה',
          'amount': 1200,
          'by': 'מנהל עבודה',
          'status': 'ממתין',
        }),
        const RemoteDoc('AP-BAD', {'amount': 'not-a-number'}),
      ]);
      await Future<void>.delayed(Duration.zero);

      final queue = repo.approvals();
      expect(queue.length, 1, reason: 'corrupt approval skipped, not fatal');
      expect(queue.single.id, 'AP-OK');
      expect(queue.single.amount, 1200);
    });
  });

  group('T4 · prefs stores — corrupt payloads degrade to safe defaults', () {
    test('board session: corrupt JSON → logged out (null), no throw', () async {
      SharedPreferences.setMockInitialValues({'bs.board-auth.v1': '{not json['});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _settle();
      expect(c.read(boardAuthProvider), isNull);
    });

    test('board session: missing fields → logged out (null), no throw',
        () async {
      SharedPreferences.setMockInitialValues({'bs.board-auth.v1': '{"x":1}'});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _settle();
      expect(c.read(boardAuthProvider), isNull);
    });

    test('rewards: garbage payload → seed kept (coins 340), no throw',
        () async {
      SharedPreferences.setMockInitialValues({kRewardsKey: 'garbage{{'});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _settle();
      expect(c.read(rewardsProvider).coins, 340);
    });

    // The cart prefs key is private to smart_cart.dart ('bs.smart-cart.v1') —
    // hardcoded here on purpose: if the key ever changes these cases silently
    // test nothing, so keep them in sync with the store.
    test('smart cart: corrupt payload → empty cart, no throw', () async {
      SharedPreferences.setMockInitialValues({'bs.smart-cart.v1': '[{{'});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _settle();
      expect(c.read(smartCartProvider), isEmpty);
    });

    test('HUGE: a 1MB junk blob under the cart key → empty cart, no throw',
        () async {
      SharedPreferences.setMockInitialValues(
        {'bs.smart-cart.v1': 'x' * 1000000},
      );
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _settle();
      expect(c.read(smartCartProvider), isEmpty);
    });
  });

  group('T5 · HUGE snapshots through the cache base + real mapper', () {
    test('5,000 remote order docs replace the cache, sorted, no throw',
        () async {
      final src = _FakeSource();
      final repo = FirebaseOrdersRepository(source: src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      const template = Order(
        id: 'BS-R',
        who: 'קבלן עומס',
        site: 'אתר עומס',
        items: 1,
        sum: 10,
        stage: 'new',
      );
      final docs = <RemoteDoc>[
        for (var i = 0; i < 5000; i++)
          RemoteDoc('BS-R$i', repo.toDoc(template)),
      ];
      src.emit(docs);
      await Future<void>.delayed(Duration.zero);

      expect(repo.cached().length, 5000);
    });
  });
}
