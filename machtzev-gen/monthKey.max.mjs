// 🤖 AUTO-EMITTED by gen-max — monthKey (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function monthKey_ORIG(iso) {
    return iso.slice(0, 7);
}
function monthLabel(key) {
    const [y, m] = key.split('-');
    return `${m}/${y}`;
}
export function monthKey(iso) { return monthKey_ORIG(iso); }
export function monthKey_fromSource(key) { return monthKey_ORIG(monthLabel(key)); }
