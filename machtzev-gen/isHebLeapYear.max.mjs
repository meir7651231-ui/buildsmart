// 🤖 AUTO-EMITTED by gen-max — isHebLeapYear משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const leapCache = new Map();
function hebToIsoEn(day, monthEn, hebYear) {
    if (!Number.isInteger(day) || day < 1 || day > 30)
        return null;
    if (!Number.isInteger(hebYear) || hebYear < 4000 || hebYear > 7000)
        return null;
    const gy = hebYear - 3761; // 1 באוגוסט של השנה הזו קודם תמיד לא׳ תשרי של hebYear
    for (let i = 0; i < 440; i++) {
        const d = new Date(gy, 7, 1 + i, 12); // צהריים — חסין להיסטי שעון קיץ
        const p = hebParts(d);
        if (p.year === hebYear && p.month === monthEn && p.day === day)
            return isoOf(d);
    }
    return null; // התאריך לא קיים בשנה זו (למשל ל׳ חשוון בשנה חסרה/כסדרה)
}
function isoOf(d) {
    return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate());
}
function pad2(n) {
    return String(n).padStart(2, '0');
}
function setAllowedPurposes(p) {
    allowedPurposes = p && p.length ? p : null;
}
function getSyncLastError() { return lastError; }
export function isHebLeapYear_ORIG(hebYear) {
    const hit = leapCache.get(hebYear);
    if (hit !== undefined)
        return hit;
    const leap = hebToIsoEn(1, 'Adar I', hebYear) !== null;
    leapCache.set(hebYear, leap);
    return leap;
}
export function isHebLeapYear(hebYear, __opt = {}) {
    const base = isHebLeapYear_ORIG(hebYear);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
