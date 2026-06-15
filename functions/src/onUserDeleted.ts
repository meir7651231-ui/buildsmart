// ─────────────────────────────────────────────────────────────────────────────
// Account-deletion server cleanup (GDPR right-to-erasure + Apple's in-app
// account-deletion requirement). The client's deleteAccount() calls the Firebase
// Auth `user.delete()` (lib/state/auth_state.dart, S1.8) — that removes ONLY the
// Auth record and leaves the user's Firestore footprint orphaned: their profile
// (displayName / phone / email / fcmToken) in `users/{uid}` and their FS_DIAG
// probe in `diag/{uid}`. This trigger fires on EVERY Auth deletion — in-app,
// Firebase console, or Admin SDK — and purges those uid-KEYED personal docs.
//
// Why v1 (firebase-functions/v1): Firebase Auth has NO v2 background trigger for
// deletion (v2 only ships the blocking beforeUserCreated / beforeUserSignedIn).
// v1 is part of the SAME firebase-functions package (^6 — no new dependency);
// region me-west1 matches the rest of this codebase and the Firestore location.
//
// SCOPE (deliberate): only docs keyed BY the uid — solely-personal, single-owner
// data — are deleted. Multi-party business records (orders, chatThreads /
// chatMessages, customers, projects, tasks) are intentionally RETAINED: each
// belongs to a transaction/conversation other users still see, and deleting it
// would corrupt those peers' data. Anonymizing the uid out of shared docs is a
// separate, heavier concern (a follow-up — see WIRING), not done here.
// ─────────────────────────────────────────────────────────────────────────────

import * as logger from "firebase-functions/logger";
import * as functionsV1 from "firebase-functions/v1";

import { writeAudit } from "./audit";
import { db, REGION } from "./common";

export const onUserDeleted = functionsV1
  .region(REGION)
  .auth.user()
  .onDelete(async (user) => {
    const uid = user.uid;
    // The uid-keyed personal docs (see SCOPE above) — nothing else is touched.
    const refs = [
      db().collection("users").doc(uid),
      db().collection("diag").doc(uid),
    ];
    // Best-effort per-doc: snapshot existence (for the audit before-state) then
    // delete, so one missing/failed doc never aborts the rest of the purge.
    const existed: Record<string, boolean> = {};
    await Promise.all(
      refs.map(async (ref) => {
        try {
          const snap = await ref.get();
          existed[ref.path] = snap.exists;
          if (snap.exists) await ref.delete();
        } catch (e) {
          logger.error("onUserDeleted: purge failed", {
            uid,
            path: ref.path,
            error: String(e),
          });
        }
      })
    );
    logger.info("onUserDeleted: purged personal docs", { uid, existed });

    await writeAudit({
      action: "account.delete",
      source: "onUserDeleted",
      // The deletion event carries no auth context; the deleted user IS the
      // subject of the erasure, so record their uid as the actor.
      actorUid: uid,
      actorRole: null, // custom claims are gone by the time this fires
      target: `users/${uid}`,
      before: existed,
      after: null,
      ok: true,
    });
  });
