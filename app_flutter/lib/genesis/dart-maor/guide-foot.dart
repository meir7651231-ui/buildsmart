// אטום-קבוע · guide-foot — קודם אוטומטית (צילום-ערך). חוזה: guide-foot.contract.md
// המרה מ-JS (new/atoms/guide-foot.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). מרכאות-כפולות בגוף ⇒ תוחם יחיד (בלי escaping).
const String guideFoot =
    'המדריך המלא והמפורט נמצא בקובץ "מדריך למשתמש" — מסך-מסך וכפתור-כפתור.';

/// החלפת תת-מחרוזת גלובלית (בלי regex) — לתרגום מונחי-ישות בגוף השורות.
/// מראה נאמן ל-JS `s.split(from).join(to)`.
String swap(String s, String from, String to) {
  return s.split(from).join(to);
}
