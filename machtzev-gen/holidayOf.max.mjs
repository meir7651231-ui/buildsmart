// 🤖 AUTO-EMITTED by gen-max — holidayOf משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function hebParts(d) {
    if (isNaN(d.getTime()))
        return { day: 0, month: '', year: 0 }; // תאריך לא-חוקי → חלקים בטוחים (מונע RangeError ב-formatToParts)
    const parts = fmtParts.formatToParts(d);
    const get = (t) => parts.find((p) => p.type === t)?.value ?? '';
    return { day: +get('day'), month: get('month'), year: +get('year') };
}
const HOLIDAYS = {
    'Tishri 1': 'ראש השנה',
    'Tishri 2': 'ראש השנה ב׳',
    'Tishri 3': 'צום גדליה',
    'Tishri 10': 'יום כיפור',
    'Tishri 15': 'סוכות',
    'Tishri 21': 'הושענא רבה',
    'Tishri 22': 'שמחת תורה',
    // חנוכה — 8 ימים: כ״ה כסלו עד ב׳/ג׳ טבת (התלות באורך כסלו מטופלת ע"י כך
    // שכ״ל בכסלו קיים רק בשנה מלאה, וג׳ טבת רק בשנה חסרה — תמיד 8 ימים בפועל).
    'Kislev 25': 'חנוכה',
    'Kislev 26': 'חנוכה',
    'Kislev 27': 'חנוכה',
    'Kislev 28': 'חנוכה',
    'Kislev 29': 'חנוכה',
    'Kislev 30': 'חנוכה',
    'Tevet 1': 'חנוכה',
    'Tevet 2': 'חנוכה',
    // ג' טבת (יום ח' של חנוכה) מטופל דינמית ב-holidayOf — רק כשכסלו היה חסר (29).
    'Tevet 10': 'צום עשרה בטבת',
    'Shevat 15': 'ט״ו בשבט',
    // פורים קטן / שושן פורים קטן — רק בשנה מעוברת (אדר א׳)
    'Adar I 14': 'פורים קטן',
    'Adar I 15': 'שושן פורים קטן',
    'Adar 13': 'תענית אסתר',
    'Adar II 13': 'תענית אסתר',
    'Adar 14': 'פורים',
    'Adar II 14': 'פורים',
    'Adar 15': 'שושן פורים',
    'Adar II 15': 'שושן פורים',
    'Nisan 15': 'פסח',
    'Nisan 21': 'שביעי של פסח',
    'Iyar 18': 'ל״ג בעומר',
    'Sivan 6': 'שבועות',
    'Tamuz 17': 'צום י״ז בתמוז',
    'Av 9': 'תשעה באב',
    'Av 15': 'ט״ו באב',
    'Elul 29': 'ערב ראש השנה',
};
const fmtParts = new Intl.DateTimeFormat('en-u-ca-hebrew', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
});
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
export function holidayOf_ORIG(d) {
    const p = hebParts(d);
    // חנוכה יום ח' (ג' טבת): קיים רק בשנה שכסלו בה חסר (29) — בשנה מלאה חנוכה
    // מסתיים ב-ב' טבת. שמירה על 8 ימים בדיוק בשתי סוגי-השנים.
    if (p.month === 'Tevet' && p.day === 3) {
        return scanHebYear(p.year).has30.has('Kislev') ? null : 'חנוכה';
    }
    // 🐛 נחיל-עמוק (13.8): צום י״ז בתמוז / ט׳ באב שחלו בשבת — הצום נדחה ליום ראשון
    // (כמו ביומן-החדרים, לקח #21). לא מציגים "צום" על השבת אלא על יום-הדחייה.
    const dow = d.getDay();
    const key = `${p.month} ${p.day}`;
    if (dow === 6 && (key === 'Tamuz 17' || key === 'Av 9'))
        return null; // שבת — הצום נדחה
    if (dow === 0 && p.month === 'Tamuz' && p.day === 18)
        return 'צום י״ז בתמוז (נדחה)';
    if (dow === 0 && p.month === 'Av' && p.day === 10)
        return 'תשעה באב (נדחה)';
    // דין-נדחה מלא (19.8) — אותו דפוס לשני הצומות הנותרים:
    // צום גדליה (ג' תשרי) שחל בשבת נדחה ליום ראשון (ד' תשרי) — קורה כשר"ה ביום חמישי.
    if (dow === 6 && key === 'Tishri 3')
        return null;
    if (dow === 0 && p.month === 'Tishri' && p.day === 4)
        return 'צום גדליה (נדחה)';
    // תענית אסתר (י"ג אדר) שחלה בשבת מוקדמת ליום חמישי (י"א אדר) — פורים ביום ראשון.
    if (dow === 6 && (key === 'Adar 13' || key === 'Adar II 13'))
        return null;
    if (dow === 4 && p.day === 11 && (p.month === 'Adar' || p.month === 'Adar II')) {
        return 'תענית אסתר (מוקדם)';
    }
    return HOLIDAYS[key] ?? null;
}
export function holidayOf(d, __opt = {}) {
    const base = holidayOf_ORIG(d);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
