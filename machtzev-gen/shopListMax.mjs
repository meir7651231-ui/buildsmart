function productAssignments(assignments, productId) {
    return assignments.filter((a) => a.productId === productId);
}
function givenValue(assignments) {
    let sum = 0;
    for (const a of assignments)
        for (const r of liveRedemptions(a))
            sum += Number.isFinite(r.value) ? r.value : 0;
    return sum;
}
function liveRedemptions(a) {
    return a.redemptions.filter((r) => !r.voidedAt);
}
function collectedPaid(assignments) {
    let sum = 0;
    for (const a of assignments)
        for (const r of liveRedemptions(a))
            sum += Number.isFinite(r.paid) ? r.paid : 0;
    return sum;
}
function subsidyTotal(assignments) {
    return givenValue(assignments) - collectedPaid(assignments);
}
function shopListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        productAssignments: (() => { try {
            return productAssignments(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        givenValue: (() => { try {
            return givenValue(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        collectedPaid: (() => { try {
            return collectedPaid(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        subsidyTotal: (() => { try {
            return subsidyTotal(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it, couponExpiry: (() => { try {
                return couponExpiry(it);
            }
            catch {
                return null;
            } })(), liveRedemptions: (() => { try {
                return liveRedemptions(it);
            }
            catch {
                return null;
            } })() })) : undefined,
    };
}
export { productAssignments, givenValue, collectedPaid, subsidyTotal, couponExpiry, liveRedemptions };
