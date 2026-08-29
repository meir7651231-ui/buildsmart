/// חוט · grade-index — אינדקס כיתה בסולם, סובלני לגרשיים ולקידומת "כיתה".
/// המרה נאמנה מ-new/atoms/grade-index.mjs (חוק-4: המקור קדוש).
/// הקבוע GRADE_ORDER הוזרק כשקע gradeOrder (חוק-1 — אפס import פנימי).
/// truthiness של JS ‏(g || '') / (!clean) ⇒ null-או-ריק מפורש — DART-PORTING-RULES §7.
int gradeIndex(String? g, List<String> gradeOrder) {
  final clean = (g ?? '')
      .replaceAll(RegExp('["\'׳״]'), '')
      .replaceAll(RegExp(r'^כיתה\s*'), '')
      .trim();
  if (clean.isEmpty) return -1;
  return gradeOrder.indexOf(clean);
}
