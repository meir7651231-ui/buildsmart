// ─────────────────────────────────────────────────────────────────────────────
// chat_settings_repository — local→server: the user's chat-settings doc at
// `chatSettings/{uid}`. One of the four settings blobs unblocked from the שער-25
// Preact-freeze (Preact retired). Single-DOC, self-only, uid-scoped seam — a
// byte-for-byte mirror of notif_settings_repository.dart. GATED under
// `kUserDataServer && useFirebaseBackend` for a NON-anonymous uid; else null.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single chat-settings store at `chatSettings/{uid}` — ONE doc per user (the
/// whole [ChatSettings.toJson] map + an `updatedAt` stamp the decoder ignores).
class ChatSettingsRepository {
  ChatSettingsRepository(this._source, {required this.currentUid});

  final RemoteCollectionSource _source;
  final String currentUid;

  Future<ChatSettings?> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return ChatSettings.fromJson(d.data);
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> save(String uid, ChatSettings settings) {
    return _source.set(uid, <String, dynamic>{
      ...settings.toJson(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// Firestore-backed uid-scoped repo ONLY under `kUserDataServer &&
/// useFirebaseBackend` for a NON-anonymous uid; else null. Mirrors notif_settings.
final chatSettingsRepositoryProvider =
    Provider<ChatSettingsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'chatSettings',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return ChatSettingsRepository(source, currentUid: uid);
    }
  }
  return null;
});
