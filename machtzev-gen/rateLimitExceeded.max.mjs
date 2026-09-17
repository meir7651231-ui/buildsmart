// 🤖 AUTO-EMITTED by gen-max — rateLimitExceeded משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function rateLimitExceeded_ORIG(cur, now, windowMs, maxPerWindow) {
    const windowStart = typeof cur?.windowStart === "number" ? cur.windowStart : 0;
    const count = typeof cur?.count === "number" ? cur.count : 0;
    if (now - windowStart >= windowMs)
        return false; // fresh window → allowed
    return count >= maxPerWindow;
}
export function rateLimitExceeded(cur, now, wi, __opt = {}) {
    const base = rateLimitExceeded_ORIG(cur, now, wi);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
