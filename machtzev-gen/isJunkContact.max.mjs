// 🤖 AUTO-EMITTED by gen-max — isJunkContact משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const digitsOnly = (s) => (s || '').replace(/\D/g, '');
function dupFieldValue(fams, def, pick, edit) {
    const edited = edit[def.key];
    if (edited != null)
        return edited;
    const idx = pick[def.key] ?? fams.findIndex((f) => def.get(f));
    return def.get(fams[idx >= 0 ? idx : 0]);
}
function cleanSupPhones(phones) {
    return (phones ?? [])
        .map((p) => ({ ...p, num: fixPhone((p.num || '').trim()) }))
        .filter((p) => p.num);
}
export function isJunkContact_ORIG(c) {
    if (!c.fullName.trim())
        return true;
    const realPhone = c.phones.some((p) => digitsOnly(p.value).length >= 5);
    return !realPhone && c.emails.length === 0;
}
export function isJunkContact(c, __opt = {}) {
    const base = isJunkContact_ORIG(c);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
