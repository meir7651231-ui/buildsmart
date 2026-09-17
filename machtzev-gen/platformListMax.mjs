function teamSummary(list) {
    if (!Array.isArray(list))
        return { week: 0, activeToday: 0, top: '' }; // מגן-קלט (21.8)
    const week = list.reduce((t, w) => t + w.last7, 0);
    const activeToday = list.filter((w) => w.today > 0).length;
    const top = list.find((w) => w.last7 > 0)?.email ?? '';
    return { week, activeToday, top };
}
function quietWorkers(list, minDays = 3) {
    return list.filter((w) => w.quietDays >= minDays);
}
function teamCsvRows(list, goals) {
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
function goalProgress(w, goal) {
    if (!goal || goal <= 0)
        return null;
    const pct = Math.min(100, Math.round((w.last7 / goal) * 100));
    return { pct, done: w.last7 >= goal };
}
function trendOf(w) {
    if (w.last7 > w.prevWeek)
        return '▲';
    if (w.last7 < w.prevWeek)
        return '▼';
    return '＝';
}
export function platformListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        teamSummary: (() => { try {
            return teamSummary(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        quietWorkers: (() => { try {
            return quietWorkers(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        teamCsvRows: (() => { try {
            return teamCsvRows(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it, trendOf: (() => { try {
                return trendOf(it);
            }
            catch {
                return null;
            } })(), goalProgress: (() => { try {
                return goalProgress(it);
            }
            catch {
                return null;
            } })() })) : undefined,
    };
}
export { teamSummary, quietWorkers, teamCsvRows, trendOf, goalProgress };
