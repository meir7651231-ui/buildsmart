function filterVolunteers(vols, q) {
    if (!q.trim())
        return vols;
    return smartFilter(q, vols, (v) => [v.name, v.phone, v.area ?? '']);
}
export function shop7ListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        filterVolunteers: (() => { try {
            return filterVolunteers(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { filterVolunteers };
