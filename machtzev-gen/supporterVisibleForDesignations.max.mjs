// 🤖 AUTO-EMITTED by gen-max — supporterVisibleForDesignations משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function supporterVisibleForDesignations_ORIG(sup, allowed) {
    if (!allowed || !allowed.length)
        return true;
    const fw = (sup.forWho ?? '').trim();
    // הכרעת-בעלים 19.8 (היפוך #8): עובד-סגור-לייעוד רואה **רק** את הייעוד שלו —
    // תורם בלי ייעוד אינו נראה לו (קודם: משותף). אכיפה-מלאה בשרת = עדכון Rules.
    if (!fw)
        return false;
    return new Set(allowed.map((s) => s.trim())).has(fw);
}
export function supporterVisibleForDesignations(sup, allowed, __opt = {}) {
    const base = supporterVisibleForDesignations_ORIG(sup, allowed);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
