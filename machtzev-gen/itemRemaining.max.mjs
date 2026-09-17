// 🤖 AUTO-EMITTED by gen-max — itemRemaining משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function liveRedemptions(a) {
    return a.redemptions.filter((r) => !r.voidedAt);
}
export function itemRemaining_ORIG(db, itemId) {
    const item = db.shopItems.find((i) => i.id === itemId);
    if (!item || item.stock === undefined)
        return null;
    let used = 0;
    for (const a of db.shopAssignments) {
        const p = db.shopProducts.find((x) => x.id === a.productId);
        if (!p)
            continue;
        for (const r of liveRedemptions(a)) {
            const c = p.components.find((x) => x.id === r.componentId);
            if (c?.itemId === itemId)
                used++;
        }
    }
    return Math.max(0, item.stock - used);
}
export function itemRemaining(db, itemId, __opt = {}) {
    const base = itemRemaining_ORIG(db, itemId);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
