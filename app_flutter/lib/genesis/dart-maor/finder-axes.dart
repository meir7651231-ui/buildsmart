/// חוט · finder-axes — צירי-הצלילה של מאתר-המשפחות (גלגל-הסינון).
/// המרה נאמנה מ-new/atoms/finder-axes.mjs (חוק-4: המקור קדוש).
/// השכן termOf (מילון-המונחים) מוזרק כשקע-פרמטר (חוק-1: אפס import פנימי).
/// config = מבנה-נתונים דינמי (Map) — האטום לא מפרש אותו, רק מעביר לשקע.
/// פלט: רשימת 9 זוגות [מפתח-ציר, תווית-עברית] בסדר-הקדימות הקבוע של המקור.
List<List<String>> finderAxes(
  Map<String, dynamic> config,
  String Function(Map<String, dynamic> config, String key, String fallback) termOf,
 {required String Function(String) term, required Map<String, String> T}) {
  return [
    ['city', term('ayr')],
    ['comm', term('khylh')],
    ['marital', term('mtsb-mshpchty')],
    ['status', term('sttvs')],
    ['cred', termOf(config, 'entity.cred', T['k11']!)],
    ['kids', term('yldym')],
    ['enrolled', termOf(config, 'nav.courses', T['k16']!)],
    ['sefach', term('spch-mla')],
    ['lang', term('shph')],
  ];
}
