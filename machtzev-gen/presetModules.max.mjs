// 🤖 AUTO-EMITTED by gen-max — presetModules משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function presetModules_ORIG(preset, scope) {
    const out = {};
    for (const m of preset.hide)
        if (scope.includes(m))
            out[m] = false;
    return out;
}
export function presetModules(preset, scope, __opt = {}) {
    const base = presetModules_ORIG(preset, scope);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
