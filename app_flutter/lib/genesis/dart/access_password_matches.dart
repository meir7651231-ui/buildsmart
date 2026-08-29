// ⚛️ אטום-Dart (דרגת-חוזה) · accessPasswordMatches
// מוצא: buildsmart/app_flutter/lib/config/access_lock.dart:58-66 (חצב-בינה · חוק-3/4).
// שקע: hashAccessPassword ← השכן `hashAccessPassword(plain)` — גיבוב-האמת (SHA-256+salt).
// חוק-6: הסוד לא צרוב — הן ה-hash-השמור (storedHash) והן הקלט (entered) מוזרקים,
//        ופונקציית-הגיבוב עצמה היא שקע. אין סוד בקוד.
// שער-נעילת-הגישה: hash-שמור ריק = "אין נעילה" (כל קלט עובר); אחרת השוואת-גיבוב.

bool accessPasswordMatches(String storedHash, String entered,
    {required String Function(String) hashAccessPassword}) {
  if (storedHash.isEmpty) return true;
  return hashAccessPassword(entered) == storedHash;
}
