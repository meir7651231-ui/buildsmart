// ─────────────────────────────────────────────────────────────────────────────
// #6 — role-request review (gen2 callable). A signed-in user asks for an
// OPERATIONAL role by writing roleRequests/{uid} (status: pending); the
// designated approver reviews it here. This is the ONLY path besides the
// bootstrap setRole that writes a role claim, and it enforces a hierarchical
// approval matrix (NOT admin-only — the real operators approve their own tier):
//
//     requested role   →   approver role
//     ───────────────      ─────────────
//     worker           →   contractor      (a contractor signs off their workers)
//     courier          →   store           (a store signs off its couriers)
//     store            →   manager
//     contractor       →   manager
//     (admin approves anything, as the superuser.)
//
// The claim write itself stays server-only (Admin SDK) — clients can never set
// roleRequests.status or a role claim directly (S5 rules deny it). On approve we
// merge the operational role over the target's existing claims (preserving admin
// etc.), exactly like setRole; manager/admin are NEVER grantable here.
// ─────────────────────────────────────────────────────────────────────────────

import { getAuth } from "firebase-admin/auth";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { asString, callerRoles, db, REGION } from "./common";

/// The role a CALLER must hold to approve a request for the keyed role. Only
/// these four operational roles are ever requestable/grantable through #6.
const APPROVER_FOR: Record<string, string> = {
  worker: "contractor",
  courier: "store",
  store: "manager",
  contractor: "manager",
};

/// PURE authorization check for the #6 matrix (no I/O — selftested): may a
/// caller holding [reviewerRoles] review a request for [requestedRole]? admin
/// reviews anything; otherwise the caller must hold the matrix-designated
/// approver role. An unknown/non-operational requestedRole is never reviewable.
export function mayReviewRoleRequest(
  reviewerRoles: ReadonlyArray<string>,
  requestedRole: string
): boolean {
  if (reviewerRoles.includes("admin")) return true;
  const approver = APPROVER_FOR[requestedRole];
  return approver !== undefined && reviewerRoles.includes(approver);
}

interface ReviewData {
  uid?: unknown;
  decision?: unknown; // 'approve' | 'deny'
}

export const reviewRoleRequest = onCall({ region: REGION }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const reviewerUid = request.auth.uid;
  const reviewerRoles = callerRoles(request.auth.token);

  const { uid, decision } = (request.data ?? {}) as ReviewData;
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "uid (string) is required.");
  }
  if (decision !== "approve" && decision !== "deny") {
    throw new HttpsError(
      "invalid-argument",
      "decision must be 'approve' or 'deny'."
    );
  }
  if (uid === reviewerUid) {
    // Nobody self-approves — the whole point of the matrix.
    throw new HttpsError("permission-denied", "Cannot review your own request.");
  }

  // Load the pending request.
  const ref = db().collection("roleRequests").doc(uid);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "No role request for that uid.");
  }
  if (asString(snap.get("status")) !== "pending") {
    throw new HttpsError("failed-precondition", "Request is not pending.");
  }
  const requestedRole = asString(snap.get("requestedRole"));
  if (requestedRole === null || !(requestedRole in APPROVER_FOR)) {
    throw new HttpsError(
      "failed-precondition",
      "Request carries no valid operational role."
    );
  }

  // Authorize the reviewer against the matrix (admin may review anything).
  if (!mayReviewRoleRequest(reviewerRoles, requestedRole)) {
    throw new HttpsError(
      "permission-denied",
      `Only a ${APPROVER_FOR[requestedRole]} (or admin) may review a ` +
        `${requestedRole} request.`
    );
  }
  const approverRole = APPROVER_FOR[requestedRole];

  const approved = decision === "approve";

  // ATOMIC status flip (closes the concurrent-review race): re-read status inside a
  // transaction and assert it is STILL pending before flipping. Only ONE reviewer
  // can win the pending→decision write — a second concurrent reviewer (e.g. a deny
  // racing an approve) now fails-precondition instead of both passing the gate and
  // leaving status=denied while the role claim was already granted.
  await db().runTransaction(async (tx) => {
    const fresh = await tx.get(ref);
    if (asString(fresh.get("status")) !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Request was already reviewed."
      );
    }
    tx.update(ref, {
      status: approved ? "approved" : "denied",
      reviewedBy: reviewerUid,
      reviewedByRole: approverRole,
      reviewedAt: FieldValue.serverTimestamp(),
    });
  });

  // Grant the claim ONLY after winning the flip (a lost approve never reaches here),
  // and OUTSIDE the transaction — setCustomUserClaims is an Auth op, not Firestore-
  // transactional, and a tx retry must never re-run it. Idempotent surface-replace,
  // same contract as setRole; admin/manager are never granted here.
  if (approved) {
    const target = await getAuth().getUser(uid);
    const claims: Record<string, unknown> = { ...(target.customClaims ?? {}) };
    delete claims.role;
    delete claims.roles;
    claims.role = requestedRole;
    await getAuth().setCustomUserClaims(uid, claims);
    // U4.4 — approval ACTIVATES the account: flip users/{uid}.status
    // pending→active. The Admin SDK bypasses the self-write freeze the S5 rules
    // put on `status`, so this is the ONLY sanctioned path to activation. Merge,
    // so displayName/phone/role-mirror/etc. are untouched; a users doc that does
    // not exist yet (edge) is created with just the status. This CLOSES the
    // all-by-approval loop (decision #1): until now approve granted the role
    // claim but left the account `pending`, so the client pending-gate kept
    // blocking the (now-approved) user.
    await db()
      .collection("users")
      .doc(uid)
      .set({ status: "active" }, { merge: true });
  }
  logger.info("reviewRoleRequest", { uid, requestedRole, decision, reviewerUid });

  await writeAudit({
    action: approved ? "role.request.approve" : "role.request.deny",
    source: "reviewRoleRequest",
    actorUid: reviewerUid,
    actorRole: reviewerRoles.join(",") || null,
    target: `roleRequests/${uid}`,
    before: { requestedRole, status: "pending" },
    after: {
      status: approved ? "approved" : "denied",
      ...(approved ? { accountStatus: "active" } : {}),
    },
    ok: true,
  });

  return { ok: true, uid, requestedRole, decision };
});
