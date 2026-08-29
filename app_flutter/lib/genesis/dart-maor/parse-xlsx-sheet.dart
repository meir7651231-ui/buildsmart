// ⚛️ אטום-Dart (דרגת-חוזה) · parseXlsxSheet — פענוח הגיליון הראשון של xlsx לרשת-תאים.
// מוצא: maor/src/lib/xlsx.ts:55-106 · המקור: new/atoms/parse-xlsx-sheet.mjs · חוזה: parse-xlsx-sheet.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). חמשת השכנים + תלות-fflate שוקעו כפרמטרים (חוק-1/3).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `files['xl/sharedStrings.xml'] ? ... : []`: truthiness של JS — מפתח-חסר/ריק ⇒ falsy.
//    מומש ב-`_truthy` (null/''/0/false ⇒ false; אובייקט/List ⇒ truthy — כמו Uint8Array בפרוד).
//  • `cm[2] ?? ''` / `vM ? ... : ''`: קבוצת-regex חסרה = null ב-Dart ⇒ `?? ''`/בדיקת-null — זהה ל-undefined.
//  • `shared[Number(raw)] ?? ''`: `Number` של JS (''→0, לא-מספר→NaN) + גישת-מערך (אינדקס לא-שלם/מחוץ-לתחום ⇒ undefined⇒'').
//    מומש ב-`_jsNumber` + שער-אינדקס (שלם, אי-שלילי, בתחום) — אחרת ''.
//  • `while (cells.length < idx) push('')` ואז `cells[idx]=val`: ב-Dart אין הרחבת-מערך בהשמה,
//    לכן `while (cells.length <= idx) add('')` ואז השמה — תוצאה זהה (ריפוד-פער ב-'' + כתיבה/דריסה).
//  • `[\s\S]` / `\b` נתמכים ב-Dart RegExp כלשונם.
List<List<String>> parseXlsxSheet(
  dynamic bytes,
  Map<String, dynamic> Function(dynamic) unzipSync,
  String Function(dynamic) strFromU8,
  List<String> Function(String) readSharedStrings,
  int Function(String) colRefToIndex,
  String Function(String) unescapeXml,
) {
  Map<String, dynamic> files;
  try {
    files = unzipSync(bytes);
  } catch (_) {
    return [];
  }
  final ss = files['xl/sharedStrings.xml'];
  final List<String> shared =
      _truthy(ss) ? readSharedStrings(strFromU8(ss)) : <String>[];
  // הגיליון בעל המספר הנמוך ביותר (sheet1.xml הוא הראשון בפועל בכל היצואים).
  final sheetRe = RegExp(r'^xl/worksheets/sheet\d+\.xml$');
  final sheetKeys = files.keys.where((n) => sheetRe.hasMatch(n)).toList()
    ..sort();
  if (sheetKeys.isEmpty) return [];
  final sheetPath = sheetKeys.first;
  final xml = strFromU8(files[sheetPath]);
  final rows = <List<String>>[];
  final rowRe = RegExp(r'<row\b[^>]*>([\s\S]*?)</row>');
  for (final rm in rowRe.allMatches(xml)) {
    final cells = <String>[];
    final cRe = RegExp(r'<c\b([^>]*?)(?:/>|>([\s\S]*?)</c>)');
    var auto = 0;
    for (final cm in cRe.allMatches(rm.group(1)!)) {
      final attrs = cm.group(1) ?? '';
      final inner = cm.group(2) ?? '';
      final refM = RegExp(r'r="([A-Z]+\d+)"').firstMatch(attrs);
      final idx = refM != null ? colRefToIndex(refM.group(1)!) : auto;
      final tM = RegExp(r't="([^"]+)"').firstMatch(attrs);
      final t = tM != null ? tM.group(1)! : '';
      var val = '';
      if (t == 'inlineStr') {
        // שרשור כל ה-<t> בתוך <is> (טקסט-עשיר מוטבע)
        final isRe = RegExp(r'<t[^>]*>([\s\S]*?)</t>');
        for (final im in isRe.allMatches(inner)) {
          val += im.group(1)!;
        }
        val = unescapeXml(val);
      } else {
        final vM = RegExp(r'<v>([\s\S]*?)</v>').firstMatch(inner);
        final raw = vM != null ? vM.group(1)! : '';
        if (t == 's') {
          final d = _jsNumber(raw);
          final ok = !d.isNaN &&
              d == d.truncateToDouble() &&
              d >= 0 &&
              d < shared.length;
          val = ok ? shared[d.toInt()] : '';
        } else {
          val = unescapeXml(raw);
        }
      }
      while (cells.length <= idx) {
        cells.add('');
      }
      cells[idx] = val;
      auto = idx + 1;
    }
    rows.add(cells);
  }
  return rows;
}

// truthiness של JS (מפתח-חסר/''/0/false/NaN ⇒ false; אחרת true).
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

// Number(x) של JS: ''/רווח-בלבד ⇒ 0; לא-מספר ⇒ NaN.
double _jsNumber(String s) {
  final t = s.trim();
  if (t.isEmpty) return 0;
  return double.tryParse(t) ?? double.nan;
}
