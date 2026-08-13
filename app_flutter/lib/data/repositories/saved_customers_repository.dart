// ─────────────────────────────────────────────────────────────────────────────
// saved_customers_repository — a local→server user-data store migration (#2):
// the user's saved-customers CRM at `savedCustomers/{uid}`.
//
// WHAT THIS IS: the server-ready seam for the [savedCustomersProvider] list of
// SavedCustomer entities. The notifier persists the WHOLE list on every mutation
// (the `set state` write-behind), so — exactly like carts / savedProjects /
// draftQuotes — the clean target is a single-DOC store: `savedCustomers/{uid}`
// holding `{ customers: [ SavedCustomer.toJson … ], updatedAt }` (distinct from the
// SHARED `customers` collection, which is the order-derived manager domain). It
// resolves Firestore the way the sibling repos do: a [FirestoreCollectionSource]
// SCOPED to the signed-in uid (`where(documentId == uid)`) so the read/write is one
// the `savedCustomers/{uid}` owner rule can prove, resolving LAZILY. Talking through
// the neutral [RemoteCollectionSource] port keeps this repo (and its tests)
// Firebase-free.
//
// GATED + DORMANT (byte-identity): [savedCustomersRepositoryProvider] returns this
// repo ONLY under `kUserDataServer && useFirebaseBackend` for a NON-anonymous
// signed-in uid; otherwise null. With [kUserDataServer] const-false (every normal
// build) the branch is dead code → tree-shaken, [savedCustomersProvider] gets a null
// repo and the CRM keeps its verbatim SharedPreferences (`bs.saved-customers.v1`)
// path → the OFF build is BYTE-IDENTICAL to today. (Mirrors draft_quotes_repository.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/customers_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The saved-customers CRM store at `savedCustomers/{uid}` — ONE document per user
/// holding the whole list as `{ customers: [ SavedCustomer.toJson … ], updatedAt }`.
/// Talks to Firestore only through the neutral [RemoteCollectionSource] seam
/// (scoped to the uid), so a hand-rolled fake drives the unit tests just like the
/// sibling repos — no `fake_cloud_firestore`, no live backend.
class SavedCustomersRepository {
  SavedCustomersRepository(this._source, {required this.currentUid});

  /// The scoped Firestore seam (`savedCustomers`, `documentId == currentUid`).
  final RemoteCollectionSource _source;

  /// The signed-in uid the doc is keyed on — the provider scopes [_source] to it
  /// and [savedCustomersProvider] passes it back to [load]/[save].
  final String currentUid;

  /// Read `savedCustomers/{uid}` and decode its `customers`; the empty list when
  /// the doc is absent / unreadable (NEVER throws — the caller starts empty, like
  /// the local path's `raw == null`). A ONE-SHOT read of the uid-scoped source
  /// (0-or-1 doc) — the async twin of the SharedPreferences `getString`.
  /// Per-entry tolerant (a bad row is skipped), mirroring the local `tryFromJson`.
  Future<List<SavedCustomer>> load(String uid) async {
    try {
      final docs = await _source.snapshots().first;
      for (final d in docs) {
        if (d.id == uid) return _customersOf(d.data);
      }
      return const <SavedCustomer>[];
    } on Object catch (_) {
      return const <SavedCustomer>[];
    }
  }

  /// Merge-write the WHOLE list to `savedCustomers/{uid}` as `{ customers, updatedAt }`
  /// — the server twin of the SharedPreferences `setString`. merge:true leaves any
  /// server-only field intact; `updatedAt` is a client ms-epoch stamp.
  Future<void> save(String uid, List<SavedCustomer> customers) {
    return _source.set(uid, <String, dynamic>{
      'customers': customers.map((c) => c.toJson()).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Decode the `customers` array (mirrors the local path's per-entry tolerant
  /// `tryFromJson` — a missing/wrong-typed array → empty; a malformed row is
  /// skipped, never throws).
  static List<SavedCustomer> _customersOf(Map<String, dynamic> data) {
    final raw = data['customers'];
    if (raw is! List) return const <SavedCustomer>[];
    final out = <SavedCustomer>[];
    for (final e in raw) {
      final c = SavedCustomer.tryFromJson(e);
      if (c != null) out.add(c);
    }
    return out;
  }
}

/// The saved-customers repository provider — the server-migration seam
/// [savedCustomersProvider] routes its persist/load through. Returns the
/// Firestore-backed, uid-scoped repo ONLY under
/// `kUserDataServer && useFirebaseBackend` for a NON-anonymous signed-in uid;
/// otherwise null (the SharedPreferences path). With [kUserDataServer] const-false
/// the branch is dead code (tree-shaken) and the value stays null →
/// [savedCustomersProvider] never rebuilds → the OFF build is byte-identical.
/// (Mirrors `draftQuotesRepositoryProvider` exactly.)
final savedCustomersRepositoryProvider =
    Provider<SavedCustomersRepository?>((ref) {
  if (kUserDataServer && useFirebaseBackend) {
    final (uid, isAnonymous) = ref.watch(
      authStateProvider.select((s) => (s.user?.uid, s.user?.isAnonymous ?? true)),
    );
    if (uid != null && uid.isNotEmpty && !isAnonymous) {
      final source = FirestoreCollectionSource(
        'savedCustomers',
        scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
      );
      return SavedCustomersRepository(source, currentUid: uid);
    }
  }
  return null;
});
