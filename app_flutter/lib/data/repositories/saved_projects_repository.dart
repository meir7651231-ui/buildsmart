// ─────────────────────────────────────────────────────────────────────────────
// saved_projects_repository — the SECOND shipped local→server store migration
// (notif_settings is parity-frozen, deferred): the user's saved install-studio
// projects at `savedProjects/{uid}`.
//
// WHAT THIS IS: the server-ready seam for the [savedProjectsProvider] list. The
// notifier already persists the WHOLE list on every mutation (save/remove/rename
// each call `_persist`), so — exactly like the cart — the clean target is a
// single-DOC store: `savedProjects/{uid}` holding `{ projects: [ SavedProject.toJson
// … ], updatedAt }` (NOT a subcollection; per-doc writes would fight the
// whole-list persist model). It resolves Firestore EXACTLY the way
// [CartsRepository] does: a [FirestoreCollectionSource] SCOPED to the signed-in uid
// (`where(documentId == uid)`) so the read/write is one the `savedProjects/{uid}`
// owner rule can prove, resolving LAZILY (the Firebase-free seam invariant).
// Talking through the neutral [RemoteCollectionSource] port keeps this repo (and
// its tests) Firebase-free: a hand-rolled fake drives the unit suite.
//
// GATED + DORMANT (byte-identity): [savedProjectsRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous
// signed-in uid; otherwise null. With [kUserDataServer] const-false (every normal
// build) the branch is dead code → tree-shaken, [savedProjectsProvider] gets a
// null repo and the projects keep their verbatim SharedPreferences
// (`bs.saved_projects.v1`) path → the OFF build is BYTE-IDENTICAL to today.
// (Mirrors carts_repository.dart.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/saved_projects.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The saved-projects store at `savedProjects/{uid}` — ONE document per user
/// holding the whole list as `{ projects: [ SavedProject.toJson … ], updatedAt }`.
/// Talks to Firestore only through the neutral [RemoteCollectionSource] seam
/// (scoped to the uid), so a hand-rolled fake drives the unit tests just like the
/// carts/users repos — no `fake_cloud_firestore`, no live backend.
class SavedProjectsRepository {
  SavedProjectsRepository(this._source, {required this.currentUid});

  /// The scoped Firestore seam (`savedProjects`, `documentId == currentUid`).
  /// Writes are by doc-id; the read is a one-shot of the single scoped doc.
  final RemoteCollectionSource _source;

  /// The signed-in uid the doc is keyed on — the provider scopes [_source] to it
  /// and [savedProjectsProvider] passes it back to [load]/[save].
  final String currentUid;

  /// Read `savedProjects/{uid}` and decode its `projects`; the empty list when the
  /// doc is absent / unreadable (NEVER throws — the caller starts from an empty
  /// list, exactly like the local path's `raw == null`). A ONE-SHOT read of the
  /// uid-scoped source (0-or-1 doc) — the async twin of the SharedPreferences
  /// `getString` the local path performs. NOT sorted here: the notifier applies
  /// the same `savedAt` desc sort to both paths.
  Future<List<SavedProject>> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return _projectsOf(d.data);
      }
      return const <SavedProject>[];
    } on Object catch (_) {
      return const <SavedProject>[];
    }
  }

  /// Merge-write the WHOLE list to `savedProjects/{uid}` as `{ projects, updatedAt }`
  /// — the server twin of the SharedPreferences `setString`. merge:true (the
  /// [RemoteCollectionSource.set] contract) leaves any server-only field intact;
  /// `updatedAt` is a client ms-epoch stamp (the carts / users repo style — the
  /// neutral seam speaks plain maps, not FieldValue).
  Future<void> save(String uid, List<SavedProject> projects) {
    return _source.set(uid, <String, dynamic>{
      'projects': projects.map((p) => p.toJson()).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Decode the `projects` array of a `savedProjects/{uid}` doc (mirrors the local
  /// path's `jsonDecode(raw) → SavedProject.fromJson`). A missing / wrong-typed
  /// `projects` → empty; a malformed element throws up to [load]'s guard → empty.
  static List<SavedProject> _projectsOf(Map<String, dynamic> data) {
    final raw = data['projects'];
    if (raw is! List) return const <SavedProject>[];
    return raw
        .map((e) => SavedProject.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// The saved-projects repository provider — the server-migration seam
/// [savedProjectsProvider] routes its persist/load through. Returns the
/// Firestore-backed, uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
/// otherwise null (the SharedPreferences path). With [kUserDataServer] const-false
/// the branch is dead code (tree-shaken) and the value stays null →
/// [savedProjectsProvider] never rebuilds → the OFF build is byte-identical.
/// (Mirrors `cartsRepositoryProvider` exactly.)
final savedProjectsRepositoryProvider =
    Provider<SavedProjectsRepository?>((ref) {
  // The const flag is checked FIRST: with kUserDataServer OFF the whole branch is
  // dead code, so this provider never even watches authState — it takes on ZERO
  // dependencies, returns null once and never rebuilds → [savedProjectsProvider]
  // stays on its SharedPreferences path, byte-identical to today.
  if (kUserDataServer && useFirebaseBackend) {
    // Watch ONLY the two axes that decide WHERE the projects live — the uid and
    // whether it is the anonymous guest — so a mere profile edit never rebuilds
    // the repo. isAnonymous ALSO flips when a guest upgrades in place (same uid),
    // which must still migrate. (Mirrors the carts/users provider granularity.)
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    // A REAL (non-anonymous) signed-in uid only — the anonymous catalog guest
    // keeps its device-local saved projects.
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'savedProjects',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return SavedProjectsRepository(source, currentUid: uid);
    }
  }
  return null;
});
