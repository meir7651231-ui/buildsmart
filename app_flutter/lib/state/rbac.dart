// ─────────────────────────────────────────────────────────────────────────────
// rbac — U1 (user-system): the TYPED role-based access-control layer.
//
// WHY THIS EXISTS (SPEC-user-system §U1): today authorization is split across
// string spaces — the `roleProvider` persona string (auth_state.dart, the Studio's
// visibility floor keys on it) and the fine-grained string `kRbacMatrix` /
// `requirePerm` (finance_hub_state.dart). U1 adds ONE typed vocabulary — [BsRole]
// + [Permission] + [roleToPermissions] — so app-wide gates check a compile-checked
// enum instead of a stringly-typed key, WITHOUT replacing either existing string
// space (both keep working — landmines, see below).
//
// THREE LANDMINES this layer is built AROUND (verified against live 079c5cbf):
//   1. `roleProvider` STRING space — the Studio role-visibility floor
//      (logic/studio/edit_safety.dart) computes over it, "never that enum". So
//      [bsRoleProvider] DERIVES from the auth claims; it does NOT touch, replace,
//      or feed `roleProvider`. The Studio is untouched.
//   2. `requirePerm` / `kRbacMatrix` / `canDo` (finance_hub_state.dart) WORK and
//      the finance hub depends on them — so this file ADDS a parallel typed
//      enforcement ([requirePermission]) and leaves the string path byte-identical.
//      The two are DIFFERENT ALTITUDES (this is the coarse app-wide vocabulary;
//      `kRbacMatrix` is the finance-hub's fine detail) and DELIBERATELY not merged
//      — they coexist without contradiction, neither replaces the other.
//   3. `setRole` (functions/src/index.ts) is ALREADY admin-only + audited — so
//      role ASSIGNMENT is a verified server concern, not re-implemented here.
//
// SERVER-AUTHORITATIVE: [bsRoleProvider] reads the SERVER claim (or the owner
// email for admin) — never the client persona PICK. A signed-out guest is always
// [BsRole.contractor] (catalog-view only, decision #2), whatever persona the
// picker shows. This is the security boundary: authorization ≠ what the UI shows.
//
// DORMANT until wired: no live surface consumes these symbols yet (the gated U1
// call-sites land next), so with nothing referencing this file the whole layer
// tree-shakes out → byte-identical. Pure helpers ([hasPermission], [permitAction],
// [roleFromClaim], [claimOf]) unit-test with zero Riverpod.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/board_accounts_local.dart' show isOwnerEmail;
import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/finance_hub_state.dart' show auditTrailProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// U1.1.1 — the typed role space. Superset of `kPersonas` (contractor/store/
/// courier/worker/manager) + `admin` (the bootstrap `admin:true` claim / owner).
/// `contractor` is the DEFAULT / least-privilege role (an unknown or absent claim
/// resolves here — see [roleFromClaim]).
enum BsRole { contractor, store, courier, worker, manager, admin }

/// U1.1.2 — the typed permission space: the COARSE app-wide capabilities gates
/// check. (The finer `kRbacMatrix` strings stay for the finance-hub detail — this
/// is a higher-altitude vocabulary, kept consistent with it by a test.)
enum Permission {
  viewCatalog,
  placeOrder,
  advanceOrder,
  editInventory,
  manageStore,
  approveOrder,
  manageUsers,
  assignRole,
  editStudio,
}

/// U1.1.3 — the ONE central role→permissions map (deny-by-default: a pair absent
/// here is denied). Every role may [Permission.viewCatalog] (the catalog is open
/// — decision #2). `assignRole` is [BsRole.admin] ONLY (mirrors `setRole`'s
/// admin-claim gate); `editStudio` is manager/admin. This is the coarse app-wide
/// vocabulary — a separate altitude from the finance-hub's fine `kRbacMatrix`.
const Map<BsRole, Set<Permission>> roleToPermissions = <BsRole, Set<Permission>>{
  BsRole.contractor: <Permission>{
    Permission.viewCatalog,
    Permission.placeOrder,
  },
  BsRole.store: <Permission>{
    Permission.viewCatalog,
    Permission.advanceOrder,
    Permission.editInventory,
    Permission.manageStore,
  },
  BsRole.courier: <Permission>{
    Permission.viewCatalog,
    Permission.advanceOrder,
  },
  BsRole.worker: <Permission>{
    Permission.viewCatalog,
  },
  BsRole.manager: <Permission>{
    Permission.viewCatalog,
    Permission.placeOrder,
    Permission.advanceOrder,
    Permission.editInventory,
    Permission.manageStore,
    Permission.approveOrder,
    Permission.manageUsers,
    Permission.editStudio,
  },
  BsRole.admin: <Permission>{
    Permission.viewCatalog,
    Permission.placeOrder,
    Permission.advanceOrder,
    Permission.editInventory,
    Permission.manageStore,
    Permission.approveOrder,
    Permission.manageUsers,
    Permission.assignRole,
    Permission.editStudio,
  },
};

/// U1.1.4 — decode a `role` claim string into [BsRole]. `null` / `''` / an
/// unknown value → [BsRole.contractor] (the default persona / least privilege —
/// an exotic claim can NEVER escalate). Total, pure.
BsRole roleFromClaim(String? claim) {
  switch (claim?.trim()) {
    case 'store':
      return BsRole.store;
    case 'courier':
      return BsRole.courier;
    case 'worker':
      return BsRole.worker;
    case 'manager':
      return BsRole.manager;
    case 'admin':
      return BsRole.admin;
    default:
      return BsRole.contractor;
  }
}

