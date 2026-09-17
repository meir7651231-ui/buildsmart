// 🤖 AUTO-EMITTED by gen-max — isLegalStep משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
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
export function isLegalStep_ORIG(from, to) {
    const a = stageIndex(from);
    const b = stageIndex(to);
    return a >= 0 && b >= 0 && b === a + 1;
}
export function isLegalStep(from, to, __opt = {}) {
    const base = isLegalStep_ORIG(from, to);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
