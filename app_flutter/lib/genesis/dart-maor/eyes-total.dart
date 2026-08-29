// חוט · eyes-total — סכום מוני-הפריטים (eyes) של תיק-עין. חוזה: ../atoms/eyes-total.contract.md
// המרה מ-JS (new/atoms/eyes-total.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4). אפס-import (dart-core בלבד).
// המקור: a.names.reduce((t, x) => t + (+x.eyes || 0), 0)
//   +x.eyes  = כפייה-מספרית של JS (מחרוזת-מספר→מספר, חסר/לא-מספרי→NaN)
//   || 0     = falsy-fallback של JS (NaN ו-0 falsy ⇒ 0; שלילי נשאר)

// שקע-כפייה: מחקה את +x של JS על הערכים שהחוזה מגדיר (מספר / מחרוזת / חסר).
num _coerce(dynamic x) {
  if (x is num) return x; // מספר כבר-מספר
  if (x is String) {
    final t = x.trim(); // +' 4 ' === 4
    if (t.isEmpty) return 0; // +'' === 0
    return num.tryParse(t) ?? double.nan; // 'שטויות' → NaN
  }
  return double.nan; // undefined/null/אחר → NaN (כמו +undefined)
}

// (+x.eyes || 0): ערך-falsy (NaN או 0) ⇒ 0; אחרת הערך (כולל שלילי).
num _eyesVal(dynamic x) {
  final c = _coerce(x);
  if (c.isNaN || c == 0) return 0;
  return c;
}

num eyesTotal(Map<String, dynamic> a) {
  final names = (a['names'] as List);
  num total = 0; // ערך-התחלה של reduce ⇒ ריק מחזיר 0
  for (final x in names) {
    total += _eyesVal((x as Map)['eyes']);
  }
  return total;
}
