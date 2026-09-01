// ⚛️ אטום-Dart (דרגת-חוזה) · publicSiteOn — האם האתר-הציבורי פעיל לארגון.
// מוצא: המקור new/atoms/public-site-on.mjs (חולץ מ-maor/src/lib/config.ts:637-641).
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן featureOn = שקע-פרמטר (חוק-1).
//
// המקור:  featureOn(cfg,'shell.publicsite') && !!cfg.site && cfg.site.enabled !== false
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//  • גישת-שכן `cfg.site` ב-JS = גישת-מפתח על-אובייקט; ב-Dart cfg הוא Map ⇒ `cfg['site']`
//    (המנוע פספס: השאיר `.site` — NoSuchMethodError על Map). שקע featureOn מוזרק כפרמטר.
//  • `!!cfg.site` = truthiness של JS ⇒ שקע `_truthy` מפורש (כלל-7): null/undefined⇒false,
//    אובייקט⇒true. (המנוע נתן `_falsy(_falsy(...))` על פונקציה בלתי-מוגדרת — הוחלף.)
//  • `cfg.site.enabled !== false` ⇒ `cfg['site']['enabled'] != false`. ב-Dart `null != false`
//    = true (enabled חסר⇒פעיל) ו-`false != false` = false — זהה ל-`!==` בדומיין-החוזה.
//  • קיצור-חישוב: `&&` של Dart מקצר בדיוק כמו JS ⇒ site לא נבדק כשהדגל כבוי (דוגמה 6).
//  • מוטביליות: אין var מוקצה-מחדש; פונקציה טהורה.

/// Is the public site active for the org: the `shell.publicsite` flag is on
/// AND `site` content exists AND it is not explicitly disabled
/// (`enabled != false` — missing means active; flag-contract: only false disables).
/// Verbatim port of new/atoms/public-site-on.mjs. `featureOn` is an injected socket.
bool publicSiteOn(
  dynamic cfg,
  bool Function(dynamic cfg, String key) featureOn,
) {
  return featureOn(cfg, 'shell.publicsite') &&
      _truthy(cfg['site']) &&
      cfg['site']['enabled'] != false;
}

/// JS-truthiness for the `!!cfg.site` guard (kept minimal, matches JS falsy set).
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
