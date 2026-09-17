// 🤖 AUTO-EMITTED by gen-max — siteVocab (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function siteVocab_ORIG(commercial, lang) {
    const en = lang === 'en';
    if (commercial) {
        return {
            heroCta: en ? 'Get in touch' : 'צרו קשר',
            navCta: en ? 'Contact' : 'צרו קשר',
            give: en ? 'Contact us' : 'צרו קשר',
            giveLabel: en ? 'Your request' : 'הפנייה שלך',
            commercial: true,
        };
    }
    return {
        heroCta: en ? 'Donate now' : 'לתרומה עכשיו',
        navCta: (en ? 'Donate' : 'לתרומה') + ' ♡',
        give: (en ? 'Donate' : 'לתרומה') + ' ♡',
        giveLabel: en ? 'Your gift' : 'התרומה שלך',
        commercial: false,
    };
}
function hasPublicSite(config) {
    return !!config.site && config.site.enabled !== false;
}
export function siteVocab(commercial, lang) { return siteVocab_ORIG(commercial, lang); }
export function siteVocab_fromSource(config, lang) { return siteVocab_ORIG(hasPublicSite(config), lang); }
