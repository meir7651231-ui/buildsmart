// 🤖 AUTO-EMITTED by gen-max — revertStillApplies משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function revertStillApplies_ORIG(liveVersion, toVersion) {
    return liveVersion === toVersion;
}
export function revertStillApplies(liveVersion, toVersion, __opt = {}) {
    const base = revertStillApplies_ORIG(liveVersion, toVersion);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
