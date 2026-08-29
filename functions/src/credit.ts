// ─────────────────────────────────────────────────────────────────────────────
// S8.2 — `computeCredit` callable: contractor credit computed SERVER-side.
//
//   creditLimit = READ from `customers/{name}.creditLimit`, or 0 when a manager
//                 has not set one. It is NOT derived. It used to be
//                 `contractorCredit(name)` — a hash of the person's name in the
//                 30,000–120,000 ₪ band — and returning that from here was worse
//                 than returning it from the client, because the client treats
//                 this callable as the one authority on credit: an invented
//                 figure arrived wearing the server's authority, was rendered
//                 under "the REAL credit figures", and was handed to an advisor
//                 that reasons about approving the next order.
//   used        = Σ `sum` of the caller's orders, folded live from `orders`.
//   balance     = (creditLimit - used).clamp(0, creditLimit)   — יתרה ≥ 0;
//   pct         = creditLimit == 0 ? 0 : round(used/creditLimit*100).clamp(0,100).
//
// AUTHORIZATION mirrors S5.4 ("read credit: role==manager || ownerId==uid"), but
// ownership now keys on the UID. It used to compare the requested name against
// `users/{uid}.displayName` — a field the caller can write, since the users
// update rule freezes only role/roles/storeUid/orgId/status. A contractor wrote
// a colleague's name into their own document and the comparison passed, handing
// them that colleague's spend and standing. A non-manager is therefore scoped by
// uid and the name they send is discarded rather than validated; the decision
// contains nothing the caller controls. Every computation is audit-logged.
// ─────────────────────────────────────────────────────────────────────────────

import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { asString, callerRoles, db, REGION } from "./common";
// `contractorCredit` is deliberately NOT imported here any more. It is the
// name-hash ceiling, and this callable is the one place the client is told to
// treat as authoritative — so a fabricated number returned from here arrived
// wearing the server's authority. It remains in creditCore for the local/demo
// derivation, which is what it was always for.
import { creditScopeFor, orderSum, readCreditLimit } from "./creditCore";

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

  // S5.4 ownership. A non-manager may only compute their OWN credit — and
  // "own" has to mean their uid, never a field they control.
  //
  // THE HOLE THIS CLOSES. The check used to resolve the caller's identity from
  // `users/{uid}.displayName` and compare it to the requested name. But the users
  // update rule freezes only role/roles/storeUid/orgId/status, so displayName is
  // self-writable by design — the welcome flow mirrors it there on every login.
  // So contractor B wrote contractor A's exact name into their own document, and
  // from that moment `own` WAS A's name: the comparison passed, and B read A's
  // spend, order count and standing. The gate was asking a question the attacker
  // got to answer.
  //
  // Two identifiers were being conflated: a display name, which is typed, shared
  // between namesakes and editable, and a uid, which is none of those. Ownership
  // now keys on the uid alone, so nothing the caller can write takes part in the
  // decision. The name is still resolved, but only to label the result.
  const scope = creditScopeFor({ callerUid: uid, isManager });
  const scopeUid = scope.byUid;
  if (scopeUid !== null) {
    const me = await db().collection("users").doc(uid).get();
    // Display only — if it is missing the figures are still correct.
    name = asString(me.get("displayName")) ?? uid;
  }
  if (name === null) {
    throw new HttpsError("invalid-argument", "name (string) is required.");
  }

  // THE CEILING IS READ, NOT INVENTED.
  //
  // This used to return `contractorCredit(name)` — a hash of the person's name
  // bucketed into the 30,000–120,000 ₪ band. Being computed on the server made it
  // worse, not better: the client was told the server is the one authority on
  // credit, so a figure with no basis arrived carrying the server's authority,
  // and `credit_explain_screen` presented it as "the REAL credit figures" and fed
  // it to an advisor that reasons about whether to approve the next order.
  //
  // A real ceiling lives in `customers/{name}.creditLimit`, set by a manager.
  // When there is none the honest answer is zero — "not on record" — which the
  // client already renders as "לא רשומה" rather than "₪0". A degraded read must
  // look degraded.
  const customer = await db().collection("customers").doc(name).get();
  const creditLimit = readCreditLimit(customer.get("creditLimit"));

  // Live spend. KEYED ON THE UID for a non-manager, because `contractorId` is
  // the display NAME: self-written, and shared by any two namesakes. Querying it
  // for the caller's own credit would fold a stranger's orders into their total
  // the moment two people registered under the same name — the same
  // name-versus-uid confusion the orders rules were already hardened against.
  // A manager asking about a name keeps the name query: they are permitted to
  // read, and the legacy documents they browse are keyed that way.
  const q = await (scopeUid !== null
    ? db().collection("orders").where("contractorUid", "==", scopeUid).get()
    : db().collection("orders").where("contractorId", "==", name).get());
  let used = 0;
  for (const doc of q.docs) {
    // `used` = Σ the contractor's COMMITTED order total — the stored `sum` (grand
    // total incl. VAT + delivery + fixed items), exactly what the manager dashboard
    // folds (Σ o.sum) and what the contractor agreed to at checkout. The bare
    // `lines` totals (no VAT/delivery, fixed items absent) UNDERstate the debt and
    // disagree with the displayed figure, so they are only a fallback for
    // legacy/partial docs that carry no usable `sum`.
    const s: unknown = doc.get("sum");
    used += typeof s === "number" && Number.isFinite(s) && s > 0
      ? Math.round(s)
      : orderSum(doc.get("lines"));
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
