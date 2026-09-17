function portalMessage(orgName, f) {
    return [
        'בקשת הרשמה לחוג — ' + (orgName || 'העמותה'),
        'ילד/ה: ' + f.childName.trim(),
        f.parentName.trim() && 'הורה: ' + f.parentName.trim(),
        'טלפון: ' + f.phone.trim(),
        f.course.trim() && 'חוג מבוקש: ' + f.course.trim(),
        f.note.trim() && 'הערה: ' + f.note.trim(),
    ]
        .filter(Boolean)
        .join('\n');
}
export function publicListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        portalMessage: (() => { try {
            return portalMessage(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        portalMessage: (() => { try {
            return portalMessage(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { portalMessage };
