// ⚛️ אטום-Dart (דרגת-חוזה) · allOffConfig — קונפיג-לידה all-off לארגון חדש.
// מוצא: maor/src/components/platform/lib.ts:58-64 · המקור: new/atoms/all-off-config.mjs —
//        `export function allOffConfig(slug, orgName, allModules, defaultConfig) {...}`
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה קונפיג-לידה שבו כל המודולים כבויים (false). השכנים ALL_MODULES ו-DEFAULT_CONFIG
// אינם מיובאים — הם שקעי-הצבה (allModules, defaultConfig) בדיוק כמו במקור-ה-JS (חוק-1).
// קלט:  slug (String) · orgName (String) · allModules (רשימת-מפתחות) · defaultConfig (מפה-בסיס).
// פלט:  מפה חדשה — בסיס-משוכפל + slug/orgName/modules(כולם false)/features:{}/terms:{}.
//
// הערת-המרה (מקור→Dart):
//   • ה-spread `{ ...defaultConfig, slug, ... }` ⇒ `{ ...defaultConfig, 'slug': slug, ... }`.
//     ב-JS וב-Dart כאחד: עדכון מפתח-קיים שומר את מיקום-ההכנסה המקורי ומחליף ערך בלבד
//     (LinkedHashMap ≡ סמנטיקת-object) ⇒ סדר-המפתחות ב-JSON.stringify זהה-ביט.
//   • shorthand של JS (`slug, orgName, modules`) ⇒ זוגות-מפתח מפורשים ב-Dart.
//   • מפה חדשה בכל קריאה ⇒ defaultConfig לא עובר מוטציה, הפלט רפרנס חדשה (טוהר).
//   • אין locale/פורמט/getMonth/truthiness מעורבים; מוטביליות: modules הוא `final` מקומי,
//     נבנה בלולאה בדיוק כמו `const modules = {}` + push שב-JS.

/// Birth config with every module off — verbatim behavior of the JS source
/// new/atoms/all-off-config.mjs. `allModules`/`defaultConfig` are injected sockets
/// (the ALL_MODULES / DEFAULT_CONFIG neighbours), never imported.
Map<String, dynamic> allOffConfig(
  String slug,
  String orgName,
  List<String> allModules,
  Map<String, dynamic> defaultConfig,
) {
  final Map<String, bool> modules = {};
  for (final m in allModules) {
    modules[m] = false;
  }
  return {
    ...defaultConfig,
    'slug': slug,
    'orgName': orgName,
    'modules': modules,
    'features': <String, dynamic>{},
    'terms': <String, dynamic>{},
  };
}
