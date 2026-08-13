// ─────────────────────────────────────────────────────────────────────────────
// worker_forms_repository — worker-HR local→server migration: a worker's own
// digital forms (טופס-101 + sick-note uploads) at `workerForms/{workerUid}`.
//
// SINGLE-DOC + SELF-SCOPED (NOT two-sided like attendance/certs/trainings): the
// 101 form is transmitted to the contractor through the CHAT engine, not read
// off a roster, so there is no employer-scoped query here — only the worker
// reads/writes their OWN doc. `workerForms/{uid}` holds the whole compound
// state `{ forms, sick, updatedAt }` (WorkerFormsState.toJson). Forms carry PII
// (ת.ז, signature) → the rule is self-only (the carts/draftQuotes shape).
//
// GATED + DORMANT (byte-identity): [workerFormsRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a real (non-demo)
// signed-in WORKER uid; otherwise null (SharedPreferences path, byte-identical).
// The courier reuse (courierFormsProvider, a separate key) passes no repo → it
// stays local, exactly like the certs/trainings courier reuse.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker's own forms store at `workerForms/{workerUid}` — ONE document per
/// worker holding the whole compound state as `{ forms, sick, updatedAt }`.
class WorkerFormsRepository {
  WorkerFormsRepository(this._source, {required this.currentUid});

  final RemoteCollectionSource _source;
  final String currentUid;

  /// Read `workerForms/{uid}` and decode the whole compound state; the empty
  /// state when the doc is absent / unreadable (never throws) — the async twin
  /// of the SharedPreferences `getString` the local path performs. Per-entry
  /// tolerance is baked into [WorkerFormsState.fromJson] (a bad row is dropped).
  Future<WorkerFormsState> load() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == currentUid) return WorkerFormsState.fromJson(d.data);
      }
      return const WorkerFormsState();
    } on Object catch (_) {
      return const WorkerFormsState();
    }
  }

  /// Merge-write the WHOLE compound state to `workerForms/{uid}` as
  /// `{ forms, sick, updatedAt }` — the server twin of the SharedPreferences
  /// `setString`. `updatedAt` is a client ms-epoch stamp (the neutral seam
  /// speaks plain maps, not FieldValue); the extra key is ignored on decode.
  Future<void> save(WorkerFormsState state) {
    return _source.set(currentUid, <String, dynamic>{
      ...state.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The worker-forms repository provider — gated on a real (non-demo) signed-in
/// worker; null on the OFF path (byte-identical). Mirrors the worker_certs /
/// worker_trainings gate (single-doc; no employer roster provider — forms reach
/// the contractor via chat, not a query).
final workerFormsRepositoryProvider = Provider<WorkerFormsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.worker &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'workerForms',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return WorkerFormsRepository(source, currentUid: uid);
    }
  }
  return null;
});
