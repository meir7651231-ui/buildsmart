// ⚛️ אטום-Dart (דרגת-חוזה) · ayinActionVisible — גלוּת הכפתור-החכם בתיק מעקב-הטיפול.
// מוצא: maor/src/lib/ayin.ts:145-153 · המקור: new/atoms/ayin-action-visible.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: האם מקדם-השלב גלוי. done ⇒ לעולם לא · new ⇒ רק כשיש לפחות שם אחד ·
//        eyes ⇒ רק כשלשם אחד יש כמות (eyes) שאינה '' / null (0 = כמות לגיטימית) ·
//        כל שלב אחר (lead/answer) ⇒ גלוי תמיד.
// שקע (חוק-1): אין — עצמאי מוחלט.
// קלט: a = {stage, names[]} (names: {eyes?, …}). פלט: bool.
//
// הערת-המרה (מקור→Dart): ה-JS משתמש ב-`!== '' && != null` — השוואה עיוורת-לטיפוס.
// ב-Dart `!= ''` על int/null מחזיר true (טיפוסים שונים), `!= null` תופס גם undefined
// של JS (מפתח חסר ⇒ null ב-Map). truthiness לא מעורב — רק שוויון מפורש, כמו במקור.
// אין locale/פורמט/getMonth/מוטביליות.

/// Returns whether the smart stage-advance button of the care-tracking case is
/// visible. Verbatim behaviour of the JS source `ayinActionVisible`.
bool ayinActionVisible(Map<String, dynamic> a) {
  final st = a['stage'];
  if (st == 'done') {
    return false;
  }
  final names = a['names'] as List;
  if (st == 'new') {
    return names.length > 0;
  }
  if (st == 'eyes') {
    return names.any((n) {
      final eyes = (n as Map)['eyes'];
      return eyes != '' && eyes != null;
    });
  }
  return true;
}
