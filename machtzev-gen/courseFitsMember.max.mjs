// 🤖 AUTO-EMITTED by gen-max — courseFitsMember משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function gradeFits(c, childGrade) {
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
function gradeIndex(g) {
    const clean = (g || '').replace(/["'׳״]/g, '').replace(/^כיתה\s*/, '').trim();
    if (!clean)
        return -1;
    return GRADE_ORDER.indexOf(clean);
}
const GRADE_ORDER = ['גן', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'יא', 'יב'];
export function courseFitsMember_ORIG(c, gender, age, 
/** כיתת הילד/ה — מועברת רק כש-courses.gradeimg פעיל (פער 28). */
grade) {
    if (c.gender && c.gender !== 'all' && gender && c.gender !== gender)
        return false;
    if (age != null) {
        if (c.ageMin && age < c.ageMin)
            return false;
        if (c.ageMax && age > c.ageMax)
            return false;
    }
    if (!gradeFits(c, grade))
        return false;
    return true;
}
