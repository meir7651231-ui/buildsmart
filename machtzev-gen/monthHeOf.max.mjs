// 🤖 AUTO-EMITTED by gen-max — monthHeOf (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
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
function hebYearNow() {
    return hebParts(new Date()).year;
}
const KNOWN_MONTHS_EN = new Set([...ORDER_COMMON, ...ORDER_LEAP]);
const ORDER_COMMON = [
    'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar',
    'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
];
const ORDER_LEAP = [
    'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar I', 'Adar II',
    'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
];
export function monthHeOf_ORIG(en) {
    return MONTHS.find((m) => m[0] === en)?.[1] ?? '';
}
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
export function monthHeOf(en) { return monthHeOf_ORIG(en); }
export function monthHeOf_fromSource(hebYear) { return monthHeOf_ORIG(validateHebMonthNames(hebYear)); }
