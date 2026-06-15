// ─────────────────────────────────────────────────────────────────────────────
// S1.8 — account-deletion server cleanup (GDPR right-to-erasure + Apple's in-app
// account-deletion requirement), as a GEN2 CALLABLE.
//
// Why a callable (not an Auth onDelete trigger): Firebase Auth has no GEN2
// background trigger for deletion, and this codebase is all gen2 (Cloud Run /
// Eventarc, region me-west1). A v1/gen1 `auth.user().onDelete` trigger requires
// a gen1 deploy path (App Engine instance + the v1 generateUploadUrl API) that
// this project doesn't have — it 403s and aborts `firebase deploy --only
// functions`, blocking the gen2 functions too. A callable stays gen2, deploys
// cleanly alongside the others, and gives the client a confirmed result.
//
// The client (lib/state/auth_state.dart, deleteAccount()) calls this, then signs
// out locally. The function VERIFIES the caller (request.auth.uid is the only
// account it can erase — no uid argument), purges the uid-keyed personal docs,
// then deletes the Auth record via the Admin SDK (no recent-login needed, unlike
// the client user.delete()), and audit-logs the erasure.
//
// SCOPE (deliberate): only docs keyed BY the uid — solely-personal, single-owner
// data — are deleted. Multi-party records (orders, chatThreads / chatMessages,
// customers, projects, tasks) are intentionally RETAINED: each belongs to a
// transaction/conversation other users still see, and deleting it would corrupt
// those peers' data. Anonymizing the uid out of shared docs is a separate,
// heavier follow-up (functions/README TODO), not done here.
// ─────────────────────────────────────────────────────────────────────────────

import { getAuth } from "firebase-admin/auth";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { callerRoles, db, REGION } from "./common";

/// GDPR cascade — sever the deleted [uid]'s personal LINK from multi-party docs
/// (the records stay for the OTHER parties; only the uid reference is scrubbed).
/// Best-effort + paginated (batches of [batchSize], capped at [maxRounds] per
/// field to bound runaway); a failure on one field never aborts the rest.
/// Returns a per-target scrub count for the audit trail.
async function purgeMultiPartyReferences(
  uid: string
): Promise<Record<string, number>> {
  const fs = db();
  const counts: Record<string, number> = {};
  const batchSize = 400;
  const maxRounds = 25;

  /// Scrub every doc where [field] equals/contains [uid], applying [update].
  /// `arrayContains` is for the participantUids membership array.
  async function scrub(
    collection: string,
    field: string,
    update: Record<string, unknown>, {
      arrayContains = false,
    }: { arrayContains?: boolean } = {}
  ): Promise<void> {
    const key = `${collection}.${field}`;
    try {
      for (let round = 0; round < maxRounds; round++) {
        const q = arrayContains
          ? fs.collection(collection).where(field, "array-contains", uid)
          : fs.collection(collection).where(field, "==", uid);
        const snap = await q.limit(batchSize).get();
        if (snap.empty) break;
        const batch = fs.batch();
        for (const doc of snap.docs) batch.update(doc.ref, update);
        await batch.commit();
        counts[key] = (counts[key] ?? 0) + snap.size;
        if (snap.size < batchSize) break; // last page
      }
    } catch (e) {
      logger.error("deleteAccount: cascade scrub failed", {
        uid,
        collection,
        field,
        error: String(e),
      });
    }
  }

  // orders — sever whichever party-uid the deleted user held (the order record
  // remains for the other parties + manager/admin; the personal link is gone).
  await scrub("orders", "contractorUid", {
    contractorUid: FieldValue.delete(),
  });
  await scrub("orders", "storeUid", { storeUid: FieldValue.delete() });
  await scrub("orders", "courierUid", { courierUid: FieldValue.delete() });
  // chatMessages — sever authorship (the message text stays in the thread).
  await scrub("chatMessages", "fromUid", { fromUid: FieldValue.delete() });
  // customers — sever ownership (forward-ready: ownerId not yet written → no-op).
  await scrub("customers", "ownerId", { ownerId: FieldValue.delete() });
  // chatThreads — drop the uid from the membership array (thread stays for peers).
  await scrub(
    "chatThreads",
    "participantUids",
    { participantUids: FieldValue.arrayRemove(uid) },
    { arrayContains: true },
  );

  return counts;
}

export const deleteAccount = onCall({ region: REGION }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const uid = request.auth.uid;
  const roles = callerRoles(request.auth.token);

  // 1 · purge the uid-keyed personal docs (see SCOPE above). Best-effort per
  //     doc: a missing/failed doc never aborts the rest of the erasure.
  const refs = [
    db().collection("users").doc(uid),
    db().collection("diag").doc(uid),
  ];
  const existed: Record<string, boolean> = {};
  await Promise.all(
    refs.map(async (ref) => {
      try {
        const snap = await ref.get();
        existed[ref.path] = snap.exists;
        if (snap.exists) await ref.delete();
      } catch (e) {
        logger.error("deleteAccount: purge failed", {
          uid,
          path: ref.path,
          error: String(e),
        });
      }
    })
  );

  // 1b · GDPR cascade — sever the uid from multi-party docs (orders/chat/
  //      customers); the records stay for the other parties, only the link goes.
  const scrubbed = await purgeMultiPartyReferences(uid);

  // 2 · delete the Auth record itself (Admin SDK — bypasses recent-login).
  await getAuth().deleteUser(uid);
  logger.info("deleteAccount: erased", { uid, existed, scrubbed });

  await writeAudit({
    action: "account.delete",
    source: "deleteAccount",
    actorUid: uid,
    actorRole: roles.join(",") || null,
    target: `users/${uid}`,
    before: existed,
    after: { scrubbed },
    ok: true,
  });

  return { ok: true };
});
