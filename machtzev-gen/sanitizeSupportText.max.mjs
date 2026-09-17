// 🤖 AUTO-EMITTED by gen-max — sanitizeSupportText משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const SUPPORT_MSG_MAX = 2000;
export function sanitizeSupportText_ORIG(raw) {
    return (raw ?? '').replace(/\s+$/u, '').replace(/^\s+/u, '').slice(0, SUPPORT_MSG_MAX);
}
export function sanitizeSupportText(raw, __opt = {}) {
    const base = sanitizeSupportText_ORIG(raw);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
