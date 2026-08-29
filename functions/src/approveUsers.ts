// ─────────────────────────────────────────────────────────────────────────────
// registration approval — the OWNER/manager activates who may buy.
//
// New accounts are born `status: pending` (the client born-status write), and the
// pending-gate (rbac checkoutBlock + the `isActive()` orders rule) blocks them at
// checkout until an owner approves. Approval is OWNER-DRIVEN from the Manager
// Customers screen's approval panel (app_flutter/lib/screens/
// manager_dashboard_screen.dart), which calls THIS callable to flip
// `users/{uid}.status` pending⇄active in bulk ("approve all" / "approve selected").
//
// SAME activation mechanism `reviewRoleRequest` uses (U4.4): the Admin SDK write
// bypasses the S5 self-write freeze on `status` (the ONLY sanctioned activation
// path — a client can never write its own `status`), and `syncDirectoryEntry`
// refreshes the readable directory row so the client's directory stream flips the
// person ממתין→מאושר with no reload. Unlike `reviewRoleRequest`, NO role claim is
// ever written here — this is the account-activation switch, not a role grant.
//
// AUTH: the caller must hold `manager` or `admin` (custom claims via
// `callerRoles`); anyone else is permission-denied (audit-logged). This is the
// account-activation tier — the same posture the S5 rules take on `status`.
// ─────────────────────────────────────────────────────────────────────────────

import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { callerRoles, db, REGION } from "./common";
import { syncDirectoryEntry } from "./directory";

/** Hard cap on one approve batch — a manager action, not a migration. Matches the
 * client directory listen bound (app_flutter/lib/state/directory.dart, limit(500))
 * so a single "approve all" over the visible pending set always fits one call. */
export const APPROVE_USERS_CAP = 500;

/** PURE authorization check (no I/O — selftested): may a caller holding
 * [callerRolesList] approve/suspend accounts? Only `manager` or `admin` — the
 * account-activation tier. Mirrors the client panel gate (BoardRole.manager) and
 * the S5 posture that `status` is server-only. */
export function mayApproveUsers(
  callerRolesList: ReadonlyArray<string>
): boolean {
  return (
    callerRolesList.includes("manager") || callerRolesList.includes("admin")
  );
}

/** The cleaned result of validating the callable's `uids` payload. [error] is a
 * non-null invalid-argument reason when the input is unusable; otherwise [uids]
 * is the de-duplicated, non-empty, capped list to act on. */
export interface CleanUidsResult {
  uids: string[];
  error: string | null;
}

/** PURE input validation (no I/O — selftested): coerce the `uids` payload to a
 * clean list, or return an [error] the handler maps to invalid-argument. Rejects
 * a non-array, any non-string / empty uid, an empty list, and a list past [cap];
 * de-duplicates (approving the same uid twice is one write). */
export function cleanApproveUids(
  input: unknown,
  cap: number = APPROVE_USERS_CAP
): CleanUidsResult {
  if (!Array.isArray(input)) {
    return { uids: [], error: "uids (string[]) is required." };
  }
  const seen = new Set<string>();
  for (const u of input) {
    if (typeof u !== "string" || u.length === 0) {
      return { uids: [], error: "every uid must be a non-empty string." };
    }
    seen.add(u);
  }
  const uids = [...seen];
  if (uids.length === 0) {
    return { uids: [], error: "uids must contain at least one uid." };
  }
  if (uids.length > cap) {
    return { uids: [], error: `too many uids in one batch (max ${cap}).` };
  }
  return { uids, error: null };
}

interface ApproveData {
  uids?: unknown;
  approve?: unknown;
}

/**
 * approveUsers — the manager/admin bulk account-activation callable (region
 * REGION, matching `kAuthFunctionsRegion` in the app).
 *
 *   data: { uids: string[], approve: boolean }
 *   auth: the caller must hold `manager` or `admin` (else permission-denied).
 *
 * For each uid it merge-writes `users/{uid}.status = approve ? 'active' :
 * 'pending'` (Admin SDK — bypassing the S5 status-freeze) and refreshes that
 * user's directory row. Best-effort per uid: a single failed write is logged and
 * skipped, never aborting the batch. Returns { ok, count } (count = uids acted on).
 */
export const approveUsers = onCall({ region: REGION }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const callerUid = request.auth.uid;
  const roles = callerRoles(request.auth.token);

  // AUTHORIZE: manager/admin only. A denied attempt is audit-logged (the setRole
  // privilege-escalation-trail precedent).
  if (!mayApproveUsers(roles)) {
    await writeAudit({
      action: "users.approve",
      source: "approveUsers",
      actorUid: callerUid,
      actorRole: roles.join(",") || null,
      target: "users/*",
      before: null,
      after: null,
      ok: false,
      reason: "manager-or-admin-required",
    });
    throw new HttpsError(
      "permission-denied",
      "Only a manager or admin may approve users."
    );
  }

  const { uids, approve } = (request.data ?? {}) as ApproveData;
  if (typeof approve !== "boolean") {
    throw new HttpsError("invalid-argument", "approve (boolean) is required.");
  }
  const clean = cleanApproveUids(uids);
  if (clean.error !== null) {
    throw new HttpsError("invalid-argument", clean.error);
  }

  const status = approve ? "active" : "pending";
  let count = 0;
  for (const uid of clean.uids) {
    try {
      // The ONLY sanctioned activation path: the Admin SDK bypasses the S5 self-
      // write freeze on `status`. Merge, so displayName/phone/role-mirror stay
      // untouched; a users doc that does not exist yet is created with just the
      // status (the same edge `reviewRoleRequest` handles).
      await db().collection("users").doc(uid).set({ status }, { merge: true });
      // Refresh the readable directory row immediately (best-effort — the users
      // write also fires onUserDocWritten, which syncs it again). A single sync
      // hiccup must not fail the whole batch.
      await syncDirectoryEntry(uid).catch((e) =>
        logger.warn("approveUsers: syncDirectoryEntry failed", {
          uid,
          e: String(e),
        })
      );
      count++;
    } catch (e) {
      logger.error("approveUsers: status write failed", {
        uid,
        e: String(e),
      });
    }
  }

  logger.info("approveUsers", {
    approve,
    requested: clean.uids.length,
    count,
    callerUid,
  });
  await writeAudit({
    action: approve ? "users.approve" : "users.suspend",
    source: "approveUsers",
    actorUid: callerUid,
    actorRole: roles.join(",") || null,
    target: `users[${count}/${clean.uids.length}]`,
    before: null,
    after: { status, count, uids: clean.uids },
    ok: true,
  });

  return { ok: true, count };
});
