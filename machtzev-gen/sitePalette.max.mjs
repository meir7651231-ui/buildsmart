// 🤖 AUTO-EMITTED by gen-max — sitePalette (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function hexToRgb(hex) {
    const m = /^#?([0-9a-f]{3}|[0-9a-f]{6})$/i.exec(hex.trim());
    if (!m)
        return null;
    let h = m[1];
    if (h.length === 3)
        h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
    const n = parseInt(h, 16);
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}
const CORAL_PALETTE = {
    c1: '#EC9C9C', c2: '#D97F7F', c3: '#B95F5F', word: '#E29392', ink: '#33272A',
    paper: '#FFFCFA', cream: '#FBF1EF', blush: '#FFF3F0', marquee: '#F9E4E1',
    rgb1: '236,156,156', rgb2: '217,127,127', inkRgb: '51,39,42',
};
function rgbToHsl(r, g, b) {
    r /= 255;
    g /= 255;
    b /= 255;
    const max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min;
    const l = (max + min) / 2;
    let h = 0, s = 0;
    if (d) {
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        if (max === r)
            h = ((g - b) / d + (g < b ? 6 : 0));
        else if (max === g)
            h = (b - r) / d + 2;
        else
            h = (r - g) / d + 4;
        h *= 60;
    }
    return [h, s, l];
}
function hslToRgb(h, s, l) {
    h = ((h % 360) + 360) % 360;
    const c = (1 - Math.abs(2 * l - 1)) * s;
    const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
    const m = l - c / 2;
    let r = 0, g = 0, b = 0;
    if (h < 60)
        [r, g, b] = [c, x, 0];
    else if (h < 120)
        [r, g, b] = [x, c, 0];
    else if (h < 180)
        [r, g, b] = [0, c, x];
    else if (h < 240)
        [r, g, b] = [0, x, c];
    else if (h < 300)
        [r, g, b] = [x, 0, c];
    else
        [r, g, b] = [c, 0, x];
    return [Math.round((r + m) * 255), Math.round((g + m) * 255), Math.round((b + m) * 255)];
}
function toHex([r, g, b]) {
    return '#' + [r, g, b].map((v) => Math.max(0, Math.min(255, v)).toString(16).padStart(2, '0')).join('');
}
const rgbStr = ([r, g, b]) => `${r},${g},${b}`;
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
export function sitePalette_ORIG(accent) {
    const base = accent && accent.trim() ? hexToRgb(accent) : null;
    if (!base)
        return CORAL_PALETTE;
    const [h, s0] = rgbToHsl(base[0], base[1], base[2]);
    const s = Math.max(0.42, Math.min(0.86, s0));
    const mk = (sat, l) => hslToRgb(h, sat, l);
    const c1 = mk(Math.min(0.8, s * 0.92), 0.75);
    const c2 = mk(s, 0.62);
    const c3 = mk(Math.min(0.9, s * 1.04), 0.47);
    const word = mk(s, 0.67);
    const ink = mk(0.18, 0.16);
    return {
        c1: toHex(c1), c2: toHex(c2), c3: toHex(c3), word: toHex(word), ink: toHex(ink),
        paper: toHex(mk(0.4, 0.986)), cream: toHex(mk(0.46, 0.955)), blush: toHex(mk(0.62, 0.965)),
        marquee: toHex(mk(0.5, 0.9)),
        rgb1: rgbStr(c1), rgb2: rgbStr(c2), inkRgb: rgbStr(ink),
    };
}
function siteUi(lang, key) {
    return (SITE_UI[lang] ?? SITE_UI.he)[key] ?? SITE_UI.he[key] ?? '';
}
export function sitePalette(accent) { return sitePalette_ORIG(accent); }
export function sitePalette_fromSource(lang, key) { return sitePalette_ORIG(siteUi(lang, key)); }
