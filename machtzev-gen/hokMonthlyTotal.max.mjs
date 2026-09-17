// 🤖 AUTO-EMITTED by gen-max — hokMonthlyTotal (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function hokEffectivelyActive(sp, todayIso) {
    const h = sp.hok;
    if (!h || !h.active)
        return false;
    if (!h.kevaId)
        return true; // הו"ק ידני — אין לאפ-אוטומטי
    let last = '';
    // 🐛 נחיל-סולה C7: גם חיובי-סולה נחשבים "חיות" של הו"ק-סליקה
    for (const e of sp.hist ?? [])
        if ((e.clearer === 'נדרים' || e.clearer === 'סולה') && (e.d || '') > last)
            last = e.d || '';
    if (!last)
        return true; // עדיין אין היסטוריית-נדרים — סומכים על הדגל
    return monthsAgoIso(last, todayIso) <= 2;
}
function hokRecordedThisMonth(sp, todayIso) {
    if (!sp.hok)
        return false;
    const month = todayIso.slice(0, 7);
    const hok = sp.hok;
    const inDonations = sp.donations.some((d) => d.date.startsWith(month) && (d.cat === HOK_CAT || (d.amount === hok.amount && (d.cur || '₪') === hok.cur)));
    if (inDonations)
        return true;
    // חיוב-נדרים כלשהו החודש ⇒ נחשב "נרשם" — **בלי דרישת-סכום-מדויק** (הו"ק בסכום-
    // משתנה, למשל שזוהתה-רטרואקטיבית, לא תוצג שגוי כ"ממתין"); נפילה: התאמת-סכום-מדויק
    // לרשומת-hist שאינה נדרים (מקור-ישן/לגאסי).
    return (sp.hist ?? []).some((h) => (h.d || '').startsWith(month) && (h.clearer === 'נדרים' || h.clearer === 'סולה' || (h.a === hok.amount && (h.c || '₪') === hok.cur)));
}
function monthsAgoIso(iso, todayIso) {
    if (!iso)
        return Infinity;
    const [y, m] = iso.slice(0, 7).split('-').map(Number);
    const [ty, tm] = todayIso.slice(0, 7).split('-').map(Number);
    return (ty - y) * 12 + (tm - m);
}
const HOK_CAT = 'הו"ק';
export function hokMonthlyTotal_ORIG(supporters, usdRate, todayIso) {
    const active = (sp) => (todayIso ? hokEffectivelyActive(sp, todayIso) : !!sp.hok?.active);
    return Math.round(supporters.reduce((a, sp) => {
        if (!active(sp) || !sp.hok)
            return a;
        return a + (sp.hok.cur === '$' ? sp.hok.amount * usdRate : sp.hok.amount);
    }, 0));
}
function hokDue(supporters, todayIso) {
    return supporters
        .filter((sp) => hokEffectivelyActive(sp, todayIso) && !hokRecordedThisMonth(sp, todayIso))
        .sort((a, b) => (a.hok?.day ?? 0) - (b.hok?.day ?? 0));
}
export function hokMonthlyTotal(supporters, usdRate, todayIso) { return hokMonthlyTotal_ORIG(supporters, usdRate, todayIso); }
export function hokMonthlyTotal_fromSource(supporters, todayIso, usdRate) { return hokMonthlyTotal_ORIG(hokDue(supporters, todayIso), usdRate, todayIso); }
