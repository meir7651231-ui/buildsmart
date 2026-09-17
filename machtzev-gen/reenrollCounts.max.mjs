// 🤖 AUTO-EMITTED by gen-max — reenrollCounts (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function reenrollCounts_ORIG(rows) {
    const c = { total: 0, yes: 0, no: 0, hold: 0, undecided: 0, renewed: 0 };
    for (const r of rows) {
        c.total++;
        if (r.renewed)
            c.renewed++;
        if (r.decision === 'yes')
            c.yes++;
        else if (r.decision === 'no')
            c.no++;
        else if (r.decision === 'hold')
            c.hold++;
        else
            c.undecided++;
    }
    return c;
}
function reenrollCounts(rows) { return reenrollCounts_ORIG(rows); }
export function reenrollCounts_fromSource(db, filter) { return reenrollCounts_ORIG(buildReenrollRows(db, filter)); }
