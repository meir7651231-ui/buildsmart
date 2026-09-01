// ⚛️ אטום-Dart (דרגת-חוזה) · parseAyinSheet — פענוח גיליון-העיניים שחזר (round-trip מהלגאסי).
// מוצא: maor/src/lib/ayin.ts:443-501 · המקור: new/atoms/parse-ayin-sheet.mjs
//        (`export function parseAyinSheet(rows, supporters, normName)` — קריאת-השכן normName שוקעה, חוק-1).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). normName = שקע (פרמטר), לא מיובא.
//
// תפקיד: מקבל rows (List<List<String>> — CSV מפוענח), supporters (List<Map> עם name+ayin.names),
//        ו-normName (שקע-נורמליזציה) ⇒ מחזיר {upds, miss} או {upds, miss, error}.
//
// הערות-המרה (מקור→Dart) — למה הטיוטה-האוטומטית לא הספיקה:
//   * `str.replace(/\s+/g, ' ')` = replace-**כל**-ההתאמות ⇒ `replaceAll` (הטיוטה: `replaceFirst` — באג).
//   * `regex.test(v)` אינו Dart ⇒ `RegExp(...).hasMatch(v)`; ‏הדגל `/i` (case-insensitive) ⇒
//     `caseSensitive: false` (הטיוטה השמיטה — 'V'/'YES' לא היו נתפסים).
//   * `arr.find(pred)` מחזיר undefined כשאין ⇒ Dart `firstWhere` **זורק**; ‏משוחזר עם `orElse:()=>null`
//     ‏(הטיוטה: firstWhere חשוף — היה קורס על "שם לא-קיים"/miss).
//   * `ansRaw || null` = מחרוזת-ריקה⇒null ⇒ `ansRaw.isEmpty ? null : ansRaw` (הטיוטה: `ansRaw ?? null` —
//     שומר '' במקום null; כלל-truthiness).
//   * `+raw` (raw תואם `^\d+$`) ⇒ `int.parse(raw)` (מספר-שלם; JS מחזיר int לספרות).
//   * truthiness: `!nm`/`if(v)`/`v ? … : …` על מחרוזות ⇒ `.isEmpty`/`.isNotEmpty` מפורש (clean מחזיר תמיד String).
//   * גישת-property `x.ayin?.names`/`x.name`/`sp.id` ⇒ גישת-Map `x['ayin']?['names']`/`x['name']`/`sp['id']`
//     (הנתונים = מפות, לא מחלקות). `x.ayin?.names ?? []` ⇒ `_ayinNames` (null/חסר⇒[]).
//   * אינדוקס-שורה בטוח: JS `row[i]` על אינדקס-חורג = undefined ⇒ clean('') ; Dart `row[i]` זורק RangeError
//     ⇒ `_cell` מגן-גבולות (שורת-נתונים קצרה מהכותרת).
//   * מוטביליות: upds/miss הם var; השאר final. אין locale/getMonth/מודולו-שלילי/תאריך מעורבים.

/// גישה בטוחה לתא-שורה: מחזיר null (=undefined ב-JS) לאינדקס שלילי/חורג-גבולות.
dynamic _cell(List row, int i) => (i >= 0 && i < row.length) ? row[i] : null;

/// `x.ayin?.names ?? []` — רשימת-השמות של תומך, או [] כשחסר ayin/names.
List _ayinNames(Map x) {
  final a = x['ayin'];
  if (a is Map && a['names'] is List) return a['names'] as List;
  return const [];
}

/// Parses a round-tripped "eyes sheet" ([rows], header+data) against [supporters]
/// using the [normName] socket, returning `{upds, miss}` on success or
/// `{upds, miss, error}` on a bad file. Verbatim port of new/atoms/parse-ayin-sheet.mjs.
Map<String, dynamic> parseAyinSheet(
    List rows, List supporters, String Function(dynamic) normName) {
  if (rows.length < 2) {
    return {'upds': [], 'miss': 0, 'error': 'הקובץ ריק או לא בפורמט CSV'};
  }
  String clean(dynamic x) =>
      (x ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  final header =
      ((rows[0] ?? const []) as List).map((h) => clean(h)).toList();
  int hIdx(List<String> keys) =>
      header.indexWhere((h) => keys.any((k) => h.contains(k)));
  final iSup = hIdx(['תומכת', 'תומך']);
  final iNm = hIdx(['שם למסירה', 'שם לעופרת', 'שם']);
  final iEyes = hIdx(['עיניים']);
  final iDone = hIdx(['נמסר']);
  final iPaid = hIdx(['שולם', 'תשלום']);
  final iAns = hIdx(['תשובה', 'הערה']);
  final iLead = hIdx(['עופרת']);
  if (iNm < 0 || iEyes < 0) {
    return {
      'upds': [],
      'miss': 0,
      'error': 'חסרות עמודות "שם למסירה" ו/או "כמה עיניים"'
    };
  }
  bool yes(String v) =>
      RegExp(r'כן|yes|✓|v|שולם', caseSensitive: false).hasMatch(v);
  final upds = <Map<String, dynamic>>[];
  var miss = 0;
  for (var r = 1; r < rows.length; r++) {
    final row = (rows[r] ?? const []) as List;
    final supN = clean(iSup >= 0 ? _cell(row, iSup) : '');
    final nm = clean(_cell(row, iNm));
    if (nm.isEmpty) continue;
    final raw = clean(_cell(row, iEyes));
    final int? eyes = RegExp(r'^\d+$').hasMatch(raw) ? int.parse(raw) : null;
    final doneRaw = clean(iDone >= 0 ? _cell(row, iDone) : '');
    final paidRaw = iPaid >= 0 ? clean(_cell(row, iPaid)) : '';
    final ansRaw = iAns >= 0 ? clean(_cell(row, iAns)) : '';
    final leadRaw = iLead >= 0 ? clean(_cell(row, iLead)) : '';
    Map? sp;
    for (final x in supporters) {
      final xm = x as Map;
      final matchSup = supN.isEmpty || normName(xm['name']) == normName(supN);
      final matchName =
          _ayinNames(xm).any((n) => normName((n as Map)['name']) == normName(nm));
      if (matchSup && matchName) {
        sp = xm;
        break;
      }
    }
    if (sp == null) {
      miss++;
      continue;
    }
    Map? rec;
    for (final n in _ayinNames(sp)) {
      if (normName((n as Map)['name']) == normName(nm)) {
        rec = n;
        break;
      }
    }
    if (eyes == null &&
        doneRaw.isEmpty &&
        paidRaw.isEmpty &&
        ansRaw.isEmpty &&
        leadRaw.isEmpty) {
      continue;
    }
    upds.add({
      'supporterId': sp['id'],
      'nameId': rec!['id'],
      'eyes': eyes,
      'done': doneRaw.isNotEmpty ? yes(doneRaw) : null,
      'paid': paidRaw.isNotEmpty ? yes(paidRaw) : null,
      'answer': ansRaw.isEmpty ? null : ansRaw,
      'lead': leadRaw.isNotEmpty ? yes(leadRaw) : null,
    });
  }
  return {'upds': upds, 'miss': miss};
}
