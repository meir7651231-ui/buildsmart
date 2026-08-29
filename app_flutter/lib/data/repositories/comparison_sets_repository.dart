// ─────────────────────────────────────────────────────────────────────────────
// comparison_sets_repository — a local→server user-data store migration (#2):
// the user's side-by-side compare set at `comparisonSets/{uid}`.
//
// WHAT THIS IS: the server-ready seam for the [comparisonSetProvider] Set<String>
// of productKeys. The notifier persists the WHOLE set on every mutation, so —
// exactly like carts / savedProjects / draftQuotes — the clean target is a
// single-DOC store: `comparisonSets/{uid}` holding
// `{ keys: [ productKey … ], updatedAt }` (the Set serialised as a list, mirroring
// the local getStringList/setStringList path). It resolves Firestore EXACTLY the
// way the sibling repos do: a [FirestoreCollectionSource] SCOPED to the signed-in
// uid (`where(documentId == uid)`) so the read/write is one the
// `comparisonSets/{uid}` owner rule can prove, resolving LAZILY (the Firebase-free
// seam invariant). Talking through the neutral [RemoteCollectionSource] port keeps
// this repo (and its tests) Firebase-free.
//
// GATED + DORMANT (byte-identity): [comparisonSetsRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous
// signed-in uid; otherwise null. With [kUserDataServer] const-false (every normal
// build) the branch is dead code → tree-shaken, [comparisonSetProvider] gets a null
// repo and the set keeps its verbatim SharedPreferences (`bs.comparison-set.v1`)
// path → the OFF build is BYTE-IDENTICAL to today. (Mirrors draft_quotes_repository.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The compare-set store at `comparisonSets/{uid}` — ONE document per user holding
/// the whole set as `{ keys: [ productKey … ], updatedAt }`. Talks to Firestore
/// only through the neutral [RemoteCollectionSource] seam (scoped to the uid), so a
/// hand-rolled fake drives the unit tests just like the sibling repos — no
/// `fake_cloud_firestore`, no live backend.
class ComparisonSetsRepository {
  ComparisonSetsRepository(this._source, {required this.currentUid});

  /// The scoped Firestore seam (`comparisonSets`, `documentId == currentUid`).
  final RemoteCollectionSource _source;

  /// The signed-in uid the doc is keyed on — the provider scopes [_source] to it
  /// and [comparisonSetProvider] passes it back to [load]/[save].
  final String currentUid;

  /// Read `comparisonSets/{uid}` and decode its `keys`; the empty set when the doc
  /// is absent / unreadable (NEVER throws — the caller starts from an empty set,
  /// exactly like the local path's `getStringList == null`). A ONE-SHOT read of the
  /// uid-scoped source (0-or-1 doc) — the async twin of the SharedPreferences
  /// `getStringList` the local path performs.
  Future<Set<String>> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return _keysOf(d.data);
      }
      return const <String>{};
    } on Object catch (_) {
      return const <String>{};
    }
  }

  /// Merge-write the WHOLE set to `comparisonSets/{uid}` as `{ keys, updatedAt }`
  /// — the server twin of the SharedPreferences `setStringList`. merge:true leaves
  /// any server-only field intact; `updatedAt` is a client ms-epoch stamp.
  Future<void> save(String uid, Set<String> keys) {
    return _source.set(uid, <String, dynamic>{
      'keys': keys.toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Decode the `keys` array of a `comparisonSets/{uid}` doc (mirrors the local
  /// path's `getStringList → toSet`). A missing / wrong-typed `keys` → empty set;
  /// non-string elements are dropped (defensive, never throws).
  static Set<String> _keysOf(Map<String, dynamic> data) {
    final raw = data['keys'];
    if (raw is! List) return const <String>{};
    return raw.whereType<String>().toSet();
  }
}

/// The compare-set repository provider — the server-migration seam
/// [comparisonSetProvider] routes its persist/load through. Returns the
/// Firestore-backed, uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
/// otherwise null (the SharedPreferences path). With [kUserDataServer] const-false
/// the branch is dead code (tree-shaken) and the value stays null →
/// [comparisonSetProvider] never rebuilds → the OFF build is byte-identical.
/// (Mirrors `draftQuotesRepositoryProvider` exactly.)
final comparisonSetsRepositoryProvider =
    Provider<ComparisonSetsRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'comparisonSets',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return ComparisonSetsRepository(source, currentUid: uid);
    }
  }
  return null;
});
