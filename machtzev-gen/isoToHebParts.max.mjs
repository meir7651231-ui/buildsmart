// 🤖 AUTO-EMITTED by gen-max — isoToHebParts (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function isHebLeapYear(hebYear) {
    const hit = leapCache.get(hebYear);
    if (hit !== undefined)
        return hit;
    const leap = hebToIsoEn(1, 'Adar I', hebYear) !== null;
    leapCache.set(hebYear, leap);
    return leap;
}
const ORDER_LEAP = [
    'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar I', 'Adar II',
    'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
];
const ORDER_COMMON = [
    'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar',
    'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
];
function monthHeOf(en) {
    return MONTHS.find((m) => m[0] === en)?.[1] ?? '';
}
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
const MONTHS = [
    ['Tishri', 'תשרי'],
    ['Heshvan', 'חשוון'],
    ['Kislev', 'כסלו'],
    ['Tevet', 'טבת'],
    ['Shevat', 'שבט'],
    ['Adar', 'אדר'],
    ['Adar I', 'אדר א׳'],
    ['Adar II', 'אדר ב׳'],
    ['Nisan', 'ניסן'],
    ['Iyar', 'אייר'],
    ['Sivan', 'סיוון'],
    ['Tamuz', 'תמוז'],
    ['Av', 'אב'],
    ['Elul', 'אלול'],
];
function isoOf(d) {
    return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate());
}
function pad2(n) {
    return String(n).padStart(2, '0');
}
function hebMonthsOf(hebYear) {
    const order = isHebLeapYear(hebYear) ? ORDER_LEAP : ORDER_COMMON;
    return order.map(monthHeOf);
}
export function isoToHebParts(iso) { return isoToHebParts_ORIG(iso); }
export function isoToHebParts_fromSource(hebYear) { return isoToHebParts_ORIG(hebMonthsOf(hebYear)); }
