// 🤖 AUTO-EMITTED by gen-max — allowItem משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function allowItem_ORIG(it, f) {
    if (f.urgentOnly && !(it.ev && it.ev.priority === 'red'))
        return false;
    if (it.layer === 'bday')
        return f.bdays;
    if (it.layer === 'join')
        return f.joins;
    if (it.layer === 'enroll')
        return f.enrolls;
    if (it.courseId)
        return f.courses;
    if (it.ev) {
        // פירוק שכבת האירועים לשכבות עדינות: תזכורות · טלפונים · אירועים
        // משפחתיים (famId) — והשאר (org/custom) תחת ה-catch-all של 'events'.
        if (it.ev.type === 'reminder')
            return f.reminders;
        if (it.ev.type === 'call')
            return f.calls;
        if (it.ev.famId)
            return f.family;
        return f.events;
    }
    return true;
}
export function allowItem(it, f, __opt = {}) {
    const base = allowItem_ORIG(it, f);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
