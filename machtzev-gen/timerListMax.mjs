function filterCashSuggest(list, q, max = 8) {
    const words = (q || '').trim().toLowerCase().split(/\s+/u).filter(Boolean);
    if (!words.length)
        return [];
    return list.filter((s) => { const n = s.name.toLowerCase(); return words.every((w) => n.includes(w)); }).slice(0, max);
}
export function timerListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        filterCashSuggest: (() => { try {
            return filterCashSuggest(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { filterCashSuggest };
