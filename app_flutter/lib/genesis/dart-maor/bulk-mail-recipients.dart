// ⚛️ אטום-Dart (דרגת-חוזה) · bulkMailRecipients — נמעני-מייל מרוכזים:
//    סינון ⇒ דדופ-לפי-כתובת-מנורמלת ⇒ מדידה. שומר את השם/מזהה של ה**ראשון**
//    באותה כתובת; שורה בלי @ מסוננת.
// מוצא: maor/src/lib/bulkContact.ts (בקשת-בעלים 25.8 "שליחה מרובה") ·
//        המקור: new/atoms/bulk-mail-recipients.mjs (חוק-4 verbatim — המקור קדוש).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core).
//        השכן normEmail הוזרק כשקע (חוק-1/חוק-3).
//
// קלט:  sups (List של תורמים: {id, name?, email?}) · השקע normEmail(String)⇒String
//        (נרמול-כתובת לצורכי-דדופ בלבד). פלט: List<Map{id,name,email}> בסדר-המקור.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע פספס):
//  • truthiness (כלל-7): `sp.email || ''` ו-`sp.name || ''` הם `||` של JS (מחרוזת-ריקה/
//    null/undefined ⇒ צד-ימין); `!e` = בדיקת-כזב על תוצאת-הנרמול. מומש ב-`_truthy`
//    שמחקה `!!` לתחום (null/bool/String/num) — לא `?? ''` (ה-?? מפספס '').
//  • המנוע פלט `seen.has(e)` — אין `has` ל-Set של Dart ⇒ `contains`.
//  • trim (כלל-16): `sp.email.trim()` = קבוצת-הרווחים של ECMAScript — Dart.trim גוזם
//    גם U+0085/U+180E ש-JS לא ⇒ `_jsTrim` נאמן-ES (inline מ-js-compat-reference).
//  • `e.includes('@')` ⇒ `e.contains('@')` (זהה למחרוזות).
//  • מוטביליות: seen/out נבנים דרך add בלבד; אין locale/getMonth/פורמט באטום זה.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/NaN/false ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// כלל-16 · קבוצת-הרווחים של ECMAScript (trim) — **בלי** U+0085/U+180E
/// (ש-Dart.trim גוזם אך JS לא).
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// כלל-16 · trim נאמן-ES (String.prototype.trim). גוזם רק את _esWs.
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

/// Bulk-mail recipients: filter (must contain '@' after normalization) ⇒ dedup by
/// normalized address (first supporter wins) ⇒ rows {id, name, email:trimmed-original}.
/// Verbatim port of new/atoms/bulk-mail-recipients.mjs (`bulkMailRecipients`);
/// the neighbour call `normEmail` is injected as a socket (Law 1/3).
List<Map<String, dynamic>> bulkMailRecipients(
  List<dynamic> sups,
  String Function(String) normEmail,
) {
  final seen = <String>{};
  final out = <Map<String, dynamic>>[];
  for (final spDyn in sups) {
    final sp = spDyn as Map<String, dynamic>;
    final emailRaw = _truthy(sp['email']) ? sp['email'] : '';
    final e = normEmail(emailRaw as String);
    if (!_truthy(e) || !e.contains('@')) continue;
    if (seen.contains(e)) continue;
    seen.add(e);
    out.add({
      'id': sp['id'],
      'name': _truthy(sp['name']) ? sp['name'] : '',
      'email': _jsTrim(sp['email'] as String),
    });
  }
  return out;
}
