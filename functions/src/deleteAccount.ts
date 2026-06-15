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
import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { callerRoles, db, REGION } from "./common";

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

  // 2 · delete the Auth record itself (Admin SDK — bypasses recent-login).
  await getAuth().deleteUser(uid);
  logger.info("deleteAccount: erased", { uid, existed });

  await writeAudit({
    action: "account.delete",
    source: "deleteAccount",
    actorUid: uid,
    actorRole: roles.join(",") || null,
    target: `users/${uid}`,
    before: existed,
    after: null,
    ok: true,
  });

  return { ok: true };
});
