// FINANCE FIRESTORE CACHE-PATTERN (S3.F) — unit coverage for the Firestore-
// backed finance repo [FirebaseFinanceRepository] (the persisted approval /
// penalty / payment-term lists) + the Firebase-free accessor/provider swap.
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages.
// One fake per persisted collection (approvals / penalties / payment-term), so
// we can assert the whole bridge (seed → snapshot replace → optimistic write →
// failure resilience) deterministically, exactly like the orders pilot test.
//
// Pins (the S3.F contract):
//   • each persisted list is BORN seeded from its existing local seed
//     (approvals = kApprovalQueue · penalties = empty · payment-term = 'net30');
//   • a snapshot REPLACES the relevant cache and is visible synchronously;
//   • an optimistic approval decision / penalty add is visible SYNCHRONOUSLY
//     and writes through (verbatim notifier semantics: status flip · PEN-####);
//   • a write FAILURE corrupts neither cache nor throws;
//   • setPaymentTerm upserts the single `active` doc;
//   • the budget DATA reads (total/spent/categories/pct/revenue) return
//     EMPTY/ZERO on the live backend — V1/P2: no fabricated demo money is shown
//     to a real signed-in user (the pure budgetLevel + static financeHub stay);
//   • the accessor + provider resolve to the LOCAL impl with no Firebase
//     (where the budget surface keeps its real local/seed values).

import 'dart:async';

import 'package:buildsmart/data/phaseb_seeds.dart'
    show kActivePaymentTerm, kApprovalQueue;
import 'package:buildsmart/data/repositories/finance_firebase.dart';
import 'package:buildsmart/data/repositories/finance_local.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource] — a broadcast stream we drive
/// manually + an in-memory record of writes (identical shape to the orders
/// pilot's fake).
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

  Future<void> close() => _controller.close();
}

