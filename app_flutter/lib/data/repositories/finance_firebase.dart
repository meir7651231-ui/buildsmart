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
  })  : _derived = ref == null
            ? const LocalFinanceRepository.constData()
            : LocalFinanceRepository(ref),
        _approvals = _ApprovalsCacheRepo(source: approvalsSource),
        _penalties = _PenaltiesCacheRepo(source: penaltiesSource),
        _paymentTerm = _PaymentTermCacheRepo(source: paymentTermSource);

  /// Delegate for the const budget reads + `activeRevenue` — the EXACT same
  /// values the local impl serves (forwarded to the const helpers / the live
  /// orders engine). These are DERIVED and never pushed to Firestore.
  final LocalFinanceRepository _derived;

  final _ApprovalsCacheRepo _approvals;
  final _PenaltiesCacheRepo _penalties;
  final _PaymentTermCacheRepo _paymentTerm;

  // ── lifecycle (fan out to the three sub-repos) ──────────────────────────────

  /// Subscribe all three persisted sub-repos to their `snapshots()`. Called by
  /// the provider after construction (mirrors `FirebaseOrdersRepository.attach`).
  void attach() {
    _approvals.attach();
    _penalties.attach();
    _paymentTerm.attach();
  }

  /// Cancel all three subscriptions. Called by `ref.onDispose`.
  void dispose() {
    _approvals.dispose();
    _penalties.dispose();
    _paymentTerm.dispose();
  }

  // ── budget DATA reads (no real source yet → EMPTY/ZERO on the live backend) ──
  // On the live Firebase backend there is NO real accounting source for the
  // project budget, so the const demo figures (15000/9840/categories/pct/
  // revenue) MUST NOT be shown to a real signed-in user as if they were theirs.
  // These run ONLY when the backend is ON (the provider routes here only when
  // `useFirebaseBackend` is true), so returning empty/zero unconditionally is
  // correct — a real user sees an honest empty state, not invented money.
  // KEEP `budgetLevel` (a PURE band function — no fabricated data) and
  // `financeHub` (STATIC UI scaffolding — the menu's section list, not data).

  @override
  int budgetTotal() => 0;

  @override
  int budgetSpent() => 0;

  @override
  List<BudgetCategory> budgetCategories() => const [];

  @override
  int budgetPct() => 0;

  @override
  ({String label, String cls}) budgetLevel(int pct) =>
      _derived.budgetLevel(pct);

  @override
  List<Section> financeHub() => _derived.financeHub();

  @override
  int activeRevenue() => 0;

  // ── PERSISTED lists (extra concrete members — the seed() precedent) ─────────

  /// The live purchase-approval queue (synchronous, from the cache).
  List<FinanceApproval> approvals() => _approvals.cached();

  /// The live late-penalty ledger (synchronous, from the cache, newest-first).
  List<Penalty> penalties() => _penalties.cached();

  /// The active payment-term id (synchronous, from the cache).
  String activePaymentTerm() => _paymentTerm.activeTerm();

  // ── PERSISTED writes (verbatim notifier ports · optimistic + guarded) ───────

  /// Set request [id]'s decision — `ok` → 'אושר', else 'נדחה'. Verbatim port of
  /// `ApprovalQueueNotifier.decide` (proto `decideApproval` @19622) over the
  /// cache: replace-by-id with the new status, no-op on an unknown id.
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
