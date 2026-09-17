// 🤖 AUTO-EMITTED by gen-max — localQuiet משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const QUIET_FROM = 21;
const QUIET_TO = 8;
export function localQuiet_ORIG(nowHour) {
    return nowHour >= QUIET_FROM || nowHour < QUIET_TO;
}
export function localQuiet(nowHour, __opt = {}) {
    const base = localQuiet_ORIG(nowHour);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
