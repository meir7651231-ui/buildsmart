// 🤖 AUTO-EMITTED by gen-max — roomClashError משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function dateOf(iso) {
    return new Date(iso + 'T12:00:00');
}
export function roomClashError_ORIG(db, config, form, excludeEventId) {
    if (!form.roomId || !form.time || !form.date)
        return null;
    const room = termOf(config, 'entity.room', 'חדר');
    const hr = parseInt(form.time, 10);
    const clashEv = db.events.find((x) => !x.done &&
        x.id !== excludeEventId &&
        x.roomId === form.roomId &&
        x.date === form.date &&
        parseInt(x.time || '-1', 10) === hr);
    if (clashEv)
        return 'ה' + room + ' תפוס בשעה זו: "' + clashEv.title + '" — בחרו שעה או ' + room + ' אחרים';
    const dow = dateOf(form.date).getDay();
    const clashC = db.courses.find((c) => c.roomId === form.roomId &&
        (!c.start || form.date >= c.start) &&
        (!c.end || form.date <= c.end) &&
        sessionsOf(c).some((ss) => ss.day === dow && parseInt(ss.time, 10) === hr));
    if (clashC)
        return ('בשעה זו מתקיים ה' +
            termOf(config, 'entity.course', 'חוג') +
            ' "' +
            clashC.name +
            '" ב' +
            room +
            ' הזה — בחרו שעה או ' +
            room +
            ' אחרים');
    return null;
}
export function roomClashError(db, config, form, __opt = {}) {
    const base = roomClashError_ORIG(db, config, form);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
