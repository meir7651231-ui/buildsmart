// ─────────────────────────────────────────────────────────────────────────────
// Offline self-test of the PURE S8 logic (no Firebase, no emulator, no
// network): `npm run selftest` → tsc → node lib/selftest.js. Asserts:
//   • creditCore — the Dart-VM string hash + contractorCredit match the
//     ground-truth probe captured from `dart run` (Dart 3.7.2, 2026-06-10);
//   • orderFlow — the chain, single-step legality, and the per-transition
//     role authorization mirror sys_orders.dart / supplier_data.dart.
// This file is NOT exported by index.ts — it never deploys as a function.
// ─────────────────────────────────────────────────────────────────────────────

import { contractorCredit, CREDIT_PROBE, dartStringHashCode } from "./creditCore";
import {
  isLegalStep,
  nextStage,
  ORDER_FLOW,
  rolesAllowedFor,
  roleMayStep,
} from "./orderFlow";

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

// ── creditCore vs the Dart VM probe ─────────────────────────────────────────
for (const [name, hash, credit] of CREDIT_PROBE) {
  check(
    dartStringHashCode(name) === hash,
    `hash("${name}") === ${hash} (got ${dartStringHashCode(name)})`
  );
  check(
    contractorCredit(name) === credit,
    `credit("${name}") === ${credit} (got ${contractorCredit(name)})`
  );
}
// Band invariant on arbitrary input.
for (const n of ["x", "אבג", "long ".repeat(40)]) {
  const c = contractorCredit(n);
  check(c >= 30000 && c <= 120000 && c % 100 === 0, `band/₪100 for "${n}"`);
}

// ── orderFlow — chain + legality ─────────────────────────────────────────────
check(ORDER_FLOW.length === 6, "six stages");
check(nextStage("new") === "preparing", "new→preparing");
check(nextStage("transit") === "delivered", "transit→delivered");
check(nextStage("delivered") === null, "delivered is terminal");
check(isLegalStep("ready", "pickup"), "ready→pickup legal");
check(!isLegalStep("new", "ready"), "jump new→ready illegal");
check(!isLegalStep("pickup", "ready"), "backward pickup→ready illegal");
check(!isLegalStep("delivered", "new"), "wrap delivered→new illegal");
check(!isLegalStep("bogus", "new"), "unknown stage illegal");

// ── orderFlow — role authorization (sys_orders.dart behavior) ───────────────
check(roleMayStep(["store"], "new", "preparing"), "store: new→preparing");
check(roleMayStep(["store"], "preparing", "ready"), "store: preparing→ready");
check(roleMayStep(["store"], "ready", "pickup"), "store: ready→pickup hand-off");
check(!roleMayStep(["store"], "pickup", "transit"), "store ✗ pickup→transit");
check(roleMayStep(["courier"], "pickup", "transit"), "courier: pickup→transit");
check(
  roleMayStep(["courier"], "transit", "delivered"),
  "courier: transit→delivered"
);
check(!roleMayStep(["courier"], "ready", "pickup"), "courier ✗ ready→pickup");
check(!roleMayStep(["contractor"], "new", "preparing"), "contractor ✗ advance");
check(!roleMayStep(["worker"], "pickup", "transit"), "worker ✗ advance");
// manager/admin: any single step.
for (let i = 0; i < ORDER_FLOW.length - 1; i++) {
  const from = ORDER_FLOW[i];
  const to = ORDER_FLOW[i + 1];
  check(roleMayStep(["manager"], from, to), `manager: ${from}→${to}`);
  check(roleMayStep(["admin"], from, to), `admin: ${from}→${to}`);
}
// multi-role token: any granted role suffices.
check(
  roleMayStep(["worker", "courier"], "transit", "delivered"),
  "multi-role [worker,courier]: transit→delivered"
);
check(rolesAllowedFor("new", "preparing").includes("store"), "owner map: store");
check(
  rolesAllowedFor("transit", "delivered").includes("courier"),
  "owner map: courier"
);
check(rolesAllowedFor("new", "ready").length === 0, "no roles for a jump");

// ── verdict ──────────────────────────────────────────────────────────────────
console.log(`selftest: ${passed}/${passed + failed} PASS`);
if (failed > 0) {
  process.exitCode = 1;
}
