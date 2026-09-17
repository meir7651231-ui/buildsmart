// 🤖 AUTO-EMITTED by gen-max — churnFromScan (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function dayDiff(iso, todayIso) {
    if (!iso)
        return Infinity;
    const a = Date.parse(iso.slice(0, 10) + 'T12:00:00');
    const b = Date.parse(todayIso.slice(0, 10) + 'T12:00:00');
    if (Number.isNaN(a) || Number.isNaN(b))
        return Infinity;
    return Math.floor((b - a) / MS_DAY);
}
function monthsBefore(iso, todayIso) {
    // YYYY-MM → שנה*12+חודש, הפרש שלם — זול ומדויק בלי פרסור-תאריך.
    const y = +iso.slice(0, 4), m = +iso.slice(5, 7);
    const ty = +todayIso.slice(0, 4), tm = +todayIso.slice(5, 7);
    if (!y || !m || !ty || !tm)
        return -1;
    return ty * 12 + tm - (y * 12 + m);
}
const MS_DAY = 86400000;
export function churnFromScan_ORIG(scan, todayIso) {
    if (scan.count === 0 || !scan.last)
        return 0;
    const daysSince = dayDiff(scan.last, todayIso);
    const span = scan.first && scan.first !== scan.last ? dayDiff(scan.first, scan.last) : 0;
    const cadence = scan.count >= 2 && span > 0 ? span / (scan.count - 1) : 365;
    const expected = Math.max(30, cadence * 1.5); // חלון-חסד
    const ratio = daysSince / expected; // 1 = הגיע-הזמן · 2 = איחר-פי-2
    return Math.max(0, Math.min(100, Math.round(ratio * 50)));
}
function donorScan(sp, todayIso, rate = 3.7, months = 12) {
    const monthly = new Array(months).fill(0);
    let count = 0, ils = 0, first = '', last = '';
    const take = (date, amount, cur) => {
        if (!date)
            return;
        count++;
        const v = (cur || '₪') === '$' ? amount * rate : amount;
        ils += v;
        if (!first || date < first)
            first = date;
        if (!last || date > last)
            last = date;
        const mb = monthsBefore(date, todayIso);
        if (mb >= 0 && mb < months)
            monthly[months - 1 - mb] += v;
    };
    const dons = sp.donations;
    for (let i = 0; i < dons.length; i++)
        take(dons[i].date, dons[i].amount, dons[i].cur);
    const hist = sp.hist;
    if (hist)
        for (let i = 0; i < hist.length; i++)
            take(hist[i].d, hist[i].a, hist[i].c);
    return { count, ils, first, last, monthly };
}
export function churnFromScan(scan, todayIso) { return churnFromScan_ORIG(scan, todayIso); }
export function churnFromScan_fromSource(sp, todayIso, rate, months) { return churnFromScan_ORIG(donorScan(sp, todayIso, rate, months), todayIso); }