/// U1.1.4 — the inverse: the canonical claim string for [role]. Round-trips with
/// [roleFromClaim] (`roleFromClaim(claimOf(r)) == r` for every role).
String claimOf(BsRole role) {
  switch (role) {
    case BsRole.contractor:
      return 'contractor';
    case BsRole.store:
      return 'store';
    case BsRole.courier:
      return 'courier';
    case BsRole.worker:
      return 'worker';
    case BsRole.manager:
      return 'manager';
    case BsRole.admin:
      return 'admin';
  }
}

/// U1.3.1 — the pure permission check (deny-by-default). No Riverpod, no status —
/// just "does this role hold this capability".
bool hasPermission(BsRole role, Permission perm) =>
    roleToPermissions[role]?.contains(perm) ?? false;

/// U1.5.1 — the pure ACTION gate, combining role + approval [status]. A user who
/// is NOT yet approved (`pending`) or is `suspended` may ONLY
/// [Permission.viewCatalog] (the catalog is open — decision #2); every other
/// action is blocked regardless of role, until an admin activates them
/// (all-by-approval). An `active` or unknown (`null`, e.g. kUserSystem OFF /
/// pre-U0) status defers entirely to [hasPermission] — the zero-regression path.
bool permitAction({
  required BsRole role,
  required Permission perm,
  required UserStatus? status,
}) {
  if (perm != Permission.viewCatalog &&
      (status == UserStatus.pending || status == UserStatus.suspended)) {
    return false;
  }
  return hasPermission(role, perm);
}

/// U1.2 — the PURE decision behind [bsRoleProvider] (testable without Riverpod):
///   • not signed in (guest) → [BsRole.contractor] (catalog-view only — decision
///     #2; the persona PICK is NOT authorization);
///   • the owner's verified email → [BsRole.admin] (admin today = `kOwnerEmails`);
///   • exactly ONE server role → that typed role (persona = identity);
///   • signed-in with 0 or many server roles → [BsRole.contractor] (least
///     privilege — an undecided identity never escalates).
BsRole bsRoleFrom({
  required bool signedIn,
  required String? email,
  required List<String> serverRoles,
}) {
  if (!signedIn) return BsRole.contractor;
  if (isOwnerEmail(email)) return BsRole.admin;
  if (serverRoles.length == 1) return roleFromClaim(serverRoles.first);
  return BsRole.contractor;
}

/// U1.2 — the SERVER-AUTHORITATIVE typed role, over [authStateProvider]. NEVER
/// reads/writes the `roleProvider` string space (landmine #1 — the Studio owns
/// that). A thin wrapper over [bsRoleFrom]; dormant with nothing watching it →
/// byte-identical.
final bsRoleProvider = Provider<BsRole>((ref) {
  final auth = ref.watch(authStateProvider);
  return bsRoleFrom(
    signedIn: auth.signedIn,
    email: auth.user?.email,
    serverRoles: auth.roles,
  );
});

/// U1.5.1 — is the signed-in user blocked pending admin approval? Drives the
/// "ממתין לאישור" banner (U1.5.2). Null status (guest / kUserSystem OFF) → false.
final pendingApprovalProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.status == UserStatus.pending;
});

/// U1.3.2 — the TYPED enforcement primitive (the parallel of the string
/// `requirePerm`): resolve the caller's [BsRole] + approval status, apply
/// [permitAction], and on a DENIAL log to the SAME audit trail
/// (`auditTrailProvider`) the string path uses — one honest privilege-denial
/// record. Returns true only when the action is allowed. The existing string
/// `requirePerm` / `canDo` / `kRbacMatrix` are left byte-identical (landmine #2);
/// new U1+ gates call THIS.
bool requirePermission(WidgetRef ref, Permission perm, String label) {
  final role = ref.read(bsRoleProvider);
  final status = ref.read(currentUserProvider)?.status;
  if (permitAction(role: role, perm: perm, status: status)) return true;
  final blockedPending = perm != Permission.viewCatalog &&
      (status == UserStatus.pending || status == UserStatus.suspended);
  ref.read(auditTrailProvider.notifier).log(
        blockedPending ? 'הרשאה נדחתה (ממתין לאישור)' : 'הרשאה נדחתה',
        label,
        claimOf(role),
      );
  return false;
}

/// Why checkout is refused — or [none] when it is not.
///
/// Split out as a PURE function because the widget path cannot be tested: the
/// gate lives behind `kUserSystem`, a compile-time const that folds false in
/// every test build, so a widget test walks straight through it and proves
/// nothing about the ON path. That is exactly how the previous gate stayed
/// broken while its tests stayed green — `contractor_checkout_engine_test`
/// asserts, correctly and uselessly, that "an UNREGISTERED contractor still
/// places a live order".
enum CheckoutBlock {
  /// Allowed through.
  none,

  /// No account at all — signed out, or the anonymous catalog guest.
  notRegistered,

  /// A real account that an admin has not approved yet.
  pendingApproval,
}

/// The checkout decision, asking the SAME two questions `firestore.rules` asks
/// on an orders create, in the same order:
///
///   `isRealUser()`  → is there a person here, not just a session
///   `isActive()`    → has an admin approved them
///
/// Kept deliberately in step with those rules. The server is what enforces this
/// — a client predicate is a courtesy that turns a silent permission-denied
/// (after the cart has already been cleared) into a Hebrew sentence in front of
/// the person, with the action that resolves it.
///
/// The flag is a PARAMETER rather than a read of `kUserSystem`, so a test can
/// exercise the ON path that ships without needing the build to be ON.
CheckoutBlock checkoutBlock({
  required bool userSystemOn,
  required bool isRealUser,
  required bool isPending,
}) {
  if (!userSystemOn) return CheckoutBlock.none;
  if (!isRealUser) return CheckoutBlock.notRegistered;
  if (isPending) return CheckoutBlock.pendingApproval;
  return CheckoutBlock.none;
}
