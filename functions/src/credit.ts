// ─────────────────────────────────────────────────────────────────────────────
// S8.2 — `computeCredit` callable: contractor credit computed SERVER-side.
//
// The deterministic ceiling is the EXACT port in creditCore.ts (see its header
// for source + bit-for-bit verification). On top of it this callable derives
// the same numbers the manager dashboard derives client-side
// (manager_dashboard_screen.dart, @legacy index.html:16559-16562):
//   used    = Σ `sum` of the contractor's orders (mgrCustomerList totalSpend
//             group-by-buyer fold) — read live from the `orders` collection,
//             where `contractorId` carries the buyer (`who` → contractorId per
//             knowledge/firestore-schema.md field mapping);
//   balance = (creditLimit - used).clamp(0, creditLimit)   — יתרה ≥ 0;
//   pct     = creditLimit == 0 ? 0 : round(used/creditLimit*100).clamp(0,100).
//
// Authorization mirrors S5.4 ("read credit: role==manager || ownerId==uid"):
// manager/admin may compute for ANY contractor name; any other caller only for
// THEIR OWN name (users/{uid}.displayName). Every computation is audit-logged.
// ─────────────────────────────────────────────────────────────────────────────

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { asString, callerRoles, db, REGION } from "./common";
import { contractorCredit } from "./creditCore";

interface ComputeCreditData {
  name?: unknown;
}

export const computeCredit = onCall({ region: REGION }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const uid = request.auth.uid;
  const roles = callerRoles(request.auth.token);
  const isManager = roles.includes("manager") || roles.includes("admin");

  const data = (request.data ?? {}) as ComputeCreditData;
  let name = typeof data.name === "string" && data.name.length > 0
    ? data.name
    : null;

  if (!isManager) {
    // S5.4 ownership: a non-manager may only compute their OWN credit.
    const me = await db().collection("users").doc(uid).get();
    const own = asString(me.get("displayName"));
    if (own === null) {
      throw new HttpsError(
        "failed-precondition",
        "users/{uid}.displayName is missing — cannot resolve the caller's " +
          "contractor name."
      );
    }
    if (name !== null && name !== own) {
      throw new HttpsError(
        "permission-denied",
        "Only a manager may compute another contractor's credit (S5.4)."
      );
    }
    name = own;
  }
  if (name === null) {
    throw new HttpsError("invalid-argument", "name (string) is required.");
  }

  // Deterministic ceiling — the exact client formula, now server-canonical.
  const creditLimit = contractorCredit(name);

  // Live spend — the mgrCustomerList fold over this buyer's orders.
  const q = await db()
    .collection("orders")
    .where("contractorId", "==", name)
    .get();
  let used = 0;
  for (const doc of q.docs) {
    const s: unknown = doc.get("sum");
    if (typeof s === "number" && Number.isFinite(s)) used += s;
  }
  const orderCount = q.size;

  // Verbatim derived fields (manager_dashboard_screen.dart:1331-1334, 1736-1741).
  const balance = Math.min(Math.max(creditLimit - used, 0), creditLimit);
  const pct =
    creditLimit === 0
      ? 0
      : Math.min(Math.max(Math.round((used / creditLimit) * 100), 0), 100);

  await writeAudit({
    action: "credit.compute",
    source: "computeCredit",
    actorUid: uid,
    actorRole: roles.join(",") || null,
    target: `customers/${name}`,
    before: null,
    after: { creditLimit, used, balance, pct, orderCount },
    ok: true,
  });

  return { ok: true, name, creditLimit, used, balance, pct, orderCount };
});
