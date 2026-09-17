function downloadCsv(name, rows) {
    download(name, 'text/csv;charset=utf-8', rows.map((r) => r.map(esc).join(',')).join('\n'));
}
function download(name, mime, text) {
    if (!guardExport())
        return; // 🔐 שער יציאת-מידע (core.export כבוי בכרטיס-העובד)
    const a = document.createElement('a');
    a.href = URL.createObjectURL(new Blob(['\uFEFF' + text], { type: mime }));
    a.download = name;
    a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 5000);
}
function monthKey(iso) {
    return iso.slice(0, 7);
}
function monthLabel(key) {
    const [y, m] = key.split('-');
    return `${m}/${y}`;
}
function inRange(iso, r) {
    if (!iso)
        return false;
    if (r.from && iso < r.from)
        return false;
    if (r.to && iso > r.to)
        return false;
    return true;
}
export function reportsListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        downloadCsv: (() => { try {
            return downloadCsv(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        monthKey: (() => { try {
            return monthKey(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        monthLabel: (() => { try {
            return monthLabel(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        inRange: (() => { try {
            return inRange(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { downloadCsv, monthKey, monthLabel, inRange };
