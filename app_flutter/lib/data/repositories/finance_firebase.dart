// ─────────────────────────────────────────────────────────────────────────────
// FirebaseFinanceRepository — the S3.F Firestore-backed implementation of
// [FinanceRepository], built on the offline-first cache base
// ([FirestoreCachedRepo]). It is a DROP-IN for [LocalFinanceRepository]: the
// `financeRepo()` accessor + `financeRepositoryProvider` + UI are unchanged —
// only which class they return changes (see the swap in `finance_local.dart`).
//
// ── WHAT THIS REPO PERSISTS vs WHAT STAYS DERIVED (the S3.F contract) ─────────
// The SSOT (`SPEC-server-connect-MICRO` row S3.F) is explicit: finance persists
// ONLY the three pieces of live runtime state — everything else is DERIVED
// client-side and must NEVER be pushed to Firestore (it would cost reads on data
// that never changes server-side and duplicate the const seeds):
//   • `financeApprovals`         — the purchase-approval queue (status decisions);
//   • `financePenalties`         — the late-penalty ledger;
//   • `financePaymentTerms/active` — the single selected payment-term id.
// The const budget reads (`budgetTotal`/`budgetSpent`/`budgetCategories`/
// `budgetPct`/`budgetLevel`/`financeHub`) and `activeRevenue` (Σ open orders)
// stay computed EXACTLY as the local impl — they are forwarded to the same
// top-level const helpers / the live orders engine, NOT read from Firestore.
//
// ── WHY THE PERSISTED LISTS ARE EXTRA CONCRETE MEMBERS (the seed() precedent) ─
// [FinanceRepository] is a READ-ONLY/DERIVED interface — it has no method for the
// approval/penalty/payment-term state (those are mutated through the
// finance-hub StateNotifiers today). So, exactly like [LocalOrdersRepository]
// exposes `seed()` as an extra concrete member beyond its abstract interface,
// this repo exposes the persisted lists + their write ports as EXTRA concrete
// members (`approvals`/`penalties`/`activePaymentTerm` + `decide`/`addPenalty`/
// `setPaymentTerm`). The abstract `FinanceRepository` surface is untouched, so
// the drop-in is preserved. (Re-pointing the finance-hub sheets — which still
// `ref.read(approvalQueueProvider.notifier)` directly — at these ports is a
// FOLLOW-UP, deliberately NOT done here; the StateNotifiers remain the live path
// for the UI until that re-wiring lands. See `/tmp/wiring-s3-finance.md`.)
//
// ── HOW THE BRIDGE IS HELD (three composed cached sub-repos) ──────────────────
// Each persisted list is its own `FirestoreCachedRepo<T>` over its own
// collection (a single-doc collection for the payment term). This repo COMPOSES
// the three and fans `attach()`/`dispose()` out to all of them, so the providers
// wire it exactly like the orders pilot. Reads are SYNCHRONOUS (served from each
// sub-repo's in-memory cache, seeded from the existing local seeds); writes are
// VERBATIM PORTS of the finance-hub notifiers (`ApprovalQueueNotifier.decide` /
// `PenaltyLedgerNotifier.add` / the `activePaymentTermProvider` state set) via
// an optimistic upsert + guarded background Firestore write (a failure is
// logged, never thrown).
//
// Comment density/voice mirrors `orders_firebase.dart` — the S3 sibling template.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/contractor_seeds.dart'
    show BudgetCategory, caToday;
import 'package:buildsmart/data/phaseb_seeds.dart'
    show kActivePaymentTerm, kApprovalQueue;
import 'package:buildsmart/data/repositories/finance_local.dart'
    show LocalFinanceRepository;
import 'package:buildsmart/data/repositories/finance_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/state/finance_hub_state.dart'
    show FinanceApproval, Penalty, kPenaltyPerDay;
