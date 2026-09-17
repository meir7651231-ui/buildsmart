// 🤖 AUTO-EMITTED by gen-max — trendFromScan (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function monthsBefore(iso, todayIso) {
    // YYYY-MM → שנה*12+חודש, הפרש שלם — זול ומדויק בלי פרסור-תאריך.
    const y = +iso.slice(0, 4), m = +iso.slice(5, 7);
    const ty = +todayIso.slice(0, 4), tm = +todayIso.slice(5, 7);
    if (!y || !m || !ty || !tm)
        return -1;
    return ty * 12 + tm - (y * 12 + m);
}
export function trendFromScan_ORIG(scan) {
    const mo = scan.monthly, n = mo.length, h = Math.floor(n / 2);
    let older = 0, newer = 0;
    for (let i = 0; i < h; i++)
        older += mo[i];
    for (let i = n - h; i < n; i++)
        newer += mo[i];
    if (older === 0 && newer === 0)
        return { dir: 'flat', pct: 0 };
    const pct = older === 0 ? 100 : Math.round(((newer - older) / older) * 100);
    const dir = pct > 8 ? 'up' : pct < -8 ? 'down' : 'flat';
    return { dir, pct };
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
export function trendFromScan(scan) { return trendFromScan_ORIG(scan); }
export function trendFromScan_fromSource(sp, todayIso, rate, months) { return trendFromScan_ORIG(donorScan(sp, todayIso, rate, months)); }
