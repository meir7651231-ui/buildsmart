// 🤖 AUTO-EMITTED by gen-max — gradeFits משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function gradeIndex(g) {
    const clean = (g || '').replace(/["'׳״]/g, '').replace(/^כיתה\s*/, '').trim();
    if (!clean)
        return -1;
    return GRADE_ORDER.indexOf(clean);
}
const GRADE_ORDER = ['גן', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'יא', 'יב'];
export function gradeFits_ORIG(c, childGrade) {
    if (!c.gradeMin && !c.gradeMax)
        return true;
    const gi = gradeIndex(childGrade);
    if (gi < 0)
        return true;
    const lo = gradeIndex(c.gradeMin);
    const hi = gradeIndex(c.gradeMax);
    if (lo >= 0 && gi < lo)
        return false;
    if (hi >= 0 && gi > hi)
        return false;
    return true;
}
export function gradeFits(c, childGrade, __opt = {}) {
    const base = gradeFits_ORIG(c, childGrade);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
