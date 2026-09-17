// 🤖 AUTO-EMITTED by gen-max — doneTodayFor (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function taskIdentity(email) {
    const e = (email ?? '').trim().toLowerCase();
    return e || 'מקומי';
}
export function doneTodayFor_ORIG(tasks, identity, todayIso) {
    const me = taskIdentity(identity);
    return tasks.filter((t) => taskIdentity(t.assignee) === me && (t.doneAt ?? '').slice(0, 10) === todayIso).length;
}
function openTasksFor(tasks, identity) {
    const me = taskIdentity(identity);
    return tasks
        .filter((t) => !t.doneAt && taskIdentity(t.assignee) === me)
        .sort((a, b) => a.pri - b.pri ||
        (a.due || '9999').localeCompare(b.due || '9999') ||
        a.createdAt.localeCompare(b.createdAt));
}
export function doneTodayFor(tasks, identity, todayIso) { return doneTodayFor_ORIG(tasks, identity, todayIso); }
export function doneTodayFor_fromSource(tasks, identity, todayIso) { return doneTodayFor_ORIG(openTasksFor(tasks, identity), identity, todayIso); }
