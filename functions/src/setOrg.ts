// ─────────────────────────────────────────────────────────────────────────────
// Stage-3.3 St1 — `setOrg` (gen2 callable, region me-west1): org membership,
// ADMIN-ONLY, and deliberately ORTHOGONAL to the role surface.
//
// NOT part of `setRole` on purpose: setRole REPLACES its whole claim surface
// (role/roles/storeId) on every call, and org membership must SURVIVE a
// re-role — so membership gets its own callable that moves ONLY the `orgId`
// claim, merged over whatever else the target carries (the same claims copy
// reviewRoleRequest uses).
//
// The S5 users rules FREEZE `orgId` on both create and update (firestore.rules
// — the role/roles/storeUid/orgId/status freeze list: "org membership —
// server-assigned, not self-claimed"), so no client can write the field. The
// Admin SDK here bypasses that freeze, making this callable the ONLY write
// path for org membership — claim + users-doc mirror move together, and every
// call (granted or denied) is audit-logged.
//
// Caller contract (the CALLER must carry the `admin: true` claim):
//   data: { uid: string, orgId: string }       → assigns membership
//   or:   { uid: string, orgId: null | '' }    → REVOKES membership (claim
//                                                deleted + mirror field removed)
// ─────────────────────────────────────────────────────────────────────────────

import { getAuth } from "firebase-admin/auth";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { callerRoles, db, REGION } from "./common";

/** The sane org-id shape: doc-id-safe charset, 1–64 chars — nothing that could
 * escape a Firestore path or smuggle structure into a claim. */
const ORG_ID_PATTERN = /^[a-zA-Z0-9_-]{1,64}$/;

interface SetOrgData {
  uid?: unknown;
  /** The org to assign; null/'' (or absent) REVOKES membership. */
  orgId?: unknown;
}

export const setOrg = onCall({ region: REGION }, async (request) => {
  // 1 · caller must be signed in.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const callerUid = request.auth.uid;
  const callerRolesList = callerRoles(request.auth.token);
  const { uid, orgId } = (request.data ?? {}) as SetOrgData;
  const targetLabel =
    typeof uid === "string" && uid.length > 0 ? `users/${uid}` : "users/?";

  // 2 · caller must carry the admin claim (the same bootstrap gate as setRole).
  //     A denied attempt is audit-logged (privilege-escalation trail).
  if (request.auth.token.admin !== true) {
    await writeAudit({
      action: "org.set",
      source: "setOrg",
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

  // 3 · validate the payload: uid + an org id, where null/''/absent = REVOKE.
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "uid (string) is required.");
  }
  let orgIdValue: string | null = null;
  if (orgId !== undefined && orgId !== null && orgId !== "") {
    if (typeof orgId !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "orgId must be a string, or null/'' to revoke."
      );
    }
    const trimmed = orgId.trim();
    if (!ORG_ID_PATTERN.test(trimmed)) {
      throw new HttpsError(
        "invalid-argument",
        "orgId must be 1-64 chars of letters, digits, '_' or '-'."
      );
    }
    orgIdValue = trimmed;
  }
  const revoke = orgIdValue === null;

  // 4 · move ONLY the `orgId` claim surface: merge over the target's EXISTING
  //     claims (reviewRoleRequest-style copy), so role/roles/storeId/admin stay
  //     exactly as they are — the whole reason this is not folded into setRole.
  const auth = getAuth();
  const target = await auth.getUser(uid).catch((e: unknown) => {
    // Surface the Admin SDK's bad-uid error as a proper callable code
    // (anything else — an Auth outage etc. — stays an internal error).
    if ((e as { code?: unknown })?.code === "auth/user-not-found") {
      throw new HttpsError("not-found", `user '${uid}' does not exist.`);
    }
    throw e;
  });
  const beforeOrgId: unknown = target.customClaims?.orgId ?? null;
  const claims: Record<string, unknown> = { ...(target.customClaims ?? {}) };
  if (revoke) {
    delete claims.orgId;
  } else {
    claims.orgId = orgIdValue;
  }
  await auth.setCustomUserClaims(uid, claims);

  // 5 · mirror to users/{uid}.orgId. The Admin SDK bypasses the S5 freeze on
  //     the field (the same bypass reviewRoleRequest uses for `status`). Merge,
  //     so displayName/phone/role-mirror/etc. are untouched; a revoke REMOVES
  //     the field rather than leaving an empty string behind.
  await db()
    .collection("users")
    .doc(uid)
    .set(
      { orgId: revoke ? FieldValue.delete() : orgIdValue },
      { merge: true }
    );

  await writeAudit({
    action: "org.set",
    source: "setOrg",
    actorUid: callerUid,
    actorRole: callerRolesList.join(",") || null,
    target: `users/${uid}`,
    before: beforeOrgId,
    after: revoke ? null : orgIdValue,
    ok: true,
  });

  return { ok: true, uid, orgId: revoke ? null : orgIdValue };
});
