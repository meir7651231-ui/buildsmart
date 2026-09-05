/// חוט · integration-setting — הגדרת-הרחבה כמחרוזת (trim, אחרת '').
/// המרה נאמנה מ-new/atoms/integration-setting.mjs (חוק-4: המקור קדוש).
/// המקור: cfg.integrations?.[key]?.[field] ⇒ מחרוזת-trim, אחרת ''.
/// המנוע הפיק גישת-שדה (cfg.integrations[key]) — שהיא ניווט-Map ב-Dart:
/// כל שכבה שאינה Map ⇒ '' (מקביל ל-optional-chaining שמחזיר undefined ⇒ '').
/// עצמאי — אפס import, אפס שקעים.
String integrationSetting(dynamic cfg, String key, String field) {
  final integrations = cfg is Map ? cfg['integrations'] : null;
  final entry = integrations is Map ? integrations[key] : null;
  final v = entry is Map ? entry[field] : null;
  return v is String ? v.trim() : '';
}
