// 🤖 AUTO-EMITTED by gen-max — supportersImportFormatRows משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
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
function normEmail(email) {
    return email.trim().toLowerCase();
}
function normName(s) {
    return normSearch(s).replace(/\s/g, '');
}
export function supportersImportFormatRows_ORIG(db) {
    const rows = [['שם', 'טלפון', 'אימייל', 'ת"ז', 'כתובת', 'קטגוריה', 'עבור']];
    for (const sp of db.supporters) {
        rows.push([sp.name, sp.phone, sp.email, sp.idNum, sp.address, sp.cat, sp.forWho]);
    }
    return rows;
}
export function supportersImportFormatRows(db, __opt = {}) {
    const base = supportersImportFormatRows_ORIG(db);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    if (typeof db.phone === 'string' && db.phone.trim() && !/^[\d+][\d\s-]{6,}$/.test(db.phone.trim()))
        return 'מספר טלפון תקין הוא שדה חובה';
    if (typeof db.email === 'string' && db.email.trim() && !/^\S+@\S+\.\S+$/.test((db.email || '').trim().toLowerCase()))
        return 'כתובת האימייל אינה תקינה';
    return base;
}
