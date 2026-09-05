// חוט · resolve-enroll-family — פתרון משפחה לשיבוץ-חדש (id קיים / '__new' עם דה-דופ).
// חוזה: ../atoms/resolve-enroll-family.contract.md
// חולץ כלשונו מ-maor/src/components/courses/lib.ts:540-559 (JS→Dart — התנהגות-זהה, חוק-4).
// השכן normName הוזרק כשקע (חוק-1 — אפס import פנימי). אפס import כלל.
//
// כללי-המרה שהוחלו (machtzev/emit/DART-PORTING-RULES.md):
//  · כלל 7 (truthiness): JS `newFamName.trim()` (מחרוזת-truthy) ⇒ `.trim().isNotEmpty`.
//  · זהות-אובייקט: JS `find`/`===` מחזיר את אותה ההפניה מהמערך — כאן מוחזר אותו Map
//    מ-`families`, כך ש-identical(fam, families[i]) נשמר (רתמת-הזהב בודקת ב-identical).

const String enrollNewFamily = '__new';

Map<String, dynamic> resolveEnrollFamily(
  List<Map<String, dynamic>> families,
  String famSel,
  String newFamName,
  String Function(String) normName,
) {
  // families.find((f) => f.id === famSel)
  Map<String, dynamic>? existing;
  for (final f in families) {
    if (f['id'] == famSel) {
      existing = f;
      break;
    }
  }
  if (existing != null) {
    return {'fam': existing, 'create': false};
  }
  // '__new' + שם לא-ריק אחרי trim (JS truthiness ⇒ isNotEmpty)
  if (famSel == enrollNewFamily && newFamName.trim().isNotEmpty) {
    // families.find((f) => normName(f.name) === normName(newFamName))
    Map<String, dynamic>? dup;
    for (final f in families) {
      if (normName(f['name'] as String) == normName(newFamName)) {
        dup = f;
        break;
      }
    }
    if (dup != null) {
      return {'fam': dup, 'create': false};
    }
    return {'fam': null, 'create': true};
  }
  return {'fam': null, 'create': false};
}
