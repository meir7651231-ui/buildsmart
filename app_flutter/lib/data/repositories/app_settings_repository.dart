// ─────────────────────────────────────────────────────────────────────────────
// app_settings_repository — a local→server store migration: the user's single
// app-settings document at `appSettings/{uid}` (theme / units / privacy blob).
//
// One of the four settings blobs that left the שער-25 Preact-freeze once Preact
// retired (buildsmart-il.com = the Flutter app) — so they may now move to the
// server like the cart / notif-settings. Single-DOC, self-only, resolved LAZILY
// through the neutral [RemoteCollectionSource] seam scoped to the uid — a
// byte-for-byte mirror of notif_settings_repository.dart. GATED under
// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
// otherwise null (the SharedPreferences path, byte-identical).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single app-settings store at `appSettings/{uid}` — ONE document per user
/// holding the whole [AppSettings.toJson] map (+ an `updatedAt` stamp the decoder
/// ignores). Neutral [RemoteCollectionSource] seam ⇒ a fake drives the tests.
class AppSettingsRepository {
  AppSettingsRepository(this._source, {required this.currentUid});

  final RemoteCollectionSource _source;
  final String currentUid;

  /// Read `appSettings/{uid}` → [AppSettings]; null when absent/unreadable (never
  /// throws — the caller keeps [AppSettings.defaults], as the local `raw == null`).
  Future<AppSettings?> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return AppSettings.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  /// Merge-write the whole blob to `appSettings/{uid}` as `{ …toJson, updatedAt }`
  /// — the server twin of the SharedPreferences `setString`.
  Future<void> save(String uid, AppSettings settings) {
    return _source.set(uid, <String, dynamic>{
      ...settings.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The app-settings repository provider — the Firestore-backed uid-scoped repo
/// ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in
/// uid; else null (SharedPreferences). Mirrors `notifSettingsRepositoryProvider`.
final appSettingsRepositoryProvider = Provider<AppSettingsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'appSettings',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return AppSettingsRepository(source, currentUid: uid);
    }
  }
  return null;
});
