// ─────────────────────────────────────────────────────────────────────────────
// worker_profile_repository — worker-HR local→server migration: a worker's own
// editable board profile (name/phone/specialty/photo/ת.ז/address/emergency) at
// `workerProfiles/{workerUid}`.
//
// SINGLE-DOC + SELF-ONLY: the local store is a `username → WorkerProfile` map,
// but every read is `map[session.username]` — the CURRENT worker's own profile
// only (no persona reads another worker's profile through this store). For a
// real Firebase worker `session.username == session.uid`, so the server model
// collapses the map to ONE document `workerProfiles/{uid}` holding that worker's
// profile `{ …WorkerProfile.toJson, updatedAt }`. The notifier re-keys the loaded
// profile by the uid so `map[session.username]` still resolves.
//
// GATED + DORMANT (byte-identity): [workerProfileRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a real (non-demo)
// signed-in WORKER uid; otherwise null (SharedPreferences path, byte-identical).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker's own profile at `workerProfiles/{workerUid}` — ONE document per
/// worker holding the profile as `{ …WorkerProfile.toJson, updatedAt }`.
class WorkerProfileRepository {
  WorkerProfileRepository(this._source, {required this.uid});

  final RemoteCollectionSource _source;

  /// The signed-in worker uid the doc is keyed on — the notifier re-keys the
  /// loaded profile by it (so the map read `[session.username]` resolves) and
  /// passes it back to [save].
  final String uid;

  /// Read `workerProfiles/{uid}` and decode the profile; null when the doc is
  /// absent / unreadable (never throws) — the caller then keeps the empty map
  /// so every field falls back honestly, exactly like the local `raw == null`.
  Future<WorkerProfile?> load() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return WorkerProfile.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  /// Merge-write the worker's profile to `workerProfiles/{uid}` as
  /// `{ …WorkerProfile.toJson, updatedAt }` — the server twin of the
  /// SharedPreferences `setString`. `updatedAt` is a client ms-epoch stamp; the
  /// extra key is ignored by [WorkerProfile.fromJson] on decode.
  Future<void> save(WorkerProfile profile) {
    return _source.set(uid, <String, dynamic>{
      ...profile.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The worker-profile repository provider — gated on a real (non-demo) signed-in
/// worker; null on the OFF path (byte-identical). Mirrors the worker_forms gate
/// (single-doc; self-only — no persona reads another worker's profile here).
final workerProfileRepositoryProvider =
    Provider<WorkerProfileRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.worker &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'workerProfiles',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return WorkerProfileRepository(source, uid: uid);
    }
  }
  return null;
});
