// חוט · course-fits-member — התאמת חוג לחבר/ה (מגדר/גיל/כיתה). חוזה: course-fits-member.contract.md
// המרה מ-JS (new/atoms/course-fits-member.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). gradeFits מוזרק כשקע (חוק-1 — אפס import פנימי).
//
// DART-PORTING-RULES כלל-7 (truthiness): `if(x)`/`&&` של JS ≠ Dart. המקור נשען על
// truthy-JS ל-c.gender / gender / c.ageMin / c.ageMax (מחרוזת-ריקה/0/undefined = falsy).
// ⇒ שקע `_truthy` שמחקה נאמנה את truthiness של JS. כלל-2 (null≠undefined):
// המקור משתמש ב-`age != null` הרופף (תופס null+undefined) ⇒ Dart `age != null` (null יחיד) זהה.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

bool courseFitsMember(
    dynamic c, dynamic gender, dynamic age, dynamic grade, dynamic gradeFits) {
  if (_truthy(c['gender']) &&
      c['gender'] != 'all' &&
      _truthy(gender) &&
      c['gender'] != gender) return false;
  if (age != null) {
    if (_truthy(c['ageMin']) && age < c['ageMin']) return false;
    if (_truthy(c['ageMax']) && age > c['ageMax']) return false;
  }
  if (!gradeFits(c, grade)) return false;
  return true;
}
