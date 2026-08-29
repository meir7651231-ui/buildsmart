/// חוט · export-allowed — הכרעת שער-יציאת-המידע: האם ייצוא מותר.
/// חולץ כלשונו מ-maor/src/lib/exportGate.ts:25-32; מצב-המודול `blocked`
/// הוזרק כפרמטר. המרה מ-new/atoms/export-allowed.mjs — התנהגות זהה-לחלוטין (חוק-4).
///
/// המקור: `return !blocked;` — ב-JS `!x` מחזיר bool לפי falsiness של x.
/// כאן `_falsy` מחקה בדיוק את קבוצת-ה-falsy של JS (false/0/-0/NaN/''/null/undefined).
/// אפס import (dart-core בלבד).
bool exportAllowed(dynamic blocked) {
  return _falsy(blocked);
}

/// האם הערך falsy בסמנטיקת-JS (כלל-המרה 7 — truthiness).
/// JS falsy: false, 0, -0, 0n, "", null, undefined, NaN. כל השאר truthy.
bool _falsy(dynamic v) {
  if (v == null) return true; // תופס גם null וגם ה-undefined-שממופה-ל-null ב-Dart
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // אובייקטים/מבנים = תמיד truthy ב-JS
}
