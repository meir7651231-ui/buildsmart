// 🤖 AUTO-EMITTED by gen-max — findSupporterDupGroups משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function supNameCityKey(sp) {
    const n = (sp.name || '').trim().replace(/\s+/g, ' ').toLowerCase();
    const c = (sp.city || '').trim().toLowerCase();
    return n && c ? n + '|' + c : '';
}
function phoneRegion(raw) {
    const s = (raw || '').replace(/[^\d+]/g, '');
    if (!s)
        return 'il';
    if (/^(\+?972|00972)/.test(s))
        return 'il';
    if (/^\+/.test(s))
        return 'intl';
    if (/^00/.test(s))
        return 'intl';
    const d = s.replace(/\D/g, '');
    if (/^0\d{8,9}$/.test(d))
        return 'il'; // 0 + 9/10 ספרות
    if (/^5\d{8}$/.test(d))
        return 'il'; // נייד ישראלי בלי 0 מוביל
    return 'intl';
}
function normEmail(email) {
    return email.trim().toLowerCase();
}
function normName(s) {
    return normSearch(s).replace(/\s/g, '');
}
function normPhone(s) {
    let d = (s || '').replace(/\D/g, '');
    if (/^(\d)\1+$/.test(d))
        return ''; // מציין-מקום (אפסים/ספרה-חוזרת) — לא טלפון אמיתי
    d = d.replace(/^00/, ''); // צורה בינ"ל 00972…
    if (d.startsWith('972'))
        d = '0' + d.slice(3);
    return d.replace(/^0{2,}/, '0'); // כיווץ אפסים-מובילים-כפולים (מספר ישראלי לא מתחיל 00)
}
function normId(s) {
    const d = (s || '').replace(/\D/g, '');
    if (!d || /^0+$/.test(d))
        return '';
    // מציין-מקום נדרים מרופד: "000000020"/"000000065" — עוברים את /^0+$/ אך אינם ת"ז.
    // אם אחרי הסרת אפסים-מובילים נשארות <4 ספרות-משמעותיות ⇒ לא מפתח.
    if (d.replace(/^0+/, '').length < 4)
        return '';
    return d.length >= 5 ? d : '';
}
export function findSupporterDupGroups_ORIG(supporters) {
    const parent = new Map();
    const find = (x) => {
        let r = x;
        while (parent.get(r) !== r)
            r = parent.get(r);
        let c = x;
        while (parent.get(c) !== r) {
            const nx = parent.get(c);
            parent.set(c, r);
            c = nx;
        }
        return r;
    };
    const union = (a, b) => {
        const ra = find(a);
        const rb = find(b);
        if (ra !== rb)
            parent.set(ra, rb);
    };
    for (const sp of supporters)
        parent.set(sp.id, sp.id);
    const byPhone = new Map();
    const byEmail = new Map();
    const byId = new Map(); // ת"ז
    const byExt = new Map(); // מזהה-חיצוני (ToremId)
    const byNameCity = new Map();
    const byNameSorted = new Map(); // שם חסין-סדר (בלי חובת-עיר)
    const link = (map, key, id) => {
        if (!key)
            return;
        const prev = map.get(key);
        if (prev)
            union(prev, id);
        else
            map.set(key, id);
    };
    for (const sp of supporters) {
        const p = normPhone(sp.phone);
        link(byPhone, p.length >= 7 ? p : '', sp.id);
        link(byEmail, (sp.email || '').trim().toLowerCase(), sp.id);
        link(byId, normId(sp.idNum), sp.id);
        link(byExt, (sp.extId || '').trim(), sp.id);
        link(byNameCity, supNameCityKey(sp), sp.id);
        // מפתח-שם חסין-סדר: תופס כפילות נדרים ("בן צבי רחל"↔"רחל בן צבי") שאין לה עיר/ת"ז.
        // דורש ≥2 מילים (שם-מלא) כדי לא לקבץ שמות-בודדים נפוצים. תוצאה = הצעה לסקירה-ידנית.
        const ns = nameSortKey(sp.name);
        link(byNameSorted, ns.includes(' ') ? ns : '', sp.id);
    }
    const groups = new Map();
    for (const sp of supporters) {
        const r = find(sp.id);
        (groups.get(r) ?? groups.set(r, []).get(r)).push(sp.id);
    }
    return [...groups.values()].filter((g) => g.length >= 2);
}
export function findSupporterDupGroups(supporters, __opt = {}) {
    const base = findSupporterDupGroups_ORIG(supporters);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    if (typeof supporters.phone === 'string' && supporters.phone.trim() && !/^[\d+][\d\s-]{6,}$/.test(supporters.phone.trim()))
        return 'מספר טלפון תקין הוא שדה חובה';
    if (typeof supporters.email === 'string' && supporters.email.trim() && !/^\S+@\S+\.\S+$/.test((supporters.email || '').trim().toLowerCase()))
        return 'כתובת האימייל אינה תקינה';
    return base;
}
