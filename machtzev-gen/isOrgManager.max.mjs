// 🤖 AUTO-EMITTED by gen-max — isOrgManager משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function normEmail(email) {
    return email.trim().toLowerCase();
}
export function isOrgManager_ORIG(email, org) {
    const m = (org.manager ?? '').trim().toLowerCase();
    return !!m && normEmail(email) === m;
}
export function isOrgManager(email, org, __opt = {}) {
    const base = isOrgManager_ORIG(email, org);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
