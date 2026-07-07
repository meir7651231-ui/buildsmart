// ─────────────────────────────────────────────────────────────────────────────
// Offline self-test of the PURE S8 logic (no Firebase, no emulator, no
// network): `npm run selftest` → tsc → node lib/selftest.js. Asserts:
//   • creditCore — the Dart-VM string hash + contractorCredit match the
//     ground-truth probe captured from `dart run` (Dart 3.7.2, 2026-06-10);
//   • orderFlow — the chain, single-step legality, and the per-transition
//     role authorization mirror sys_orders.dart / supplier_data.dart.
// This file is NOT exported by index.ts — it never deploys as a function.
// ─────────────────────────────────────────────────────────────────────────────

import * as fs from "fs";
import * as path from "path";

import {
  contractorCredit,
  CREDIT_PROBE,
  dartStringHashCode,
  orderSum,
} from "./creditCore";
import {
  isLegalStep,
  nextStage,
  ORDER_FLOW,
  rolesAllowedFor,
  roleMayStep,
} from "./orderFlow";
import { mayReviewRoleRequest } from "./reviewRoleRequest";

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

// ── orderSum — authoritative total = Σ line.price (qty is NOT a multiplier) ──
check(orderSum([{ price: 600 }, { price: 300 }]) === 900, "orderSum sums price");
check(orderSum([]) === 0, "orderSum([]) === 0");
check(orderSum(undefined) === 0, "orderSum(undefined) === 0");
check(orderSum("x") === 0, 'orderSum("x") === 0 (non-array)');
check(orderSum([{ qty: 5, price: 100 }]) === 100, "orderSum ignores qty (≠500)");

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

// ── #6 role-request approval matrix (reviewRoleRequest authz) ────────────────
// worker→contractor · courier→store · store/contractor→manager · admin=any.
check(mayReviewRoleRequest(["contractor"], "worker"), "contractor reviews worker");
check(mayReviewRoleRequest(["store"], "courier"), "store reviews courier");
check(mayReviewRoleRequest(["manager"], "store"), "manager reviews store");
check(mayReviewRoleRequest(["manager"], "contractor"), "manager reviews contractor");
check(mayReviewRoleRequest(["admin"], "worker"), "admin reviews anything (worker)");
check(mayReviewRoleRequest(["admin"], "store"), "admin reviews anything (store)");
check(
  mayReviewRoleRequest(["worker", "courier"], "worker") === false,
  "worker/courier cannot review a worker"
);
check(
  mayReviewRoleRequest(["contractor"], "courier") === false,
  "contractor cannot review a courier (store does)"
);
check(
  mayReviewRoleRequest(["store"], "worker") === false,
  "store cannot review a worker (contractor does)"
);
check(
  mayReviewRoleRequest(["manager"], "worker") === false,
  "manager does NOT review a worker (contractor does)"
);
check(
  mayReviewRoleRequest([], "worker") === false,
  "a role-less caller reviews nothing"
);
check(
  mayReviewRoleRequest(["contractor"], "manager") === false,
  "manager is not a requestable/reviewable role"
);

// ── P5.68 · deploy-ordering CI-assertion (R2-10) ─────────────────────────────
// The Studio publish/catalog path ships server artifacts in a HARD order:
//   bootstrap studioConfig/published → rules-lock → indexes (GATE) →
//   wait-indexes-READY → functions (gated on index-deploy SUCCESS).
// A functions deploy that races AHEAD of its composite index makes the
// token-indexer / rollups throw FAILED_PRECONDITION; a rules-lock BEFORE the
// pointer seed blocks the bootstrap. This OFFLINE check pins that ordering in
// `.github/workflows/firebase-deploy.yml`, so any future edit that reorders the
// steps or re-adds `continue-on-error` fails `npm run selftest` — no emulator,
// no network, no Firebase (same contract as the pure S8 logic above).
const wfPath = path.resolve(
  __dirname,
  "..",
  "..",
  ".github",
  "workflows",
  "firebase-deploy.yml"
);
check(fs.existsSync(wfPath), `deploy workflow present (${wfPath})`);
if (fs.existsSync(wfPath)) {
  const wf = fs.readFileSync(wfPath, "utf8");
  const iBootstrap = wf.indexOf("Bootstrap studioConfig/published pointer");
  const iRules = wf.indexOf("name: Deploy Firestore rules");
  const iIndexes = wf.indexOf("id: indexes");
  const iReady = wf.indexOf("collectionGroups/-/indexes");
  const iGate = wf.indexOf("steps.indexes.outcome == 'success'");

  check(
    wf.includes("bootstrap-studio-pointer.mjs"),
    "R2-10(a): deploy runs the studioConfig/published bootstrap script"
  );
  check(iBootstrap >= 0, "R2-10(a): bootstrap-pointer step present");
  check(iRules >= 0, "deploy has a Firestore-rules step");
  check(
    iBootstrap >= 0 && iRules >= 0 && iBootstrap < iRules,
    "R2-10(a): bootstrap-pointer runs BEFORE the rules-lock"
  );
  check(iIndexes >= 0, "R2-10(b): indexes step is id-tagged (id: indexes) for gating");
  check(
    iRules >= 0 && iIndexes >= 0 && iRules < iIndexes,
    "R2-10: indexes deploy after the rules step"
  );
  check(iReady >= 0, "R2-10(d): an index-READY poll is present");
  check(
    iIndexes >= 0 && iReady >= 0 && iIndexes < iReady,
    "R2-10(d): READY-poll runs AFTER the indexes deploy"
  );
  check(iGate >= 0, "R2-10(c): functions deploy is gated on index-deploy success");
  check(
    iReady >= 0 && iGate >= 0 && iReady < iGate,
    "R2-10(c/d): the gated functions deploy runs AFTER the READY-poll"
  );
  check(
    !wf.includes("continue-on-error: true"),
    "R2-10(b/e): no `continue-on-error: true` — an index failure gates functions; functions fail LOUD"
  );
}

// ── verdict ──────────────────────────────────────────────────────────────────
console.log(`selftest: ${passed}/${passed + failed} PASS`);
if (failed > 0) {
  process.exitCode = 1;
}