import 'package:flutter/foundation.dart' show Listenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// `financeApprovals` — the purchase-approval queue. doc-id = approval id (e.g.
// `AP-201`). Seed = the [kApprovalQueue] genesis (status starts 'ממתין'),
// identical to `ApprovalQueueNotifier`'s initial state. The write port `decide`
// is a verbatim port of `ApprovalQueueNotifier.decide`.
// ─────────────────────────────────────────────────────────────────────────────
class _ApprovalsCacheRepo extends FirestoreCachedRepo<FinanceApproval> {
  _ApprovalsCacheRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('financeApprovals'));

  /// The cache is born with the two seed requests (lifted from [kApprovalQueue]
  /// — the single seed source of truth) so the queue is non-empty before the
  /// first snapshot, identical genesis to `ApprovalQueueNotifier`.
  @override
  List<FinanceApproval> get seed => [
        for (final a in kApprovalQueue)
          FinanceApproval(
            id: a.id,
            what: a.what,
            amount: a.amount,
            by: a.by,
            status: a.status,
          ),
      ];

  @override
  String idOf(FinanceApproval value) => value.id;

  @override
  Map<String, dynamic> toDoc(FinanceApproval a) => {
        'what': a.what,
        'amount': a.amount,
        'by': a.by,
        'status': a.status,
      };

  /// Firestore doc → [FinanceApproval]. The doc-id becomes `id`. THROWS on a
  /// structurally-bad doc (missing required field) — the base catches that
  /// per-doc and skips it (never blanks the queue).
  @override
  FinanceApproval fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return FinanceApproval(
      id: doc.id,
      what: j['what'] as String,
      amount: (j['amount'] as num).toInt(),
      by: j['by'] as String,
      status: j['status'] as String,
    );
  }

  /// Fresh backend (first snapshot empty) → seed the remote from the local seed
  /// the cache was born with, so the two seed requests exist server-side.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();
}

