// 🤖 AUTO-EMITTED by gen-max — dashboardCsvRows (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function dashboardCsvRows_ORIG(dash) {
    const head = ['חוג', 'מורה', 'רשומים', 'מקסימום', 'תפוסה %', 'רשימת-המתנה', 'חוב (₪)', 'חיסורים', 'בסיכון'];
    const body = dash.rows.map((r) => [
        r.name,
        r.teacher,
        r.enrolled,
        r.max || '∞',
        r.max > 0 ? r.occupancy : '—',
        r.waitlist,
        r.debt,
        r.absences,
        r.atRisk,
    ]);
    return [head, ...body];
}
function dashboardCsvRows(dash) { return dashboardCsvRows_ORIG(dash); }
export function dashboardCsvRows_fromSource(db, opts) { return dashboardCsvRows_ORIG(courseDashboard(db, opts)); }
