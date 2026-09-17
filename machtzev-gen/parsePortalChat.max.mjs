// 🤖 AUTO-EMITTED by gen-max — parsePortalChat (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const PORTAL_REQ_PREFIX = '📥 בקשת-הרשמה';
export function parsePortalChat_ORIG(text) {
    if (!text || !text.startsWith(PORTAL_REQ_PREFIX))
        return null;
    const get = (label) => {
        const m = text.match(new RegExp('^' + label + ':\\s*(.+)$', 'm'));
        return m ? m[1].trim() : '';
    };
    const phone = get('טלפון');
    const childName = get('ילד/ה');
    if (!childName && !phone)
        return null;
    return { childName, parentName: get('הורה'), phone, course: get('חוג'), note: get('הערה') };
}
function portalMessage(orgName, f) {
    return [
        'בקשת הרשמה לחוג — ' + (orgName || 'העמותה'),
        'ילד/ה: ' + f.childName.trim(),
        f.parentName.trim() && 'הורה: ' + f.parentName.trim(),
        'טלפון: ' + f.phone.trim(),
        f.course.trim() && 'חוג מבוקש: ' + f.course.trim(),
        f.note.trim() && 'הערה: ' + f.note.trim(),
    ]
        .filter(Boolean)
        .join('\n');
}
export function parsePortalChat(text) { return parsePortalChat_ORIG(text); }
export function parsePortalChat_fromSource(orgName, f) { return parsePortalChat_ORIG(portalMessage(orgName, f)); }
