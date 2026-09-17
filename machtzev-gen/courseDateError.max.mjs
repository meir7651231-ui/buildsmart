// 🤖 AUTO-EMITTED by gen-max — courseDateError משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function courseDateError_ORIG(start, end, config) {
    if (start && end && end < start) {
        const courseWord = config ? termOf(config, 'entity.course', 'חוג') : 'חוג';
        return 'תאריך הסיום מוקדם מתאריך ההתחלה — ה' + courseWord + ' לא יופיע בלוח. תקנו את התאריכים';
    }
    return null;
}
export function courseDateError(start, end, config, __opt = {}) {
    const base = courseDateError_ORIG(start, end, config);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
