// ⚛️ אטום-Dart (דרגת-חוזה) · effectiveConfigFor — קונפיג אפקטיבי לעובד/ת
// (הגבלה-בלבד + הדלקות-בסט). מוצא: maor/src/components/platform/lib.ts:205-220
// (ORGADMIN — "לב האכיפה בממשק"; קריאות-השכן שוקעו). המקור:
//        new/atoms/effective-config-for.mjs — חולץ כלשונו, קריאות-השכן שוקעו לשקעים.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// תפקיד: מנהל ⇒ קונפיג-הארגון כמו-שהוא (אותה רפרנס). אחרת — קונפיג-הארגון בניכוי
//        מה שכובה בכרטיס-העובד (false=כיבוי; חסר=יורש). חריג: מפתח בסט-ההדלקות
//        (grantable) שסומן true בכרטיס — מדליק פר-עובד; לכל שאר ה-true מתעלמים.
// שקעים (חוק-1): isOrgManager(email, org)→bool · overrideOf(email, org)→כרטיס-עובד
//        {modules?, features?} · grantable: Set של מפתחות-הדלקה-פר-עובד.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · === של JS ⇒ identical ב-Dart (החזרת אותה רפרנס למנהל/בלי-כרטיס).
//  · truthiness (כלל 7): `!ov.modules` של JS ⇒ שקע `_truthy` מפורש. אובייקט-ריק {}
//    truthy ב-JS ⇒ לא-מפעיל את קיצור-הדרך; מפתח-חסר/null falsy ⇒ מפעיל.
//  · `v === false` / `v === true` ⇒ `v == false` / `v == true` (null ≠ false/true ב-Dart).
//  · spread `{...orgConfig.modules}` ⇒ Map.from (עותק-רדוד ⇒ הקלט לא משתנה, טוהר).
//  · undefined של JS (מפתח-חסר) ⇒ מפתח שלא-נוסף ב-Dart (containsKey==false).
//  אין locale/פורמט/getMonth/תאריך-מגלגל/substring באטום הזה.

/// JS truthiness proxy: falsy = null, false, 0, '', NaN; everything else truthy
/// (an empty Map/List is truthy, matching JS `{}`/`[]`).
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Effective config for a staff member. Verbatim behaviour of the JS source
/// `effectiveConfigFor`: manager (or no override card) ⇒ the org config itself
/// (same reference); otherwise a new config = org config minus what the member
/// card turned off, plus per-member grants for keys in [grantable].
Map<String, dynamic> effectiveConfigFor(
  String email,
  Map<String, dynamic> org,
  Map<String, dynamic> orgConfig,
  bool Function(String email, Map<String, dynamic> org) isOrgManager,
  Map<String, dynamic> Function(String email, Map<String, dynamic> org) overrideOf,
  Set<String> grantable,
) {
  if (isOrgManager(email, org)) return orgConfig;

  final ov = overrideOf(email, org);
  // JS: if (!ov.modules && !ov.features) return orgConfig;  (truthiness)
  if (!_truthy(ov['modules']) && !_truthy(ov['features'])) return orgConfig;

  // modules = { ...orgConfig.modules }; then apply only false (turn-off).
  final modules = Map<String, dynamic>.from((orgConfig['modules'] as Map?) ?? {});
  final ovModules = (ov['modules'] as Map?) ?? {};
  for (final entry in ovModules.entries) {
    if (entry.value == false) modules[entry.key as String] = false;
  }

  // features = { ...orgConfig.features }; false ⇒ off, true+grantable ⇒ on.
  final features = Map<String, dynamic>.from((orgConfig['features'] as Map?) ?? {});
  final ovFeatures = (ov['features'] as Map?) ?? {};
  for (final entry in ovFeatures.entries) {
    final k = entry.key as String;
    final v = entry.value;
    if (v == false) {
      features[k] = false;
    } else if (v == true && grantable.contains(k)) {
      features[k] = true; // הדלקה פר-עובד
    }
  }

  // return { ...orgConfig, modules, features };
  final result = Map<String, dynamic>.from(orgConfig);
  result['modules'] = modules;
  result['features'] = features;
  return result;
}
