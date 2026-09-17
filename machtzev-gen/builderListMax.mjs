function groupFeatures(feats) {
    const labelOf = (f) => {
        const parts = f.key.split('.');
        return parts.length >= 3 ? (SUBGROUP_LABELS[parts[1]] ?? null) : null;
    };
    const counts = {};
    for (const f of feats) {
        const l = labelOf(f);
        if (l)
            counts[l] = (counts[l] ?? 0) + 1;
    }
    const groups = [];
    const at = {};
    const general = { label: null, items: [] };
    for (const f of feats) {
        const l = labelOf(f);
        if (l && counts[l] >= 2) {
            if (!at[l]) {
                at[l] = { label: l, items: [] };
                groups.push(at[l]);
            }
            at[l].items.push(f);
        }
        else
            general.items.push(f);
    }
    return general.items.length ? [general, ...groups] : groups;
}
const SUBGROUP_LABELS = {
    punch: '🎟️ כרטיסיות',
    printout: '🖨 תדפיסים ודוחות',
    enroll: '📝 שיבוץ',
    absence: '🕐 חיסורים והשלמות',
    makeup: '🕐 חיסורים והשלמות',
    attendance: '🕐 חיסורים והשלמות',
    receipt: '🧾 קבלות',
    ayin: '🗂 מעקב-טיפול ופרויקטים',
    cred: '⭐ אמינות',
    hok: '🔁 הוראות-קבע',
};
export function builderListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        groupFeatures: (() => { try {
            return groupFeatures(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { groupFeatures };
