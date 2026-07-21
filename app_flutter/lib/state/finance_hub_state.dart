// 📊 מרכז פיננסים — runtime state for the finance-hub feature track (T1).
//
// Mutable runtime state that STARTS from the B0 const seeds in
// `data/phaseb_seeds.dart` (the genesis values) — exactly as the proto's
// module-scoped `let activePaymentTerm` / `approvalQueue` / `penaltyLedger`
// vars start from their seed literals. The seeds themselves are NOT
// re-declared here (R6/R8 — single source of truth).
//
// Three pieces of live state + a faithful RBAC/audit port (T1.4):
//   • [activePaymentTermProvider] — the selected תנאי תשלום (T1.2 `setPaymentTerm`).
//   • [approvalQueueProvider]     — purchase-approval decisions (T1.4 `decideApproval`).
//   • [penaltyLedgerProvider]     — the late-penalty ledger (T1.8 `addPenalty`).
//   • [securityRoleProvider] + [requirePerm] + [auditTrailProvider] — the RBAC
//     gate the approve/reject action runs through (proto §82/§84).

import 'package:buildsmart/data/contractor_seeds.dart' show caToday;
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/data/repositories/finance_local.dart' show financeRepo;
import 'package:buildsmart/data/repositories/finance_repository.dart'
    show FinanceRepository;
import 'package:flutter/foundation.dart' show Listenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// T1.2 — active payment term. Seed `kActivePaymentTerm` (== 'net30', proto 19467).
// ─────────────────────────────────────────────────────────────────────────────
final activePaymentTermProvider =
    StateProvider<String>((ref) => kActivePaymentTerm);

// ─────────────────────────────────────────────────────────────────────────────
// T1.4 — the purchase-approval queue. A mutable copy of the [kApprovalQueue]
// seed (status starts 'ממתין'); `decide` flips a row to 'אושר' / 'נדחה'.
// proto `decideApproval` @index.html:19617.
// ─────────────────────────────────────────────────────────────────────────────

/// A live approval row — the [ApprovalItem] seed fields with a MUTABLE status.
class FinanceApproval {
  const FinanceApproval({
    required this.id,
    required this.what,
    required this.amount,
    required this.by,
    required this.status,
  });

  final String id;
  final String what;
  final int amount;
  final String by;
  final String status; // 'ממתין' | 'אושר' | 'נדחה'

  FinanceApproval copyWith({String? status}) => FinanceApproval(
        id: id,
        what: what,
        amount: amount,
        by: by,
        status: status ?? this.status,
      );
}

class ApprovalQueueNotifier extends StateNotifier<List<FinanceApproval>> {
  /// Optional-repo constructor. With a [repo] the queue SEEDS from — and RE-SEEDS
  /// on — the repo's persisted approvals (so on the connected build the manager
  /// sees the REAL Firestore list, not the demo seed); `decide` is mirrored to
  /// the repo. With NO repo (the no-arg default/test path) it falls back to the
  /// const `kApprovalQueue` seed — byte-identical to before this wiring. Mirrors
  /// the `BudgetNotifier(financeRepo())` seed+listen pattern.
  ApprovalQueueNotifier([FinanceRepository? repo])
      : _repo = repo,
        super(repo?.approvals() ??
            [
              for (final a in kApprovalQueue)
                FinanceApproval(
                  id: a.id,
                  what: a.what,
                  amount: a.amount,
                  by: a.by,
                  status: a.status,
                ),
            ]) {
    final l = repo?.approvalsListenable;
    if (l != null) _listenable = l..addListener(_syncFromRepo);
  }

  final FinanceRepository? _repo;
  Listenable? _listenable;

  /// Re-seed from the repo when its persisted approvals change (a snapshot
  /// arrived / our own optimistic write landed). No-op once disposed.
  void _syncFromRepo() {
    if (!mounted) return;
    final r = _repo;
    if (r != null) state = r.approvals();
  }

  /// Set a request's decision — `ok` → 'אושר', else 'נדחה' (proto 19622).
  /// Flips the local state optimistically AND persists to the repo (Firebase
  /// writes to Firestore; the const-local impl is a no-op).
  void decide(String id, bool ok) {
    state = [
      for (final a in state)
        a.id == id ? a.copyWith(status: ok ? 'אושר' : 'נדחה') : a,
    ];
    _repo?.decide(id, ok);
  }

  @override
  void dispose() {
    _listenable?.removeListener(_syncFromRepo);
    super.dispose();
  }
}

final approvalQueueProvider =
    StateNotifierProvider<ApprovalQueueNotifier, List<FinanceApproval>>(
        (ref) => ApprovalQueueNotifier(financeRepo()));

