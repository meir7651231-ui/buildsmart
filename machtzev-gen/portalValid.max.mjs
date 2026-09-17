// 🤖 AUTO-EMITTED by gen-max — portalValid משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
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
export function portalValid_ORIG(f) {
    return f.childName.trim().length >= 2 && f.phone.replace(/\D/g, '').length >= 6;
}
export function portalValid(f, __opt = {}) {
    const base = portalValid_ORIG(f);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    if (typeof f.phone === 'string' && f.phone.trim() && !/^[\d+][\d\s-]{6,}$/.test(f.phone.trim()))
        return 'מספר טלפון תקין הוא שדה חובה';
    return base;
}
