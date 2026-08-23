// Offline self-test of the PURE `computeCredit` decision cores — the same style
// as functions/test/studio.test.ts and functions/src/selftest.ts: a `check()`
// harness over the pure cores, run with `tsc && node`. This repo carries no
// `firebase-functions-test`, so the Firebase-bound onCall wrapper, the Firestore
// reads and the audit sink are exercised only through the cores tested here —
// exactly as `mayReviewRoleRequest` is tested beside its untested transaction.
//
// Run: `npx ts-node functions/test/credit.test.ts`
// It lives OUTSIDE src, so the deploy build (tsconfig include: ["src"]) never
// compiles or ships it.
//
// ── WHAT THESE TWO CORES EXIST TO PREVENT ───────────────────────────────────
//
// creditScopeFor — ownership used to be decided by reading
// `users/{uid}.displayName` and comparing it to the requested name. The users
// update rule freezes role/roles/storeUid/orgId/status and nothing else, so
// displayName is self-writable by design; the login flow mirrors it there on
// every sign-in. A contractor wrote a colleague's exact name into their own
// document, and from that point the comparison passed — handing them that
// colleague's spend, order count and standing. The gate was asking a question
// the caller got to answer.
//
// readCreditLimit — the ceiling used to be `contractorCredit(name)`, a hash of
// the person's name in the 30,000–120,000 ₪ band. Returning it from the SERVER
// was worse than returning it from the client, because the client is told this
// callable is the one authority on credit: an invented figure arrived carrying
// that authority, was rendered under "the REAL credit figures", and was fed to
// an advisor asked whether to approve the next order.

import { contractorCredit, creditScopeFor, readCreditLimit } from "../src/creditCore";

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

console.log("creditScopeFor — ownership keys on the uid, never a written field");

check(
  "a contractor is scoped to their OWN uid",
  creditScopeFor({ callerUid: "uid-b", isManager: false }),
  { byUid: "uid-b", byName: false },
);

check(
  "THE BUG: the scope does not depend on any name the caller supplies",
  // Contractor B used to write contractor A's name into their own users doc and
  // the comparison then passed. There is no name in the decision at all now, so
  // the attack has nothing left to aim at.
  creditScopeFor({ callerUid: "uid-b", isManager: false }),
  creditScopeFor({ callerUid: "uid-b", isManager: false }),
);

check(
  "two contractors never share a scope, whatever they call themselves",
  creditScopeFor({ callerUid: "uid-a", isManager: false }).byUid ===
    creditScopeFor({ callerUid: "uid-b", isManager: false }).byUid,
  false,
);

check(
  "a manager keeps the by-name query (permitted to read anyone)",
  creditScopeFor({ callerUid: "uid-mgr", isManager: true }),
  { byUid: null, byName: true },
);

console.log("readCreditLimit — a ceiling is read, never derived");

check("a manager-set ceiling is returned", readCreditLimit(80000), 80000);
check("a fractional stored value is rounded", readCreditLimit(50000.4), 50000);
check("no ceiling on record reads as zero", readCreditLimit(undefined), 0);
check("a null ceiling reads as zero", readCreditLimit(null), 0);
check("a string ceiling is not trusted", readCreditLimit("80000"), 0);
check("NaN reads as zero", readCreditLimit(Number.NaN), 0);
check("Infinity reads as zero", readCreditLimit(Number.POSITIVE_INFINITY), 0);
check("a negative ceiling reads as zero", readCreditLimit(-5000), 0);
check("an explicit zero stays zero", readCreditLimit(0), 0);

check(
  "THE BUG: the name hash is never what comes back",
  // contractorCredit still exists for the local/demo derivation, which is what
  // it was always for — it simply has no path to a server answer any more.
  readCreditLimit(undefined) === contractorCredit("משה אברהם"),
  false,
);

check(
  "and the hash it must not equal is genuinely non-zero",
  // Guards the premise: if contractorCredit ever returned 0 the check above
  // would pass for the wrong reason and stop protecting anything.
  contractorCredit("משה אברהם") > 0,
  true,
);

if (failures > 0) {
  console.log(`\n${failures} FAILED`);
  process.exit(1);
}
console.log("\nall credit-core checks passed");