// ─────────────────────────────────────────────────────────────────────────────
// `financePenalties` — the late-penalty ledger. doc-id = penalty id (e.g.
// `PEN-301`). Seed = empty (proto `let penaltyLedger=[]`), identical to
// `PenaltyLedgerNotifier`'s initial state. The write port `addPenalty` is a
// verbatim port of `PenaltyLedgerNotifier.add` (newest-first unshift).
// ─────────────────────────────────────────────────────────────────────────────
class _PenaltiesCacheRepo extends FirestoreCachedRepo<Penalty> {
  _PenaltiesCacheRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('financePenalties'));

  /// The ledger starts EMPTY — identical genesis to `PenaltyLedgerNotifier`
  /// (`super(const [])`). A first empty snapshot is therefore the natural state;
  /// the base's default no-op `onFirstSnapshotEmpty` is correct (nothing to push).
  @override
  List<Penalty> get seed => const [];

  @override
  String idOf(Penalty value) => value.id;

  @override
  Map<String, dynamic> toDoc(Penalty p) => {
        'days': p.days,
        'perDay': p.perDay,
        'amount': p.amount,
        'createdAt': p.createdAt,
      };

  @override
  Penalty fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return Penalty(
      id: doc.id,
      days: (j['days'] as num).toInt(),
      perDay: (j['perDay'] as num).toInt(),
      amount: (j['amount'] as num).toInt(),
      createdAt: j['createdAt'] as String,
    );
  }

  /// Restore the notifier's newest-first ordering. Firestore returns documents
  /// in doc-id order; `PenaltyLedgerNotifier.add` UNSHIFTS (newest first), and
  /// ids are `PEN-${300+n}` — so sorting by the numeric id descending reproduces
  /// the unshift order exactly (a higher PEN-#### is newer → comes first).
  @override
  List<Penalty> sortBy(List<Penalty> items) {
    int n(Penalty p) => int.tryParse(p.id.replaceFirst('PEN-', '')) ?? 0;
    return List<Penalty>.of(items)..sort((a, b) => n(b).compareTo(n(a)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// `financePaymentTerms/active` — the single selected payment-term id. Modelled
// as a SINGLE-DOC collection: the one doc has id `active` and field `{termId}`.
// Seed = [kActivePaymentTerm] ('net30'), identical to `activePaymentTermProvider`'s
// initial value. The write port `setPaymentTerm` upserts the `active` doc.
//
// The model [T] is a tiny ({id, termId}) record so the generic `List<T>` cache
// holds the one row; `activeTerm` reads its `termId` (falling back to the seed
// if the cache is somehow empty — defensive, the seed guarantees one row).
// ─────────────────────────────────────────────────────────────────────────────
typedef _PaymentTermRow = ({String id, String termId});

/// The fixed doc-id for the single active-payment-term document.
const String kActivePaymentTermDocId = 'active';

class _PaymentTermCacheRepo extends FirestoreCachedRepo<_PaymentTermRow> {
  _PaymentTermCacheRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('financePaymentTerms'));

  /// One row, born from [kActivePaymentTerm] ('net30') — identical genesis to
  /// `activePaymentTermProvider`. So the active term is non-empty before the
  /// first snapshot and a fresh backend gets seeded with the default.
  @override
  List<_PaymentTermRow> get seed =>
      const [(id: kActivePaymentTermDocId, termId: kActivePaymentTerm)];

  @override
  String idOf(_PaymentTermRow value) => value.id;

  @override
  Map<String, dynamic> toDoc(_PaymentTermRow v) => {'termId': v.termId};

  @override
  _PaymentTermRow fromDoc(RemoteDoc doc) =>
      (id: doc.id, termId: doc.data['termId'] as String);

  /// Fresh backend → seed the remote with the default active term.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();

  /// The active payment-term id — the `active` row's `termId`, or the seed
  /// default if the cache is empty (defensive; the seed guarantees one row).
  String activeTerm() {
    for (final r in cached()) {
      if (r.id == kActivePaymentTermDocId) return r.termId;
    }
    return kActivePaymentTerm;
  }

  /// Set the active payment-term id — optimistic upsert of the `active` row +
  /// guarded background write. Verbatim semantics of the
  /// `activePaymentTermProvider.notifier.state = id` assignment the sheet does.
  void setTerm(String termId) =>
      upsert((id: kActivePaymentTermDocId, termId: termId));
}

// ─────────────────────────────────────────────────────────────────────────────
// `financeBudget` — the editable project budget, persisted as ONE document
// (`active`) holding total + spent + the category list. Same single-doc shape as
// `_PaymentTermCacheRepo`. The seed is EMPTY (0/0/[]) — NOT the const demo: a real
// signed-in user starts from an honest blank budget (matching the budget box's
// honest-empty reads), never fabricated demo money. `onFirstSnapshotEmpty` is the
// base no-op, so a fresh backend is NEVER seeded with figures.
// ─────────────────────────────────────────────────────────────────────────────
typedef _BudgetRow = ({
  String id,
  int total,
  int spent,
  List<BudgetCategory> categories,
});

/// The fixed doc-id for the single budget document.
const String kBudgetDocId = 'active';

class _BudgetCacheRepo extends FirestoreCachedRepo<_BudgetRow> {
  _BudgetCacheRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('financeBudget'));

  /// EMPTY genesis — an honest blank budget before the first snapshot. The base
  /// `onFirstSnapshotEmpty` no-op means a fresh backend is NOT seeded with money.
  @override
  List<_BudgetRow> get seed =>
      const [(id: kBudgetDocId, total: 0, spent: 0, categories: <BudgetCategory>[])];

  @override
  String idOf(_BudgetRow value) => value.id;

  @override
  Map<String, dynamic> toDoc(_BudgetRow v) => {
        'total': v.total,
        'spent': v.spent,
        'cats': [
          for (final c in v.categories)
            {'name': c.name, 'icon': c.icon, 'amount': c.amount},
        ],
      };

  @override
  _BudgetRow fromDoc(RemoteDoc doc) => (
        id: doc.id,
        total: (doc.data['total'] as num?)?.toInt() ?? 0,
        spent: (doc.data['spent'] as num?)?.toInt() ?? 0,
        categories: [
          for (final c in (doc.data['cats'] as List<dynamic>? ?? const []))
            if (c is Map)
              BudgetCategory(
                (c['name'] as String?) ?? '',
                (c['icon'] as String?) ?? '📦',
                (c['amount'] as num?)?.toInt() ?? 0,
              ),
        ],
      );

  /// The active budget row, or the empty default if the cache is somehow empty
  /// (defensive — the seed guarantees one row).
  _BudgetRow active() {
    for (final r in cached()) {
      if (r.id == kBudgetDocId) return r;
    }
    return const (
      id: kBudgetDocId,
      total: 0,
      spent: 0,
      categories: <BudgetCategory>[],
    );
  }

  /// Persist the WHOLE budget — optimistic upsert of the single `active` row +
  /// guarded background write.
  void setBudget(int total, int spent, List<BudgetCategory> categories) => upsert(
        (id: kBudgetDocId, total: total, spent: spent, categories: categories),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseFinanceRepository — composes the three persisted sub-repos for the
// LIVE state, and forwards the const budget reads + `activeRevenue` to the same
// backing the local impl uses (NEVER pushing derived values to Firestore).
//
// It is NOT a `FirestoreCachedRepo` itself (it persists three independent
// lists, not one), so it holds the three sub-repos and fans `attach()`/
// `dispose()` out to them — the provider wires it exactly like the orders pilot.
// The const reads are delegated to an internal [LocalFinanceRepository] (Ref-
// bearing when the provider supplies a Ref) so every byte-identical budget value
// + `activeRevenue` stays exactly as local.
// ─────────────────────────────────────────────────────────────────────────────
class FirebaseFinanceRepository implements FinanceRepository {
  /// Constructs the repo over the three finance collections. The real Firestore
  /// instance is resolved LAZILY by each [FirestoreCollectionSource] (never
  /// here), so construction does not require Firebase to be initialised. Pass
  /// the [Ref] so the delegated [activeRevenue] can reach the live orders engine
  /// (null in tests that don't exercise revenue). The three `*Source` params let
  /// tests drive each sub-repo's cache with a fake.
  FirebaseFinanceRepository(
    Ref? ref, {
    RemoteCollectionSource? approvalsSource,
    RemoteCollectionSource? penaltiesSource,
    RemoteCollectionSource? paymentTermSource,
    RemoteCollectionSource? budgetSource,
  })  : _derived = ref == null
            ? const LocalFinanceRepository.constData()
            : LocalFinanceRepository(ref),
        _approvals = _ApprovalsCacheRepo(source: approvalsSource),
        _penalties = _PenaltiesCacheRepo(source: penaltiesSource),
        _paymentTerm = _PaymentTermCacheRepo(source: paymentTermSource),
        _budget = _BudgetCacheRepo(source: budgetSource);

  /// Delegate for the const budget reads + `activeRevenue` — the EXACT same
  /// values the local impl serves (forwarded to the const helpers / the live
  /// orders engine). These are DERIVED and never pushed to Firestore.
  final LocalFinanceRepository _derived;

  final _ApprovalsCacheRepo _approvals;
  final _PenaltiesCacheRepo _penalties;
  final _PaymentTermCacheRepo _paymentTerm;
  final _BudgetCacheRepo _budget;

  // ── lifecycle (fan out to the four sub-repos) ───────────────────────────────

  /// Subscribe all four persisted sub-repos to their `snapshots()`. Called by
  /// the provider after construction (mirrors `FirebaseOrdersRepository.attach`).
  void attach() {
    _approvals.attach();
    _penalties.attach();
    _paymentTerm.attach();
    _budget.attach();
  }

  /// Cancel all four subscriptions. Called by `ref.onDispose`.
  void dispose() {
    _approvals.dispose();
    _penalties.dispose();
    _paymentTerm.dispose();
    _budget.dispose();
  }

  // ── budget DATA reads (now backed by the persisted `_budget` sub-repo) ───────
  // The editable project budget is persisted in the single `financeBudget/active`
  // doc. Its genesis is EMPTY (0/0/[]) and `onFirstSnapshotEmpty` is the base
  // no-op, so a real signed-in user still sees an HONEST blank budget until THEY
  // set one — never fabricated demo money — but once set it round-trips through
  // the cache. (`budgetLevel` stays a pure band fn; `financeHub` is static UI
  // scaffolding; `activeRevenue` has no real accounting source → 0.)

  @override
  int budgetTotal() => _budget.active().total;

  @override
  int budgetSpent() => _budget.active().spent;

  @override
  List<BudgetCategory> budgetCategories() => _budget.active().categories;

  @override
  int budgetPct() {
    final r = _budget.active();
    return r.total > 0 ? (r.spent / r.total * 100).round() : 0;
  }

  @override
  ({String label, String cls}) budgetLevel(int pct) =>
      _derived.budgetLevel(pct);

  @override
  List<Section> financeHub() => _derived.financeHub();

  @override
  int activeRevenue() => 0;

  // ── budget WRITE + change stream (server-connect persistence) ───────────────

  @override
  void setBudget(int total, int spent, List<BudgetCategory> categories) =>
      _budget.setBudget(total, spent, categories);

  /// The budget sub-repo IS a [ChangeNotifier] (fires on every snapshot + our own
  /// optimistic write), so the budget editor re-seeds from the live reads when it
  /// changes — that's how a persisted budget shows up after the snapshot lands.
  @override
  Listenable? get budgetListenable => _budget;

  // ── PERSISTED lists (extra concrete members — the seed() precedent) ─────────

  /// The live purchase-approval queue (synchronous, from the cache).
  @override
  List<FinanceApproval> approvals() => _approvals.cached();

  /// The approvals cache IS a [ChangeNotifier] (fires on every snapshot + our own
  /// optimistic write) — mirrors [budgetListenable] so the approval-queue notifier
  /// re-seeds when the persisted list changes.
  @override
  Listenable? get approvalsListenable => _approvals;

  /// The live late-penalty ledger (synchronous, from the cache, newest-first).
  List<Penalty> penalties() => _penalties.cached();

  /// The active payment-term id (synchronous, from the cache).
  String activePaymentTerm() => _paymentTerm.activeTerm();

  // ── PERSISTED writes (verbatim notifier ports · optimistic + guarded) ───────

  /// Set request [id]'s decision — `ok` → 'אושר', else 'נדחה'. Verbatim port of
  /// `ApprovalQueueNotifier.decide` (proto `decideApproval` @19622) over the
  /// cache: replace-by-id with the new status, no-op on an unknown id.
  @override
  void decide(String id, bool ok) {
    FinanceApproval? found;
    for (final a in _approvals.cached()) {
      if (a.id == id) {
        found = a;
        break;
      }
    }
    if (found == null) return;
    _approvals.upsert(found.copyWith(status: ok ? 'אושר' : 'נדחה'));
  }

  /// Record a late penalty for [days] (clamped to ≥1) and return the new row's
  /// amount (`days × kPenaltyPerDay`) for the toast. Verbatim port of
  /// `PenaltyLedgerNotifier.add` (proto `addPenalty` @19717): id is
  /// `PEN-${300+ledgerLength+1}`, unshifted newest-first (the sub-repo's `sortBy`
  /// keeps the highest PEN-#### in front).
  int addPenalty(int days, {DateTime? now}) {
    final d = days < 1 ? 1 : days;
    final row = Penalty(
      id: 'PEN-${300 + _penalties.cached().length + 1}',
      days: d,
      perDay: kPenaltyPerDay,
      amount: d * kPenaltyPerDay,
      createdAt: caToday(now),
    );
    _penalties.upsert(row); // optimistic prepend (sortBy keeps newest-first)
    return row.amount;
  }

  /// Set the active payment-term id — verbatim semantics of the
  /// `activePaymentTermProvider.notifier.state = id` assignment the sheet does
  /// (T1.2 `setPaymentTerm`), as an optimistic single-doc upsert.
  void setPaymentTerm(String termId) => _paymentTerm.setTerm(termId);
}
