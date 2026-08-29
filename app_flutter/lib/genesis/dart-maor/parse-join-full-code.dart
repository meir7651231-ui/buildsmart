// ⚛️ אטום-Dart (דרגת-חוזה) · parseJoinFullCode — פירוק "קוד מהבוס" {slug}.{code}
// מוצא: maor/src/components/platform/lib.ts:113-123 (חוק-4 — התנהגות זהה למקור-ה-JS,
//        לא-משופרת). המקור: new/atoms/parse-join-full-code.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). השכן isValidSlug
//        הוזרק כשקע-פרמטר (חוק-1 — קריאה-לשכן לא-מיובאת).
//
// תפקיד: פירוק קוד-הזמנה מלא בצורת `{slug}.{code}` ל-{slug, code}. הנקודה הראשונה
//        מפרידה; הסלאג עובר trim+lowercase; הקוד שומר-רישיות; צורה לא-תקינה ⇒ null.
// קלט:  full — מחרוזת (String); isValidSlug — שקע bool Function(String).
// פלט:  Map<String,String>{'slug','code'} או null.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • המנוע פלט `t.sublist(...)` — שגוי ל-String; ‏JS `slice` על מחרוזת ⇒ Dart `substring`.
//   • ‏JS `!code` (truthiness, כלל-7) על מחרוזת ⇒ `code.isEmpty` (הקוד תמיד String אחרי trim).
//   • ‏dot<=0 מטפל גם ב-indexOf==-1 (אין נקודה) וגם ב-==0 (נקודה בתחילה) — זהה ל-JS.
//   • ‏substring(dot+1): dot<=0 כבר חסם, ולכן dot+1 בטווח [1..length] — אין substring-שלילי (כלל-5).

/// Parses a full join code `{slug}.{code}` into `{slug, code}`, or `null` when
/// malformed. The first dot separates; the slug is trimmed + lowercased and must
/// pass the injected [isValidSlug]; the code is trimmed and must be non-empty and
/// keeps its case. Verbatim behaviour of the JS source
/// new/atoms/parse-join-full-code.mjs.
Map<String, String>? parseJoinFullCode(
  String full,
  bool Function(String) isValidSlug,
) {
  final t = full.trim();
  final dot = t.indexOf('.');
  if (dot <= 0) return null;
  final slug = t.substring(0, dot).trim().toLowerCase();
  final code = t.substring(dot + 1).trim();
  if (!isValidSlug(slug) || code.isEmpty) return null;
  return {'slug': slug, 'code': code};
}
