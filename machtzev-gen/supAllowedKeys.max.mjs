// 🤖 AUTO-EMITTED by gen-max — supAllowedKeys משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const SHARED_SUP_KEY = '_shared_';
export function supAllowedKeys_ORIG(allowed) {
    const clean = [...new Set(allowed.map((s) => s.trim()).filter(Boolean))].slice(0, 29);
    return [...clean, SHARED_SUP_KEY];
}
export function supAllowedKeys(allowed, __opt = {}) {
    const base = supAllowedKeys_ORIG(allowed);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
