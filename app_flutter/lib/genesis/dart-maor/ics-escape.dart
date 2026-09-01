// חוט · ics-escape — בריחת-תווים ל-iCalendar (RFC5545). חוזה: ics-escape.contract.md
// המרה מ-JS (new/atoms/ics-escape.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). RegExp/replaceAll הם dart:core.
// truthiness (כלל-המרה 7): JS (s||'') → null/'' נהיים '' ; String? עם ?? '' מחקה זאת.
// סדר-ההחלפות קדוש: backslash ראשון, כדי שהבקסלאשים שנוספו אח"כ לא יוכפלו.
String icsEscape(String? s) {
  return (s ?? '')
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll(RegExp(r'\r?\n'), '\\n');
}
