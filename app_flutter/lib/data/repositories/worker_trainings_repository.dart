// ─────────────────────────────────────────────────────────────────────────────
// worker_trainings_repository — worker-HR local→server migration (mirrors
// worker_certs_repository): a worker's own safety-training log at
// `workerTrainings/{workerUid}`.
//
// TWO-SIDED (worker writes, employer reads), same shape as attendance/certs:
// `workerTrainings/{uid}` holds `{ trainings: [ WorkerTraining.toJson … ],
// employerId, updatedAt }`; the worker WRITES/READS their own doc, the EMPLOYER
// (the doc's employerId equals the reader) and a manager READ it. Training
// certificates are PII → the read-scope is strict (never the permissive
// isSignedIn()).
//
// GATED + DORMANT (byte-identity): [workerTrainingsRepositoryProvider] returns
// this repo ONLY under `kUserDataServer && useFirebaseBackend` for a real
// (non-demo) signed-in WORKER uid; otherwise null (SharedPreferences path,
// byte-identical). The DEMO-SEED (demoSeedTrainings) is a local-only affordance
// and never rides the server path — a real worker's server wallet starts empty.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_trainings.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker's own safety-training log at `workerTrainings/{workerUid}` — ONE
/// document per worker holding `{ trainings, employerId, updatedAt }`.
class WorkerTrainingsRepository {
  WorkerTrainingsRepository(
    this._source, {
    required this.currentUid,
    required this.employerId,
  });

  final RemoteCollectionSource _source;
  final String currentUid;
  final String employerId;

  /// Read `workerTrainings/{uid}` and decode its `trainings`; empty when absent /
  /// unreadable (never throws). Per-entry tolerant (a bad row is skipped).
  Future<List<WorkerTraining>> loadMine() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == currentUid) return _trainingsOf(d.data);
      }
      return const <WorkerTraining>[];
    } on Object catch (_) {
      return const <WorkerTraining>[];
    }
  }

  /// Merge-write the worker's WHOLE log to `workerTrainings/{uid}` as
  /// `{ trainings, employerId, updatedAt }` — `employerId` rides every write so
  /// the employer roster query can scope to it.
  Future<void> saveMine(List<WorkerTraining> trainings) {
    return _source.set(currentUid, <String, dynamic>{
      'trainings': trainings.map((t) => t.toJson()).toList(),
      'employerId': employerId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static List<WorkerTraining> _trainingsOf(Map<String, dynamic> data) {
    final raw = data['trainings'];
    if (raw is! List) return const <WorkerTraining>[];
    final out = <WorkerTraining>[];
    for (final e in raw) {
      final t = WorkerTraining.tryFromJson(e);
      if (t != null) out.add(t);
    }
    return out;
  }

  /// FLATTEN one employer-scoped `workerTrainings` snapshot (each doc = one
  /// worker's log) into a single training list for the contractor's HR view.
  static List<WorkerTraining> flattenEmployerDocs(List<RemoteDoc> docs) => [
        for (final d in docs) ..._trainingsOf(d.data),
      ];
}

/// The worker-trainings repository provider — gated on a real (non-demo)
/// signed-in worker; null on the OFF path (byte-identical). Mirrors
/// workerCertsRepositoryProvider.
final workerTrainingsRepositoryProvider =
    Provider<WorkerTrainingsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.worker &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'workerTrainings',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return WorkerTrainingsRepository(
        source,
        currentUid: uid,
        employerId: session.employerId,
      );
    }
  }
  return null;
});

/// The EMPLOYER roster stream — every `workerTrainings` doc whose `employerId`
/// equals [employerUid], flattened. BOUNDED (`limit(500)`), read proven by the
/// `workerTrainings` rule's employer branch. Mirrors employerCertsProvider.
final employerTrainingsProvider =
    StreamProvider.family<List<WorkerTraining>, String>((ref, employerUid) {
  final source = FirestoreCollectionSource(
    'workerTrainings',
    scope: (c) => c.where('employerId', isEqualTo: employerUid),
    bound: (q) => q.limit(500),
  );
  return source.snapshots().map(WorkerTrainingsRepository.flattenEmployerDocs);
});
