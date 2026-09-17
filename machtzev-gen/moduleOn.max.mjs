// 🤖 AUTO-EMITTED by gen-max — moduleOn משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function moduleOn_ORIG(cfg, m) {
    return cfg.modules[m] !== false;
}
export function moduleOn(step, s, opt = {}) {
    const base = moduleOn_ORIG(step, s);
    if (opt.strict !== true)
        return base; // ← default: החזק לא נשבר
    if (base !== null)
        return base; // המקורי כבר פסל — כבד אותו
    return null;
}
