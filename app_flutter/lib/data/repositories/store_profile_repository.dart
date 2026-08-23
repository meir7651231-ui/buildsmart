// ─────────────────────────────────────────────────────────────────────────────
// store_profile_repository — supplier-board local→server migration: a store's
// own editable business profile (businessName/phone/address/ח.פ./logo) at
// `storeProfiles/{storeUid}`. The store-keyed twin of worker_profile_repository
// (single-doc + self-only).
//
// The local store is a `username → StoreProfile` map, but every read is
// `map[session.username]` — the CURRENT store's own profile only. For a real
// Firebase store `session.username == session.uid`, so the server model collapses
// the map to ONE document `storeProfiles/{uid}` holding that store's profile
// `{ …StoreProfile.toJson, updatedAt }`; the notifier re-keys the loaded profile
// by the uid so `map[session.username]` still resolves.
//
// The legacy-global (F-18.3) SharedPreferences seed is a LOCAL-ONLY migration
// affordance and is SKIPPED on the server path — a real store's server profile
// starts from its own `storeProfiles/{uid}` doc, never the device's legacy record.
//
// GATED + DORMANT (byte-identity): [storeProfileRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a real (non-demo)
// signed-in STORE uid; otherwise null (SharedPreferences path, byte-identical).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The store's own business profile at `storeProfiles/{storeUid}` — ONE document
/// per store holding the profile as `{ …StoreProfile.toJson, updatedAt }`.
class StoreProfileRepository {
  StoreProfileRepository(this._source, {required this.uid});

  final RemoteCollectionSource _source;

  /// The signed-in store uid the doc is keyed on — the notifier re-keys the
  /// loaded profile by it (so `map[session.username]` resolves) and passes it
  /// back to [save].
  final String uid;

  /// Read `storeProfiles/{uid}` and decode the profile; null when the doc is
  /// absent / unreadable (never throws) — the caller then keeps the empty map so
  /// every field falls back honestly, exactly like the local `raw == null`.
  Future<StoreProfile?> load() async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return StoreProfile.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  /// Merge-write the store's profile to `storeProfiles/{uid}` as
  /// `{ …StoreProfile.toJson, updatedAt }`. The JSON keys match the legacy
  /// bs.supplier-settings.v1 payload (name/bid/phone/address/logo); `updatedAt`
  /// is a client ms-epoch stamp, ignored by [StoreProfile.fromJson] on decode.
  Future<void> save(StoreProfile profile) {
    return _source.set(uid, <String, dynamic>{
      ...profile.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The store-profile repository provider — gated on a real (non-demo) signed-in
/// store; null on the OFF path (byte-identical). Mirrors
/// workerProfileRepositoryProvider (single-doc; self-only).
final storeProfileRepositoryProvider =
    Provider<StoreProfileRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final session = ref.watch(boardAuthProvider);
    if (session != null &&
        session.role == BoardRole.store &&
        !session.demo &&
        session.uid.isNotEmpty) {
      final uid = session.uid;
      final source = FirestoreCollectionSource(
        'storeProfiles',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return StoreProfileRepository(source, uid: uid);
    }
  }
  return null;
});
