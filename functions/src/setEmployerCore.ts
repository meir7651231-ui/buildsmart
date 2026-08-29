// PURE core of the `setEmployer` callable — NO firebase imports, so the offline
// self-test (test/setEmployer.test.ts, the creditCore idiom) can import it with
// plain `ts-node`. The Firebase-bound wrapper (setEmployer.ts) calls this to
// decide, then does the admin-gated claim + users-doc write.

/** A Firebase-uid-safe shape: doc-id-safe charset, 1–128 chars — nothing that
 * could escape a Firestore path or smuggle structure into a claim. */
export const UID_PATTERN = /^[a-zA-Z0-9_-]{1,128}$/;

/** Resolve the raw `setEmployer` payload to `{ uid, employerValue, revoke }` or
 * an `{ error }` carrying the callable's invalid-argument message.
 * `employerValue === null` (from null/''/absent employerUid) is the REVOKE path;
 * a worker cannot be their own employer; a uid must be path-safe. No IO. */
export function parseSetEmployerInput(
  uid: unknown,
  employerUid: unknown,
):
  | { uid: string; employerValue: string | null; revoke: boolean }
  | { error: string } {
  if (typeof uid !== "string" || uid.length === 0) {
    return { error: "uid (string) is required." };
  }
  let employerValue: string | null = null;
  if (employerUid !== undefined && employerUid !== null && employerUid !== "") {
    if (typeof employerUid !== "string") {
      return { error: "employerUid must be a string, or null/'' to revoke." };
    }
    const trimmed = employerUid.trim();
    if (!UID_PATTERN.test(trimmed)) {
      return {
        error:
          "employerUid must be 1-128 chars of letters, digits, '_' or '-'.",
      };
    }
    if (trimmed === uid) {
      return { error: "a worker cannot be their own employer." };
    }
    employerValue = trimmed;
  }
  return { uid, employerValue, revoke: employerValue === null };
}
