// 🤖 AUTO-EMITTED by gen-max — academicYearLabel (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function atNoon(iso) {
    return new Date(`${iso}T12:00:00`);
}
export function academicYearLabel_ORIG(startIso) {
    if (!startIso)
        return '';
    const d = atNoon(startIso);
    // מתי חלה ה-31.12 שבתוך שנת-הלימודים הזאת:
    // חוג שנפתח 1.9.2026 (September=8) ⇒ 31.12.2026 = תוך-השנה, שיין ל-תשפ״ז.
    // חוג שנפתח 1.3.2026 (March=2) ⇒ שנת-הלימודים ההיא נפתחה 1.9.2025 ⇒ 31.12.2025.
    const yy = d.getMonth() >= 8 ? d.getFullYear() : d.getFullYear() - 1;
    return gemYear(hebPartsOfIso(`${yy}-12-31`).year);
}
function nextAcademicYearLabel(startIso) {
    if (!startIso)
        return '';
    const d = atNoon(startIso);
    const yy = d.getMonth() >= 8 ? d.getFullYear() : d.getFullYear() - 1;
    // "השנה הבאה" = הוסף שנה עברית אחת (31.12 של השנה הלועזית הבאה).
    return gemYear(hebPartsOfIso(`${yy + 1}-12-31`).year);
}
export function academicYearLabel(startIso) { return academicYearLabel_ORIG(startIso); }
export function academicYearLabel_fromSource(startIso) { return academicYearLabel_ORIG(nextAcademicYearLabel(startIso)); }
