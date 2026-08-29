// חוט · academic-year-label — תווית שנה"ל מתאריך-פתיחה (1.9). חוזה: academic-year-label.contract.md
// המרה מ-JS (new/atoms/academic-year-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן atNoon (פרסור-צהריים) מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
String academicYearLabel(String startIso, DateTime Function(String) atNoon) {
  final d = atNoon(startIso);
  final y = d.year;
  // JS getMonth() 0-אינדקס: ספט׳=8; Dart month 1-אינדקס: ספט׳=9.
  final startYear = d.month >= 9 ? y : y - 1;
  final nn = ((startYear + 1) % 100).toString().padLeft(2, '0');
  return '$startYear/$nn';
}
