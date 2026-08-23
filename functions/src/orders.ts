// ─────────────────────────────────────────────────────────────────────────────
// S8.1 — server-side stage-transition enforcement, TWO layers (both required):
//
//  1. CALLABLE `advanceOrderStage({orderId})` — THE sanctioned write path.
//     Firestore triggers carry no auth context, so role checks can only happen
//     where the caller's ID token is present: here. The callable advances the
//     order ONE step along ORDER_FLOW iff the caller's role claims own that
//     transition (store / courier per sys_orders.dart; manager/admin may nudge
//     any single step), inside a transaction, and stamps stageBy/stageRole/
//     stageAt. Every grant AND every denial is written to `auditLog`.
//
//  2. TRIGGER `revertIllegalOrderStageWrite` (onDocumentUpdated orders/{id}) —
//     defense-in-depth for DIRECT writes that slip past S5 rules (or arrive
//     before rules are deployed): any stage change that is NOT a single
//     forward step along the chain is reverted to the previous stage and
//     logged to `auditLog`. Role enforcement for legal direct writes remains
//     S5 rules' job (no auth context here) — this trigger guards the CHAIN.
//
//     Loop guard: the revert write stamps `stageGuard` (revertedAt = event id);
//     an update whose `stageGuard` changed IS a revert and is skipped.
//
//     Known consequences (accepted, documented in README):
//       • the manager "god-step" to an arbitrary stage and the demo
//         `resetToSeed` backward writes are reverted when issued as direct
//         writes — single steps must go through the callable instead.
// ─────────────────────────────────────────────────────────────────────────────

import { FieldValue } from "firebase-admin/firestore";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { writeAudit } from "./audit";
import { asString, callerRoles, db, REGION } from "./common";
import {
  isLegalStep,
  isOrderStage,
  nextStage,
  rolesAllowedFor,
} from "./orderFlow";

interface AdvanceOrderStageData {
  orderId?: unknown;
}

/**
 * Advance an order ONE step along ORDER_FLOW on behalf of the caller, with
 * role authorization from their custom claims. Returns `{ok, orderId, from, to}`.
 */
export const advanceOrderStage = onCall(
  { region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    const { orderId } = (request.data ?? {}) as AdvanceOrderStageData;
    if (typeof orderId !== "string" || orderId.length === 0) {
      throw new HttpsError("invalid-argument", "orderId (string) is required.");
    }
    const uid = request.auth.uid;
    const roles = callerRoles(request.auth.token);
    const ref = db().collection("orders").doc(orderId);

    // Context captured inside the transaction closure for the deny-audit.
    let denyFrom: string | null = null;
    let denyTo: string | null = null;

    try {
      const result = await db().runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists) {
          throw new HttpsError("not-found", `Order ${orderId} not found.`);
        }
        const cur: unknown = snap.get("stage");
        if (!isOrderStage(cur)) {
          denyFrom = asString(cur);
          throw new HttpsError(
            "failed-precondition",
            `Order ${orderId} carries an unknown stage.`
          );
        }
        const nxt = nextStage(cur);
        if (nxt === null) {
          // Mirrors the client advance no-op at the last stage — but surfaced.
          denyFrom = cur;
          throw new HttpsError(
            "failed-precondition",
            "Order is already delivered (last stage of the flow)."
          );
        }
        const allowed = rolesAllowedFor(cur, nxt);
        const grantedVia = roles.find((r) => allowed.includes(r)) ?? null;
        if (grantedVia === null) {
          denyFrom = cur;
          denyTo = nxt;
          throw new HttpsError(
            "permission-denied",
            `Role(s) [${roles.join(", ")}] may not advance ${cur}→${nxt}; ` +
              `allowed: [${allowed.join(", ")}].`
          );
        }
        tx.update(ref, {
          stage: nxt,
          stageBy: uid,
          stageRole: grantedVia,
          stageAt: new Date().toISOString(),
        });
        return { from: cur, to: nxt, grantedVia };
      });

      await writeAudit({
        action: "order.stage.advance",
        source: "advanceOrderStage",
        actorUid: uid,
        actorRole: roles.join(",") || null,
        target: `orders/${orderId}`,
        before: { stage: result.from },
        after: { stage: result.to },
        ok: true,
      });
      return { ok: true, orderId, from: result.from, to: result.to };
    } catch (e) {
      if (e instanceof HttpsError) {
        await writeAudit({
          action: "order.stage.advance",
          source: "advanceOrderStage",
          actorUid: uid,
          actorRole: roles.join(",") || null,
          target: `orders/${orderId}`,
          before: { stage: denyFrom },
          after: { stage: denyTo },
          ok: false,
          reason: `${e.code}: ${e.message}`,
        });
      }
      throw e;
    }
  }
);

/**
 * Defense-in-depth: revert any DIRECT `orders/{id}` write whose stage change
 * is not a single forward step along ORDER_FLOW (see module header).
 */
export const revertIllegalOrderStageWrite = onDocumentUpdated(
  { region: REGION, document: "orders/{orderId}" },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const before = change.before;
    const after = change.after;

    const fromStage: unknown = before.get("stage");
    const toStage: unknown = after.get("stage");
    if (fromStage === toStage) return; // not a stage change

    // Loop guard — this very update was written by the revert below.
    const guardBefore = JSON.stringify(before.get("stageGuard") ?? null);
    const guardAfter = JSON.stringify(after.get("stageGuard") ?? null);
    if (guardBefore !== guardAfter) return;

    // A legal single forward step: tolerated (role enforcement on direct
    // writes = S5 rules; the sanctioned path is the callable above).
    if (isLegalStep(fromStage, toStage)) return;

    const orderId = event.params.orderId;
    await db().runTransaction(async (tx) => {
      const snap = await tx.get(after.ref);
      if (!snap.exists) return;
      // Superseded by a newer write? Don't clobber it.
      if (snap.get("stage") !== toStage) return;
      tx.update(after.ref, {
        stage: typeof fromStage === "string" ? fromStage : FieldValue.delete(),
        stageBy: before.get("stageBy") ?? FieldValue.delete(),
        stageRole: before.get("stageRole") ?? FieldValue.delete(),
        stageAt: before.get("stageAt") ?? FieldValue.delete(),
        stageGuard: {
          revertedAt: event.id,
          from: asString(fromStage),
          to: asString(toStage),
        },
      });
    });

    logger.warn("illegal direct stage write reverted", {
      orderId,
      from: fromStage,
      to: toStage,
    });
    await writeAudit({
      action: "order.stage.revert",
      source: "revertIllegalOrderStageWrite",
      // Triggers carry no auth context; stageBy is self-reported by the writer
      // and may be absent or spoofed — recorded as-is for forensics.
      actorUid: asString(after.get("stageBy")),
      actorRole: null,
      target: `orders/${orderId}`,
      before: { stage: asString(fromStage) },
      after: { stage: asString(toStage) },
      ok: false,
      reason:
        "illegal direct stage write reverted " +
        "(not a single forward step along ORDER_FLOW)",
    });
  }
);
