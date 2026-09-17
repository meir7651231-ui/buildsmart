// 🤖 AUTO-EMITTED by gen-max — currentId משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function currentId_ORIG(c) {
    return c.queue.length ? c.queue[0] : null;
}
export function currentId(c, __opt = {}) {
    const base = currentId_ORIG(c);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
