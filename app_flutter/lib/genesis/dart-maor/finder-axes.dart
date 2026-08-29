/// חוט · finder-axes — צירי-הצלילה של מאתר-המשפחות (גלגל-הסינון).
/// המרה נאמנה מ-new/atoms/finder-axes.mjs (חוק-4: המקור קדוש).
/// השכן termOf (מילון-המונחים) מוזרק כשקע-פרמטר (חוק-1: אפס import פנימי).
/// config = מבנה-נתונים דינמי (Map) — האטום לא מפרש אותו, רק מעביר לשקע.
/// פלט: רשימת 9 זוגות [מפתח-ציר, תווית-עברית] בסדר-הקדימות הקבוע של המקור.
List<List<String>> finderAxes(
  Map<String, dynamic> config,
  String Function(Map<String, dynamic> config, String key, String fallback) termOf,
 {required String Function(String) term}) {
  return [
    ['city', term('ayr')],
    ['comm', term('khylh')],
    ['marital', term('mtsb-mshpchty')],
    ['status', term('sttvs')],
    ['cred', termOf(config, 'entity.cred', 'אמינות')],
    ['kids', term('yldym')],
    ['enrolled', termOf(config, 'nav.courses', 'חוגים')],
    ['sefach', term('spch-mla')],
    ['lang', term('shph')],
  ];
}
