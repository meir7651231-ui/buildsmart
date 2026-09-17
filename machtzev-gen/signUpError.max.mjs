// 🤖 AUTO-EMITTED by gen-max — signUpError משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function signUpError_ORIG(orgName, contactName, phone, email, password, password2) {
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
export function signUpError(orgName, contactName, phone, email, pass, __opt = {}) {
    const base = signUpError_ORIG(orgName, contactName, phone, email, pass);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
