// ─────────────────────────────────────────────────────────────────────────────
// worker_certs_repository — worker-HR local→server migration (mirrors
// worker_attendance_repository): a worker's own certificate wallet at
// `workerCerts/{workerUid}`.
//
// TWO-SIDED (worker writes, employer reads), same shape as attendance:
// `workerCerts/{uid}` holds `{ certs: [ WorkerCert.toJson … ], employerId,
// updatedAt }`; the worker WRITES/READS their own doc, the EMPLOYER (the doc's
// employerId equals the reader) and a manager READ it. Certificate photos are
// PII → the read-scope is strict (never the permissive isSignedIn()).
//
// GATED + DORMANT (byte-identity): [workerCertsRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a real (non-demo)
// signed-in WORKER uid; otherwise null (SharedPreferences path, byte-identical).
// The courier reuse (a separate wallet key) stays local — it passes no repo.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker's own certificate wallet at `workerCerts/{workerUid}` — ONE
/// document per worker holding `{ certs, employerId, updatedAt }`.
class WorkerCertsRepository {
  WorkerCertsRepository(
    this._source, {
    required this.currentUid,
    required this.employerId,
  });

  final RemoteCollectionSource _source;
  final String currentUid;
  final String employerId;

  /// Read `workerCerts/{uid}` and decode its `certs`; empty when absent /
  /// unreadable (never throws). Per-entry tolerant (a bad row is skipped).
  Future<List<WorkerCert>> loadMine() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == currentUid) return _certsOf(d.data);
      }
      return const <WorkerCert>[];
    } on Object catch (_) {
      return const <WorkerCert>[];
    }
  }

  /// Merge-write the worker's WHOLE wallet to `workerCerts/{uid}` as
  /// `{ certs, employerId, updatedAt }` — `employerId` rides every write so the
  /// employer roster query can scope to it.
  Future<void> saveMine(List<WorkerCert> certs) {
    return _source.set(currentUid, <String, dynamic>{
      'certs': certs.map((c) => c.toJson()).toList(),
      'employerId': employerId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static List<WorkerCert> _certsOf(Map<String, dynamic> data) {
    final raw = data['certs'];
    if (raw is! List) return const <WorkerCert>[];
    final out = <WorkerCert>[];
    for (final e in raw) {
      final c = WorkerCert.tryFromJson(e);
      if (c != null) out.add(c);
    }
    return out;
  }

  /// FLATTEN one employer-scoped `workerCerts` snapshot (each doc = one worker's
  /// wallet) into a single cert list for the contractor's HR view.
  static List<WorkerCert> flattenEmployerDocs(List<RemoteDoc> docs) => [
        for (final d in docs) ..._certsOf(d.data),
      ];
}

/// The worker-certs repository provider — gated on a real (non-demo) signed-in
/// worker; null on the OFF path (byte-identical). Mirrors
/// workerAttendanceRepositoryProvider.
final workerCertsRepositoryProvider = Provider<WorkerCertsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.worker &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'workerCerts',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return WorkerCertsRepository(
        source,
        currentUid: uid,
        employerId: session.employerId,
      );
    }
  }
  return null;
});

/// The EMPLOYER roster stream — every `workerCerts` doc whose `employerId`
/// equals [employerUid], flattened. BOUNDED (`limit(500)`), read proven by the
/// `workerCerts` rule's employer branch. Mirrors employerAttendanceProvider.
final employerCertsProvider =
    StreamProvider.family<List<WorkerCert>, String>((ref, employerUid) {
  final source = FirestoreCollectionSource(
    'workerCerts',
    scope: (c) => c.where('employerId', isEqualTo: employerUid),
    bound: (q) => q.limit(500),
  );
  return source.snapshots().map(WorkerCertsRepository.flattenEmployerDocs);
});
