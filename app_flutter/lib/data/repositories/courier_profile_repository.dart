// ─────────────────────────────────────────────────────────────────────────────
// courier_profile_repository — courier-HR local→server migration: a courier's
// own editable board profile (displayName/phone/preferredHaul/photo) at
// `courierProfiles/{courierUid}`. The courier-keyed twin of
// worker_profile_repository (single-doc + self-only).
//
// The local store is a `username → CourierProfile` map, but every read is
// `map[session.username]` — the CURRENT courier's own profile only. For a real
// Firebase courier `session.username == session.uid`, so the server model
// collapses the map to ONE document `courierProfiles/{uid}` holding that
// courier's profile `{ …CourierProfile.toJson, updatedAt }`; the notifier re-keys
// the loaded profile by the uid so `map[session.username]` still resolves.
//
// GATED + DORMANT (byte-identity): [courierProfileRepositoryProvider] returns
// this repo ONLY under `kUserDataServer && useFirebaseBackend` for a real
// (non-demo) signed-in COURIER uid; otherwise null (SharedPreferences path,
// byte-identical).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The courier's own profile at `courierProfiles/{courierUid}` — ONE document
/// per courier holding the profile as `{ …CourierProfile.toJson, updatedAt }`.
class CourierProfileRepository {
  CourierProfileRepository(this._source, {required this.uid});

  final RemoteCollectionSource _source;

  /// The signed-in courier uid the doc is keyed on — the notifier re-keys the
  /// loaded profile by it (so `map[session.username]` resolves) and passes it
  /// back to [save].
  final String uid;

  /// Read `courierProfiles/{uid}` and decode the profile; null when the doc is
  /// absent / unreadable (never throws) — the caller then keeps the empty map so
  /// every field falls back honestly, exactly like the local `raw == null`.
  Future<CourierProfile?> load() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return CourierProfile.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  /// Merge-write the courier's profile to `courierProfiles/{uid}` as
  /// `{ …CourierProfile.toJson, updatedAt }`. `updatedAt` is a client ms-epoch
  /// stamp; the extra key is ignored by [CourierProfile.fromJson] on decode.
  Future<void> save(CourierProfile profile) {
    return _source.set(uid, <String, dynamic>{
      ...profile.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The courier-profile repository provider — gated on a real (non-demo) signed-in
/// courier; null on the OFF path (byte-identical). Mirrors
/// workerProfileRepositoryProvider (single-doc; self-only).
final courierProfileRepositoryProvider =
    Provider<CourierProfileRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.courier &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'courierProfiles',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return CourierProfileRepository(source, uid: uid);
    }
  }
  return null;
});
