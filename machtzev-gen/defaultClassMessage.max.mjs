// 🤖 AUTO-EMITTED by gen-max — defaultClassMessage (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function defaultClassMessage_ORIG(courseName, orgName) {
    return 'שלום, כאן ' + (orgName || 'העמותה') + ' — הודעה בנוגע ל"' + courseName + '": ';
}
function classPhonesText(contacts) {
    return contacts.map((c) => c.phone).filter(Boolean).join(', ');
}
export function defaultClassMessage(courseName, orgName) { return defaultClassMessage_ORIG(courseName, orgName); }
export function defaultClassMessage_fromSource(contacts, orgName) { return defaultClassMessage_ORIG(classPhonesText(contacts), orgName); }
