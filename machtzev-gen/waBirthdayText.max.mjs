// 🤖 AUTO-EMITTED by gen-max — waBirthdayText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function orgOf(orgName) {
    return orgName.trim() || 'העמותה';
}
export function waBirthdayText_ORIG(orgName, firstName, cfg) {
    return renderTemplate(cfg, 'wa.birthday', { first: firstName, org: orgOf(orgName) });
}
function waDeliveryText(orgName, famName, cfg) {
    return renderTemplate(cfg, 'wa.delivery', { name: ('משפחת ' + famName).trim(), org: orgOf(orgName) });
}
export function waBirthdayText(orgName, firstName, cfg) { return waBirthdayText_ORIG(orgName, firstName, cfg); }
export function waBirthdayText_fromSource(orgName, famName, cfg, firstName) { return waBirthdayText_ORIG(waDeliveryText(orgName, famName, cfg), firstName, cfg); }
