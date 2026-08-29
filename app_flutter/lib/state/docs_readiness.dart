// #101 · שער-מוכנות מסמכים (HARD gate) — the PURE readiness rule + providers
// that decide whether the worker board (and the courier board) may open.
//
// PRODUCT DECISION (prior): this is a HARD gate for the worker AND the courier
// — the board does NOT open until the logged user's documents are complete and
// in-date. The gate UI lives in `screens/docs_readiness_gate.dart`; the
// insertion points are the worker/courier board builds.
//
// HONESTY: the REQUIRED-SET below is a DEMO product rule, marked SERVER-SWAP —
// the employer defines the real required document set server-side. Nothing here
// invents data: readiness is computed only from the user's REAL forms/certs.

import 'package:buildsmart/state/board_auth.dart' show boardAuthProvider;
import 'package:buildsmart/state/courier_hr.dart'
    show courierCertsProvider, kCourierCertPresets;
import 'package:buildsmart/state/required_docs_policy.dart'
    show normalizeDocName, requiredDocsForEmployer;
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The outcome of a documents-readiness check for one user.
///
/// [ready] is the HARD gate decision (false ⇒ the board is blocked). [missing]
/// lists blocking gaps in Hebrew (an unsigned/absent 101, an EXPIRED cert) and
/// [expiring] carries non-blocking WARNINGS (a cert expiring soon) so the gate
/// can surface them honestly without blocking on them.
class DocsReadiness {
  const DocsReadiness({
    required this.ready,
    this.missing = const [],
    this.expiring = const [],
  });

  /// True ⇒ the board may open. False ⇒ blocked (see [missing]).
  final bool ready;

  /// Blocking gaps, each a ready-to-show Hebrew line (e.g.
  /// 'טופס 101 חתום לשנת 2026', 'תעודה פגה: רישיון נהיגה').
  final List<String> missing;

  /// Non-blocking warnings — certificates expiring soon (e.g.
  /// 'תעודה פגה: …' is blocking and lives in [missing]; here is the soft
  /// 'תעודה תפוג בקרוב: …').
  final List<String> expiring;
}

/// PURE — the WORKER readiness rule (no Ref / no I/O, unit-tested directly).
///
/// REQUIRED-SET (⚠️ DEMO / SERVER-SWAP product rule — the employer will define
/// the real required document set server-side; this is the on-device stand-in):
/// the worker is `ready` ⟺
///   • a [Form101] for `now.year` EXISTS, its [Form101.signature] is non-empty,
///     and [Form101.declared] is true (a signed, declared current-year 101); AND
///   • NONE of this user's certificates is [CertExpiryStatus.expired].
/// A cert that is [CertExpiryStatus.expiringSoon] is a WARNING only — it is
/// added to [DocsReadiness.expiring] and does NOT block. [DocsReadiness.missing]
/// is populated honestly from the real state.
///
/// [requiredCertNames] is an ADD-ON layer (default `const []` ⇒ today's
/// behavior EXACTLY = back-compat): the CONTRACTOR's employer-scoped
/// required-docs policy (`required_docs_policy.dart`). For EACH required name,
/// the worker must hold a present, VALID (not expired) cert whose name matches
/// by [normalizeDocName] (NORMALIZED-EXACT — never substring); an unmet
/// requirement adds a `חסרה תעודה נדרשת: <name>` blocking line.
DocsReadiness workerDocsReadiness({
  required String username,
  required WorkerFormsState forms,
  required List<WorkerCert> certs,
  required DateTime now,
  List<String> requiredCertNames = const [],
}) {
  final missing = <String>[];
  final expiring = <String>[];

  // 1) Signed + declared 101 for the current tax year.
  final form = forms.form101For(username, now.year);
  final hasSigned101 =
      form != null && form.signature.isNotEmpty && form.declared;
  if (!hasSigned101) {
    missing.add('טופס 101 חתום לשנת ${now.year}');
  }

  // 2) No EXPIRED certificate (expiringSoon = warning only).
  for (final c in certs) {
    if (c.username != username) continue;
    switch (c.statusAt(now)) {
      case CertExpiryStatus.expired:
        missing.add('תעודה פגה: ${c.name}');
      case CertExpiryStatus.expiringSoon:
        expiring.add('תעודה תפוג בקרוב: ${c.name}');
      case CertExpiryStatus.valid:
        break;
    }
  }

  // 3) Employer-required cert TYPES (ADD-ON; empty ⇒ no-op). Each required name
  // must be matched by a present, VALID (not expired) cert of this user, by
  // NORMALIZED-EXACT name — never substring (no fabricated satisfaction).
  for (final req in requiredCertNames) {
    final key = normalizeDocName(req);
    final satisfied = certs.any((c) =>
        c.username == username &&
        normalizeDocName(c.name) == key &&
        c.statusAt(now) != CertExpiryStatus.expired);
    if (!satisfied) {
      missing.add('חסרה תעודה נדרשת: $req');
    }
  }

  return DocsReadiness(
    ready: missing.isEmpty,
    missing: missing,
    expiring: expiring,
  );
}

