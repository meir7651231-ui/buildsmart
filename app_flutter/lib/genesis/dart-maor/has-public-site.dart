// ⚛️ אטום-Dart (דרגת-חוזה) · hasPublicSite — האם להציג אתר-ציבורי.
// מוצא: maor/src/lib/publicSite.ts:242-244 · המקור: new/atoms/has-public-site.mjs —
//        `return !!config.site && config.site.enabled !== false;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: יש תוכן `site` בקונפיג *ולא* כובה במפורש. חוזה-הדגלים של maor:
//        מפתח חסר = פעיל, רק `false` ממש מכבה.
// שקע (חוק-1): config — אובייקט-הקונפיג (עם/בלי שדה `site`). פלט: bool.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES §7 truthiness):
//   • `!!config.site` — אמת-JS: null/undefined/0/""/NaN שקריים, אובייקט אמיתי.
//     ⇒ `_truthy` מפורש שמחקה אמת-JS (‏v==null ב-Dart תופס גם undefined-הנעדר).
//   • `config.site.enabled !== false` — אי-שוויון-קפדני: רק בוליאני false-ממש מכבה.
//     גישה ל-`.enabled` על לא-אובייקט ב-JS = undefined (⇒ null ב-Dart) ⇒ ‏!==false ⇒ true.
//     ‏Dart `!= false` בין טיפוסים-שונים = true (0!=false, null!=false) — מקביל ל-‏!==false כאן.
//   • אין locale/פורמט/getMonth/מוטביליות.

/// מחקה את אמת-ה-JS (truthiness): null/undefined/0/-0/NaN/"" שקריים, השאר אמת.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Returns whether the org's public site should be shown: a truthy `site` object
/// that is not explicitly disabled (`enabled !== false`). Verbatim behaviour of
/// the JS source `hasPublicSite`.
bool hasPublicSite(Map config) {
  final site = config['site'];
  if (!_truthy(site)) return false;
  final enabled = site is Map ? site['enabled'] : null;
  return enabled != false;
}
