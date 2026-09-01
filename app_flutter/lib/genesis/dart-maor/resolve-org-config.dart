// 🔌 חוט-Dart (דרגת-חוזה) · resolveOrgConfig — מיזוג-עדיפויות ענן > סטטי > ברירת-מחדל.
// מוצא: maor/src/lib/config.ts:803-810 · המקור: new/atoms/resolve-org-config.mjs —
//        `export function resolveOrgConfig(staticCfg, cloudRaw, normalizeConfig) {...}`
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: קונפיג-הענן גובר, אך ה-slug נשאר של הכתובת (staticCfg.slug) ו-firebase
// נשמר מהסטטי כשהענן לא מגדיר. cloudRaw לא-שמיש (השקע מחזיר falsy) ⇒ הסטטי
// כמות-שהוא — **אותה-רפרנס**, אפס-שינוי (ratchet, ערבות-חוזה 1).
// normalizeConfig הוא שקע-הצבה (raw)⇒cfg|null — לעולם לא מיובא (חוק-1).
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//   • חוק-7 (truthiness): `if (!cloud)` של JS ⇒ עוזר `_falsy` מפורש
//     (null / false / 0 / NaN / '' — בדיוק ששת ה-falsy של JS פרט ל-undefined,
//     ש-null של Dart מכסה). כך גם `!merged.firebase && staticCfg.firebase`.
//   • ה-spread `{ ...cloud, slug: staticCfg.slug }` ⇒ העתקת-מפה שומרת-סדר
//     (LinkedHashMap ≡ סמנטיקת-object) + הצבת slug: מפתח-קיים מוחלף-במקומו,
//     מפתח-חסר מתווסף-בסוף — זהה ל-JS בשני המקרים.
//   • `merged.firebase` על מפתח-חסר: JS ⇒ undefined (falsy), Dart ⇒ null (falsy)
//     — אותו ענף בשני העולמות; ההצבה `merged['firebase'] = ...` משמרת-מיקום
//     כשקיים ומוסיפה-בסוף כשחסר, כמו ב-JS (אין צורך ב-containsKey — כלל-2
//     רלוונטי רק כשמבחינים null-מפורש מ-חסר, וכאן שניהם falsy).
//   • השדות מועברים by-reference (העתקה רדודה) — כמו spread של JS: merged.firebase
//     היא אותה-רפרנס של staticCfg.firebase כשנשלמה מהסטטי.
//   • אין locale/תאריך/מספר-למחרוזת — כללים 3/4/6/9/10/12 לא-רלוונטיים.

/// ‏falsy של JS: null (מכסה גם undefined) · false · 0 · NaN · מחרוזת-ריקה.
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // אובייקטים/מערכים/פונקציות — תמיד truthy ב-JS
}

/// Cloud-over-static org-config merge — verbatim behavior of the JS source
/// new/atoms/resolve-org-config.mjs. `normalizeConfig` is an injected socket
/// ((raw) => cfg|null — the sanitizer neighbour), never imported.
dynamic resolveOrgConfig(
  dynamic staticCfg,
  dynamic cloudRaw,
  dynamic Function(dynamic) normalizeConfig,
) {
  final cloud = normalizeConfig(cloudRaw);
  if (_falsy(cloud)) return staticCfg; // ענן לא-שמיש ⇒ בדיוק staticCfg (אותה-רפרנס)
  final merged = <String, dynamic>{};
  (cloud as Map).forEach((k, v) => merged[k as String] = v); // ‎{...cloud}‎ שומר-סדר
  merged['slug'] = staticCfg['slug']; // ה-slug תמיד של הכתובת
  if (_falsy(merged['firebase']) && !_falsy(staticCfg['firebase'])) {
    merged['firebase'] = staticCfg['firebase']; // credentials מקונפיג-השורש
  }
  return merged;
}
