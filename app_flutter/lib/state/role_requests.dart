// ─────────────────────────────────────────────────────────────────────────────
// #6 — role requests (client side). A signed-in backend user asks for an
// OPERATIONAL role by writing roleRequests/{uid} (status: pending); the
// matrix-designated approver reviews it server-side (reviewRoleRequest). This
// module is the WRITE/READ seam + the submit/cancel helpers; the request UI
// (role_request_sheet.dart) and the approval inbox consume it.
//
// HARD RULE (mirrors every data seam): no Firebase touch without the live
// backend — the providers gate on `useFirebaseBackend`, so the whole
// Firebase-free test suite + the demo build get null and never touch Firestore.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/bs_user.dart' show UserStatus;
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_repository.dart'
    show currentUserProvider;
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldPath;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four OPERATIONAL roles a user may request (#6). `manager`/`admin` are
/// NEVER self-requestable — they are assigned, not requested. This list is the
/// client mirror of the server's APPROVER_FOR keys (functions/reviewRoleRequest).
const List<String> kRequestableRoles = [
  'worker',
  'courier',
  'store',
  'contractor',
];

/// The `roleRequests` collection seam (write a request by doc-id = uid; read
/// own/scoped). Null when Firebase is not initialised (tests + demo) — the SAME
/// `useFirebaseBackend` gate every repo/`usersProfileWriterProvider` uses.
/// Tests override this with a fake [RemoteCollectionSource].
final roleRequestWriterProvider = Provider<RemoteCollectionSource?>((ref) {
  if (useFirebaseBackend) return FirestoreCollectionSource('roleRequests');
  return null;
});

/// Submit a pending role request for the signed-in user (doc-id = their uid).
/// Returns false (no-op) Firebase-free / signed-out. Any prior request is
/// cleared first (delete → set) so a re-request after a denial starts clean —
/// the create rule forbids carrying stale reviewer fields.
Future<bool> submitRoleRequest(WidgetRef ref, String role) async {
  final writer = ref.read(roleRequestWriterProvider);
  final uid = ref.read(currentUidProvider);
  if (writer == null || uid == null || !kRequestableRoles.contains(role)) {
    return false;
  }
  final p = ref.read(userProfileProvider);
  try {
    // Clear any prior request FIRST so a re-request after a denial starts from a
    // fresh CREATE — NOT a merge:true write onto stale reviewer fields (which the
    // create rule would then reject). NOT swallowed: if the delete fails
    // (offline/denied) we bail to false, since the follow-up set would be a
    // denied update anyway. A delete on a non-existent doc is a no-op (first
    // request is unaffected).
    await writer.delete(uid);
    await writer.set(uid, <String, dynamic>{
      'requestedRole': role,
      'status': 'pending',
      if (p.name.isNotEmpty) 'displayName': p.name,
      if (p.contact.isNotEmpty) 'phone': p.contact,
      'requestedAt': DateTime.now().toIso8601String(),
    });
    return true;
  } on Object catch (e) {
    // A network / permission-denied write must surface as a clean "couldn't
    // send" (false → the sheet shows the Hebrew error + clears its spinner),
    // never throw past the caller and leave the sheet stuck busy.
    debugPrint('submitRoleRequest failed: $e');
    return false;
  }
}

// ── approval side (#6 inc.3) ─────────────────────────────────────────────────

/// PURE client mirror of the server matrix (functions/reviewRoleRequest's
/// APPROVER_FOR, inverted): which requested-roles a caller holding [claimRoles]
/// may review. admin reviews everything; otherwise contractor→worker,
/// store→courier, manager→store+contractor. Empty ⇒ this caller approves
/// nothing (no inbox). The SERVER + S5 rules are the real authority — this only
/// scopes the client's read so it matches what the rule (`canReview`) allows.
List<String> approvableRolesForClaims(List<String> claimRoles) {
  if (claimRoles.contains('admin')) return kRequestableRoles;
  final out = <String>[];
  if (claimRoles.contains('contractor')) out.add('worker');
  if (claimRoles.contains('store')) out.add('courier');
  if (claimRoles.contains('manager')) {
    out
      ..add('store')
      ..add('contractor');
  }
  return out;
}

/// The `roleRequests` listen SCOPED to the tier the signed-in caller may review
/// (status == pending). Null Firebase-free, or when the caller approves nothing
/// — so the inbox never issues a query the rules would deny. Uses the real claim
/// roles (authStateProvider), NOT the null-collapsed persona.
final roleRequestsInboxProvider = Provider<RemoteCollectionSource?>((ref) {
  if (!useFirebaseBackend) return null;
  final approvable = approvableRolesForClaims(ref.watch(authStateProvider).roles);
  if (approvable.isEmpty) return null;
  return FirestoreCollectionSource(
    'roleRequests',
    scope: (c) => c
        .where('requestedRole', whereIn: approvable)
        .where('status', isEqualTo: 'pending'),
  );
});

/// The live pending requests the caller may review (empty stream when the inbox
/// source is null — Firebase-free / approves-nothing).
final pendingRoleRequestsProvider = StreamProvider<List<RemoteDoc>>((ref) {
  final src = ref.watch(roleRequestsInboxProvider);
  if (src == null) return Stream<List<RemoteDoc>>.value(const []);
  return src.snapshots();
});

/// Seam over the `reviewRoleRequest` callable — a function so tests inject a
/// fake (the real impl needs FirebaseFunctions, which a Firebase-free test can't
/// construct). The SERVER enforces the matrix; this just forwards the decision.
typedef RoleReviewer = Future<void> Function(
  String uid, {
  required bool approve,
});

/// The reviewer — null Firebase-free (tests override with a fake). Region must
/// match the function (kAuthFunctionsRegion = me-west1).
final roleReviewerProvider = Provider<RoleReviewer?>((ref) {
  if (!useFirebaseBackend) return null;
  final functions = FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);
  return (String uid, {required bool approve}) =>
      functions.httpsCallable('reviewRoleRequest').call<dynamic>(
        <String, String>{'uid': uid, 'decision': approve ? 'approve' : 'deny'},
      );
});

