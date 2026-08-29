// ─────────────────────────────────────────────────────────────────────────────
// vacation_requests_repository — the FIRST cross-party HR local→server migration.
// The worker/courier SUBMITS a request; the MANAGER (or the employing contractor)
// DECIDES it (status flip). So — unlike the self-only stores — a DIFFERENT party
// writes the doc than the one who created it. That rules out the single-doc-per-uid
// shape: each request is its OWN document `vacationRequests/{requestId}` carrying
// `username` (the requester's uid on the server path) and `employerId` (the
// contractor uid, from the setEmployer claim via the board session).
//
// SCOPES (chosen by the session role in [vacationRequestsRepositoryProvider]):
//   • worker / courier → their OWN queue: `where username == uid` (submit + read).
//   • manager          → the WHOLE queue (read all + decide), bounded.
//   • the employer roster (`requestsForEmployer`) → a separate bounded stream
//     [employerVacationProvider] (`where employerId == me`), the certs pattern.
//
// The firestore rule (see firestore.rules) is what makes the cross-party write
// SAFE: a worker may only CREATE their own pending request (never UPDATE — no
// self-approval); only the employer (doc's employerId == me) or a manager may
// UPDATE the status. GATED + DORMANT behind kUserDataServer → OFF is byte-identical.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The shared vacation-request queue at `vacationRequests/{requestId}` — one
/// document per request. Reads through a scoped [RemoteCollectionSource]; writes
/// are per-doc (submit = create by request-id, decide = merge the status flip).
class VacationRequestsRepository {
  VacationRequestsRepository(this._source);

  final RemoteCollectionSource _source;

  /// Read the session-scoped slice of the queue (own / employer / all — the
  /// scope lives in [_source]); empty when unreadable (never throws).
  Future<List<VacationRequest>> loadScoped() async {
    try {
      return decodeDocs(await _source.snapshots().first);
    } on Object catch (_) {
      return const <VacationRequest>[];
    }
  }

  /// WORKER/COURIER write — create the request at `vacationRequests/{r.id}` with
  /// its whole payload ([VacationRequest.toJson] already carries id/username/
  /// employerId/status=='pending'). The rule proves `username == auth.uid`.
  Future<void> submit(VacationRequest r) => _source.set(r.id, r.toJson());

  /// MANAGER/EMPLOYER write — merge the status flip onto the existing request
  /// doc. `decidedTs` is written in the SAME ISO-8601 shape [VacationRequest.
  /// toJson] uses, so a re-decode is byte-consistent. The rule proves the caller
  /// is the doc's employer or a manager (never the requester → no self-approval).
  Future<void> decide(String id, String status, DateTime decidedTs) =>
      _source.set(id, <String, dynamic>{
        'status': status,
        'decidedTs': decidedTs.toIso8601String(),
      });

  /// Decode a `vacationRequests` snapshot into a request list (per-entry
  /// tolerant — a malformed doc is dropped, never crashes the load).
  static List<VacationRequest> decodeDocs(List<RemoteDoc> docs) => [
        for (final d in docs)
          if (VacationRequest.tryFromJson(d.data) case final r?) r,
      ];
}

/// The vacation-requests repository provider — scoped by the CURRENT board
/// session's role, so the same shared notifier serves every persona:
///   • worker / courier → their own queue (`where username == uid`) + submit;
///   • manager          → the whole queue (bounded) + decide.
/// null on the OFF path (byte-identical) and for a demo/anon/uid-less session.
final vacationRequestsRepositoryProvider =
    Provider<VacationRequestsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null && !session.demo && session.uid.isNotEmpty) {
      final uid = session.uid;
      if (session.role == BoardRole.worker ||
          session.role == BoardRole.courier) {
        // The requester's own queue — read own, submit own.
        final source = FirestoreCollectionSource(
          'vacationRequests',
          scope: (c) => c.where('username', isEqualTo: uid),
          bound: (q) => q.limit(200),
        );
        return VacationRequestsRepository(source);
      }
      if (session.role == BoardRole.manager) {
        // The whole queue — the manager reads all and decides. BOUNDED.
        final source = FirestoreCollectionSource(
          'vacationRequests',
          bound: (q) => q.limit(500),
        );
        return VacationRequestsRepository(source);
      }
    }
  }
  return null;
});

/// The EMPLOYER roster stream — every `vacationRequests` doc whose `employerId`
/// equals [employerUid], BOUNDED (`limit(500)`). Read proven by the rule's
/// employer branch. Mirrors employerCertsProvider; feeds `requestsForEmployer`.
final employerVacationProvider =
    StreamProvider.family<List<VacationRequest>, String>((ref, employerUid) {
  final source = FirestoreCollectionSource(
    'vacationRequests',
    scope: (c) => c.where('employerId', isEqualTo: employerUid),
    bound: (q) => q.limit(500),
  );
  return source.snapshots().map(VacationRequestsRepository.decodeDocs);
});
