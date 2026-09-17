// 🤖 AUTO-EMITTED by gen-max — reenrollListText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function reenrollListText_ORIG(rows) {
    const decWord = (d) => (d === 'yes' ? 'ממשיך' : d === 'no' ? 'לא ממשיך' : d === 'hold' ? 'בהמתנה' : 'טרם הוחלט');
    return rows
        .map((r) => `${r.memberName} · ${r.courseName} — נוכחות ${r.summary.presents}, חיסורים ${r.summary.absences} · ${decWord(r.decision)}${r.renewed ? ' ✓נרשם' : ''}`)
        .join('\n');
}
function reenrollListText(rows) { return reenrollListText_ORIG(rows); }
export function reenrollListText_fromSource(db, filter) { return reenrollListText_ORIG(buildReenrollRows(db, filter)); }
