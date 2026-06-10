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
