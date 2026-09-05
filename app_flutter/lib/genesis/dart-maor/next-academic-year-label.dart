// חוט · next-academic-year-label — תווית שנת-הלימודים העברית הבאה. חוזה: next-academic-year-label.contract.md
// המרה מ-JS (new/atoms/next-academic-year-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכנים atNoon (פרסור-צהריים) · gemYear (גימטריית-שנה) · hebPartsOfIso (חלקי-תאריך-עברי)
// מוזרקים כשקעים (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
String nextAcademicYearLabel(
  String startIso,
  DateTime Function(String) atNoon,
  String Function(int) gemYear,
  ({int year}) Function(String) hebPartsOfIso,
) {
  if (startIso.isEmpty) return ''; // JS: if(!startIso) — מחרוזת ריקה = falsy.
  final d = atNoon(startIso);
  // JS getMonth() 0-אינדקס (ספט׳=8); Dart month 1-אינדקס ⇒ month-1.
  final yy = (d.month - 1) >= 8 ? d.year : d.year - 1;
  // "השנה הבאה" = הוסף שנה עברית אחת (31.12 של השנה הלועזית הבאה).
  return gemYear(hebPartsOfIso('${yy + 1}-12-31').year);
}
