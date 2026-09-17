function buildGregorianGrid(db, year, month, config = DEFAULT_CONFIG) {
    const first = new Date(year, month, 1);
    const gridStart = new Date(year, month, 1 - first.getDay());
    const todayIso = isoOf(new Date());
    const cells = [];
    for (let i = 0; i < 42; i++) {
        const d = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
        cells.push(makeCell(db, d, d.getMonth() === month, todayIso, false, config));
    }
    const last = new Date(year, month + 1, 0);
    const m1 = fmtHebMonth.format(first);
    const m2 = fmtHebMonth.format(last);
    return {
        cells,
        monthLabel: fmtMonthYear.format(first),
        hebLabel: (m1 === m2 ? m1 : m1 + '–' + m2) + ' ' + gemYear(fmtHebYear.format(last)),
        prevIso: null,
        nextIso: null,
    };
}
function isoOf(d) {
    return isoLocal(d);
}
function makeCell(db, d, inMonth, todayIso, hebMode, config = DEFAULT_CONFIG) {
    const iso = isoOf(d);
    const hp = hpOf(iso, d);
    return {
        iso,
        date: d,
        dayNum: hebMode ? `${d.getDate()}.${d.getMonth() + 1}` : String(d.getDate()),
        hebDay: hebMode ? gem(hp.day) : gem(hp.day) + (hp.day === 1 ? ' ' + fmtHebMonth.format(d) : ''),
        inMonth,
        isToday: iso === todayIso,
        holiday: holidayOf(d),
        items: dayItems(db, d, config),
    };
}
const fmtHebMonth = new Intl.DateTimeFormat('he-u-ca-hebrew', { month: 'long' });
const fmtMonthYear = new Intl.DateTimeFormat('he', { month: 'long', year: 'numeric' });
const fmtHebYear = new Intl.DateTimeFormat('he-u-ca-hebrew', { year: 'numeric' });
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
function dayItems(db, d, config = DEFAULT_CONFIG) {
    const iso = isoOf(d);
    const hp = hpOf(iso, d);
    const courseBlock = blockReason(d, 'course');
    const famOf = termOf(config, 'entity.familyOf', 'משפחת');
    const courseWord = termOf(config, 'entity.course', 'חוג');
    const out = [];
    for (const ev of db.events) {
        // אירוע שסומן "בוצע" מוצג רק בתאריכו המקורי (מחוק-קו) ואינו חוזר שנתית.
        const hit = ev.done ? ev.date === iso : eventOccursOn(ev, iso, hp);
        if (!hit)
            continue;
        out.push({
            key: 'ev-' + ev.id,
            label: (ev.time ? ev.time + ' · ' : '') + ev.title,
            title: ev.title + (ev.done ? ' · בוצע ✓' : ''),
            bg: EV_META[ev.type].bg,
            c: EV_META[ev.type].c,
            typeLabel: evLabel(ev),
            sort: ev.priority === 'red' ? 0.5 : 1,
            prC: PRIORITY_COLOR[ev.priority] ?? 'transparent',
            // שורת משנה (P3 פריט 6) — הערות האירוע, כמו בלגאסי
            sub: ev.notes || '',
            ev,
        });
    }
    // ימי הולדת של בני משפחה — חזרה שנתית לפי היום והחודש העבריים של תאריך הלידה
    // (אותה לוגיקת hebParts כמו אזכרות), עם הגיל בשנים עבריות.
    for (const f of db.families) {
        for (const m of f.members) {
            if (!m.birth || iso <= m.birth)
                continue;
            const bh = hpOf(m.birth);
            if (!hebAnnualEq(bh, hp))
                continue; // נרמול אדר — יום-הולדת עברי לא נעלם בשנה מעוברת
            const age = hp.year - bh.year;
            out.push({
                key: 'bd-' + m.id,
                label: `🎂 יום הולדת — ${m.first} (${age})`,
                title: `🎂 יום הולדת — ${m.first} (${age}) · ${famOf} ${f.name}`,
                bg: EV_META.bday.bg,
                c: EV_META.bday.c,
                typeLabel: 'יום הולדת',
                sort: 2,
                prC: 'transparent',
                famId: f.id,
                layer: 'bday',
            });
        }
    }
    // ימי שנה להצטרפות משפחה — לפי createdAt (חודש-יום לועזי, מהשנה שאחרי ההצטרפות).
    for (const f of db.families) {
        if (!f.createdAt || iso <= f.createdAt || iso.slice(5) !== f.createdAt.slice(5))
            continue;
        const n = +iso.slice(0, 4) - +f.createdAt.slice(0, 4);
        out.push({
            key: 'join-' + f.id,
            label: `🏠 ${n} שנים ל${famOf} ${f.name}`,
            title: `🏠 ${n} שנים ל${famOf} ${f.name} במערכת`,
            bg: '#e7edf5',
            c: '#3a5a86',
            typeLabel: 'הצטרפות',
            sort: 2.4,
            prC: 'transparent',
            famId: f.id,
            layer: 'join',
        });
    }
    // הרשמות לחוגים — ביום הרישום (enrolledAt).
    for (const e of db.enrollments) {
        if (e.enrolledAt !== iso)
            continue;
        let em = null;
        let ef = null;
        for (const f of db.families) {
            const x = f.members.find((mm) => mm.id === e.memberId);
            if (x) {
                em = x;
                ef = f;
                break;
            }
        }
        const ec = db.courses.find((x) => x.id === e.courseId);
        if (!em || !ec)
            continue;
        out.push({
            key: 'enr-' + e.id,
            label: `📝 נרשמ/ה ${em.first} — ${ec.name}`,
            title: `📝 הרשמה ל${courseWord}: ${em.first}` + (ef ? ` (${famOf} ${ef.name})` : '') + ` ← ${ec.name}`,
            bg: '#eef7e6',
            c: '#3f6212',
            typeLabel: 'הרשמה ל' + courseWord,
            sort: 2.6,
            prC: 'transparent',
            courseId: ec.id,
            layer: 'enroll',
        });
    }
    const dow = d.getDay();
    for (const c of db.courses) {
        if (c.start && iso < c.start)
            continue;
        if (c.end && iso > c.end)
            continue;
        for (const [i, ss] of sessionsOf(c).entries()) {
            if (ss.day !== dow)
                continue;
            // שורת משנה (P3 פריט 6, לגאסי dayV): מורה · חדר · N רשומים
            const tName = db.teachers.find((t) => t.id === c.teacherId)?.name;
            const rName = db.rooms.find((r) => r.id === c.roomId)?.name;
            const nEnrolled = db.enrollments.filter((e) => e.courseId === c.id && e.status !== 'ended' && e.status !== 'wait').length;
            out.push({
                key: `crs-${c.id}-${i}-${ss.label || ss.time}`,
                label: (ss.time ? ss.time + ' · ' : '') + c.name + (ss.label ? ' · ' + ss.label : ''),
                title: c.name + (ss.label ? ' — ' + ss.label : '') + (courseBlock ? ' · לא מתקיים — ' + courseBlock : ''),
                bg: SESSION_META.bg,
                c: SESSION_META.c,
                typeLabel: 'מפגש ' + courseWord,
                sort: 3,
                prC: 'transparent',
                sub: [tName, rName, nEnrolled + ' רשומים'].filter(Boolean).join(' · '),
                courseId: c.id,
                skipped: !!courseBlock,
            });
        }
    }
    return out.sort((a, b) => a.sort - b.sort);
}
const hpCache = new Map();
const HP_CACHE_MAX = 3000;
function dateOf(iso) {
    return new Date(iso + 'T12:00:00');
}
function blockReason(d, kind = 'org') {
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
function eventOccursOn(ev, iso, hp) {
    if (!ev.date)
        return false;
    if (ev.date === iso)
        return true;
    if (!HEBREW_RECURRING.has(ev.type) || iso <= ev.date)
        return false;
    // נרמול אדר משותף — כך שאזכרה/נישואים ב"אדר" רגיל חוזרים ב"אדר ב׳" מעוברת,
    // בדיוק כמו בלוח הבית (eventsOnDate). בלי זה האירוע נעלם מהלוח בשנה מעוברת.
    return hebAnnualEq(hpOf(ev.date), hp);
}
const PRIORITY_COLOR = {
    red: '#dc2626',
    orange: '#d97706',
    green: '#16a34a',
};
const SESSION_META = { label: 'מפגש קורס', bg: '#fdf1d4', c: '#9a6414' };
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
function buildHebrewGrid(db, anchorIso, config = DEFAULT_CONFIG) {
    const anchor = dateOf(anchorIso);
    const hp0 = hpOf(anchorIso, anchor);
    // א׳ בחודש: הליכה אחורה לפי היום העברי של העוגן.
    const first = new Date(anchor);
    first.setDate(first.getDate() - (hp0.day - 1));
    // אורך החודש: בדיקה האם יום 30 עדיין באותו חודש עברי.
    const d30 = new Date(first);
    d30.setDate(d30.getDate() + 29);
    const dim = hpOf(isoOf(d30), d30).month === hp0.month ? 30 : 29;
    const hmStart = isoOf(first);
    const lastH = new Date(first);
    lastH.setDate(lastH.getDate() + dim - 1);
    const hmEnd = isoOf(lastH);
    const gridStart = new Date(first);
    gridStart.setDate(gridStart.getDate() - first.getDay());
    const count = Math.ceil((first.getDay() + dim) / 7) * 7;
    const todayIso = isoOf(new Date());
    const cells = [];
    for (let i = 0; i < count; i++) {
        const d = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
        const iso = isoOf(d);
        cells.push(makeCell(db, d, iso >= hmStart && iso <= hmEnd, todayIso, true, config));
    }
    const prevD = new Date(first);
    prevD.setDate(prevD.getDate() - 1);
    const nextD = new Date(first);
    nextD.setDate(nextD.getDate() + dim);
    return {
        cells,
        monthLabel: fmtD(hmStart) + ' – ' + fmtD(hmEnd),
        hebLabel: fmtHebMonth.format(first) + ' ' + gemYear(fmtHebYear.format(first)),
        prevIso: isoOf(prevD),
        nextIso: isoOf(nextD),
    };
}
function fmtD(iso) {
    if (!iso)
        return '—';
    const [y, m, d] = iso.split('-');
    if (!y || !m || !d)
        return '—';
    return `${d}/${m}/${y}`;
}
function icsWindowEvents(db, fromIso, days, slug, config) {
    const rooms = new Map(db.rooms.map((r) => [r.id, r.name]));
    const wantBdays = !!config && featureOn(config, 'calendar.ics.bdays');
    const wantSessions = !!config && featureOn(config, 'calendar.ics.sessions') && moduleActive(config);
    const famWord = config ? termOf(config, 'entity.familyOf', 'משפחת') : 'משפחת';
    const from = new Date(fromIso + 'T12:00:00');
    const out = [];
    for (let i = 0; i < days; i++) {
        const d = new Date(from.getFullYear(), from.getMonth(), from.getDate() + i);
        const iso = isoOf(d);
        const hp = hpOf(iso, d);
        for (const ev of db.events) {
            if (!eventOccursOn(ev, iso, hp))
                continue;
            if (ev.done && iso !== ev.date)
                continue; // 'בוצע' — רק במקור, כמו בלוח
            out.push({
                uid: ev.id + '-' + iso + '@' + slug,
                title: ev.title,
                date: iso,
                time: ev.time || '',
                notes: ev.notes || undefined,
                location: (ev.roomId && rooms.get(ev.roomId)) || undefined,
            });
        }
        if (wantBdays) {
            // אותה לוגיקה עברית כמו בלוח הבית (dayItems) — כולל דין אדר
            for (const f of db.families) {
                for (const m of f.members) {
                    if (!m.birth || iso <= m.birth)
                        continue;
                    if (!hebAnnualEq(hpOf(m.birth), hp))
                        continue;
                    out.push({
                        uid: 'bday-' + m.id + '-' + iso + '@' + slug,
                        title: '🎂 יום הולדת — ' + m.first + ' · ' + famWord + ' ' + f.name,
                        date: iso,
                        time: '',
                    });
                }
            }
        }
        if (wantSessions) {
            const dow = d.getDay();
            const courseBlock = blockReason(d, 'course');
            if (!courseBlock) {
                for (const c of db.courses) {
                    if (c.start && iso < c.start)
                        continue;
                    if (c.end && iso > c.end)
                        continue;
                    for (const [si, ss] of sessionsOf(c).entries()) {
                        if (ss.day !== dow)
                            continue;
                        out.push({
                            uid: 'crs-' + c.id + '-' + si + '-' + iso + '@' + slug,
                            title: c.name + (ss.label ? ' — ' + ss.label : ''),
                            date: iso,
                            time: ss.time || '',
                            location: rooms.get(c.roomId) || undefined,
                        });
                    }
                }
            }
        }
    }
    return out;
}
function moduleActive(config) {
    return config.modules.courses !== false;
}
function upcomingItems(db, now, days = 30, config = DEFAULT_CONFIG) {
    const out = [];
    for (let i = 0; i < days; i++) {
        const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
        const iso = isoOf(d);
        const items = dayItems(db, d, config).filter((it) => !it.courseId && !(it.ev && it.ev.done));
        if (!items.length)
            continue;
        const hp = hpOf(iso, d);
        out.push({
            iso,
            dayGem: gem(hp.day),
            monHeb: fmtHebMonth.format(d),
            gLabel: fmtD(iso),
            weekday: 'יום ' + DAY_NAMES[d.getDay()],
            items,
        });
    }
    return out;
}
const DAY_NAMES = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];
export function calendarListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        buildGregorianGrid: (() => { try {
            return buildGregorianGrid(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        buildHebrewGrid: (() => { try {
            return buildHebrewGrid(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        dayItems: (() => { try {
            return dayItems(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        icsWindowEvents: (() => { try {
            return icsWindowEvents(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        upcomingItems: (() => { try {
            return upcomingItems(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { buildGregorianGrid, buildHebrewGrid, dayItems, icsWindowEvents, upcomingItems };
