// 🔧 AUTO-FIXED by gen-max — makeupEligibility: קבועי-קסם חולצו לפרמטר-opts (ברירת-מחדל=מקורי ⇒ אפס-אובדן). אל תערוך ביד.
export function makeupEligibility_ORIG(kind, justified, rawHrs) {
    if (kind === 'noshow')
        return { eligible: false, dropsPunch: true };
    const earlyCancel = rawHrs != null && rawHrs >= 48;
    const eligible = justified || earlyCancel;
    return { eligible, dropsPunch: !eligible };
}
export function makeupEligibility(kind, justified, rawHrs, opts = {}) {
    if (kind === 'noshow')
        return { eligible: false, dropsPunch: true };
    const earlyCancel = rawHrs != null && rawHrs >= (opts.k0 ?? 48);
    const eligible = justified || earlyCancel;
    return { eligible, dropsPunch: !eligible };
}
