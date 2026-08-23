// ─────────────────────────────────────────────────────────────────────────────
// S8.4 — append-only `auditLog` collection writes from the sensitive paths
// (advanceOrderStage · revertIllegalOrderStageWrite · computeCredit ·
// getUploadUrl). who / what / when / before→after.
//
// APPEND-ONLY contract: this module only ever `add()`s. Functions run with the
// Admin SDK (rules-exempt); S5 Security Rules (sibling fleet — firestore.rules)
// must deny ALL client read/write on `auditLog` so the collection is server-
// append-only end to end.
// ─────────────────────────────────────────────────────────────────────────────

import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { db } from "./common";

export interface AuditEntry {
  /** e.g. "order.stage.advance" · "order.stage.revert" · "credit.compute" ·
   * "r2.uploadUrl.issue". */
  action: string;
  /** The function that wrote the entry. */
  source: string;
  /** Authenticated caller uid, or null when unknown (Firestore triggers carry
   * no auth context — exactly why the revert trigger exists). */
  actorUid: string | null;
  /** The caller's role claims (comma-joined), or null. */
  actorRole: string | null;
  /** What was touched, e.g. "orders/BS-1042" or "r2://bucket/key". */
  target: string;
  /** State before the action (e.g. `{ stage: "ready" }`), or null. */
  before: unknown;
  /** State after / the attempted state, or null. */
  after: unknown;
  /** true = the action was performed; false = it was denied/reverted. */
  ok: boolean;
  /** Human-readable cause for denied/reverted entries. */
  reason?: string;
}

/**
 * Append one audit entry (server timestamp added). Best-effort by design: an
 * audit failure is logged loudly but never breaks the business operation —
 * the structured `logger.error` itself still lands in Cloud Logging.
 */
export async function writeAudit(entry: AuditEntry): Promise<void> {
  try {
    await db()
      .collection("auditLog")
      .add({
        action: entry.action,
        source: entry.source,
        actorUid: entry.actorUid,
        actorRole: entry.actorRole,
        target: entry.target,
        before: entry.before ?? null,
        after: entry.after ?? null,
        ok: entry.ok,
        ...(entry.reason !== undefined ? { reason: entry.reason } : {}),
        at: FieldValue.serverTimestamp(),
      });
  } catch (e) {
    logger.error("auditLog write failed", { entry, error: String(e) });
  }
}
