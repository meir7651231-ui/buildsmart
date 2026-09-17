function inactiveRoomCourses(db, iso, config) {
    const out = [];
    for (const c of db.courses) {
        if (c.end && iso > c.end)
            continue;
        if (!c.roomId)
            continue;
        const room = db.rooms.find((r) => r.id === c.roomId);
        if (!room)
            out.push({ course: c, roomName: termOf(config, 'entity.room', 'חדר') + ' לא קיים' });
        else if (!room.active)
            out.push({ course: c, roomName: room.name });
    }
    return out;
}
function enrollmentsForSession(db, c, sessionIndex) {
    const all = db.enrollments.filter((e) => e.courseId === c.id);
    const ss = sessionsOf(c);
    if (ss.length <= 1)
        return all;
    const label = groupLabelOf(ss[Math.min(sessionIndex, ss.length - 1)], sessionIndex);
    return all.filter((e) => !e.group || e.group === label);
}
function groupLabelOf(ss, i) {
    return ss.label || 'קבוצה ' + (i + 1);
}
function weeklyRoomSessions(db, roomId, iso) {
    return db.courses
        .filter((c) => c.roomId === roomId && (!c.end || iso <= c.end))
        .reduce((a, c) => a + sessionsOf(c).length, 0);
}
export function diaryListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        inactiveRoomCourses: (() => { try {
            return inactiveRoomCourses(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        enrollmentsForSession: (() => { try {
            return enrollmentsForSession(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        weeklyRoomSessions: (() => { try {
            return weeklyRoomSessions(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { inactiveRoomCourses, enrollmentsForSession, weeklyRoomSessions };
