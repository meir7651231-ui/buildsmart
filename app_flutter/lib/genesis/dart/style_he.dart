// ⚛️ אטום-Dart (דרגת-חוזה) · styleHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:184-195 (‏_styleHe; חוק-4).
//        פרטי-במקור (`_`) — גולגל לאטום top-level; אח-שסוקט: `_colorHe` (תיעוד בלבד בטיוטה).
// אחים-שהוזרקו (חוק-3): `style?.colorToken` (טיפוס-שכן-קטן `CfgStyle`, נקרא רק דרך `.colorToken`)
//        ⇒ שקע `colorToken` (String?); `registry.allowedValues(id,'color')` ⇒ שקע `allowedValues`;
//        הפונקציה-השכנה `_colorHe` ⇒ שקע `colorHe`. הליטרל `'color'` נשמר verbatim.
//
// קלט:  id            — מזהה-האלמנט (String).
//       colorToken    — שקע: הטוקן-הצבע מ-CfgStyle (null = אין).
//       allowedValues — שקע: (id, attr) ⇒ ערכים-מותרים מהרישום.
//       colorHe       — שקע: טוקן-צבע ⇒ שם-עברי (מדרדר לעצמו).
// פלט:  אין-טוקן ⇒ 'שינוי עיצוב: id'. יש-טוקן שהרישום מאשר ⇒ 'שינוי צבע: id ← <עברית>'.
//        יש-טוקן שהרישום לא-מאשר ⇒ 'שינוי צבע: id' (בלי החץ).

/// Hebrew preview line for a style change. Precise ("← color name") ONLY when the
/// registry vouches for the token; unknown/unvouched degrades gracefully.
/// Verbatim behaviour of diff_preview.dart:184-195 with the registry read, the
/// `CfgStyle.colorToken` field, and `_colorHe` injected as slots.
String styleHe(
  String id, {required String Function(String) term, 
  required String? colorToken,
  required List<String> Function(String id, String attr) allowedValues,
  required String Function(String) colorHe,
}) {
  final token = colorToken;
  if (token == null) return '${term('shynvy-aytsvb')}$id';
  // §10 — precise only when the registry vouches for the token (skip when unknown).
  if (allowedValues(id, 'color').contains(token)) {
    return '${term('shynvy-tsba')}$id ← ${colorHe(token)}';
  }
  return '${term('shynvy-tsba')}$id';
}
