// 🤖 AUTO-EMITTED by gen-max — canAddPhoto משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const PHOTO_MAX = 5;
export function canAddPhoto_ORIG(current) {
    return (current?.length ?? 0) < PHOTO_MAX;
}
export function canAddPhoto(current, __opt = {}) {
    const base = canAddPhoto_ORIG(current);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
