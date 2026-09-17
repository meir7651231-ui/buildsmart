// 🤖 AUTO-EMITTED by gen-max — portalMessage (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const PORTAL_REQ_PREFIX = '📥 בקשת-הרשמה';
export function portalMessage_ORIG(orgName, f) {
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
function portalChatLine(f) {
    return [
        PORTAL_REQ_PREFIX,
        'ילד/ה: ' + f.childName.trim(),
        f.parentName.trim() && 'הורה: ' + f.parentName.trim(),
        'טלפון: ' + f.phone.trim(),
        f.course.trim() && 'חוג: ' + f.course.trim(),
        f.note.trim() && 'הערה: ' + f.note.trim(),
    ]
        .filter(Boolean)
        .join('\n');
}
export function portalMessage(orgName, f) { return portalMessage_ORIG(orgName, f); }
export function portalMessage_fromSource(f) { return portalMessage_ORIG(portalChatLine(f), f); }
