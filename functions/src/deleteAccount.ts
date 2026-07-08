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

/// GDPR erasure of the CUSTOMER-INTELLIGENCE layer for [uid] (Studio Pillar-3) —
/// the server-side twin of the PURE Dart plan `eraseSubject`
/// (app_flutter/lib/state/intel/erasure.dart). The Dart plan is the TESTABLE spec
/// (erasure_completeness_test.dart proves ZERO residue); THIS runs the IDENTICAL
/// key-set against live Firestore.
///
/// The MULTI-KEY set (R1-3): the deleted [uid] PLUS the pre-login ANON keys stitched
/// to it (read from `actorStitch/{uid}`), so ORPHANED pre-stitch anon events (a
/// DIFFERENT `actor_key`) are erased too. Over that key-set {uid, ...anonKeys}:
///   • intelEvents  — where actor_key ∈ {uid, ...anonKeys}
///   • presence     — presence/{uid} AND presence/{actorKey}   (doc-id per key)
///   • sessions     — where actor_key ∈ {uid, ...anonKeys}     (forward-ready: no
///                    server session collection is written today — no-op now)
///   • displayName  — reset →'' on any RETAINED row (DEFENSIVE: IntelEvent.toWire
///                    NEVER serializes a displayName, R1-4 — the events are deleted
///                    above, so this matches zero docs today; the forward-ready hook
///                    mirrors the `customers.ownerId` no-op precedent)
///   • actorStitch/{uid} — the mapping doc itself, LAST (a mid-sweep failure leaves
///                    the anon→uid join intact for a retry)
/// Best-effort + paginated exactly like `purgeMultiPartyReferences`: one failure
/// never aborts the rest. Returns a per-target count for the audit trail.
async function purgeIntelForSubject(
  uid: string
): Promise<Record<string, number>> {
  const fs = db();
  const counts: Record<string, number> = {};
  const batchSize = 400;
  const maxRounds = 25;
  const inChunk = 30; // Firestore `in` operator ceiling

  // R1-3 — recover the anon keys stitched to this uid so PRE-login events (a
  // DIFFERENT actor_key) are reachable. Best-effort: a read failure ⇒ uid-only.
  let anonKeys: string[] = [];
  try {
    const stitchSnap = await fs.collection("actorStitch").doc(uid).get();
    const raw = stitchSnap.exists ? stitchSnap.get("anonKeys") : undefined;
    if (Array.isArray(raw)) {
      anonKeys = raw.filter(
        (k): k is string => typeof k === "string" && k.length > 0
      );
    }
  } catch (e) {
    logger.error("deleteAccount: actorStitch read failed", {
      uid,
      error: String(e),
    });
  }
  // The pseudonymous key-set the WHOLE sweep operates over: {uid, ...anonKeys}.
  const actorKeys = Array.from(new Set<string>([uid, ...anonKeys]));

  /// Purge every doc a chunked `actor_key in [...]` query returns — paginated +
  /// best-effort (mirrors `scrub`'s shape, deleting instead of updating). Firestore
  /// caps `in` at [inChunk] terms, so the key-set is chunked.
  async function purgeByActorKey(collection: string): Promise<void> {
    for (let i = 0; i < actorKeys.length; i += inChunk) {
      const chunk = actorKeys.slice(i, i + inChunk);
      try {
        for (let round = 0; round < maxRounds; round++) {
          const snap = await fs
            .collection(collection)
            .where("actor_key", "in", chunk)
            .limit(batchSize)
            .get();
          if (snap.empty) break;
          const batch = fs.batch();
          for (const doc of snap.docs) batch.delete(doc.ref);
          await batch.commit();
          counts[collection] = (counts[collection] ?? 0) + snap.size;
          if (snap.size < batchSize) break; // last page
        }
      } catch (e) {
        logger.error("deleteAccount: intel sweep failed", {
          uid,
          collection,
          error: String(e),
        });
      }
    }
  }

  // 1 · events — actor_key ∈ {uid, ...anonKeys} (INCLUDING the pre-stitch anon
  //     events, the orphan-risk rows reachable only via actorStitch).
  await purgeByActorKey("intelEvents");

  // 2 · presence — presence/{uid} AND presence/{actorKey} for EVERY key (doc-id
  //     keyed, so a plain get/delete per key — a signed-out actor's doc is anon-keyed,
  //     a signed-in actor's is uid-keyed; both must go).
  for (const key of actorKeys) {
    try {
      const ref = fs.collection("presence").doc(key);
      const snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
        counts["presence"] = (counts["presence"] ?? 0) + 1;
      }
    } catch (e) {
      logger.error("deleteAccount: presence sweep failed", {
        uid,
        key,
        error: String(e),
      });
    }
  }

  // 3 · sessions (if present) — actor_key ∈ {uid, ...anonKeys}. Forward-ready: the
  //     app mints session ids LOCALLY (no server `sessions` collection today), so
  //     this is a no-op now, wired so a future server session doc is swept too.
  await purgeByActorKey("sessions");

  // 4 · displayName reset (R1-4, DEFENSIVE) — after the wholesale event delete above,
  //     verify no RETAINED intel doc still carries a human displayName for this
  //     subject and scrub it →''. IntelEvent.toWire NEVER serializes a displayName,
  //     so this matches ZERO docs today (the events are already gone); it mirrors the
  //     Dart plan's resetDisplayNames step + the forward-ready `customers.ownerId`
  //     no-op precedent, catching any legacy / future retained-profile row.
  for (let i = 0; i < actorKeys.length; i += inChunk) {
    const chunk = actorKeys.slice(i, i + inChunk);
    try {
      for (let round = 0; round < maxRounds; round++) {
        const snap = await fs
          .collection("intelEvents")
          .where("actor_key", "in", chunk)
          .limit(batchSize)
          .get();
        if (snap.empty) break;
        const batch = fs.batch();
        let scrubbed = 0;
        for (const doc of snap.docs) {
          if (doc.get("displayName") !== undefined) {
            batch.update(doc.ref, { displayName: "" });
            scrubbed++;
          }
        }
        if (scrubbed > 0) {
          await batch.commit();
          counts["displayName.reset"] =
            (counts["displayName.reset"] ?? 0) + scrubbed;
        }
        if (snap.size < batchSize) break;
      }
    } catch (e) {
      logger.error("deleteAccount: displayName reset failed", {
        uid,
        error: String(e),
      });
    }
  }

  // 5 · actorStitch/{uid} — the mapping doc itself, LAST (a mid-sweep failure leaves
  //     the anon→uid join intact for a retry).
  try {
    const ref = fs.collection("actorStitch").doc(uid);
    const snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      counts["actorStitch"] = (counts["actorStitch"] ?? 0) + 1;
    }
  } catch (e) {
    logger.error("deleteAccount: actorStitch sweep failed", {
      uid,
      error: String(e),
    });
  }

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

  // 1c · GDPR erasure — sweep the CUSTOMER-INTELLIGENCE layer (Studio Pillar-3) for
  //      this uid + its stitched anon keys: intelEvents / presence / sessions /
  //      actorStitch + displayName reset. Multi-key + best-effort; the IDENTICAL
  //      key-set the pure Dart plan `eraseSubject` proves complete
  //      (app_flutter/.../erasure.dart · erasure_completeness_test.dart).
  const intelPurged = await purgeIntelForSubject(uid);

  // 2 · delete the Auth record itself (Admin SDK — bypasses recent-login).
  await getAuth().deleteUser(uid);
  logger.info("deleteAccount: erased", { uid, existed, scrubbed, intelPurged });

  await writeAudit({
    action: "account.delete",
    source: "deleteAccount",
    actorUid: uid,
    actorRole: roles.join(",") || null,
    target: `users/${uid}`,
    before: existed,
    after: { scrubbed, intelPurged },
    ok: true,
  });

  return { ok: true };
});
