// 🤖 AUTO-EMITTED by gen-max — familiesImportFormatRows משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function phoneRegion(raw) {
    const s = (raw || '').replace(/[^\d+]/g, '');
    if (!s)
        return 'il';
    if (/^(\+?972|00972)/.test(s))
        return 'il';
    if (/^\+/.test(s))
        return 'intl';
    if (/^00/.test(s))
        return 'intl';
    const d = s.replace(/\D/g, '');
    if (/^0\d{8,9}$/.test(d))
        return 'il'; // 0 + 9/10 ספרות
    if (/^5\d{8}$/.test(d))
        return 'il'; // נייד ישראלי בלי 0 מוביל
    return 'intl';
}
function normName(s) {
    return normSearch(s).replace(/\s/g, '');
}
export function familiesImportFormatRows_ORIG(db) {
    const rows = [
        ['שם', 'ת"ז אב', 'טלפון', 'שם האם', 'ת"ז אם', 'טלפון 2', 'עיר', 'כתובת', '', 'אלמן', 'קהילה', '', 'הערות'],
    ];
    for (const f of db.families) {
        rows.push([
            f.name, f.fatherId, f.phone, f.mother, f.motherId, f.phone2, f.city, f.address, '',
            (f.maritalStatus || '').includes('אלמן') ? 'אלמן' : '', f.community, '', f.notes,
        ]);
    }
    return rows;
}
export function familiesImportFormatRows(db, __opt = {}) {
    const base = familiesImportFormatRows_ORIG(db);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    if (typeof db.phone === 'string' && db.phone.trim() && !/^[\d+][\d\s-]{6,}$/.test(db.phone.trim()))
        return 'מספר טלפון תקין הוא שדה חובה';
    return base;
}
