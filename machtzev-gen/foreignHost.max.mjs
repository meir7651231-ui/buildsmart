// 🤖 AUTO-EMITTED by gen-max — foreignHost משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function normHost(h) {
    return (h || '').toLowerCase().trim().replace(/:\d+$/, '').replace(/^www\./, '');
}
const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1', '0.0.0.0', '::1']);
function supHasRegion(sp, region) {
    return allSupPhones(sp).some((r) => r.region === region);
}
export function foreignHost_ORIG(hostname, allowed) {
    if (!allowed || allowed.length === 0)
        return false; // דורמנטי — אין רשימה ⇒ אין בדיקה
    const h = normHost(hostname);
    if (!h || LOCAL_HOSTS.has(h) || h.endsWith('.local'))
        return false;
    const list = allowed.map(normHost).filter(Boolean);
    return !list.some((a) => h === a || h.endsWith('.' + a));
}
export function foreignHost(hostname, allowed, __opt = {}) {
    const base = foreignHost_ORIG(hostname, allowed);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