// ── registration approval (owner-driven account activation) ──────────────────

/// Seam over the `approveUsers` callable (registration approval) — a function so
/// tests inject a fake (the real impl needs FirebaseFunctions, which a
/// Firebase-free test can't construct). Bulk-activates the given uids:
/// `approve: true` flips `users.status` pending→active (unblocks checkout),
/// `false` reverts to pending. Returns the server's acted `count`.
typedef UserApprover = Future<int> Function(
  List<String> uids, {
  required bool approve,
});

/// The user-approver — null Firebase-free / demo (byte-identical when off, like
/// every seam here), so the approval panel is inert without the live backend.
/// Region must match the function (kAuthFunctionsRegion = me-west1), exactly like
/// [roleReviewerProvider] above. The SERVER enforces the manager/admin auth
/// (callerRoles); this only forwards the batch and reads back `count`.
final userApproverProvider = Provider<UserApprover?>((ref) {
  if (!useFirebaseBackend) return null;
  final functions = FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);
  return (List<String> uids, {required bool approve}) async {
    final res = await functions.httpsCallable('approveUsers').call<dynamic>(
      <String, dynamic>{'uids': uids, 'approve': approve},
    );
    final data = res.data;
    if (data is Map && data['count'] is int) return data['count'] as int;
    // The call resolved but returned no count — fall back to the requested size.
    return uids.length;
  };
});

// ── account removal (manager-driven user deletion) ───────────────────────────

/// Seam over the `deleteUser` callable (manager-driven account removal) — a
/// function so tests inject a fake (the real impl needs FirebaseFunctions, which
/// a Firebase-free test can't construct). Deletes the user identified by [uid].
typedef UserDeleter = Future<void> Function(String uid);

/// The user-deleter — null Firebase-free / demo (byte-identical when off, like
/// every seam here), so the delete control is inert without the live backend.
/// Region must match the function (kAuthFunctionsRegion = me-west1), exactly like
/// [userApproverProvider] above. The SERVER enforces the manager/admin auth
/// (callerRoles); this only forwards the uid.
final userDeleterProvider = Provider<UserDeleter?>((ref) {
  if (!useFirebaseBackend) return null;
  final functions = FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);
  return (String uid) async {
    await functions.httpsCallable('deleteUser').call<dynamic>(
      <String, dynamic>{'uid': uid},
    );
  };
});

/// Set true by the registration flow (`WelcomeScreen._finishAfterAuth`) the
/// moment a NEW user finishes registering, so the shell opens the role-request
/// sheet ONCE — "בקשת תפקיד במסך אחד אחרי הרשמה". The shell resets it after
/// showing the sheet (a one-shot latch, not persisted). Registration no longer
/// auto-files a 'contractor' request behind the user's back; they choose.
final promptRoleRequestProvider = StateProvider<bool>((_) => false);

