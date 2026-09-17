// 🤖 AUTO-EMITTED by gen-max — duplicateCourse משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function duplicateCourse_ORIG(c, newId, dates) {
    return { ...c, id: newId, name: c.name + ' (עותק)', start: dates.start, end: dates.end };
}
export function duplicateCourse(c, newId, dates, __opt = {}) {
    const base = duplicateCourse_ORIG(c, newId, dates);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
