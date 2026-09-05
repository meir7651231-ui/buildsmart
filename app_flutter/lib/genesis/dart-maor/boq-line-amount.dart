// חוט · boq-line-amount — סכום שורת כתב-כמויות. חוזה: boq-line-amount.contract.md
// המרה מ-JS (new/atoms/boq-line-amount.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// המקור: (+n.eyes || 0) * (n.rate || 0). n = מפת-שדות {eyes, rate}.
// שעתוק נאמן: +eyes = המרת-JS (Number) עם ||0-אמת; rate עם ||0-אמת; ה-* ממיר.
// אפס-import (dart-core בלבד). המנוע פספס: +→Number, ?? →||-אמת, dynamic→Map.
num boqLineAmount(Map<String, dynamic> n) {
  final num a = _jsNumber(n['eyes']);        // +n.eyes
  final num left = _jsTruthyNum(a) ? a : 0;  // (+n.eyes || 0)
  final Object? r = _jsTruthy(n['rate']) ? n['rate'] : 0; // (n.rate || 0)
  return left * _jsNumber(r);                // ה-* של JS ממיר ToNumber
}

// המרת-JS Number(): מספר→עצמו, מחרוזת→פרסור (ריק→0, לא-מספרי→NaN),
// bool→1/0, null/undefined→NaN.
num _jsNumber(Object? v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return 0;
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

// אמת-JS על ערך גולמי: null=false, bool=עצמו, num=לא-0-ולא-NaN,
// String=לא-ריק, אחר=true.
bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

// אמת-JS על מספר (עבור ||0): לא-0 ולא-NaN.
bool _jsTruthyNum(num n) => n != 0 && !n.isNaN;
