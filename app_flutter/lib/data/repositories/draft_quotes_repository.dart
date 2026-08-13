// ─────────────────────────────────────────────────────────────────────────────
// draft_quotes_repository — a local→server user-data store migration (#2): the
// user's saved quote drafts at `draftQuotes/{uid}`.
//
// WHAT THIS IS: the server-ready seam for the [draftQuoteProvider] list. The
// notifier persists the WHOLE list on every mutation (save/remove/clear), so —
// exactly like carts / savedProjects — the clean target is a single-DOC store:
// `draftQuotes/{uid}` holding `{ quotes: [ DraftQuote.toJson … ], updatedAt }`
// (NOT a subcollection). It resolves Firestore EXACTLY the way
// [SavedProjectsRepository] does: a [FirestoreCollectionSource] SCOPED to the
// signed-in uid (`where(documentId == uid)`) so the read/write is one the
// `draftQuotes/{uid}` owner rule can prove, resolving LAZILY (the Firebase-free
// seam invariant). Talking through the neutral [RemoteCollectionSource] port
// keeps this repo (and its tests) Firebase-free: a hand-rolled fake drives the
// unit suite.
//
// GATED + DORMANT (byte-identity): [draftQuotesRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous
// signed-in uid; otherwise null. With [kUserDataServer] const-false (every normal
// build) the branch is dead code → tree-shaken, [draftQuoteProvider] gets a null
// repo and the drafts keep their verbatim SharedPreferences (`bs.draft-quotes.v1`)
// path → the OFF build is BYTE-IDENTICAL to today. (Mirrors saved_projects_repository.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/draft_quote.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The draft-quotes store at `draftQuotes/{uid}` — ONE document per user holding
/// the whole list as `{ quotes: [ DraftQuote.toJson … ], updatedAt }`. Talks to
/// Firestore only through the neutral [RemoteCollectionSource] seam (scoped to
/// the uid), so a hand-rolled fake drives the unit tests just like the
/// carts/savedProjects/users repos — no `fake_cloud_firestore`, no live backend.
class DraftQuotesRepository {
  DraftQuotesRepository(this._source, {required this.currentUid});

  /// The scoped Firestore seam (`draftQuotes`, `documentId == currentUid`).
  /// Writes are by doc-id; the read is a one-shot of the single scoped doc.
  final RemoteCollectionSource _source;

  /// The signed-in uid the doc is keyed on — the provider scopes [_source] to it
  /// and [draftQuoteProvider] passes it back to [load]/[save].
  final String currentUid;

  /// Read `draftQuotes/{uid}` and decode its `quotes`; the empty list when the
  /// doc is absent / unreadable (NEVER throws — the caller starts from an empty
  /// list, exactly like the local path's `raw == null`). A ONE-SHOT read of the
  /// uid-scoped source (0-or-1 doc) — the async twin of the SharedPreferences
  /// `getString` the local path performs. NOT sorted here: the notifier keeps the
  /// same insertion order on both paths.
  Future<List<DraftQuote>> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return _quotesOf(d.data);
      }
      return const <DraftQuote>[];
    } on Object catch (_) {
      return const <DraftQuote>[];
    }
  }

  /// Merge-write the WHOLE list to `draftQuotes/{uid}` as `{ quotes, updatedAt }`
  /// — the server twin of the SharedPreferences `setString`. merge:true (the
  /// [RemoteCollectionSource.set] contract) leaves any server-only field intact;
  /// `updatedAt` is a client ms-epoch stamp (the carts / savedProjects repo style
  /// — the neutral seam speaks plain maps, not FieldValue).
  Future<void> save(String uid, List<DraftQuote> quotes) {
    return _source.set(uid, <String, dynamic>{
      'quotes': quotes.map((q) => q.toJson()).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Decode the `quotes` array of a `draftQuotes/{uid}` doc (mirrors the local
  /// path's `jsonDecode(raw) → DraftQuote.fromJson`). A missing / wrong-typed
  /// `quotes` → empty; a malformed element throws up to [load]'s guard → empty.
  static List<DraftQuote> _quotesOf(Map<String, dynamic> data) {
    final raw = data['quotes'];
    if (raw is! List) return const <DraftQuote>[];
    return raw
        .map((e) => DraftQuote.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// The draft-quotes repository provider — the server-migration seam
/// [draftQuoteProvider] routes its persist/load through. Returns the
/// Firestore-backed, uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
/// otherwise null (the SharedPreferences path). With [kUserDataServer] const-false
/// the branch is dead code (tree-shaken) and the value stays null →
/// [draftQuoteProvider] never rebuilds → the OFF build is byte-identical.
/// (Mirrors `savedProjectsRepositoryProvider` exactly.)
final draftQuotesRepositoryProvider = Provider<DraftQuotesRepository?>((ref) {
  // The const flag is checked FIRST: with kUserDataServer OFF the whole branch is
  // dead code, so this provider never even watches authState — it takes on ZERO
  // dependencies, returns null once and never rebuilds → [draftQuoteProvider]
  // stays on its SharedPreferences path, byte-identical to today.
  if (kUserDataServer && useFirebaseBackend) {
    // Watch ONLY the two axes that decide WHERE the drafts live — the uid and
    // whether it is the anonymous guest — so a mere profile edit never rebuilds
    // the repo. isAnonymous ALSO flips when a guest upgrades in place (same uid),
    // which must still migrate. (Mirrors the carts/savedProjects granularity.)
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    // A REAL (non-anonymous) signed-in uid only — the anonymous catalog guest
    // keeps its device-local drafts.
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'draftQuotes',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return DraftQuotesRepository(source, currentUid: uid);
    }
  }
  return null;
});
