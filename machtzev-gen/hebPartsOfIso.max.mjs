// 🤖 AUTO-EMITTED by gen-max — hebPartsOfIso (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const hpCacheShared = new Map();
const HP_CACHE_MAX = 3000;
function hebParts(d) {
    if (isNaN(d.getTime()))
        return { day: 0, month: '', year: 0 }; // תאריך לא-חוקי → חלקים בטוחים (מונע RangeError ב-formatToParts)
    const parts = fmtParts.formatToParts(d);
    const get = (t) => parts.find((p) => p.type === t)?.value ?? '';
    return { day: +get('day'), month: get('month'), year: +get('year') };
}
function gem(n) {
    n = Math.floor(+n);
    if (!Number.isFinite(n) || n <= 0)
        return ''; // מונע פלט "undefined" מאינדקסים שליליים/שבורים
    const U = ['', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'];
    const T = ['', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ'];
    const H = ['', 'ק', 'ר', 'ש', 'ת', 'תק', 'תר', 'תש', 'תת', 'תתק'];
    let s = H[Math.floor(n / 100)] || '';
    const r = n % 100;
    if (r === 15)
        s += 'טו';
    else if (r === 16)
        s += 'טז';
    else
        s += T[Math.floor(r / 10)] + U[r % 10];
    return s.length === 1 ? s + '׳' : s.slice(0, -1) + '״' + s.slice(-1);
}
const fmtHM = new Intl.DateTimeFormat('he-u-ca-hebrew', { month: 'long' });
function gemYear(y) {
    return gem(+y % 1000);
}
const fmtHY = new Intl.DateTimeFormat('he-u-ca-hebrew', { year: 'numeric' });
const fmtParts = new Intl.DateTimeFormat('en-u-ca-hebrew', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
});
export function hebPartsOfIso_ORIG(iso) {
    let hp = hpCacheShared.get(iso);
    if (!hp) {
        if (hpCacheShared.size >= HP_CACHE_MAX)
            hpCacheShared.clear();
        hp = hebParts(new Date(iso.slice(0, 10) + 'T12:00:00'));
        hpCacheShared.set(iso, hp);
    }
    return hp;
}
function hebDateFull(iso) {
    if (!iso)
        return '';
    const d = new Date(iso.slice(0, 10) + 'T12:00:00');
    if (isNaN(d.getTime()))
        return '';
    return `${gem(hebParts(d).day)} ${fmtHM.format(d)} ${gemYear(fmtHY.format(d))}`;
}
export function hebPartsOfIso(iso) { return hebPartsOfIso_ORIG(iso); }
export function hebPartsOfIso_fromSource(iso) { return hebPartsOfIso_ORIG(hebDateFull(iso)); }
