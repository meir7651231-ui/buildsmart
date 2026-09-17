// 🤖 AUTO-EMITTED by gen-max — normalizePrices משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const DEFAULT_PRICES = {
    base: 290, // ליבה: בית · משפחות · לוח · הגדרות (CRM בסיסי)
    modules: {
        families: 0, // כלול בבסיס (CRM ליבה)
        calendar: 0, // כלול בבסיס
        courses: 120, // חוגים · שיבוצים · נוכחות — מודול כבד
        diary: 70,
        supporters: 180, // תורמים + קבלות §46 — הערך הגבוה ביותר
        reports: 60,
        tzedaka: 90,
        shop: 90,
        shop7: 80, // חלוקה
    },
    integrations: DEFAULT_INTEGRATION_PRICES,
    sizeMult: { small: 1, medium: 1.6, large: 2.4 },
    setup: 1500, // הקמה/הטמעה חד-פעמית — נורמת-שוק (הבעלים יכול לאפס כמנוף-מכירה)
    enterprise: { oneTime: 55000, annualMaintenance: 9000 },
};
const DEFAULT_INTEGRATION_PRICES = {
    receipts: 60, // קבלות §46 אוטומטיות — ערך-ציות גבוה
    payments: 90, // סליקה והוראות-קבע
    whatsapp: 50,
    sms: 40, // דמי-מודול (עלות-הודעה בפועל נגבית בנפרד)
    phone: 90, // טלפוניה/מרכזייה
    gcal: 30,
    drive: 30,
    sheets: 40,
    maps: 40,
    esign: 60, // חתימה דיגיטלית
    ai: 120, // עוזר-חכם — פרימיום
    campaign: 60,
};
function donAllowedKeys(allowed) {
    const clean = [...new Set(allowed.map((s) => s.trim()).filter(Boolean))].slice(0, 29);
    return [...clean, SHARED_PURPOSE_KEY];
}
export function normalizePrices_ORIG(raw) {
    const base = raw && typeof raw === 'object' ? raw : {};
    const num = (v, fb) => (typeof v === 'number' && Number.isFinite(v) && v >= 0 ? v : fb);
    const modules = {};
    for (const m of ALL_MODULES)
        modules[m] = num(base.modules?.[m], DEFAULT_PRICES.modules[m] ?? 0);
    const integrations = {};
    for (const k of Object.keys(DEFAULT_INTEGRATION_PRICES)) {
        integrations[k] = num(base.integrations?.[k], DEFAULT_INTEGRATION_PRICES[k]);
    }
    return {
        base: num(base.base, DEFAULT_PRICES.base),
        modules,
        integrations,
        sizeMult: {
            small: num(base.sizeMult?.small, DEFAULT_PRICES.sizeMult.small),
            medium: num(base.sizeMult?.medium, DEFAULT_PRICES.sizeMult.medium),
            large: num(base.sizeMult?.large, DEFAULT_PRICES.sizeMult.large),
        },
        setup: num(base.setup, DEFAULT_PRICES.setup),
        enterprise: {
            oneTime: num(base.enterprise?.oneTime, DEFAULT_PRICES.enterprise.oneTime),
            annualMaintenance: num(base.enterprise?.annualMaintenance, DEFAULT_PRICES.enterprise.annualMaintenance),
        },
    };
}
export function normalizePrices(raw, __opt = {}) {
    const base = normalizePrices_ORIG(raw);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
