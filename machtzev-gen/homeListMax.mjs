function homeStats(db, now) {
    const todayIso = isoOf(now);
    const members = allMembers(db);
    const weekIds = new Set();
    let eventsToday = 0;
    for (let i = 0; i < 7; i++) {
        const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
        const evs = eventsOnDate(db, d);
        if (i === 0)
            eventsToday = evs.length;
        for (const ev of evs)
            weekIds.add(ev.id);
    }
    // הכרעת-בעלים 9.8 (#14 "לכולל"): הצבירה המוצגת = קבלות+היסטוריה דרך supIls/supUsd —
    // אותו מקור-אמת כמו מסך התורמים (הבית הראה עד כה קבלות-בלבד ⇒ מספר שונה מהרשימה).
    let donIls = 0;
    let donUsd = 0;
    for (const sp of db.supporters) {
        donIls += supIls(sp);
        donUsd += supUsd(sp);
    }
    return {
        famTotal: db.families.length,
        famActive: db.families.filter((f) => f.status === 'active').length,
        famPending: db.families.filter((f) => f.status === 'pending').length,
        famInactive: db.families.filter((f) => f.status === 'inactive').length,
        membersTotal: members.length,
        childrenTotal: members.filter((m) => !m.isParent).length,
        activeCourses: db.courses.filter((c) => courseActiveOn(c, todayIso)).length,
        coursesTotal: db.courses.length,
        activeEnrollments: db.enrollments.filter((e) => e.status === 'active').length,
        enrollTotal: db.enrollments.length,
        eventsToday,
        eventsWeek: weekIds.size,
        donIls,
        donUsd,
        supportersTotal: db.supporters.length,
        widows: db.families.filter((f) => (f.maritalStatus || '').includes('אלמן')).length,
    };
}
function isoOf(d) {
    return isoLocal(d);
}
function eventsOnDate(db, d) {
    const iso = isoOf(d);
    const hp = hebParts(d);
    const out = [];
    for (const ev of db.events) {
        if (ev.done || !ev.date)
            continue;
        let hit = ev.date === iso;
        if (!hit && HEBREW_RECURRING.has(ev.type) && iso > ev.date) {
            hit = hebAnnualEq(hebPartsOfIso(ev.date), hp);
        }
        if (hit)
            out.push(ev);
    }
    // אירוע בלי שעה יורד לסוף היום ('99:99') — כמו במפגשים
    return out.sort((a, b) => (a.time || '99:99').localeCompare(b.time || '99:99'));
}
function courseActiveOn(c, iso) {
    return (!c.start || iso >= c.start) && (!c.end || iso <= c.end);
}
function credSummary(db, tierKeyOf) {
    const counts = { titan: 0, lion: 0, pale: 0, red: 0 };
    let sum = 0;
    for (const f of db.families) {
        const score = f.cred?.score ?? 700;
        sum += score;
        counts[tierKeyOf(score)]++;
    }
    const total = db.families.length;
    return { avg: total > 0 ? Math.round(sum / total) : 0, counts, total };
}
function courseMetrics(db) {
    const rows = courseOccupancies(db);
    const avgOcc = Math.round(rows.reduce((a, r) => a + r.pct, 0) / Math.max(1, rows.length));
    return {
        rows,
        avgOcc,
        students: db.enrollments.length,
        income: weightedMonthlyIncome(db),
        fullCount: rows.filter((r) => r.pct >= 100).length,
        punchCount: rows.filter((r) => r.course.model === 'punch').length,
        monthlyCount: rows.filter((r) => r.course.model === 'monthly').length,
        top: rows.slice().sort((a, b) => b.pct - a.pct).slice(0, 3),
    };
}
function courseOccupancies(db) {
    return db.courses.map((c) => {
        const n = db.enrollments.filter((e) => e.courseId === c.id).length;
        const max = c.maxStudents || 12;
        return { course: c, n, max, pct: Math.min(100, Math.round((n / max) * 100)) };
    });
}
function weightedMonthlyIncome(db) {
    let sum = 0;
    for (const e of db.enrollments) {
        if ((e.status || 'active') !== 'active')
            continue;
        const c = db.courses.find((x) => x.id === e.courseId);
        if (!c)
            continue;
        const p = c.price || 0;
        sum += c.model === 'monthly' ? p : c.model === 'half_year' ? p / 6 : c.model === 'year' ? p / 12 : 0;
    }
    return sum;
}
function morningBrief(db, config, todayIso, now, usdRate) {
    const rate = usdRate || 3.7;
    const sections = [];
    // תורי-הקוקפיט — שיחות/תודות/הו"ק (אותו מנוע, אותם ספים)
    const q = cockpitQueue(db.supporters, todayIso, rate);
    if (q.calls.length)
        sections.push({ key: 'calls', icon: '📞', title: 'שיחות להיום', count: q.calls.length, top: names(q.calls), view: 'supporters' });
    if (q.thanks.length)
        sections.push({ key: 'thanks', icon: '💛', title: 'תודות לומר', count: q.thanks.length, top: names(q.thanks), view: 'supporters' });
    if (q.hok.length)
        sections.push({ key: 'hok', icon: '🔁', title: 'הו"ק שטרם נרשמו החודש', count: q.hok.length, top: names(q.hok), view: 'supporters' });
    // 🕎 העונה-העברית — רק כשהדגל שלה דלוק (אותו opt-in של הקוקפיט)
    if (config.features?.['supporters.hebtiming'] === true) {
        const heb = hebTimingTasks(db.supporters, todayIso);
        if (heb.length) {
            const season = hebSeasonOf(todayIso);
            sections.push({ key: 'season', icon: '🕎', title: 'העונה שלהם — ' + season.monthHe, count: heb.length, top: names(heb), view: 'supporters' });
        }
    }
    // 🎨 חוגי-היום (מנוע-הבית הקיים)
    const sessions = todaySessions(db, now);
    if (sessions.length) {
        sections.push({
            key: 'sessions', icon: '🎨', title: 'מפגשים היום', count: sessions.length,
            top: sessions.slice(0, TOP).map((s) => s.course.name + (s.session?.time ? ' · ' + s.session.time : '')),
            view: 'courses',
        });
    }
    // 📅 אירועי-היום מהלוח
    const events = db.events.filter((e) => e.date === todayIso);
    if (events.length) {
        sections.push({
            key: 'events', icon: '📅', title: 'אירועים היום', count: events.length,
            top: events.slice(0, TOP).map((e) => e.title + (e.time ? ' · ' + e.time : '')),
            view: 'calendar',
        });
    }
    return { sections, empty: sections.length === 0 };
}
const names = (xs) => xs.slice(0, TOP).map((t) => t.name + (t.reason ? ' — ' + t.reason : ''));
const TOP = 3;
function todaySessions(db, now) {
    const iso = isoOf(now);
    const dow = now.getDay();
    const out = [];
    for (const c of db.courses) {
        if (!courseActiveOn(c, iso))
            continue;
        const all = sessionsOf(c);
        all.forEach((ss, gi) => {
            if (ss.day === dow)
                out.push({ course: c, session: ss, gi, groups: all.length });
        });
    }
    // מפגש בלי שעה יורד לסוף היום ('99:99') — לא צף מעל המפגשים המתוזמנים
    return out.sort((a, b) => (a.session.time || '99:99').localeCompare(b.session.time || '99:99'));
}
function birthdaysOn(db, d) {
    const iso = isoOf(d);
    const hp = hebParts(d);
    const out = [];
    for (const m of allMembers(db)) {
        if (!m.birth || iso <= m.birth)
            continue;
        const bh = hebPartsOfIso(m.birth);
        if (!hebAnnualEq(bh, hp))
            continue;
        out.push({ member: m, age: hp.year - bh.year });
    }
    return out;
}
function recentFamilies(db, n = 5) {
    return db.families
        .slice()
        .sort((a, b) => String(b.createdAt || '').localeCompare(String(a.createdAt || '')))
        .slice(0, n);
}
function credHistogram(db) {
    const bins = Array.from({ length: 20 }, () => 0);
    for (const f of db.families) {
        const score = f.cred?.score ?? 700;
        bins[Math.min(19, Math.floor(score / 50))]++;
    }
    return bins;
}
function credNeedsBoost(db, n = 3) {
    return db.families
        .map((f) => ({ family: f, score: f.cred?.score ?? 700 }))
        .sort((a, b) => a.score - b.score)
        .slice(0, n);
}
function dueContacts(db, now) {
    const todayIso = isoOf(now);
    return db.supporters
        .filter((sp) => sp.nextDate && sp.nextDate <= todayIso)
        .map((sp) => ({
        id: sp.id,
        name: sp.name,
        date: sp.nextDate,
        phone: sp.phone,
        late: Math.max(0, daysBetween(sp.nextDate, todayIso)),
    }))
        .sort((a, b) => b.late - a.late);
}
function daysBetween(fromIso, toIso) {
    const [y1, m1, d1] = fromIso.split('-').map(Number);
    const [y2, m2, d2] = toIso.split('-').map(Number);
    return Math.round((new Date(y2, m2 - 1, d2).getTime() - new Date(y1, m1 - 1, d1).getTime()) / 86400000);
}
function punchLow(db, maxLeft = 2) {
    const members = allMembers(db);
    return db.enrollments
        .filter((e) => e.plan === 'punch' && e.status === 'active' && e.purchased > 0 && e.purchased - e.used <= maxLeft)
        .map((e) => {
        const m = members.find((x) => x.id === e.memberId);
        return {
            key: e.id,
            member: m?.first ?? '',
            famName: m?.famName ?? '',
            course: db.courses.find((c) => c.id === e.courseId)?.name ?? '',
            left: Math.max(0, e.purchased - e.used),
            total: e.purchased,
            // נפילה הגיונית (20.8): שיבוץ-יתום בלי בן-משפחה — לחוג, לא ללוח-השנה
            nav: (m ? { kind: 'family', id: m.famId } : { kind: 'course', id: e.courseId }),
        };
    })
        .sort((a, b) => a.left - b.left);
}
function monthDonationSum(db, now) {
    const key = monthKeyOf(now, 0);
    let sum = 0;
    for (const sp of db.supporters) {
        for (const dn of sp.donations)
            if (dn.cur !== '$' && (dn.date || '').startsWith(key))
                sum += dn.amount;
        for (const h of sp.hist ?? [])
            if (h.c !== '$' && (h.d || '').startsWith(key))
                sum += h.a;
    }
    return sum;
}
function monthKeyOf(anchor, delta) {
    const d = new Date(anchor.getFullYear(), anchor.getMonth() + delta, 1);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
}
function credTodayTrend(db, todayIso) {
    let sum = 0;
    for (const f of db.families) {
        for (const e of f.cred?.log ?? [])
            if (e.date === todayIso)
                sum += e.delta;
    }
    return sum;
}
export function homeListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        homeStats: (() => { try {
            return homeStats(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        credSummary: (() => { try {
            return credSummary(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        courseMetrics: (() => { try {
            return courseMetrics(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        morningBrief: (() => { try {
            return morningBrief(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        todaySessions: (() => { try {
            return todaySessions(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        eventsOnDate: (() => { try {
            return eventsOnDate(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        birthdaysOn: (() => { try {
            return birthdaysOn(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        recentFamilies: (() => { try {
            return recentFamilies(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        courseOccupancies: (() => { try {
            return courseOccupancies(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        credHistogram: (() => { try {
            return credHistogram(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        credNeedsBoost: (() => { try {
            return credNeedsBoost(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        dueContacts: (() => { try {
            return dueContacts(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        punchLow: (() => { try {
            return punchLow(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        monthDonationSum: (() => { try {
            return monthDonationSum(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        weightedMonthlyIncome: (() => { try {
            return weightedMonthlyIncome(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        credTodayTrend: (() => { try {
            return credTodayTrend(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { homeStats, credSummary, courseMetrics, morningBrief, todaySessions, eventsOnDate, birthdaysOn, recentFamilies, courseOccupancies, credHistogram, credNeedsBoost, dueContacts, punchLow, monthDonationSum, weightedMonthlyIncome, credTodayTrend };
