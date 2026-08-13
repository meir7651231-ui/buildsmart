// ─────────────────────────────────────────────────────────────────────────────
// notif_settings_repository — a local→server store migration: the user's single
// notification-settings document at `notifSettings/{uid}`.
//
// (Unblocked 2026-08-13: notif_settings left the שער-25 Preact-freeze once Preact
// retired — buildsmart-il.com is the Flutter app — so this settings blob may now
// move to the server like the cart.)
//
// WHAT THIS IS: the server-ready seam for the ONE [notifSettingsProvider] settings
// blob. Like the cart, a user has exactly ONE settings record, so this is a
// single-DOC store — `notifSettings/{uid}` holding the whole [NotifSettings.toJson]
// map (plus an `updatedAt` stamp the decoder ignores) — with a plain async
// load/save. It resolves Firestore EXACTLY the way [CartsRepository] /
// [FirestoreUsersRepository] do: a [FirestoreCollectionSource] SCOPED to the
// signed-in uid (`where(documentId == uid)`) so the read/write is one the
// `notifSettings/{uid}` owner rule can prove, resolving LAZILY (the Firebase-free
// seam invariant). Talking through the neutral [RemoteCollectionSource] port keeps
// this repo (and its tests) Firebase-free — a hand-rolled fake drives the unit
// suite, no `fake_cloud_firestore`.
//
// GATED: [notifSettingsRepositoryProvider] returns this repo ONLY under
// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
// otherwise null (the SharedPreferences path). With USER_DATA_SERVER ARMED live
// (2026-08-13), a real signed-in user's settings now live at `notifSettings/{uid}`.
// (Mirrors carts_repository.dart exactly.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single notification-settings store at `notifSettings/{uid}` — ONE document
/// per user holding the whole [NotifSettings.toJson] map (+ an `updatedAt` stamp
/// the decoder ignores). Talks to Firestore only through the neutral
/// [RemoteCollectionSource] seam (scoped to the uid), so a hand-rolled fake drives
/// the unit tests just like the carts/users repos — no `fake_cloud_firestore`.
class NotifSettingsRepository {
  NotifSettingsRepository(this._source, {required this.currentUid});

  /// The scoped Firestore seam (`notifSettings`, `documentId == currentUid`).
  /// Writes are by doc-id; the read is a one-shot of the single scoped doc.
  final RemoteCollectionSource _source;

  /// The signed-in uid the doc is keyed on — the provider scopes [_source] to it
  /// and [notifSettingsProvider] passes it back to [load]/[save].
  final String currentUid;

  /// Read `notifSettings/{uid}` and decode it into [NotifSettings]; `null` when
  /// the doc is absent / unreadable (NEVER throws — the caller keeps its current
  /// [NotifSettings.defaults], exactly like the local path's `raw == null` →
  /// return). A ONE-SHOT read of the uid-scoped source (0-or-1 doc) — the async
  /// twin of the SharedPreferences `getString` the local path performs.
  Future<NotifSettings?> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return NotifSettings.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  /// Merge-write the WHOLE settings blob to `notifSettings/{uid}` as
  /// `{ …toJson, updatedAt }` — the server twin of the SharedPreferences
  /// `setString`. merge:true (the [RemoteCollectionSource.set] contract) leaves
  /// any server-only field intact; `updatedAt` is a client ms-epoch stamp (the
  /// carts / users repo style — the neutral seam speaks plain maps, not
  /// FieldValue). [NotifSettings.fromJson] ignores the extra `updatedAt` key on
  /// the way back, so the round-trip is lossless.
  Future<void> save(String uid, NotifSettings settings) {
    return _source.set(uid, <String, dynamic>{
      ...settings.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The notif-settings repository provider — the server-migration seam
/// [notifSettingsProvider] routes its persist/load through. Returns the
/// Firestore-backed, uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
/// otherwise null (the SharedPreferences path). (Mirrors `cartsRepositoryProvider`
/// exactly.)
final notifSettingsRepositoryProvider = Provider<NotifSettingsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    // Watch ONLY the two axes that decide WHERE the settings live — the uid and
    // whether it is the anonymous guest — so a mere profile edit never rebuilds
    // the repo and reloads the settings. isAnonymous ALSO flips when a guest
    // upgrades in place (same uid), which must still migrate. (Mirrors the
    // uid-scoped carts/users provider rebuild granularity.)
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    // A REAL (non-anonymous) signed-in uid only — the anonymous catalog guest
    // keeps its device-local settings.
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'notifSettings',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return NotifSettingsRepository(source, currentUid: uid);
    }
  }
  return null;
});
