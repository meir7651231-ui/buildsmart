// 🤖 AUTO-EMITTED by gen-max — scheduleClashText משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function sessionsOf(c) {
    return c.sessions && c.sessions.length ? c.sessions : [{ day: c.weekday, time: c.time, label: '' }];
}
const DAY_NAMES = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי'];
function normName(s) {
    return normSearch(s).replace(/\s/g, '');
}
export function scheduleClashText_ORIG(db, memberId, course) {
    const target = sessionsOf(course);
    for (const e of db.enrollments) {
        if (e.memberId !== memberId || e.status === 'ended' || e.courseId === course.id)
            continue;
        const other = db.courses.find((x) => x.id === e.courseId);
        if (!other)
            continue;
        for (const s1 of target) {
            for (const s2 of sessionsOf(other)) {
                if (s1.day === s2.day && !!s1.time && s1.time === s2.time) {
                    return '⚠ התנגשות לו"ז: כבר משובצ/ת ל"' + other.name + '" — יום ' + DAY_NAMES[s1.day] + ' ' + s1.time;
                }
            }
        }
    }
    return null;
}
export function scheduleClashText(db, memberId, course, __opt = {}) {
    const base = scheduleClashText_ORIG(db, memberId, course);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
