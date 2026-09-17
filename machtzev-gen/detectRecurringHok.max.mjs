// 🤖 AUTO-EMITTED by gen-max — detectRecurringHok (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function curOf(charge) {
    const raw = String(charge.currency || '').trim();
    return raw === '$' || raw === '2' || /usd|\$|דולר/i.test(raw) ? '$' : '₪';
}
function hokDayFromDate(iso) {
    const d = Number((iso || '').slice(8, 10));
    return isFinite(d) && d >= 1 ? Math.min(28, Math.floor(d)) : 1;
}
function withNedarimHok(sp, charge) {
    if (!(charge.amount > 0))
        return sp; // זיכוי/ביטול (Amount≤0) לא ממלא/מעדכן הו"ק
    const keva = (charge.kevaId || '').trim();
    if (!keva)
        return sp;
    if (sp.hok && !sp.hok.kevaId)
        return sp; // הו"ק ידני — לא דורסים
    const cd = (charge.d || charge.at || '').slice(0, 10);
    const prevStart = sp.hok?.startedAt || '';
    return {
        ...sp,
        hok: {
            amount: charge.amount,
            cur: curOf(charge),
            day: hokDayFromDate(cd),
            method: 'card',
            note: 'הו״ק נדרים · ' + keva,
            active: true,
            startedAt: prevStart && prevStart < cd ? prevStart : cd || prevStart || '',
            kevaId: keva,
        },
    };
}
export function detectRecurringHok(supporters, todayIso, minMonths) { return detectRecurringHok_ORIG(supporters, todayIso, minMonths); }
export function detectRecurringHok_fromSource(sp, charge, todayIso, minMonths) { return detectRecurringHok_ORIG(withNedarimHok(sp, charge), todayIso, minMonths); }
