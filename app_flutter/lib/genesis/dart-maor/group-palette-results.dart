// ⚛️ אטום-Dart (דרגת-חוזה) · groupPaletteResults — קיבוץ יציב של תוצאות-פלטה לדליי-סוג + כותרות section.
// מוצא: maor/src/lib/paletteGroups.ts:51-64 · המקור: new/atoms/group-palette-results.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1 — אפס import פנימי): buckets(config)⇒רשימת [prefix,label]; bucketOf(key)⇒אינדקס-דלי.
// קלט: items (רשימת מפות עם 'key'), config, buckets, bucketOf. פלט: רשימת עותקים + 'section'.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · מיון-יציב (כלל 1): המיין `a.b-b.b || a.i-b.i` נושא כבר שובר-שוויון אינדקס-מקורי
//    ⇒ קומפרטור טוטלי ודטרמיניסטי, אי-יציבות-Dart אינה משפיעה.
//  · undefined (כלל 2): `section: undefined` של JS ⇒ ערך null עם מפתח 'section' קיים
//    (המפתח תמיד נכתב מפורשות ⇒ `containsKey('section')` תמיד true, כמו `'section' in g`).
//  · truthiness (כלל 7): `label && label !== last` על מחרוזת ⇒ `label.isNotEmpty && label != last`;
//    `if (label)` ⇒ `if (label.isNotEmpty)`.
//  · אי-מוטביליות: `{...it, section:…}` בונה מפה חדשה — המקור לא משתנה.

/// Stable grouping of palette results into type-buckets with section headers.
/// Verbatim behaviour of the JS source `groupPaletteResults`.
List<Map<String, Object?>> groupPaletteResults(
  List<Map<String, Object?>> items,
  Object? config,
  List<List<String>> Function(Object? config) buckets,
  int Function(Object? key) bucketOf,
) {
  final B = buckets(config);
  // decorate: {it, i (אינדקס-מקורי), b (דלי)}
  final indexed = <Map<String, Object?>>[];
  for (var i = 0; i < items.length; i++) {
    final it = items[i];
    indexed.add({'it': it, 'i': i, 'b': bucketOf(it['key'])});
  }
  // מיון: לפי דלי עולה, ואז אינדקס-מקורי (שובר-שוויון ⇒ יציבות-מקור).
  indexed.sort((a, b) {
    final c = (a['b'] as int) - (b['b'] as int);
    return c != 0 ? c : (a['i'] as int) - (b['i'] as int);
  });
  final out = <Map<String, Object?>>[];
  var lastLabel = '';
  for (final rec in indexed) {
    final it = rec['it'] as Map<String, Object?>;
    final b = rec['b'] as int;
    final label = b < B.length ? B[b][1] : '';
    // שני דליים חולקים כותרת ('nav-'/'act-') — הכותרת לא מוכפלת.
    final section = (label.isNotEmpty && label != lastLabel) ? label : null;
    out.add({...it, 'section': section});
    if (label.isNotEmpty) lastLabel = label;
  }
  return out;
}
