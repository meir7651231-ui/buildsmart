// חוט · feat-label — שם פיצ'ר-העין מותאם-ארגון (כותרת הלוח/הכרטיס). חוזה: feat-label.contract.md
// המרה מ-JS (new/atoms/feat-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן termOf (מילון-המונחים) מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
// המקור: return termOf(cfg, 'nav.ayin', 'מעקב טיפול') — האטום לא מכריע, כל ההכרעה אצל השקע.
String featLabel(Object? cfg, String Function(Object?, String, String) termOf, Map<String, String> T) {
  return termOf(cfg, 'nav.ayin', T['k2']!);
}
