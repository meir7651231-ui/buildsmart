/// חוט · integration-on — האם הרחבה פעילה (opt-in: חסר=כבוי).
/// המרה נאמנה מ-new/atoms/integration-on.mjs (חוק-4: המקור קדוש).
/// המקור: cfg.integrations?.[key]?.enabled === true — ניווט-בטוח + השוואת-true בוליאנית מדויקת.
/// המנוע פספס: (א) cfg.integrations[key] בלי שקע-בטוח זורק על מפתח-חסר (JS מחזיר undefined);
/// (ב) == true של Dart אינו ===true — String 'true' חייב להישאר false. שני-אלה מתוקנים כאן.
bool integrationOn(Map? cfg, String key) {
  final integrations = cfg?['integrations'];
  if (integrations is! Map) return false;
  final entry = integrations[key];
  if (entry is! Map) return false;
  // === true בוליאני מדויק: bool true בלבד מדליק; 'true'/null/false ⇒ false.
  return entry['enabled'] == true;
}
