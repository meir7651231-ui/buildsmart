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
