// 🤖 AUTO-EMITTED by gen-max — sanitizeIncoming משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const LIST_FIELDS = {
    families: ['members', 'docs'],
    enrollments: ['payments', 'absences'],
    supporters: ['donations'],
    // קופות צדקה — ריקונים ולוג ניקוד (BUILD-ORDER-TZEDAKA)
    tzBoxes: ['collections'],
    tzCoordinators: ['scoreLog'],
    // חנות — רכיבי מוצר, מימושים וקריטריונים (BUILD-ORDER-SHOP)
    shopProducts: ['components'],
    shopAssignments: ['redemptions', 'criterionIds'],
    // רשימת ההמתנה על הפריט (SHOP6 חנות 27)
    shopItems: ['waits'],
};
export function sanitizeIncoming_ORIG(col, item) {
    const fields = LIST_FIELDS[col];
    if (!fields)
        return item;
    let out = item;
    for (const f of fields) {
        if (!Array.isArray(out[f]))
            out = { ...out, [f]: [] };
    }
    return out;
}
export function sanitizeIncoming(step, s, opt = {}) {
    const base = sanitizeIncoming_ORIG(step, s);
    if (opt.strict !== true)
        return base; // ← default: החזק לא נשבר
    if (base !== null)
        return base; // המקורי כבר פסל — כבד אותו
    return null;
}
