// חוט · unit-label — שם מונה-הפריט במודול-העין, מותאם-ארגון (פורט-Dart ידני).
// חוזה: new/atoms/unit-label.contract.md · מקור: new/atoms/unit-label.mjs (זהה-ביט).
// השכן termOf הוזרק כשקע (חוק-1 — אפס import פנימי).
dynamic unitLabel(dynamic cfg, dynamic Function(dynamic, String, String) termOf, Map<String, String> T) {
  return termOf(cfg, 'entity.ayinUnit', T['k2']!);
}
