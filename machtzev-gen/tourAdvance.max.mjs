// 🤖 AUTO-EMITTED by gen-max — tourAdvance משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function tourAdvance_ORIG(index, delta, length) {
    const next = index + delta;
    if (next < 0)
        return 0;
    if (next >= length)
        return null;
    return next;
}
export function tourAdvance(index, delta, length, __opt = {}) {
    const base = tourAdvance_ORIG(index, delta, length);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
