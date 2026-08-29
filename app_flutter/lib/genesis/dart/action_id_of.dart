// ⚛️ אטום-Dart (דרגת-חוזה) · actionIdOf
// תפקיד: חילוץ מזהה-פעולה (String) ממפה-op מפוענחת — או null אם אין.
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:287-302 (‏_actionIdOf; פרטי-במקור; חוק-4).
// אחים: אין — פונקציה עצמאית, אפס שקע.
// טוהר: dart:core בלבד.

/// m['action'] אם String לא-ריק (מקוצץ) ⇒ אותו טקסט;
/// אם Map עם 'kind' String לא-ריק ⇒ ה-kind (מקוצץ); אחרת null. verbatim edit_intent.dart:287-302.
String? actionIdOf(Map<String, dynamic> m) {
  final a = m['action'];
  if (a is String) {
    final t = a.trim();
    return t.isEmpty ? null : t;
  }
  if (a is Map) {
    final k = a['kind'];
    if (k is String && k.trim().isNotEmpty) return k.trim();
  }
  return null;
}
