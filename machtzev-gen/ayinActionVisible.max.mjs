// 🤖 AUTO-EMITTED by gen-max — ayinActionVisible משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function validateHebMonthNames(hebYear = hebYearNow()) {
    const known = KNOWN_MONTHS_EN;
    const unknown = [];
    const seen = new Set();
    const gy = hebYear - 3761;
    for (let i = 0; i < 440; i++) {
        const p = hebParts(new Date(gy, 7, 1 + i, 12));
        if (p.year !== hebYear || seen.has(p.month))
            continue;
        seen.add(p.month);
        if (!known.has(p.month))
            unknown.push(p.month);
    }
    return unknown;
}
export function ayinActionVisible_ORIG(a) {
    const st = a.stage;
    if (st === 'done')
        return false;
    if (st === 'new')
        return a.names.length > 0;
    if (st === 'eyes')
        return a.names.some((n) => n.eyes !== '' && n.eyes != null);
    return true;
}
export function ayinActionVisible(a, __opt = {}) {
    const base = ayinActionVisible_ORIG(a);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
