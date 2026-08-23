// ─────────────────────────────────────────────────────────────────────────────
// S8.1 domain — the order stage chain + per-transition role authorization.
// PURE module (no Firebase imports) so `selftest.ts` can exercise it offline.
//
// VERBATIM SOURCES (read 2026-06-10, branch claude/whats-happening-LyY9G):
//   • Chain: app_flutter/lib/logic/manager_dashboard.dart `kManagerOrderFlow`
//     (@legacy index.html:16943 `ORDER_FLOW`):
//       new → preparing → ready → pickup → transit → delivered
//   • Labels: app_flutter/lib/data/supplier_data.dart `kOrderStageLabel`
//     (@legacy `ORDER_STAGE[k].label`, index.html:12041) — verbatim Hebrew.
//   • Who advances what — app_flutter/lib/state/sys_orders.dart (the CODE is
//     authoritative; its file-header summary is stale):
//       `storeAdvance`   fires on stage ∈ {new, preparing, ready}  →  the STORE
//         owns new→preparing, preparing→ready AND ready→pickup (the "מסור
//         לשליח" hand-off — the courier explicitly no-ops on `ready`).
//       `courierAdvance` fires on stage ∈ {pickup, transit}        →  the COURIER
//         owns pickup→transit, transit→delivered.
//     This is also consistent with SSOT §S5.5: "update-stage: store(new→ready) /
//     courier(pickup→delivered)" — with the hand-off step (ready→pickup)
//     resolved by the app code in favour of the store.
//   • Manager: "manager can nudge any single step" (supplier_data.dart §1.1)
//     → `manager` (and the bootstrap `admin` claim) may perform EVERY legal
//     single forward step. The manager "god-step" to an ARBITRARY stage is NOT
//     offered server-side — see revertIllegalOrderStageWrite (orders.ts).
// ─────────────────────────────────────────────────────────────────────────────

/** The six canonical stages, in flow order. */
export const ORDER_FLOW = [
  "new",
  "preparing",
  "ready",
  "pickup",
  "transit",
  "delivered",
] as const;

export type OrderStage = (typeof ORDER_FLOW)[number];

/** Verbatim Hebrew stage label (`ORDER_STAGE[k].label` — supplier_data.dart). */
export const ORDER_STAGE_LABEL_HE: Record<OrderStage, string> = {
  new: "התקבלה",
  preparing: "בהכנה",
  ready: "מוכן לאיסוף",
  pickup: "נאסף",
  transit: "בדרך לאתר",
  delivered: "נמסר ✓",
};

export function isOrderStage(v: unknown): v is OrderStage {
  return typeof v === "string" && (ORDER_FLOW as readonly string[]).includes(v);
}

/** Index in the flow, or -1 for an unknown value. */
export function stageIndex(stage: unknown): number {
  return typeof stage === "string"
    ? (ORDER_FLOW as readonly string[]).indexOf(stage)
    : -1;
}

/** The next stage in the chain, or null at/after `delivered` (mirrors the
 * client `advance` no-op: `cur < 0 || cur >= len-1` → do nothing). */
export function nextStage(stage: OrderStage): OrderStage | null {
  const i = stageIndex(stage);
  if (i < 0 || i >= ORDER_FLOW.length - 1) return null;
  return ORDER_FLOW[i + 1];
}

/** True iff `from`→`to` is a single FORWARD step along the chain — the only
 * stage mutation the server accepts (callable) or tolerates (direct write). */
export function isLegalStep(from: unknown, to: unknown): boolean {
  const a = stageIndex(from);
  const b = stageIndex(to);
  return a >= 0 && b >= 0 && b === a + 1;
}

/** The fulfilment role that OWNS each transition (sys_orders.dart code). */
export const TRANSITION_OWNER: Readonly<Record<string, "store" | "courier">> = {
  "new>preparing": "store",
  "preparing>ready": "store",
  "ready>pickup": "store", // the "מסור לשליח" hand-off — store-owned
  "pickup>transit": "courier",
  "transit>delivered": "courier",
};

/** Roles allowed to perform `from`→`to`: the owning fulfilment role, plus
 * `manager` ("can nudge any single step") and the bootstrap `admin` claim.
 * Empty for an illegal step. */
export function rolesAllowedFor(from: OrderStage, to: OrderStage): string[] {
  if (!isLegalStep(from, to)) return [];
  const owner = TRANSITION_OWNER[`${from}>${to}`];
  return owner === undefined ? [] : [owner, "manager", "admin"];
}

/** True iff any of the caller's roles may perform `from`→`to`. */
export function roleMayStep(
  roles: readonly string[],
  from: OrderStage,
  to: OrderStage
): boolean {
  const allowed = rolesAllowedFor(from, to);
  return roles.some((r) => allowed.includes(r));
}
