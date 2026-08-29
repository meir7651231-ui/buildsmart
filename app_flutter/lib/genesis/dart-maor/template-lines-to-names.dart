/// חוט · template-lines-to-names — שורות-תבנית (שם·כמות·מחיר) ⇒ פריטי-BOQ חדשים,
/// עם מזהים מסופק-המזהים המוזרק (nextId — שקע, פרמטר כבר במקור).
/// חוזה: template-lines-to-names.contract.md
/// המרה זהת-ביט מ-new/atoms/template-lines-to-names.mjs. אפס import של אטום אחר.
///
/// המקור (maor/src/lib/ayin.ts:126-144):
///   lines.filter((l) => (l.name || '').trim())
///        .map((l, i) => ({ id: nextId(i), name: l.name.trim(),
///          eyes: +l.qty || 0, done: false,
///          ...(l.rate > 0 ? { rate: l.rate } : {}) }));
///
/// תיקון-ההסגר: הערך המחושב (eyes/rate) נשאר במרחב-float64 של JS (חוק-17).
/// הבאג היה בשכבת-ההשוואה (הרתמה): `_jsNumJson` של-הסוכן המיר double-שלם ל-int
/// רק כשקטן מ-int64, ולערך [9.2e18,1e21) נפל ל-toString עם ".0"/מדעי ⇒ סטה
/// מ-JSON.stringify. התיקון: הבדיקה מסדרת מספרים דרך `_jsStr` המאומת (חוק-12).
/// המנוע עצמו כאן נכון — פונקציה-טהורה זהת-ביט. חוק-1: כל עוזר INLINE בקידומת _.

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim). **בלי** U+0085/U+180E
/// (ש-Dart.trim גוזם אך JS לא). WhiteSpace + LineTerminator של ES.
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680, //
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// חוק-16 · trim נאמן-ES (String.prototype.trim). גוזם רק את _esWs.
String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

/// חוק-7 · truthiness של JS: ''/0/-0/NaN/null/false כוזבים; השאר אמת.
bool _jsTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// חוקים 10+18 · ToNumber של JS על מחרוזת, דקדוק-ES קפדני **לפני** פרסינג
/// (‏Dart tryParse גוזם רווחי-יוניקוד בעצמו). מחזיר double (NaN על קלט-רע).
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0.0; // Number('') === 0
  if (s == 'Infinity' || s == '+Infinity') return double.infinity;
  if (s == '-Infinity') return double.negativeInfinity;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(s)) {
    return _fromRadix(s.substring(2), 16);
  }
  if (RegExp(r'^0[oO][0-7]+$').hasMatch(s)) return _fromRadix(s.substring(2), 8);
  if (RegExp(r'^0[bB][01]+$').hasMatch(s)) return _fromRadix(s.substring(2), 2);
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) {
    return double.nan;
  }
  return double.tryParse(s) ?? double.nan;
}

double _fromRadix(String digits, int radix) {
  try {
    return BigInt.parse(digits, radix: radix).toDouble();
  } catch (_) {
    return double.nan;
  }
}

/// חוק-10/17 · ToNumber כללי (כל טיפוס), במרחב-float64 של JS.
/// null≡undefined בהקשר-מספר ⇒ NaN (כמו +undefined). מחרוזת ⇒ דקדוק-ES.
double _jsNum(dynamic v) {
  if (v == null) return double.nan;
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}

/// שורות-תבנית ⇒ פריטי-BOQ: ‏qty→eyes (float64; שבור/אפס⇒0 דרך `|| 0`) ·
/// ‏done:false · ‏rate רק כשחיובי (מפתח-חסר, לא null — חוק-2; הערך המקורי
/// verbatim, לא מומר) · ריקי-שם מסולקים · ‏i של nextId = האינדקס אחרי הסינון.
List<dynamic> templateLinesToNames(dynamic lines, dynamic nextId) {
  final out = <dynamic>[];
  var i = 0;
  for (final l in (lines as List)) {
    // filter: (l.name || '').trim() truthy
    final nameVal = (l as Map)['name'];
    final rawName = _jsTruthy(nameVal) ? (nameVal as String) : '';
    if (_jsTrim(rawName).isEmpty) continue;
    // eyes: +l.qty || 0  (float64; 0/-0/NaN ⇒ 0)
    final q = _jsNum(l['qty']);
    final num eyes = (q.isNaN || q == 0) ? 0 : q;
    final item = <String, dynamic>{
      'id': nextId(i),
      'name': _jsTrim(rawName),
      'eyes': eyes,
      'done': false,
    };
    // ...(l.rate > 0 ? { rate: l.rate } : {})  — הערך המקורי, לא מומר
    if (_jsNum(l['rate']) > 0) item['rate'] = l['rate'];
    out.add(item);
    i++;
  }
  return out;
}
