/// חוט · parse-csv — פורט Dart מ-maor/src/lib/csvx.ts (parseCsv). חוזה: parse-csv.contract.md
/// התנהגות זהה-ביט למקור-ה-JS (new/atoms/parse-csv.mjs). אפס import (dart-core בלבד).
List<List<String>> parseCsv(String text) {
  // JS: text.replace(/^﻿/, '') — הסרת BOM בתחילת המחרוזת בלבד.
  final t = text.startsWith('﻿') ? text.substring(1) : text;
  // JS: t[i+1] מחזיר undefined מחוץ-לגבול; ב-Dart t[j] זורק RangeError. שקע-גישה בטוח מחזיר '' (≠ כל ערך-השוואה).
  String at(int j) => (j >= 0 && j < t.length) ? t[j] : '';
  // זיהוי-מפריד (הכרעת-בעלים 9.8): שורה ראשונה עם יותר טאבים מפסיקים ⇒ TSV, אחרת פסיקים.
  final nl = t.indexOf('\n');
  final firstLine = nl < 0 ? t : t.substring(0, nl);
  final tabs = firstLine.split('\t').length - 1;
  final commas = firstLine.split(',').length - 1;
  final delim = tabs > commas ? '\t' : ',';
  final rows = <List<String>>[];
  var row = <String>[];
  var cur = '';
  var q = false;
  for (var i = 0; i < t.length; i++) {
    final ch = t[i];
    if (q) {
      if (ch == '"' && at(i + 1) == '"') {
        cur += '"';
        i++;
      } else if (ch == '"' &&
          (i + 1 >= t.length ||
              at(i + 1) == delim ||
              at(i + 1) == '\n' ||
              at(i + 1) == '\r')) {
        q = false;
      } else {
        cur += ch;
      }
    } else if (ch == '"' && cur == '') {
      q = true;
    } else if (ch == delim) {
      row.add(cur);
      cur = '';
    } else if (ch == '\n' || ch == '\r') {
      if (ch == '\r' && at(i + 1) == '\n') i++;
      row.add(cur);
      cur = '';
      if (row.any((c) => c.trim() != '')) rows.add(row);
      row = [];
    } else {
      cur += ch;
    }
  }
  if (cur != '' || row.isNotEmpty) {
    row.add(cur);
    if (row.any((c) => c.trim() != '')) rows.add(row);
  }
  return rows;
}
