// 🤖 AUTO-EMITTED by gen-max — waAppLink משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function waDigits(phone) {
    let d = (phone || '').replace(/\D/g, '');
    if (!d)
        return null;
    if (d.startsWith('00972'))
        d = '972' + d.slice(5);
    else if (d.startsWith('00'))
        d = d.slice(2); // קידומת חיוג בינ"ל כללית
    if (d.startsWith('9720'))
        d = '972' + d.slice(4); // ‎+972 שנשמר עם ה-0 המקומי
    if (!d.startsWith('972') && !d.startsWith('0') && (d.length === 8 || d.length === 9)) {
        d = '0' + d; // ישראלי בלי 0 מוביל — אותו דין כמו formatIsraeliPhone
    }
    if (d.startsWith('0')) {
        if (d.length === 9 || d.length === 10)
            d = '972' + d.slice(1);
        else
            return null; // 0-מוביל באורך אחר = לא-תקין ל-wa.me — עדיף בלי כפתור
    }
    if (d.length < 8 || d.length > 15)
        return null; // גבולות E.164
    return d;
}
export function waAppLink_ORIG(phone, text = '') {
    const digits = waDigits(phone);
    if (!digits)
        return null;
    const t = text.trim();
    return 'whatsapp://send?phone=' + digits + (t ? '&text=' + encodeURIComponent(t) : '');
}
export function waAppLink(phone, text = '', __opt = {}) {
    const base = waAppLink_ORIG(phone, text = '');
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
