// 🤖 AUTO-EMITTED by gen-max — genJoinCode (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function genJoinCode_ORIG(seed) {
    let h = 2166136261;
    for (let i = 0; i < seed.length; i++) {
        h ^= seed.charCodeAt(i);
        h = Math.imul(h, 16777619);
    }
    let out = '';
    let x = h >>> 0;
    for (let i = 0; i < 8; i++) {
        out += (x % 36).toString(36);
        x = Math.floor(x / 36) || (h >>> 0) + i + 1;
    }
    return out;
}
function orgJoinLink(origin, basePath, slug, code) {
    return origin + basePath + '?org=' + slug + '&join=' + code;
}
export function genJoinCode(seed) { return genJoinCode_ORIG(seed); }
export function genJoinCode_fromSource(origin, basePath, slug, code) { return genJoinCode_ORIG(orgJoinLink(origin, basePath, slug, code)); }
