// חוט · caller-kind-label — תווית-סוג-המתקשר דרך מילון-המונחים. חוזה: caller-kind-label.contract.md
// המרה מ-JS (new/atoms/caller-kind-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן termOf מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
// סוג לא-מוכר: המקור נופל מה-switch ומחזיר undefined ⇒ ב-Dart null (String?).
String? callerKindLabel(dynamic cfg,
  String kind,
  String Function(dynamic cfg, String key, String fb) termOf, Map<String, String> T) {
  switch (kind) {
    case 'family':
      return termOf(cfg, 'entity.family', T['k3']!);
    case 'member':
      return termOf(cfg, 'entity.member', T['k6']!);
    case 'supporter':
      return termOf(cfg, 'entity.supporter', T['k9']!);
    case 'volunteer':
      return termOf(cfg, 'entity.volunteer', T['k12']!);
    case 'coordinator':
      return termOf(cfg, 'entity.tzCoordinator', T['k15']!);
  }
  return null;
}
