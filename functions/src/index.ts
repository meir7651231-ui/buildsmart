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
import { callerRoles, db } from "./common";

initializeApp();

/** The five persona ids the app knows (lib/data/personas.dart) — the client
 * filters claims to this same list, so an out-of-list role is never accepted
 * on either side. */
const VALID_ROLES = ["contractor", "manager", "store", "courier", "worker"];

interface SetRoleData {
  uid?: unknown;
  role?: unknown;
  roles?: unknown;
  /** U3.1.1 — OPTIONAL store-ownership claim (single-owner, decision #3). When
   * present it names the store this user OWNS; stamped as the `storeId` claim the
   * live inventory rule checks. */
  storeId?: unknown;
}

export const setRole = onCall({ region: "me-west1" }, async (request) => {
  // 1 · caller must be signed in.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const callerUid = request.auth.uid;
  const callerRolesList = callerRoles(request.auth.token);
  const { uid, role, roles, storeId } = (request.data ?? {}) as SetRoleData;
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

  // 3b · U3.1.1 — validate the OPTIONAL storeId claim (store-ownership). When
  //     supplied it must be a non-empty string naming an EXISTING store, so the
  //     claim can never point at a store that does not exist. Same admin-only gate
  //     as the whole callable (checked above). The live inventory rule
  //     (firestore.rules) already lets a `store` write ONLY rows whose `storeId`
  //     equals this claim — stamping it here is what WAKES that dormant branch.
  let storeIdValue: string | null = null;
  if (storeId !== undefined && storeId !== null) {
    if (typeof storeId !== "string" || storeId.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "storeId, when provided, must be a non-empty string."
      );
    }
    const storeSnap = await db().collection("stores").doc(storeId).get();
    if (!storeSnap.exists) {
      throw new HttpsError("not-found", `store '${storeId}' does not exist.`);
    }
    storeIdValue = storeId;
  }

  // 4 · merge over the target's EXISTING claims (e.g. an admin keeps `admin`),
  //     replacing only the role surface — single `role` and multi `roles` are
  //     mutually exclusive by construction.
  const auth = getAuth();
  const target = await auth.getUser(uid); // throws not-found for a bad uid
  const claims: Record<string, unknown> = { ...(target.customClaims ?? {}) };
  delete claims.role;
  delete claims.roles;
  delete claims.storeId;
  if (roleList) {
    claims.roles = roleList;
  } else {
    claims.role = role;
  }
  // U3.1.1 — stamp the (validated) store-ownership claim. It is cleared above,
  // so a re-role that omits storeId REVOKES ownership (a user demoted from store
  // loses inventory-write) — ownership is always explicit, never sticky.
  if (storeIdValue) {
    claims.storeId = storeIdValue;
  }
  await auth.setCustomUserClaims(uid, claims);

  await writeAudit({
    action: "role.set",
    source: "setRole",
    actorUid: callerUid,
    actorRole: callerRolesList.join(",") || null,
    target: `users/${uid}`,
    before: null,
    after: {
      ...(roleList ? { roles: roleList } : { role }),
      ...(storeIdValue ? { storeId: storeIdValue } : {}),
    },
    ok: true,
  });

  return {
    ok: true,
    uid,
    ...(roleList ? { roles: roleList } : { role }),
    ...(storeIdValue ? { storeId: storeIdValue } : {}),
  };
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
//   P5.56 publishConfig                — gen2 callable; THE sanctioned publish-
//                                        to-all path (CAS on expectedBaseVersion,
//                                        owner/dual-control + live allow-flag,
//                                        per-uid rate-limit, audit on both paths)
//   P5.57 revertIllegalConfigWrite     — trigger; reverts any DIRECT write to
//                                        studioConfig/published lacking the
//                                        callable's publishGuard stamp (defense-
//                                        in-depth; loop-guarded like S8.1's revert)
//   P5.66 rollupAnalyticsDaily         — scheduled; sums the distributed-counter
//         rollupPresenceSummary          shards → one analyticsDaily/{day} doc, and
//                                        rolls presence/* → one presenceSummary/
//                                        current doc (cost-guardrails: owner reads
//                                        ~1 doc, never the raw collections; R1-1/2/3)
// ─────────────────────────────────────────────────────────────────────────────

export { deleteAccount, deleteUser } from "./deleteAccount";
export { advanceOrderStage, revertIllegalOrderStageWrite } from "./orders";
export { onOrderCreatedEmail } from "./orderEmail";
export { computeCredit } from "./credit";
export { askClaude } from "./claude";
export {
  onChatMessageCreated,
  onOrderStageChanged,
  onUserActivated,
} from "./push";
export { getUploadUrl } from "./r2";
export { onUserDocWritten } from "./directory";
export {
  onUserCreatedQueueApproval,
  reviewRoleRequest,
} from "./reviewRoleRequest";
//   reg   approveUsers                 — gen2 callable; manager/admin bulk
//                                        account-activation (users.status
//                                        pending⇄active via the Admin SDK), the
//                                        server side of the owner's approval panel
export { approveUsers } from "./approveUsers";
export { publishConfig, revertIllegalConfigWrite } from "./studio";
// P5.66 rollup schedulers. Deploying these `onSchedule` functions requires the
// Cloud Scheduler API enabled AND the CI service account granted
// roles/cloudscheduler.admin (cloudscheduler.jobs.create/update/delete) — both
// now provisioned on buildsmart-b0b78. See `.github/workflows/firebase-deploy.yml`
// "Required APIs/roles" and `app_flutter/knowledge/STUDIO_GA.md`.
export { rollupAnalyticsDaily, rollupPresenceSummary } from "./analytics";
export { setOrg } from "./setOrg";
