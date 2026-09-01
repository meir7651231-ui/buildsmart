// ⚛️ אטום-Dart (דרגת-חוזה) · netCheckScript — נוסח-בקשה לפתיחת כתובות חסומות.
// מוצא: maor/src/lib/netcheck.ts:105-115 · המקור: new/atoms/net-check-script.mjs (חוזה-Golden).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מקבל רשימת-תוצאות (כל אחת {ok, domain}); מסנן את החסומות (!ok); אם אין —
//        מחזיר מחרוזת-ריקה; אחרת בונה נוסח-בקשה עברי עם שורת-נקודה לכל domain חסום.
// קלט:  List<dynamic> results. פלט: String (נוסח מחובר ב-'\n', או '' כשאין חסומות).
//
// הערות-המרה (מקור→Dart) — לפי machtzev/emit/DART-PORTING-RULES.md:
//  • כלל-2 (null≠undefined): הקלטות-ה-Golden מזינות אלמנטים ללא `ok`/`domain` (Map ללא
//    המפתח, או String). ב-JS גישה-לשדה-חסר ⇒ undefined. משוחזר דרך סנטינל `_jsUndefined`
//    ‏(‏`containsKey` ⇒ undefined כשהמפתח חסר), במקום להשוות `== null`.
//  • כלל-7 (truthiness): `!r.ok` של JS ≠ Dart. שקע `_truthy` מחקה בדיוק את חוקי-ה-truthy
//    של JS (undefined/null/false/0/NaN/''=falsy; אחרת truthy) ⇒ `!truthy` שומר סמנטיקה.
//  • שרשור-מחרוזת: JS `'• ' + r.domain` על undefined ⇒ 'undefined' (מילולי). שקע `_jsConcat`
//    מחזיר 'undefined'/'null'/toString() — נאמן לכפיית-המחרוזת של JS.
//  • `.filter`→`.where`, `.map`→`.map`, spread `...blocked.map`→spread-operator, `.join('\n')`
//    ‏→`.join('\n')`. אין locale/getMonth/מודולו — לוגיקת-מחרוזת-טהורה בלבד.

/// Sentinel standing in for JavaScript `undefined` (a missing property),
/// distinct from Dart `null` (an explicit null value). See porting-rule 2.
const Object _jsUndefined = Object();

/// Read property [key] off [r] the way JS member-access does:
/// present on a Map ⇒ its value; otherwise ⇒ undefined (missing property).
Object? _prop(dynamic r, String key) {
  if (r is Map && r.containsKey(key)) return r[key];
  return _jsUndefined;
}

/// JavaScript truthiness of [v]: undefined/null/false/0/NaN/'' are falsy;
/// every other value (non-empty string, non-zero number, object, list) is truthy.
bool _truthy(Object? v) {
  if (identical(v, _jsUndefined)) return false;
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// JavaScript string coercion under `'...' + v`: undefined→'undefined',
/// null→'null', otherwise `v.toString()`.
String _jsConcat(Object? v) {
  if (identical(v, _jsUndefined)) return 'undefined';
  if (v == null) return 'null';
  return v.toString();
}

/// Verbatim port of new/atoms/net-check-script.mjs (`netCheckScript`).
/// Builds a Hebrew request listing every blocked domain; '' when none are blocked.
String netCheckScript(List<dynamic> results, Map<String, String> T) {
  final blocked = results.where((r) => !_truthy(_prop(r, 'ok'))).toList();
  if (blocked.isEmpty) return '';
  return [
    T['k1']!,
    T['k2']!,
    ...blocked.map((r) => '• ' + _jsConcat(_prop(r, 'domain'))),
    T['k3']!,
  ].join('\n');
}
