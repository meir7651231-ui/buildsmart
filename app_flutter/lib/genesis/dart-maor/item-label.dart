/// חוט · item-label — שם פריט-בודד-למעקב במודול-העין, מותאם-ארגון.
/// המרה נאמנה מ-new/atoms/item-label.mjs (חוק-4: המקור קדוש).
/// חולץ כלשונו מ-maor/src/lib/ayin.ts:40-42 (תורגם TS→JS→Dart).
/// השכן termOf (מילון-מונחי-הארגון) מוזרק כשקע-פרמטר (חוק-1: אפס import פנימי).
String itemLabel(Map<String, dynamic> cfg,
  String Function(Map<String, dynamic> cfg, String key, String fallback) termOf, Map<String, String> T) {
  return termOf(cfg, 'entity.ayinItem', T['k2']!);
}
