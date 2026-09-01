// ⚛️ אטום-Dart (דרגת-חוזה) · ayinBoardItems — פריטי-לוח שטוחים מכרטיסי מעקב-הטיפול.
// מוצא: maor/src/lib/ayin.ts:335-357 · המקור: new/atoms/ayin-board-items.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: כל השמות בכרטיסי-הטיפול כפריטי-לוח שטוחים — תומך בלי ayin מדולג ·
//        שם ריק/רווחים מדולג · ayin חלקי ממוזג עם emptyAyin.
// שקע (חוק-1): emptyAyin() — תיק-ריק עם כל המערכים (במקור קריאת-שכן שהוזרקה כפרמטר).
// קלט: supporters[] ({id, name, phone?, ayin?}) · שקע emptyAyin.
// פלט: {supporterId, supporter, phone, name, eyes, note, done, stage}[].
//
// הערת-המרה (מקור→Dart):
//   · truthiness — JS `!sp.ayin` / `sp.phone || ''` / `!!n.done` שוקפו ב-_truthy
//     (null/false/0/NaN/'' = כוזב; Map/List/String-לא-ריק = אמת).
//   · `+n.eyes` (כפייה-למספר) שוקף ב-_plus: מחרוזת→num.parse, מספר כמו-שהוא.
//     השומר `eyes !== '' && eyes != null` נשמר מילה-במילה ⇒ eyes ריק/null ⇒ '' (מחרוזת).
//   · `{...emptyAyin(), ...sp.ayin}` ⇒ spread-מיזוג של Map ב-Dart (ayin גובר).
//   · אין locale/פורמט/getMonth-אינדקס בקוד-זה.

/// כפייה-לבוליאני נאמנה ל-JS `!!x` / `x || …`: null/false/0/NaN/'' כוזב, השאר אמת.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

/// כפייה-למספר נאמנה ל-JS `+v`: מספר כמו-שהוא, מחרוזת→num.parse, בוליאני→0/1.
num _plus(Object? v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is String) return num.parse(v);
  throw ArgumentError('cannot coerce to number: $v');
}

/// מחזיר את כל שמות-הטיפול כפריטי-לוח שטוחים. התנהגות זהה-ביט למקור-ה-JS.
List<Map<String, Object?>> ayinBoardItems(
  List<Object?> supporters,
  Map<String, Object?> Function() emptyAyin,
) {
  final out = <Map<String, Object?>>[];
  for (final spRaw in supporters) {
    final sp = spRaw as Map;
    if (!_truthy(sp['ayin'])) continue; // JS: if (!sp.ayin) continue
    final Map<String, Object?> a = {
      ...emptyAyin(),
      ...(sp['ayin'] as Map).cast<String, Object?>(),
    };
    for (final nRaw in (a['names'] as List)) {
      final n = nRaw as Map;
      if ((n['name'] as String).trim().isEmpty) continue; // JS: if (!n.name.trim()) continue
      final eyesRaw = n['eyes'];
      out.add({
        'supporterId': sp['id'],
        'supporter': sp['name'],
        'phone': _truthy(sp['phone']) ? sp['phone'] : '',
        'name': n['name'],
        'eyes': (eyesRaw != '' && eyesRaw != null) ? _plus(eyesRaw) : '',
        'note': _truthy(n['note']) ? n['note'] : '',
        'done': _truthy(n['done']),
        'stage': a['stage'],
      });
    }
  }
  return out;
}