// ── status chip under the logo (replaces the pending banner) ─────────────────

/// The four lifecycle states shown as the status chip beneath the logo — the
/// user asked for exactly these, in place of the old "ממתין לאישור" banner:
///   🟠 [needsRegistration] · 🟡 [inProcess] · 🟢 [approved] · 🔴 [rejected].
enum RoleChipState { needsRegistration, inProcess, approved, rejected }

/// PURE mapping to the chip, from signals the app already holds. Order matters:
///   • not a REGISTERED (real, non-anonymous) user      → 🟠 needsRegistration
///   • account already active / holds a server role /
///     own request approved                              → 🟢 approved
///   • own roleRequest was denied                        → 🔴 rejected
///   • own roleRequest is pending                        → 🟡 inProcess
///   • registered but never requested a role             → 🟠 needsRegistration
/// Firebase-free (no request doc) a registered user reads as needsRegistration —
/// they still have to request a role, which is the honest prompt.
RoleChipState roleChipStateFor({
  required bool isRegistered,
  required bool isActive,
  required bool hasServerRole,
  required String? requestStatus,
}) {
  if (!isRegistered) return RoleChipState.needsRegistration;
  if (isActive || hasServerRole || requestStatus == 'approved') {
    return RoleChipState.approved;
  }
  if (requestStatus == 'denied') return RoleChipState.rejected;
  if (requestStatus == 'pending') return RoleChipState.inProcess;
  return RoleChipState.needsRegistration;
}

/// The `roleRequests` listen SCOPED to the caller's OWN doc (doc-id == uid) — the
/// `read: own` branch of the rule. Null Firebase-free / signed-out. Distinct from
/// [roleRequestsInboxProvider] (the approver's tier view).
final myRoleRequestSourceProvider = Provider<RemoteCollectionSource?>((ref) {
  if (!useFirebaseBackend) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null || uid.isEmpty) return null;
  return FirestoreCollectionSource(
    'roleRequests',
    scope: (c) => c.where(FieldPath.documentId, isEqualTo: uid),
  );
});

/// The caller's own role request doc (or null when none / Firebase-free). Live —
/// so the chip flips 🟡→🟢/🔴 the moment an approver decides, with no reload.
final myRoleRequestProvider = StreamProvider<RemoteDoc?>((ref) {
  final src = ref.watch(myRoleRequestSourceProvider);
  if (src == null) return Stream<RemoteDoc?>.value(null);
  return src.snapshots().map((docs) => docs.isEmpty ? null : docs.first);
});

/// The live status chip state under the logo. Composes the pure [roleChipStateFor]
/// over auth (registration), the users doc (active), server claims, and the own
/// request doc. Watched only under `kUserSystem` at the call-site → OFF build
/// byte-identical.
final roleChipStateProvider = Provider<RoleChipState>((ref) {
  final auth = ref.watch(authStateProvider);
  final status = ref.watch(currentUserProvider)?.status;
  final req = ref.watch(myRoleRequestProvider).valueOrNull;
  return roleChipStateFor(
    isRegistered: auth.user?.isRealUser ?? false,
    isActive: status == UserStatus.active,
    hasServerRole: auth.roles.isNotEmpty,
    requestStatus: req?.data['status'] as String?,
  );
});

/// Owner/admin bulk-clear: delete EVERY pending role request the caller can see
/// (their inbox tier). The rule allows an admin to delete any roleRequests doc,
/// so the owner (admin=any tier) clears the whole pending queue. Returns the count
/// deleted. No-op Firebase-free / empty. A single failed delete is skipped, not
/// fatal — a best-effort sweep.
Future<int> clearAllRoleRequests(WidgetRef ref) async {
  final writer = ref.read(roleRequestWriterProvider);
  final docs = ref.read(pendingRoleRequestsProvider).valueOrNull ?? const [];
  if (writer == null || docs.isEmpty) return 0;
  var deleted = 0;
  for (final d in docs) {
    try {
      await writer.delete(d.id);
      deleted++;
    } on Object catch (e) {
      debugPrint('clearAllRoleRequests: skip ${d.id}: $e');
    }
  }
  return deleted;
}
