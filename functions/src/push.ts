// ─────────────────────────────────────────────────────────────────────────────
// S8.3 (+S6.3) — FCM push triggers:
//
//   • `onOrderStageChanged`  — onDocumentUpdated orders/{orderId}: a LEGAL
//     stage step notifies the order's participants (contractorId / storeId /
//     courierId — uids per the schema; ids that have no users/{uid} doc, e.g.
//     legacy seed display-names, are silently skipped) minus the actor that
//     advanced it (the callable stamps stageBy/stageAt). Hebrew payload with
//     the VERBATIM stage label (supplier_data.dart `kOrderStageLabel`).
//     Illegal writes and revert writes (stageGuard changed) never notify.
//
//   • `onChatMessageCreated` — onDocumentCreated chatMessages/{messageId}:
//     notifies the thread's participants minus the sender, Hebrew title with
//     the sender's displayName (fallback: the persona's Hebrew title) and a
//     preview of the message text.
//
// Tokens are read from users/{uid}.fcmToken (S6.1). Tokens FCM reports as
// no-longer-registered are pruned from the user doc.
// ─────────────────────────────────────────────────────────────────────────────

import { FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import { asString, db, REGION } from "./common";
import { isLegalStep, isOrderStage, ORDER_STAGE_LABEL_HE } from "./orderFlow";

/** Verbatim persona titles (app_flutter/lib/data/personas.dart). */
const ROLE_TITLE_HE: Record<string, string> = {
  contractor: "קבלן",
  manager: "מנהל המערכת",
  store: "חנות ספק",
  courier: "שליח",
  worker: "עובד",
};

/** Resolve users/{uid}.fcmToken for each uid and send one notification per
 * token (sendEach). Unknown uids / missing tokens are skipped; dead tokens
 * are pruned from the user doc. Exported so the registration-approval alert
 * (onUserCreatedQueueApproval, reviewRoleRequest.ts) reuses this ONE send path. */
export async function sendToUsers(
  uids: ReadonlyArray<string>,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  const unique = [...new Set(uids.filter((u) => u.length > 0))];
  if (unique.length === 0) return;

  const looked = await Promise.all(
    unique.map(async (uid) => {
      const snap = await db().collection("users").doc(uid).get();
      return { uid, token: asString(snap.get("fcmToken")) };
    })
  );
  const targets = looked.filter(
    (t): t is { uid: string; token: string } => t.token !== null
  );
  if (targets.length === 0) {
    logger.info("push: no fcmTokens for recipients", { uids: unique });
    return;
  }

  const res = await getMessaging().sendEach(
    targets.map(({ token }) => ({
      token,
      notification: { title, body },
      data,
    }))
  );
  await Promise.all(
    res.responses.map(async (r, i) => {
      if (r.success) return;
      const code = r.error?.code ?? "unknown";
      logger.warn("push send failed", { uid: targets[i].uid, code });
      if (code === "messaging/registration-token-not-registered") {
        // Stale token — prune so we stop addressing it.
        await db()
          .collection("users")
          .doc(targets[i].uid)
          .update({ fcmToken: FieldValue.delete() })
          .catch(() => undefined);
      }
    })
  );
  logger.info("push sent", {
    ok: res.successCount,
    failed: res.failureCount,
    title,
  });
}

/** Order stage-change push (Hebrew, verbatim stage label). */
export const onOrderStageChanged = onDocumentUpdated(
  { region: REGION, document: "orders/{orderId}" },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const before = change.before;
    const after = change.after;

    const from: unknown = before.get("stage");
    const to: unknown = after.get("stage");
    if (from === to) return; // not a stage change

    // Revert writes (stageGuard changed) and illegal jumps never notify —
    // the revert trigger (orders.ts) owns those.
    const guardChanged =
      JSON.stringify(before.get("stageGuard") ?? null) !==
      JSON.stringify(after.get("stageGuard") ?? null);
    if (guardChanged) return;
    if (!isLegalStep(from, to)) return;
    if (!isOrderStage(to)) return;

    const orderId = event.params.orderId;

    // The actor: when THIS update stamped stageAt (the callable path), exclude
    // the stamped stageBy from the recipients — don't notify the actor.
    const stamped =
      asString(after.get("stageAt")) !== asString(before.get("stageAt"));
    const actor = stamped ? asString(after.get("stageBy")) : null;

    const recipients = [
      asString(after.get("contractorId")),
      asString(after.get("storeId")),
      asString(after.get("courierId")),
    ].filter((u): u is string => u !== null && u !== actor);

    await sendToUsers(
      recipients,
      "עדכון הזמנה",
      `הזמנה ${orderId} · ${ORDER_STAGE_LABEL_HE[to]}`,
      { type: "orderStage", orderId, stage: to }
    );
  }
);

/** New chat-message push (Hebrew, sender name + text preview). */
export const onChatMessageCreated = onDocumentCreated(
  { region: REGION, document: "chatMessages/{messageId}" },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const threadId = asString(snap.get("threadId"));
    if (threadId === null) return;
    const fromUid = asString(snap.get("fromUid"));
    const text = asString(snap.get("text")) ?? "";

    const thread = await db().collection("chatThreads").doc(threadId).get();
    // Address the uid members: `participantUids` is the AUTH-TRUTH the A14
    // chat-sync stamps and the rules scope on. `participants` carries display
    // ROLE NAMES (not uids), so FCM-by-participants never matched a
    // users/{uid}.fcmToken — no chat push was delivered. Minus the sender.
    const raw: unknown = thread.get("participantUids");
    const participantUids = Array.isArray(raw)
      ? raw.filter((p): p is string => typeof p === "string" && p.length > 0)
      : [];
    const recipients = participantUids.filter((p) => p !== fromUid);
    if (recipients.length === 0) return;

    // Sender display: users/{fromUid}.displayName → persona Hebrew title.
    let sender: string | null = null;
    if (fromUid !== null) {
      const u = await db().collection("users").doc(fromUid).get();
      sender = asString(u.get("displayName"));
    }
    if (sender === null) {
      const role = asString(snap.get("fromRole"));
      sender = role !== null ? ROLE_TITLE_HE[role] ?? null : null;
    }

    const title = sender !== null ? `הודעה חדשה מ־${sender}` : "הודעה חדשה";
    const preview = text.length > 80 ? `${text.slice(0, 79)}…` : text;

    await sendToUsers(recipients, title, preview, {
      type: "chatMessage",
      threadId,
      messageId: event.params.messageId,
    });
  }
);

/** Account-approval push (Hebrew).
 *
 * Registration is all-by-approval: a new account is born `pending` and most of
 * the app is locked until an admin activates it. Until now that activation was
 * SILENT — the person was told to wait and then never told anything again, so
 * the only way to discover the account had opened was to keep reopening the app
 * and guessing. Most people would simply stop.
 *
 * Fires only on the pending → active edge, so re-saving an already-active user,
 * a suspension, or any other field change never notifies. */
export const onUserActivated = onDocumentUpdated(
  { region: REGION, document: "users/{uid}" },
  async (event) => {
    const change = event.data;
    if (!change) return;

    const from = asString(change.before.get("status"));
    const to = asString(change.after.get("status"));
    // The single edge worth announcing. Anything → active where it was already
    // active is a no-op; suspended → active is a genuine re-activation and does
    // count.
    if (to !== "active" || from === "active") return;

    await sendToUsers(
      [event.params.uid],
      "החשבון שלך אושר ✓",
      "אפשר להתחיל — כל הפעולות פתוחות עכשיו.",
      { type: "userActivated" }
    );
  }
);
