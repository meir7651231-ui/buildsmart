// 🤖 AUTO-EMITTED by gen-max — numMatch משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function numMatch_ORIG(q, n) {
    q = String(q || '').trim();
    if (!q)
        return true;
    let m = q.match(/^(\d+)\s*\+$/);
    if (m)
        return n >= +m[1];
    m = q.match(/^(\d+)\s*-\s*(\d+)$/);
    if (m)
        return n >= +m[1] && n <= +m[2];
    if (/^\d+$/.test(q))
        return n === +q;
    return true;
}
export function numMatch(step, s, opt = {}) {
    const base = numMatch_ORIG(step, s);
    if (opt.strict !== true)
        return base; // ← default: החזק לא נשבר
    if (base !== null)
        return base; // המקורי כבר פסל — כבד אותו
    return null;
}
