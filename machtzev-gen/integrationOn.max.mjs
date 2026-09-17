// 🤖 AUTO-EMITTED by gen-max — integrationOn משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function integrationOn_ORIG(cfg, key) {
    return cfg.integrations?.[key]?.enabled === true;
}
export function integrationOn(cfg, key, __opt = {}) {
    const base = integrationOn_ORIG(cfg, key);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
