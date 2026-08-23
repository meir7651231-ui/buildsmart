// directory — the small, readable "who exists here" list.
//
// WHY IT HAS TO EXIST. Chat threads are isolated by `participantUids`, and the
// app fills that list by resolving the other side's uids from their role. It did
// that by reading the whole `users` collection — which the rules correctly deny
// to everyone except an admin, since `users` holds phone numbers, e-mail
// addresses and approval status. The client caught the denial and "degraded
// gracefully" to stamping only the sender.
//
// The result was a silent, exact inversion of the feature: every thread became
// private to whoever wrote in it first. Two contractors could type into the same
// conversation and neither would ever see the other. It appeared to work only
// for the owner, because the owner is an admin and their read succeeds.
//
// So this is a SECOND collection carrying the minimum needed to address someone:
//
//     directory/{uid} = { role, displayName, status, updatedAt }
//
// No phone, no e-mail, nothing that is not already implied by being able to send
// a person a message. Readable by any signed-in, non-anonymous user; writable
// only from here.
//
// WRITTEN SERVER-SIDE ON PURPOSE: `role` is the field every permission decision
// keys on, and it lives in the custom claims. If a client could write it, the
// directory would be a way to claim a role by asserting one. Here it is read
// back from the claims, so it cannot be forged.
//
// It is also the foundation the rest of the messaging work needs — a contractor
// list to start a conversation from, a support channel to the owner, and a
// last-seen stamp for "who is online" — which is why it is worth building once
// rather than widening the `users` read rule and hoping.

import { getAuth } from "firebase-admin/auth";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { asString, db, REGION } from "./common";

/** What the Auth record knows: the role claim, and the name the provider gave.
 *
 * ONE `getUser` call for both, because they answer the same question — how this
 * person is addressed — and a second round trip would only be a way for the two
 * to disagree. */
async function fromAuth(
  uid: string
): Promise<{ role: string; displayName: string; email: string }> {
  try {
    const user = await getAuth().getUser(uid);
    return {
      role: asString(user.customClaims?.role) ?? "contractor",
      displayName: (user.displayName ?? "").trim(),
      email: (user.email ?? "").trim(),
    };
  } catch (e) {
    logger.warn("directory: could not read the auth record", {
      uid,
      e: String(e),
    });
    return { role: "contractor", displayName: "", email: "" };
  }
}

/** The name to show, in the order the sources actually know one.
 *
 * Google hands over a real display name and the person never types anything, so
 * for a Google account the Auth record is the ONLY place a name exists — take it
 * first. A phone sign-up is the mirror image: no provider name, but a name typed
 * at registration, which is what `users.displayName` holds.
 *
 * Last resort is the e-mail's local part rather than a blank: a list of unnamed
 * rows is a list nobody can pick a person out of, and an address at least
 * identifies who it is. */
function pickName(authName: string, typedName: string, email: string): string {
  if (authName.length > 0) return authName;
  if (typedName.length > 0) return typedName;
  const at = email.indexOf("@");
  return at > 0 ? email.slice(0, at) : email;
}

/** Upsert `directory/{uid}` from the authoritative sources.
 *
 * Exported so the paths that change a role — `setRole` and the approval in
 * `reviewRoleRequest` — can refresh the entry immediately, instead of waiting
 * for the next unrelated write to `users`. Merge-writes, so a `lastSeenAt` the
 * client stamped for presence is never clobbered. */
export async function syncDirectoryEntry(uid: string): Promise<void> {
  if (!uid) return;
  const userSnap = await db().collection("users").doc(uid).get();
  if (!userSnap.exists) return; // not a real account (anonymous browser)

  const auth = await fromAuth(uid);

  await db()
    .collection("directory")
    .doc(uid)
    .set(
      {
        role: auth.role,
        displayName: pickName(
          auth.displayName,
          (asString(userSnap.get("displayName")) ?? "").trim(),
          auth.email
        ),
        // Carried so a list can show who is still waiting — the approval queue
        // and the people list are then the same data, not two truths.
        status: asString(userSnap.get("status")) ?? "pending",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
}

/** Keep the directory in step with `users/{uid}`.
 *
 * `onDocumentWritten` rather than `onCreate`: an account's display name changes,
 * and approval flips `status` — both have to reach the list. Deletion removes
 * the entry, so a deleted account stops being addressable. */
export const onUserDocWritten = onDocumentWritten(
  { region: REGION, document: "users/{uid}" },
  async (event) => {
    const uid = event.params.uid;
    const after = event.data?.after;
    if (!after?.exists) {
      await db().collection("directory").doc(uid).delete().catch(() => undefined);
      return;
    }
    await syncDirectoryEntry(uid);
  }
);
