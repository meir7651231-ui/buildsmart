// ⚛️ אטום-Dart (דרגת-חוזה) · finderAxisValue — ערך-המשפחה בציר-צלילה נתון.
// מוצא: maor/src/components/families/lib.ts:102-118 · המקור: new/atoms/finder-axis-value.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכנים termOf/tierOf/
//        famLiveEnrollments/STATUS_META הוזרקו כשקעים (חוק-1/חוק-3).
//
// תפקיד: switch על 9 צירים ⇒ תווית-עברית. city/comm/lang = השדה או '' ·
//        marital = השדה או 'לא ידוע' · status = STATUS_META[status].label ·
//        cred = tierOf(score ?? 700).label · kids = 'עם ילדים'/'בלי ילדים' ·
//        enrolled = 'משתתפות ב<מונח>'/'לא משתתפות' · sefach = 'קיים'/'חסר' ·
//        ציר לא-מוכר ⇒ ''.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס, DART-PORTING-RULES):
//  • truthiness (כלל 7): `f.city || ''` של JS מחליף גם מחרוזת-ריקה בברירת-המחדל
//    (בניגוד ל-`??` שתופס null בלבד). ⇒ `_orStr` שמחקה `||` לתחום-מחרוזות
//    (מחרוזת לא-ריקה ⇒ עצמה, אחרת ה-fallback). כך city='' ⇒ '' ו-marital='' ⇒ 'לא ידוע'
//    בדיוק כמו JS. `!m.isParent` ו-`f.fullSefach ?` הם בדיקות-אמת ⇒ `_truthy`.
//  • `config ?` (truthiness): null/undefined ⇒ fallback; {} ⇒ termOf. `config != null`
//    מבחין נכון (null ⇒ fb · {} לא-null ⇒ termOf).
//  • `f.cred?.score ?? 700`: optional-chaining על cred + `??` שתופס null בלבד (0 נשמר).
//  • `famLiveEnrollments(...).length ?` (מספר-truthy: 0=false) ⇒ `.isNotEmpty`.
//  • מוטביליות: כל המקומיים final; אין locale/פורמט/getMonth.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/NaN/false ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// חיקוי `v || fb` של JS למחרוזות: מחרוזת לא-ריקה ⇒ עצמה, אחרת ה-fallback
/// (מחרוזת-ריקה/null/undefined ⇒ fb — זהה ל-`||`, בניגוד ל-`??`).
String _orStr(dynamic v, String fb) => (v is String && v.isNotEmpty) ? v : fb;

/// Family's value on a given drill axis — Hebrew labels, verbatim to the JS source.
/// Neighbour calls termOf/tierOf/famLiveEnrollments/STATUS_META injected as sockets
/// (Law 1/3). Verbatim behaviour of new/atoms/finder-axis-value.mjs (`finderAxisValue`).
String finderAxisValue(
  dynamic db,
  Map<String, dynamic> f,
  String axis,
  dynamic config, {
  required String Function(dynamic config, String key, String fallback) termOf,
  required Map<String, dynamic> Function(num score) tierOf,
  required List<dynamic> Function(dynamic db, Map<String, dynamic> f)
      famLiveEnrollments,
  required Map<String, dynamic> STATUS_META, required Map<String, dynamic> T2}) {
  String T(String k, String fb) => (config != null) ? termOf(config, k, fb) : fb;
  switch (axis) {
    case 'city':
      return _orStr(f['city'], '');
    case 'comm':
      return _orStr(f['community'], '');
    case 'marital':
      return _orStr(f['maritalStatus'], (T2['k4'] as String));
    case 'status':
      return (STATUS_META[f['status']] as Map)['label'] as String;
    case 'cred':
      final cred = f['cred'] as Map<String, dynamic>?;
      final score = cred?['score'] ?? 700;
      return tierOf(score as num)['label'] as String;
    case 'kids':
      return (f['members'] as List)
              .any((m) => !_truthy((m as Map)['isParent']))
          ? (T2['k8'] as String)
          : (T2['k9'] as String);
    case 'enrolled':
      return famLiveEnrollments(db, f).isNotEmpty
          ? (T2['k11'] as String) + T('nav.courses', (T2['k13'] as String))
          : (T2['k14'] as String);
    case 'sefach':
      return _truthy(f['fullSefach']) ? (T2['k16'] as String) : (T2['k17'] as String);
    case 'lang':
      return _orStr(f['language'], '');
    default:
      return '';
  }
}
