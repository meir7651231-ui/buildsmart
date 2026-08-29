// ⚛️ אטום-Dart (דרגת-חוזה) · bulkWaRecipients — נמעני-וואטסאפ מרוכזים:
//    סינון-לפי-ספרות ⇒ דדופ ⇒ מדידה.
// מוצא: maor/src/lib/bulkContact.ts · המקור: new/atoms/bulk-wa-recipients.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן waDigits הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: שני-תורמים-אותו-טלפון = הודעה-אחת (דדופ לפי digits); טלפון לא-תקין
//        (waDigits ⇒ null/ריק) מסונן. phone המקורי נשמר בשורה כפי-שהוא.
// קלט:  sups (List של Map: id · name? · phone?) · השקע waDigits(phone) ⇒ ספרות-בינ"ל
//        או null. פלט: List<Map{id,name,phone,digits}> בסדר-המקור, ראשון-מנצח בדדופ.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע פספס בטיוטה):
//  • `sp.phone || ''` הוא truthiness-coalescing של JS (גם '' ⇒ ''), לא `??` —
//    מומש ב-`_falsy` (כלל-7 של DART-PORTING-RULES); המנוע פלט `sp.phone ?? ''`
//    וגם גישת-שדה על Map — תוקן ל-`sp['phone']`.
//  • `if (!digits)` — waDigits מחזיר null או מחרוזת; `_falsy` תופס null וגם ''
//    בדיוק כמו `!` של JS.
//  • `seen.has(digits)` של JS ⇒ `seen.contains(digits)` ב-Dart (המנוע השאיר .has).
//  • `sp.name || ''` — אותו truthiness-coalescing כמו phone.
//  • מוטביליות: seen/out הם final; התוכן מוטבל דרך add בלבד. אין locale/פורמט/
//    getMonth — כל לוגיקת-הטלפון חיה בשקע המוזרק.

/// חיקוי `!v` של JS לתחום-האטום: null/false/מחרוזת-ריקה/0/NaN ⇒ true (falsy).
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is String) return v.isEmpty;
  if (v is num) return v == 0 || (v is double && v.isNaN);
  return false;
}

/// Bulk WhatsApp recipients: filter by digits, dedup (first wins), keep original
/// phone. Verbatim port of new/atoms/bulk-wa-recipients.mjs (`bulkWaRecipients`);
/// the neighbour call `waDigits` is injected as a socket (Law 1/3).
List<Map<String, dynamic>> bulkWaRecipients(
  List<dynamic> sups,
  dynamic Function(dynamic) waDigits,
) {
  final seen = <dynamic>{};
  final out = <Map<String, dynamic>>[];
  for (final spRaw in sups) {
    final sp = spRaw as Map<String, dynamic>;
    final phone = sp['phone'];
    final digits = waDigits(_falsy(phone) ? '' : phone);
    if (_falsy(digits)) continue;
    if (seen.contains(digits)) continue;
    seen.add(digits);
    final name = sp['name'];
    out.add({
      'id': sp['id'],
      'name': _falsy(name) ? '' : name,
      'phone': phone,
      'digits': digits,
    });
  }
  return out;
}
