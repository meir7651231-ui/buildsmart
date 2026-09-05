// ⚛️ אטום-Dart (דרגת-חוזה) · mergeHist — מיזוג היסטוריית-רשומות (existing↔incoming).
// מוצא: maor/src/components/supporters/lib.ts:557-597 · המקור: new/atoms/merge-hist.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). המנוע-האוטומטי החזיר טיוטה-ריקה
//        ⇒ הפורט כולו ידני.
//
// הקלט הוא ערך-JS גולמי (מהקלטות-ה-Golden): existing תמיד מערך; incoming מערך **או
// מחרוזת**. הרשומות עצמן הן אובייקטים או **מחרוזות**. לכן החוט חייב לחקות את
// מודל-הערכים של JS על קלט פתולוגי, לא רק מיזוג-אובייקטים "נקי":
//
// הערות-המרה (מקור→Dart — הנקודות שחייבות דיוק-JS, אחרת סטייה):
//  • גישת-שדה `h.d`/`h.a`/`h.c`: ב-JS על אובייקט⇒הערך-או-undefined; על מחרוזת⇒undefined.
//    ⇒ `_prop` מחזיר סנטינל `_undef` (≠null) כשאין מפתח/כשלא-Map. (כלל-2: null≠undefined.)
//  • `(h.c ?? '₪')`: `??` נתפס ב-null **וב-undefined** ⇒ `_coalesce` (undef||null ⇒ fallback).
//  • שרשור-מפתח `h.d + '|' + …`: undefined ⇒ "undefined" (הצירוף של JS) ⇒ `_jsStr`.
//  • `{...arr[idx], ...h}` — ספרד-אובייקט של JS: מחרוזת מתפזרת לאינדקסים תו-אחר-תו
//    ({0:'2',1:'0',…}); null/undefined/מספר ⇒ ללא-תרומה; המקור-המאוחר גובר-בחפיפה.
//    ⇒ `_spreadInto` (מחרוזת=code-units כמו own-enumerable של JS; length=code-units בשתי-השפות).
//  • **סדר-מפתחות של JSON.stringify**: מפתחות-אינדקס-שלם עולים תחילה, אח"כ מפתחות-מחרוזת
//    בסדר-הכנסה. ⇒ `_canon` מסדר כל מפה בסדר-own-keys של JS ⇒ jsonEncode מייצר-מחדש את הפלט.
//  • `for (const h of incoming)`: מערך⇒איברים; מחרוזת⇒תווים; "" ⇒ אפס-איטרציות ⇒ `_iterate`.
//  • `.sort((x,y)=>x.d.localeCompare(y.d))`: על ≤1 איבר (כל ה-Golden) הרכיב-המשווה
//    לא נקרא; מומש יציב (decorate-sort, כלל-1) לנאמנות על ≥2 איברים.
//  • מוטביליות: כל המפות/רשימות-הביניים final ומוטבלות דרך add/[]= — כמו ב-JS.

/// סנטינל ל-`undefined` של JS (נבדל מ-null; כלל-המרה 2).
const Object _undef = _Undef();

class _Undef {
  const _Undef();
}

/// גישת-שדה בסגנון JS: מפה עם מפתח ⇒ הערך; אחרת (מפתח-חסר / לא-Map) ⇒ `_undef`.
Object? _prop(Object? o, String k) {
  if (o is Map && o.containsKey(k)) return o[k];
  return _undef;
}

/// `a ?? b` של JS — מוחזר [fallback] כש-[v] הוא undefined **או** null.
Object? _coalesce(Object? v, Object? fallback) =>
    (identical(v, _undef) || v == null) ? fallback : v;

/// המרת-ערך-למחרוזת בשרשור של JS (String(v) בהקשר של +).
String _jsStr(Object? v) {
  if (identical(v, _undef)) return 'undefined';
  if (v == null) return 'null';
  if (v is String) return v;
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) {
    if (v is int) return v.toString();
    final d = v.toDouble();
    if (d.isNaN) return 'NaN';
    if (d.isInfinite) return d.isNegative ? '-Infinity' : 'Infinity';
    if (d == d.truncateToDouble() && d.abs() < 1e21) return d.toInt().toString();
    return d.toString();
  }
  return v.toString();
}

/// איטרציית `for..of` של JS: רשימה⇒איברים · מחרוזת⇒תווים (code-units).
List<Object?> _iterate(Object? it) {
  if (it is List) return it;
  if (it is String) {
    final out = <Object?>[];
    for (var i = 0; i < it.length; i++) {
      out.add(String.fromCharCode(it.codeUnitAt(i)));
    }
    return out;
  }
  // ב-JS `for..of` על לא-iterable זורק; אין קלט-כזה ב-Golden.
  throw ArgumentError('not iterable: $it');
}

/// האם מפתח-מחרוזת הוא אינדקס-מערך קנוני של JS (מפתחות-אלה עולים-תחילה בסריקה).
bool _isArrayIndex(String k) {
  if (k.isEmpty || k.length > 10) return false;
  if (k == '0') return true;
  if (k.codeUnitAt(0) == 0x30) return false; // אפס מוביל
  for (var i = 0; i < k.length; i++) {
    final c = k.codeUnitAt(i);
    if (c < 0x30 || c > 0x39) return false;
  }
  final n = int.tryParse(k);
  return n != null && n < 4294967295; // < 2^32-1
}

