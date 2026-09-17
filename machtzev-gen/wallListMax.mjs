function buildPodium(db, monthKey, yearKey, config) {
    const T = (key, fb) => (config ? termOf(config, key, fb) : fb);
    const dons = allIlsDonations(db);
    const agg = (filter) => {
        const m = new Map();
        for (const d of dons) {
            if (!filter(d))
                continue;
            const cur = m.get(d.supporterId) ?? { id: d.supporterId, name: d.name, amount: 0, count: 0 };
            cur.amount += d.amount;
            cur.count++;
            m.set(d.supporterId, cur);
        }
        return [...m.values()].filter((x) => x.amount > 0);
    };
    let rows = agg((d) => d.date.startsWith(monthKey));
    let scopeLabel = 'החודש';
    if (!rows.length) {
        rows = agg((d) => d.date.startsWith(yearKey));
        scopeLabel = 'השנה';
    }
    if (!rows.length) {
        rows = db.supporters
            .filter((s) => s.ils > 0)
            // amount=s.ils הוא סכום השקלים בלבד; count חייב לספור תרומות-שקל בלבד (לא
            // סה"כ כל המטבעות) כדי שהתווית 'N תרומות' תתאים לסכום המוצג.
            .map((s) => ({ id: s.id, name: s.name, amount: s.ils, count: s.donations.filter((d) => d.cur !== '$').length }));
        scopeLabel = 'מאז ומעולם';
    }
    rows.sort((a, b) => b.amount - a.amount);
    const top = rows.slice(0, 3).map((r) => ({
        name: r.name,
        supporterId: r.id,
        sub: r.count === 1 ? `${T('entity.donation', 'תרומה')} אחת` : `${r.count} ${T('entity.donations', 'תרומות')}`,
        amount: r.amount,
    }));
    const rest = rows.slice(3);
    return {
        rows: top,
        othersCount: rest.length,
        othersAmount: rest.reduce((s, r) => s + r.amount, 0),
        scopeLabel,
    };
}
function allIlsDonations(db) {
    const out = [];
    for (const s of db.supporters) {
        for (const d of s.donations) {
            if (d.cur === '$')
                continue; // $ = דולר; כל השאר (₪/ריק/מיובא) = שקל — עקבי עם הבית והצבירה
            // ציד-באגים 3.8.2026 (🟡): גיבוי מושחת עם amount=null/NaN הפך את raisedThisYear
            // וטבעת-היעד ל-NaN ושבר את כל הקיר. שמירה על finite (עקבי עם supporterAggregates).
            out.push({ name: s.name, supporterId: s.id, date: d.date, amount: Number.isFinite(d.amount) ? d.amount : 0 });
        }
    }
    return out;
}
function birthdaysToday(db, todayIso) {
    const hp = hpOf(todayIso);
    const out = [];
    for (const f of db.families) {
        for (const m of f.members) {
            if (!m.birth || todayIso <= m.birth)
                continue;
            const bh = hpOf(m.birth);
            // נרמול אדר משותף — יום-הולדת עברי ב"אדר" מופיע בקיר גם בשנה מעוברת (אדר ב׳)
            if (hebAnnualEq(bh, hp))
                out.push({ first: m.first, age: hp.year - bh.year });
        }
    }
    return out;
}
function buildWeek(db, now, config) {
    const T = (key, fb) => (config ? termOf(config, key, fb) : fb);
    const course = T('entity.course', 'חוג');
    const courses = T('nav.courses', 'חוגים');
    const out = [];
    for (let i = 0; i < 7 && out.length < 7; i++) {
        const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
        const iso = isoOf(d);
        const hp = hpOf(iso, d);
        const hd = `${gem(hp.day)} ${fmtHebMonth.format(d)}`;
        const hol = holidayOf(d);
        if (hol) {
            out.push({
                key: iso + '-hol',
                hd,
                title: hol,
                sub: 'חג ומועד בלוח העברי',
                emoji: holidayEmoji(hol),
            });
        }
        for (const ev of db.events) {
            if (out.length >= 7)
                break;
            if (ev.done || !eventOccursOn(ev, iso, hp))
                continue;
            const fam = ev.famId ? db.families.find((f) => f.id === ev.famId) : undefined;
            out.push({
                key: iso + '-ev-' + ev.id,
                hd,
                title: ev.title,
                sub: [evLabel(ev), ev.time, fam && T('entity.familyOf', 'משפחת') + ' ' + fam.name].filter(Boolean).join(' · '),
                emoji: EV_EMOJI[ev.type],
            });
        }
        if (out.length >= 7)
            continue;
        // ציד-באגים 3.8.2026 (🟡): מפגשי-חוגים הוסתרו בכל יום עם *כל* חג — כולל חגים
        // קלים (חנוכה/פורים/ל"ג בעומר/חוה"מ) שבהם החוגים רצים כרגיל. עקבי עם הלוח
        // ויומן-החדרים: רק חג-מלא/שבת/ערב-שבת חוסמים חוג (blockReason 'course').
        if (blockReason(d, 'course'))
            continue;
        const dow = d.getDay();
        const names = [];
        let n = 0;
        for (const c of db.courses) {
            if (c.start && iso < c.start)
                continue;
            if (c.end && iso > c.end)
                continue;
            const k = sessionsOf(c).filter((ss) => ss.day === dow).length;
            if (k > 0) {
                n += k;
                names.push(c.name);
            }
        }
        if (n > 0) {
            out.push({
                key: iso + '-crs',
                hd,
                title: (i === 0 ? 'היום · ' : '') + (n === 1 ? `מפגש ${course} אחד` : `${n} מפגשי ${courses}`),
                sub: names.slice(0, 3).join(' · '),
                emoji: i === 0 ? '☀️' : '🎨',
            });
        }
    }
    return out;
}
const fmtHebMonth = new Intl.DateTimeFormat('he-u-ca-hebrew', { month: 'long' });
function holidayEmoji(name) {
    // ימי-צום (כולל תענית אסתר/צום גדליה) מקבלים 📿; שאר החגים 🎉
    return name.includes('צום') || name.includes('תענית') || name === 'תשעה באב' || name === 'יום כיפור' ? '📿' : '🎉';
}
const EV_EMOJI = {
    org: '🎉',
    reminder: '⏰',
    call: '📞',
    wedding: '💍',
    memorial: '🕯️',
    anniversary: '💍',
    bday: '🎂',
    custom: '📌',
};
export function wallListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        buildPodium: (() => { try {
            return buildPodium(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        birthdaysToday: (() => { try {
            return birthdaysToday(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        buildWeek: (() => { try {
            return buildWeek(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { buildPodium, birthdaysToday, buildWeek };
