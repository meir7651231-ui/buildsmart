// 🤖 AUTO-EMITTED by gen-max — safeHttpsUrl משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function safeHttpsUrl_ORIG(raw) {
    const t = (raw || '').trim();
    if (!t)
        return null;
    try {
        const u = new URL(t);
        return u.protocol === 'https:' ? u.toString() : null;
    }
    catch {
        return null;
    }
}
export function safeHttpsUrl(raw, __opt = {}) {
    const base = safeHttpsUrl_ORIG(raw);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
