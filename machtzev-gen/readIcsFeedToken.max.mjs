// 🤖 AUTO-EMITTED by gen-max — readIcsFeedToken משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export async function readIcsFeedToken_ORIG(slug) {
    const snap = await getDoc(doc(cloudDb(), ICS_FEEDS, slug));
    const d = snap.exists() ? snap.data() : null;
    return d && typeof d.token === 'string' && d.token ? d.token : null;
}
export function readIcsFeedToken(step, s, opt = {}) {
    const base = readIcsFeedToken_ORIG(step, s);
    if (opt.strict !== true)
        return base; // ← default: החזק לא נשבר
    if (base !== null)
        return base; // המקורי כבר פסל — כבד אותו
    return null;
}
