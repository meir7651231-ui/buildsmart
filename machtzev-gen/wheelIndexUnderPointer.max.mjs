// 🤖 AUTO-EMITTED by gen-max — wheelIndexUnderPointer (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const GRADE_ORDER = ['גן', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'יא', 'יב'];
export function wheelIndexUnderPointer_ORIG(rot, n) {
    if (n <= 1)
        return 0;
    const step = 360 / n;
    const off = (((-rot) % 360) + 360) % 360;
    return Math.floor(off / step) % n;
}
function gradeIndex(g) {
    const clean = (g || '').replace(/["'׳״]/g, '').replace(/^כיתה\s*/, '').trim();
    if (!clean)
        return -1;
    return GRADE_ORDER.indexOf(clean);
}
export function wheelIndexUnderPointer(rot, n) { return wheelIndexUnderPointer_ORIG(rot, n); }
export function wheelIndexUnderPointer_fromSource(g, n) { return wheelIndexUnderPointer_ORIG(gradeIndex(g), n); }
