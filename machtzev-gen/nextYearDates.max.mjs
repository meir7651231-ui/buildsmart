// 🤖 AUTO-EMITTED by gen-max — nextYearDates (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function atNoon(iso) {
    return new Date(`${iso}T12:00:00`);
}
function academicYearLabel(startIso) {
    if (!startIso)
        return '';
    const d = atNoon(startIso);
    // מתי חלה ה-31.12 שבתוך שנת-הלימודים הזאת:
    // חוג שנפתח 1.9.2026 (September=8) ⇒ 31.12.2026 = תוך-השנה, שיין ל-תשפ״ז.
    // חוג שנפתח 1.3.2026 (March=2) ⇒ שנת-הלימודים ההיא נפתחה 1.9.2025 ⇒ 31.12.2025.
    const yy = d.getMonth() >= 8 ? d.getFullYear() : d.getFullYear() - 1;
    return gemYear(hebPartsOfIso(`${yy}-12-31`).year);
}
export function nextYearDates(start, end) { return nextYearDates_ORIG(start, end); }
export function nextYearDates_fromSource(startIso, end) { return nextYearDates_ORIG(academicYearLabel(startIso), end); }
