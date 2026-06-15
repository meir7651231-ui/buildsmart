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
