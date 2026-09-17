function finderAxisValue(db, f, axis, config) {
    const T = (k, fb) => (config ? termOf(config, k, fb) : fb);
    switch (axis) {
        case 'city': return f.city || '';
        case 'comm': return f.community || '';
        case 'marital': return f.maritalStatus || 'לא ידוע';
        case 'status': return STATUS_META[f.status].label;
        case 'cred': return tierOf(f.cred?.score ?? 700).label;
        case 'kids': return f.members.some((m) => !m.isParent) ? 'עם ילדים' : 'בלי ילדים';
        case 'enrolled': return famLiveEnrollments(db, f).length ? 'משתתפות ב' + T('nav.courses', 'חוגים') : 'לא משתתפות';
        case 'sefach': return f.fullSefach ? 'קיים' : 'חסר';
        case 'lang': return f.language || '';
        default: return '';
    }
}
const STATUS_META = {
    active: { label: 'פעילה', bg: '#e4f5ea', c: '#12803c' },
    pending: { label: 'ממתינה', bg: '#fdf1d4', c: '#9a6414' },
    inactive: { label: 'לא פעילה', bg: '#eceae2', c: '#8b8474' },
};
function tierOf(score) {
    if (score >= 950)
        return { key: 'titan', label: 'טיטאן', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' };
    if (score >= 800)
        return { key: 'lion', label: 'לביאה', bg: '#e4f5ea', c: '#12803c', dot: '#16a34a' };
    if (score >= CRED_RED_THRESHOLD)
        return { key: 'pale', label: 'טעון שיפור', bg: '#fdf1d4', c: '#9a6414', dot: '#d97706' };
    return { key: 'red', label: 'סיכון נטישה', bg: '#fdeaea', c: '#b91c1c', dot: '#dc2626' };
}
function famLiveEnrollments(db, fam) {
    return famEnrollments(db, fam).filter((e) => e.status !== 'ended' && e.status !== 'wait');
}
const CRED_RED_THRESHOLD = 500;
function famEnrollments(db, fam) {
    const ids = new Set(fam.members.map((m) => m.id));
    return db.enrollments.filter((e) => ids.has(e.memberId));
}
function finderMatches(db, locks) {
    return db.families.filter((f) => Object.entries(locks).every(([k, v]) => finderAxisValue(db, f, k) === v));
}
function famHistoryOf(db, fam, config = DEFAULT_CONFIG) {
    const out = [];
    const push = (date, tag, bg, c, text) => {
        if (date)
            out.push({ date, tag, bg, c, text });
    };
    if (fam.createdAt)
        push(fam.createdAt, 'הצטרפות', '#e7edf5', '#3a5a86', 'ה' + termOf(config, 'entity.family', 'משפחה') + ' הצטרפה');
    // אירועי הלוח של המשפחה (P3 פריט 9) — נשזרים בציר, כולל סימון ✓ בוצע
    for (const ev of db.events) {
        if (ev.famId !== fam.id || !ev.date)
            continue;
        push(ev.date, 'אירוע', '#efe7f3', '#7c3aed', ev.title + (ev.time ? ' · ' + ev.time : '') + (ev.done ? ' · ✓ בוצע' : ''));
    }
    for (const l of fam.cred?.log ?? []) {
        push(l.date, termOf(config, 'entity.cred', 'אמינות'), '#f6ead1', '#9a6414', l.reason + ' (' + (l.delta > 0 ? '+' : '') + l.delta + ' נק׳)');
    }
    for (const d of fam.docs)
        push(d.addedAt, 'מסמך', '#eceae2', '#4d463c', 'מסמך נוסף: ' + d.name);
    const ids = new Set(fam.members.map((m) => m.id));
    for (const e of db.enrollments) {
        if (!ids.has(e.memberId))
            continue;
        const first = fam.members.find((x) => x.id === e.memberId)?.first ?? '';
        const cname = db.courses.find((x) => x.id === e.courseId)?.name ?? '';
        push(e.enrolledAt, termOf(config, 'entity.enrollment', 'שיבוץ'), '#eef7e6', '#3f6212', 
        // 'wait' מסומן — אחרת שיבוץ-בהמתנה נראה בהיסטוריה/בתדפיס כרישום רגיל
        'נרשמ/ה ' + first + ' ל' + cname + (e.group ? ' · ' + e.group : '') + (e.status === 'wait' ? ' · ברשימת-המתנה' : ''));
        for (const p of e.payments) {
            push(p.date, 'תשלום', '#e4f5ea', '#12803c', 'תשלום ₪' + p.amount + ' (' + p.method + ') — ' + cname + ' · ' + p.rid);
        }
        for (const a of e.absences) {
            push(a.date, a.noshow ? 'No-Show' : 'היעדרות', '#fdeaea', '#b91c1c', 'היעדרות — ' + cname + (a.reason ? ' · ' + a.reason : '') + (a.makeup ? ' · זכאי/ת השלמה' : ''));
        }
    }
    return out.sort((a, b) => b.date.localeCompare(a.date)).slice(0, 40);
}
export function familiesListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        finderAxisValue: (() => { try {
            return finderAxisValue(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        famEnrollments: (() => { try {
            return famEnrollments(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        famLiveEnrollments: (() => { try {
            return famLiveEnrollments(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        finderMatches: (() => { try {
            return finderMatches(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        famHistoryOf: (() => { try {
            return famHistoryOf(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { finderAxisValue, famEnrollments, famLiveEnrollments, finderMatches, famHistoryOf };
