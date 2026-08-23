// Offline self-test of the PURE `parseSetEmployerInput` core — the credit.test.ts
// idiom (this repo carries no `firebase-functions-test`, so the onCall wrapper +
// Admin SDK writes are exercised only through the pure core tested here). It lives
// OUTSIDE src, so the deploy build (tsconfig include: ["src"]) never ships it.
//
// Run: `npx ts-node functions/test/setEmployer.test.ts`
//
// WHAT THIS CORE EXISTS TO GUARANTEE: the worker→employer link is server-truth.
// The admin-gate + Admin-SDK write live in the wrapper; the PURE decision here is
// exactly which payloads assign, which REVOKE, and which are rejected — the input
// contract a mis-call (or a hostile client that somehow reached an admin token)
// must not be able to bend (self-employer, path-escaping uid, wrong type).

import { parseSetEmployerInput } from "../src/setEmployerCore";

let failures = 0;

function check(label: string, actual: unknown, expected: unknown): void {
  const a = JSON.stringify(actual);
  const e = JSON.stringify(expected);
  if (a === e) {
    console.log(`  ok   ${label}`);
  } else {
    failures++;
    console.log(`  FAIL ${label}\n       expected ${e}\n       actual   ${a}`);
  }
}

console.log("parseSetEmployerInput — assign / revoke / reject");

check(
  "assigns a valid employer uid",
  parseSetEmployerInput("worker-1", "contractor-9"),
  { uid: "worker-1", employerValue: "contractor-9", revoke: false },
);

check(
  "null employerUid → REVOKE",
  parseSetEmployerInput("worker-1", null),
  { uid: "worker-1", employerValue: null, revoke: true },
);

check(
  "empty-string employerUid → REVOKE",
  parseSetEmployerInput("worker-1", ""),
  { uid: "worker-1", employerValue: null, revoke: true },
);

check(
  "absent employerUid (undefined) → REVOKE",
  parseSetEmployerInput("worker-1", undefined),
  { uid: "worker-1", employerValue: null, revoke: true },
);

check(
  "trims surrounding whitespace before assigning",
  parseSetEmployerInput("worker-1", "  contractor-9  "),
  { uid: "worker-1", employerValue: "contractor-9", revoke: false },
);

check(
  "THE GUARD: a worker cannot be their own employer",
  parseSetEmployerInput("uid-x", "uid-x"),
  { error: "a worker cannot be their own employer." },
);

check(
  "rejects a missing uid",
  parseSetEmployerInput("", "contractor-9"),
  { error: "uid (string) is required." },
);

check(
  "rejects a non-string uid",
  parseSetEmployerInput(42, "contractor-9"),
  { error: "uid (string) is required." },
);

check(
  "rejects a non-string employerUid",
  parseSetEmployerInput("worker-1", 7),
  { error: "employerUid must be a string, or null/'' to revoke." },
);

check(
  "PATH-SAFETY: rejects a uid with a slash (Firestore path escape)",
  parseSetEmployerInput("worker-1", "a/b"),
  {
    error: "employerUid must be 1-128 chars of letters, digits, '_' or '-'.",
  },
);

if (failures > 0) {
  throw new Error(`${failures} setEmployer core test(s) FAILED`);
}
console.log("\nall ok");
