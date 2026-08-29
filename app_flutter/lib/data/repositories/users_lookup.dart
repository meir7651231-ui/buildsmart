// ─────────────────────────────────────────────────────────────────────────────
// users_lookup — A7 (launch uid-migration): the COUNTERPARTY → uid directory.
//
// WHY THIS EXISTS (SPEC launch Phase A, row A7):
//   A4 stamps an order's storeId/courierId with an `auth.uid`; A8 scopes a chat
//   thread's `participants` on uids. But the app only knows a counterparty by
//   their identity fields (a store/courier phone, sometimes a role) — NOT their
//   uid. This service is the missing translation step: given a PHONE (and
//   optionally a ROLE), it resolves the matching `users/{uid}` document and
//   returns its doc-id — the `auth.uid` — so A4/A8 can fill those fields.
//
// THE `users` COLLECTION (the data this reads):
//   `users/{uid}` is the profile mirror written by `usersProfileWriterProvider`
//   (= `FirestoreCollectionSource('users')`, see state/auth_state.dart). The
//   welcome flow merges the signed-in identity into it (screens/welcome_screen
//   .dart): `{displayName, phone}`; the doc-id IS the `auth.uid`, and per the
//   writer's contract the doc may also carry an admin-assigned `role` (and an
//   `fcmToken`). So a phone → uid lookup is "find the `users` doc whose `phone`
//   equals X, return its id", and an optional role filter narrows on `role`.
//
// HARD RULES (mirroring every other data-layer seam — break one, break the
// zero-regression contract):
//   1. NO Firebase touch without the live backend. The provider gates on the
//      SAME `useFirebaseBackend` switch the repos + `usersProfileWriterProvider`
//      use; Firebase-free (the whole test suite + the sandbox) ⇒ the provider is
//      null and every lookup returns null/[]. Nothing here resolves
//      `FirebaseFirestore.instance` itself — it goes through the injectable
//      [RemoteCollectionSource] (real impl resolves the instance LAZILY).
//   2. ADDITIVE ONLY. A7 builds the directory; it is NOT wired into any A4/A8
//      call-site here (that is the next row). No existing flow changes behavior.
//   3. A backend hiccup must NEVER throw into a caller — a failed/empty snapshot
//      resolves to null/[] (the "not found" answer), never an exception.
//
// THE SEAM ([RemoteCollectionSource]): this reuses the very port the cache base
// speaks (firestore_cached_repo.dart) — neutral [RemoteDoc]s (id + field map),
// no `QuerySnapshot`. That is what lets `uidByPhone`/`uidsByRole` be unit-tested
// against a hand-rolled fake `users` dataset with zero new packages (the same
// `_FakeSource` the S2/A3/A8 tests already use).
//
// Comment density/voice intentionally mirrors firestore_cached_repo.dart /
// auth_state.dart — this is a foundation A4/A8 will read first.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/edge/edge_collection_source.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart' show filteredFirestoreProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `users/{uid}` field names this directory keys on. Kept verbatim with the
/// writer (`usersProfileWriterProvider`, screens/welcome_screen.dart) so the
/// read side can never silently drift from the write side.
const String kUsersPhoneField = 'phone';
const String kUsersRoleField = 'role';

/// The counterparty → uid directory over the `users` collection.
///
/// It reads the collection through the injectable [RemoteCollectionSource] seam
/// — so a fake source drives every unit test with no Firebase — and translates a
/// counterparty's identity (phone, optional role) into their `auth.uid` (the
/// `users` doc-id). A single read snapshot is scanned per lookup; a read failure
/// or an empty/closed collection yields the "not found" answer (null / `[]`),
/// never a throw (HARD RULE #3).
@immutable
class UsersLookup {
  const UsersLookup(this._source, {RemoteCollectionSource? directorySource})
      : _directory = directorySource;

  /// The `directory` seam — the small, readable {role, displayName, status}
  /// list. Optional: null keeps every lookup on `_source`, which is what the
  /// existing tests (and any Firebase-free path) expect.
  ///
  /// It exists because role resolution is done by EVERY signed-in person, and
  /// the `users` rule only lets someone read their OWN document. That read was
  /// therefore denied for everyone but an admin, and the denial was swallowed —
  /// so a chat thread got stamped with only its sender and became invisible to
  /// the person it was addressed to. Phone lookup deliberately stays on `users`:
  /// it is an admin-only surface (the manager assigning a role), and a phone
  /// number is exactly the kind of field the directory must not carry.
  final RemoteCollectionSource? _directory;

