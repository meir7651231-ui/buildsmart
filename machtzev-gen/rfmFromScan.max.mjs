// 🤖 AUTO-EMITTED by gen-max — rfmFromScan (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function dayDiff(iso, todayIso) {
    if (!iso)
        return Infinity;
    const a = Date.parse(iso.slice(0, 10) + 'T12:00:00');
    const b = Date.parse(todayIso.slice(0, 10) + 'T12:00:00');
    if (Number.isNaN(a) || Number.isNaN(b))
        return Infinity;
    return Math.floor((b - a) / MS_DAY);
}
function rScore(days) {
    return days <= 30 ? 350 : days <= 90 ? 280 : days <= 180 ? 200 : days <= 365 ? 120 : 40;
}
function fScore(cnt) {
    return cnt >= 10 ? 300 : cnt >= 5 ? 230 : cnt >= 3 ? 160 : cnt >= 2 ? 100 : 50;
}
function mScore(tot) {
    return tot >= 5000 ? 350 : tot >= 2000 ? 280 : tot >= 1000 ? 210 : tot >= 500 ? 140 : tot >= 100 ? 80 : 40;
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
export function rfmFromScan_ORIG(scan, todayIso) {
    const days = scan.last ? dayDiff(scan.last, todayIso) : 99999;
    const r = rScore(days), f = fScore(scan.count), m = mScore(scan.ils);
    return {
        r, f, m, score: r + f + m,
        rPct: Math.round((r / 350) * 100),
        fPct: Math.round((f / 300) * 100),
        mPct: Math.round((m / 350) * 100),
    };
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
export function rfmFromScan(scan, todayIso) { return rfmFromScan_ORIG(scan, todayIso); }
export function rfmFromScan_fromSource(sp, todayIso, rate, months) { return rfmFromScan_ORIG(donorScan(sp, todayIso, rate, months), todayIso); }
