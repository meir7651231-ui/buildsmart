// 🤖 AUTO-EMITTED by gen-max — supDupFieldValue משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function getSyncLastError() { return lastError; }
export function supDupFieldValue_ORIG(sups, def, pick, edit) {
    const edited = edit[def.key];
    if (edited != null)
        return edited;
    const idx = pick[def.key] ?? sups.findIndex((s) => def.get(s));
    return def.get(sups[idx >= 0 ? idx : 0]);
}
export function supDupFieldValue(sups, def, pick, edit, __opt = {}) {
    const base = supDupFieldValue_ORIG(sups, def, pick, edit);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
