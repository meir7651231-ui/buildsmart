// ─────────────────────────────────────────────────────────────────────────────
// S8.2 core — EXACT port of the deterministic contractor-credit logic.
// PURE module (no Firebase imports) so `selftest.ts` can exercise it offline.
//
// SOURCE (read 2026-06-10): app_flutter/lib/logic/manager_dashboard.dart
// `contractorCredit(String name)` — note: the SSOT row pointed at
// lib/state/orders_engine.dart, but the function actually lives in
// logic/manager_dashboard.dart (orders_engine.dart only consumes it via
// `mgrCustomerList`). Ported verbatim:
//
//   int contractorCredit(String name) {
//     const lo = 30000;
//     const hi = 120000;
//     const span = hi - lo; // 90,000
//     // Stable non-negative hash → bucket within the band, rounded to ₪100.
//     final h = name.hashCode.abs();
//     final raw = lo + (h % (span + 1));
//     return (raw ~/ 100) * 100;
//   }
//
// `name.hashCode` is Dart's String hash. [dartStringHashCode] below replicates
// the Dart VM algorithm (runtime/vm/hash.h `CombineHashes`/`FinalizeHash` over
// UTF-16 code units, masked to kHashBits=30, 0→1) — the hash the app produces
// on iOS/Android (the store-launch targets). VERIFIED bit-for-bit against
// `dart run` (Dart 3.7.2) — see CREDIT_PROBE + selftest.ts.
//
// ⚠️ Dart does NOT guarantee hashCode stability across platforms: dart2js
// (Flutter web) masks to 29 bits per round and yields DIFFERENT values. The
// server value computed here is therefore the CANONICAL credit ceiling; the
// client-side derivation matches it exactly on native and is superseded by
// `computeCredit` (credit.ts) once connected.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Dart VM `String.hashCode` — Jenkins one-at-a-time over UTF-16 code units,
 * all arithmetic mod 2^32, finalized and masked to 30 bits (never 0).
 */
export function dartStringHashCode(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = (h + s.charCodeAt(i)) >>> 0; // hash += codeUnit
    h = (h + ((h << 10) >>> 0)) >>> 0; // hash += hash << 10
    h = (h ^ (h >>> 6)) >>> 0; // hash ^= hash >> 6
  }
  h = (h + ((h << 3) >>> 0)) >>> 0; // hash += hash << 3
  h = (h ^ (h >>> 11)) >>> 0; // hash ^= hash >> 11
  h = (h + ((h << 15) >>> 0)) >>> 0; // hash += hash << 15
  h = h & 0x3fffffff; // mask to kHashBits = 30
  return h === 0 ? 1 : h; // FinalizeHash zero-guard
}

/**
 * EXACT port of `contractorCredit` (see module header): a deterministic hash
 * of the contractor's name into the 30,000–120,000 ₪ band, floored to ₪100.
 * The hash is already non-negative (30-bit) so Dart's `.abs()` is a no-op.
 */
export function contractorCredit(name: string): number {
  const lo = 30000;
  const hi = 120000;
  const span = hi - lo; // 90,000
  const h = dartStringHashCode(name);
  const raw = lo + (h % (span + 1));
  return Math.floor(raw / 100) * 100; // Dart `(raw ~/ 100) * 100` (raw ≥ 0)
}

/**
 * Authoritative order total = Σ(line.price). Each line's `price` is ALREADY the
 * full line total (the client stamps `OrderLineItem.price = lineTotal`, qty is
 * informational, not a multiplier), so we sum `price` alone — multiplying by qty
 * would double-count. Tolerant of malformed input: non-array → 0, and any line
 * whose `price` isn't a finite number contributes 0. Used by `computeCredit` to
 * fold `used` from each order's lines instead of trusting a client-written `sum`.
 */
export function orderSum(lines: unknown): number {
  if (!Array.isArray(lines)) return 0;
  let t = 0;
  for (const l of lines) {
    const p = (l as { price?: unknown })?.price;
    if (typeof p === "number" && Number.isFinite(p)) t += Math.round(p);
  }
  return t;
}

/**
 * Ground truth captured from the Dart VM (dart 3.7.2, 2026-06-10):
 * `[name, name.hashCode, contractorCredit(name)]`. The first four names are
 * the seed contractors (`kManagerOrderSeed.who`). Asserted by selftest.ts.
 */
export const CREDIT_PROBE: ReadonlyArray<readonly [string, number, number]> = [
  ["יוסי כהן", 1056602882, 111100],
  ["אבי מזרחי", 577043904, 77400],
  ["משה אברהם", 593147781, 71100],
  ["דוד לוי", 1056795669, 33900],
  ["", 1, 30000],
  ["a", 170824770, 32800],
  ["Test Name 123", 701781088, 73200],
  ["בניין הרצליה 12", 426786400, 31600],
  ["🦺 עובד", 8297365, 47200],
];

/** Whose orders a credit query is allowed to fold, and under which key.
 *
 * SPLIT OUT AS A PURE CORE because it is the security decision, and the only
 * part of `computeCredit` that can be tested without Firebase — the same shape
 * as `mayReviewRoleRequest` beside its transaction.
 *
 * THE HOLE IT CLOSES. Ownership used to be decided by reading
 * `users/{uid}.displayName` and comparing it to the requested name. The users
 * update rule freezes role/roles/storeUid/orgId/status and nothing else, so
 * displayName is self-writable by design — the login flow mirrors it there. A
 * contractor wrote a colleague's exact name into their own document and the
 * comparison then passed, handing them that colleague's spend and standing. The
 * gate was asking a question the caller got to answer.
 *
 * So a non-manager is scoped BY UID and the name they sent is discarded, not
 * validated: there is no value they control anywhere in the decision. Keying on
 * the uid also fixes a quieter bug — `contractorId` is a display name, and two
 * contractors registering under the same one would have folded each other's
 * orders into a single total.
 *
 * A manager keeps the name query. They are permitted to read anyone, and the
 * historical documents they browse are keyed that way. */
export function creditScopeFor(opts: {
  callerUid: string;
  isManager: boolean;
}): { byUid: string | null; byName: boolean } {
  return opts.isManager
    ? { byUid: null, byName: true }
    : { byUid: opts.callerUid, byName: false };
}

/** A credit ceiling is READ, never derived.
 *
 * `contractorCredit` above is a hash of a person's name in the 30,000–120,000 ₪
 * band — a demo prop. Returning it from the server was worse than returning it
 * on the client, because the client is told the server is the one authority on
 * credit: a number with no basis arrived carrying that authority, was rendered
 * under the heading "the REAL credit figures", and was fed to an advisor that
 * reasons about approving the next order.
 *
 * Zero means "not on record", which the app renders as "לא רשומה" rather than
 * "₪0" — a different and equally false claim. A degraded read must look
 * degraded. */
export function readCreditLimit(stored: unknown): number {
  return typeof stored === "number" && Number.isFinite(stored) && stored > 0
    ? Math.round(stored)
    : 0;
}
