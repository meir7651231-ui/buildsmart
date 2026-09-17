// 🤖 AUTO-EMITTED by gen-max — supLastInBucket משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export export function supLastInBucket(sp, todayIso, bucket, __opt = {}) {
    const base = supLastInBucket_ORIG(sp, todayIso, bucket);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
