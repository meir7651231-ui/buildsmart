function coordinatorBoxes(boxes, coordId) {
    return boxes.filter((b) => b.coordinatorId === coordId);
}
function staleBoxes(boxes, todayIso, days = TZ_STALE_DAYS) {
    const cutoff = new Date(todayIso + 'T12:00:00');
    cutoff.setDate(cutoff.getDate() - days);
    const cut = isoOf(cutoff);
    return boxes.filter((b) => {
        if (b.status !== 'home')
            return false;
        const last = lastCollectionIso(b) || b.since;
        return !!last && last <= cut;
    });
}
const TZ_STALE_DAYS = 90;
function lastCollectionIso(box) {
    let last = '';
    for (const c of box.collections)
        if (c.date > last)
            last = c.date;
    return last;
}
function coordinatorTotal(boxes, coordId) {
    return coordinatorBoxes(boxes, coordId).reduce((a, b) => a + boxTotal(b), 0);
}
function boxTotal(box) {
    return box.collections.reduce((a, c) => a + (Number.isFinite(c.amount) ? c.amount : 0), 0);
}
function grandTotal(boxes) {
    return boxes.reduce((a, b) => a + boxTotal(b), 0);
}
function campaignTotal(boxes, campaignId) {
    let sum = 0;
    for (const b of boxes)
        for (const c of b.collections)
            if (c.campaignId === campaignId)
                sum += Number.isFinite(c.amount) ? c.amount : 0;
    return sum;
}
function collectionScoreDelta(box, date, amount, rules = TZ_SCORE_RULES) {
    let pts = rules.emptyPts + Math.floor(amount / rules.ilsPerPoint);
    const prev = lastCollectionIso(box);
    if (prev) {
        const days = Math.round((new Date(date + 'T12:00:00').getTime() - new Date(prev + 'T12:00:00').getTime()) / 86400000);
        if (days >= 0 && days <= rules.streakDays)
            pts += rules.streakPts;
    }
    return pts;
}
const TZ_SCORE_RULES = { emptyPts: 10, ilsPerPoint: 50, streakDays: 60, streakPts: 5 };
export function tzedakaListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        coordinatorBoxes: (() => { try {
            return coordinatorBoxes(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        staleBoxes: (() => { try {
            return staleBoxes(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        coordinatorTotal: (() => { try {
            return coordinatorTotal(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        grandTotal: (() => { try {
            return grandTotal(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        campaignTotal: (() => { try {
            return campaignTotal(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it, lastCollectionIso: (() => { try {
                return lastCollectionIso(it);
            }
            catch {
                return null;
            } })(), collectionScoreDelta: (() => { try {
                return collectionScoreDelta(it);
            }
            catch {
                return null;
            } })(), boxTotal: (() => { try {
                return boxTotal(it);
            }
            catch {
                return null;
            } })() })) : undefined,
    };
}
export { coordinatorBoxes, staleBoxes, coordinatorTotal, grandTotal, campaignTotal, lastCollectionIso, collectionScoreDelta, boxTotal };
