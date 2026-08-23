// ─────────────────────────────────────────────────────────────────────────────
// rewards_repository — local→server: the user's private rewards overlay at
// `rewards/{uid}` = `{ coins, claimedChallengeIds, updatedAt }`. The compact
// overlay the local path persists (state/rewards_state.dart `_persist`) — the live
// coin balance + which seed challenges were claimed; the leaderboard stays a
// DERIVED local view (`_syncMe`), so only this private overlay migrates.
//
// Resolves the board-username→uid deferral: OFF the store is keyed by the board
// USERNAME (SharedPreferences); ON a REAL signed-in user's overlay lives at
// `rewards/{uid}` keyed by the Firebase uid. Single-DOC, self-only, uid-scoped
// seam — a mirror of notif_settings_repository.dart. GATED under
// `kUserDataServer && useFirebaseBackend` for a NON-anonymous uid; else null.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The private rewards overlay at `rewards/{uid}` — ONE doc per user holding the
/// same compact `{ coins, claimedChallengeIds }` map the local path persists.
class RewardsRepository {
  RewardsRepository(this._source, {required this.currentUid});

  final RemoteCollectionSource _source;
  final String currentUid;

  /// Read `rewards/{uid}` → the raw overlay map (`{coins, claimedChallengeIds}`);
  /// null when absent/unreadable (never throws — the caller keeps the seed, as the
  /// local `raw == null` → return).
  Future<Map<String, dynamic>?> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return d.data;
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  /// Merge-write the compact overlay to `rewards/{uid}` — the server twin of the
  /// SharedPreferences `setString` (`{ coins, claimedChallengeIds, updatedAt }`).
  Future<void> save(String uid, Map<String, dynamic> overlay) {
    return _source.set(uid, <String, dynamic>{
      ...overlay,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// The rewards repository provider — Firestore-backed uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid; else
/// null (the SharedPreferences path). Mirrors `notifSettingsRepositoryProvider`.
final rewardsRepositoryProvider = Provider<RewardsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'rewards',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return RewardsRepository(source, currentUid: uid);
    }
  }
  return null;
});
