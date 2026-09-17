// 🤖 AUTO-EMITTED by gen-max — softClashSuffix משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function findDuplicateGroups(families) {
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
export function softClashSuffix_ORIG(events, date, time, excludeId) {
    if (!date || !time)
        return '';
    const other = events.find((ev) => ev.id !== excludeId && !ev.done && ev.date === date && ev.time === time);
    return other ? ' · ⚠ התנגשות עם "' + other.title + '" בשעה ' + time : '';
}
export function softClashSuffix(events, date, time, excludeId, __opt = {}) {
    const base = softClashSuffix_ORIG(events, date, time, excludeId ?  : );
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
