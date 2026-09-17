function cockpitKpis(supporters, todayIso, rate = 3.7) {
    return {
        total: supporters.length,
        collected: cockpitCollectedThisMonth(supporters, todayIso, rate),
        // 🐛 (21.8): בלי todayIso הו"ק-נדרים שפגה (>2 חודשים שקט) נספרה ב"צפוי מהו״ק",
        // בעוד תור-המשימות (hokDue) כבר מחריג אותה — אותו-כלל לשני המשטחים.
        expectedHok: hokMonthlyTotal(supporters, rate, todayIso),
        atRisk: cockpitAtRisk(supporters, todayIso).length,
    };
}
function cockpitCollectedThisMonth(supporters, todayIso, rate = 3.7) {
    const month = todayIso.slice(0, 7);
    let sum = 0;
    for (const sp of supporters) {
        for (const d of sp.donations) {
            if (!d.date.startsWith(month))
                continue;
            sum += (d.cur || '₪') === '$' ? d.amount * rate : d.amount;
        }
        for (const h of sp.hist ?? []) {
            if (!(h.d || '').startsWith(month))
                continue;
            sum += (h.c || '₪') === '$' ? h.a * rate : h.a;
        }
    }
    return Math.round(sum);
}
function cockpitAtRisk(supporters, todayIso, silentDays = COCKPIT_SILENT_DAYS) {
    return supporters
        .filter((sp) => {
        if (!hasGiven(sp))
            return false;
        if (sp.nextDate)
            return false; // יש יעד מתוזמן (עתידי או עבר) ⇒ מטופל דרך השיחות
        return daysSince(supLast(sp), todayIso) >= silentDays;
    })
        .sort((a, b) => daysSince(supLast(b), todayIso) - daysSince(supLast(a), todayIso));
}
const COCKPIT_SILENT_DAYS = 60;
function hasGiven(sp) {
    return supCount(sp) > 0 && !!supLast(sp);
}
function daysSince(iso, todayIso) {
    if (!iso)
        return Infinity;
    const t = new Date(iso + 'T12:00:00').getTime();
    const now = new Date(todayIso + 'T12:00:00').getTime();
    if (Number.isNaN(t) || Number.isNaN(now))
        return Infinity;
    return Math.floor((now - t) / MS_DAY);
}
const MS_DAY = 86400000;
function cockpitQueue(supporters, todayIso, rate = 3.7) {
    const calls = cockpitCalls(supporters, todayIso, rate);
    const thanks = cockpitThanks(supporters, todayIso);
    const hok = cockpitHokTasks(supporters, todayIso);
    const tasks = [...calls, ...thanks, ...hok];
    return { calls, thanks, hok, tasks, total: tasks.length };
}
function cockpitCalls(supporters, todayIso, rate = 3.7, silentDays = COCKPIT_SILENT_DAYS) {
    const tasks = [];
    const seen = new Set();
    // ── יעד-קשר שעבר ──
    for (const sp of supporters) {
        if (!sp.nextDate || sp.nextDate > todayIso)
            continue;
        const late = daysSince(sp.nextDate, todayIso);
        tasks.push({
            id: 'call:' + sp.id,
            kind: 'call',
            supId: sp.id,
            name: sp.name,
            phone: sp.phone || '',
            email: sp.email || '',
            reason: (late <= 0 ? 'יעד-קשר להיום' : 'יעד-קשר עבר לפני ' + late + ' יום') +
                (sp.nextNote ? ' · 📝 ' + sp.nextNote : ''),
            severity: 'due',
            sort: 1000000 + late, // כל היעדים-שעברו לפני כל השקטים
        });
        seen.add(sp.id);
    }
    // ── בסיכון-נטישה ──
    for (const sp of cockpitAtRisk(supporters, todayIso, silentDays)) {
        if (seen.has(sp.id))
            continue;
        const silent = daysSince(supLast(sp), todayIso);
        tasks.push({
            id: 'call:' + sp.id,
            kind: 'call',
            supId: sp.id,
            name: sp.name,
            phone: sp.phone || '',
            email: sp.email || '',
            reason: valueTag(sp, rate) + ' · שקט/ה ' + silent + ' יום',
            severity: 'risk',
            sort: silent,
        });
        seen.add(sp.id);
    }
    return tasks.sort((a, b) => b.sort - a.sort);
}
function cockpitThanks(supporters, todayIso, windowDays = COCKPIT_THANK_DAYS) {
    const tasks = [];
    for (const sp of supporters) {
        const last = latestDonation(sp);
        if (!last)
            continue;
        const ago = daysSince(last.date, todayIso);
        if (ago < 0 || ago > windowDays)
            continue;
        const money = last.cur === '$' ? '$' + last.amount.toLocaleString('en-US') : '₪' + last.amount.toLocaleString('he-IL');
        tasks.push({
            id: 'thanks:' + sp.id,
            kind: 'thanks',
            supId: sp.id,
            name: sp.name,
            phone: sp.phone || '',
            email: sp.email || '',
            reason: 'תרם/ה ' + money + ' · ' + (ago <= 0 ? 'היום' : 'לפני ' + ago + ' יום'),
            severity: 'warm',
            sort: windowDays - ago, // החדש ביותר ראשון
        });
    }
    return tasks.sort((a, b) => b.sort - a.sort);
}
function cockpitHokTasks(supporters, todayIso) {
    return hokDue(supporters, todayIso).map((sp) => {
        const hok = sp.hok;
        const money = hok.cur === '$' ? '$' + hok.amount.toLocaleString('en-US') : '₪' + hok.amount.toLocaleString('he-IL');
        return {
            id: 'hok:' + sp.id,
            kind: 'hok',
            supId: sp.id,
            name: sp.name,
            phone: sp.phone || '',
            email: sp.email || '',
            reason: 'הו״ק ' + money + ' · יום ' + hok.day + ' — טרם נרשם החודש',
            severity: 'due',
            sort: 100 - (hok.day || 0), // מוקדם בחודש = דחוף יותר
        };
    });
}
function valueTag(sp, rate) {
    const ils = supIls(sp) + supUsd(sp) * rate;
    if (ils >= 5000)
        return 'תורם/ת מרכזי/ת';
    if (ils >= 1000)
        return 'תורם/ת מהותי/ת';
    return 'תורם/ת';
}
const COCKPIT_THANK_DAYS = 3;
function latestDonation(sp) {
    let best = null;
    for (const d of sp.donations) {
        if (!d.date)
            continue;
        if (!best || d.date > best.date)
            best = { date: d.date, amount: d.amount, cur: d.cur || '₪' };
    }
    for (const h of sp.hist ?? []) {
        if (!h.d)
            continue;
        if (!best || h.d > best.date)
            best = { date: h.d, amount: h.a, cur: h.c || '₪' };
    }
    return best;
}
function seasonality(supporters, rate = 3.7) {
    const ils = new Array(13).fill(0); // אינדקס 1–12
    const gifts = new Array(13).fill(0);
    const donorHits = new Array(13).fill(0);
    for (const sp of supporters) {
        const seen = new Array(13).fill(false);
        const take = (date, amount, cur) => {
            const m = M(date);
            if (!m)
                return;
            ils[m] += (cur || '₪') === '$' ? amount * rate : amount;
            gifts[m]++;
            seen[m] = true;
        };
        const dons = sp.donations;
        for (let i = 0; i < dons.length; i++)
            take(dons[i].date, dons[i].amount, dons[i].cur);
        const hist = sp.hist;
        if (hist)
            for (let i = 0; i < hist.length; i++)
                take(hist[i].d, hist[i].a, hist[i].c);
        for (let m = 1; m <= 12; m++)
            if (seen[m])
                donorHits[m]++;
    }
    const byMonth = [];
    let totalIls = 0, peakMonth = 0, peakIls = -1, troughMonth = 0, troughIls = Infinity;
    for (let m = 1; m <= 12; m++) {
        const v = Math.round(ils[m]);
        byMonth.push({ month: m, ils: v, gifts: gifts[m], donors: donorHits[m] });
        totalIls += v;
        if (v > peakIls) {
            peakIls = v;
            peakMonth = m;
        }
        if (gifts[m] > 0 && v < troughIls) {
            troughIls = v;
            troughMonth = m;
        }
    }
    if (peakIls <= 0)
        peakMonth = 0;
    return {
        byMonth,
        peakMonth,
        troughMonth,
        totalIls,
        peakShare: totalIls > 0 && peakMonth ? Math.round((peakIls / totalIls) * 100) : 0,
    };
}
function visibleSupportersForDesignations(supporters, allowed) {
    if (!allowed || !allowed.length)
        return supporters;
    const set = new Set(allowed.map((s) => s.trim()));
    return supporters
        .filter((sup) => supporterVisibleForDesignations(sup, allowed))
        .map((sup) => ({
        ...sup,
        donations: (sup.donations ?? []).filter((d) => {
            const p = (d.purpose ?? '').trim();
            return !p || set.has(p);
        }),
    }));
}
function supporterVisibleForDesignations(sup, allowed) {
    if (!allowed || !allowed.length)
        return true;
    const fw = (sup.forWho ?? '').trim();
    // הכרעת-בעלים 19.8 (היפוך #8): עובד-סגור-לייעוד רואה **רק** את הייעוד שלו —
    // תורם בלי ייעוד אינו נראה לו (קודם: משותף). אכיפה-מלאה בשרת = עדכון Rules.
    if (!fw)
        return false;
    return new Set(allowed.map((s) => s.trim())).has(fw);
}
function supScoreBins(supporters, rate = 3.7) {
    const bins = Array(10).fill(0);
    for (const sp of supporters)
        bins[Math.min(9, Math.floor(supScore(sp, rate) / 100))]++;
    return bins;
}
function supScore(sp, rate = 3.7) {
    const tot = supTotalIls(sp, rate);
    const last = supLast(sp);
    const cnt = supCount(sp);
    const days = last
        ? Math.floor((Date.now() - new Date(last + 'T12:00:00').getTime()) / 86400000)
        : 9999;
    const R = days <= 30 ? 350 : days <= 90 ? 280 : days <= 180 ? 200 : days <= 365 ? 120 : 40;
    const F = cnt >= 10 ? 300 : cnt >= 5 ? 230 : cnt >= 3 ? 160 : cnt >= 2 ? 100 : 50;
    const M = tot >= 5000 ? 350 : tot >= 2000 ? 280 : tot >= 1000 ? 210 : tot >= 500 ? 140 : tot >= 100 ? 80 : 40;
    return R + F + M;
}
function supTotalIls(sp, rate = 3.7) {
    return supIls(sp) + supUsd(sp) * rate;
}
function supLast(sp) {
    let m = sp.last || '';
    for (const h of sp.hist ?? [])
        if (h.d > m)
            m = h.d;
    return m;
}
function supCount(sp) {
    return (sp.count || 0) + (sp.hist ?? []).filter((h) => (h.a || 0) > 0).length;
}
function supIls(sp) {
    return (sp.ils || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? 0 : h.a), 0);
}
function supUsd(sp) {
    return (sp.usd || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? h.a : 0), 0);
}
function orgCalEntries(supporters) {
    const out = [];
    for (const sp of supporters) {
        for (const e of supDonEvents(sp))
            out.push({ date: e.date, amount: e.amount, cur: e.cur, src: e.src, name: sp.name, spId: sp.id });
        for (const l of sp.ayin?.log ?? []) {
            out.push({ date: l.date, amount: 0, cur: '', src: '🧿 ' + l.eyes + (l.name ? ' — ' + l.name : ''), name: sp.name, spId: sp.id });
        }
        for (const an of sp.ayin?.answers ?? [])
            out.push({ date: an.date, amount: 0, cur: '', src: '📞 תשובה: ' + an.note, name: sp.name, spId: sp.id });
        if (sp.ayin?.nextTalk)
            out.push({ date: sp.ayin.nextTalk, amount: 0, cur: '', src: '🔁 לדבר שוב', name: sp.name, spId: sp.id });
    }
    return out.filter((e) => !!e.date);
}
function supDonEvents(sp, config) {
    const T = (k, fb) => (config ? termOf(config, k, fb) : fb);
    const out = (sp.donations || []).map((d) => ({
        date: d.date,
        amount: d.amount,
        cur: d.cur || '₪',
        src: 'קבלה ' + d.rid,
        rid: d.rid,
    }));
    for (const h of sp.hist || []) {
        // 13.8 — פירוט מטא-דאטת-הסליקה בשורת-ההיסטוריה (רק שדות שקיימים).
        const meta = [
            h.receipt && 'קבלה ' + h.receipt,
            h.txn && 'עסקה ' + h.txn,
            h.ref && 'אסמכתא ' + h.ref,
            h.brand,
            h.last4 && '•' + h.last4,
            h.clearer,
            h.pays && h.pays > 1 && h.pays + ' תשלומים',
            h.status,
        ]
            .filter(Boolean)
            .join(' · ');
        // הכרעת-בעלים 19.8 ("אין יותר קובץ היסטורי — נדרים זה חי"): רשומה שהגיעה מחברת-
        // סליקה (clearer, למשל נדרים) היא תרומה חיה — מוצגת כ"תרומה", לא "מהקובץ ההיסטורי".
        // רק ייבוא-קובץ-ישן (בלי חברה-סולקת) נשאר "מהקובץ ההיסטורי" (תאימות-לאחור).
        const label = h.clearer ? T('entity.donation', 'תרומה') : 'מהקובץ ההיסטורי';
        out.push({ date: h.d, amount: h.a, cur: h.c || '₪', src: label + (meta ? ' · ' + meta : '') });
    }
    if (!(sp.hist || []).length) {
        const seen = new Set(out.map((x) => x.date));
        if (sp.first && !seen.has(sp.first))
            out.push({ date: sp.first, amount: 0, cur: '', src: T('entity.donation', 'תרומה') + ' ראשונה (מהקובץ)' });
        if (sp.last && sp.last !== sp.first && !seen.has(sp.last))
            out.push({ date: sp.last, amount: 0, cur: '', src: T('entity.donation', 'תרומה') + ' אחרונה (מהקובץ)' });
    }
    return out.sort((a, b) => String(b.date).localeCompare(String(a.date)));
}
function hokDue(supporters, todayIso) {
    return supporters
        .filter((sp) => hokEffectivelyActive(sp, todayIso) && !hokRecordedThisMonth(sp, todayIso))
        .sort((a, b) => (a.hok?.day ?? 0) - (b.hok?.day ?? 0));
}
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
function tierTrendCounts(supporters, todayIso, rate = 3.7) {
    const order = ['זהב', 'כסף', 'ארד', 'רדומה'];
    const map = new Map(order.map((t) => [t, { tier: t, total: 0, rising: 0, falling: 0, stable: 0 }]));
    for (const sp of supporters) {
        const scan = donorScan(sp, todayIso, rate, 12);
        if (scan.count === 0)
            continue;
        const tier = supTier(rfmFromScan(scan, todayIso).score).label;
        const row = map.get(tier);
        if (!row)
            continue;
        row.total++;
        const d = trendFromScan(scan).dir;
        if (d === 'up')
            row.rising++;
        else if (d === 'down')
            row.falling++;
        else
            row.stable++;
    }
    return order.map((t) => map.get(t));
}
function segmentCounts(supporters, todayIso, rate = 3.7) {
    const atRiskCount = cockpitAtRisk(supporters, todayIso).length;
    return SEGMENTS.map((seg) => ({
        key: seg.key,
        label: seg.label,
        dot: seg.dot,
        count: seg.key === 'atrisk'
            ? atRiskCount
            : supporters.reduce((n, sp) => n + (seg.match(sp, todayIso, rate) ? 1 : 0), 0),
    }));
}
const SEGMENTS = [
    {
        key: 'atrisk',
        label: 'בסיכון נטישה',
        dot: '#b45309',
        // נתן-בעבר, שקט מעל הסף, בלי יעד-קשר — זהה להגדרת הקוקפיט (מקור-אמת אחד).
        match: (sp, today) => {
            // מימוש דרך cockpitAtRisk כדי לשמור מקור-אמת יחיד (ראה segmentCounts).
            void sp;
            void today;
            return false;
        },
    },
    {
        key: 'goldsilent',
        label: 'זהב · שקטים 60+ יום',
        dot: '#a05008',
        match: (sp, today, rate) => totalIls(sp, rate) >= SEGMENT_GOLD_ILS && daysSince(supLast(sp), today) >= SEGMENT_GOLD_SILENT_DAYS,
    },
    {
        key: 'hok',
        label: 'הו״ק פעילות',
        dot: '#2e7d32',
        match: (sp) => sp.hok?.active === true,
    },
    {
        key: 'gave12m',
        label: 'תרמו ב-12 החודשים',
        dot: '#1d4ed8',
        match: (sp, today) => {
            const last = supLast(sp);
            return !!last && daysSince(last, today) <= 365;
        },
    },
    {
        key: 'noemail',
        label: 'ללא אימייל',
        dot: '#8a8172',
        match: (sp) => !sp.email,
    },
];
function totalIls(sp, rate) {
    return supIls(sp) + supUsd(sp) * rate;
}
const SEGMENT_GOLD_ILS = 5000;
const SEGMENT_GOLD_SILENT_DAYS = 60;
function atRiskIdSet(supporters, todayIso) {
    return new Set(cockpitAtRisk(supporters, todayIso).map((s) => s.id));
}
function sup12m(supporters, todayIso) {
    const d = new Date(todayIso + 'T12:00:00');
    d.setDate(d.getDate() - 365);
    const p2 = (n) => String(n).padStart(2, '0');
    const cut = `${d.getFullYear()}-${p2(d.getMonth() + 1)}-${p2(d.getDate())}`;
    let n = 0;
    for (const sp of supporters) {
        const last = supLast(sp);
        if (last && last >= cut)
            n++;
    }
    return n;
}
function hokMonthlyTotal(supporters, usdRate, todayIso) {
    const active = (sp) => (todayIso ? hokEffectivelyActive(sp, todayIso) : !!sp.hok?.active);
    return Math.round(supporters.reduce((a, sp) => {
        if (!active(sp) || !sp.hok)
            return a;
        return a + (sp.hok.cur === '$' ? sp.hok.amount * usdRate : sp.hok.amount);
    }, 0));
}
function supAvgDon(supporters, rate = 3.7) {
    const totIls = supporters.reduce((a, x) => a + supTotalIls(x, rate), 0);
    const totCnt = supporters.reduce((a, x) => a + supCount(x), 0);
    return totCnt ? Math.round(totIls / totCnt) : null;
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
function monthsBefore(iso, todayIso) {
    // YYYY-MM → שנה*12+חודש, הפרש שלם — זול ומדויק בלי פרסור-תאריך.
    const y = +iso.slice(0, 4), m = +iso.slice(5, 7);
    const ty = +todayIso.slice(0, 4), tm = +todayIso.slice(5, 7);
    if (!y || !m || !ty || !tm)
        return -1;
    return ty * 12 + tm - (y * 12 + m);
}
function mergeSupporterRow(sp, row) {
    return {
        ...sp,
        ...(row.hist?.length ? { hist: mergeHist(sp.hist ?? [], row.hist) } : {}),
        name: row.name.trim() || sp.name,
        phone: row.phone ? fixPhone(row.phone.trim()) : sp.phone,
        email: row.email.trim() || sp.email,
        idNum: row.idNum.trim() || sp.idNum,
        address: row.address.trim() || sp.address,
        cat: row.cat.trim() || sp.cat,
        forWho: row.forWho.trim() || sp.forWho,
    };
}
function mergeHist(existing, incoming) {
    const key = (h) => h.d + '|' + h.a + '|' + (h.c ?? '₪');
    // אינדקס-נכנס פר-מפתח (בסדר) — משמש גם ל**העשרת** רשומות קיימות וגם לספירה.
    const incByKey = new Map();
    for (const h of incoming) {
        const arr = incByKey.get(key(h));
        if (arr)
            arr.push(h);
        else
            incByKey.set(key(h), [h]);
    }
    // העשרה (13.8b): רשומה קיימת שיובאה **לפני** שדות-המטא-דאטה (בלי txn/מותג/…)
    // מתמלאת מהשורה-הנכנסת התואמת — הערך הקיים גובר, הנכנס ממלא רק חוסרים. כך
    // ייבוא-חוזר של אותו קובץ *משדרג* עסקאות ותיקות בלי לשכפל אותן.
    const usedInc = new Map();
    const out = existing.map((h) => {
        const k = key(h);
        const arr = incByKey.get(k);
        const idx = usedInc.get(k) ?? 0;
        if (arr && idx < arr.length) {
            usedInc.set(k, idx + 1);
            return { ...arr[idx], ...h }; // נכנס ממלא חוסרים; קיים גובר על חפיפה
        }
        return { ...h };
    });
    // דחיפת מופעים-נכנסים מעבר לכמות-הקיימת (עסקאות חדשות באמת) — עם כל שדותיהן.
    const haveCount = new Map();
    for (const h of existing)
        haveCount.set(key(h), (haveCount.get(key(h)) ?? 0) + 1);
    const seen = new Map();
    for (const h of incoming) {
        const k = key(h);
        const n = (seen.get(k) ?? 0) + 1;
        seen.set(k, n);
        if (n > (haveCount.get(k) ?? 0))
            out.push({ ...h });
    }
    return out.sort((x, y) => x.d.localeCompare(y.d));
}
function fixPhone(p) {
    return formatIsraeliPhone(p);
}
function tierAsOf(sp, asOfIso, rate = 3.7) {
    const cut = asOfIso.slice(0, 10);
    const asMs = Date.parse(cut + 'T12:00:00');
    let count = 0, ils = 0, last = '';
    const take = (date, amount, cur) => {
        if (!date)
            return;
        const d = date.slice(0, 10);
        if (d > cut)
            return; // אחרי נקודת-הזמן — לא קיים עדיין
        count++;
        ils += (cur || '₪') === '$' ? amount * rate : amount;
        if (!last || d > last)
            last = d;
    };
    const dons = sp.donations;
    for (let i = 0; i < dons.length; i++)
        take(dons[i].date, dons[i].amount, dons[i].cur);
    const hist = sp.hist;
    if (hist)
        for (let i = 0; i < hist.length; i++)
            take(hist[i].d, hist[i].a, hist[i].c);
    if (count === 0)
        return null;
    const days = last ? Math.floor((asMs - Date.parse(last + 'T12:00:00')) / MS_DAY) : 99999;
    const score = rScore(days) + fScore(count) + mScore(ils);
    return supTier(score).label;
}
function rScore(days) { return days <= 30 ? 350 : days <= 90 ? 280 : days <= 180 ? 200 : days <= 365 ? 120 : 40; }
function fScore(c) { return c >= 10 ? 300 : c >= 5 ? 230 : c >= 3 ? 160 : c >= 2 ? 100 : 50; }
function mScore(t) { return t >= 5000 ? 350 : t >= 2000 ? 280 : t >= 1000 ? 210 : t >= 500 ? 140 : t >= 100 ? 80 : 40; }
function totalLabel(sp) {
    const i = supIls(sp);
    const u = supUsd(sp);
    const ils = i ? '₪' + i.toLocaleString('he-IL') : '';
    const usd = u ? '$' + u.toLocaleString('he-IL') : '';
    return ils && usd ? ils + ' + ' + usd : ils || usd || '—';
}
function applyAyinNames(sp, names, mkId) {
    let a = sp.ayin ?? emptyAyin();
    let changed = false;
    for (const nm of names) {
        if (!planAddName(a, nm, '', '').ok)
            continue; // כפילות/ריק — דילוג שקט, בלי לשרוף מזהה
        const plan = planAddName(a, nm, '', mkId());
        if (plan.ok) {
            a = { ...a, names: plan.names };
            changed = true;
        }
    }
    return changed ? { ...sp, ayin: a } : sp;
}
function allSupPhones(sp) {
    const rows = [];
    if (sp.phone)
        rows.push({ num: sp.phone, label: '', note: '', wa: false, region: phoneRegion(sp.phone), primary: true });
    for (const p of sp.phones ?? []) {
        if (!p.num)
            continue;
        rows.push({ num: p.num, label: p.label ?? '', note: p.note ?? '', wa: !!p.wa, region: phoneRegion(p.num), primary: false });
    }
    return rows;
}
function phoneRegion(raw) {
    const s = (raw || '').replace(/[^\d+]/g, '');
    if (!s)
        return 'il';
    if (/^(\+?972|00972)/.test(s))
        return 'il';
    if (/^\+/.test(s))
        return 'intl';
    if (/^00/.test(s))
        return 'intl';
    const d = s.replace(/\D/g, '');
    if (/^0\d{8,9}$/.test(d))
        return 'il'; // 0 + 9/10 ספרות
    if (/^5\d{8}$/.test(d))
        return 'il'; // נייד ישראלי בלי 0 מוביל
    return 'intl';
}
function personalCalEntries(sp) {
    const out = supDonEvents(sp).map((e) => ({ date: e.date, amount: e.amount, cur: e.cur, src: e.src }));
    if (sp.nextDate)
        out.push({ date: sp.nextDate, amount: 0, cur: '', src: '🎯 תאריך יעד לקשר הבא' });
    for (const l of sp.ayin?.log ?? []) {
        out.push({ date: l.date, amount: 0, cur: '', src: '🧿 ' + l.eyes + (l.name ? ' — ' + l.name : '') });
    }
    for (const an of sp.ayin?.answers ?? [])
        out.push({ date: an.date, amount: 0, cur: '', src: '📞 תשובה: ' + an.note });
    if (sp.ayin?.nextTalk)
        out.push({ date: sp.ayin.nextTalk, amount: 0, cur: '', src: '🔁 לדבר שוב' });
    return out.filter((e) => !!e.date);
}
function donorSignals(sp, todayIso, rate = 3.7) {
    const ev = events(sp, rate);
    if (ev.length === 0)
        return [];
    const id = sp.id, name = sp.name || 'ללא שם';
    const total = ev.reduce((a, e) => a + e.ils, 0);
    const last = ev[ev.length - 1];
    const sinceLast = dayDiff(last.date, todayIso);
    const out = [];
    // תורם-חדש — מתנה יחידה וטרייה (לטיפוח).
    if (ev.length === 1 && sinceLast <= SIGNAL.RECENT_DAYS) {
        out.push({ id, name, kind: 'firstgift', detail: 'תורם חדש · מתנה ראשונה', magnitude: 40, ils: total });
    }
    if (ev.length >= 2) {
        const prev = ev.slice(0, -1);
        const prevAvg = prev.reduce((a, e) => a + e.ils, 0) / prev.length;
        const gapBeforeLast = dayDiff(prev[prev.length - 1].date, last.date);
        // חזרה-אחרי-נטישה — פער גדול לפני המתנה-האחרונה, והיא טרייה.
        if (gapBeforeLast >= SIGNAL.GAP_DAYS && sinceLast <= SIGNAL.RECENT_DAYS) {
            out.push({ id, name, kind: 'reactivated', detail: 'חזר לתת אחרי ' + Math.round(gapBeforeLast / 30) + ' חודשי-שקט', magnitude: 70, ils: total });
        }
        // נפילת-מתנה — האחרונה קטנה משמעותית מהממוצע (רק על ותק ≥3, לצמצום-רעש).
        if (ev.length >= 3 && prevAvg > 0 && last.ils < prevAvg * SIGNAL.DROP_RATIO) {
            const pct = Math.round((1 - last.ils / prevAvg) * 100);
            out.push({ id, name, kind: 'drop', detail: 'מתנה אחרונה נמוכה ב-' + pct + '% מהרגיל', magnitude: 55 + Math.min(30, pct / 2), ils: total });
        }
        // קפיצה — האחרונה גדולה משמעותית (הזדמנות).
        if (prevAvg > 0 && last.ils > prevAvg * SIGNAL.JUMP_RATIO) {
            const mult = (last.ils / prevAvg).toFixed(1);
            out.push({ id, name, kind: 'jump', detail: 'מתנה אחרונה פי-' + mult + ' מהרגיל', magnitude: 50, ils: total });
        }
        // גולש — תורם-ותיק ששקט הרבה (לא מתנה-בודדת ולא חדש).
        if (sinceLast >= SIGNAL.LAPSING_DAYS) {
            out.push({ id, name, kind: 'lapsing', detail: 'שקט ' + Math.round(sinceLast / 30) + ' חודשים', magnitude: 45 + Math.min(35, sinceLast / 30), ils: total });
        }
    }
    return out;
}
function events(sp, rate) {
    const out = [];
    const push = (date, amount, cur) => {
        if (!date)
            return;
        out.push({ date: date.slice(0, 10), ils: (cur || '₪') === '$' ? amount * rate : amount });
    };
    const dons = sp.donations;
    for (let i = 0; i < dons.length; i++)
        push(dons[i].date, dons[i].amount, dons[i].cur);
    const hist = sp.hist;
    if (hist)
        for (let i = 0; i < hist.length; i++)
            push(hist[i].d, hist[i].a, hist[i].c);
    out.sort((a, b) => (a.date < b.date ? -1 : a.date > b.date ? 1 : 0));
    return out;
}
const SIGNAL = {
    RECENT_DAYS: 90, // "טרי" = מתנה ב-90 יום
    GAP_DAYS: 365, // "חזרה" = פער ≥ שנה ואז מתנה טרייה
    DROP_RATIO: 0.5, // מתנה < 50% מהממוצע-הקודם
    JUMP_RATIO: 2, // מתנה > פי-2 מהממוצע-הקודם
    LAPSING_DAYS: 240, // תורם-ותיק ששקט מעל 240 יום
};
function supLastInPeriod(sp, year, month) {
    if (year == null && month == null)
        return true;
    const iso = supLast(sp);
    if (!iso)
        return false;
    if (year != null && +iso.slice(0, 4) !== year)
        return false;
    if (month != null && +iso.slice(5, 7) !== month)
        return false;
    return true;
}
function supHasRegion(sp, region) {
    return allSupPhones(sp).some((r) => r.region === region);
}
export function supportersListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        cockpitKpis: (() => { try {
            return cockpitKpis(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        cockpitQueue: (() => { try {
            return cockpitQueue(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        seasonality: (() => { try {
            return seasonality(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        cockpitHokTasks: (() => { try {
            return cockpitHokTasks(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        visibleSupportersForDesignations: (() => { try {
            return visibleSupportersForDesignations(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        supScoreBins: (() => { try {
            return supScoreBins(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        orgCalEntries: (() => { try {
            return orgCalEntries(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        hokDue: (() => { try {
            return hokDue(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        tierTrendCounts: (() => { try {
            return tierTrendCounts(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        segmentCounts: (() => { try {
            return segmentCounts(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        atRiskIdSet: (() => { try {
            return atRiskIdSet(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        cockpitCollectedThisMonth: (() => { try {
            return cockpitCollectedThisMonth(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        sup12m: (() => { try {
            return sup12m(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        hokMonthlyTotal: (() => { try {
            return hokMonthlyTotal(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        hokMonthlyTotal: (() => { try {
            return hokMonthlyTotal(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        supAvgDon: (() => { try {
            return supAvgDon(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it, donorScan: (() => { try {
                return donorScan(it);
            }
            catch {
                return null;
            } })(), mergeSupporterRow: (() => { try {
                return mergeSupporterRow(it);
            }
            catch {
                return null;
            } })(), tierAsOf: (() => { try {
                return tierAsOf(it);
            }
            catch {
                return null;
            } })(), supLast: (() => { try {
                return supLast(it);
            }
            catch {
                return null;
            } })(), totalLabel: (() => { try {
                return totalLabel(it);
            }
            catch {
                return null;
            } })(), applyAyinNames: (() => { try {
                return applyAyinNames(it);
            }
            catch {
                return null;
            } })(), allSupPhones: (() => { try {
                return allSupPhones(it);
            }
            catch {
                return null;
            } })(), supDonEvents: (() => { try {
                return supDonEvents(it);
            }
            catch {
                return null;
            } })(), personalCalEntries: (() => { try {
                return personalCalEntries(it);
            }
            catch {
                return null;
            } })(), donorSignals: (() => { try {
                return donorSignals(it);
            }
            catch {
                return null;
            } })(), supLastInPeriod: (() => { try {
                return supLastInPeriod(it);
            }
            catch {
                return null;
            } })(), supHasRegion: (() => { try {
                return supHasRegion(it);
            }
            catch {
                return null;
            } })(), hokEffectivelyActive: (() => { try {
                return hokEffectivelyActive(it);
            }
            catch {
                return null;
            } })(), hokRecordedThisMonth: (() => { try {
                return hokRecordedThisMonth(it);
            }
            catch {
                return null;
            } })(), supIls: (() => { try {
                return supIls(it);
            }
            catch {
                return null;
            } })(), supUsd: (() => { try {
                return supUsd(it);
            }
            catch {
                return null;
            } })(), supCount: (() => { try {
                return supCount(it);
            }
            catch {
                return null;
            } })(), supTotalIls: (() => { try {
                return supTotalIls(it);
            }
            catch {
                return null;
            } })(), supScore: (() => { try {
                return supScore(it);
            }
            catch {
                return null;
            } })() })) : undefined,
    };
}
export { cockpitKpis, cockpitQueue, seasonality, cockpitHokTasks, visibleSupportersForDesignations, supScoreBins, orgCalEntries, hokDue, tierTrendCounts, segmentCounts, atRiskIdSet, cockpitCollectedThisMonth, sup12m, hokMonthlyTotal, supAvgDon, donorScan, mergeSupporterRow, tierAsOf, supLast, totalLabel, applyAyinNames, allSupPhones, supDonEvents, personalCalEntries, donorSignals, supLastInPeriod, supHasRegion, hokEffectivelyActive, hokRecordedThisMonth, supIls, supUsd, supCount, supTotalIls, supScore };
