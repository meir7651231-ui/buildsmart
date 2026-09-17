// 🤖 AUTO-EMITTED by gen-max — isValidSlug משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function isValidSlug_ORIG(slug) {
    return /^[a-z0-9-]{2,40}$/.test(slug);
}
export function isValidSlug(slug, __opt = {}) {
    const base = isValidSlug_ORIG(slug);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