/// ספרד-אובייקט של JS: הזרקת [source] לתוך [target].
void _spreadInto(Map<String, Object?> target, Object? source) {
  if (identical(source, _undef) || source == null) return; // no-op
  if (source is String) {
    for (var i = 0; i < source.length; i++) {
      target[i.toString()] = String.fromCharCode(source.codeUnitAt(i));
    }
    return;
  }
  if (source is Map) {
    for (final k in _ownKeys(source)) {
      target[k] = source[k];
    }
    return;
  }
  if (source is List) {
    for (var i = 0; i < source.length; i++) {
      target[i.toString()] = source[i];
    }
    return;
  }
  // num/bool וכו' — לפרימיטיב אין own-enumerable ⇒ ללא-תרומה.
}

/// מפתחות-מפה בסדר own-keys של JS: אינדקסי-שלם עולים תחילה, אח"כ מחרוזת בסדר-הכנסה.
List<String> _ownKeys(Map<dynamic, dynamic> m) {
  final ints = <String>[];
  final strs = <String>[];
  for (final k in m.keys) {
    final ks = k.toString();
    if (_isArrayIndex(ks)) {
      ints.add(ks);
    } else {
      strs.add(ks);
    }
  }
  ints.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  return [...ints, ...strs];
}

/// בונה מפה חדשה מהספרד של [sources] בסדר-own-keys של JS (⇒ jsonEncode≡JSON.stringify).
Map<String, Object?> _spreadObj(List<Object?> sources) {
  final tmp = <String, Object?>{};
  for (final s in sources) {
    _spreadInto(tmp, s);
  }
  return _canon(tmp);
}

/// סידור-מחדש רקורסיבי לסדר-own-keys של JS (מפות בלבד מסודרות; ערכים עוברים as-is).
Map<String, Object?> _canon(Map<String, Object?> m) {
  final out = <String, Object?>{};
  for (final k in _ownKeys(m)) {
    final v = m[k];
    out[k] = v is Map<String, Object?> ? _canon(v) : v;
  }
  return out;
}

/// השוואת `localeCompare` (נדרש רק ל-≥2 איברים; לא-מגיע ב-Golden). על מחרוזות ISO
/// ההשוואה הלקסיקוגרפית זהה; שדה-חסר ⇒ 'undefined' (מונע קריסה, מדמה coercion).
int _localeCompare(Object? a, Object? b) => _jsStr(a).compareTo(_jsStr(b));

/// מיזוג היסטוריית-רשומות. פורט מילולי של new/atoms/merge-hist.mjs (`mergeHist`):
/// הצלבה לפי מפתח `d|a|c` — רשומה-קיימת מועשרת מהנכנסת-התואמת (הקיים גובר, הנכנס
/// ממלא חוסרים); מופעים-נכנסים מעבר-לכמות-הקיימת נדחפים כרשומות-חדשות; מיון לפי `d`.
List<Object?> mergeHist(Object? existing, Object? incoming) {
  String key(Object? h) =>
      _jsStr(_prop(h, 'd')) +
      '|' +
      _jsStr(_prop(h, 'a')) +
      '|' +
      _jsStr(_coalesce(_prop(h, 'c'), '₪'));

  // אינדקס-נכנס פר-מפתח (בסדר) — משמש להעשרה וגם לספירה.
  final incByKey = <String, List<Object?>>{};
  for (final h in _iterate(incoming)) {
    final k = key(h);
    final arr = incByKey[k];
    if (arr != null) {
      arr.add(h);
    } else {
      incByKey[k] = [h];
    }
  }

  // העשרה: רשומה-קיימת מתמלאת מהשורה-הנכנסת-התואמת (הקיים גובר; הנכנס ממלא חוסרים).
  final usedInc = <String, int>{};
  final out = (existing as List).map<Object?>((h) {
    final k = key(h);
    final arr = incByKey[k];
    final idx = usedInc[k] ?? 0;
    if (arr != null && idx < arr.length) {
      usedInc[k] = idx + 1;
      return _spreadObj([arr[idx], h]); // נכנס ממלא חוסרים; קיים גובר על חפיפה
    }
    return _spreadObj([h]);
  }).toList();

  // דחיפת מופעים-נכנסים מעבר-לכמות-הקיימת (עסקאות חדשות באמת) — עם כל שדותיהן.
  final haveCount = <String, int>{};
  for (final h in existing) {
    final k = key(h);
    haveCount[k] = (haveCount[k] ?? 0) + 1;
  }
  final seen = <String, int>{};
  for (final h in _iterate(incoming)) {
    final k = key(h);
    final n = (seen[k] ?? 0) + 1;
    seen[k] = n;
    if (n > (haveCount[k] ?? 0)) out.add(_spreadObj([h]));
  }

  // מיון יציב לפי `d` (decorate-sort — כלל-1; הרכיב-המשווה לא-נקרא על ≤1 איבר).
  final decorated = <MapEntry<int, Object?>>[];
  for (var i = 0; i < out.length; i++) {
    decorated.add(MapEntry(i, out[i]));
  }
  decorated.sort((x, y) {
    final c = _localeCompare(_prop(x.value, 'd'), _prop(y.value, 'd'));
    return c != 0 ? c : x.key.compareTo(y.key);
  });
  return [for (final e in decorated) e.value];
}