  /// The injectable Firestore seam pointed at `users`. The real provider passes
  /// `FirestoreCollectionSource('users')` (resolves the instance lazily); tests
  /// pass a hand-rolled fake holding a `users` dataset.
  final RemoteCollectionSource _source;

  /// Read ONE snapshot of the whole `users` collection. The seam's `snapshots()`
  /// is a live stream; a directory lookup only needs the current state, so we
  /// take the first event. ANY error (stream error, no backend reachable) is
  /// swallowed to an empty list — the caller then gets the "not found" answer.
  Future<List<RemoteDoc>> _readAll() => _readAllFrom(_source);

  /// One snapshot of [source]. Same swallow-to-empty contract as [_readAll].
  Future<List<RemoteDoc>> _readAllFrom(RemoteCollectionSource source) async {
    try {
      return await source.snapshots().first;
    } on Object catch (e) {
      // A backend hiccup is a "directory unavailable" → empty, never a throw.
      debugPrint('UsersLookup: users read failed (treated as empty): $e');
      return const <RemoteDoc>[];
    }
  }

  /// True when [doc]'s `role` field equals [role]. A null [role] means "don't
  /// filter on role" (always true). A `users` doc with no/non-matching role is
  /// excluded only when a role IS requested — so an unscoped phone lookup still
  /// matches docs that carry no role (the common, mirror-only case).
  static bool _roleMatches(RemoteDoc doc, String? role) {
    if (role == null) return true;
    return doc.data[kUsersRoleField] == role;
  }

  /// Resolve the `auth.uid` (the `users` doc-id) of the counterparty whose
  /// `phone` equals [phone] — or null when no such user exists (or no backend).
  ///
  /// When [role] is supplied, the match must ALSO carry that `role` (e.g.
  /// "the STORE at this phone", not a same-phone courier). [phone] is matched
  /// verbatim against the stored `phone` field, so callers must pass it in the
  /// SAME shape the welcome flow mirrors it (the on-device `profile.contact`).
  /// On multiple matches the FIRST in document order wins (deterministic enough
  /// for a directory whose phones are expected unique per role).
  Future<String?> uidByPhone(String phone, {String? role}) async {
    if (phone.isEmpty) return null;
    for (final doc in await _readAll()) {
      if (doc.data[kUsersPhoneField] == phone && _roleMatches(doc, role)) {
        return doc.id;
      }
    }
    return null;
  }

  /// All `auth.uid`s (the `users` doc-ids) carrying the `role` [role] — the
  /// directory's "who are the stores / couriers / managers" query. Empty when
  /// none match (or no backend). Order follows document order; duplicates are
  /// impossible (doc-ids are unique).
  Future<List<String>> uidsByRole(String role) async {
    final out = <String>[];
    for (final doc in await _readAllFrom(_directory ?? _source)) {
      if (doc.data[kUsersRoleField] == role) out.add(doc.id);
    }
    return List.unmodifiable(out);
  }
}

/// The directory — null when Firebase is not initialised (the entire
/// Firebase-free test suite + this sandbox), so nothing can ever touch
/// `FirebaseFirestore.instance` there. The SAME `useFirebaseBackend` gate the
/// repository providers and `usersProfileWriterProvider` use; pointed at the
/// same `users` collection. A7 only EXPOSES this — A4/A8 wire it in next.
/// Tests override this (or construct [UsersLookup] directly) with a fake source.
final usersLookupProvider = Provider<UsersLookup?>((ref) {
  // 🌉 מצב-מסונן (שלב D · חלק 2): המילון (directory) דרך הגשר — כך הלקוח מפענח
  // את ה-uid של הצד-השני ובונה את **אותו** dmThreadId (uids-ממוינים) כמו המנהל,
  // במקום שרשור-כפול. ‏users חסום ל-Rules של קבלן ⇒ REST מחזיר ריק (לא-נורא;
  // המילון הוא מקור-הפענוח). כבוי ⇒ SDK (byte-identical).
  final rest = ref.watch(filteredFirestoreProvider);
  if (rest != null) {
    return UsersLookup(
      EdgeRestCollectionSource('users', rest),
      directorySource: EdgeRestCollectionSource('directory', rest),
    );
  }
  if (useFirebaseBackend) {
    return UsersLookup(
      FirestoreCollectionSource('users'),
      directorySource: FirestoreCollectionSource('directory'),
    );
  }
  return null;
});