/// PURE — the COURIER readiness rule (no Ref / no I/O, unit-tested directly).
///
/// REQUIRED-SET (⚠️ DEMO / SERVER-SWAP product rule — server-defined for real):
/// the courier is `ready` ⟺ EACH of the three [kCourierCertPresets] names
/// (רישיון נהיגה · ביטוח רכב · רישיון רכב) is present among this courier's
/// certificates AND NONE of the courier's certs is [CertExpiryStatus.expired].
/// A missing preset → its name in [DocsReadiness.missing]; an expired cert is
/// BLOCKING (its 'תעודה פגה: …' line in [DocsReadiness.missing]); expiringSoon is a warning
/// in [DocsReadiness.expiring].
DocsReadiness courierDocsReadiness({
  required String username,
  required List<WorkerCert> certs,
  required DateTime now,
}) {
  final mine = certs.where((c) => c.username == username).toList();
  final missing = <String>[];
  final expiring = <String>[];

  // 1) Each required preset must be present (by name).
  final presentNames = mine.map((c) => c.name).toSet();
  for (final required in kCourierCertPresets) {
    if (!presentNames.contains(required)) {
      missing.add('חסרה תעודה: $required');
    }
  }

  // 2) No EXPIRED cert (blocking); expiringSoon is a warning.
  for (final c in mine) {
    switch (c.statusAt(now)) {
      case CertExpiryStatus.expired:
        missing.add('תעודה פגה: ${c.name}');
      case CertExpiryStatus.expiringSoon:
        expiring.add('תעודה תפוג בקרוב: ${c.name}');
      case CertExpiryStatus.valid:
        break;
    }
  }

  return DocsReadiness(
    ready: missing.isEmpty,
    missing: missing,
    expiring: expiring,
  );
}

/// The WORKER readiness for a given username, computed LIVE off the real forms
/// + certs providers and the current clock. The gate watches this, so adding a
/// signed 101 / a valid cert re-evaluates and opens the board with no manual
/// "check again". `.family` keys on the logged username (#66 per-user scope).
final workerDocsReadyProvider = Provider.family<DocsReadiness, String>(
  (ref, username) {
    // ADD-ON: the contractor's employer-scoped required-docs policy. No session
    // → employerId '' → requiredDocsForEmployer('') → [] → no extra requirement
    // (back-compat: existing gate behavior unchanged).
    final employerId = ref.watch(boardAuthProvider)?.employerId ?? '';
    final required = ref.watch(requiredDocsForEmployer(employerId));
    return workerDocsReadiness(
      username: username,
      forms: ref.watch(workerFormsProvider),
      certs: ref
          .watch(workerCertsProvider)
          .where((c) => c.username == username)
          .toList(),
      now: DateTime.now(),
      requiredCertNames: required,
    );
  },
);

/// The COURIER readiness for a given username, computed LIVE off the courier
/// certificate wallet (#86.4) and the current clock. Same live-re-evaluation
/// contract as [workerDocsReadyProvider].
final courierDocsReadyProvider = Provider.family<DocsReadiness, String>(
  (ref, username) => courierDocsReadiness(
    username: username,
    certs: ref
        .watch(courierCertsProvider)
        .where((c) => c.username == username)
        .toList(),
    now: DateTime.now(),
  ),
);

/// TEST SEAM (critical) — when non-null this FORCES the board's gate decision,
/// bypassing the live readiness providers:
///   • `true`  → the board opens regardless of documents (the board tests that
///     are about the board, not the gate, set this so the HARD gate never
///     blocks them);
///   • `false` → the board is forced CLOSED (a test can assert the gate shows);
///   • `null`  → production: the real [workerDocsReadyProvider] /
///     [courierDocsReadyProvider] decision is used.
/// Boards read it as `ref.watch(docsGateOverrideProvider) ?? readiness.ready`.
final docsGateOverrideProvider = StateProvider<bool?>((ref) => null);
