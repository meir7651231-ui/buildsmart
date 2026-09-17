// 🤖 AUTO-EMITTED by gen-max — supHasRegion משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function allSupPhones(sp) {
    const rows = [];
    if (sp.phone)
        rows.push({ num: sp.phone, label: '', note: '', wa: false, region: phoneRegion(sp.phone), primary: true });
    for (const p of sp.phones ?? []) {
        if (!p.num)
            continue;
        rows.push({ num: p.num, label: p.label ?? '', note: p.note ?? '', wa: !!p.wa, region: phoneRegion(p.num), primary: false });
    }
    return rows;
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
export function supHasRegion_ORIG(sp, region) {
    return allSupPhones(sp).some((r) => r.region === region);
}
export function supHasRegion(sp, region, __opt = {}) {
    const base = supHasRegion_ORIG(sp, region);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
