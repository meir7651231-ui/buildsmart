// ─────────────────────────────────────────────────────────────────────────────
// users_repository — U0.2 (user-system foundation): the `users/{uid}` repo.
//
// WHAT THIS IS: the server-ready seam for the unified [BsUser] identity, mirroring
// every other data-layer repo (orders/customers/…): ONE sync [UsersRepository]
// contract with two interchangeable impls behind [usersRepositoryProvider] —
//   • [LocalUsersRepository]  — in-memory, born EMPTY (U0 forbids seeding real
//     user data). The Firebase-free path (the whole test suite + the sandbox).
//   • [FirestoreUsersRepository] — extends the offline-first [FirestoreCachedRepo]
//     base, SCOPED TO THE SIGNED-IN UID (`where(documentId == uid)`) so a regular
//     user reads ONLY their own doc — exactly what the users read rule proves
//     (`read: own || isAdmin`). A whole-collection listen would be DENIED for a
//     non-admin, so the scope is load-bearing, not an optimisation.
//
// GATED + DORMANT (byte-identity): [usersRepositoryProvider] returns the Firestore
// impl ONLY under `kUserSystem && useFirebaseBackend`. With [kUserSystem]
// const-false (every normal build) the Firestore branch is dead code → tree-shaken,
// and NO live surface watches this provider yet (the U0.3 call-sites are equally
// gated) → the OFF build is BYTE-IDENTICAL to today. `useFirebaseBackend` is ANDed
// too, so it can never touch Firestore offline / in tests.
//
// RULES-SAFE WRITES (firestore.rules users block + U0.4): a client self-write may
// NEVER carry `role`/`roles`/`storeUid`/`orgId`, and may only set `status` to
// `pending` on CREATE. So the two client write paths build EXPLICIT partial maps —
// [ensureUser] a create ({displayName,phone,email,status:'pending',timestamps}),
// [touchLastSeen] an update ({lastSeen} only) — instead of the full [BsUser.toDoc]
// (which is kept for the local cache round-trip + a privileged manager/admin write).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/board_accounts_local.dart' show isOwnerEmail;
import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/edge/filtered_mode.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sync repository contract for `users/{uid}`. Every method is synchronous
/// over the born-seeded cache (the [FirestoreCachedRepo] bridge) EXCEPT
/// [ensureUser], whose create is a genuine "does-it-exist-then-write" round-trip.
abstract class UsersRepository {
  /// The signed-in user's record, or null when unknown / signed-out.
  BsUser? currentUser();

  /// The record for [uid], or null when not present.
  BsUser? byUid(String uid);

  /// Author-write the WHOLE record (a privileged manager/admin path — a client
  /// self-write goes through [ensureUser]/[touchLastSeen], which are rules-safe).
  void upsertUser(BsUser user);

  /// CREATE-IF-ABSENT: when no doc exists for `seed.uid`, create it with
  /// `status: pending` (all-by-approval). NEVER clobbers an existing record — a
  /// returning user's server-assigned status/role/store is preserved.
  Future<void> ensureUser(BsUser seed);

  /// Refresh `lastSeen` for [uid] to [at]. A no-op when the record is unknown
  /// locally; on the server it is an update touching ONLY `lastSeen`.
  void touchLastSeen(String uid, DateTime at);
}

/// The in-memory implementation — the Firebase-free path + tests. Born EMPTY
/// (U0 forbids seeding real user data); the app's identity fills it at runtime.
class LocalUsersRepository implements UsersRepository {
  LocalUsersRepository({String? currentUid}) : _currentUid = currentUid;

  final String? _currentUid;
  final Map<String, BsUser> _byUid = <String, BsUser>{};

  @override
  BsUser? byUid(String uid) => _byUid[uid];

  @override
  BsUser? currentUser() {
    final uid = _currentUid;
    return uid == null ? null : _byUid[uid];
  }

  @override
  void upsertUser(BsUser user) => _byUid[user.uid] = user;

  @override
  Future<void> ensureUser(BsUser seed) async {
    // putIfAbsent → never clobber an existing record (idempotent re-login).
    _byUid.putIfAbsent(seed.uid, () => seed);
  }

  @override
  void touchLastSeen(String uid, DateTime at) {
    final existing = _byUid[uid];
    if (existing != null) _byUid[uid] = existing.copyWith(lastSeen: at);
  }
}

