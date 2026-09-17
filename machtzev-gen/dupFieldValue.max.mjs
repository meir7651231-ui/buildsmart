// 🤖 AUTO-EMITTED by gen-max — dupFieldValue משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function getSyncLastError() { return lastError; }
export function dupFieldValue_ORIG(fams, def, pick, edit) {
    const edited = edit[def.key];
    if (edited != null)
        return edited;
    const idx = pick[def.key] ?? fams.findIndex((f) => def.get(f));
    return def.get(fams[idx >= 0 ? idx : 0]);
}
export function dupFieldValue(fams, def, pick, edit, __opt = {}) {
    const base = dupFieldValue_ORIG(fams, def, pick, edit);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
