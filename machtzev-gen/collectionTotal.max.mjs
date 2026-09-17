// 🤖 AUTO-EMITTED by gen-max — collectionTotal (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function collectionTotal_ORIG(rows) {
    return rows.reduce((a, r) => a + r.bal, 0);
}
function collectionList(db) {
    const courseName = (id) => db.courses.find((c) => c.id === id)?.name ?? '—';
    const rows = [];
    for (const e of db.enrollments) {
        if (e.status === 'ended' || e.status === 'wait')
            continue;
        const bal = payBal(e);
        if (bal <= 0)
            continue;
        let name = '—';
        let phone = '';
        for (const f of db.families) {
            const m = f.members.find((x) => x.id === e.memberId);
            if (m) {
                name = m.first + ' · ' + f.name;
                phone = f.phone || m.phone || '';
                break;
            }
        }
        rows.push({ id: e.id, memberId: e.memberId, name, phone, courseId: e.courseId, courseName: courseName(e.courseId), bal });
    }
    return rows.sort((a, b) => b.bal - a.bal);
}
export function collectionTotal(rows) { return collectionTotal_ORIG(rows); }
export function collectionTotal_fromSource(db) { return collectionTotal_ORIG(collectionList(db)); }
