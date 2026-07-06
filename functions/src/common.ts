// ─────────────────────────────────────────────────────────────────────────────
// Shared plumbing for the S8 server-side modules (orders/credit/push/r2/audit).
//
// IMPORTANT — load order: `index.ts` (the entrypoint) calls `initializeApp()`
// in its module body, but ES imports are hoisted ABOVE that call, so every
// module here executes first. Therefore modules must NEVER resolve an Admin
// SDK service at module scope — always lazily, inside a handler (by the time
// any handler runs, index.ts has long finished loading).
// ─────────────────────────────────────────────────────────────────────────────

import { getFirestore } from "firebase-admin/firestore";

/** The single deploy region — `me-west1` (Tel Aviv), matching the Firestore
 * database location and `kAuthFunctionsRegion` in the app (same constraint the
 * S1 `setRole` skeleton documents). EVERY function in this codebase must pass
 * this to its options. */
export const REGION = "me-west1";

/** Lazy Firestore handle (see load-order note above). */
export function db() {
  return getFirestore();
}

/** Coerce an unknown Firestore field to a non-empty string, else null. */
export function asString(v: unknown): string | null {
  return typeof v === "string" && v.length > 0 ? v : null;
}

/**
 * The caller's role surface from their ID-token custom claims, exactly as
 * `setRole` writes them (index.ts): a single `role: string`, a multi-role
 * `roles: string[]`, plus the bootstrap `admin: true` claim (returned as the
 * pseudo-role `"admin"`). Order: admin first, then role/roles as carried.
 */
export function callerRoles(token: Record<string, unknown>): string[] {
  const out: string[] = [];
  if (token.admin === true) out.push("admin");
  if (typeof token.role === "string" && token.role.length > 0) {
    out.push(token.role);
  }
  if (Array.isArray(token.roles)) {
    for (const r of token.roles) {
      if (typeof r === "string" && r.length > 0) out.push(r);
    }
  }
  return out;
}

/**
 * The BuildSmart OWNER account, by verified email. SSOT: the Flutter app's
 * `kOwnerEmails` (app_flutter/lib/data/board_accounts_local.dart:98) — a single
 * allow-listed Google account. Kept here (server) as the authority ROOT of the
 * publish-to-all path (`publishConfig`, Pillar-5 Step 56): a caller whose ID-
 * token email equals this may publish WITHOUT a second manager's dual-control
 * approval. Mirrored — same verbatim value — by the `isOwnerEmail()` helper in
 * firestore.rules (repo root) so the rules and the callable share ONE owner
 * identity. Stored lower-cased; the compare trims + lower-cases the token email,
 * exactly like the Dart `isOwnerEmail` (case/space-insensitive).
 */
export const OWNER_EMAIL = "meir7651231@gmail.com";

/**
 * True iff the authenticated caller's ID-token email is the app OWNER
 * ([OWNER_EMAIL]). Tolerant like its Dart twin (board_accounts_local.dart:102):
 * a null auth, an absent email, or a non-string yields false; a present email is
 * trimmed + lower-cased before the compare. Takes the whole `request.auth`
 * (structurally `{ token: { email } }`), so a handler passes `request.auth`
 * straight through — `isOwnerEmail(request.auth)`.
 */
export function isOwnerEmail(
  auth: { token?: { email?: unknown } } | null | undefined
): boolean {
  const email = auth?.token?.email;
  return typeof email === "string" && email.trim().toLowerCase() === OWNER_EMAIL;
}
