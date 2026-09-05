// ⚛️ אטום-Dart (דרגת-חוזה) · parseVcards — פענוח קובץ vCard שלם ⇒ רשימת אנשי-קשר (סדר-הקובץ).
// מוצא: maor/src/lib/vcardImport.ts:153-228 · המקור: new/atoms/parse-vcards.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). חמשת שכני-הקובץ (unfoldLines/splitProperty/
//        decodeValue/phoneLabel/joinAddress) הוזרקו כשקעים בסדר הזה (חוק-1/חוק-3).
//
// תפקיד: מכונת-מצבים על שורות-לוגיות. BEGIN:VCARD פותח רשומה, END:VCARD דוחף אותה (בלי FN ⇒
//        שם מורכב "פרטי משפחה" מ-N); שורות מחוץ לכרטיס וריקות מדולגות; שדות לא-מוכרים
//        (PHOTO/URL/X-*) מדולגים. ORG: ; סופיים נחתכים, 'null' (כל רישיות) מסונן.
//        TEL/EMAIL ריקים לא נדחפים. דטרמיניסטי, טהור.
// קלט:  text (תוכן; null/ריק ⇒ []) + 5 השקעים. פלט:
//        List<Map>: {fullName, family, given, phones:[{value,label}], emails[], org, title, address, note}.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `text || ''` (falsy: null/undefined/'') — מחרוזת ריקה נשארת ריקה ⇒ `text ?? ''`
//    (Dart String לא-null; רק null נתפס). ריק ⇒ unfoldLines('') ⇒ הלולאה לא דוחפת ⇒ [].
//  • truthiness: `if (!trimmed)` / `if (!cur.fullName)` / `if (v)` = בדיקת-מחרוזת-ריקה של JS
//    ⇒ `.isEmpty` / `.isNotEmpty` מפורש (הערכים תמיד String לא-null כאן).
//  • `if (!cur)` / `if (!prop)` = null-check ⇒ `== null` (המפה או null בלבד; לא מחרוזת ריקה).
//  • `filter(Boolean).join(' ')` על [given, family] (שתי מחרוזות) ⇒ `.where(isNotEmpty).join(' ')`.
//  • regex `/^BEGIN:VCARD$/i` ⇒ `RegExp(..., caseSensitive:false)` — אותה סמנטיקה.
//  • `params.some(...)` / `.replace(/;+$/,'')` חיים בשקעים המוזרקים — לא באטום.
//  • מוטביליות: cur/out/phones/emails מוטבלים דרך add (final references). אין locale/פורמט/getMonth.

final RegExp _begin = RegExp(r'^BEGIN:VCARD$', caseSensitive: false);
final RegExp _end = RegExp(r'^END:VCARD$', caseSensitive: false);

/// Parses a whole vCard file text into a list of contact records, in file order.
/// State machine over logical lines. Verbatim port of new/atoms/parse-vcards.mjs
/// (`parseVcards`); the five file-neighbour helpers are injected as sockets (Law 1/3).
List<Map<String, dynamic>> parseVcards(
  String? text,
  List<String> Function(String) unfoldLines,
  Map<String, dynamic>? Function(String) splitProperty,
  String Function(String, List<String>) decodeValue,
  String Function(List<String>) phoneLabel,
  String Function(String, List<String>) joinAddress,
) {
  final lines = unfoldLines(text ?? '');
  final out = <Map<String, dynamic>>[];
  Map<String, dynamic>? cur;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (_begin.hasMatch(trimmed)) {
      cur = {
        'fullName': '',
        'family': '',
        'given': '',
        'phones': <Map<String, dynamic>>[],
        'emails': <String>[],
        'org': '',
        'title': '',
        'address': '',
        'note': '',
      };
      continue;
    }
    if (_end.hasMatch(trimmed)) {
      if (cur != null) {
        if ((cur['fullName'] as String).isEmpty) {
          cur['fullName'] = [cur['given'] as String, cur['family'] as String]
              .where((s) => s.isNotEmpty)
              .join(' ')
              .trim();
        }
        out.add(cur);
      }
      cur = null;
      continue;
    }
    if (cur == null) continue;
    final prop = splitProperty(line);
    if (prop == null) continue;
    final name = prop['name'] as String;
    final params = (prop['params'] as List).cast<String>();
    final value = prop['value'] as String;
    switch (name) {
      case 'FN':
        cur['fullName'] = decodeValue(value, params).trim();
        break;
      case 'N':
        {
          final decoded = decodeValue(value, params);
          final segs = decoded.split(';');
          cur['family'] = (segs.isNotEmpty ? segs[0] : '').trim();
          cur['given'] = (segs.length > 1 ? segs[1] : '').trim();
          break;
        }
      case 'TEL':
        {
          final v = value.trim();
          if (v.isNotEmpty) {
            (cur['phones'] as List).add({'value': v, 'label': phoneLabel(params)});
          }
          break;
        }
      case 'EMAIL':
        {
          final v = decodeValue(value, params).trim();
          if (v.isNotEmpty) (cur['emails'] as List).add(v);
          break;
        }
      case 'ORG':
        {
          final v = decodeValue(value, params).replaceAll(RegExp(r';+$'), '').trim();
          if (v.isNotEmpty && v.toLowerCase() != 'null') cur['org'] = v;
          break;
        }
      case 'TITLE':
        cur['title'] = decodeValue(value, params).trim();
        break;
      case 'ADR':
        cur['address'] = joinAddress(value, params);
        break;
      case 'NOTE':
        cur['note'] = decodeValue(value, params).trim();
        break;
      default:
        break; // PHOTO/URL/X-* וכו' — מדולגים
    }
  }
  return out;
}
