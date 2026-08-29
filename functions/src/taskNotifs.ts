// ─────────────────────────────────────────────────────────────────────────────
// onTaskStatusChanged (Wave T3 · 2d) — SERVER-GENERATED worker bell feed. The
// in-app §6 worker notification feed (the 🔔 bell) migrates from the client's
// username-keyed local store to `workerNotifs/{workerUid}`, WRITTEN BY THE SERVER
// so a contractor's approve/reject can reach the worker WITHOUT a cross-party
// client write (a client can never write another user's feed — the rule is
// self-only; only this Admin-SDK trigger crosses the boundary).
//
// Mirrors `onOrderStageChanged` (push.ts): react to a `tasks/{taskId}` status
// transition, and for the WORKER-FACING ones append a bell entry to the assigned
// worker's feed. The messages mirror the Dart engine
// (`state/tasks_engine.dart` approve/reject/approveProposal/auto-advance) so the
// bell reads identically to the local path.
//
// The feed doc is a single capped list: `workerNotifs/{uid} = { items: [...],
// updatedAt }`, newest-first, capped at 50 (the client `kWorkerNotifsCap`). A
// transaction read-modify-writes it so concurrent task events never lose an entry.
// ─────────────────────────────────────────────────────────────────────────────

import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import { asString, db, REGION } from "./common";

/// Cap per worker feed — mirrors the client `kWorkerNotifsCap` so the payload
/// stays small (oldest entries drop).
const CAP = 50;

/// One bell entry — the SAME shape the Dart `WorkerNotif.toJson` writes/decodes
/// (id · emoji · title · body · ts ISO-8601 · read), so the client reader is
/// byte-compatible with the local store it replaces.
interface Bell {
  id: string;
  emoji: string;
  title: string;
  body: string;
  ts: string;
  read: boolean;
}

/// The worker-facing message for a status transition, or null when the
/// transition is NOT worker-facing (a worker's own submit → `review`, a
/// proposal → `proposed`: those notify the contractor, not the bell). Mirrors
/// the Dart engine's `addForWorker` call sites verbatim.
function bellFor(from: string, to: string): { emoji: string; title: string } | null {
  if (to === "done") return { emoji: "✅", title: "המשימה אושרה" };
  if (to === "rejected") return { emoji: "🔁", title: "הוחזרה לתיקון" };
  if (to === "active" && from === "proposed") {
    return { emoji: "✅", title: "ההצעה אושרה — המשימה פעילה" };
  }
  if (to === "active" && from === "pending") {
    return { emoji: "📋", title: "משימה חדשה הוקצתה" };
  }
  return null; // →review / →proposed / no-op — not the worker's bell
}

export const onTaskStatusChanged = onDocumentUpdated(
  { region: REGION, document: "tasks/{taskId}" },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const from = asString(change.before.get("status")) ?? "";
    const to = asString(change.after.get("status")) ?? "";
    if (from === to) return; // not a status change

    const bell = bellFor(from, to);
    if (bell === null) return; // not a worker-facing transition

    const workerUid = asString(change.after.get("assignedWorkerUid")) ?? "";
    if (workerUid.length === 0) return; // unassigned → no one to notify

    const taskId = event.params.taskId;
    const name = asString(change.after.get("name")) ?? "";
    const entry: Bell = {
      id: `${taskId}-${to}-${event.time}`, // deterministic per transition
      emoji: bell.emoji,
      title: bell.title,
      body: name,
      ts: event.time,
      read: false,
    };

    try {
      const ref = db().collection("workerNotifs").doc(workerUid);
      await db().runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        const prev = (snap.exists ? snap.get("items") : null) as Bell[] | null;
        const items = [entry, ...(Array.isArray(prev) ? prev : [])].slice(0, CAP);
        tx.set(ref, { items, updatedAt: Date.now() }, { merge: true });
      });
    } catch (e) {
      logger.error("onTaskStatusChanged: bell write failed", {
        workerUid,
        taskId,
        error: String(e),
      });
    }
  }
);
