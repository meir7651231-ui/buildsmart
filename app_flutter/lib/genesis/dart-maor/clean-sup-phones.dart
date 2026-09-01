// ⚛️ אטום-Dart (דרגת-חוזה) · cleanSupPhones — ניקוי מערך-טלפונים לשמירה.
// מוצא: maor/src/components/supporters/lib.ts:300-304 · המקור: new/atoms/clean-sup-phones.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן fixPhone הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: מכל טלפון בונה עותק ({...p}) עם num=fixPhone(trim(num||'')), ואז מסנן שורות
//        עם num-ריק. שאר-שדות-השורה (label/note/...) נשמרים כפי-שהם (spread).
// קלט:  phones? = List של {num?, ...} · השקע fixPhone(num) ⇒ String מוזרק.
//        פלט: List<Map> — אותן שורות, num מנוקה, ריקי-num מסוננים.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס; הטיוטה dart-from-maor הייתה ריקה):
//  • `phones ?? []` → `(phones ?? const [])` — ה-`??` תופס null בלבד (זהה JS/Dart).
//  • `{ ...p, num: fixPhone((p.num || '').trim()) }` → spread של Map ואז דריסת 'num'.
//    ב-Dart, כמו ב-JS, מפתח-קיים בזמן-הדריסה שומר על מיקום-ההוספה המקורי (LinkedHashMap /
//    insertion-order) ⇒ סדר-המפתחות בפלט זהה למקור (בדוגמאות: num ואז label).
//  • `p.num || ''` = OR-truthiness של JS: num-ריק/null ⇒ '' (לא num). מומש ב-`_truthy`
//    (מחרוזת-ריקה=false) — כך '   ' עובר-trim ל-'' ומסונן, בדיוק כמו במקור.
//  • `.filter((p) => p.num)` = בדיקת-אמת: שומר רק num לא-ריק ⇒ `_truthy(num)`.
//  • מוטביליות: `out` הוא final (מוטבל דרך add); שאר-המקומיים final. אין locale/פורמט/
//    getMonth — הפורמט חי כולו בשקע fixPhone המוזרק.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/false/NaN ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// Clean a supporter's phones for saving: for each entry keep all its fields and set
/// num = fixPhone((num || '').trim()), then drop entries whose resulting num is empty.
/// Verbatim port of new/atoms/clean-sup-phones.mjs (`cleanSupPhones`); the neighbour call
/// fixPhone is injected as a socket (Law 1/3).
List<Map<String, dynamic>> cleanSupPhones(
  List<Map<String, dynamic>>? phones,
  String Function(String) fixPhone,
) {
  final out = <Map<String, dynamic>>[];
  for (final p in (phones ?? const <Map<String, dynamic>>[])) {
    final raw = p['num'];
    final base = _truthy(raw) ? (raw as String) : '';
    final num = fixPhone(base.trim());
    if (!_truthy(num)) continue;
    out.add({...p, 'num': num});
  }
  return out;
}
