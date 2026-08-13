// ─────────────────────────────────────────────────────────────────────────────
// HR-enablement St1 — `setEmployer` (gen2 callable, region me-west1): the
// worker→employer link, ADMIN-ONLY, and deliberately ORTHOGONAL to the role
// surface (mirrors `setOrg`).
//
// WHY: worker HR (attendance / certs / vacations …) can only move to the server
// once the server knows WHO a worker's employer is — so a secure rule can say
// "the worker writes their own doc, and ONLY their employer (or a manager) reads
// it". Today `boardSessionFromAuthSnapshot` leaves `employerId` '' because "there
// is NO employer/contractor-id claim yet"; THIS callable mints exactly that claim
// (+ a users-doc mirror), so the link is server-truth, not client-claimed.
//
// NOT part of `setRole` on purpose: setRole REPLACES its whole claim surface on
// every call, and the employment link must SURVIVE a re-role — so it gets its own
// callable that moves ONLY the `employerId` claim, merged over whatever else the
// target carries (the setOrg / reviewRoleRequest idiom).
//
// The S5 users rules FREEZE `employerId` on both create and update (firestore.rules
// — added to the role/roles/storeUid/orgId/status freeze list), so no client can
// self-assign their boss. The Admin SDK here bypasses that freeze, making this
// callable the ONLY write path — claim + users-doc mirror move together, and every
// call (granted or denied) is audit-logged.
//
// Caller contract (the CALLER must carry the `admin: true` claim):
//   data: { uid: string, employerUid: string }   → assigns the employment link
//   or:   { uid: string, employerUid: null | '' } → REVOKES it (claim deleted +
//                                                    mirror field removed)
// ─────────────────────────────────────────────────────────────────────────────

import { getAuth } from "firebase-admin/auth";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { callerRoles, db, REGION } from "./common";
import { parseSetEmployerInput } from "./setEmployerCore";

interface SetEmployerData {
  uid?: unknown;
  /** The employer (contractor) uid to assign; null/'' (or absent) REVOKES. */
  employerUid?: unknown;
}

export const setEmployer = onCall({ region: REGION }, async (request) => {
  // 1 · caller must be signed in.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const callerUid = request.auth.uid;
  const callerRolesList = callerRoles(request.auth.token);
  const { uid, employerUid } = (request.data ?? {}) as SetEmployerData;
  const targetLabel =
    typeof uid === "string" && uid.length > 0 ? `users/${uid}` : "users/?";

  // 2 · caller must carry the admin claim (the same bootstrap gate as setOrg).
  //     A denied attempt is audit-logged (privilege-escalation trail).
  if (request.auth.token.admin !== true) {
    await writeAudit({
      action: "employer.set",
      source: "setEmployer",
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

  // 3 · validate the payload via the PURE core (uid + employer uid, null/''/absent
  //     = REVOKE, no self-employer). Surface a core error as invalid-argument.
  const parsed = parseSetEmployerInput(uid, employerUid);
  if ("error" in parsed) {
    throw new HttpsError("invalid-argument", parsed.error);
  }
  const { employerValue, revoke } = parsed;
  // `uid` is now proven a non-empty string by the core.
  const targetUid = parsed.uid;

  // 4 · move ONLY the `employerId` claim surface: merge over the target's EXISTING
  //     claims (setOrg-style copy), so role/roles/storeId/orgId/admin stay exactly
  //     as they are — the whole reason this is not folded into setRole.
  const auth = getAuth();
  const target = await auth.getUser(targetUid).catch((e: unknown) => {
    if ((e as { code?: unknown })?.code === "auth/user-not-found") {
      throw new HttpsError("not-found", `user '${targetUid}' does not exist.`);
    }
    throw e;
  });
  const beforeEmployer: unknown = target.customClaims?.employerId ?? null;
  const claims: Record<string, unknown> = { ...(target.customClaims ?? {}) };
  if (revoke) {
    delete claims.employerId;
  } else {
    claims.employerId = employerValue;
  }
  await auth.setCustomUserClaims(targetUid, claims);

  // 5 · mirror to users/{uid}.employerId. The Admin SDK bypasses the S5 freeze on
  //     the field (the same bypass setOrg uses for `orgId`). Merge, so the rest of
  //     the doc is untouched; a revoke REMOVES the field rather than leaving an
  //     empty string behind. The users-doc mirror is what the HR read rules read
  //     via get() to prove "the reader is this worker's employer".
  await db()
    .collection("users")
    .doc(targetUid)
    .set(
      { employerId: revoke ? FieldValue.delete() : employerValue },
      { merge: true }
    );

  await writeAudit({
    action: "employer.set",
    source: "setEmployer",
    actorUid: callerUid,
    actorRole: callerRolesList.join(",") || null,
    target: `users/${targetUid}`,
    before: beforeEmployer,
    after: revoke ? null : employerValue,
    ok: true,
  });

  return { ok: true, uid: targetUid, employerId: revoke ? null : employerValue };
});
