// ⚛️ אטום-Dart (דרגת-חוזה) · supDonEvents — מיזוג תרומות+היסטוריה לרשימת-תצוגה
// ממוינת מהחדש לישן. מוצא: maor/src/components/supporters/lib.ts:261-296 ·
// המקור: new/atoms/sup-don-events.mjs · חוזה: new/atoms/sup-don-events.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import של אטום-שכן (חוק-3). השכן termOf הוזרק
//        כשקע term(key, fallback) אופציונלי (חוק-1) — לא-מוזרק ⇒ ה-fallback העברי כמות-שהוא.
//
// 🔧 תיקון-הסגר (חוק-18): ‏num.tryParse של Dart גוזם רווחי-יוניקוד (‏U+0085 NEL, ‏U+180E)
//    בעצמו — גם אחרי `_jsTrim` נאמן-ES — ולכן פרסר מחרוזת-pays כמו '2' ל-2 בעוד
//    ‏Number('2')===NaN ב-JS. התוצאה: "N תשלומים" מזויף. **התיקון:** אימות-דקדוק-
//    מספר-ES (regex) חייב-להתאים-במלואו לפני tryParse — כל שארית-תו (כולל NEL) ⇒ NaN.
//    זהה לספריית-התאימות המאומתת (jsStrToNum, machtzev/emit/js-compat-reference.dart).
//
// תפקיד: תרומות-עם-קבלה ("קבלה R-N") + שורות hist עם מטא-דאטת-סליקה (שדות-קיימים
//        בלבד, ' · '), וכשאין hist — שורות first/last בסכום 0, רק אם תאריכן חדש.
//        הכרעת-בעלים 19.8: ‏hist עם clearer ⇒ "תרומה" (דרך השקע); בלעדיו ⇒ "מהקובץ ההיסטורי".

/// זקיף-undefined פנימי: מבחין מפתח-חסר (undefined של JS) מ-null מפורש (חוק-2).
const Object _undefined = #_supDonEventsUndefined;

/// גישת-שדה נאמנת-JS: מפה עם המפתח ⇒ הערך; מפתח-חסר / לא-Map ⇒ זקיף-undefined.
Object? _prop(Object? o, String k) =>
    (o is Map && o.containsKey(k)) ? o[k] : _undefined;

