// חוט · need-label — תווית-תצוגה לצורך-ארגוני לפי מזהה. חוזה: need-label.contract.md
// המרה מ-JS (new/atoms/need-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן ORG_NEEDS מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
// המנוע פספס: firstWhere זורק כשאין-התאמה (JS .find מחזיר undefined ⇒ ?.label ?? id);
// וגישה n.id/n.label על Map = n['id']/n['label'].
String needLabel(String id, List<Map<String, String>> orgNeeds) {
  for (final n in orgNeeds) {
    if (n['id'] == id) return n['label'] ?? id;
  }
  return id;
}
