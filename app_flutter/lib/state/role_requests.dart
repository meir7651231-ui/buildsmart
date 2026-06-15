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

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  await writer.delete(uid).catchError((Object _) {});
  await writer.set(uid, <String, dynamic>{
    'requestedRole': role,
    'status': 'pending',
    if (p.name.isNotEmpty) 'displayName': p.name,
    if (p.contact.isNotEmpty) 'phone': p.contact,
    'requestedAt': DateTime.now().toIso8601String(),
  });
  return true;
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