/// מקביל-ביט ל-truthiness של JS: undefined/null/''/0/-0/false/NaN = כוזב, השאר = אמת.
bool _jsTruthy(Object? v) {
  if (identical(v, _undefined) || v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// String(num) של JS (חוק-12): int ⇒ עשרוני · NaN/±Infinity כלשונם · -0⇒'0' ·
/// double שלם סופי <1e21 ⇒ פריסת-Dart העשרונית-המלאה בלי הסיומת '.0'.
String _jsNumStr(num v) {
  if (v is int) return v.toString();
  final d = v as double;
  if (d.isNaN) return 'NaN';
  if (d.isInfinite) return d > 0 ? 'Infinity' : '-Infinity';
  if (d == 0) return '0'; // גם -0.0 — JS: String(-0)==='0'
  final s = d.toString();
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

/// מקביל-ביט ל-String(v) של JS (שרשור/join/מיון): undefined⇒'undefined' · null⇒'null' ·
/// מחרוזת⇒עצמה · מספר⇒`_jsNumStr` · bool⇒'true'/'false' · אחר⇒toString.
String _jsStr(Object? v) {
  if (identical(v, _undefined)) return 'undefined';
  if (v == null) return 'null';
  if (v is String) return v;
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) return _jsNumStr(v);
  return v.toString();
}

/// trim בקבוצת-הרווחים של ECMAScript בדיוק (חוק-16): **בלי** ‏U+0085 (NEL) ו-U+180E
/// שאותם String.trim של Dart כן גוזם.
String _jsTrim(String s) {
  bool ws(int c) =>
      c == 0x09 || c == 0x0A || c == 0x0B || c == 0x0C || c == 0x0D ||
      c == 0x20 || c == 0xA0 || c == 0x1680 ||
      (c >= 0x2000 && c <= 0x200A) ||
      c == 0x2028 || c == 0x2029 || c == 0x202F || c == 0x205F ||
      c == 0x3000 || c == 0xFEFF;
  var a = 0, b = s.length;
  while (a < b && ws(s.codeUnitAt(a))) a++;
  while (b > a && ws(s.codeUnitAt(b - 1))) b--;
  return s.substring(a, b);
}

/// ToNumber של JS (חוק-15/18) לצורך ההשוואה-המקרצת: num⇒עצמו · bool⇒1/0 · null⇒0 ·
/// undefined/אחר⇒NaN · מחרוזת: ‏trim-ES; ריק⇒0; ‏±Infinity; ‏0x/0o/0b; אחרת **דקדוק-ES
/// קפדני חייב-להתאים-במלואו לפני tryParse** — אחרת NaN (חוק-18: tryParse גוזם NEL בעצמו).
num _jsToNum(Object? v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return 0;
  if (v is String) {
    final t = _jsTrim(v);
    if (t.isEmpty) return 0;
    if (t == 'Infinity' || t == '+Infinity') return double.infinity;
    if (t == '-Infinity') return double.negativeInfinity;
    if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(t)) {
      return int.parse(t.substring(2), radix: 16);
    }
    if (RegExp(r'^0[oO][0-7]+$').hasMatch(t)) {
      return int.parse(t.substring(2), radix: 8);
    }
    if (RegExp(r'^0[bB][01]+$').hasMatch(t)) {
      return int.parse(t.substring(2), radix: 2);
    }
    // 🔧 חוק-18: דקדוק עשרוני-ES חייב-להתאים-במלואו — כל שארית-תו (כולל NEL/U+180E
    //    ש-tryParse היה גוזם) ⇒ NaN, נאמן ל-Number(str) של JS.
    if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(t)) {
      return double.nan;
    }
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan; // undefined-זקיף / אובייקטים (בלי valueOf) ⇒ NaN
}

/// ‏`v > 1` של JS: ‏ToNumber על לא-מספר; ‏NaN ⇒ false (גם ב-Dart: nan>1 == false).
bool _jsGt1(Object? v) => _jsToNum(v) > 1;

/// ‏`a !== b` בהיפוכו: שוויון-ערך של JS על ערכי-שדה (זקיף-undefined קבוע ⇒ זהות;
/// מחרוזות/מספרים ⇒ ==; ‏NaN!=NaN בשתי-השפות).
bool _strictEq(Object? a, Object? b) {
  if (identical(a, _undefined) || identical(b, _undefined)) {
    return identical(a, b);
  }
  if (a is num && b is num) return a == b; // NaN==NaN ⇒ false, כמו ===
  return a == b;
}

/// זקיף-הפלט מנורמל ל-null בשורות המוחזרות (ייצוג-Dart המוסכם ל-undefined).
Object? _deUndef(Object? v) => identical(v, _undefined) ? null : v;

/// מיזוג כל אירועי-הכסף של תומכת לרשימת-תצוגה אחת, ממוינת מהחדש לישן.
/// התנהגות זהה-ביט למקור-ה-JS `supDonEvents` (new/atoms/sup-don-events.mjs).
List<Map<String, dynamic>> supDonEvents(dynamic sp,
    [dynamic Function(String key, String fallback)? term]) {
  // ‏const T = (k, fb) => (term ? term(k, fb) : fb) — פונקציה תמיד truthy ב-JS.
  dynamic T(String k, String fb) => term != null ? term(k, fb) : fb;

  // ‏(sp.donations || []) — מערך-ריק truthy ב-JS; רק ערך-כוזב נופל ל-[].
  final donationsRaw = _prop(sp, 'donations');
  final donations = _jsTruthy(donationsRaw) ? donationsRaw as List : const [];
  final out = <Map<String, dynamic>>[];
  for (final d in donations) {
    final cur = _prop(d, 'cur');
    out.add({
      'date': _prop(d, 'date'),
      'amount': _prop(d, 'amount'),
      'cur': _jsTruthy(cur) ? cur : '₪',
      'src': 'קבלה ' + _jsStr(_prop(d, 'rid')),
      'rid': _prop(d, 'rid'),
    });
  }

  final histRaw = _prop(sp, 'hist');
  final hist = _jsTruthy(histRaw) ? histRaw as List : const [];
  for (final h in hist) {
    // 13.8 — פירוט מטא-דאטת-הסליקה בשורת-ההיסטוריה (רק שדות שקיימים).
    final receipt = _prop(h, 'receipt');
    final txn = _prop(h, 'txn');
    final ref = _prop(h, 'ref');
    final brand = _prop(h, 'brand');
    final last4 = _prop(h, 'last4');
    final clearer = _prop(h, 'clearer');
    final pays = _prop(h, 'pays');
    final status = _prop(h, 'status');
    // ‏[x && 'טקסט'+x, …].filter(Boolean) ⇒ collection-if על truthiness;
    // ‏join של JS ממחרז איברים-לא-מחרוזת דרך String(v) ⇒ map(_jsStr).
    final metaParts = <Object?>[
      if (_jsTruthy(receipt)) 'קבלה ' + _jsStr(receipt),
      if (_jsTruthy(txn)) 'עסקה ' + _jsStr(txn),
      if (_jsTruthy(ref)) 'אסמכתא ' + _jsStr(ref),
      if (_jsTruthy(brand)) brand,
      if (_jsTruthy(last4)) '•' + _jsStr(last4),
      if (_jsTruthy(clearer)) clearer,
      if (_jsTruthy(pays) && _jsGt1(pays)) _jsStr(pays) + ' תשלומים',
      if (_jsTruthy(status)) status,
    ];
    final meta = metaParts.map(_jsStr).join(' · ');
    // הכרעת-בעלים 19.8: רשומה עם clearer ⇒ "תרומה" (דרך השקע); בלעדיו ⇒ "מהקובץ ההיסטורי".
    final label = _jsTruthy(clearer) ? T('entity.donation', 'תרומה') : 'מהקובץ ההיסטורי';
    final c = _prop(h, 'c');
    out.add({
      'date': _prop(h, 'd'),
      'amount': _prop(h, 'a'),
      'cur': _jsTruthy(c) ? c : '₪',
      // ‏label + (meta ? ' · '+meta : '') — meta-ריק כוזב; label מקורץ-למחרוזת בצירוף.
      'src': _jsStr(label) + (meta.isNotEmpty ? ' · ' + meta : ''),
    });
  }

  // ‏!(sp.hist || []).length — אורך-אפס כוזב ⇒ שורות first/last רק כשאין hist כלל.
  if (hist.isEmpty) {
    final seen = <Object?>{for (final x in out) x['date']}; // Set = SameValueZero
    final first = _prop(sp, 'first');
    final last = _prop(sp, 'last');
    if (_jsTruthy(first) && !seen.contains(first)) {
      out.add({
        'date': first,
        'amount': 0,
        'cur': '',
        'src': _jsStr(T('entity.donation', 'תרומה')) + ' ראשונה (מהקובץ)',
      });
    }
    if (_jsTruthy(last) && !_strictEq(last, first) && !seen.contains(last)) {
      out.add({
        'date': last,
        'amount': 0,
        'cur': '',
        'src': _jsStr(T('entity.donation', 'תרומה')) + ' אחרונה (מהקובץ)',
      });
    }
  }

  // ‏sort((a,b)=>String(b.date).localeCompare(String(a.date))) — desc; ‏Array.sort יציב
  // ⇒ decorate באינדקס-מקורי כשובר-שוויון (List.sort של Dart אינו-יציב ל-≥32).
  final idx = <int>[for (var i = 0; i < out.length; i++) i];
  idx.sort((ia, ib) {
    final c = _jsStr(out[ib]['date']).compareTo(_jsStr(out[ia]['date']));
    return c != 0 ? c : ia - ib;
  });
  return <Map<String, dynamic>>[
    for (final i in idx)
      {for (final e in out[i].entries) e.key: _deUndef(e.value)},
  ];
}
