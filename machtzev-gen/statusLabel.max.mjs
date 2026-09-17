// 🤖 AUTO-EMITTED by gen-max — statusLabel (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const ORDER = ['pickup', 'enroute', 'delivered'];
export function statusLabel_ORIG(status) {
    return status === 'pickup' ? 'איסוף' : status === 'enroute' ? 'בדרך' : 'נמסר';
}
function advanceStatus(status) {
    const i = ORDER.indexOf(status);
    return i < 0 || i >= ORDER.length - 1 ? 'delivered' : ORDER[i + 1];
}
export function statusLabel(status) { return statusLabel_ORIG(status); }
export function statusLabel_fromSource(status) { return statusLabel_ORIG(advanceStatus(status)); }