/// The Firestore implementation — the offline-first cache base, scoped to the
/// signed-in uid so the listen is one the `users` read rule can prove. The cache
/// therefore holds AT MOST the one self-record; [currentUser] serves it sync.
class FirestoreUsersRepository extends FirestoreCachedRepo<BsUser>
    implements UsersRepository {
  FirestoreUsersRepository(this._source, {required this.currentUid})
      : super(_source);

  /// Kept alongside the base's private copy so this subclass can issue the
  /// rules-safe PARTIAL writes ([ensureUser]/[touchLastSeen]) the generic
  /// `upsert` (full [toDoc]) cannot.
  final RemoteCollectionSource _source;

  /// The signed-in uid the source is scoped to — [currentUser] keys on it.
  final String currentUid;

  // ── FirestoreCachedRepo<BsUser> contract ───────────────────────────────────

  @override
  List<BsUser> get seed => const <BsUser>[]; // no demo seed — honest empty

  @override
  String idOf(BsUser value) => value.uid;

  @override
  BsUser fromDoc(RemoteDoc doc) => BsUser.fromJson(doc.id, doc.data);

  @override
  Map<String, dynamic> toDoc(BsUser value) => value.toDoc();

  // ── UsersRepository ────────────────────────────────────────────────────────

  @override
  BsUser? byUid(String uid) {
    for (final u in cached()) {
      if (u.uid == uid) return u;
    }
    return null;
  }

  @override
  BsUser? currentUser() {
    final mine = byUid(currentUid);
    if (mine != null) return mine;
    // Scoped to `documentId == uid` → at most one doc; serve it if the uid field
    // and the doc-id ever disagree (they should not).
    final all = cached();
    return all.isEmpty ? null : all.first;
  }

  @override
  void upsertUser(BsUser user) => upsert(user); // full author write (manager/admin)

  @override
  Future<void> ensureUser(BsUser seed) async {
    if (byUid(seed.uid) != null) return; // exists — never clobber server truth
    await guardWrite(() => _source.set(seed.uid, _createDoc(seed)));
  }

  @override
  void touchLastSeen(String uid, DateTime at) {
    // Update touching ONLY `lastSeen` — passes the users update rule (which
    // freezes role/roles/storeUid/orgId/status). merge:true leaves all else intact.
    guardWrite(
      () => _source.set(uid, {'lastSeen': at.millisecondsSinceEpoch}),
    );
  }

  /// The rules-safe CREATE map for a client self-create: display identity +
  /// timestamps, `status` PINNED to `pending` (all-by-approval — the rule allows
  /// only `pending` on create), and DELIBERATELY no `role`/`storeUid`/`orgId`.
  static Map<String, dynamic> _createDoc(BsUser u) => <String, dynamic>{
        if (u.name.isNotEmpty) 'displayName': u.name,
        if (u.phone != null && u.phone!.isNotEmpty) 'phone': u.phone,
        if (u.email != null && u.email!.isNotEmpty) 'email': u.email,
        'status': UserStatus.pending.wire,
        if (u.createdAt != null) 'createdAt': u.createdAt!.millisecondsSinceEpoch,
        if (u.lastSeen != null) 'lastSeen': u.lastSeen!.millisecondsSinceEpoch,
      };
}

/// The users repository provider — the server-ready seam the U0.3 login sync
/// flows through. Returns the Firestore-backed, uid-scoped impl ONLY under
/// `kUserSystem && useFirebaseBackend` with a known uid; otherwise the in-memory
/// [LocalUsersRepository]. With [kUserSystem] const-false the Firestore branch is
/// dead code (tree-shaken) and, since no live surface watches this yet, the OFF
/// build is byte-identical. (Copies the `customersRepositoryProvider` switch.)
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (kUserSystem && useFirebaseBackend && uid != null && uid.isNotEmpty) {
    final source = FirestoreCollectionSource(
      'users',
      scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
    );
    final repo = FirestoreUsersRepository(source, currentUid: uid)..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalUsersRepository(currentUid: uid);
});

