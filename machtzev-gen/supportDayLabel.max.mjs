// 🤖 AUTO-EMITTED by gen-max — supportDayLabel (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const SUPPORT_MSG_MAX = 2000;
export function supportDayLabel_ORIG(at, todayIso) {
    const day = at.slice(0, 10);
    if (day === todayIso)
        return 'היום';
    // אתמול = יום-אחד לפני todayIso (חישוב על ה-ISO, צהריים מקומי)
    const t = new Date(todayIso + 'T12:00:00');
    t.setDate(t.getDate() - 1);
    const y = t.getFullYear();
    const m = String(t.getMonth() + 1).padStart(2, '0');
    const dd = String(t.getDate()).padStart(2, '0');
    if (day === `${y}-${m}-${dd}`)
        return 'אתמול';
    const [yy, mm, d2] = day.split('-');
    return d2 && mm && yy ? `${d2}/${mm}/${yy}` : day;
}
function sanitizeSupportText(raw) {
    return (raw ?? '').replace(/\s+$/u, '').replace(/^\s+/u, '').slice(0, SUPPORT_MSG_MAX);
}
export function supportDayLabel(at, todayIso) { return supportDayLabel_ORIG(at, todayIso); }
export function supportDayLabel_fromSource(raw, todayIso) { return supportDayLabel_ORIG(sanitizeSupportText(raw), todayIso); }
