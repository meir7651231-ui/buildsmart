function trendOf(w) {
    if (w.last7 > w.prevWeek)
        return '▲';
    if (w.last7 < w.prevWeek)
        return '▼';
    return '＝';
}
function workerIntel(audit, email, todayIso) {
    const me = norm(email);
    const mine = safeAudit(audit).filter((a) => norm(a.who) === me);
    const byActMap = {};
    const days = new Set();
    const hours = Array.from({ length: 24 }, () => 0);
    const spark14 = Array.from({ length: 14 }, () => 0);
    const t = new Date(todayIso + 'T12:00:00').getTime();
    let last7 = 0;
    let prevWeek = 0;
    let today = 0;
    let lastAt = '';
    for (const a of mine) {
        byActMap[a.act] = (byActMap[a.act] ?? 0) + 1;
        days.add(dayOf(a.at));
        if (a.at > lastAt)
            lastAt = a.at;
        if (withinDays(a.at, todayIso, 7))
            last7++;
        if (dayOf(a.at) === todayIso)
            today++;
        // שבוע-קודם + פס-14-יום — אותו חישוב-ימים דטרמיניסטי (צהריים מקומי)
        const diff = Math.round((t - new Date(dayOf(a.at) + 'T12:00:00').getTime()) / 86400000);
        if (diff >= 7 && diff < 14)
            prevWeek++;
        if (diff >= 0 && diff < 14)
            spark14[13 - diff]++;
        const h = Number(a.at.slice(11, 13));
        if (Number.isFinite(h) && h >= 0 && h < 24)
            hours[h]++;
    }
    const quietDays = lastAt ? Math.max(0, Math.round((t - new Date(dayOf(lastAt) + 'T12:00:00').getTime()) / 86400000)) : 99;
    const byAct = Object.entries(byActMap)
        .map(([act, n]) => ({ act, n }))
        .sort((a, b) => b.n - a.n || a.act.localeCompare(b.act, 'he'));
    const recent = [...mine].sort((a, b) => b.at.localeCompare(a.at)).slice(0, RECENT_LIMIT);
    const peak = hours.reduce((best, n, h) => (n > hours[best] ? h : best), 0);
    return {
        email,
        actions: mine.length,
        lastAt,
        daysActive: days.size,
        last7,
        today,
        byAct,
        recent,
        peakHour: mine.length ? peak : null,
        prevWeek,
        spark14,
        quietDays,
    };
}
function safeAudit(audit) {
    if (!Array.isArray(audit))
        return [];
    return audit.filter((a) => !!a && typeof a === 'object' && typeof a.at === 'string');
}
const norm = (e) => String(e ?? '').trim().toLowerCase();
const dayOf = (iso) => iso.slice(0, 10);
function withinDays(iso, todayIso, days) {
    const d = new Date(dayOf(iso) + 'T12:00:00').getTime();
    const t = new Date(todayIso + 'T12:00:00').getTime();
    const diff = (t - d) / 86400000;
    return diff >= 0 && diff < days;
}
const RECENT_LIMIT = 6;
export function teamCsvRows_ORIG(list, goals) {
    const rows = [
        ['עובד/ת', 'סה"כ פעולות', 'השבוע', 'שבוע-קודם', 'מגמה', 'ימי-פעילות', 'שקט (ימים)', 'שעת-שיא', 'יעד-שבועי', 'עמידה-ביעד', 'פעולה-מובילה'],
    ];
    for (const w of list) {
        const g = goals[w.email];
        const gp = goalProgress(w, g);
        rows.push([
            w.email,
            w.actions,
            w.last7,
            w.prevWeek,
            trendOf(w),
            w.daysActive,
            w.quietDays >= 99 ? '' : w.quietDays,
            w.peakHour == null ? '' : String(w.peakHour).padStart(2, '0') + ':00',
            g ?? '',
            gp ? gp.pct + '%' : '',
            w.byAct[0]?.act ?? '',
        ]);
    }
    return rows;
}
function teamIntel(audit, emails, todayIso) {
    const uniq = [...new Set((Array.isArray(emails) ? emails : []).map((e) => String(e ?? '').trim()).filter(Boolean))];
    return uniq
        .map((e) => workerIntel(safeAudit(audit), e, todayIso))
        .sort((a, b) => b.last7 - a.last7 || b.actions - a.actions || a.email.localeCompare(b.email));
}
export function teamCsvRows(list, goals) { return teamCsvRows_ORIG(list, goals); }
export function teamCsvRows_fromSource(audit, emails, todayIso, goals) { return teamCsvRows_ORIG(teamIntel(audit, emails, todayIso), goals); }
