// 🤖 AUTO-EMITTED by gen-max — featureOn משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const NAV_MODULE_KEYS = [
    'families',
    'courses',
    'calendar',
    'diary',
    'supporters',
    'reports',
    'tzedaka',
    'shop',
    'shop7',
];
function moduleOn(cfg, m) {
    return cfg.modules[m] !== false;
}
export function featureOn_ORIG(cfg, key) {
    const parts = key.split('.');
    // כל דגל-אב (וכן הדגל עצמו) שכבוי במפורש — מכבה את הצאצא
    for (let i = 1; i <= parts.length; i++) {
        if (cfg.features?.[parts.slice(0, i).join('.')] === false)
            return false;
    }
    // מודול-הניווט (הקידומת הראשונה) כבוי — מכבה את כל הדגלים תחתיו
    const prefix = parts[0] ?? '';
    if (NAV_MODULE_KEYS.includes(prefix) && !moduleOn(cfg, prefix)) {
        return false;
    }
    return true;
}
export function featureOn(cfg, key, __opt = {}) {
    const base = featureOn_ORIG(cfg, key);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
