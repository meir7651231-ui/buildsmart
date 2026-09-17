// 🤖 AUTO-EMITTED by gen-max — reenrollCsvRows (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function reenrollCsvRows_ORIG(rows) {
    const head = ['תלמיד/ה', 'משפחה', 'חוג', 'נוכחות', 'חיסורים', 'יתרה ₪', 'סטטוס', 'החלטה', 'נרשם לשנה הבאה', 'הערה'];
    const decWord = (d) => (d === 'yes' ? 'ממשיך' : d === 'no' ? 'לא ממשיך' : d === 'hold' ? 'בהמתנה' : '');
    const body = rows.map((r) => [
        r.memberName,
        r.familyName,
        r.courseName,
        String(r.summary.presents),
        String(r.summary.absences),
        String(r.summary.balance),
        r.summary.statusLabel,
        decWord(r.decision),
        r.renewed ? 'כן' : '',
        r.e.renewNote ?? '',
    ]);
    return [head, ...body];
}
function reenrollCsvRows(rows) { return reenrollCsvRows_ORIG(rows); }
export function reenrollCsvRows_fromSource(db, filter) { return reenrollCsvRows_ORIG(buildReenrollRows(db, filter)); }
