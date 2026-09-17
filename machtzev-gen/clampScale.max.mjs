// 🤖 AUTO-EMITTED by gen-max — clampScale (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const SCALE_MAX = 1.6;
const SCALE_MIN = 0.8;
const SCALE_STEP = 0.1;
export function clampScale_ORIG(v) {
    if (!Number.isFinite(v))
        return 1;
    return Math.min(SCALE_MAX, Math.max(SCALE_MIN, v));
}
function stepScale(v, dir) {
    return clampScale(Math.round((clampScale(v) + dir * SCALE_STEP) * 10) / 10);
}
export function clampScale(v) { return clampScale_ORIG(v); }
export function clampScale_fromSource(v, dir) { return clampScale_ORIG(stepScale(v, dir)); }
