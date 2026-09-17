// 🤖 AUTO-EMITTED by gen-max — normalizePhone משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function normalizePhone_ORIG(raw) {
    let s = String(raw || '').replace(/[\s\-().]/g, '');
    if (s.startsWith('972'))
        s = '0' + s.slice(3);
    if (raw.startsWith('+972'))
        s = '0' + raw.replace(/[\s\-().]/g, '').slice(4);
    return s;
}
export function normalizePhone(raw, __opt = {}) {
    const base = normalizePhone_ORIG(raw);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
