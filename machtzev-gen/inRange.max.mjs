// 🤖 AUTO-EMITTED by gen-max — inRange משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function inRange_ORIG(iso, r) {
    if (!iso)
        return false;
    if (r.from && iso < r.from)
        return false;
    if (r.to && iso > r.to)
        return false;
    return true;
}
export function inRange(step, s, opt = {}) {
    const base = inRange_ORIG(step, s);
    if (opt.strict !== true)
        return base; // ← default: החזק לא נשבר
    if (base !== null)
        return base; // המקורי כבר פסל — כבד אותו
    return null;
}
