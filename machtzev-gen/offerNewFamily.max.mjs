// 🤖 AUTO-EMITTED by gen-max — offerNewFamily משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function normNameLocal(s) {
    return normSearch(s).replace(/\s/g, '');
}
function normName(s) {
    return normSearch(s).replace(/\s/g, '');
}
export function offerNewFamily_ORIG(families, q) {
    const t = q.trim();
    return t.length >= 2 && !families.some((f) => normNameLocal(f.name) === normNameLocal(t));
}
export function offerNewFamily(families, q, __opt = {}) {
    const base = offerNewFamily_ORIG(families, q);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
