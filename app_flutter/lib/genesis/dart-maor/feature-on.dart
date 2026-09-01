/// חוט · feature-on — חוזה-הדגלים: מפתח חסר = פעיל, רק false מכבה, שרשור-אבות מלא.
/// המרה נאמנה מ-new/atoms/feature-on.mjs (חוק-4: המקור קדוש).
/// חולץ כלשונו מ-maor/src/lib/config.ts:40-52. השכן moduleOn והקבוע
/// NAV_MODULE_KEYS הוזרקו כשקעים (חוק-1 + חוק-5 — אפס import פנימי).
///
/// שקעים: navModuleKeys (מפתחות מודולי-הניווט) · moduleOn(cfg, moduleKey)⇒bool.
/// cfg = מילון עם features? (מילון דגלים). רק ערך-false מכבה — חסר/true = פעיל
/// (מקביל ל-`=== false` המחמיר של המקור; null/חסר ≠ false).
bool featureOn(
  Map<String, dynamic> cfg,
  String key,
  List<String> navModuleKeys,
  bool Function(Map<String, dynamic> cfg, String moduleKey) moduleOn,
) {
  final parts = key.split('.');
  final features = cfg['features'] as Map?;
  // כל דגל-אב (וכן הדגל עצמו) שכבוי במפורש (false בלבד) — מכבה את הצאצא.
  for (var i = 1; i <= parts.length; i++) {
    final flag = parts.sublist(0, i).join('.');
    if (features != null && features[flag] == false) {
      return false;
    }
  }
  // מודול-הניווט (הקידומת הראשונה) כבוי — מכבה את כל הדגלים תחתיו.
  final prefix = parts.isNotEmpty ? parts[0] : '';
  if (navModuleKeys.contains(prefix) && !moduleOn(cfg, prefix)) {
    return false;
  }
  return true;
}
