// 🤖 AUTO-EMITTED by gen-max — isMember משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function normEmail(email) {
    return email.trim().toLowerCase();
}
export function isMember_ORIG(email, org) {
    const e = normEmail(email);
    if (isOrgManager(e, org))
        return true;
    return (org.members ?? []).map((m) => m.trim().toLowerCase()).includes(e);
}
export function isMember(step, s, opt = {}) {
    const base = isMember_ORIG(step, s);
    if (opt.strict !== true)
        return base; // ← default: החזק לא נשבר
    if (base !== null)
        return base; // המקורי כבר פסל — כבד אותו
    return null;
}
