// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Cloud Functions — S1.9 `setRole` (server-connect §S1).
//
// THE ONLY WAY A ROLE IS WRITTEN. Roles live as Firebase Auth CUSTOM CLAIMS
// (`role: contractor|manager|store|courier|worker`, or `roles: [...]` for a
// multi-role user) — never as a client-writable Firestore field. The client
// reads them via `getIdTokenResult` (lib/state/auth_state.dart, roleProvider)
// and S5 Security Rules enforce them server-side. Admin SDK creds exist ONLY
// here (SSOT warning: "creds בשרת/Functions בלבד — לעולם לא client").
//
// Caller contract (callable `setRole`, region me-west1 — must match
// `kAuthFunctionsRegion` in the app):
//   data: { uid: string, role: string }            → sets { role }
//   or:   { uid: string, roles: string[] }         → sets { roles } (multi-role)
//   auth: the CALLER must carry the `admin: true` claim (bootstrap: README).
//
// The target user sees the new claim on their next ID-token refresh (≤1h) or
// next sign-in; the app can force it via getIdTokenResult(true).
// ─────────────────────────────────────────────────────────────────────────────

import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { callerRoles } from "./common";

initializeApp();

/** The five persona ids the app knows (lib/data/personas.dart) — the client
 * filters claims to this same list, so an out-of-list role is never accepted
 * on either side. */
const VALID_ROLES = ["contractor", "manager", "store", "courier", "worker"];

interface SetRoleData {
  uid?: unknown;
  role?: unknown;
  roles?: unknown;
}

export const setRole = onCall({ region: "me-west1" }, async (request) => {
  // 1 · caller must be signed in.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const callerUid = request.auth.uid;
  const callerRolesList = callerRoles(request.auth.token);
  const { uid, role, roles } = (request.data ?? {}) as SetRoleData;
  const targetLabel =
    typeof uid === "string" && uid.length > 0 ? `users/${uid}` : "users/?";

  // 2 · caller must carry the admin claim (assigned once via the bootstrap
  //     script in the README — the chicken-and-egg first admin). A denied
  //     attempt is audit-logged (privilege-escalation trail).
  if (request.auth.token.admin !== true) {
    await writeAudit({
      action: "role.set",
      source: "setRole",
      actorUid: callerUid,
      actorRole: callerRolesList.join(",") || null,
      target: targetLabel,
      before: null,
      after: null,
      ok: false,
      reason: "admin-claim-required",
    });
    throw new HttpsError("permission-denied", "Admin claim required.");
  }

  // 3 · validate the payload: uid + a single role OR a roles list.
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "uid (string) is required.");
  }
  let roleList: string[] | null = null;
  if (Array.isArray(roles)) {
    roleList = roles.filter(
      (r): r is string => typeof r === "string" && VALID_ROLES.includes(r)
    );
    if (roleList.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        `roles must contain at least one of: ${VALID_ROLES.join(", ")}.`
      );
    }
  } else if (typeof role !== "string" || !VALID_ROLES.includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      `role must be one of: ${VALID_ROLES.join(", ")}.`
    );
  }

  // 4 · merge over the target's EXISTING claims (e.g. an admin keeps `admin`),
  //     replacing only the role surface — single `role` and multi `roles` are
  //     mutually exclusive by construction.
  const auth = getAuth();
  const target = await auth.getUser(uid); // throws not-found for a bad uid
  const claims: Record<string, unknown> = { ...(target.customClaims ?? {}) };
  delete claims.role;
  delete claims.roles;
  if (roleList) {
    claims.roles = roleList;
  } else {
    claims.role = role;
  }
  await auth.setCustomUserClaims(uid, claims);

  await writeAudit({
    action: "role.set",
    source: "setRole",
    actorUid: callerUid,
    actorRole: callerRolesList.join(",") || null,
    target: `users/${uid}`,
    before: null,
    after: roleList ? { roles: roleList } : { role },
    ok: true,
  });

  return roleList ? { ok: true, uid, roles: roleList } : { ok: true, uid, role };
});

// ─────────────────────────────────────────────────────────────────────────────
// S8 · server-side logic (SPEC-server-connect-MICRO §S8 + S7.2/S6.3) — added
// AROUND the untouched S1 `setRole` skeleton above. Load-order note: these
// re-export imports are hoisted above the `initializeApp()` call, so the
// modules resolve every Admin SDK service LAZILY inside their handlers
// (src/common.ts `db()`), never at module scope. Region: me-west1 everywhere.
//
//   S8.1  advanceOrderStage            — callable; role-checked single-step
//         revertIllegalOrderStageWrite — trigger; reverts illegal direct writes
//   S8.2  computeCredit                — callable; server-canonical credit
//   S8.3  onOrderStageChanged          — trigger; Hebrew FCM on stage step
//         onChatMessageCreated         — trigger; Hebrew FCM on new message
//   S7.2  getUploadUrl                 — callable; R2 presigned PUT (no creds
//                                        in code — Secret Manager / env)
//   S8.4  auditLog                     — append-only writes from all the above
//   S1.8  deleteAccount                — gen2 callable; purges the caller's
//                                        uid-keyed personal docs + deletes their
//                                        Auth record (Admin SDK)
//   #6    reviewRoleRequest            — gen2 callable; the matrix-authorized
//                                        approver grants an operational role
//                                        (writes the claim) or denies a request
// ─────────────────────────────────────────────────────────────────────────────

export { deleteAccount } from "./deleteAccount";
export { advanceOrderStage, revertIllegalOrderStageWrite } from "./orders";
export { computeCredit } from "./credit";
export { onChatMessageCreated, onOrderStageChanged } from "./push";
export { getUploadUrl } from "./r2";
export { reviewRoleRequest } from "./reviewRoleRequest";
