// 🤖 AUTO-EMITTED by gen-max — findDuplicateGroups משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function phonesOf(f) {
    return [normPhone(f.phone), normPhone(f.phone2)].filter((p) => p.length >= 7);
}
function nameCityKey(f) {
    const n = (f.name || '').trim().replace(/\s+/g, ' ').toLowerCase();
    const c = (f.city || '').trim().toLowerCase();
    return n && c ? n + '|' + c : '';
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
function setAllowedPurposes(p) {
    allowedPurposes = p && p.length ? p : null;
}
function getSyncLastError() { return lastError; }
export function findDuplicateGroups_ORIG(families) {
    const parent = new Map();
    const find = (x) => {
        let r = x;
        while (parent.get(r) !== r)
            r = parent.get(r);
        // דחיסת-נתיב
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
    for (const f of families)
        parent.set(f.id, f.id);
    const byPhone = new Map();
    const byNameCity = new Map();
    for (const f of families) {
        for (const p of phonesOf(f)) {
            const prev = byPhone.get(p);
            if (prev)
                union(prev, f.id);
            else
                byPhone.set(p, f.id);
        }
        const nk = nameCityKey(f);
        if (nk) {
            const prev = byNameCity.get(nk);
            if (prev)
                union(prev, f.id);
            else
                byNameCity.set(nk, f.id);
        }
    }
    const groups = new Map();
    for (const f of families) {
        const r = find(f.id);
        (groups.get(r) ?? groups.set(r, []).get(r)).push(f.id);
    }
    return [...groups.values()].filter((g) => g.length >= 2);
}
export function findDuplicateGroups(families, __opt = {}) {
    const base = findDuplicateGroups_ORIG(families);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
