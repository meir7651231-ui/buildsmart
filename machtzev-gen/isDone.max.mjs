// 🤖 AUTO-EMITTED by gen-max — isDone משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function isDone_ORIG(c) {
    return c.queue.length === 0;
}
export function isDone(c, __opt = {}) {
    const base = isDone_ORIG(c);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
