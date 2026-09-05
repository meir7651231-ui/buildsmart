// חוט · next-year-dates — הזזת תאריכי-חוג (start/end) שנה קדימה, שומר יום/חודש.
// המרה מ-JS (new/atoms/next-year-dates.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכנים atNoon (פרסור-צהריים) ו-toIso (החזרה ל-ISO) מוזרקים כשקעים (חוק-1 — אפס import פנימי).
// אפס-import (dart-core בלבד).
//
// JS מבצע d.setFullYear(d.getFullYear()+1) על אובייקט-Date (מוטבילי) ⇒ נורמליזציית-גלישה
// (29.2 בשנה לא-מעוברת ⇒ 1.3). ‏DateTime של Dart חסין-שינוי; לכן בונים DateTime חדש עם
// year+1 ואותם רכיבים — הבנאי מנרמל זהה (DateTime(2025,2,29) ⇒ 2025-03-01), משמר את הזהב.
Map<String, String> nextYearDates(
  String start,
  String end,
  DateTime Function(String) atNoon,
  String Function(DateTime) toIso,
) {
  String shift(String iso) {
    final d = atNoon(iso);
    final shifted = DateTime(
      d.year + 1,
      d.month,
      d.day,
      d.hour,
      d.minute,
      d.second,
      d.millisecond,
      d.microsecond,
    );
    return toIso(shifted);
  }

  return {'start': shift(start), 'end': shift(end)};
}