/// Build a [FirebaseFinanceRepository] over three fakes, registering teardown.
/// Returns the repo + the three fakes for assertions. `ref` is null (the const
/// budget path needs none; the one revenue test passes its own container repo).
({
  FirebaseFinanceRepository repo,
  _FakeSource approvals,
  _FakeSource penalties,
  _FakeSource term,
  _FakeSource budget,
}) _build() {
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
  );
  addTearDown(approvals.close);
  addTearDown(penalties.close);
  addTearDown(term.close);
  addTearDown(budget.close);
  addTearDown(repo.dispose);
  return (
    repo: repo,
    approvals: approvals,
    penalties: penalties,
    term: term,
    budget: budget,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseFinanceRepository — persisted lists (seed · snapshot · write)',
      () {
    test('caches BORN seeded: approvals=kApprovalQueue · penalties empty · '
        'payment-term net30', () {
      final f = _build();
      // Approvals seeded from kApprovalQueue (ids + statuses verbatim).
      expect(
        f.repo.approvals().map((a) => a.id).toList(),
        kApprovalQueue.map((a) => a.id).toList(), // AP-201, AP-202
      );
      expect(f.repo.approvals().every((a) => a.status == 'ממתין'), isTrue);
      // Penalty ledger starts empty (identical to PenaltyLedgerNotifier).
      expect(f.repo.penalties(), isEmpty);
      // Active payment term = the seed default.
      expect(f.repo.activePaymentTerm(), kActivePaymentTerm); // 'net30'
    });

    test('a snapshot REPLACES the approvals cache (decode + visible sync)',
        () async {
      final f = _build();
      f.repo.attach();

      f.approvals.emit([
        const RemoteDoc('AP-201', {
          'what': 'הזמנת ברזל זיון',
          'amount': 8400,
          'by': 'מנהל עבודה',
          'status': 'אושר', // decided server-side
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(f.repo.approvals().length, 1);
      expect(f.repo.approvals().single.id, 'AP-201');
      expect(f.repo.approvals().single.status, 'אושר');
    });

    test('decide(): optimistic status flip visible SYNCHRONOUSLY + writes',
        () async {
      final f = _build();

      f.repo.decide('AP-201', true); // approve
      // Visible immediately (no await) — verbatim ApprovalQueueNotifier.decide.
      expect(
        f.repo.approvals().firstWhere((a) => a.id == 'AP-201').status,
        'אושר',
      );

      f.repo.decide('AP-202', false); // reject
      expect(
        f.repo.approvals().firstWhere((a) => a.id == 'AP-202').status,
        'נדחה',
      );

      await Future<void>.delayed(Duration.zero);
      // Both flips written through to the remote with the new status.
      final ap201 = f.approvals.sets.lastWhere((e) => e.key == 'AP-201').value;
      final ap202 = f.approvals.sets.lastWhere((e) => e.key == 'AP-202').value;
      expect(ap201['status'], 'אושר');
      expect(ap202['status'], 'נדחה');
    });

    test('decide(): unknown id is a no-op (no cache change, no write)',
        () async {
      final f = _build();
      final before = f.repo.approvals().map((a) => a.status).toList();
      f.repo.decide('NOPE', true);
      expect(f.repo.approvals().map((a) => a.status).toList(), before);
      await Future<void>.delayed(Duration.zero);
      expect(f.approvals.sets, isEmpty);
    });

    test('addPenalty(): PEN-#### id, days×₪500, newest-first, writes through',
        () async {
      final f = _build();

      final amt = f.repo.addPenalty(3);
      expect(amt, 1500); // 3 × kPenaltyPerDay(500)
      // First row: id PEN-301 (300 + length(0) + 1), visible immediately.
      expect(f.repo.penalties().first.id, 'PEN-301');
      expect(f.repo.penalties().first.days, 3);
      expect(f.repo.penalties().first.amount, 1500);

      // A second penalty unshifts to the FRONT (newest-first via sortBy).
      f.repo.addPenalty(2);
      expect(f.repo.penalties().first.id, 'PEN-302'); // newest first
      expect(
        f.repo.penalties().map((p) => p.id).toList(),
        ['PEN-302', 'PEN-301'],
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        f.penalties.sets.map((e) => e.key).toSet(),
        {'PEN-301', 'PEN-302'},
      );
    });

    test('addPenalty(): days clamped to >= 1 (proto floor)', () {
      final f = _build();
      final amt = f.repo.addPenalty(0); // clamped to 1
      expect(amt, 500);
      expect(f.repo.penalties().first.days, 1);
    });

    test('setPaymentTerm(): upserts the single `active` doc, visible sync',
        () async {
      final f = _build();

      f.repo.setPaymentTerm('net60');
      expect(f.repo.activePaymentTerm(), 'net60'); // immediate

      await Future<void>.delayed(Duration.zero);
      // Written to the single doc id `active` with field termId.
      final written =
          f.term.sets.lastWhere((e) => e.key == kActivePaymentTermDocId).value;
      expect(written['termId'], 'net60');
    });

    test('a write FAILURE corrupts neither cache nor throws (approval decide)',
        () async {
      final f = _build();
      f.approvals.failNextSet = true;

      f.repo.decide('AP-201', true);
      // Optimistic cache intact despite the background set throwing.
      expect(
        f.repo.approvals().firstWhere((a) => a.id == 'AP-201').status,
        'אושר',
      );
      await Future<void>.delayed(Duration.zero);
      // The failing set was swallowed (not recorded) and nothing threw.
      expect(f.approvals.sets, isEmpty);
      expect(
        f.repo.approvals().firstWhere((a) => a.id == 'AP-201').status,
        'אושר',
      );
    });

    test('budget DATA reads are EMPTY/ZERO on the backend (no fabricated money)',
        () async {
      // V1/P2: on the live Firebase backend there is no real accounting source,
      // so the const demo figures (15000/9840/categories/66) must NOT be shown
      // to a real signed-in user as if they were theirs — they return 0/empty.
      final f = _build();
      expect(f.repo.budgetTotal(), 0);
      expect(f.repo.budgetSpent(), 0);
      expect(f.repo.budgetPct(), 0);
      expect(f.repo.budgetCategories(), isEmpty);
      expect(f.repo.activeRevenue(), 0);
      // KEPT: the pure budgetLevel band function + the static financeHub section
      // list (UI scaffolding, not fabricated data) still resolve.
      expect(f.repo.budgetLevel(100).label, isNotEmpty);
      expect(f.repo.financeHub(), isNotEmpty);

      // None of these reads pushed anything to ANY persisted collection.
      await Future<void>.delayed(Duration.zero);
      expect(f.approvals.sets, isEmpty);
      expect(f.penalties.sets, isEmpty);
      expect(f.term.sets, isEmpty);
    });
  });

  group('finance accessor/provider — Firebase-free path', () {
    test('financeRepo() resolves to the const LOCAL impl (no Firebase)', () {
      // The whole suite runs without Firebase.initializeApp → Firebase.apps is
      // empty → the accessor must return the in-memory local repo (never touch
      // Firestore). This is what keeps every finance-hub sheet Firebase-free.
      final repo = financeRepo();
      expect(repo, isA<LocalFinanceRepository>());
      expect(repo.budgetTotal(), 15000); // const surface behaves
    });

    test('financeRepositoryProvider resolves to LOCAL + activeRevenue works',
        () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final repo = c.read(financeRepositoryProvider);
      expect(repo, isA<LocalFinanceRepository>());
      // The Ref-bearing local impl resolves activeRevenue against the engine
      // (Σ sum of open seed orders) — a non-negative live figure.
      expect(repo.activeRevenue(), greaterThanOrEqualTo(0));
    });
  });
}
