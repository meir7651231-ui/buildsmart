// 🤖 AUTO-EMITTED by gen-max — monthLabel (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function fmtDate(iso) {
    if (!iso)
        return '';
    const [y, m, d] = iso.slice(0, 10).split('-');
    if (!y || !m || !d)
        return iso; // קלט פגום → מוחזר כמו-שהוא (בלי "undefined/undefined/..")
    return `${d}/${m}/${y}`;
}
export function monthLabel_ORIG(key) {
    const [y, m] = key.split('-');
    return `${m}/${y}`;
}
function rangeLabel(r) {
    if (!r.from && !r.to)
        return 'כל התאריכים';
    if (r.from && r.to)
        return `${fmtDate(r.from)} – ${fmtDate(r.to)}`;
    return r.from ? 'מ-' + fmtDate(r.from) : 'עד ' + fmtDate(r.to);
}
export function monthLabel(key) { return monthLabel_ORIG(key); }
export function monthLabel_fromSource(r) { return monthLabel_ORIG(rangeLabel(r)); }
