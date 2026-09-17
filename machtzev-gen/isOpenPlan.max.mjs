// 🤖 AUTO-EMITTED by gen-max — isOpenPlan משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function isOpenPlan_ORIG(p) {
    return !p.chargedRid && !p.cancelledAt;
}
export function isOpenPlan(p, __opt = {}) {
    const base = isOpenPlan_ORIG(p);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
