// ─────────────────────────────────────────────────────────────────────────────
// store_settings_repository — local→server: the user's store-settings doc at
// `storeSettings/{uid}`. One of the four settings blobs unblocked from the שער-25
// Preact-freeze (Preact retired). Single-DOC, self-only, uid-scoped seam — a
// byte-for-byte mirror of notif_settings_repository.dart. GATED under
// `kUserDataServer && useFirebaseBackend` for a NON-anonymous uid; else null.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single store-settings store at `storeSettings/{uid}` — ONE doc per user (the
/// whole [StoreSettings.toJson] map + an `updatedAt` stamp the decoder ignores).
class StoreSettingsRepository {
  StoreSettingsRepository(this._source, {required this.currentUid});

  final RemoteCollectionSource _source;
  final String currentUid;

  Future<StoreSettings?> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return StoreSettings.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> save(String uid, StoreSettings settings) {
    return _source.set(uid, <String, dynamic>{
      ...settings.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// Firestore-backed uid-scoped repo ONLY under `kUserDataServer &&
/// useFirebaseBackend` for a NON-anonymous uid; else null. Mirrors notif_settings.
final storeSettingsRepositoryProvider =
    Provider<StoreSettingsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'storeSettings',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return StoreSettingsRepository(source, currentUid: uid);
    }
  }
  return null;
});
