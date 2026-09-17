// 🤖 AUTO-EMITTED by gen-max — taskStatsFor (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function taskIdentity(email) {
    const e = (email ?? '').trim().toLowerCase();
    return e || 'מקומי';
}
function taskOverdue(t, todayIso) {
    return !t.doneAt && !!t.due && t.due < todayIso;
}
export function taskStatsFor_ORIG(tasks, identity, todayIso) {
    const me = taskIdentity(identity);
    const mine = tasks.filter((t) => taskIdentity(t.assignee) === me);
    const t0 = new Date(todayIso + 'T12:00:00').getTime();
    let open = 0, overdue = 0, done = 0, doneWeek = 0;
    for (const t of mine) {
        if (!t.doneAt) {
            open++;
            if (taskOverdue(t, todayIso))
                overdue++;
        }
        else {
            done++;
            const d = new Date((t.doneAt ?? '').slice(0, 10) + 'T12:00:00').getTime();
            const diff = (t0 - d) / 86400000;
            if (diff >= 0 && diff < 7)
                doneWeek++;
        }
    }
    return { open, overdue, done, doneWeek };
}
function openTasksFor(tasks, identity) {
    const me = taskIdentity(identity);
    return tasks
        .filter((t) => !t.doneAt && taskIdentity(t.assignee) === me)
        .sort((a, b) => a.pri - b.pri ||
        (a.due || '9999').localeCompare(b.due || '9999') ||
        a.createdAt.localeCompare(b.createdAt));
}
export function taskStatsFor(tasks, identity, todayIso) { return taskStatsFor_ORIG(tasks, identity, todayIso); }
export function taskStatsFor_fromSource(tasks, identity, todayIso) { return taskStatsFor_ORIG(openTasksFor(tasks, identity), identity, todayIso); }
