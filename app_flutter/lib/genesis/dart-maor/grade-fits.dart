/// חוט · grade-fits — התאמת כיתה לחוג (סינון רך — מידע חסר אינו מסנן).
/// המרה נאמנה מ-new/atoms/grade-fits.mjs (חוק-4: המקור קדוש).
/// השכן gradeIndex הוזרק כשקע (חוק-1 — אפס import פנימי).
/// c ממודל כ-Map<String,String?> (gradeMin/gradeMax אופציונליים); היעדר-מפתח=null.
/// truthiness של JS ‏(!c.gradeMin) ⇒ שקע `_falsy` (null או ריק) — DART-PORTING-RULES §7.
bool gradeFits(
  Map<String, String?> c,
  String? childGrade,
  int Function(String?) gradeIndex,
) {
  final gradeMin = c['gradeMin'];
  final gradeMax = c['gradeMax'];
  if (_falsy(gradeMin) && _falsy(gradeMax)) return true;
  final gi = gradeIndex(childGrade);
  if (gi < 0) return true;
  final lo = gradeIndex(gradeMin);
  final hi = gradeIndex(gradeMax);
  if (lo >= 0 && gi < lo) return false;
  if (hi >= 0 && gi > hi) return false;
  return true;
}

bool _falsy(String? v) => v == null || v.isEmpty;
