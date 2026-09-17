// 🤖 AUTO-EMITTED by gen-max — rolesAllowedFor משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function isLegalStep(from, to) {
    const a = stageIndex(from);
    const b = stageIndex(to);
    return a >= 0 && b >= 0 && b === a + 1;
}
const TRANSITION_OWNER = {
    "new>preparing": "store",
    "preparing>ready": "store",
    "ready>pickup": "store", // the "מסור לשליח" hand-off — store-owned
    "pickup>transit": "courier",
    "transit>delivered": "courier",
};
function stageIndex(stage) {
    return typeof stage === "string"
        ? ORDER_FLOW.indexOf(stage)
        : -1;
}
const ORDER_FLOW = [
    "new",
    "preparing",
    "ready",
    "pickup",
    "transit",
    "delivered",
];
export function rolesAllowedFor_ORIG(from, to) {
    if (!isLegalStep(from, to))
        return [];
    const owner = TRANSITION_OWNER[`${from}>${to}`];
    return owner === undefined ? [] : [owner, "manager", "admin"];
}
export function rolesAllowedFor(from, to, __opt = {}) {
    const base = rolesAllowedFor_ORIG(from, to);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
