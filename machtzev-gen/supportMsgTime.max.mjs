// 🤖 AUTO-EMITTED by gen-max — supportMsgTime (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const SUPPORT_MSG_MAX = 2000;
export function supportMsgTime_ORIG(at) {
    const d = new Date(at.includes('T') ? at : at + 'T12:00:00');
    if (Number.isNaN(d.getTime()))
        return '';
    return d.toLocaleTimeString('he-IL', { hour: '2-digit', minute: '2-digit' });
}
function sanitizeSupportText(raw) {
    return (raw ?? '').replace(/\s+$/u, '').replace(/^\s+/u, '').slice(0, SUPPORT_MSG_MAX);
}
export function supportMsgTime(at) { return supportMsgTime_ORIG(at); }
export function supportMsgTime_fromSource(raw) { return supportMsgTime_ORIG(sanitizeSupportText(raw)); }
