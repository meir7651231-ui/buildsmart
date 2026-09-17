// 🤖 AUTO-EMITTED by gen-max — ayinActive משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
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
export function ayinActive_ORIG(a) {
    if (!a)
        return false;
    return (a.stage !== 'new' ||
        a.names.length > 0 ||
        !!a.lastTouch ||
        a.answers.length > 0 ||
        a.log.length > 0);
}
export function ayinActive(a, __opt = {}) {
    const base = ayinActive_ORIG(a);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
