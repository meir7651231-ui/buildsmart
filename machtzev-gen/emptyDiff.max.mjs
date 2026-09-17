// 🤖 AUTO-EMITTED by gen-max — emptyDiff משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function emptyDiff_ORIG(d) {
    return d.sets.length === 0 && d.deletes.length === 0 && d.meta === null;
}
export function emptyDiff(d, __opt = {}) {
    const base = emptyDiff_ORIG(d);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
