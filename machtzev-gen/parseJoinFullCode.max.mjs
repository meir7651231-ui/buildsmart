// 🤖 AUTO-EMITTED by gen-max — parseJoinFullCode (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function genJoinCode(seed) {
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
export function parseJoinFullCode(full) { return parseJoinFullCode_ORIG(full); }
export function parseJoinFullCode_fromSource(seed) { return parseJoinFullCode_ORIG(genJoinCode(seed)); }
