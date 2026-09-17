// 🤖 AUTO-EMITTED by gen-max — waPaymentText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function orgOf(orgName) {
    return orgName.trim() || 'העמותה';
}
export function waPaymentText_ORIG(orgName, what, balance, cfg) {
    return renderTemplate(cfg, 'wa.payment', {
        org: orgOf(orgName),
        what,
        amount: Math.round(balance).toLocaleString('he-IL'),
    });
}
function waDeliveryText(orgName, famName, cfg) {
    return renderTemplate(cfg, 'wa.delivery', { name: ('משפחת ' + famName).trim(), org: orgOf(orgName) });
}
export function waPaymentText(orgName, what, balance, cfg) { return waPaymentText_ORIG(orgName, what, balance, cfg); }
export function waPaymentText_fromSource(orgName, famName, cfg, what, balance) { return waPaymentText_ORIG(waDeliveryText(orgName, famName, cfg), what, balance, cfg); }
