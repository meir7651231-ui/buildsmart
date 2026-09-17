// 🤖 AUTO-EMITTED by gen-max — collectionCsvRows (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function collectionCsvRows_ORIG(rows) {
    return [['שם', 'חוג', 'טלפון', 'יתרת חוב (₪)'], ...rows.map((r) => [r.name, r.courseName, r.phone, r.bal])];
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
export function collectionCsvRows(rows) { return collectionCsvRows_ORIG(rows); }
export function collectionCsvRows_fromSource(db) { return collectionCsvRows_ORIG(collectionList(db)); }
