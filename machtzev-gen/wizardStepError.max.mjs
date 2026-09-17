// 🤖 AUTO-EMITTED by gen-max — wizardStepError משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
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
function signUpError(orgName, contactName, phone, email, password, password2) {
    if (!orgName.trim())
        return 'שם הארגון הוא שדה חובה';
    // הזרימה מבוססת שיחה חוזרת (עדכון פקודה 30.7) — איש קשר וטלפון חובה
    if (!contactName.trim())
        return 'שם איש הקשר הוא שדה חובה';
    if (!/^[\d+][\d\s-]{6,}$/.test(phone.trim()))
        return 'מספר טלפון תקין הוא שדה חובה — נחזור אליכם לאישור';
    if (!/^\S+@\S+\.\S+$/.test(email.trim()))
        return 'כתובת האימייל אינה תקינה';
    if (password.length < 6)
        return 'הסיסמה חייבת להיות לפחות 6 תווים';
    if (password !== password2)
        return 'הסיסמאות אינן זהות';
    return '';
}
export function wizardStepError_ORIG(step, s) {
    switch (step) {
        case 0:
            return s.industry ? null : 'בחרו את תחום העסק כדי להמשיך';
        case 1:
            return s.size ? null : 'בחרו את גודל הארגון';
        case 2:
            return null; // צרכים — אופציונלי
        case 3:
            if (!s.orgName.trim())
                return 'שם הארגון חובה';
            if (!s.contactName.trim())
                return 'שם איש קשר חובה';
            if (!s.phone.trim())
                return 'טלפון חובה — נחזור אליכם לאישור';
            return null;
        case 4:
            // signUpError מחזיר '' בהצלחה — מנרמלים ל-null לעקביות עם שאר השלבים.
            return signUpError(s.orgName, s.contactName, s.phone, s.email, s.password, s.password2) || null;
        default:
            return null;
    }
}
const WIZARD_INDUSTRIES_IDS = ["chesed", "clinic", "shop", "services", "rooms", "fleet", "garage", "hospitality", "gemach", "tzedakot", "digital", "build", "studio"];
const ORG_SIZES_IDS = ["small", "medium", "large"];
const ORG_NEEDS_IDS = ["crm", "billing", "schedule", "inventory", "reports", "multi", "backup"];
export function wizardStepError(step, s, __opt = {}) {
    const base = wizardStepError_ORIG(step, s);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    if (typeof s.phone === 'string' && s.phone.trim() && !/^[\d+][\d\s-]{6,}$/.test(s.phone.trim()))
        return 'מספר טלפון תקין הוא שדה חובה';
    if (typeof s.email === 'string' && s.email.trim() && !/^\S+@\S+\.\S+$/.test((s.email || '').trim().toLowerCase()))
        return 'כתובת האימייל אינה תקינה';
    if (typeof s.industry === 'string' && s.industry && !WIZARD_INDUSTRIES_IDS.includes(s.industry))
        return 'industry לא חוקי';
    if (typeof s.size === 'string' && s.size && !ORG_SIZES_IDS.includes(s.size))
        return 'size לא חוקי';
    if (Array.isArray(s.needs) && s.needs.some((v) => !ORG_NEEDS_IDS.includes(v)))
        return 'needs לא חוקי';
    return base;
}