/// The signed-in [BsUser], or null. Dormant with [kUserSystem] OFF (the local
/// repo is empty → always null → zero regression).
///
/// LISTENS to the repository, not just to which repository is in use. Watching
/// [usersRepositoryProvider] alone only re-runs when the repo INSTANCE changes —
/// i.e. on login/logout — so a change to the user's own document was never seen:
/// the value was computed once at sign-in and cached from then on.
///
/// What that cost in practice: an admin activates a waiting account, the server
/// document flips to `active`, and the person keeps looking at "ממתין לאישור"
/// with the app still locked down — believing it, and with no reason to try
/// again. The status only caught up on a full app restart.
///
/// [FirestoreCachedRepo] is a [ChangeNotifier] that fires on every snapshot
/// (that is what its class doc means by "a thin Riverpod provider can listen"),
/// so subscribing is all that was missing. `invalidateSelf` re-reads the cache
/// and pushes the new value to every watcher — the banner disappears and the
/// app unlocks the moment approval lands, with nothing for the user to do.
///
/// The local (Firebase-free) repo is not a notifier; the type check keeps that
/// path exactly as it was.
final currentUserProvider = Provider<BsUser?>((ref) {
  final repo = ref.watch(usersRepositoryProvider);
  if (repo case final ChangeNotifier notifier) {
    void onRemoteChange() => ref.invalidateSelf();
    notifier.addListener(onRemoteChange);
    ref.onDispose(() => notifier.removeListener(onRemoteChange));
  }
  // The AUTH email (the signed-in Google identity) is the authoritative owner
  // signal — the `users/{uid}` DOC may not carry an email (ensureUser writes it
  // only when the seed had one; a phone/other-path registration leaves it blank),
  // so keying only on the doc email missed the owner. Pass the auth email too.
  final auth = ref.watch(authStateProvider);
  final authEmail = auth.user?.email;
  var u = withOwnerApproval(repo.currentUser(), authEmail);
  // 🌉 מצב-מסונן: תפקיד-שרת מה-claim ⇒ active (השער לא זורק חזרה להרשמה).
  // מגודר במצב-מסונן ⇒ לא-מסונן ביט-זהה (שם ה-doc נקרא ומספק את הסטטוס האמיתי).
  if (ref.watch(filteredModeProvider)) {
    u = withServerRoleApproval(
      u,
      uid: auth.user?.uid,
      roles: auth.roles,
      email: authEmail,
    );
  }
  return u;
});

/// The OWNER (verified email) is inherently approved — the bootstrap admin.
/// Their `users/{uid}` doc can lag at `pending` (the 2026-07-19 bootstrap set the
/// admin claim + role but never flipped the status), which — because the pending
/// gate blocks EVERY action even for an admin (`permitAction`, by design) — locks
/// the superuser out of the whole app and HIDES the approve action, so they can
/// approve NO ONE (the first-admin chicken-and-egg, surfaced live). This forces
/// `active` for the owner so the pending gate never traps them. Recognised by the
/// DOC email OR the [authEmail] (the un-spoofable signed-in Google identity — the
/// doc email can be blank), so no other account is affected; a non-owner (or an
/// already-active / null user) is returned verbatim. Pure — unit-tested.
BsUser? withOwnerApproval(BsUser? user, [String? authEmail]) {
  if (user != null &&
      user.status == UserStatus.pending &&
      (isOwnerEmail(user.email) || isOwnerEmail(authEmail))) {
    return user.copyWith(status: UserStatus.active);
  }
  return user;
}

/// 🌉 מצב-מסונן — אישור-תפקיד = custom-claim ב-idToken (נקרא בלי Firestore).
/// בקו-מסונן ה-doc של `users/{uid}` לא-נקרא (אין live-snapshot) ⇒ הסטטוס נשאר
/// null/pending והשערים (הזמנה וכו') זורקים חזרה להרשמה — למרות שהמנהל אישר.
/// כאן: יש **תפקיד-שרת** (מה-claim) ⇒ המשתמש פעיל: מסנתז active כשה-doc חסר,
/// או משדרג pending→active. אין תפקיד ⇒ ללא-שינוי (זהה-התנהגות). טהור.
BsUser? withServerRoleApproval(
  BsUser? user, {
  required String? uid,
  required List<String> roles,
  String? email,
}) {
  if (roles.isEmpty || uid == null || uid.isEmpty) return user;
  final role = roles.first;
  if (user == null) {
    return BsUser(
      uid: uid,
      email: email,
      role: role,
      status: UserStatus.active,
    );
  }
  if (user.status == UserStatus.pending) {
    return user.copyWith(
      status: UserStatus.active,
      role: user.role.isEmpty ? role : user.role,
    );
  }
  return user;
}
