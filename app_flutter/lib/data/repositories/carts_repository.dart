// ─────────────────────────────────────────────────────────────────────────────
// carts_repository — the FIRST local→server store migration: the smart cart's
// single active document at `carts/{uid}`.
//
// WHAT THIS IS: the server-ready seam for the ONE active [smartCartProvider]
// cart. Unlike the S3 collection repos (orders/customers/…) a user has exactly
// ONE cart, so this is a single-DOC store — `carts/{uid}` holding
// `{ lines: [ SmartCartLine.toJson … ], updatedAt }` — with a plain async
// load/save (NOT the streaming FirestoreCachedRepo cache; the cart notifier
// already holds the live in-memory list). It resolves Firestore EXACTLY the way
// FirestoreUsersRepository does: a [FirestoreCollectionSource] SCOPED to the
// signed-in uid (`where(documentId == uid)`) so the read/write is one the
// `carts/{uid}` owner rule can prove, and the instance resolves LAZILY (never at
// construction — the Firebase-free seam invariant). Talking through the neutral
// [RemoteCollectionSource] port keeps this repo (and its tests) Firebase-free: a
// hand-rolled fake drives the unit suite, exactly like the users repo — no
// `fake_cloud_firestore`, no live backend.
//
// GATED + DORMANT (byte-identity): [cartsRepositoryProvider] returns this repo
// ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-
// in uid; otherwise null. With [kUserDataServer] const-false (every normal
// build) the branch is dead code → tree-shaken, [smartCartProvider] gets a null
// repo and the cart keeps its verbatim SharedPreferences (`bs.smart-cart.v1`)
// path → the OFF build is BYTE-IDENTICAL to today. [useFirebaseBackend] is ANDed
// too (never Firestore offline / in tests) and the anonymous catalog guest is
// excluded (guests stay local).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single active smart-cart store at `carts/{uid}` — ONE document per user
/// holding the whole cart as `{ lines: [ SmartCartLine.toJson … ], updatedAt }`.
/// Talks to Firestore only through the neutral [RemoteCollectionSource] seam
/// (scoped to the uid), so a hand-rolled fake drives the unit tests just like
/// the users repo — no `fake_cloud_firestore`, no live backend.
class CartsRepository {
  CartsRepository(this._source, {required this.currentUid});

  /// The scoped Firestore seam (`carts`, `documentId == currentUid`). Writes are
  /// by doc-id; the read is a one-shot of the single scoped doc.
  final RemoteCollectionSource _source;

  /// The signed-in uid the doc is keyed on — the provider scopes [_source] to it
  /// and [smartCartProvider] passes it back to [load]/[save] (`carts/{uid}`).
  final String currentUid;

  /// Read `carts/{uid}` and decode its `lines`; the empty list when the doc is
  /// absent / unreadable (NEVER throws — the caller starts from an empty cart).
  /// A ONE-SHOT read of the uid-scoped source (0-or-1 doc) — the async twin of
  /// the SharedPreferences `getString` the local path performs.
  Future<List<SmartCartLine>> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return _linesOf(d.data);
      }
      return const <SmartCartLine>[];
    } on Object catch (_) {
      return const <SmartCartLine>[];
    }
  }

  /// Merge-write the WHOLE cart to `carts/{uid}` as `{ lines, updatedAt }` — the
  /// server twin of the SharedPreferences `setString`. merge:true (the
  /// [RemoteCollectionSource.set] contract) leaves any server-only field intact;
  /// `updatedAt` is a client ms-epoch stamp (the users repo's `lastSeen` /
  /// `createdAt` style — the neutral seam speaks plain maps, not FieldValue).
  Future<void> save(String uid, List<SmartCartLine> lines) {
    return _source.set(uid, <String, dynamic>{
      'lines': lines.map((l) => l.toJson()).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Decode the `lines` array of a `carts/{uid}` doc (mirrors the local path's
  /// `jsonDecode(raw) → SmartCartLine.fromJson`). A missing / wrong-typed `lines`
  /// → empty; a malformed element throws up to [load]'s guard → empty.
  static List<SmartCartLine> _linesOf(Map<String, dynamic> data) {
    final raw = data['lines'];
    if (raw is! List) return const <SmartCartLine>[];
    return raw
        .map((e) => SmartCartLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// The carts repository provider — the server-migration seam [smartCartProvider]
/// routes its persist/load through. Returns the Firestore-backed, uid-scoped
/// repo ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous
/// signed-in uid; otherwise null (the SharedPreferences path). With
/// [kUserDataServer] const-false the branch is dead code (tree-shaken) and the
/// value stays null → [smartCartProvider] never rebuilds → the OFF build is
/// byte-identical. (Mirrors the `usersRepositoryProvider` OFF-fallback switch;
/// the anonymous catalog guest is excluded so guests stay local.)
final cartsRepositoryProvider = Provider<CartsRepository?>((ref) {
  // The const flag is checked FIRST: with kUserDataServer OFF the whole branch
  // is dead code, so this provider never even watches authState — it takes on
  // ZERO dependencies, returns null once and never rebuilds → [smartCartProvider]
  // stays on its SharedPreferences path, byte-identical to today.
  if (kUserDataServer && useFirebaseBackend) {
    // Watch ONLY the two axes that decide WHERE the cart lives — the uid and
    // whether it is the anonymous guest — so a mere profile edit (name/email)
    // never rebuilds the repo and reloads/flickers the cart. They change
    // together on sign-in, and isAnonymous ALSO flips when a guest upgrades in
    // place (same uid), which must still migrate — so watching uid alone misses
    // it. (Mirrors the uid-scoped `usersRepositoryProvider` rebuild granularity.)
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    // A REAL (non-anonymous) signed-in uid only — the anonymous catalog guest
    // stays local (guests share the device, not a server cart).
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'carts',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return CartsRepository(source, currentUid: uid);
    }
  }
  return null;
});
