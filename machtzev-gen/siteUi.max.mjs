// 🤖 AUTO-EMITTED by gen-max — siteUi (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const SITE_UI = {
    he: {
        donate: 'לתרומה', contact: 'צור קשר', enter: 'כניסה למערכת', services: 'מה אנחנו עושים',
        story: 'הסיפור שמאחורי', news: 'כל חודש — מה חדש', gallery: 'רגעים', campaign: 'הקמפיין שלנו',
        raised: 'גויסו', goal: 'יעד', daysLeft: 'ימים נותרו', call: 'חייגו', whatsapp: 'וואטסאפ',
        email: 'מייל', poweredBy: 'מופעל על-ידי מאור', dir: 'rtl',
    },
    en: {
        donate: 'Donate', contact: 'Contact', enter: 'Staff login', services: 'What we do',
        story: 'Our story', news: 'This month', gallery: 'Moments', campaign: 'Our campaign',
        raised: 'Raised', goal: 'Goal', daysLeft: 'days left', call: 'Call', whatsapp: 'WhatsApp',
        email: 'Email', poweredBy: 'Powered by Maor', dir: 'ltr',
    },
    yi: {
        donate: 'שפּענדן', contact: 'פֿאַרבינדונג', enter: 'אַרײַנגאַנג', services: 'וואָס מיר טוען',
        story: 'אונדזער געשיכטע', news: 'דעם חודש', gallery: 'מאָמענטן', campaign: 'אונדזער קאַמפּיין',
        raised: 'געזאַמלט', goal: 'ציל', daysLeft: 'טעג געבליבן', call: 'רופֿט', whatsapp: 'וואַטסאַפּ',
        email: 'בליץ-פּאָסט', poweredBy: 'געטריבן דורך מאור', dir: 'rtl',
    },
};
export function siteUi_ORIG(lang, key) {
    return (SITE_UI[lang] ?? SITE_UI.he)[key] ?? SITE_UI.he[key] ?? '';
}
function siteLangs(site) {
    const raw = site?.langs?.filter((l) => SITE_LANGS.includes(l)) ?? [];
    const uniq = [...new Set(raw)];
    return uniq.length ? uniq : ['he'];
}
export function siteUi(lang, key) { return siteUi_ORIG(lang, key); }
export function siteUi_fromSource(site, key) { return siteUi_ORIG(siteLangs(site), key); }
