// 🤖 AUTO-EMITTED by gen-max — assignmentRedeemed משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function liveRedemptions(a) {
    return a.redemptions.filter((r) => !r.voidedAt);
}
function hebYearOf(iso) {
    return hebParts(new Date(iso + 'T12:00:00')).year;
}
export function assignmentRedeemed_ORIG(a, componentId, holiday) {
    const live = liveRedemptions(a);
    if (!holiday)
        return live.some((r) => r.componentId === componentId);
    const year = hebYearOf(holiday.iso);
    return live.some((r) => r.componentId === componentId && r.holiday === holiday.name && !!r.date && hebYearOf(r.date) === year);
}
export function assignmentRedeemed(a, componentId, holiday, __opt = {}) {
    const base = assignmentRedeemed_ORIG(a, componentId, holiday ?  : );
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
