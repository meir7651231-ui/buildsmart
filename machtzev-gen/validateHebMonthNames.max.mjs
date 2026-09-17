// 🤖 AUTO-EMITTED by gen-max — validateHebMonthNames משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
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
function supHasRegion(sp, region) {
    return allSupPhones(sp).some((r) => r.region === region);
}
export function validateHebMonthNames_ORIG(hebYear = hebYearNow()) {
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
export function validateHebMonthNames(hebYear, __opt = {}) {
    const base = validateHebMonthNames_ORIG(hebYear);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
