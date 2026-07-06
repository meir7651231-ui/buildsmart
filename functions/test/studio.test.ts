// ─────────────────────────────────────────────────────────────────────────────
// Offline self-test of the PURE Step-56 `publishConfig` logic (no Firebase, no
// emulator, no network) — the SAME style as functions/src/selftest.ts (the
// repo's only existing functions test: a `check()` harness over the PURE cores,
// run `tsc && node`). This repo carries NO `firebase-functions-test` dependency,
// and the Firebase-bound onCall wrapper / transaction / audit sink are exercised
// through their PURE decision cores here — exactly as reviewRoleRequest's matrix
// is tested via `mayReviewRoleRequest` while its transaction/claim-grant is not.
//
// Run: `npx ts-node functions/test/studio.test.ts`  (or compile with a test
// tsconfig, then `node`). It is OUTSIDE `src`, so the deploy build
// (tsconfig `include: ["src"]`) never compiles or ships it.
//
// COVERS the Step-56 test matrix (spec detail/051-068.md §56.5):
//   • happy-path → {ok, version:N}         (owner, equal base, live-allow ON)
//   • stale expectedBaseVersion → failed-precondition, published UNCHANGED (CAS)
//   • single manager, no isOwnerEmail, no dual-control → permission-denied
//   • revoked allow-flag → permission-denied EVEN with a valid owner claim
//   • rate-limit exceeded → the predicate that maps to resource-exhausted
//   • every denial verdict carries ok:false → the flag written to auditLog
// ─────────────────────────────────────────────────────────────────────────────

import { decidePublish, rateLimitExceeded } from "../src/studio";
import type { PublishVerdict } from "../src/studio";
import { isOwnerEmail, OWNER_EMAIL } from "../src/common";

let passed = 0;
let failed = 0;

function check(cond: boolean, msg: string): void {
  if (cond) {
    passed++;
  } else {
    failed++;
    console.error(`FAIL · ${msg}`);
  }
}

/** Assert a denial verdict — the `code` the handler throws AND the ok:false it
 * writes to auditLog (spec §56.5 "denial writes audit ok:false"). */
function expectDeny(
  v: PublishVerdict,
  code: "failed-precondition" | "permission-denied",
  label: string
): void {
  if (v.ok) {
    check(false, `${label} — expected DENY, got ok`);
    return;
  }
  check(v.code === code, `${label} — code ${code} (got ${v.code})`);
  check(v.ok === false, `${label} — audit ok:false`);
}

/** Assert a successful verdict advances published → [toVersion] (= what the
 * callable returns as `version` and freezes as the vN snapshot). */
function expectOk(v: PublishVerdict, toVersion: number, label: string): void {
  if (!v.ok) {
    check(false, `${label} — expected OK, got deny ${v.code}`);
    return;
  }
  check(v.toVersion === toVersion, `${label} — toVersion ${toVersion} (got ${v.toVersion})`);
  check(v.fromVersion === toVersion - 1, `${label} — fromVersion ${toVersion - 1}`);
}

// ── isOwnerEmail — the authority root (mirrors board_accounts_local.dart) ─────
check(isOwnerEmail({ token: { email: OWNER_EMAIL } }), "owner email → true");
check(
  isOwnerEmail({ token: { email: "  MEIR7651231@Gmail.COM  " } }),
  "owner email is case/space-insensitive → true"
);
check(!isOwnerEmail({ token: { email: "someone@else.com" } }), "other email → false");
check(!isOwnerEmail({ token: {} }), "absent email → false");
check(!isOwnerEmail({ token: { email: 42 } }), "non-string email → false");
check(!isOwnerEmail(null), "null auth → false");
check(!isOwnerEmail(undefined), "undefined auth → false");

// ── decidePublish · HAPPY-PATH → {ok, version:N} ─────────────────────────────
// Owner, live-allow ON, base == published(7) → publishes v8.
expectOk(
  decidePublish({
    publishedVersion: 7,
    expectedBaseVersion: 7,
    isOwner: true,
    dualControlApproved: false,
    liveAllow: true,
  }),
  8,
  "owner happy-path"
);
// version 0 backend (no published doc yet) → first publish is v1.
expectOk(
  decidePublish({
    publishedVersion: 0,
    expectedBaseVersion: 0,
    isOwner: true,
    dualControlApproved: false,
    liveAllow: true,
  }),
  1,
  "genesis publish 0→1"
);
// Dual-control happy-path: NOT the owner, but a second manager approved.
expectOk(
  decidePublish({
    publishedVersion: 3,
    expectedBaseVersion: 3,
    isOwner: false,
    dualControlApproved: true,
    liveAllow: true,
  }),
  4,
  "dual-control happy-path"
);

// ── decidePublish · CAS — stale expectedBaseVersion → failed-precondition ─────
// published moved to 5 while the draft branched from 3 → CONFLICT, not overwrite.
// verdict.ok === false ⇒ the handler never flips ⇒ published stays 5 (unchanged).
expectDeny(
  decidePublish({
    publishedVersion: 5,
    expectedBaseVersion: 3,
    isOwner: true,
    dualControlApproved: false,
    liveAllow: true,
  }),
  "failed-precondition",
  "CAS stale base (3<5)"
);
// Even a base AHEAD of published is a conflict (exact compare-and-set, not >=).
expectDeny(
  decidePublish({
    publishedVersion: 4,
    expectedBaseVersion: 9,
    isOwner: true,
    dualControlApproved: false,
    liveAllow: true,
  }),
  "failed-precondition",
  "CAS base ahead (9≠4)"
);

// ── decidePublish · single manager, no owner, no dual-control → denied ────────
expectDeny(
  decidePublish({
    publishedVersion: 2,
    expectedBaseVersion: 2,
    isOwner: false,
    dualControlApproved: false,
    liveAllow: true,
  }),
  "permission-denied",
  "single manager without owner/dual-control"
);

// ── decidePublish · revoked live allow-flag → denied EVEN with a valid claim ──
// isOwner:true (a valid token claim) but liveAllow:false ⇒ still denied — the
// seconds-not-hours revocation. Base is equal, so the ONLY reason is the flag.
expectDeny(
  decidePublish({
    publishedVersion: 6,
    expectedBaseVersion: 6,
    isOwner: true,
    dualControlApproved: true,
    liveAllow: false,
  }),
  "permission-denied",
  "revoked allow-flag denies a valid owner"
);

// ── rateLimitExceeded → maps to resource-exhausted ───────────────────────────
const now = 1_000_000;
const win = 60_000;
const max = 12;
check(!rateLimitExceeded(undefined, now, win, max), "fresh (no doc) → allowed");
check(
  !rateLimitExceeded({ windowStart: now, count: 11 }, now, win, max),
  "under budget (11<12) → allowed"
);
check(
  rateLimitExceeded({ windowStart: now, count: 12 }, now, win, max),
  "at budget (12>=12) → resource-exhausted"
);
check(
  rateLimitExceeded({ windowStart: now, count: 99 }, now, win, max),
  "over budget → resource-exhausted"
);
check(
  !rateLimitExceeded({ windowStart: now - win - 1, count: 999 }, now, win, max),
  "expired window resets → allowed"
);

// ── verdict ──────────────────────────────────────────────────────────────────
console.log(`studio.test: ${passed}/${passed + failed} PASS`);
if (failed > 0) {
  process.exitCode = 1;
}