// ─────────────────────────────────────────────────────────────────────────────
// T1.8 — the late-penalty ledger. Empty at start (proto `let penaltyLedger=[]`);
// `add(days)` unshifts a PEN-row of `days × ₪500`. proto `addPenalty` @19717.
// ─────────────────────────────────────────────────────────────────────────────

/// One late-penalty ledger row. proto `addPenalty` object @index.html:19722.
class Penalty {
  const Penalty({
    required this.id,
    required this.days,
    required this.perDay,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final int days;
  final int perDay;
  final int amount;
  final String createdAt;
}

/// The fixed per-day late penalty (proto `const perDay=500` @index.html:19721).
const int kPenaltyPerDay = 500;

class PenaltyLedgerNotifier extends StateNotifier<List<Penalty>> {
  PenaltyLedgerNotifier() : super(const []);

  /// Record a late penalty for `days` (clamped to ≥1, proto 19720). Returns the
  /// new row's amount (`days × kPenaltyPerDay`) for the toast.
  int add(int days, {DateTime? now}) {
    final d = days < 1 ? 1 : days;
    final row = Penalty(
      // proto: 'PEN-'+(300+penaltyLedger.length+1) @index.html:19722.
      id: 'PEN-${300 + state.length + 1}',
      days: d,
      perDay: kPenaltyPerDay,
      amount: d * kPenaltyPerDay,
      createdAt: caToday(now),
    );
    state = [row, ...state]; // unshift
    return row.amount;
  }
}

final penaltyLedgerProvider =
    StateNotifierProvider<PenaltyLedgerNotifier, List<Penalty>>(
        (ref) => PenaltyLedgerNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// RBAC + audit — faithful port of proto §82 (`RBAC_MATRIX`/`can`/`requirePerm`)
// and §84 (`auditLog`). The finance hub is the manager's tool, so the role
// defaults to 'manager' (which grants 'order.approve'); a denied action audits
// the denial and returns false, exactly as `requirePerm` does (proto 19619).
// ─────────────────────────────────────────────────────────────────────────────

/// The permission matrix — VERBATIM from proto `RBAC_MATRIX` @index.html:21675.
const Map<String, List<String>> kRbacMatrix = {
  'contractor': [
    'order.create',
    'order.view',
    'catalog.view',
    'budget.view',
    'budget.edit',
    'tasks.view',
    'rewards.use',
  ],
  'manager': [
    'order.view',
    'order.approve',
    'catalog.view',
    'catalog.edit',
    'budget.view',
    'budget.edit',
    'users.manage',
    'reports.view',
    'tasks.view',
    'tasks.assign',
  ],
  'store': ['order.view', 'order.fulfill', 'stock.edit', 'catalog.view'],
  'courier': ['delivery.view', 'delivery.advance', 'delivery.pod'],
  'worker': ['tasks.view', 'tasks.complete'],
};

/// The active security role. Defaults to 'manager' (proto default is
/// 'contractor', but the finance hub is reached as a manager tool — the role
/// that holds 'order.approve'). proto `currentSecurityRole` @index.html:21685.
final securityRoleProvider = StateProvider<String>((ref) => 'manager');

/// One audit-trail entry — proto `auditLog` object @index.html:21705.
class AuditEntry {
  const AuditEntry({
    required this.action,
    required this.detail,
    required this.role,
    required this.time,
  });

  final String action;
  final String detail;
  final String role;
  final String time;
}

class AuditTrailNotifier extends StateNotifier<List<AuditEntry>> {
  AuditTrailNotifier() : super(const []);

  /// Prepend an audit entry (newest first), capped at 200 (proto 21711).
  void log(String action, String detail, String role, {DateTime? now}) {
    final entry = AuditEntry(
      action: action,
      detail: detail,
      role: role,
      time: (now ?? DateTime.now()).toIso8601String(),
    );
    final next = [entry, ...state];
    state = next.length > 200 ? next.sublist(0, 200) : next;
  }
}

final auditTrailProvider =
    StateNotifierProvider<AuditTrailNotifier, List<AuditEntry>>(
        (ref) => AuditTrailNotifier());

/// Whether the active role holds [perm]. proto `can` @index.html:21689.
bool canDo(WidgetRef ref, String perm) {
  final role = ref.read(securityRoleProvider);
  return (kRbacMatrix[role] ?? const []).contains(perm);
}

/// Enforce a permission before an action — logs every denial to the audit trail
/// and returns false if denied. proto `requirePerm` @index.html:21695.
bool requirePerm(WidgetRef ref, String perm, String label) {
  if (canDo(ref, perm)) return true;
  final role = ref.read(securityRoleProvider);
  ref.read(auditTrailProvider.notifier).log('הרשאה נדחתה', label, role);
  return false;
}
