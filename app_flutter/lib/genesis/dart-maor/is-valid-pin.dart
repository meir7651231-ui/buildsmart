// ⚛️ אטום-Dart · isValidPin — PIN תקין = 4–8 ספרות. מקור: is-valid-pin.mjs, חוק-4.
// המקור: /^\d{4,8}$/.test(pin) — JS מכפה כל קלט למחרוזת (ToString) לפני הבדיקה.
// לכן שיקוף-נאמן דורש כפיית-מחרוזת בסגנון-JS (מערך⇒join, אובייקט⇒"[object Object]"),
// לא Dart .toString() (שמוסיף סוגריים למערך/מפה — סטייה מהמקור, כלל-המרה 7 truthiness/coercion).
bool isValidPin(dynamic pin) {
  return RegExp(r'^\d{4,8}$').hasMatch(_jsCoerce(pin));
}

String _jsCoerce(dynamic v) {
  if (v == null) return 'null'; // String(null) — RegExp.test(null) ⇒ "null"
  if (v is String) return v;
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) return _jsNum(v);
  if (v is List) return v.map(_jsArrayElem).join(','); // Array.prototype.join(',')
  return '[object Object]'; // מפה/אובייקט רגיל
}

// איבר-מערך: null/undefined ⇒ '' (סמנטיקת Array.join), אחרת כפיית-מחרוזת רגילה.
String _jsArrayElem(dynamic v) => v == null ? '' : _jsCoerce(v);

// String(number) של JS: שלם ⇒ בלי נקודה עשרונית; אחרת ייצוג עשרוני.
String _jsNum(num v) {
  if (v is int) return v.toString();
  if (v.isFinite && v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}
