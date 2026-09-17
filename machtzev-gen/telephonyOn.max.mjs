// 🤖 AUTO-EMITTED by gen-max — telephonyOn משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const TEL_KINDS = ['sim', 'virtual', 'whatsapp'];
function telStr(v, max) {
    return typeof v === 'string' ? v.replace(/\p{Cc}/gu, '').trim().slice(0, max) : '';
}
const TEL_HHMM_RE = /^([01]\d|2[0-3]):[0-5]\d$/;
function telExt(v, def) {
    const s = typeof v === 'string' ? v.replace(/\D/g, '').slice(0, 8) : '';
    return s || def;
}
function normalizeTelephony(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw))
        return undefined;
    const t = raw;
    const numsRaw = Array.isArray(t.numbers) ? t.numbers.slice(0, 64) : [];
    const numbers = [];
    numsRaw.forEach((n, i) => {
        if (!n || typeof n !== 'object' || Array.isArray(n))
            return;
        const o = n;
        const kind = TEL_KINDS.includes(o.kind) ? o.kind : 'sim';
        const e164 = typeof o.e164 === 'string' ? o.e164.replace(/[^\d+()\-\s]/g, '').trim().slice(0, 24) : '';
        const id = telStr(o.id, 32) || `n${i + 1}`;
        const num = { id, e164, label: telStr(o.label, 60) || id, kind };
        if (o.kosher === true)
            num.kosher = true;
        numbers.push(num);
    });
    const daysRaw = Array.isArray(t.officeDays) ? t.officeDays : [0, 1, 2, 3, 4];
    const officeDays = [
        ...new Set(daysRaw.filter((d) => Number.isInteger(d) && d >= 0 && d <= 6)),
    ].sort((a, b) => a - b);
    const bool = (v, def) => (typeof v === 'boolean' ? v : def);
    const hhmm = (v, def) => (typeof v === 'string' && TEL_HHMM_RE.test(v) ? v : def);
    // עיר — [a-z] בלבד, 2–20 תווים (תואם לקבלה של validate.mjs); אורך פסול ⇒ '' (מושמט,
    // לא נגזם — קלט חורג הוא זבל, עדיף נפילה לברירת-מחדל מאשר שם-עיר שגוי-שקט).
    const cityRaw = typeof t.city === 'string' ? t.city.toLowerCase().replace(/[^a-z]/g, '') : '';
    return {
        // מתג-המקטע — opt-in: הכותרת נשמרת רק כשהיא true (חסר/false ⇒ כבוי, מושמט).
        ...(t.enabled === true ? { enabled: true } : {}),
        numbers,
        officeDays,
        officeStart: hhmm(t.officeStart, '09:00'),
        officeEnd: hhmm(t.officeEnd, '17:00'),
        officeExt: telExt(t.officeExt, '101'),
        managerExt: telExt(t.managerExt, '201'),
        vmBox: telExt(t.vmBox, '100'),
        city: cityRaw.length >= 2 && cityRaw.length <= 20 ? cityRaw : '',
        kosherMode: bool(t.kosherMode, false),
        hebrewCalendar: bool(t.hebrewCalendar, true),
        zmanim: bool(t.zmanim, false),
        shabbat: bool(t.shabbat, true),
        fasts: bool(t.fasts, false),
        voicemail: bool(t.voicemail, true),
    };
}
export function telephonyOn_ORIG(cfg) {
    return cfg.telephony?.enabled === true;
}
export function telephonyOn(cfg, __opt = {}) {
    const base = telephonyOn_ORIG(cfg);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
