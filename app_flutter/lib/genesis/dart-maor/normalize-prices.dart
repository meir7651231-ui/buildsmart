// ⚛️ אטום-Dart (דרגת-חוזה) · normalizePrices — נרמול טבלת-מחירים לא-אמינה לטבלה מלאה.
// מוצא: maor/src/lib/pricing.ts:122-151 · המקור: new/atoms/normalize-prices.mjs. חוזה: normalize-prices.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — התנהגות זהה-ביט למקור-JS.
//        השכנים ALL_MODULES/DEFAULT_PRICES/DEFAULT_INTEGRATION_PRICES מוזרקים כשקעים (חוק-1/5).
//
// הערות-המרה (JS→Dart):
//  • `raw && typeof raw === 'object'` ⇒ `raw is Map` (List/null אינם Map; מפה-ריקה כברירת-מחדל).
//  • `typeof v==='number' && Number.isFinite(v) && v>=0` ⇒ `v is num && v.isFinite && v>=0`
//    (int/double שניהם num; NaN/Infinity ⇒ isFinite=false, זהה ל-Number.isFinite).
//  • `base.modules?.[m]` (optional-chaining) ⇒ `(base['modules'] is Map ? base['modules'][m] : null)`.
//  • `DEFAULT_PRICES.modules[m] ?? 0` ⇒ `defaultPrices['modules'][m] ?? 0` (null/חסר ⇒ 0).
//  • הטיפוסים נשמרים כמות-שהם (v או fb) ⇒ jsonEncode זהה ל-JSON.stringify (int→"1", double 1.6→"1.6").
Map<String, dynamic> normalizePrices(
  dynamic raw,
  List<String> allModules,
  Map<String, dynamic> defaultPrices,
  Map<String, dynamic> defaultIntegrationPrices,
) {
  final base = raw is Map ? raw : const <dynamic, dynamic>{};
  num numOr(dynamic v, num fb) => (v is num && v.isFinite && v >= 0) ? v : fb;

  dynamic sub(String key) => base[key] is Map ? base[key] as Map : null;

  final dp = defaultPrices;
  final dpModules = dp['modules'] as Map;
  final dpSize = dp['sizeMult'] as Map;
  final dpEnt = dp['enterprise'] as Map;

  final modules = <String, dynamic>{};
  final baseModules = sub('modules');
  for (final m in allModules) {
    modules[m] = numOr(baseModules?[m], (dpModules[m] ?? 0) as num);
  }

  final integrations = <String, dynamic>{};
  final baseIntegrations = sub('integrations');
  for (final k in defaultIntegrationPrices.keys) {
    integrations[k] = numOr(baseIntegrations?[k], defaultIntegrationPrices[k] as num);
  }

  final baseSize = sub('sizeMult');
  final baseEnt = sub('enterprise');
  return {
    'base': numOr(base['base'], dp['base'] as num),
    'modules': modules,
    'integrations': integrations,
    'sizeMult': {
      'small': numOr(baseSize?['small'], dpSize['small'] as num),
      'medium': numOr(baseSize?['medium'], dpSize['medium'] as num),
      'large': numOr(baseSize?['large'], dpSize['large'] as num),
    },
    'setup': numOr(base['setup'], dp['setup'] as num),
    'enterprise': {
      'oneTime': numOr(baseEnt?['oneTime'], dpEnt['oneTime'] as num),
      'annualMaintenance': numOr(baseEnt?['annualMaintenance'], dpEnt['annualMaintenance'] as num),
    },
  };
}
