// 🤖 AUTO-EMITTED by gen-max — blockReason משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const FULL_HOLIDAYS = [
    'ראש השנה',
    'ראש השנה ב׳',
    'יום כיפור',
    'סוכות',
    'שמחת תורה',
    'פסח',
    'שביעי של פסח',
    'שבועות',
    'תשעה באב',
];
function hpOf(iso, d) {
    let hp = hpCache.get(iso);
    if (!hp) {
        if (hpCache.size >= HP_CACHE_MAX)
            hpCache.clear();
        hp = hebParts(d ?? dateOf(iso));
        hpCache.set(iso, hp);
    }
    return hp;
}
function isoOf(d) {
    return isoLocal(d);
}
const hpCache = new Map();
const HP_CACHE_MAX = 3000;
function dateOf(iso) {
    return new Date(iso + 'T12:00:00');
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
export function blockReason_ORIG(d, kind = 'org') {
    const dow = d.getDay();
    if (dow === 6)
        return 'שבת';
    if (kind === 'course' && dow === 5)
        return 'יום שישי (שעתיים לפני שבת)';
    const hol = holidayOf(d);
    if (hol && FULL_HOLIDAYS.includes(hol))
        return hol;
    // צום תשעה באב נדחה: כשט' באב חל בשבת, הצום נצפה בי' באב (ראשון). ט' באב עצמו
    // נחסם כ'שבת', אך י' באב — הצום בפועל — לא היה נחסם. שער dow===0 מונע חישוב hp
    // מיותר ברוב הימים; חל גם על org וגם על course כמו תשעה באב המקורי.
    if (dow === 0) {
        const hpAv = hpOf(isoOf(d), d);
        if (hpAv.month === 'Av' && hpAv.day === 10)
            return 'תשעה באב (נדחה)';
    }
    if (kind === 'course') {
        const hp = hpOf(isoOf(d), d);
        if ((hp.month === 'Tishri' && hp.day >= 16 && hp.day <= 21) || (hp.month === 'Nisan' && hp.day >= 16 && hp.day <= 20))
            return 'חול המועד';
    }
    return null;
}
export function blockReason(d, kind, __opt = {}) {
    const base = blockReason_ORIG(d, kind);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
