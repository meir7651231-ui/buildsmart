// ─────────────────────────────────────────────────────────────────────────────
// user_system_sync — U0.3 (user-system foundation): profile ↔ server wiring.
//
// WHAT THIS DOES: on a REGISTERED login it makes the unified `users/{uid}` record
// real — CREATE it (born `status: pending`, all-by-approval) when it does not yet
// exist, and refresh `lastSeen` on every entry. It is the bridge from the
// on-device [UserProfile] (what the welcome flow already collected) to the typed
// server [BsUser], routed through the rules-safe [UsersRepository] writes.
//
// TWO LOCKED RULES it honours (SPEC-user-system §"הקשר-החלטות"):
//   • ANONYMOUS GUESTS are never written to `users` — a catalog-browsing guest
//     (anon-auth) is not a user record. [onRegisteredLogin] short-circuits on
//     `isAnonymous`.
//   • A returning user is NEVER downgraded — [UsersRepository.ensureUser] is
//     create-if-absent, so a server-assigned `status`/`role`/`storeUid` survives
//     a re-login; only `lastSeen` moves.
//
// DORMANT (byte-identity): the SINGLE live call-site (welcome_screen
// `_finishAfterAuth`) is compile-gated `if (kUserSystem)`, so with the flag
// const-false this provider + [UserSystemSync] tree-shake away → byte-identical.
// The core is a pure function over the [UsersRepository] contract, so it
// unit-tests against [LocalUsersRepository] with zero backend.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PURE — the create-seed for a registered login: a `pending` [BsUser] derived
/// from the on-device [profile], stamped [now] for both `createdAt` and
/// `lastSeen`. Unit-testable in isolation (no repo, no clock).
BsUser buildLoginSeed({
  required String uid,
  required UserProfile profile,
  required DateTime now,
}) =>
    // status defaults to UserStatus.pending (all-by-approval) in fromProfile.
    BsUser.fromProfile(
      profile,
      uid: uid,
      createdAt: now,
      lastSeen: now,
    );

/// The login → `users/{uid}` synchroniser. Holds only the repository contract, so
/// a test drives it with [LocalUsersRepository] and asserts the writes.
class UserSystemSync {
  UserSystemSync(this._repo);

  final UsersRepository _repo;

  /// On a REGISTERED login: ensure `users/{uid}` exists (create born `pending`
  /// when new — never clobbering an existing record) and refresh `lastSeen`.
  /// Anonymous guests and empty uids are SKIPPED — they are not user records.
  Future<void> onRegisteredLogin({
    required String uid,
    required UserProfile profile,
    required bool isAnonymous,
    required DateTime now,
  }) async {
    if (isAnonymous || uid.isEmpty) return;
    await _repo.ensureUser(buildLoginSeed(uid: uid, profile: profile, now: now));
    _repo.touchLastSeen(uid, now);
  }
}

/// The sync provider — dormant with `kUserSystem` OFF (its only call-site is
/// compile-gated). Reads the current [UsersRepository] (local or the uid-scoped
/// Firestore impl).
final userSystemSyncProvider = Provider<UserSystemSync>((ref) {
  return UserSystemSync(ref.watch(usersRepositoryProvider));
});
