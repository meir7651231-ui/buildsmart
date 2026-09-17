// 🤖 AUTO-EMITTED by gen-max — waDeliveryText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function orgOf(orgName) {
    return orgName.trim() || 'העמותה';
}
export function waDeliveryText_ORIG(orgName, famName, cfg) {
    return renderTemplate(cfg, 'wa.delivery', { name: ('משפחת ' + famName).trim(), org: orgOf(orgName) });
}
function waPaymentText(orgName, what, balance, cfg) {
    return renderTemplate(cfg, 'wa.payment', {
        org: orgOf(orgName),
        what,
        amount: Math.round(balance).toLocaleString('he-IL'),
    });
}
export function waDeliveryText(orgName, famName, cfg) { return waDeliveryText_ORIG(orgName, famName, cfg); }
export function waDeliveryText_fromSource(orgName, what, balance, cfg, famName) { return waDeliveryText_ORIG(waPaymentText(orgName, what, balance, cfg), famName, cfg); }
