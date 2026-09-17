// 🤖 AUTO-EMITTED by gen-max — cleanApproveUids משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const APPROVE_USERS_CAP = 500;
export function cleanApproveUids_ORIG(input, cap = APPROVE_USERS_CAP) {
    if (!Array.isArray(input)) {
        return { uids: [], error: "uids (string[]) is required." };
    }
    const seen = new Set();
    for (const u of input) {
        if (typeof u !== "string" || u.length === 0) {
            return { uids: [], error: "every uid must be a non-empty string." };
        }
        seen.add(u);
    }
    const uids = [...seen];
    if (uids.length === 0) {
        return { uids: [], error: "uids must contain at least one uid." };
    }
    if (uids.length > cap) {
        return { uids: [], error: `too many uids in one batch (max ${cap}).` };
    }
    return { uids, error: null };
}
export function cleanApproveUids(input, cap, __opt = {}) {
    const base = cleanApproveUids_ORIG(input, cap);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
